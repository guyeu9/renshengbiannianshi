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
    await transaction(() async {
      await (delete(db.timelineEvents)
            ..where((t) => t.id.equals(id))
            ..where((t) => t.eventType.equals('moment')))
          .go();
      await (delete(db.momentRecords)..where((t) => t.id.equals(id))).go();
    });
    await _changeLogRecorder.recordDelete(
      entityType: 'moment_records',
      entityId: id,
    );
  }

  Future<void> softDeleteById(String id, {required DateTime now}) async {
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
}
