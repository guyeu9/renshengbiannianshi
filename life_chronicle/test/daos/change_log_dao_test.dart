import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late ChangeLogDao changeLogDao;

  setUp(() async {
    db = createTestDatabase();
    changeLogDao = ChangeLogDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('ChangeLogDao CRUD Operations', () {
    test('should insert a change log', () async {
      final now = DateTime.now();
      final entry = ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'test-entity-1',
        action: 'insert',
        timestamp: now,
      );

      await changeLogDao.insert(entry);

      final logs = await changeLogDao.findAll();
      expect(logs.length, greaterThanOrEqualTo(1));
    });

    test('should mark a change log as synced by id', () async {
      final now = DateTime.now();
      final entry = ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'test-entity-2',
        action: 'insert',
        timestamp: now,
      );

      await changeLogDao.insert(entry);
      final logs = await changeLogDao.findUnsynced();
      final logId = logs.first.id;

      await changeLogDao.markAsSynced(logId);

      final unsyncedLogs = await changeLogDao.findUnsynced();
      expect(unsyncedLogs.any((l) => l.id == logId), isFalse);
    });

    test('should mark multiple change logs as synced by ids', () async {
      final now = DateTime.now();
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'test-entity-3',
        action: 'insert',
        timestamp: now,
      ));
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'test-entity-4',
        action: 'insert',
        timestamp: now,
      ));

      final unsyncedLogs = await changeLogDao.findUnsynced();
      final ids = unsyncedLogs.map((l) => l.id).toList();

      await changeLogDao.markAllAsSyncedByIds(ids);

      final unsyncedAfter = await changeLogDao.findUnsynced();
      expect(unsyncedAfter.length, equals(0));
    });

    test('should mark all change logs as synced', () async {
      final now = DateTime.now();
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'test-entity-5',
        action: 'insert',
        timestamp: now,
      ));
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'test-entity-6',
        action: 'insert',
        timestamp: now,
      ));

      await changeLogDao.markAllAsSynced();

      final unsyncedLogs = await changeLogDao.findUnsynced();
      expect(unsyncedLogs.length, equals(0));
    });

    test('should delete all synced change logs', () async {
      final now = DateTime.now();
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'test-entity-7',
        action: 'insert',
        timestamp: now,
      ));
      await changeLogDao.markAllAsSynced();

      await changeLogDao.deleteAllSynced();

      final logs = await changeLogDao.findAll();
      expect(logs.length, equals(0));
    });
  });

  group('ChangeLogDao Query Operations', () {
    test('should find unsynced change logs', () async {
      final now = DateTime.now();
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'test-entity-8',
        action: 'insert',
        timestamp: now,
      ));
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'test-entity-9',
        action: 'insert',
        timestamp: now,
        synced: const Value(true),
      ));

      final unsynced = await changeLogDao.findUnsynced();
      expect(unsynced.length, equals(1));
      expect(unsynced.first.entityId, equals('test-entity-8'));
    });

    test('should get last unsynced id', () async {
      final now = DateTime.now();
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'test-entity-10',
        action: 'insert',
        timestamp: now,
      ));
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'test-entity-11',
        action: 'insert',
        timestamp: now,
      ));

      final lastId = await changeLogDao.getLastUnsyncedId();
      expect(lastId, isNotNull);
      expect(lastId, isPositive);
    });

    test('should return null for last unsynced id when none exist', () async {
      final lastId = await changeLogDao.getLastUnsyncedId();
      expect(lastId, isNull);
    });
  });

  group('ChangeLogDao Watch Operations', () {
    test('should watch all change logs', () async {
      final now = DateTime.now();
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'watch-entity-1',
        action: 'insert',
        timestamp: now,
      ));

      final logs = await changeLogDao.watchAll().first;
      expect(logs.length, greaterThanOrEqualTo(1));
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('ChangeLogDao Stream Reliability - watchAll（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await changeLogDao.watchAll().first;
      expect(result, isEmpty);
    });

    test('B: 插入数据后流应发出包含新记录的列表', () async {
      final now = DateTime.now();
      final stream = changeLogDao.watchAll();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<ChangeLog> list) =>
              list.any((l) => l.entityId == 'cl-stream-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'cl-stream-1',
        action: 'insert',
        timestamp: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出新值', () async {
      final now = DateTime.now();
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'cl-stream-2',
        action: 'insert',
        timestamp: now,
      ));
      final logs = await changeLogDao.findAll();
      final logId = logs.firstWhere((l) => l.entityId == 'cl-stream-2').id;
      final stream = changeLogDao.watchAll();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<ChangeLog> list) =>
              list.firstWhere((l) => l.id == logId).synced == false),
          predicate((List<ChangeLog> list) =>
              list.firstWhere((l) => l.id == logId).synced == true),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await changeLogDao.markAsSynced(logId);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 删除后流应发出不包含该记录的列表', () async {
      final now = DateTime.now();
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'cl-stream-3',
        action: 'insert',
        timestamp: now,
      ));
      final logs = await changeLogDao.findAll();
      final logId = logs.first.id;
      await changeLogDao.markAsSynced(logId);
      final stream = changeLogDao.watchAll();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate(
              (List<ChangeLog> list) => list.any((l) => l.id == logId)),
          predicate(
              (List<ChangeLog> list) => !list.any((l) => l.id == logId)),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await changeLogDao.deleteAllSynced();
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 插入多条后应按 id 降序排序', () async {
      final now = DateTime.now();
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'cl-stream-4',
        action: 'insert',
        timestamp: now,
      ));
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'cl-stream-5',
        action: 'insert',
        timestamp: now,
      ));
      final result = await changeLogDao.watchAll().first;
      expect(result.length, greaterThanOrEqualTo(2));
      expect(result.first.id, greaterThan(result.last.id));
    });

    test('边界2: markAsSynced 后流应发出 synced=true 的记录', () async {
      final now = DateTime.now();
      await changeLogDao.insert(ChangeLogsCompanion.insert(
        entityType: 'moment',
        entityId: 'cl-stream-6',
        action: 'insert',
        timestamp: now,
      ));
      final logs = await changeLogDao.findAll();
      final logId = logs.firstWhere((l) => l.entityId == 'cl-stream-6').id;
      final stream = changeLogDao.watchAll();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<ChangeLog> list) =>
              list.any((l) => l.id == logId && l.synced == false)),
          predicate((List<ChangeLog> list) =>
              list.any((l) => l.id == logId && l.synced == true)),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await changeLogDao.markAsSynced(logId);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });
  });
}
