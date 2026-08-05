import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:life_chronicle/core/providers/ai_provider.dart';
import '../test_utils/test_database.dart';

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

  // 0.1.166 Provider层状态同步可靠性测试
  // 防护 0.1.159 同类 bug：Provider 在 DAO 数据变化后必须正确刷新
  group('AiProvider Provider层状态同步（0.1.166）', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() async {
      db = createTestDatabase();
      // 清空 beforeOpen 插入的默认 AI provider，确保测试从空表开始
      await (db.delete(db.aiProviders)).go();
      container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ]);
    });

    tearDown(() async {
      container.dispose();
      await closeTestDatabase(db);
    });

    // 构造 AiProvidersCompanion.insert 的辅助方法
    AiProvidersCompanion makeProvider({
      required String id,
      String name = '测试Provider',
      String apiType = 'openai',
      required String serviceType,
      String baseUrl = 'https://api.test.com',
      String apiKey = 'sk-test-key',
      String? modelName,
      bool isActive = false,
    }) {
      final now = DateTime.now();
      return AiProvidersCompanion.insert(
        id: id,
        name: name,
        apiType: apiType,
        serviceType: serviceType,
        baseUrl: baseUrl,
        apiKey: apiKey,
        modelName: modelName != null ? Value(modelName) : const Value.absent(),
        isActive: Value(isActive),
        createdAt: now,
        updatedAt: now,
      );
    }

    // ==================== allChatProvidersProvider ====================
    group('allChatProvidersProvider', () {
      // ap-stream-chat-A: 初始状态返回空列表
      test('ap-stream-chat-A 初始状态返回空列表', () async {
        final sub = container.listen(allChatProvidersProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));

        expect(container.read(allChatProvidersProvider).value, isEmpty);

        sub.close();
      });

      // ap-stream-chat-B: 插入chat类型provider后Provider发出包含新记录的列表
      test('ap-stream-chat-B 插入chat类型provider后Provider发出包含新记录的列表', () async {
        final sub = container.listen(allChatProvidersProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(allChatProvidersProvider).value, isEmpty);

        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-chat-B', serviceType: 'chat'),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        final list = container.read(allChatProvidersProvider).value!;
        expect(list.length, equals(1));
        expect(list.first.id, equals('ap-stream-chat-B'));

        sub.close();
      });

      // ap-stream-chat-C: 插入embedding类型provider后Provider不发出该记录（serviceType过滤）
      test('ap-stream-chat-C 插入embedding类型provider后Provider不发出该记录', () async {
        final sub = container.listen(allChatProvidersProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(allChatProvidersProvider).value, isEmpty);

        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-chat-C', serviceType: 'embedding'),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(allChatProvidersProvider).value, isEmpty);

        sub.close();
      });

      // ap-stream-chat-D: 物理删除后Provider发出不包含该记录的列表
      test('ap-stream-chat-D 物理删除后Provider发出不包含该记录的列表', () async {
        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-chat-D', serviceType: 'chat'),
        );
        final sub = container.listen(allChatProvidersProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(allChatProvidersProvider).value!.length, equals(1));

        await db.aiProviderDao.deleteById('ap-stream-chat-D');

        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(allChatProvidersProvider).value, isEmpty);

        sub.close();
      });

      // ap-stream-chat-E: upsert更新后Provider发出新值
      test('ap-stream-chat-E upsert更新后Provider发出新值', () async {
        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-chat-E', serviceType: 'chat', name: '旧名称'),
        );
        final sub = container.listen(allChatProvidersProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(allChatProvidersProvider).value!.first.name, equals('旧名称'));

        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-chat-E', serviceType: 'chat', name: '新名称'),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(allChatProvidersProvider).value!.first.name, equals('新名称'));

        sub.close();
      });
    });

    // ==================== allEmbeddingProvidersProvider ====================
    group('allEmbeddingProvidersProvider', () {
      // ap-stream-emb-A: 初始状态返回空列表
      test('ap-stream-emb-A 初始状态返回空列表', () async {
        final sub = container.listen(allEmbeddingProvidersProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));

        expect(container.read(allEmbeddingProvidersProvider).value, isEmpty);

        sub.close();
      });

      // ap-stream-emb-B: 插入embedding类型provider后Provider发出包含新记录的列表
      test('ap-stream-emb-B 插入embedding类型provider后Provider发出包含新记录的列表', () async {
        final sub = container.listen(allEmbeddingProvidersProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(allEmbeddingProvidersProvider).value, isEmpty);

        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-emb-B', serviceType: 'embedding'),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        final list = container.read(allEmbeddingProvidersProvider).value!;
        expect(list.length, equals(1));
        expect(list.first.id, equals('ap-stream-emb-B'));

        sub.close();
      });

      // ap-stream-emb-C: 插入chat类型provider后Provider不发出该记录
      test('ap-stream-emb-C 插入chat类型provider后Provider不发出该记录', () async {
        final sub = container.listen(allEmbeddingProvidersProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(allEmbeddingProvidersProvider).value, isEmpty);

        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-emb-C', serviceType: 'chat'),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(allEmbeddingProvidersProvider).value, isEmpty);

        sub.close();
      });

      // ap-stream-emb-D: upsert更新后Provider发出新值
      test('ap-stream-emb-D upsert更新后Provider发出新值', () async {
        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-emb-D', serviceType: 'embedding', name: '旧Embedding'),
        );
        final sub = container.listen(allEmbeddingProvidersProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(
            container.read(allEmbeddingProvidersProvider).value!.first.name, equals('旧Embedding'));

        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-emb-D', serviceType: 'embedding', name: '新Embedding'),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        expect(
            container.read(allEmbeddingProvidersProvider).value!.first.name, equals('新Embedding'));

        sub.close();
      });
    });

    // ==================== activeChatProviderProvider ====================
    group('activeChatProviderProvider', () {
      // ap-stream-active-chat-A: 初始状态返回null
      test('ap-stream-active-chat-A 初始状态返回null', () async {
        final sub = container.listen(activeChatProviderProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));

        expect(container.read(activeChatProviderProvider).value, isNull);

        sub.close();
      });

      // ap-stream-active-chat-B: 插入active的chat provider后Provider发出该记录
      test('ap-stream-active-chat-B 插入active的chat provider后Provider发出该记录', () async {
        final sub = container.listen(activeChatProviderProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(activeChatProviderProvider).value, isNull);

        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-active-chat-B', serviceType: 'chat', isActive: true),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        final active = container.read(activeChatProviderProvider).value;
        expect(active, isNotNull);
        expect(active!.id, equals('ap-stream-active-chat-B'));

        sub.close();
      });

      // ap-stream-active-chat-C: setActiveProvider切换后Provider发出新active记录
      test('ap-stream-active-chat-C setActiveProvider切换后Provider发出新active记录', () async {
        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-active-chat-C1', serviceType: 'chat', isActive: true),
        );
        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-active-chat-C2', serviceType: 'chat', isActive: false),
        );
        final sub = container.listen(activeChatProviderProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(activeChatProviderProvider).value!.id,
            equals('ap-stream-active-chat-C1'));

        await db.aiProviderDao.setActiveProvider(
          'ap-stream-active-chat-C2',
          'chat',
          now: DateTime.now(),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(activeChatProviderProvider).value!.id,
            equals('ap-stream-active-chat-C2'));

        sub.close();
      });

      // ap-stream-active-chat-edge1: 无active provider时返回null
      test('ap-stream-active-chat-edge1 无active provider时返回null', () async {
        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-active-chat-edge1', serviceType: 'chat', isActive: false),
        );
        final sub = container.listen(activeChatProviderProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));

        expect(container.read(activeChatProviderProvider).value, isNull);

        sub.close();
      });

      // ap-stream-active-chat-edge2: 删除active后返回null
      test('ap-stream-active-chat-edge2 删除active后返回null', () async {
        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-active-chat-edge2', serviceType: 'chat', isActive: true),
        );
        final sub = container.listen(activeChatProviderProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(activeChatProviderProvider).value, isNotNull);

        await db.aiProviderDao.deleteById('ap-stream-active-chat-edge2');

        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(activeChatProviderProvider).value, isNull);

        sub.close();
      });
    });

    // ==================== activeEmbeddingProviderProvider ====================
    group('activeEmbeddingProviderProvider', () {
      // ap-stream-active-emb-A: 初始状态返回null
      test('ap-stream-active-emb-A 初始状态返回null', () async {
        final sub = container.listen(activeEmbeddingProviderProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));

        expect(container.read(activeEmbeddingProviderProvider).value, isNull);

        sub.close();
      });

      // ap-stream-active-emb-B: 插入active的embedding provider后Provider发出该记录
      test('ap-stream-active-emb-B 插入active的embedding provider后Provider发出该记录', () async {
        final sub = container.listen(activeEmbeddingProviderProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(activeEmbeddingProviderProvider).value, isNull);

        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-active-emb-B', serviceType: 'embedding', isActive: true),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        final active = container.read(activeEmbeddingProviderProvider).value;
        expect(active, isNotNull);
        expect(active!.id, equals('ap-stream-active-emb-B'));

        sub.close();
      });

      // ap-stream-active-emb-C: setActiveProvider切换后Provider发出新active记录
      test('ap-stream-active-emb-C setActiveProvider切换后Provider发出新active记录', () async {
        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-active-emb-C1', serviceType: 'embedding', isActive: true),
        );
        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-active-emb-C2', serviceType: 'embedding', isActive: false),
        );
        final sub = container.listen(activeEmbeddingProviderProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(activeEmbeddingProviderProvider).value!.id,
            equals('ap-stream-active-emb-C1'));

        await db.aiProviderDao.setActiveProvider(
          'ap-stream-active-emb-C2',
          'embedding',
          now: DateTime.now(),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(activeEmbeddingProviderProvider).value!.id,
            equals('ap-stream-active-emb-C2'));

        sub.close();
      });

      // ap-stream-active-emb-edge1: 无active provider时返回null
      test('ap-stream-active-emb-edge1 无active provider时返回null', () async {
        await db.aiProviderDao.upsert(
          makeProvider(id: 'ap-stream-active-emb-edge1', serviceType: 'embedding', isActive: false),
        );
        final sub = container.listen(activeEmbeddingProviderProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 100));

        expect(container.read(activeEmbeddingProviderProvider).value, isNull);

        sub.close();
      });
    });
  });
}
