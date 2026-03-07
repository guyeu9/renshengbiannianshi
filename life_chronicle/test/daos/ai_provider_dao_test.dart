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
}
