import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';

void main() {
  group('AiProvider', () {
    late AiProvider testChatProvider;
    late AiProvider testEmbeddingProvider;
    late AiProvider testActiveProvider;

    setUp(() {
      final now = DateTime.now();

      testChatProvider = AiProvider(
        id: 'chat-provider-1',
        name: 'OpenAI Chat',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.openai.com/v1',
        apiKey: 'sk-test-key-12345',
        modelName: 'gpt-4',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      testEmbeddingProvider = AiProvider(
        id: 'embedding-provider-1',
        name: 'OpenAI Embedding',
        apiType: 'openai',
        serviceType: 'embedding',
        baseUrl: 'https://api.openai.com/v1',
        apiKey: 'sk-test-key-67890',
        modelName: 'text-embedding-3-small',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      testActiveProvider = AiProvider(
        id: 'active-provider-1',
        name: 'Active Provider',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'sk-active-123',
        modelName: 'gpt-3.5-turbo',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
    });

    test('should have correct properties for chat provider', () {
      expect(testChatProvider.id, equals('chat-provider-1'));
      expect(testChatProvider.name, equals('OpenAI Chat'));
      expect(testChatProvider.apiType, equals('openai'));
      expect(testChatProvider.serviceType, equals('chat'));
      expect(testChatProvider.baseUrl, equals('https://api.openai.com/v1'));
      expect(testChatProvider.apiKey, equals('sk-test-key-12345'));
      expect(testChatProvider.modelName, equals('gpt-4'));
      expect(testChatProvider.isActive, isFalse);
    });

    test('should have correct properties for embedding provider', () {
      expect(testEmbeddingProvider.id, equals('embedding-provider-1'));
      expect(testEmbeddingProvider.serviceType, equals('embedding'));
      expect(testEmbeddingProvider.modelName, equals('text-embedding-3-small'));
    });

    test('should have isActive true for active provider', () {
      expect(testActiveProvider.isActive, isTrue);
    });
  });
}
