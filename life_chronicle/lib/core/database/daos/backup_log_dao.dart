part of '../app_database.dart';

@DriftAccessor(tables: [BackupLogs])
class BackupLogDao extends DatabaseAccessor<AppDatabase> with _$BackupLogDaoMixin {
  BackupLogDao(super.db);

  Future<void> insert(BackupLogsCompanion entry) async {
    await into(db.backupLogs).insert(entry);
  }

  Future<void> updateStatus(String id, String status, {String? errorMessage, DateTime? completedAt}) async {
    await (update(db.backupLogs)..where((t) => t.id.equals(id))).write(
      BackupLogsCompanion(
        status: Value(status),
        errorMessage: Value(errorMessage),
        completedAt: Value(completedAt),
      ),
    );
  }

  Future<List<BackupLog>> findAll() {
    return (select(db.backupLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Stream<List<BackupLog>> watchAll() {
    return (select(db.backupLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Stream<List<BackupLog>> watchByStorageType(String storageType) {
    return (select(db.backupLogs)
          ..where((t) => t.storageType.equals(storageType))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<BackupLog?> findLatestByStorageType(String storageType) async {
    return (select(db.backupLogs)
          ..where((t) => t.storageType.equals(storageType))
          ..where((t) => t.status.equals('completed'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<BackupLog?> findLatestSuccessful() async {
    return (select(db.backupLogs)
          ..where((t) => t.status.equals('completed'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> deleteById(String id) async {
    await (delete(db.backupLogs)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteOlderThan(DateTime date) async {
    await (delete(db.backupLogs)..where((t) => t.createdAt.isSmallerThanValue(date))).go();
  }

  Future<int> countByStatus(String status) async {
    final count = db.backupLogs.id.count();
    final query = selectOnly(db.backupLogs, distinct: false)
      ..addColumns([count])
      ..where(db.backupLogs.status.equals(status));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
