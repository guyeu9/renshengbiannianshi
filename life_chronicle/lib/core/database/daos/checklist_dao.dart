part of '../app_database.dart';

@DriftAccessor(tables: [ChecklistItems])
class ChecklistDao extends DatabaseAccessor<AppDatabase> with _$ChecklistDaoMixin {
  ChecklistDao(super.db);

  Future<void> insert(ChecklistItemsCompanion entry) async {
    await into(db.checklistItems).insert(entry);
  }

  Future<void> upsert(ChecklistItemsCompanion entry) async {
    await into(db.checklistItems).insertOnConflictUpdate(entry);
  }

  Future<void> updateDone(String id, {required bool isDone, required DateTime now}) async {
    await (update(db.checklistItems)..where((t) => t.id.equals(id))).write(
      ChecklistItemsCompanion(
        isDone: Value(isDone),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> updateItem(String id, {required String title, String? note, required DateTime now}) async {
    await (update(db.checklistItems)..where((t) => t.id.equals(id))).write(
      ChecklistItemsCompanion(
        title: Value(title),
        note: Value(note),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> deleteById(String id) async {
    await (delete(db.checklistItems)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteByTripId(String tripId) async {
    await (delete(db.checklistItems)..where((t) => t.tripId.equals(tripId))).go();
  }

  Future<ChecklistItem?> findById(String id) {
    return (select(db.checklistItems)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<List<ChecklistItem>> watchByTripId(String tripId) {
    return (select(db.checklistItems)
          ..where((t) => t.tripId.equals(tripId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .watch();
  }

  Future<List<ChecklistItem>> listByTripId(String tripId) {
    return (select(db.checklistItems)
          ..where((t) => t.tripId.equals(tripId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }
}
