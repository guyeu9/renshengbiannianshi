part of '../app_database.dart';

@DriftAccessor(tables: [FoodRecords])
class FoodDao extends DatabaseAccessor<AppDatabase> with _$FoodDaoMixin {
  FoodDao(super.db);

  late final ChangeLogRecorder _changeLogRecorder = ChangeLogRecorder(db);

  Future<void> upsert(FoodRecordsCompanion entry) async {
    await into(db.foodRecords).insertOnConflictUpdate(entry);
    await _changeLogRecorder.recordInsert(
      entityType: 'food_records',
      entityId: entry.id.value,
    );
  }

  Future<void> softDeleteById(String id, {required DateTime now}) async {
    await (update(db.foodRecords)..where((t) => t.id.equals(id))).write(
      FoodRecordsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    await _changeLogRecorder.recordDelete(
      entityType: 'food_records',
      entityId: id,
    );
  }

  Future<void> updateFavorite(String id, {required bool isFavorite, required DateTime now}) async {
    await (update(db.foodRecords)..where((t) => t.id.equals(id))).write(
      FoodRecordsCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(now),
      ),
    );
    await _changeLogRecorder.recordUpdate(
      entityType: 'food_records',
      entityId: id,
      changedFields: ['isFavorite'],
    );
  }

  Future<void> updateWishlistStatus(String id, {required bool isWishlist, required bool wishlistDone, required DateTime now}) async {
    await (update(db.foodRecords)..where((t) => t.id.equals(id))).write(
      FoodRecordsCompanion(
        isWishlist: Value(isWishlist),
        wishlistDone: Value(wishlistDone),
        updatedAt: Value(now),
      ),
    );
    await _changeLogRecorder.recordUpdate(
      entityType: 'food_records',
      entityId: id,
      changedFields: ['isWishlist', 'wishlistDone'],
    );
  }

  Future<FoodRecord?> findById(String id) {
    return (select(db.foodRecords)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<FoodRecord?> watchById(String id) {
    return (select(db.foodRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<FoodRecord>> watchAllActive() {
    return (select(db.foodRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<FoodRecord>> watchByRecordDateRange(DateTime start, DateTime endExclusive) {
    return (select(db.foodRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(endExclusive))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<FoodRecord>> searchFood(String query) async {
    if (query.trim().isEmpty) return [];

    final rows = await customSelect(
      '''
      SELECT fr.* FROM food_records fr
      JOIN food_records_fts fts ON fr.rowid = fts.rowid
      WHERE food_records_fts MATCH ? AND fr.is_deleted = 0
      ORDER BY fr.record_date DESC
      ''',
      variables: [Variable.withString(query)],
      readsFrom: {foodRecords},
    ).get();

    return rows.map((row) => db.foodRecords.map(row.data)).toList();
  }
}
