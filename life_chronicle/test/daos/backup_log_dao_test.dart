import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late BackupLogDao backupLogDao;

  setUp(() async {
    db = createTestDatabase();
    backupLogDao = BackupLogDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('BackupLogDao CRUD Operations', () {
    test('should insert a backup log', () async {
      final now = DateTime.now();
      final entry = BackupLogsCompanion.insert(
        id: 'test-log-1',
        backupType: 'manual',
        storageType: 'local',
        fileName: 'backup_2025.db',
        status: 'in_progress',
        startedAt: now,
        createdAt: now,
      );

      await backupLogDao.insert(entry);

      final logs = await backupLogDao.findAll();
      expect(logs.length, greaterThanOrEqualTo(1));
      expect(logs.any((l) => l.id == 'test-log-1'), isTrue);
    });

    test('should update backup log status', () async {
      final now = DateTime.now();
      final entry = BackupLogsCompanion.insert(
        id: 'test-log-2',
        backupType: 'manual',
        storageType: 'local',
        fileName: 'backup_2025.db',
        status: 'in_progress',
        startedAt: now,
        createdAt: now,
      );

      await backupLogDao.insert(entry);
      await backupLogDao.updateStatus('test-log-2', 'completed', errorMessage: null, completedAt: now);

      final logs = await backupLogDao.findAll();
      final found = logs.firstWhere((l) => l.id == 'test-log-2');
      expect(found.status, equals('completed'));
    });

    test('should delete a backup log by id', () async {
      final now = DateTime.now();
      final entry = BackupLogsCompanion.insert(
        id: 'test-log-3',
        backupType: 'manual',
        storageType: 'local',
        fileName: 'backup_2025.db',
        status: 'completed',
        startedAt: now,
        createdAt: now,
      );

      await backupLogDao.insert(entry);
      await backupLogDao.deleteById('test-log-3');

      final logs = await backupLogDao.findAll();
      expect(logs.any((l) => l.id == 'test-log-3'), isFalse);
    });

    test('should delete backup logs older than a date', () async {
      final now = DateTime.now();
      final oldDate = now.subtract(const Duration(days: 10));
      final entry1 = BackupLogsCompanion.insert(
        id: 'test-log-4',
        backupType: 'manual',
        storageType: 'local',
        fileName: 'old_backup.db',
        status: 'completed',
        startedAt: now,
        createdAt: oldDate,
      );
      final entry2 = BackupLogsCompanion.insert(
        id: 'test-log-5',
        backupType: 'manual',
        storageType: 'local',
        fileName: 'new_backup.db',
        status: 'completed',
        startedAt: now,
        createdAt: now,
      );

      await backupLogDao.insert(entry1);
      await backupLogDao.insert(entry2);
      await backupLogDao.deleteOlderThan(now.subtract(const Duration(days: 5)));

      final logs = await backupLogDao.findAll();
      expect(logs.any((l) => l.id == 'test-log-4'), isFalse);
      expect(logs.any((l) => l.id == 'test-log-5'), isTrue);
    });
  });

  group('BackupLogDao Query Operations', () {
    test('should find latest successful backup log', () async {
      final now = DateTime.now();
      final entry1 = BackupLogsCompanion.insert(
        id: 'test-log-6',
        backupType: 'manual',
        storageType: 'local',
        fileName: 'backup1.db',
        status: 'completed',
        startedAt: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
      );
      final entry2 = BackupLogsCompanion.insert(
        id: 'test-log-7',
        backupType: 'manual',
        storageType: 'local',
        fileName: 'backup2.db',
        status: 'completed',
        startedAt: now,
        createdAt: now,
      );

      await backupLogDao.insert(entry1);
      await backupLogDao.insert(entry2);

      final latest = await backupLogDao.findLatestSuccessful();
      expect(latest, isNotNull);
      expect(latest!.id, equals('test-log-7'));
    });

    test('should find latest by storage type', () async {
      final now = DateTime.now();
      final entry1 = BackupLogsCompanion.insert(
        id: 'test-log-8',
        backupType: 'manual',
        storageType: 'webdav',
        fileName: 'webdav_backup1.db',
        status: 'completed',
        startedAt: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
      );
      final entry2 = BackupLogsCompanion.insert(
        id: 'test-log-9',
        backupType: 'manual',
        storageType: 'webdav',
        fileName: 'webdav_backup2.db',
        status: 'completed',
        startedAt: now,
        createdAt: now,
      );

      await backupLogDao.insert(entry1);
      await backupLogDao.insert(entry2);

      final latest = await backupLogDao.findLatestByStorageType('webdav');
      expect(latest, isNotNull);
      expect(latest!.id, equals('test-log-9'));
    });

    test('should count by status', () async {
      final now = DateTime.now();
      final entry1 = BackupLogsCompanion.insert(
        id: 'test-log-10',
        backupType: 'manual',
        storageType: 'local',
        fileName: 'backup1.db',
        status: 'completed',
        startedAt: now,
        createdAt: now,
      );
      final entry2 = BackupLogsCompanion.insert(
        id: 'test-log-11',
        backupType: 'manual',
        storageType: 'local',
        fileName: 'backup2.db',
        status: 'completed',
        startedAt: now,
        createdAt: now,
      );
      final entry3 = BackupLogsCompanion.insert(
        id: 'test-log-12',
        backupType: 'manual',
        storageType: 'local',
        fileName: 'backup3.db',
        status: 'failed',
        startedAt: now,
        createdAt: now,
      );

      await backupLogDao.insert(entry1);
      await backupLogDao.insert(entry2);
      await backupLogDao.insert(entry3);

      final completedCount = await backupLogDao.countByStatus('completed');
      final failedCount = await backupLogDao.countByStatus('failed');

      expect(completedCount, equals(2));
      expect(failedCount, equals(1));
    });
  });

  group('BackupLogDao Watch Operations', () {
    test('should watch all backup logs', () async {
      final now = DateTime.now();
      final entry = BackupLogsCompanion.insert(
        id: 'watch-log-1',
        backupType: 'manual',
        storageType: 'local',
        fileName: 'watch_backup.db',
        status: 'completed',
        startedAt: now,
        createdAt: now,
      );

      await backupLogDao.insert(entry);

      final logs = await backupLogDao.watchAll().first;
      expect(logs.any((l) => l.id == 'watch-log-1'), isTrue);
    });

    test('should watch by storage type', () async {
      final now = DateTime.now();
      final entry1 = BackupLogsCompanion.insert(
        id: 'watch-log-2',
        backupType: 'manual',
        storageType: 'local',
        fileName: 'local_backup.db',
        status: 'completed',
        startedAt: now,
        createdAt: now,
      );
      final entry2 = BackupLogsCompanion.insert(
        id: 'watch-log-3',
        backupType: 'manual',
        storageType: 'webdav',
        fileName: 'webdav_backup.db',
        status: 'completed',
        startedAt: now,
        createdAt: now,
      );

      await backupLogDao.insert(entry1);
      await backupLogDao.insert(entry2);

      final logs = await backupLogDao.watchByStorageType('local').first;
      expect(logs.any((l) => l.id == 'watch-log-2'), isTrue);
      expect(logs.any((l) => l.id == 'watch-log-3'), isFalse);
    });
  });
}
