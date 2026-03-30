part of '../app_database.dart';

/// 万物互联核心组件
///
/// ## 职责
/// 管理所有实体关联的创建、删除和查询。
///
/// ## 自动处理的后续逻辑
/// 当创建或删除关联时，会自动处理：
/// 1. **朋友的 lastMeetDate 更新**：如果关联/取消关联的是朋友
/// 2. **目标进度同步**：如果关联/取消关联的是目标
/// 3. **关联日志记录**：所有关联变更都会记录到 link_logs 表
///
/// ## 使用规范
/// - ✅ 所有关联操作都应通过此类进行
/// - ❌ 不要直接操作 entity_links 表
/// - ⚠️ 如果必须在其他地方删除关联，请确保手动调用后续处理方法
///
/// ## 示例
/// ```dart
/// // 创建关联
/// await db.linkDao.createLink(
///   sourceType: 'food',
///   sourceId: foodId,
///   targetType: 'friend',
///   targetId: friendId,
///   now: DateTime.now(),
/// );
///
/// // 删除关联
/// await db.linkDao.deleteLink(
///   sourceType: 'food',
///   sourceId: foodId,
///   targetType: 'friend',
///   targetId: friendId,
///   now: DateTime.now(),
/// );
/// ```
@DriftAccessor(tables: [EntityLinks, LinkLogs])
class LinkDao extends DatabaseAccessor<AppDatabase> with _$LinkDaoMixin {
  LinkDao(super.db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  late final ChangeLogRecorder _changeLogRecorder = ChangeLogRecorder(db);

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

  /// 获取源实体的记录日期
  Future<DateTime?> _getSourceRecordDate({
    required String sourceType,
    required String sourceId,
  }) async {
    switch (sourceType) {
      case 'encounter':
        final event = await (select(db.timelineEvents)
              ..where((t) => t.id.equals(sourceId))
              ..where((t) => t.isDeleted.equals(false))
              ..limit(1))
            .getSingleOrNull();
        return event?.startAt ?? event?.recordDate;

      case 'food':
        final food = await (select(db.foodRecords)
              ..where((t) => t.id.equals(sourceId))
              ..where((t) => t.isDeleted.equals(false))
              ..limit(1))
            .getSingleOrNull();
        return food?.recordDate;

      case 'moment':
        final moment = await (select(db.momentRecords)
              ..where((t) => t.id.equals(sourceId))
              ..where((t) => t.isDeleted.equals(false))
              ..limit(1))
            .getSingleOrNull();
        return moment?.recordDate;

      case 'travel':
        final travel = await (select(db.travelRecords)
              ..where((t) => t.id.equals(sourceId))
              ..where((t) => t.isDeleted.equals(false))
              ..limit(1))
            .getSingleOrNull();
        return travel?.recordDate;

      case 'goal':
        final goal = await (select(db.goalRecords)
              ..where((t) => t.id.equals(sourceId))
              ..where((t) => t.isDeleted.equals(false))
              ..limit(1))
            .getSingleOrNull();
        return goal?.dueDate ?? goal?.createdAt;

      case 'friend':
        final friend = await (select(db.friendRecords)
              ..where((t) => t.id.equals(sourceId))
              ..where((t) => t.isDeleted.equals(false))
              ..limit(1))
            .getSingleOrNull();
        return friend?.meetDate ?? friend?.createdAt;

      default:
        return null;
    }
  }

  /// 收集实体关联的朋友和目标ID
  ///
  /// 用于在删除实体前收集受影响的关联，以便后续处理：
  /// - 重新计算朋友的 lastMeetDate
  /// - 同步目标进度
  ///
  /// 参数：
  /// - [entityType] 实体类型
  /// - [entityId] 实体ID
  ///
  /// 返回：AffectedEntities 对象，包含受影响的朋友ID和目标ID列表
  Future<AffectedEntities> collectAffectedEntities({
    required String entityType,
    required String entityId,
  }) async {
    final links = await listLinksForEntity(entityType: entityType, entityId: entityId);

    final friendIds = <String>{};
    final goalIds = <String>{};

    for (final link in links) {
      if (link.sourceType == 'friend') friendIds.add(link.sourceId);
      if (link.targetType == 'friend') friendIds.add(link.targetId);
      if (link.sourceType == 'goal') goalIds.add(link.sourceId);
      if (link.targetType == 'goal') goalIds.add(link.targetId);
    }

    return AffectedEntities(
      friendIds: friendIds.toList(),
      goalIds: goalIds.toList(),
    );
  }

  /// 更新朋友的上次见面时间
  ///
  /// 如果新的见面时间比现有记录更新，则更新 lastMeetDate
  Future<void> _updateFriendLastMeetDate({
    required String friendId,
    required DateTime recordDate,
    required DateTime now,
  }) async {
    final friend = await (select(db.friendRecords)
          ..where((t) => t.id.equals(friendId))
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .getSingleOrNull();

    if (friend == null) return;

    // 只有当新日期比现有记录更新时才更新
    if (friend.lastMeetDate == null || recordDate.isAfter(friend.lastMeetDate!)) {
      await (update(db.friendRecords)..where((t) => t.id.equals(friendId))).write(
        FriendRecordsCompanion(
          lastMeetDate: Value(recordDate),
          updatedAt: Value(now),
        ),
      );
      await _changeLogRecorder.recordUpdate(
        entityType: 'friend_records',
        entityId: friendId,
        changedFields: ['lastMeetDate'],
      );
    }
  }

  /// 重新计算朋友的上次见面时间
  ///
  /// 从所有关联记录中查找最晚的日期作为 lastMeetDate
  Future<void> recalculateFriendLastMeetDate({
    required String friendId,
    required DateTime now,
  }) async {
    // 查询所有与该朋友关联的记录（双向查询）
    final links = await (select(db.entityLinks)
          ..where(
            (t) =>
                (t.targetType.equals('friend') & t.targetId.equals(friendId)) |
                (t.sourceType.equals('friend') & t.sourceId.equals(friendId)),
          ))
        .get();

    DateTime? maxDate;

    for (final link in links) {
      // 确定关联的另一方
      final otherType = link.sourceType == 'friend' ? link.targetType : link.sourceType;
      final otherId = link.sourceType == 'friend' ? link.targetId : link.sourceId;

      final recordDate = await _getSourceRecordDate(
        sourceType: otherType,
        sourceId: otherId,
      );
      if (recordDate != null && (maxDate == null || recordDate.isAfter(maxDate))) {
        maxDate = recordDate;
      }
    }

    await (update(db.friendRecords)..where((t) => t.id.equals(friendId))).write(
      FriendRecordsCompanion(
        lastMeetDate: Value(maxDate),
        updatedAt: Value(now),
      ),
    );

    if (maxDate != null) {
      await _changeLogRecorder.recordUpdate(
        entityType: 'friend_records',
        entityId: friendId,
        changedFields: ['lastMeetDate'],
      );
    }
  }

  /// 处理与朋友关联的变更
  ///
  /// 在创建或删除关联时调用，自动更新朋友的 lastMeetDate
  Future<void> _syncFriendLastMeetDate({
    required String? sourceType,
    required String? sourceId,
    required String? targetType,
    required String? targetId,
    required DateTime now,
    bool isDelete = false,
  }) async {
    // 处理 targetType == 'friend' 的情况
    if (targetType == 'friend' && targetId != null) {
      if (isDelete) {
        await recalculateFriendLastMeetDate(friendId: targetId, now: now);
      } else if (sourceType != null && sourceId != null) {
        final recordDate = await _getSourceRecordDate(
          sourceType: sourceType,
          sourceId: sourceId,
        );
        if (recordDate != null) {
          await _updateFriendLastMeetDate(
            friendId: targetId,
            recordDate: recordDate,
            now: now,
          );
        }
      }
    }

    // 处理 sourceType == 'friend' 的情况（双向关联）
    if (sourceType == 'friend' && sourceId != null) {
      if (isDelete) {
        await recalculateFriendLastMeetDate(friendId: sourceId, now: now);
      } else if (targetType != null && targetId != null) {
        final recordDate = await _getSourceRecordDate(
          sourceType: targetType,
          sourceId: targetId,
        );
        if (recordDate != null) {
          await _updateFriendLastMeetDate(
            friendId: sourceId,
            recordDate: recordDate,
            now: now,
          );
        }
      }
    }
  }

  /// 创建实体关联
  ///
  /// 创建关联后会自动：
  /// - 更新朋友的 lastMeetDate（如果关联的是朋友）
  /// - 同步目标进度（如果关联的是目标）
  /// - 记录关联创建日志
  ///
  /// 参数：
  /// - [sourceType] 源实体类型（food/moment/travel/goal/encounter/friend）
  /// - [sourceId] 源实体ID
  /// - [targetType] 目标实体类型
  /// - [targetId] 目标实体ID
  /// - [linkType] 关联类型，默认为 'manual'
  /// - [now] 当前时间
  Future<void> createLink({
    required String sourceType,
    required String sourceId,
    required String targetType,
    required String targetId,
    String linkType = 'manual',
    required DateTime now,
  }) async {
    if (targetType == 'travel') {
      final isValid = await isTravelRecord(targetId);
      if (!isValid) {
        return;
      }
    }
    if (sourceType == 'travel') {
      final isValid = await isTravelRecord(sourceId);
      if (!isValid) {
        return;
      }
    }

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

      await _changeLogRecorder.recordInsert(
        entityType: 'entity_links',
        entityId: linkId,
      );
    });

    // 同步朋友的上次见面时间
    await _syncFriendLastMeetDate(
      sourceType: sourceType,
      sourceId: sourceId,
      targetType: targetType,
      targetId: targetId,
      now: now,
      isDelete: false,
    );

    await _syncGoalsAfterLinkChange(
      sourceType: sourceType,
      sourceId: sourceId,
      targetType: targetType,
      targetId: targetId,
      now: now,
    );
  }

