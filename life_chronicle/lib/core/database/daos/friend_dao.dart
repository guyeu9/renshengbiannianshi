part of '../app_database.dart';

@DriftAccessor(tables: [FriendRecords])
class FriendDao extends DatabaseAccessor<AppDatabase> with _$FriendDaoMixin {
  FriendDao(super.db);

  Future<void> upsert(FriendRecordsCompanion entry) async {
    await into(db.friendRecords).insertOnConflictUpdate(entry);
  }

  Future<void> softDeleteById(String id, {required DateTime now}) async {
    await (update(db.friendRecords)..where((t) => t.id.equals(id))).write(
      FriendRecordsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
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
  }

  Stream<List<FriendRecord>> watchAllActive() {
    return (select(db.friendRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .watch();
  }
}
