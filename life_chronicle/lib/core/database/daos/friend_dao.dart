part of '../app_database.dart';

@DriftAccessor(tables: [FriendRecords])
class FriendDao extends DatabaseAccessor<AppDatabase> with _$FriendDaoMixin {
  FriendDao(super.db);

  late final ChangeLogRecorder _changeLogRecorder = ChangeLogRecorder(db);

  Future<void> upsert(FriendRecordsCompanion entry) async {
    await into(db.friendRecords).insertOnConflictUpdate(entry);
    await _changeLogRecorder.recordInsert(
      entityType: 'friend_records',
      entityId: entry.id.value,
    );
  }

  Future<void> softDeleteById(String id, {required DateTime now}) async {
    final linkDao = LinkDao(db);
    final links = await linkDao.listLinksForEntity(entityType: 'friend', entityId: id);
    for (final link in links) {
      await linkDao.deleteLink(
        sourceType: link.sourceType,
        sourceId: link.sourceId,
        targetType: link.targetType,
        targetId: link.targetId,
        linkType: link.linkType,
        now: now,
      );
    }
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
