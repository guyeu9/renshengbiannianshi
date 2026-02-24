part of '../app_database.dart';

@DriftAccessor(tables: [ChangeLogs])
class ChangeLogDao extends DatabaseAccessor<AppDatabase> with _$ChangeLogDaoMixin {
  ChangeLogDao(super.db);

  Future<void> insert(ChangeLogsCompanion entry) async {
    await into(db.changeLogs).insert(entry);
  }

  Future<void> markAsSynced(int id) async {
    await (update(db.changeLogs)..where((t) => t.id.equals(id))).write(
      const ChangeLogsCompanion(
        synced: Value(true),
      ),
    );
  }

  Future<void> markAllAsSyncedByIds(List<int> ids) async {
    if (ids.isEmpty) return;
    await (update(db.changeLogs)..where((t) => t.id.isIn(ids))).write(
      const ChangeLogsCompanion(
        synced: Value(true),
      ),
    );
  }

  Future<void> markAllAsSynced() async {
    await (update(db.changeLogs)).write(
      const ChangeLogsCompanion(
        synced: Value(true),
      ),
    );
  }

  Future<List<ChangeLog>> findUnsynced() {
    return (select(db.changeLogs)
          ..where((t) => t.synced.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  Future<List<ChangeLog>> findAll() {
    return (select(db.changeLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .get();
  }

  Stream<List<ChangeLog>> watchAll() {
    return (select(db.changeLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .watch();
  }

  Future<int?> getLastUnsyncedId() async {
    final result = await (select(db.changeLogs)
          ..where((t) => t.synced.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
    return result?.id;
  }

  Future<void> deleteAllSynced() async {
    await (delete(db.changeLogs)..where((t) => t.synced.equals(true))).go();
  }
}
