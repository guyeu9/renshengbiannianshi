import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late AnnualReviewDao annualReviewDao;

  setUp(() async {
    db = createTestDatabase();
    annualReviewDao = AnnualReviewDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('AnnualReviewDao CRUD Operations', () {
    test('should insert an annual review', () async {
      final now = DateTime.now();
      final entry = AnnualReviewsCompanion.insert(
        id: 'test-review-1',
        year: 2025,
        content: const Value('This is a test annual review'),
        createdAt: now,
        updatedAt: now,
      );

      await annualReviewDao.upsert(entry);

      final found = await annualReviewDao.findByYear(2025);
      expect(found, isNotNull);
      expect(found!.content, equals('This is a test annual review'));
    });

    test('should update an existing annual review', () async {
      final now = DateTime.now();
      final entry = AnnualReviewsCompanion.insert(
        id: 'test-review-2',
        year: 2026,
        content: const Value('Old content'),
        createdAt: now,
        updatedAt: now,
      );

      await annualReviewDao.upsert(entry);

      final updatedEntry = AnnualReviewsCompanion.insert(
        id: 'test-review-2',
        year: 2026,
        content: const Value('New content'),
        createdAt: now,
        updatedAt: now,
      );

      await annualReviewDao.upsert(updatedEntry);

      final found = await annualReviewDao.findByYear(2026);
      expect(found!.content, equals('New content'));
    });

    test('should delete an annual review by year', () async {
      final now = DateTime.now();
      final entry = AnnualReviewsCompanion.insert(
        id: 'test-review-3',
        year: 2027,
        content: const Value('Test content'),
        createdAt: now,
        updatedAt: now,
      );

      await annualReviewDao.upsert(entry);
      await annualReviewDao.deleteByYear(2027);

      final found = await annualReviewDao.findByYear(2027);
      expect(found, isNull);
    });

    test('should return null for non-existent year', () async {
      final found = await annualReviewDao.findByYear(9999);
      expect(found, isNull);
    });
  });

  group('AnnualReviewDao Watch Operations', () {
    test('should watch annual review by year', () async {
      final now = DateTime.now();
      final entry = AnnualReviewsCompanion.insert(
        id: 'watch-review-1',
        year: 2028,
        content: const Value('Watch test content'),
        createdAt: now,
        updatedAt: now,
      );

      await annualReviewDao.upsert(entry);

      final watched = await annualReviewDao.watchByYear(2028).first;
      expect(watched, isNotNull);
      expect(watched!.year, equals(2028));
    });
  });
}
