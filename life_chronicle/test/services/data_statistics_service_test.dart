import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/services/data_statistics_service.dart';
import '../test_utils/test_data_factory.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase.connect(NativeDatabase.memory());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('DataStatisticsService Tests', skip: '需要 path_provider 插件，在集成测试环境中运行', () {
    late AppDatabase db;
    late DataStatisticsService statisticsService;

    setUp(() {
      db = _createTestDatabase();
      statisticsService = DataStatisticsService(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('getStatistics should return empty statistics when no data', () async {
      final stats = await statisticsService.getStatistics();

      expect(stats, isNotNull);
      expect(stats.foodStats.recordCount, equals(0));
      expect(stats.momentStats.recordCount, equals(0));
      expect(stats.friendStats.recordCount, equals(0));
      expect(stats.travelStats.recordCount, equals(0));
      expect(stats.goalStats.recordCount, equals(0));
      expect(stats.timelineStats.recordCount, equals(0));
      expect(stats.totalRecordCount, equals(0));
      expect(stats.totalMediaFileCount, equals(0));
      expect(stats.totalMediaFileSize, equals(0));
    });

    test('getStatistics should count food records correctly', () async {
      await db.foodDao.upsert(TestDataFactory.createFoodRecord(title: 'Food 1'));
      await db.foodDao.upsert(TestDataFactory.createFoodRecord(title: 'Food 2'));
      await db.foodDao.upsert(TestDataFactory.createFoodRecord(title: 'Food 3'));

      final stats = await statisticsService.getStatistics();

      expect(stats.foodStats.recordCount, equals(3));
      expect(stats.totalRecordCount, equals(3));
    });

    test('getStatistics should count moment records correctly', () async {
      await (db.into(db.momentRecords)).insert(TestDataFactory.createMomentRecord(content: 'Moment 1'));
      await (db.into(db.momentRecords)).insert(TestDataFactory.createMomentRecord(content: 'Moment 2'));

      final stats = await statisticsService.getStatistics();

      expect(stats.momentStats.recordCount, equals(2));
      expect(stats.totalRecordCount, equals(2));
    });

    test('getStatistics should count friend records correctly', () async {
      await (db.into(db.friendRecords)).insert(TestDataFactory.createFriendRecord(name: 'Friend 1'));
      await (db.into(db.friendRecords)).insert(TestDataFactory.createFriendRecord(name: 'Friend 2'));
      await (db.into(db.friendRecords)).insert(TestDataFactory.createFriendRecord(name: 'Friend 3'));
      await (db.into(db.friendRecords)).insert(TestDataFactory.createFriendRecord(name: 'Friend 4'));

      final stats = await statisticsService.getStatistics();

      expect(stats.friendStats.recordCount, equals(4));
      expect(stats.totalRecordCount, equals(4));
    });

    test('getStatistics should count travel records correctly', () async {
      await (db.into(db.travelRecords)).insert(TestDataFactory.createTravelRecord(title: 'Travel 1'));
      await (db.into(db.travelRecords)).insert(TestDataFactory.createTravelRecord(title: 'Travel 2'));

      final stats = await statisticsService.getStatistics();

      expect(stats.travelStats.recordCount, equals(2));
      expect(stats.totalRecordCount, equals(2));
    });

    test('getStatistics should count goal records correctly', () async {
      await (db.into(db.goalRecords)).insert(TestDataFactory.createGoalRecord(title: 'Goal 1'));
      await (db.into(db.goalRecords)).insert(TestDataFactory.createGoalRecord(title: 'Goal 2'));
      await (db.into(db.goalRecords)).insert(TestDataFactory.createGoalRecord(title: 'Goal 3'));

      final stats = await statisticsService.getStatistics();

      expect(stats.goalStats.recordCount, equals(3));
      expect(stats.totalRecordCount, equals(3));
    });

    test('getStatistics should count timeline events correctly', () async {
      await (db.into(db.timelineEvents)).insert(TestDataFactory.createTimelineEvent(title: 'Event 1'));
      await (db.into(db.timelineEvents)).insert(TestDataFactory.createTimelineEvent(title: 'Event 2'));

      final stats = await statisticsService.getStatistics();

      expect(stats.timelineStats.recordCount, equals(2));
      expect(stats.totalRecordCount, equals(2));
    });

    test('getStatistics should count all record types together correctly', () async {
      await db.foodDao.upsert(TestDataFactory.createFoodRecord(title: 'Food 1'));
      await (db.into(db.momentRecords)).insert(TestDataFactory.createMomentRecord(content: 'Moment 1'));
      await (db.into(db.friendRecords)).insert(TestDataFactory.createFriendRecord(name: 'Friend 1'));
      await (db.into(db.travelRecords)).insert(TestDataFactory.createTravelRecord(title: 'Travel 1'));
      await (db.into(db.goalRecords)).insert(TestDataFactory.createGoalRecord(title: 'Goal 1'));
      await (db.into(db.timelineEvents)).insert(TestDataFactory.createTimelineEvent(title: 'Event 1'));

      final stats = await statisticsService.getStatistics();

      expect(stats.foodStats.recordCount, equals(1));
      expect(stats.momentStats.recordCount, equals(1));
      expect(stats.friendStats.recordCount, equals(1));
      expect(stats.travelStats.recordCount, equals(1));
      expect(stats.goalStats.recordCount, equals(1));
      expect(stats.timelineStats.recordCount, equals(1));
      expect(stats.totalRecordCount, equals(6));
    });

    test('getStatistics should return lastBackupTime when backup exists', () async {
      final now = DateTime.now();
      await db.backupLogDao.insert(BackupLogsCompanion(
        id: const Value('test-backup-1'),
        backupType: const Value('full'),
        storageType: const Value('cloud'),
        fileName: const Value('test.zip'),
        status: const Value('completed'),
        startedAt: Value(now.subtract(const Duration(hours: 2))),
        completedAt: Value(now.subtract(const Duration(hours: 1))),
        createdAt: Value(now.subtract(const Duration(hours: 2))),
      ));

      final stats = await statisticsService.getStatistics();

      expect(stats.lastBackupTime, isNotNull);
      expect(stats.lastBackupTime!.isAfter(now.subtract(const Duration(hours: 2))), isTrue);
      expect(stats.lastBackupTime!.isBefore(now), isTrue);
    });

    test('getStatistics should return null for lastBackupTime when no backups exist', () async {
      final stats = await statisticsService.getStatistics();

      expect(stats.lastBackupTime, isNull);
    });

    group('ModuleStatistics formatters', () {
      test('formattedMediaSize should format bytes correctly', () {
        final stats = ModuleStatistics(
          recordCount: 10,
          mediaFileCount: 5,
          mediaFileSize: 500,
        );

        expect(stats.formattedMediaSize, equals('500 B'));
      });

      test('formattedMediaSize should format kilobytes correctly', () {
        final stats = ModuleStatistics(
          recordCount: 10,
          mediaFileCount: 5,
          mediaFileSize: 1024 * 5,
        );

        expect(stats.formattedMediaSize, equals('5.0 KB'));
      });

      test('formattedMediaSize should format megabytes correctly', () {
        final stats = ModuleStatistics(
          recordCount: 10,
          mediaFileCount: 5,
          mediaFileSize: 1024 * 1024 * 10,
        );

        expect(stats.formattedMediaSize, equals('10.0 MB'));
      });

      test('formattedMediaSize should format gigabytes correctly', () {
        final stats = ModuleStatistics(
          recordCount: 10,
          mediaFileCount: 5,
          mediaFileSize: 1024 * 1024 * 1024 * 2,
        );

        expect(stats.formattedMediaSize, equals('2.0 GB'));
      });
    });

    group('DataStatistics formatters', () {
      test('formattedTotalMediaSize should format correctly', () {
        final stats = DataStatistics(
          foodStats: ModuleStatistics(recordCount: 0, mediaFileCount: 0, mediaFileSize: 0),
          momentStats: ModuleStatistics(recordCount: 0, mediaFileCount: 0, mediaFileSize: 0),
          friendStats: ModuleStatistics(recordCount: 0, mediaFileCount: 0, mediaFileSize: 0),
          travelStats: ModuleStatistics(recordCount: 0, mediaFileCount: 0, mediaFileSize: 0),
          goalStats: ModuleStatistics(recordCount: 0, mediaFileCount: 0, mediaFileSize: 0),
          timelineStats: ModuleStatistics(recordCount: 0, mediaFileCount: 0, mediaFileSize: 0),
          totalRecordCount: 0,
          totalMediaFileCount: 0,
          totalMediaFileSize: 1024 * 1024 * 5,
          databaseSize: 0,
        );

        expect(stats.formattedTotalMediaSize, equals('5.0 MB'));
      });

      test('formattedDatabaseSize should format correctly', () {
        final stats = DataStatistics(
          foodStats: ModuleStatistics(recordCount: 0, mediaFileCount: 0, mediaFileSize: 0),
          momentStats: ModuleStatistics(recordCount: 0, mediaFileCount: 0, mediaFileSize: 0),
          friendStats: ModuleStatistics(recordCount: 0, mediaFileCount: 0, mediaFileSize: 0),
          travelStats: ModuleStatistics(recordCount: 0, mediaFileCount: 0, mediaFileSize: 0),
          goalStats: ModuleStatistics(recordCount: 0, mediaFileCount: 0, mediaFileSize: 0),
          timelineStats: ModuleStatistics(recordCount: 0, mediaFileCount: 0, mediaFileSize: 0),
          totalRecordCount: 0,
          totalMediaFileCount: 0,
          totalMediaFileSize: 0,
          databaseSize: 1024 * 1024 * 10,
        );

        expect(stats.formattedDatabaseSize, equals('10.0 MB'));
      });
    });
  });
}
