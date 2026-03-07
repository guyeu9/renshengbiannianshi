import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/services/pdf_export_service.dart';
import '../test_utils/test_data_factory.dart';

AppDatabase _createTestDatabase() {
  return AppDatabase.connect(NativeDatabase.memory());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PdfExportService Tests', skip: '需要 path_provider 插件，在集成测试环境中运行', () {
    late AppDatabase db;
    late PdfExportService pdfExportService;

    setUp(() {
      db = _createTestDatabase();
      pdfExportService = PdfExportService(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('exportToPdf should create file path with correct format', () async {
      final filePath = await pdfExportService.exportToPdf(
        includeFood: true,
        includeMoment: true,
        includeFriend: true,
        includeTravel: true,
        includeGoal: true,
        includeTimeline: true,
        includeCover: true,
        includeToc: true,
        includeCharts: true,
        includePhotos: true,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.pdf'));
      expect(filePath, contains('人生编年史导出'));
    });

    test('exportToPdf should work with all modules disabled', () async {
      final filePath = await pdfExportService.exportToPdf(
        includeFood: false,
        includeMoment: false,
        includeFriend: false,
        includeTravel: false,
        includeGoal: false,
        includeTimeline: false,
        includeCover: true,
        includeToc: true,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.pdf'));
    });

    test('exportToPdf should work with date range', () async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);

      final filePath = await pdfExportService.exportToPdf(
        includeFood: true,
        includeMoment: true,
        startDate: startDate,
        endDate: endDate,
        includeCover: true,
        includeToc: true,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.pdf'));
    });

    test('exportToPdf should work without cover and toc', () async {
      final filePath = await pdfExportService.exportToPdf(
        includeFood: true,
        includeMoment: true,
        includeCover: false,
        includeToc: false,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.pdf'));
    });

    test('exportToPdf should work without charts and photos', () async {
      final filePath = await pdfExportService.exportToPdf(
        includeFood: true,
        includeMoment: true,
        includeCharts: false,
        includePhotos: false,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.pdf'));
    });

    test('exportToPdf should work with only food module', () async {
      await db.foodDao.upsert(TestDataFactory.createFoodRecord(title: 'Test Food'));

      final filePath = await pdfExportService.exportToPdf(
        includeFood: true,
        includeMoment: false,
        includeFriend: false,
        includeTravel: false,
        includeGoal: false,
        includeTimeline: false,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.pdf'));
    });

    test('exportToPdf should work with only moment module', () async {
      await (db.into(db.momentRecords)).insert(TestDataFactory.createMomentRecord(content: 'Test Moment'));

      final filePath = await pdfExportService.exportToPdf(
        includeFood: false,
        includeMoment: true,
        includeFriend: false,
        includeTravel: false,
        includeGoal: false,
        includeTimeline: false,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.pdf'));
    });

    test('exportToPdf should work with only friend module', () async {
      await (db.into(db.friendRecords)).insert(TestDataFactory.createFriendRecord(name: 'Test Friend'));

      final filePath = await pdfExportService.exportToPdf(
        includeFood: false,
        includeMoment: false,
        includeFriend: true,
        includeTravel: false,
        includeGoal: false,
        includeTimeline: false,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.pdf'));
    });

    test('exportToPdf should work with only travel module', () async {
      await (db.into(db.travelRecords)).insert(TestDataFactory.createTravelRecord(title: 'Test Travel'));

      final filePath = await pdfExportService.exportToPdf(
        includeFood: false,
        includeMoment: false,
        includeFriend: false,
        includeTravel: true,
        includeGoal: false,
        includeTimeline: false,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.pdf'));
    });

    test('exportToPdf should work with only goal module', () async {
      await (db.into(db.goalRecords)).insert(TestDataFactory.createGoalRecord(title: 'Test Goal'));

      final filePath = await pdfExportService.exportToPdf(
        includeFood: false,
        includeMoment: false,
        includeFriend: false,
        includeTravel: false,
        includeGoal: true,
        includeTimeline: false,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.pdf'));
    });

    test('exportToPdf should work with only timeline module', () async {
      await (db.into(db.timelineEvents)).insert(TestDataFactory.createTimelineEvent(title: 'Test Event'));

      final filePath = await pdfExportService.exportToPdf(
        includeFood: false,
        includeMoment: false,
        includeFriend: false,
        includeTravel: false,
        includeGoal: false,
        includeTimeline: true,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.pdf'));
    });

    test('exportToPdf should work with all modules enabled and data present', () async {
      await db.foodDao.upsert(TestDataFactory.createFoodRecord(title: 'Food 1'));
      await (db.into(db.momentRecords)).insert(TestDataFactory.createMomentRecord(content: 'Moment 1'));
      await (db.into(db.friendRecords)).insert(TestDataFactory.createFriendRecord(name: 'Friend 1'));
      await (db.into(db.travelRecords)).insert(TestDataFactory.createTravelRecord(title: 'Travel 1'));
      await (db.into(db.goalRecords)).insert(TestDataFactory.createGoalRecord(title: 'Goal 1'));
      await (db.into(db.timelineEvents)).insert(TestDataFactory.createTimelineEvent(title: 'Event 1'));

      final filePath = await pdfExportService.exportToPdf(
        includeFood: true,
        includeMoment: true,
        includeFriend: true,
        includeTravel: true,
        includeGoal: true,
        includeTimeline: true,
      );

      expect(filePath, isNotNull);
      expect(filePath, endsWith('.pdf'));
    });

    test('getLogs should return empty list initially', () {
      expect(pdfExportService.getLogs(), isEmpty);
    });

    test('clearLogs should clear all logs', () async {
      await pdfExportService.exportToPdf(includeFood: false, includeMoment: false);
      expect(pdfExportService.getLogs(), isNotEmpty);
      
      pdfExportService.clearLogs();
      expect(pdfExportService.getLogs(), isEmpty);
    });
  });
}
