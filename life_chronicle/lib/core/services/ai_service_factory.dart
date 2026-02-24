import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/services/ai_service.dart';
import 'package:life_chronicle/core/services/embedding_service.dart';
import 'package:life_chronicle/core/services/providers/openai_compatible_service.dart';

class AiServiceFactory {
  static AiServiceBase createChatService(AiProvider provider) {
    switch (provider.apiType) {
      case 'openai':
      case 'gemini':
      case 'claude':
      case 'qwen':
      case 'zhipu':
      case 'baichuan':
      case 'moonshot':
      case 'bge':
      case 'custom':
      default:
        return OpenAiCompatibleService(provider);
    }
  }
  
  static EmbeddingServiceBase? createEmbeddingService(AiProvider provider) {
    switch (provider.apiType) {
      case 'openai':
      case 'bge':
      default:
        return OpenAiCompatibleEmbeddingService(provider);
    }
  }
}
