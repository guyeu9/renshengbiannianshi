part of '../app_database.dart';

@DriftAccessor(tables: [GoalRecords])
class GoalDao extends DatabaseAccessor<AppDatabase> with _$GoalDaoMixin {
  GoalDao(super.db);

  late final ChangeLogRecorder _changeLogRecorder = ChangeLogRecorder(db);

  Future<void> upsert(GoalRecordsCompanion entry) async {
    await into(db.goalRecords).insertOnConflictUpdate(entry);
    await _changeLogRecorder.recordInsert(
      entityType: 'goal_records',
      entityId: entry.id.value,
    );
    final textParts = <String>[];
    if (entry.title.present) {
      textParts.add(entry.title.value);
    }
    if (entry.note.present && entry.note.value != null) {
      textParts.add(entry.note.value!);
    }
    if (entry.summary.present && entry.summary.value != null) {
      textParts.add(entry.summary.value!);
    }
    final text = textParts.join(' ');
    if (text.isNotEmpty && db.vectorIndexManager != null) {
      await db.vectorIndexManager!.recordInsert(
        entityType: 'goal',
        entityId: entry.id.value,
        text: text,
      );
    }
  }

  Future<void> softDeleteById(String id, {required DateTime now}) async {
    await (update(db.goalRecords)..where((t) => t.id.equals(id))).write(
      GoalRecordsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    await _changeLogRecorder.recordDelete(
      entityType: 'goal_records',
      entityId: id,
    );
    if (db.vectorIndexManager != null) {
      await db.vectorIndexManager!.recordDelete(
        entityType: 'goal',
        entityId: id,
      );
    }
  }

  Future<void> updateFavorite(String id, {required bool isFavorite, required DateTime now}) async {
    await (update(db.goalRecords)..where((t) => t.id.equals(id))).write(
      GoalRecordsCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(now),
      ),
    );
    await _changeLogRecorder.recordUpdate(
      entityType: 'goal_records',
      entityId: id,
      changedFields: ['isFavorite'],
    );
  }

  Future<void> updateProgress(String id, {required double progress, required DateTime now}) async {
    await (update(db.goalRecords)..where((t) => t.id.equals(id))).write(
      GoalRecordsCompanion(
        progress: Value(progress),
        updatedAt: Value(now),
      ),
    );
    await _changeLogRecorder.recordUpdate(
      entityType: 'goal_records',
      entityId: id,
      changedFields: ['progress'],
    );
  }

  Future<void> updateCompletion(String id, {required bool isCompleted, required DateTime now}) async {
    await (update(db.goalRecords)..where((t) => t.id.equals(id))).write(
      GoalRecordsCompanion(
        isCompleted: Value(isCompleted),
        updatedAt: Value(now),
      ),
    );
    await _changeLogRecorder.recordUpdate(
      entityType: 'goal_records',
      entityId: id,
      changedFields: ['isCompleted'],
    );
  }

  Future<GoalRecord?> findById(String id) {
    return (select(db.goalRecords)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<GoalRecord?> watchById(String id) {
    return (select(db.goalRecords)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<GoalRecord>> watchAllActive() {
    return (select(db.goalRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<GoalRecord>> watchUncompletedYearGoals() {
    return (select(db.goalRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.level.equals('year'))
          ..where((t) => t.isCompleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<GoalRecord>> watchByParentId(String parentId) {
    return (select(db.goalRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.parentId.equals(parentId))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<GoalRecord>> watchByLevel(String level) {
    return (select(db.goalRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.level.equals(level))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<GoalRecord>> watchByRecordDateRange(DateTime start, DateTime endExclusive) {
    return (select(db.goalRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
          ..where((t) => t.recordDate.isSmallerThanValue(endExclusive))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<GoalRecord>> searchGoals(String query) async {
    if (query.trim().isEmpty) return [];

    final rows = await customSelect(
      '''
      SELECT gr.* FROM goal_records gr
      JOIN goal_records_fts fts ON gr.rowid = fts.rowid
      WHERE goal_records_fts MATCH ? AND gr.is_deleted = 0
      ORDER BY gr.record_date DESC
      ''',
      variables: [Variable.withString(query)],
      readsFrom: {goalRecords},
    ).get();

    return rows.map((row) => db.goalRecords.map(row.data)).toList();
  }
}
