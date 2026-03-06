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
}
