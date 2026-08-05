import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late SyncStateDao syncStateDao;

  setUp(() async {
    db = createTestDatabase();
    syncStateDao = SyncStateDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('SyncStateDao CRUD Operations', () {
    test('should upsert a sync state', () async {
      final now = DateTime.now();
      final entry = SyncStateCompanion.insert(
        id: 'test-state-1',
        lastSyncTime: Value(now),
        lastSyncChangeId: const Value(100),
        deviceId: 'test-device-1',
      );

      await syncStateDao.upsert(entry);

      final found = await syncStateDao.getById('test-state-1');
      expect(found, isNotNull);
      expect(found!.deviceId, equals('test-device-1'));
      expect(found.lastSyncChangeId, equals(100));
    });

    test('should update an existing sync state', () async {
      final now = DateTime.now();
      final entry = SyncStateCompanion.insert(
        id: 'test-state-2',
        lastSyncTime: Value(now.subtract(const Duration(days: 1))),
        lastSyncChangeId: const Value(100),
        deviceId: 'old-device',
      );

      await syncStateDao.upsert(entry);

      final newNow = DateTime.now();
      final updatedEntry = SyncStateCompanion.insert(
        id: 'test-state-2',
        lastSyncTime: Value(newNow),
        lastSyncChangeId: const Value(200),
        deviceId: 'new-device',
      );

      await syncStateDao.upsert(updatedEntry);

      final found = await syncStateDao.getById('test-state-2');
      expect(found!.deviceId, equals('new-device'));
      expect(found.lastSyncChangeId, equals(200));
    });

    test('should update last sync', () async {
      final syncTime = DateTime(2025, 1, 1);
      
      await syncStateDao.updateLastSync(
        'test-state-3',
        lastSyncTime: syncTime,
        lastSyncChangeId: 150,
        deviceId: 'update-device',
      );

      final found = await syncStateDao.getById('test-state-3');
      expect(found, isNotNull);
      expect(found!.deviceId, equals('update-device'));
      expect(found.lastSyncChangeId, equals(150));
      expect(found.lastSyncTime, equals(syncTime));
    });

    test('should return null for non-existent sync state', () async {
      final found = await syncStateDao.getById('non-existent-id');
      expect(found, isNull);
    });
  });

  group('SyncStateDao Default Sync State', () {
    test('should get default sync state', () async {
      final now = DateTime.now();
      await syncStateDao.updateLastSync(
        'default',
        lastSyncTime: now,
        lastSyncChangeId: 200,
        deviceId: 'default-device',
      );

      final found = await syncStateDao.getDefault();
      expect(found, isNotNull);
      expect(found!.id, equals('default'));
    });
  });

  group('SyncStateDao Watch Operations', () {
    test('should watch sync state by id', () async {
      final now = DateTime.now();
      await syncStateDao.updateLastSync(
        'watch-state-1',
        lastSyncTime: now,
        lastSyncChangeId: 300,
        deviceId: 'watch-device',
      );

      final watched = await syncStateDao.watchById('watch-state-1').first;
      expect(watched, isNotNull);
      expect(watched!.deviceId, equals('watch-device'));
    });

    test('should watch default sync state', () async {
      final now = DateTime.now();
      await syncStateDao.updateLastSync(
        'default',
        lastSyncTime: now,
        lastSyncChangeId: 400,
        deviceId: 'watch-default-device',
      );

      final watched = await syncStateDao.watchDefault().first;
      expect(watched, isNotNull);
      expect(watched!.id, equals('default'));
    });
  });

  group('SyncStateDao Nullable Fields', () {
    test('should handle nullable lastSyncChangeId', () async {
      final now = DateTime.now();
      await syncStateDao.updateLastSync(
        'test-state-4',
        lastSyncTime: now,
        lastSyncChangeId: null,
        deviceId: 'null-change-id-device',
      );

      final found = await syncStateDao.getById('test-state-4');
      expect(found, isNotNull);
      expect(found!.lastSyncChangeId, isNull);
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('SyncStateDao Stream Reliability - watchById（0.1.160）', () {
    test('A: 初始状态（不存在的 id）应返回 null', () async {
      final result = await syncStateDao.watchById('ss-stream-nonexist').first;
      expect(result, isNull);
    });

    test('B: 插入数据后流应发出新值', () async {
      final now = DateTime.now();
      final stream = syncStateDao.watchById('ss-stream-1');
      final future = expectLater(
        stream,
        emitsInOrder([
          isNull,
          isNotNull,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await syncStateDao.upsert(SyncStateCompanion.insert(
        id: 'ss-stream-1',
        deviceId: 'stream-device-1',
        lastSyncTime: Value(now),
        lastSyncChangeId: const Value(100),
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出新值', () async {
      final now = DateTime.now();
      await syncStateDao.upsert(SyncStateCompanion.insert(
        id: 'ss-stream-2',
        deviceId: 'old-device',
        lastSyncTime: Value(now),
        lastSyncChangeId: const Value(100),
      ));
      final stream = syncStateDao.watchById('ss-stream-2');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((SyncStateData? s) => s?.deviceId == 'old-device'),
          predicate((SyncStateData? s) => s?.deviceId == 'new-device'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await syncStateDao.upsert(SyncStateCompanion.insert(
        id: 'ss-stream-2',
        deviceId: 'new-device',
        lastSyncTime: Value(now),
        lastSyncChangeId: const Value(200),
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 不存在的 id 应返回 null', () async {
      final result = await syncStateDao.watchById('').first;
      expect(result, isNull);
    });

    test('边界2: upsert 后流应发出更新后的新值', () async {
      final now = DateTime.now();
      await syncStateDao.upsert(SyncStateCompanion.insert(
        id: 'ss-stream-3',
        deviceId: 'boundary-device',
        lastSyncTime: Value(now),
        lastSyncChangeId: const Value(100),
      ));
      final stream = syncStateDao.watchById('ss-stream-3');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((SyncStateData? s) => s?.lastSyncChangeId == 100),
          predicate((SyncStateData? s) => s?.lastSyncChangeId == 200),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await syncStateDao.upsert(SyncStateCompanion.insert(
        id: 'ss-stream-3',
        deviceId: 'boundary-device',
        lastSyncTime: Value(now),
        lastSyncChangeId: const Value(200),
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('SyncStateDao Stream Reliability - watchDefault（0.1.160）', () {
    test('A: 初始状态应返回 null', () async {
      final result = await syncStateDao.watchDefault().first;
      expect(result, isNull);
    });

    test('B: 插入数据后流应发出新值', () async {
      final now = DateTime.now();
      final stream = syncStateDao.watchDefault();
      final future = expectLater(
        stream,
        emitsInOrder([
          isNull,
          isNotNull,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await syncStateDao.upsert(SyncStateCompanion.insert(
        id: 'default',
        deviceId: 'default-device',
        lastSyncTime: Value(now),
        lastSyncChangeId: const Value(100),
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出新值', () async {
      final now = DateTime.now();
      await syncStateDao.upsert(SyncStateCompanion.insert(
        id: 'default',
        deviceId: 'default-device',
        lastSyncTime: Value(now),
        lastSyncChangeId: const Value(100),
      ));
      final stream = syncStateDao.watchDefault();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((SyncStateData? s) => s?.lastSyncChangeId == 100),
          predicate((SyncStateData? s) => s?.lastSyncChangeId == 200),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await syncStateDao.upsert(SyncStateCompanion.insert(
        id: 'default',
        deviceId: 'default-device',
        lastSyncTime: Value(now),
        lastSyncChangeId: const Value(200),
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 未插入 default 记录时应返回 null', () async {
      final result = await syncStateDao.watchDefault().first;
      expect(result, isNull);
    });

    test('边界2: updateLastSync 后流应发出新值', () async {
      final now = DateTime.now();
      await syncStateDao.updateLastSync(
        'default',
        lastSyncTime: now,
        lastSyncChangeId: 100,
        deviceId: 'update-device',
      );
      final stream = syncStateDao.watchDefault();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((SyncStateData? s) => s?.lastSyncChangeId == 100),
          predicate((SyncStateData? s) => s?.lastSyncChangeId == 200),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await syncStateDao.updateLastSync(
        'default',
        lastSyncTime: now,
        lastSyncChangeId: 200,
        deviceId: 'update-device',
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });
  });
}
