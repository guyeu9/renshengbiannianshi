
part of '../app_database.dart';

@DriftAccessor(tables: [ChecklistItems])
class ChecklistDao extends DatabaseAccessor&lt;AppDatabase&gt; with _$ChecklistDaoMixin {
  ChecklistDao(super.db);

  Future&lt;void&gt; insert(ChecklistItemsCompanion entry) async {
    await into(db.checklistItems).insert(entry);
  }

  Future&lt;void&gt; upsert(ChecklistItemsCompanion entry) async {
    await into(db.checklistItems).insertOnConflictUpdate(entry);
  }

  Future&lt;void&gt; updateDone(String id, {required bool isDone, required DateTime now}) async {
    await (update(db.checklistItems)..where((t) =&gt; t.id.equals(id))).write(
      ChecklistItemsCompanion(
        isDone: Value(isDone),
        updatedAt: Value(now),
      ),
    );
  }

  Future&lt;void&gt; updateItem(String id, {required String title, String? note, required DateTime now}) async {
    await (update(db.checklistItems)..where((t) =&gt; t.id.equals(id))).write(
      ChecklistItemsCompanion(
        title: Value(title),
        note: Value(note),
        updatedAt: Value(now),
      ),
    );
  }

  Future&lt;void&gt; deleteById(String id) async {
    await (delete(db.checklistItems)..where((t) =&gt; t.id.equals(id))).go();
  }

  Future&lt;void&gt; deleteByTripId(String tripId) async {
    await (delete(db.checklistItems)..where((t) =&gt; t.tripId.equals(tripId))).go();
  }

  Future&lt;ChecklistItem?&gt; findById(String id) {
    return (select(db.checklistItems)
          ..where((t) =&gt; t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream&lt;List&lt;ChecklistItem&gt;&gt; watchByTripId(String tripId) {
    return (select(db.checklistItems)
          ..where((t) =&gt; t.tripId.equals(tripId))
          ..orderBy([(t) =&gt; OrderingTerm.asc(t.orderIndex)]))
        .watch();
  }

  Future&lt;List&lt;ChecklistItem&gt;&gt; listByTripId(String tripId) {
    return (select(db.checklistItems)
          ..where((t) =&gt; t.tripId.equals(tripId))
          ..orderBy([(t) =&gt; OrderingTerm.asc(t.orderIndex)]))
        .get();
  }
}
