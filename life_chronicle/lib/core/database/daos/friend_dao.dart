part of '../app_database.dart';

@DriftAccessor(tables: [FriendRecords])
class FriendDao extends DatabaseAccessor<AppDatabase> with _$FriendDaoMixin {
  FriendDao(super.db);

  late final ChangeLogRecorder _changeLogRecorder = ChangeLogRecorder(db);
  final Uuid _uuid = const Uuid();

  Future<void> upsert(FriendRecordsCompanion entry) async {
    await into(db.friendRecords).insertOnConflictUpdate(entry);
    await _changeLogRecorder.recordInsert(
      entityType: 'friend_records',
      entityId: entry.id.value,
    );
  }

  Future<void> softDeleteById(String id, {required DateTime now}) async {
    // 先查询受影响的关联（双向查询）
    final links = await (select(db.entityLinks)
          ..where((t) =>
              (t.sourceType.equals('friend') & t.sourceId.equals(id)) |
              (t.targetType.equals('friend') & t.targetId.equals(id))))
        .get();

    // 收集受影响的目标ID
    final affectedGoalIds = <String>{};
    for (final link in links) {
      if (link.sourceType == 'goal') affectedGoalIds.add(link.sourceId);
      if (link.targetType == 'goal') affectedGoalIds.add(link.targetId);
    }

    await transaction(() async {
      for (final link in links) {
        await into(db.linkLogs).insert(
          LinkLogsCompanion.insert(
            id: _uuid.v4(),
            sourceType: link.sourceType,
            sourceId: link.sourceId,
            targetType: link.targetType,
            targetId: link.targetId,
            action: 'delete',
            linkType: Value(link.linkType),
            createdAt: now,
          ),
        );
      }

      // 删除双向关联
      await (delete(db.entityLinks)
            ..where((t) =>
                (t.sourceType.equals('friend') & t.sourceId.equals(id)) |
                (t.targetType.equals('friend') & t.targetId.equals(id))))
          .go();

      // 软删除记录
      await (update(db.friendRecords)..where((t) => t.id.equals(id))).write(
        FriendRecordsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );

      await _changeLogRecorder.recordDelete(
        entityType: 'friend_records',
        entityId: id,
      );
    });

    // 同步受影响目标的进度
    for (final goalId in affectedGoalIds) {
      await db.linkDao.syncGoalProgress(goalId: goalId, now: now);
    }
  }

  Future<FriendRecord?> findById(String id) {
    return (select(db.friendRecords)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<FriendRecord?> watchById(String id) {
    return (select(db.friendRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<void> updateFavorite(String id, {required bool isFavorite, required DateTime now}) async {
    await (update(db.friendRecords)..where((t) => t.id.equals(id))).write(
      FriendRecordsCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(now),
      ),
    );
    await _changeLogRecorder.recordUpdate(
      entityType: 'friend_records',
      entityId: id,
      changedFields: ['isFavorite'],
    );
  }

  Stream<List<FriendRecord>> watchAllActive() {
    return (select(db.friendRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm(expression: t.isFavorite, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }
}
