import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late AiProviderDao aiProviderDao;

  setUp(() async {
    db = createTestDatabase();
    aiProviderDao = AiProviderDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('AiProviderDao CRUD Operations', () {
    test('should insert an ai provider', () async {
      final now = DateTime.now();
      final entry = AiProvidersCompanion.insert(
        id: 'test-provider-1',
        name: 'Test Provider',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-api-key',
        createdAt: now,
        updatedAt: now,
      );

      await aiProviderDao.upsert(entry);

      final found = await aiProviderDao.findById('test-provider-1');
      expect(found, isNotNull);
      expect(found!.name, equals('Test Provider'));
    });

    test('should update an existing ai provider', () async {
      final now = DateTime.now();
      final entry = AiProvidersCompanion.insert(
        id: 'test-provider-2',
        name: 'Old Name',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-api-key',
        createdAt: now,
        updatedAt: now,
      );

      await aiProviderDao.upsert(entry);

      final updatedEntry = AiProvidersCompanion.insert(
        id: 'test-provider-2',
        name: 'New Name',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-api-key',
        createdAt: now,
        updatedAt: now,
      );

      await aiProviderDao.upsert(updatedEntry);

      final found = await aiProviderDao.findById('test-provider-2');
      expect(found!.name, equals('New Name'));
    });

    test('should delete an ai provider by id', () async {
      final now = DateTime.now();
      final entry = AiProvidersCompanion.insert(
        id: 'test-provider-3',
        name: 'Test Provider',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-api-key',
        createdAt: now,
        updatedAt: now,
      );

      await aiProviderDao.upsert(entry);
      await aiProviderDao.deleteById('test-provider-3');

      final found = await aiProviderDao.findById('test-provider-3');
      expect(found, isNull);
    });

    test('should return null for non-existent provider', () async {
      final found = await aiProviderDao.findById('non-existent-id');
      expect(found, isNull);
    });
  });

  group('AiProviderDao Active Provider Operations', () {
    test('should set and get active provider', () async {
      final now = DateTime.now();
      final provider1 = AiProvidersCompanion.insert(
        id: 'test-provider-4',
        name: 'Provider 1',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-api-key',
        createdAt: now,
        updatedAt: now,
      );
      final provider2 = AiProvidersCompanion.insert(
        id: 'test-provider-5',
        name: 'Provider 2',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-api-key',
        createdAt: now,
        updatedAt: now,
      );

      await aiProviderDao.upsert(provider1);
      await aiProviderDao.upsert(provider2);
      await aiProviderDao.setActiveProvider('test-provider-5', 'chat', now: now);

      final active = await aiProviderDao.getActiveProvider('chat');
      expect(active, isNotNull);
      expect(active!.id, equals('test-provider-5'));
      expect(active.isActive, isTrue);

      final provider1Check = await aiProviderDao.findById('test-provider-4');
      expect(provider1Check!.isActive, isFalse);
    });
  });

  group('AiProviderDao Watch Operations', () {
    test('should watch all providers', () async {
      final now = DateTime.now();
      final provider1 = AiProvidersCompanion.insert(
        id: 'watch-provider-1',
        name: 'Provider 1',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-api-key',
        createdAt: now,
        updatedAt: now,
      );
      final provider2 = AiProvidersCompanion.insert(
        id: 'watch-provider-2',
        name: 'Provider 2',
        apiType: 'openai',
        serviceType: 'embedding',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-api-key',
        createdAt: now,
        updatedAt: now,
      );

      await aiProviderDao.upsert(provider1);
      await aiProviderDao.upsert(provider2);

      final providers = await aiProviderDao.watchAll().first;
      expect(providers.length, greaterThanOrEqualTo(2));
    });

    test('should watch by service type', () async {
      final now = DateTime.now();
      final provider1 = AiProvidersCompanion.insert(
        id: 'watch-provider-3',
        name: 'Provider 1',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-api-key',
        createdAt: now,
        updatedAt: now,
      );
      final provider2 = AiProvidersCompanion.insert(
        id: 'watch-provider-4',
        name: 'Provider 2',
        apiType: 'openai',
        serviceType: 'embedding',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-api-key',
        createdAt: now,
        updatedAt: now,
      );

      await aiProviderDao.upsert(provider1);
      await aiProviderDao.upsert(provider2);

      final chatProviders = await aiProviderDao.watchByServiceType('chat').first;
      expect(chatProviders.any((p) => p.id == 'watch-provider-3'), isTrue);
      expect(chatProviders.any((p) => p.id == 'watch-provider-4'), isFalse);
    });

    test('should watch active provider', () async {
      final now = DateTime.now();
      final provider = AiProvidersCompanion.insert(
        id: 'watch-provider-5',
        name: 'Provider',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-api-key',
        createdAt: now,
        updatedAt: now,
      );

      await aiProviderDao.upsert(provider);
      await aiProviderDao.setActiveProvider('watch-provider-5', 'chat', now: now);

      final watched = await aiProviderDao.watchActiveProvider('chat').first;
      expect(watched, isNotNull);
      expect(watched!.id, equals('watch-provider-5'));
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('AiProviderDao Stream Reliability - watchAll（0.1.160）', () {
    test('A: 初始状态应包含默认seed的2条providers', () async {
      final result = await aiProviderDao.watchAll().first;
      expect(result.length, greaterThanOrEqualTo(2));
      expect(result.any((p) => p.name == '模力方舟' && p.serviceType == 'embedding'), isTrue);
      expect(result.any((p) => p.name == '默认' && p.serviceType == 'chat'), isTrue);
    });

    test('B: 插入数据后流应发出包含新记录的列表', () async {
      final now = DateTime.now();
      final stream = aiProviderDao.watchAll();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<AiProvider> list) => list.length >= 2),
          predicate((List<AiProvider> list) => list.any((p) => p.id == 'ap-stream-all-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-all-1',
        name: 'Stream Provider',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出包含更新后记录的列表', () async {
      final now = DateTime.now();
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-all-2',
        name: 'Old Name',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      final stream = aiProviderDao.watchAll();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<AiProvider> list) => list.firstWhere((p) => p.id == 'ap-stream-all-2').name == 'Old Name'),
          predicate((List<AiProvider> list) => list.firstWhere((p) => p.id == 'ap-stream-all-2').name == 'New Name'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-all-2',
        name: 'New Name',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 物理删除后流应发出不包含已删除记录的列表', () async {
      final now = DateTime.now();
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-all-3',
        name: 'To Delete',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      final stream = aiProviderDao.watchAll();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<AiProvider> list) => list.any((p) => p.id == 'ap-stream-all-3')),
          predicate((List<AiProvider> list) => !list.any((p) => p.id == 'ap-stream-all-3')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await aiProviderDao.deleteById('ap-stream-all-3');
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 插入多条后应按 createdAt 降序排序', () async {
      final now = DateTime.now();
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-order-1',
        name: 'Old',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ));
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-order-2',
        name: 'New',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      final result = await aiProviderDao.watchAll().first;
      final filtered = result.where((p) => p.id.startsWith('ap-stream-order-')).toList();
      expect(filtered.length, equals(2));
      expect(filtered.first.id, equals('ap-stream-order-2'));
      expect(filtered.last.id, equals('ap-stream-order-1'));
    });

    test('边界2: 物理删除后不返回', () async {
      final now = DateTime.now();
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-deleted-1',
        name: 'Deleted',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      await aiProviderDao.deleteById('ap-stream-deleted-1');
      final result = await aiProviderDao.watchAll().first;
      expect(result.any((p) => p.id == 'ap-stream-deleted-1'), isFalse);
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('AiProviderDao Stream Reliability - watchByServiceType（0.1.160）', () {
    test('A: 初始状态应包含默认seed的chat provider', () async {
      final result = await aiProviderDao.watchByServiceType('chat').first;
      expect(result.length, greaterThanOrEqualTo(1));
      expect(result.any((p) => p.name == '默认'), isTrue);
    });

    test('B: 插入数据后流应发出包含新记录的列表', () async {
      final now = DateTime.now();
      final stream = aiProviderDao.watchByServiceType('chat');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<AiProvider> list) => list.isNotEmpty),
          predicate((List<AiProvider> list) => list.any((p) => p.id == 'ap-stream-st-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-st-1',
        name: 'Chat Provider',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 不同 serviceType 不返回', () async {
      final now = DateTime.now();
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-st-2',
        name: 'Embedding Provider',
        apiType: 'openai',
        serviceType: 'embedding',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      final result = await aiProviderDao.watchByServiceType('chat').first;
      expect(result.any((p) => p.id == 'ap-stream-st-2'), isFalse);
    });

    test('边界2: 物理删除后不返回', () async {
      final now = DateTime.now();
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-st-3',
        name: 'To Delete',
        apiType: 'openai',
        serviceType: 'chat',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      await aiProviderDao.deleteById('ap-stream-st-3');
      final result = await aiProviderDao.watchByServiceType('chat').first;
      expect(result.any((p) => p.id == 'ap-stream-st-3'), isFalse);
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('AiProviderDao Stream Reliability - watchActiveProvider（0.1.160）', () {
    test('A: 初始状态（无该serviceType的active）应返回 null', () async {
      final result = await aiProviderDao.watchActiveProvider('vision').first;
      expect(result, isNull);
    });

    test('B: 设置 active 后流应发出非 null', () async {
      final now = DateTime.now();
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-active-1',
        name: 'Active Provider',
        apiType: 'openai',
        serviceType: 'vision',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      final values = <AiProvider?>[];
      final sub = aiProviderDao.watchActiveProvider('vision').listen(values.add);
      await Future.delayed(const Duration(milliseconds: 50));
      await aiProviderDao.setActiveProvider('ap-stream-active-1', 'vision', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();
      expect(values.isNotEmpty, isTrue);
      final lastNonNull = values.lastWhere((v) => v != null, orElse: () => null);
      expect(lastNonNull, isNotNull);
      expect(lastNonNull?.id, equals('ap-stream-active-1'));
      expect(lastNonNull?.isActive, isTrue);
    });

    test('C: 切换 active 后流应发出新值（mayEmit 跳过中间 null）', () async {
      final now = DateTime.now();
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-active-2',
        name: 'Provider A',
        apiType: 'openai',
        serviceType: 'vision',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-active-3',
        name: 'Provider B',
        apiType: 'openai',
        serviceType: 'vision',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      await aiProviderDao.setActiveProvider('ap-stream-active-2', 'vision', now: now);
      final stream = aiProviderDao.watchActiveProvider('vision');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((AiProvider? p) => p?.id == 'ap-stream-active-2'),
          mayEmit(predicate((AiProvider? p) => p == null)),
          predicate((AiProvider? p) => p?.id == 'ap-stream-active-3'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await aiProviderDao.setActiveProvider('ap-stream-active-3', 'vision', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 有 provider 但无 active 应返回 null', () async {
      final now = DateTime.now();
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-no-active-1',
        name: 'Inactive Provider',
        apiType: 'openai',
        serviceType: 'vision',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      final result = await aiProviderDao.watchActiveProvider('vision').first;
      expect(result, isNull);
    });

    test('边界2: setActiveProvider 切换后流式响应（mayEmit 跳过中间 null）', () async {
      final now = DateTime.now();
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-switch-1',
        name: 'First Active',
        apiType: 'openai',
        serviceType: 'audio',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      await aiProviderDao.upsert(AiProvidersCompanion.insert(
        id: 'ap-stream-switch-2',
        name: 'Second Active',
        apiType: 'openai',
        serviceType: 'audio',
        baseUrl: 'https://api.test.com',
        apiKey: 'test-key',
        createdAt: now,
        updatedAt: now,
      ));
      await aiProviderDao.setActiveProvider('ap-stream-switch-1', 'audio', now: now);
      final stream = aiProviderDao.watchActiveProvider('audio');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((AiProvider? p) => p?.id == 'ap-stream-switch-1'),
          mayEmit(predicate((AiProvider? p) => p == null)),
          predicate((AiProvider? p) => p?.id == 'ap-stream-switch-2'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await aiProviderDao.setActiveProvider('ap-stream-switch-2', 'audio', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });
  });
}
