import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/services/backup/backup_service.dart';
import 'package:life_chronicle/core/services/backup/encryption_service.dart';
import 'package:life_chronicle/core/services/backup/change_log_recorder.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}

void main() {
  group('BackupService Tests', () {
    late AppDatabase db;
    late BackupService backupService;

    setUp(() {
      db = _createTestDatabase();
      backupService = BackupService(db);
    });

    tearDown(() async {
      backupService.dispose();
      await db.close();
    });

    test('exportAllData should export all tables', () async {
      await db.foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'test-food-1',
        title: 'Test Food',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final data = await backupService.exportAllData();

      expect(data, isNotNull);
      expect(data.containsKey('food_records'), isTrue);
      expect(data.containsKey('exported_at'), isTrue);
      expect(data.containsKey('schema_version'), isTrue);
    });

    test('importData should import records correctly', () async {
      final testData = {
        'food_records': [
          {
            'id': 'test-food-import-1',
            'title': 'Imported Food',
            'description': null,
            'location': null,
            'rating': null,
            'price': null,
            'images': '[]',
            'tags': '[]',
            'isFavorite': false,
            'isDeleted': false,
            'isWishlist': false,
            'wishlistDone': false,
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          }
        ],
      };

      await backupService.importData(testData, merge: true);

      final food = await db.foodDao.findById('test-food-import-1');
      expect(food, isNotNull);
      expect(food!.title, equals('Imported Food'));
    });

    test('importData with merge=true should update existing records', () async {
      await db.foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'test-food-merge-1',
        title: 'Original Title',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final testData = {
        'food_records': [
          {
            'id': 'test-food-merge-1',
            'title': 'Updated Title',
            'description': null,
            'location': null,
            'rating': null,
            'price': null,
            'images': '[]',
            'tags': '[]',
            'isFavorite': false,
            'isDeleted': false,
            'isWishlist': false,
            'wishlistDone': false,
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          }
        ],
      };

      await backupService.importData(testData, merge: true);

      final food = await db.foodDao.findById('test-food-merge-1');
      expect(food!.title, equals('Updated Title'));
    });
  });

  group('EncryptionService Tests', () {
    test('encrypt and decrypt should work correctly', () async {
      final testData = {'key': 'value', 'number': 42};
      final testJson = testData.toString();

      final encrypted = await EncryptionService.encryptString(
        testJson,
        'test-password',
      );

      expect(encrypted, isNotEmpty);

      final decrypted = await EncryptionService.decryptString(
        encrypted,
        'test-password',
      );

      expect(decrypted, equals(testJson));
    });

    test('decrypt with wrong password should fail', () async {
      final testData = 'test data';
      final encrypted = await EncryptionService.encryptString(
        testData,
        'correct-password',
      );

      expect(
        () => EncryptionService.decryptString(encrypted, 'wrong-password'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('ChangeLogRecorder Tests', () {
    late AppDatabase db;
    late ChangeLogRecorder recorder;

    setUp(() {
      db = _createTestDatabase();
      recorder = ChangeLogRecorder(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('recordInsert should create change log entry', () async {
      await recorder.recordInsert(
        entityType: 'food_records',
        entityId: 'test-id-1',
      );

      final changes = await db.changeLogDao.findUnsynced();
      expect(changes.length, equals(1));
      expect(changes.first.entityType, equals('food_records'));
      expect(changes.first.entityId, equals('test-id-1'));
      expect(changes.first.action, equals('insert'));
    });

    test('recordUpdate should create change log entry', () async {
      await recorder.recordUpdate(
        entityType: 'food_records',
        entityId: 'test-id-2',
        changedFields: ['title', 'description'],
      );

      final changes = await db.changeLogDao.findUnsynced();
      expect(changes.length, equals(1));
      expect(changes.first.action, equals('update'));
    });

    test('recordDelete should create change log entry', () async {
      await recorder.recordDelete(
        entityType: 'food_records',
        entityId: 'test-id-3',
      );

      final changes = await db.changeLogDao.findUnsynced();
      expect(changes.length, equals(1));
      expect(changes.first.action, equals('delete'));
    });

    test('markAsSynced should mark entries as synced', () async {
      await recorder.recordInsert(
        entityType: 'food_records',
        entityId: 'test-id-4',
      );

      var changes = await db.changeLogDao.findUnsynced();
      expect(changes.length, equals(1));

      await db.changeLogDao.markAllAsSyncedByIds([changes.first.id]);

      changes = await db.changeLogDao.findUnsynced();
      expect(changes.length, equals(0));
    });
  });

  group('SyncState Tests', () {
    late AppDatabase db;

    setUp(() {
      db = _createTestDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    test('upsert should create or update sync state', () async {
      await db.syncStateDao.upsert(SyncStateCompanion(
        id: const Value('main'),
        lastSyncTime: Value(DateTime.now()),
        lastSyncChangeId: const Value(100),
        deviceId: const Value('test-device'),
      ));

      final state = await db.syncStateDao.getDefault();
      expect(state, isNotNull);
      expect(state!.lastSyncChangeId, equals(100));
    });

    test('watchDefault should emit state changes', () async {
      final stream = db.syncStateDao.watchDefault();

      await db.syncStateDao.upsert(SyncStateCompanion(
        id: const Value('main'),
        lastSyncTime: Value(DateTime.now()),
        deviceId: const Value('test-device'),
      ));

      final state = await stream.first;
      expect(state, isNotNull);
    });
  });
}
