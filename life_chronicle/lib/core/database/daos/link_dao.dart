part of '../app_database.dart';

@DriftAccessor(tables: [EntityLinks, LinkLogs])
class LinkDao extends DatabaseAccessor<AppDatabase> with _$LinkDaoMixin {
  LinkDao(super.db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  Future<bool> linkExists({
    required String sourceType,
    required String sourceId,
    required String targetType,
    required String targetId,
  }) async {
    final row = await (select(db.entityLinks)
          ..where((t) => t.sourceType.equals(sourceType))
          ..where((t) => t.sourceId.equals(sourceId))
          ..where((t) => t.targetType.equals(targetType))
          ..where((t) => t.targetId.equals(targetId))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> createLink({
    required String sourceType,
    required String sourceId,
    required String targetType,
    required String targetId,
    String linkType = 'manual',
    required DateTime now,
  }) async {
    final linkId = _uuid.v4();
    final logId = _uuid.v4();

    await transaction(() async {
      await into(db.entityLinks).insert(
        EntityLinksCompanion.insert(
          id: linkId,
          sourceType: sourceType,
          sourceId: sourceId,
          targetType: targetType,
          targetId: targetId,
          linkType: Value(linkType),
          createdAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );

      await into(db.linkLogs).insert(
        LinkLogsCompanion.insert(
          id: logId,
          sourceType: sourceType,
          sourceId: sourceId,
          targetType: targetType,
          targetId: targetId,
          action: 'create',
          linkType: Value(linkType),
          createdAt: now,
        ),
      );
    });
    await _syncGoalsAfterLinkChange(
      sourceType: sourceType,
      sourceId: sourceId,
      targetType: targetType,
      targetId: targetId,
      now: now,
    );
  }

  Future<void> deleteLink({
    required String sourceType,
    required String sourceId,
    required String targetType,
    required String targetId,
    String? linkType,
    required DateTime now,
  }) async {
    final logId = _uuid.v4();

    await transaction(() async {
      await (delete(db.entityLinks)
            ..where((t) => t.sourceType.equals(sourceType))
            ..where((t) => t.sourceId.equals(sourceId))
            ..where((t) => t.targetType.equals(targetType))
            ..where((t) => t.targetId.equals(targetId)))
          .go();

      await into(db.linkLogs).insert(
        LinkLogsCompanion.insert(
          id: logId,
          sourceType: sourceType,
          sourceId: sourceId,
          targetType: targetType,
          targetId: targetId,
          action: 'delete',
          linkType: Value(linkType),
          createdAt: now,
        ),
      );
    });
    await _syncGoalsAfterLinkChange(
      sourceType: sourceType,
      sourceId: sourceId,
      targetType: targetType,
      targetId: targetId,
      now: now,
    );
  }

  Stream<List<EntityLink>> watchLinksForEntity({
    required String entityType,
    required String entityId,
  }) {
    final query = select(db.entityLinks)
      ..where(
        (t) =>
            (t.sourceType.equals(entityType) & t.sourceId.equals(entityId)) |
            (t.targetType.equals(entityType) & t.targetId.equals(entityId)),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    return query.watch();
  }

  Future<List<EntityLink>> listLinksForEntity({
    required String entityType,
    required String entityId,
  }) {
    final query = select(db.entityLinks)
      ..where(
        (t) =>
            (t.sourceType.equals(entityType) & t.sourceId.equals(entityId)) |
            (t.targetType.equals(entityType) & t.targetId.equals(entityId)),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    return query.get();
  }

  Future<void> syncGoalProgress({required String goalId, required DateTime now}) async {
    final goal = await (db.select(db.goalRecords)
          ..where((t) => t.id.equals(goalId))
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .getSingleOrNull();
    if (goal == null) return;

    final quarters = await (db.select(db.goalRecords)
          ..where((t) => t.parentId.equals(goalId))
          ..where((t) => t.level.equals('quarter'))
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    final quarterIds = quarters.map((q) => q.id).toList(growable: false);
    if (quarterIds.isNotEmpty) {
      final tasks = await (db.select(db.goalRecords)
            ..where((t) => t.parentId.isIn(quarterIds))
            ..where((t) => t.level.equals('daily'))
            ..where((t) => t.isDeleted.equals(false)))
          .get();
      if (tasks.isNotEmpty) {
        final taskProgress = tasks.where((t) => t.isCompleted).length / tasks.length;
        await (db.update(db.goalRecords)..where((t) => t.id.equals(goalId))).write(
          GoalRecordsCompanion(
            progress: Value(taskProgress),
            isCompleted: Value(taskProgress >= 1),
            updatedAt: Value(now),
          ),
        );
        return;
      }
    }

    final links = await listLinksForEntity(entityType: 'goal', entityId: goalId);
    if (links.isEmpty) {
      await (db.update(db.goalRecords)..where((t) => t.id.equals(goalId))).write(
        GoalRecordsCompanion(
          progress: const Value(0.0),
          isCompleted: const Value(false),
          updatedAt: Value(now),
        ),
      );
      return;
    }

    final momentIds = <String>{};
    final foodIds = <String>{};
    final travelIds = <String>{};
    final friendIds = <String>{};
    for (final link in links) {
      final isSource = link.sourceType == 'goal' && link.sourceId == goalId;
      final otherType = isSource ? link.targetType : link.sourceType;
      final otherId = isSource ? link.targetId : link.sourceId;
      if (otherType == 'moment') {
        momentIds.add(otherId);
      } else if (otherType == 'food') {
        foodIds.add(otherId);
      } else if (otherType == 'travel') {
        travelIds.add(otherId);
      } else if (otherType == 'friend') {
        friendIds.add(otherId);
      }
    }

    var total = 0;
    var completed = 0;

    if (momentIds.isNotEmpty) {
      final moments = await (db.select(db.momentRecords)
            ..where((t) => t.id.isIn(momentIds.toList()))
            ..where((t) => t.isDeleted.equals(false)))
          .get();
      total += moments.length;
      completed += moments.length;
    }

    if (foodIds.isNotEmpty) {
      final foods = await (db.select(db.foodRecords)
            ..where((t) => t.id.isIn(foodIds.toList()))
            ..where((t) => t.isDeleted.equals(false)))
          .get();
      total += foods.length;
      completed += foods.where((f) => !f.isWishlist || f.wishlistDone).length;
    }

    if (travelIds.isNotEmpty) {
      final travels = await (db.select(db.travelRecords)
            ..where((t) => t.id.isIn(travelIds.toList()))
            ..where((t) => t.isDeleted.equals(false)))
          .get();
      total += travels.length;
      completed += travels.where((t) => !t.isWishlist || t.wishlistDone).length;
    }

    if (friendIds.isNotEmpty) {
      final friends = await (db.select(db.friendRecords)
            ..where((t) => t.id.isIn(friendIds.toList()))
            ..where((t) => t.isDeleted.equals(false)))
          .get();
      total += friends.length;
      completed += friends.length;
    }

    final progress = total == 0 ? 0.0 : completed / total;
    await (db.update(db.goalRecords)..where((t) => t.id.equals(goalId))).write(
      GoalRecordsCompanion(
        progress: Value(progress),
        isCompleted: Value(progress >= 1 && total > 0),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> _syncGoalsAfterLinkChange({
    required String sourceType,
    required String sourceId,
    required String targetType,
    required String targetId,
    required DateTime now,
  }) async {
    if (sourceType == 'goal') {
      await syncGoalProgress(goalId: sourceId, now: now);
    }
    if (targetType == 'goal') {
      await syncGoalProgress(goalId: targetId, now: now);
    }
  }
}
