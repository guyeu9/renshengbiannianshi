import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/services/excel_export_service.dart';
import 'package:life_chronicle/core/services/path_provider_service.dart';
import '../test_utils/test_data_factory.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase.connect(NativeDatabase.memory());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ExcelExportService Tests', () {
    late AppDatabase db;
    late ExcelExportService excelExportService;
    late Directory tempDir;

    setUp(() async {
      db = _createTestDatabase();
      tempDir = await Directory.systemTemp.createTemp('test_excel_');
      final mockPathProvider = MockPathProviderService(
        appDocDir: tempDir,
        tempDir: tempDir,
      );
      excelExportService = ExcelExportService(db, mockPathProvider);
    });

    tearDown(() async {
      await db.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('exportToExcel should create file path with correct format', () async {
      final filePath = await excelExportService.exportToExcel(
        includeFood: true,
        includeMoment: true,
        includeFriend: true,
        includeTravel: true,
        includeGoal: true,
        includeTimeline: true,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.xlsx'));
      expect(filePath, contains('人生编年史导出'));
    });

    test('exportToExcel should work with all modules disabled', () async {
      final filePath = await excelExportService.exportToExcel(
        includeFood: false,
        includeMoment: false,
        includeFriend: false,
        includeTravel: false,
        includeGoal: false,
        includeTimeline: false,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.xlsx'));
    });

    test('exportToExcel should work with date range', () async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);

      final filePath = await excelExportService.exportToExcel(
        includeFood: true,
        includeMoment: true,
        startDate: startDate,
        endDate: endDate,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.xlsx'));
    });

    test('exportToExcel should work with only food module', () async {
      await db.foodDao.upsert(TestDataFactory.createFoodRecord(title: 'Test Food'));

      final filePath = await excelExportService.exportToExcel(
        includeFood: true,
        includeMoment: false,
        includeFriend: false,
        includeTravel: false,
        includeGoal: false,
        includeTimeline: false,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.xlsx'));
    });

    test('exportToExcel should work with only moment module', () async {
      await (db.into(db.momentRecords)).insert(TestDataFactory.createMomentRecord(content: 'Test Moment'));

      final filePath = await excelExportService.exportToExcel(
        includeFood: false,
        includeMoment: true,
        includeFriend: false,
        includeTravel: false,
        includeGoal: false,
        includeTimeline: false,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.xlsx'));
    });

    test('exportToExcel should work with only friend module', () async {
      await (db.into(db.friendRecords)).insert(TestDataFactory.createFriendRecord(name: 'Test Friend'));

      final filePath = await excelExportService.exportToExcel(
        includeFood: false,
        includeMoment: false,
        includeFriend: true,
        includeTravel: false,
        includeGoal: false,
        includeTimeline: false,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.xlsx'));
    });

    test('exportToExcel should work with only travel module', () async {
      await (db.into(db.travelRecords)).insert(TestDataFactory.createTravelRecord(title: 'Test Travel'));

      final filePath = await excelExportService.exportToExcel(
        includeFood: false,
        includeMoment: false,
        includeFriend: false,
        includeTravel: true,
        includeGoal: false,
        includeTimeline: false,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.xlsx'));
    });

    test('exportToExcel should work with only goal module', () async {
      await (db.into(db.goalRecords)).insert(TestDataFactory.createGoalRecord(title: 'Test Goal'));

      final filePath = await excelExportService.exportToExcel(
        includeFood: false,
        includeMoment: false,
        includeFriend: false,
        includeTravel: false,
        includeGoal: true,
        includeTimeline: false,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.xlsx'));
    });

    test('exportToExcel should work with only timeline module', () async {
      await (db.into(db.timelineEvents)).insert(TestDataFactory.createTimelineEvent(title: 'Test Event'));

      final filePath = await excelExportService.exportToExcel(
        includeFood: false,
        includeMoment: false,
        includeFriend: false,
        includeTravel: false,
        includeGoal: false,
        includeTimeline: true,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.xlsx'));
    });

    test('exportToExcel should work with all modules enabled and data present', () async {
      await db.foodDao.upsert(TestDataFactory.createFoodRecord(title: 'Food 1'));
      await (db.into(db.momentRecords)).insert(TestDataFactory.createMomentRecord(content: 'Moment 1'));
      await (db.into(db.friendRecords)).insert(TestDataFactory.createFriendRecord(name: 'Friend 1'));
      await (db.into(db.travelRecords)).insert(TestDataFactory.createTravelRecord(title: 'Travel 1'));
      await (db.into(db.goalRecords)).insert(TestDataFactory.createGoalRecord(title: 'Goal 1'));
      await (db.into(db.timelineEvents)).insert(TestDataFactory.createTimelineEvent(title: 'Event 1'));

      final filePath = await excelExportService.exportToExcel(
        includeFood: true,
        includeMoment: true,
        includeFriend: true,
        includeTravel: true,
        includeGoal: true,
        includeTimeline: true,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.xlsx'));

      final file = File(filePath);
      expect(await file.exists(), isTrue);
      final bytes = await file.readAsBytes();
      expect(bytes.length, greaterThan(0));
    });
  });
}
