import 'dart:typed_data';

import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/services/embedding_service.dart';
import 'package:life_chronicle/core/utils/vector_utils.dart';
import 'package:uuid/uuid.dart';

class VectorIndexService {
  final AppDatabase _db;
  final EmbeddingServiceBase? Function() _embeddingServiceGetter;

  VectorIndexService(this._db, this._embeddingServiceGetter);

  Future<void> indexRecord({
    required String entityType,
    required String entityId,
    required String text,
    String? modelName,
  }) async {
    if (text.trim().isEmpty) return;

    final embeddingService = _embeddingServiceGetter();
    if (embeddingService == null) return;

    final embedding = await embeddingService.embed(text);
    if (embedding.isEmpty) return;

    final now = DateTime.now();
    final id = const Uuid().v4();

    await _db.embeddingDao.upsert(
      RecordEmbeddingsCompanion.insert(
        id: id,
        entityType: entityType,
        entityId: entityId,
        embedding: Value(vectorToBlob(embedding)),
        dimension: embedding.length,
        modelName: modelName ?? embeddingService.provider.modelName ?? 'unknown',
        sourceText: Value(text),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateIndex({
    required String entityType,
    required String entityId,
    required String text,
    String? modelName,
  }) async {
    await indexRecord(
      entityType: entityType,
      entityId: entityId,
      text: text,
      modelName: modelName,
    );
  }

  Future<void> deleteIndex({
    required String entityType,
    required String entityId,
  }) async {
    await _db.embeddingDao.deleteByEntity(entityType, entityId);
  }

  Future<List<SimilarityMatch>> findSimilar({
    required List<double> queryVector,
    required int limit,
    List<String>? entityTypes,
    double minSimilarity = 0.0,
  }) async {
    List<RecordEmbedding> embeddings;
    if (entityTypes != null && entityTypes.isNotEmpty) {
      embeddings = await _db.embeddingDao.findByEntityTypes(entityTypes);
    } else {
      embeddings = await _db.embeddingDao.getAllEmbeddings();
    }

    if (embeddings.isEmpty) return [];

    final candidates = embeddings.map((e) {
      final vector = blobToVectorFromList(e.embedding);
      return (id: e.entityId, vector: vector);
    }).toList();

    final results = batchCosineSimilarity(queryVector, candidates, limit: limit * 2);

    return results
        .where((r) => r.similarity >= minSimilarity)
        .take(limit)
        .map((r) {
          final embedding = embeddings.firstWhere((e) => e.entityId == r.id);
          return SimilarityMatch(
            entityType: embedding.entityType,
            entityId: r.id,
            similarity: r.similarity,
          );
        })
        .toList();
  }

  Future<List<SimilarityMatch>> searchByText({
    required String query,
    required int limit,
    List<String>? entityTypes,
    double minSimilarity = 0.0,
  }) async {
    final embeddingService = _embeddingServiceGetter();
    if (embeddingService == null) return [];

    final queryVector = await embeddingService.embed(query);
    if (queryVector.isEmpty) return [];

    return findSimilar(
      queryVector: queryVector,
      limit: limit,
      entityTypes: entityTypes,
      minSimilarity: minSimilarity,
    );
  }
}

class SimilarityMatch {
  final String entityType;
  final String entityId;
  final double similarity;

  const SimilarityMatch({
    required this.entityType,
    required this.entityId,
    required this.similarity,
  });
}
