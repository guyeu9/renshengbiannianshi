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

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('AnnualReviewDao Stream Reliability - watchByYear（0.1.160）', () {
    test('A: 初始状态（不存在的 year）应返回 null', () async {
      final result = await annualReviewDao.watchByYear(3999).first;
      expect(result, isNull);
    });

    test('B: 插入数据后流应发出新值', () async {
      final now = DateTime.now();
      final stream = annualReviewDao.watchByYear(2025);
      final future = expectLater(
        stream,
        emitsInOrder([
          isNull,
          isNotNull,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await annualReviewDao.upsert(AnnualReviewsCompanion.insert(
        id: 'ar-stream-year-1',
        year: 2025,
        content: const Value('Stream test'),
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出新值', () async {
      final now = DateTime.now();
      await annualReviewDao.upsert(AnnualReviewsCompanion.insert(
        id: 'ar-stream-year-2',
        year: 2026,
        title: const Value('旧标题'),
        createdAt: now,
        updatedAt: now,
      ));
      final stream = annualReviewDao.watchByYear(2026);
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((AnnualReview? r) => r?.title == '旧标题'),
          predicate((AnnualReview? r) => r?.title == '新标题'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await annualReviewDao.updateTitle('ar-stream-year-2', '新标题');
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 不存在的 year 返回 null', () async {
      final result = await annualReviewDao.watchByYear(4999).first;
      expect(result, isNull);
    });

    test('边界2: deleteByYear 后返回 null', () async {
      final now = DateTime.now();
      await annualReviewDao.upsert(AnnualReviewsCompanion.insert(
        id: 'ar-stream-year-3',
        year: 2027,
        createdAt: now,
        updatedAt: now,
      ));
      await annualReviewDao.deleteByYear(2027);
      final result = await annualReviewDao.watchByYear(2027).first;
      expect(result, isNull);
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('AnnualReviewDao Stream Reliability - watchAll（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await annualReviewDao.watchAll().first;
      expect(result, isEmpty);
    });

    test('B: 插入数据后流应发出包含新记录的列表', () async {
      final now = DateTime.now();
      final stream = annualReviewDao.watchAll();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<AnnualReview> list) => list.any((r) => r.id == 'ar-stream-all-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await annualReviewDao.upsert(AnnualReviewsCompanion.insert(
        id: 'ar-stream-all-1',
        year: 2030,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出包含更新后记录的列表', () async {
      final now = DateTime.now();
      await annualReviewDao.upsert(AnnualReviewsCompanion.insert(
        id: 'ar-stream-all-2',
        year: 2031,
        title: const Value('旧标题'),
        createdAt: now,
        updatedAt: now,
      ));
      final stream = annualReviewDao.watchAll();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<AnnualReview> list) => list.firstWhere((r) => r.id == 'ar-stream-all-2').title == '旧标题'),
          predicate((List<AnnualReview> list) => list.firstWhere((r) => r.id == 'ar-stream-all-2').title == '新标题'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await annualReviewDao.updateTitle('ar-stream-all-2', '新标题');
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: year 降序排序', () async {
      final now = DateTime.now();
      await annualReviewDao.upsert(AnnualReviewsCompanion.insert(
        id: 'ar-stream-order-1',
        year: 2030,
        createdAt: now,
        updatedAt: now,
      ));
      await annualReviewDao.upsert(AnnualReviewsCompanion.insert(
        id: 'ar-stream-order-2',
        year: 2035,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await annualReviewDao.watchAll().first;
      expect(result.first.id, equals('ar-stream-order-2'));
      expect(result.last.id, equals('ar-stream-order-1'));
    });

    test('边界2: deleteById 后不返回', () async {
      final now = DateTime.now();
      await annualReviewDao.upsert(AnnualReviewsCompanion.insert(
        id: 'ar-stream-deleted-1',
        year: 2040,
        createdAt: now,
        updatedAt: now,
      ));
      await annualReviewDao.deleteById('ar-stream-deleted-1');
      final result = await annualReviewDao.watchAll().first;
      expect(result.any((r) => r.id == 'ar-stream-deleted-1'), isFalse);
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('AnnualReviewDao Stream Reliability - watchById（0.1.160）', () {
    test('A: 初始状态（不存在的 id）应返回 null', () async {
      final result = await annualReviewDao.watchById('non-existent').first;
      expect(result, isNull);
    });

    test('B: 插入数据后流应发出新值', () async {
      final now = DateTime.now();
      final stream = annualReviewDao.watchById('ar-stream-byid-1');
      final future = expectLater(
        stream,
        emitsInOrder([
          isNull,
          isNotNull,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await annualReviewDao.upsert(AnnualReviewsCompanion.insert(
        id: 'ar-stream-byid-1',
        year: 2045,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 不存在的 id 返回 null', () async {
      final result = await annualReviewDao.watchById('').first;
      expect(result, isNull);
    });

    test('边界2: deleteById 后返回 null', () async {
      final now = DateTime.now();
      await annualReviewDao.upsert(AnnualReviewsCompanion.insert(
        id: 'ar-stream-byid-2',
        year: 2046,
        createdAt: now,
        updatedAt: now,
      ));
      await annualReviewDao.deleteById('ar-stream-byid-2');
      final result = await annualReviewDao.watchById('ar-stream-byid-2').first;
      expect(result, isNull);
    });
  });
}
