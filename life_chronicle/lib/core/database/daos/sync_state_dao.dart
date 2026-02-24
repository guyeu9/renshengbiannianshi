part of '../app_database.dart';

@DriftAccessor(tables: [SyncState])
class SyncStateDao extends DatabaseAccessor<AppDatabase> with _$SyncStateDaoMixin {
  SyncStateDao(super.db);

  Future<void> upsert(SyncStateCompanion entry) async {
    await into(db.syncState).insertOnConflictUpdate(entry);
  }

  Future<SyncState?> getById(String id) {
    return (select(db.syncState)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<SyncState?> getDefault() {
    return getById('default');
  }

  Stream<SyncState?> watchById(String id) {
    return (select(db.syncState)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<SyncState?> watchDefault() {
    return watchById('default');
  }

  Future<void> updateLastSync(
    String id, {
    required DateTime lastSyncTime,
    required int? lastSyncChangeId,
    required String deviceId,
  }) async {
    await into(db.syncState).insertOnConflictUpdate(
      SyncStateCompanion(
        id: Value(id),
        lastSyncTime: Value(lastSyncTime),
        lastSyncChangeId: Value(lastSyncChangeId),
        deviceId: Value(deviceId),
      ),
    );
  }
}
