import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:life_chronicle/core/providers/ai_provider.dart';
import 'package:life_chronicle/core/services/semantic_search_service.dart';
import 'package:life_chronicle/core/services/vector_index_service.dart';

final vectorIndexManagerInitializerProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  await db.initializeVectorIndexManager(
    () => ref.read(activeEmbeddingServiceProvider),
  );
});

final vectorIndexServiceProvider = Provider<VectorIndexService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return VectorIndexService(
    db,
    () => ref.read(activeEmbeddingServiceProvider),
  );
});

final semanticSearchServiceProvider = Provider<SemanticSearchService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final vectorIndexService = ref.watch(vectorIndexServiceProvider);
  return SemanticSearchService(
    db,
    vectorIndexService,
  );
});

final hasVectorSearchCapabilityProvider = Provider<bool>((ref) {
  return ref.watch(activeEmbeddingServiceProvider) != null;
});
