part of '../app_database.dart';

@DriftAccessor(tables: [RecordEmbeddings])
class EmbeddingDao extends DatabaseAccessor<AppDatabase> with _$EmbeddingDaoMixin {
  EmbeddingDao(super.db);

  Future<void> upsert(RecordEmbeddingsCompanion entry) async {
    await into(db.recordEmbeddings).insertOnConflictUpdate(entry);
  }

  Future<void> deleteByEntity(String entityType, String entityId) async {
    await (delete(db.recordEmbeddings)
          ..where((t) => t.entityType.equals(entityType) & t.entityId.equals(entityId)))
        .go();
  }

  Future<RecordEmbedding?> findByEntity(String entityType, String entityId) async {
    return (select(db.recordEmbeddings)
          ..where((t) => t.entityType.equals(entityType) & t.entityId.equals(entityId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<RecordEmbedding>> findByEntityType(String entityType) async {
    return (select(db.recordEmbeddings)
          ..where((t) => t.entityType.equals(entityType)))
        .get();
  }

  Future<List<RecordEmbedding>> getAllEmbeddings() async {
    return select(db.recordEmbeddings).get();
  }

  Future<List<RecordEmbedding>> findByEntityTypes(List<String> entityTypes) async {
    if (entityTypes.isEmpty) return [];
    return (select(db.recordEmbeddings)
          ..where((t) => t.entityType.isIn(entityTypes)))
        .get();
  }

  Future<int> countByEntityType(String entityType) async {
    final query = select(db.recordEmbeddings)
      ..where((t) => t.entityType.equals(entityType));
    final results = await query.get();
    return results.length;
  }

  Future<void> deleteAll() async {
    await delete(db.recordEmbeddings).go();
  }
}
