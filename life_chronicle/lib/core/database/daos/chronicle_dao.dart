part of '../app_database.dart';

@DriftAccessor(tables: [Chronicles])
class ChronicleDao extends DatabaseAccessor<AppDatabase> with _$ChronicleDaoMixin {
  ChronicleDao(super.db);

  late final ChangeLogRecorder _changeLogRecorder = ChangeLogRecorder(db);

  Future<void> upsert(ChroniclesCompanion entry) async {
    await into(db.chronicles).insertOnConflictUpdate(entry);
  }

  Future<List<Chronicle>> listAll() {
    return (select(db.chronicles)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Stream<List<Chronicle>> watchAll() {
    return (select(db.chronicles)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Stream<List<Chronicle>> watchFeatured() {
    return (select(db.chronicles)
          ..where((t) => t.isFeatured.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<Chronicle?> findById(String id) {
    return (select(db.chronicles)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<Chronicle?> watchById(String id) {
    return (select(db.chronicles)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<void> updateTitle(String id, String title) async {
    await (update(db.chronicles)..where((t) => t.id.equals(id)))
        .write(ChroniclesCompanion(
      title: Value(title),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateAiSummary(String id, String aiSummary) async {
    await (update(db.chronicles)..where((t) => t.id.equals(id)))
        .write(ChroniclesCompanion(
      aiSummary: Value(aiSummary),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateFeatured(String id, bool isFeatured) async {
    await transaction(() async {
      final existing = await findById(id);
      if (existing == null) return;
      await _changeLogRecorder.recordUpdate(
        entityType: 'chronicles',
        entityId: id,
        changedFields: ['isFeatured'],
      );
      await (update(db.chronicles)..where((t) => t.id.equals(id)))
          .write(ChroniclesCompanion(
        isFeatured: Value(isFeatured),
        updatedAt: Value(DateTime.now()),
      ));
    });
  }

  Future<void> deleteById(String id) async {
    await transaction(() async {
      await _changeLogRecorder.recordDelete(
        entityType: 'chronicles',
        entityId: id,
      );
      await (delete(db.chronicles)..where((t) => t.id.equals(id))).go();
    });
  }
}