  /// 删除实体关联
  ///
  /// 删除关联后会自动：
  /// - 重新计算朋友的 lastMeetDate（如果关联的是朋友）
  /// - 同步目标进度（如果关联的是目标）
  /// - 记录关联删除日志
  ///
  /// 参数：
  /// - [sourceType] 源实体类型
  /// - [sourceId] 源实体ID
  /// - [targetType] 目标实体类型
  /// - [targetId] 目标实体ID
  /// - [linkType] 关联类型（可选）
  /// - [now] 当前时间
  Future<void> deleteLink({
    required String sourceType,
    required String sourceId,
    required String targetType,
    required String targetId,
    String? linkType,
    required DateTime now,
  }) async {
    final logId = _uuid.v4();
    
    final existingLinks = await (select(db.entityLinks)
          ..where((t) => t.sourceType.equals(sourceType))
          ..where((t) => t.sourceId.equals(sourceId))
          ..where((t) => t.targetType.equals(targetType))
          ..where((t) => t.targetId.equals(targetId)))
        .get();
    final linkIds = existingLinks.map((l) => l.id).toList();

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

      for (final linkId in linkIds) {
        await _changeLogRecorder.recordDelete(
          entityType: 'entity_links',
          entityId: linkId,
        );
      }
    });

    // 同步朋友的上次见面时间（删除后重新计算）
    await _syncFriendLastMeetDate(
      sourceType: sourceType,
      sourceId: sourceId,
      targetType: targetType,
      targetId: targetId,
      now: now,
      isDelete: true,
    );

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

  Stream<List<EntityLink>> watchLinksForEntities({
    required String entityType,
    required List<String> entityIds,
  }) {
    if (entityIds.isEmpty) return Stream.value(const []);
    final query = select(db.entityLinks)
      ..where(
        (t) =>
            (t.sourceType.equals(entityType) & t.sourceId.isIn(entityIds)) |
            (t.targetType.equals(entityType) & t.targetId.isIn(entityIds)),
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

  Future<List<EntityLink>> listLinksForEntities({
    required String entityType,
    required List<String> entityIds,
  }) {
    if (entityIds.isEmpty) return Future.value([]);
    final query = select(db.entityLinks)
      ..where(
        (t) =>
            (t.sourceType.equals(entityType) & t.sourceId.isIn(entityIds)) |
            (t.targetType.equals(entityType) & t.targetId.isIn(entityIds)),
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

  /// 删除实体的所有关联
  ///
  /// 删除关联后会自动：
  /// - 重新计算朋友的 lastMeetDate（如果关联的是朋友）
  /// - 同步目标进度（如果关联的是目标）
  /// - 记录关联删除日志
  ///
  /// 此方法会同时删除双向关联：
  /// - sourceType/sourceId 作为源的关联
  /// - targetType/targetId 作为目标的关联
  ///
  /// 参数：
  /// - [sourceType] 实体类型
  /// - [sourceId] 实体ID
  Future<void> deleteLinksBySource(String sourceType, String sourceId) async {
    final now = DateTime.now();
    // 查询双向关联（source 和 target 方向都要处理）
    final sourceLinks = await (select(db.entityLinks)
          ..where((t) => t.sourceType.equals(sourceType))
          ..where((t) => t.sourceId.equals(sourceId)))
        .get();
    final targetLinks = await (select(db.entityLinks)
          ..where((t) => t.targetType.equals(sourceType))
          ..where((t) => t.targetId.equals(sourceId)))
        .get();
    final existingLinks = [...sourceLinks, ...targetLinks];
    final linkIds = existingLinks.map((l) => l.id).toList();

    // 收集受影响的朋友ID（双向检查）
    final affectedFriendIds = <String>{};
    for (final link in existingLinks) {
      if (link.targetType == 'friend') {
        affectedFriendIds.add(link.targetId);
      }
      if (link.sourceType == 'friend') {
        affectedFriendIds.add(link.sourceId);
      }
    }

    // 收集受影响的目标ID（双向检查）
    final affectedGoalIds = <String>{};
    for (final link in existingLinks) {
      if (link.targetType == 'goal') {
        affectedGoalIds.add(link.targetId);
      }
      if (link.sourceType == 'goal') {
        affectedGoalIds.add(link.sourceId);
      }
    }

    await transaction(() async {
      // 删除双向关联
      await (delete(db.entityLinks)
            ..where((t) => t.sourceType.equals(sourceType))
            ..where((t) => t.sourceId.equals(sourceId)))
          .go();
      await (delete(db.entityLinks)
            ..where((t) => t.targetType.equals(sourceType))
            ..where((t) => t.targetId.equals(sourceId)))
          .go();

      for (final link in existingLinks) {
        final logId = _uuid.v4();
        await into(db.linkLogs).insert(
          LinkLogsCompanion.insert(
            id: logId,
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

      for (final linkId in linkIds) {
        await _changeLogRecorder.recordDelete(
          entityType: 'entity_links',
          entityId: linkId,
        );
      }
    });

    // 重新计算受影响朋友的 lastMeetDate
    for (final friendId in affectedFriendIds) {
      await recalculateFriendLastMeetDate(friendId: friendId, now: now);
    }

    // 同步受影响目标的进度
    for (final goalId in affectedGoalIds) {
      await syncGoalProgress(goalId: goalId, now: now);
    }
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

  Future<bool> isTravelRecord(String travelId) async {
    final record = await (select(db.travelRecords)
          ..where((t) => t.id.equals(travelId))
          ..limit(1))
        .getSingleOrNull();

    if (record == null) return false;

    return !record.isJournal;
  }

  Future<void> cleanupJournalLinks() async {
    final now = DateTime.now();

    final journals = await (select(db.travelRecords)
          ..where((t) => t.isJournal.equals(true))
          ..where((t) => t.isDeleted.equals(false)))
        .get();

    final journalIds = journals.map((j) => j.id).toList();

    if (journalIds.isEmpty) return;

    final existingLinks = await (select(db.entityLinks)
          ..where((t) => t.sourceType.equals('travel') & t.sourceId.isIn(journalIds))
          ..where((t) => t.targetType.equals('travel') & t.targetId.isIn(journalIds)))
        .get();

    final linkIds = existingLinks.map((l) => l.id).toList();

    // 收集受影响的朋友ID（虽然游记通常不关联朋友，但为了完整性）
    final affectedFriendIds = <String>{};

    await transaction(() async {
      await (delete(db.entityLinks)
            ..where((t) => t.sourceType.equals('travel') & t.sourceId.isIn(journalIds))
            ..where((t) => t.targetType.equals('travel') & t.targetId.isIn(journalIds)))
          .go();

      for (final link in existingLinks) {
        final logId = _uuid.v4();
        await into(db.linkLogs).insert(
          LinkLogsCompanion.insert(
            id: logId,
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
    });

    for (final linkId in linkIds) {
      await _changeLogRecorder.recordDelete(
        entityType: 'entity_links',
        entityId: linkId,
      );
    }

    // 重新计算受影响朋友的 lastMeetDate
    for (final friendId in affectedFriendIds) {
      await recalculateFriendLastMeetDate(friendId: friendId, now: now);
    }

    for (final link in existingLinks) {
      await _syncGoalsAfterLinkChange(
        sourceType: link.sourceType,
        sourceId: link.sourceId,
        targetType: link.targetType,
        targetId: link.targetId,
        now: now,
      );
    }
  }
}

/// 受影响的实体集合
///
/// 用于记录删除实体时受影响的朋友和目标ID
class AffectedEntities {
  /// 受影响的朋友ID列表
  final List<String> friendIds;

  /// 受影响的目标ID列表
  final List<String> goalIds;

  const AffectedEntities({
    required this.friendIds,
    required this.goalIds,
  });

  /// 是否有受影响的朋友
  bool get hasFriends => friendIds.isNotEmpty;

  /// 是否有受影响的目标
  bool get hasGoals => goalIds.isNotEmpty;

  /// 是否为空
  bool get isEmpty => friendIds.isEmpty && goalIds.isEmpty;

  /// 是否不为空
  bool get isNotEmpty => !isEmpty;
}
