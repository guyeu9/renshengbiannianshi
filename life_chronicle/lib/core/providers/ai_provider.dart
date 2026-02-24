import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:life_chronicle/core/services/ai_service.dart';
import 'package:life_chronicle/core/services/ai_service_factory.dart';
import 'package:life_chronicle/core/services/embedding_service.dart';

final aiProviderDaoProvider = Provider<AiProviderDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.aiProviderDao;
});

final allChatProvidersProvider = StreamProvider<List<AiProvider>>((ref) {
  final dao = ref.watch(aiProviderDaoProvider);
  return dao.watchByServiceType('chat');
});

final allEmbeddingProvidersProvider = StreamProvider<List<AiProvider>>((ref) {
  final dao = ref.watch(aiProviderDaoProvider);
  return dao.watchByServiceType('embedding');
});

final activeChatProviderProvider = StreamProvider<AiProvider?>((ref) {
  final dao = ref.watch(aiProviderDaoProvider);
  return dao.watchActiveProvider('chat');
});

final activeEmbeddingProviderProvider = StreamProvider<AiProvider?>((ref) {
  final dao = ref.watch(aiProviderDaoProvider);
  return dao.watchActiveProvider('embedding');
});

final activeChatServiceProvider = Provider<AiServiceBase?>((ref) {
  final provider = ref.watch(activeChatProviderProvider).value;
  if (provider == null) return null;
  return AiServiceFactory.createChatService(provider);
});

final activeEmbeddingServiceProvider = Provider<EmbeddingServiceBase?>((ref) {
  final provider = ref.watch(activeEmbeddingProviderProvider).value;
  if (provider == null) return null;
  return AiServiceFactory.createEmbeddingService(provider);
});

final hasActiveChatProvider = Provider<bool>((ref) {
  return ref.watch(activeChatProviderProvider).value != null;
});

final hasActiveEmbeddingProvider = Provider<bool>((ref) {
  return ref.watch(activeEmbeddingProviderProvider).value != null;
});
