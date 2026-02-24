import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/services/backup/backup_service.dart';
import 'package:life_chronicle/core/services/backup/change_log_recorder.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase.connect(NativeDatabase.memory());
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
        recordDate: DateTime.now(),
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
            'content': null,
            'images': null,
            'tags': null,
            'rating': null,
            'pricePerPerson': null,
            'link': null,
            'latitude': null,
            'longitude': null,
            'poiName': null,
            'poiAddress': null,
            'city': null,
            'mood': null,
            'isWishlist': false,
            'isFavorite': false,
            'wishlistDone': false,
            'recordDate': DateTime.now().toIso8601String(),
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'isDeleted': false,
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
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final testData = {
        'food_records': [
          {
            'id': 'test-food-merge-1',
            'title': 'Updated Title',
            'content': null,
            'images': null,
            'tags': null,
            'rating': null,
            'pricePerPerson': null,
            'link': null,
            'latitude': null,
            'longitude': null,
            'poiName': null,
            'poiAddress': null,
            'city': null,
            'mood': null,
            'isWishlist': false,
            'isFavorite': false,
            'wishlistDone': false,
            'recordDate': DateTime.now().toIso8601String(),
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'isDeleted': false,
          }
        ],
      };

      await backupService.importData(testData, merge: true);

      final food = await db.foodDao.findById('test-food-merge-1');
      expect(food!.title, equals('Updated Title'));
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
        changedFields: ['title', 'content'],
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
        id: const Value('default'),
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
        id: const Value('default'),
        lastSyncTime: Value(DateTime.now()),
        deviceId: const Value('test-device'),
      ));

      final state = await stream.first;
      expect(state, isNotNull);
    });
  });
}
