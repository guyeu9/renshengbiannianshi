part of '../app_database.dart';

@DriftAccessor(tables: [SyncState])
class SyncStateDao extends DatabaseAccessor<AppDatabase> with _$SyncStateDaoMixin {
  SyncStateDao(super.db);

  Future<void> upsert(SyncStateCompanion entry) async {
    await into(db.syncState).insertOnConflictUpdate(entry);
  }

  Future<SyncStateData?> getById(String id) {
    return (select(db.syncState)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<SyncStateData?> getDefault() {
    return getById('default');
  }

  Stream<SyncStateData?> watchById(String id) {
    return (select(db.syncState)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<SyncStateData?> watchDefault() {
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
