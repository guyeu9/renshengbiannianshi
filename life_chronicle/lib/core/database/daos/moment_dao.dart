part of '../app_database.dart';

@DriftAccessor(tables: [MomentRecords])
class MomentDao extends DatabaseAccessor<AppDatabase> with _$MomentDaoMixin {
  MomentDao(super.db);

  Future<void> upsert(MomentRecordsCompanion entry) async {
    await into(db.momentRecords).insertOnConflictUpdate(entry);
  }

  Future<void> softDeleteById(String id, {required DateTime now}) async {
    await (update(db.momentRecords)..where((t) => t.id.equals(id))).write(
      MomentRecordsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  Future<MomentRecord?> findById(String id) {
    return (select(db.momentRecords)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
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
}

