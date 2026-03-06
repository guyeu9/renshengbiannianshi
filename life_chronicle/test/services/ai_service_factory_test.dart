import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/services/ai_service.dart';
import 'package:life_chronicle/core/services/ai_service_factory.dart';
import 'package:life_chronicle/core/services/embedding_service.dart';
import 'package:life_chronicle/core/services/providers/openai_compatible_service.dart';

AiProvider _createTestProvider({
  required String apiType,
  required String baseUrl,
  required String modelName,
}) {
  return AiProvider(
    id: 'test-id',
    name: 'Test Provider',
    apiType: apiType,
    serviceType: 'chat',
    baseUrl: baseUrl,
    apiKey: 'test-api-key',
    modelName: modelName,
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

void main() {
  group('AiServiceFactory Tests', () {
    group('createChatService', () {
      test('should return OpenAiCompatibleService for openai apiType', () {
        final provider = _createTestProvider(
          apiType: 'openai',
          baseUrl: 'https://api.openai.com',
          modelName: 'gpt-3.5-turbo',
        );

        final service = AiServiceFactory.createChatService(provider);
        expect(service, isA<OpenAiCompatibleService>());
        expect(service.provider, equals(provider));
      });

      test('should return OpenAiCompatibleService for gemini apiType', () {
        final provider = _createTestProvider(
          apiType: 'gemini',
          baseUrl: 'https://api.gemini.com',
          modelName: 'gemini-pro',
        );

        final service = AiServiceFactory.createChatService(provider);
        expect(service, isA<OpenAiCompatibleService>());
      });

      test('should return OpenAiCompatibleService for claude apiType', () {
        final provider = _createTestProvider(
          apiType: 'claude',
          baseUrl: 'https://api.anthropic.com',
          modelName: 'claude-3-opus',
        );

        final service = AiServiceFactory.createChatService(provider);
        expect(service, isA<OpenAiCompatibleService>());
      });

      test('should return OpenAiCompatibleService for qwen apiType', () {
        final provider = _createTestProvider(
          apiType: 'qwen',
          baseUrl: 'https://dashscope.aliyuncs.com',
          modelName: 'qwen-turbo',
        );

        final service = AiServiceFactory.createChatService(provider);
        expect(service, isA<OpenAiCompatibleService>());
      });

      test('should return OpenAiCompatibleService for zhipu apiType', () {
        final provider = _createTestProvider(
          apiType: 'zhipu',
          baseUrl: 'https://open.bigmodel.cn',
          modelName: 'glm-4',
        );

        final service = AiServiceFactory.createChatService(provider);
        expect(service, isA<OpenAiCompatibleService>());
      });

      test('should return OpenAiCompatibleService for baichuan apiType', () {
        final provider = _createTestProvider(
          apiType: 'baichuan',
          baseUrl: 'https://api.baichuan-ai.com',
          modelName: 'Baichuan4',
        );

        final service = AiServiceFactory.createChatService(provider);
        expect(service, isA<OpenAiCompatibleService>());
      });

      test('should return OpenAiCompatibleService for moonshot apiType', () {
        final provider = _createTestProvider(
          apiType: 'moonshot',
          baseUrl: 'https://api.moonshot.cn',
          modelName: 'moonshot-v1',
        );

        final service = AiServiceFactory.createChatService(provider);
        expect(service, isA<OpenAiCompatibleService>());
      });

      test('should return OpenAiCompatibleService for bge apiType', () {
        final provider = _createTestProvider(
          apiType: 'bge',
          baseUrl: 'https://api.example.com',
          modelName: 'bge-large-zh',
        );

        final service = AiServiceFactory.createChatService(provider);
        expect(service, isA<OpenAiCompatibleService>());
      });

      test('should return OpenAiCompatibleService for custom apiType', () {
        final provider = _createTestProvider(
          apiType: 'custom',
          baseUrl: 'https://custom-api.com',
          modelName: 'custom-model',
        );

        final service = AiServiceFactory.createChatService(provider);
        expect(service, isA<OpenAiCompatibleService>());
      });

      test('should return OpenAiCompatibleService for unknown apiType', () {
        final provider = _createTestProvider(
          apiType: 'unknown-type',
          baseUrl: 'https://unknown-api.com',
          modelName: 'unknown-model',
        );

        final service = AiServiceFactory.createChatService(provider);
        expect(service, isA<OpenAiCompatibleService>());
      });
    });

    group('createEmbeddingService', () {
      test('should return OpenAiCompatibleEmbeddingService for openai apiType', () {
        final provider = _createTestProvider(
          apiType: 'openai',
          baseUrl: 'https://api.openai.com',
          modelName: 'text-embedding-3-small',
        );

        final service = AiServiceFactory.createEmbeddingService(provider);
        expect(service, isA<OpenAiCompatibleEmbeddingService>());
        expect(service!.provider, equals(provider));
      });

      test('should return OpenAiCompatibleEmbeddingService for bge apiType', () {
        final provider = _createTestProvider(
          apiType: 'bge',
          baseUrl: 'https://api.example.com',
          modelName: 'bge-large-zh',
        );

        final service = AiServiceFactory.createEmbeddingService(provider);
        expect(service, isA<OpenAiCompatibleEmbeddingService>());
      });

      test('should return OpenAiCompatibleEmbeddingService for unknown apiType', () {
        final provider = _createTestProvider(
          apiType: 'unknown-type',
          baseUrl: 'https://api.example.com',
          modelName: 'unknown-model',
        );

        final service = AiServiceFactory.createEmbeddingService(provider);
        expect(service, isA<OpenAiCompatibleEmbeddingService>());
      });
    });
  });
}
