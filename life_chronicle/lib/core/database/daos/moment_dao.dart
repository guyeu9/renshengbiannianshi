part of '../app_database.dart';

@DriftAccessor(tables: [MomentRecords])
class MomentDao extends DatabaseAccessor<AppDatabase> with _$MomentDaoMixin {
  MomentDao(super.db);

  late final ChangeLogRecorder _changeLogRecorder = ChangeLogRecorder(db);

  Future<void> upsert(MomentRecordsCompanion entry) async {
    await into(db.momentRecords).insertOnConflictUpdate(entry);
    await _changeLogRecorder.recordInsert(
      entityType: 'moment_records',
      entityId: entry.id.value,
    );
    final text = entry.content.present && entry.content.value != null ? entry.content.value! : '';
    if (text.isNotEmpty && db.vectorIndexManager != null) {
      await db.vectorIndexManager!.recordInsert(
        entityType: 'moment',
        entityId: entry.id.value,
        text: text,
      );
    }
  }

  Future<void> updateFavorite(String id, {required bool isFavorite, required DateTime now}) async {
    await (update(db.momentRecords)..where((t) => t.id.equals(id))).write(
      MomentRecordsCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(now),
      ),
    );
    await _changeLogRecorder.recordUpdate(
      entityType: 'moment_records',
      entityId: id,
      changedFields: ['isFavorite'],
    );
  }

  Future<void> deleteById(String id) async {
    // 先查询受影响的关联（双向查询）
    final links = await db.linkDao.listLinksForEntity(entityType: 'moment', entityId: id);

    // 收集受影响的朋友ID和目标ID
    final affectedFriendIds = <String>{};
    final affectedGoalIds = <String>{};
    for (final link in links) {
      if (link.sourceType == 'friend') affectedFriendIds.add(link.sourceId);
      if (link.targetType == 'friend') affectedFriendIds.add(link.targetId);
      if (link.sourceType == 'goal') affectedGoalIds.add(link.sourceId);
      if (link.targetType == 'goal') affectedGoalIds.add(link.targetId);
    }

    await transaction(() async {
      // 删除双向关联
      await (delete(db.entityLinks)
            ..where((t) => t.sourceType.equals('moment'))
            ..where((t) => t.sourceId.equals(id)))
          .go();
      await (delete(db.entityLinks)
            ..where((t) => t.targetType.equals('moment'))
            ..where((t) => t.targetId.equals(id)))
          .go();

      await (delete(db.timelineEvents)
            ..where((t) => t.id.equals(id))
            ..where((t) => t.eventType.equals('moment')))
          .go();

      await (delete(db.momentRecords)..where((t) => t.id.equals(id))).go();

      await _changeLogRecorder.recordDelete(
        entityType: 'moment_records',
        entityId: id,
      );

      if (db.vectorIndexManager != null) {
        await db.vectorIndexManager!.recordDelete(
          entityType: 'moment',
          entityId: id,
        );
      }
    });

    // 重新计算受影响朋友的 lastMeetDate
    for (final friendId in affectedFriendIds) {
      await db.linkDao.recalculateFriendLastMeetDate(friendId: friendId, now: DateTime.now());
    }

    // 同步受影响目标的进度
    for (final goalId in affectedGoalIds) {
      await db.linkDao.syncGoalProgress(goalId: goalId, now: DateTime.now());
    }
  }

  Future<void> softDeleteById(String id, {required DateTime now}) async {
    // 先查询受影响的关联（双向查询）
    final links = await db.linkDao.listLinksForEntity(entityType: 'moment', entityId: id);

    // 收集受影响的朋友ID和目标ID
    final affectedFriendIds = <String>{};
    final affectedGoalIds = <String>{};
    for (final link in links) {
      if (link.sourceType == 'friend') affectedFriendIds.add(link.sourceId);
      if (link.targetType == 'friend') affectedFriendIds.add(link.targetId);
      if (link.sourceType == 'goal') affectedGoalIds.add(link.sourceId);
      if (link.targetType == 'goal') affectedGoalIds.add(link.targetId);
    }

    await transaction(() async {
      // 删除双向关联
      await (delete(db.entityLinks)
            ..where((t) => t.sourceType.equals('moment'))
            ..where((t) => t.sourceId.equals(id)))
          .go();
      await (delete(db.entityLinks)
            ..where((t) => t.targetType.equals('moment'))
            ..where((t) => t.targetId.equals(id)))
          .go();

      // 软删除记录
      await (update(db.momentRecords)..where((t) => t.id.equals(id))).write(
        MomentRecordsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );

      await _changeLogRecorder.recordDelete(
        entityType: 'moment_records',
        entityId: id,
      );

      if (db.vectorIndexManager != null) {
        await db.vectorIndexManager!.recordDelete(
          entityType: 'moment',
          entityId: id,
        );
      }
    });

    // 重新计算受影响朋友的 lastMeetDate
    for (final friendId in affectedFriendIds) {
      await db.linkDao.recalculateFriendLastMeetDate(friendId: friendId, now: now);
    }

    // 同步受影响目标的进度
    for (final goalId in affectedGoalIds) {
      await db.linkDao.syncGoalProgress(goalId: goalId, now: now);
    }
  }

  Future<MomentRecord?> findById(String id) {
    return (select(db.momentRecords)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<MomentRecord?> watchById(String id) {
    return (select(db.momentRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<MomentRecord>> watchAllActive() {
    return (select(db.momentRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<MomentRecord>> watchByRecordDateRange(DateTime start, DateTime endExclusive) {
    return (select(db.momentRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(endExclusive))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<MomentRecord>> searchMoments(String query) async {
    if (query.trim().isEmpty) return [];

    final rows = await customSelect(
      '''
      SELECT mr.* FROM moment_records mr
      JOIN moment_records_fts fts ON mr.rowid = fts.rowid
      WHERE moment_records_fts MATCH ? AND mr.is_deleted = 0
      ORDER BY mr.record_date DESC
      ''',
      variables: [Variable.withString(query)],
      readsFrom: {momentRecords},
    ).get();

    return rows.map((row) => db.momentRecords.map(row.data)).toList();
  }
}
