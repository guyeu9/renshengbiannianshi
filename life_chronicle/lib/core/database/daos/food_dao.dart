part of '../app_database.dart';

@DriftAccessor(tables: [FoodRecords])
class FoodDao extends DatabaseAccessor<AppDatabase> with _$FoodDaoMixin {
  FoodDao(super.db);

  Future<void> upsert(FoodRecordsCompanion entry) async {
    await into(db.foodRecords).insertOnConflictUpdate(entry);
  }

  Future<void> softDeleteById(String id, {required DateTime now}) async {
    await (update(db.foodRecords)..where((t) => t.id.equals(id))).write(
      FoodRecordsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  Future<FoodRecord?> findById(String id) {
    return (select(db.foodRecords)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
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
}

