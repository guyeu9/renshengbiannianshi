import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late GoalReviewDao goalReviewDao;

  setUp(() async {
    db = createTestDatabase();
    goalReviewDao = GoalReviewDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('GoalReviewDao CRUD Operations', () {
    test('should insert a goal review', () async {
      final now = DateTime.now();
      final entry = GoalReviewsCompanion.insert(
        id: 'test-review-1',
        goalId: 'test-goal-1',
        title: 'Test Review',
        content: const Value('Review content'),
        reviewDate: now,
        createdAt: now,
      );

      await goalReviewDao.insert(entry);

      final found = await goalReviewDao.findById('test-review-1');
      expect(found, isNotNull);
      expect(found!.title, equals('Test Review'));
      expect(found.content, equals('Review content'));
    });

    test('should upsert a goal review', () async {
      final now = DateTime.now();
      final entry = GoalReviewsCompanion.insert(
        id: 'test-review-2',
        goalId: 'test-goal-1',
        title: 'Old Title',
        reviewDate: now,
        createdAt: now,
      );

      await goalReviewDao.upsert(entry);

      final updatedEntry = GoalReviewsCompanion.insert(
        id: 'test-review-2',
        goalId: 'test-goal-1',
        title: 'New Title',
        reviewDate: now,
        createdAt: now,
      );

      await goalReviewDao.upsert(updatedEntry);

      final found = await goalReviewDao.findById('test-review-2');
      expect(found!.title, equals('New Title'));
    });

    test('should update review details', () async {
      final now = DateTime.now();
      final reviewDate = DateTime(2025, 1, 1);
      final entry = GoalReviewsCompanion.insert(
        id: 'test-review-3',
        goalId: 'test-goal-1',
        title: 'Old Title',
        content: const Value('Old content'),
        reviewDate: reviewDate,
        createdAt: now,
      );

      await goalReviewDao.insert(entry);

      final newReviewDate = DateTime(2025, 2, 1);
      await goalReviewDao.updateReview(
        'test-review-3',
        title: 'New Title',
        content: 'New content',
        reviewDate: newReviewDate,
        now: now,
      );

      final found = await goalReviewDao.findById('test-review-3');
      expect(found!.title, equals('New Title'));
      expect(found.content, equals('New content'));
      expect(found.reviewDate, equals(newReviewDate));
    });

    test('should delete a goal review by id', () async {
      final now = DateTime.now();
      final entry = GoalReviewsCompanion.insert(
        id: 'test-review-4',
        goalId: 'test-goal-1',
        title: 'Test Review',
        reviewDate: now,
        createdAt: now,
      );

      await goalReviewDao.insert(entry);
      await goalReviewDao.deleteById('test-review-4');

      final found = await goalReviewDao.findById('test-review-4');
      expect(found, isNull);
    });

    test('should delete all goal reviews by goal id', () async {
      final now = DateTime.now();
      await goalReviewDao.insert(GoalReviewsCompanion.insert(
        id: 'test-review-5',
        goalId: 'test-goal-2',
        title: 'Review 1',
        reviewDate: now,
        createdAt: now,
      ));
      await goalReviewDao.insert(GoalReviewsCompanion.insert(
        id: 'test-review-6',
        goalId: 'test-goal-2',
        title: 'Review 2',
        reviewDate: now,
        createdAt: now,
      ));
      await goalReviewDao.insert(GoalReviewsCompanion.insert(
        id: 'test-review-7',
        goalId: 'test-goal-3',
        title: 'Review 3',
        reviewDate: now,
        createdAt: now,
      ));

      await goalReviewDao.deleteByGoalId('test-goal-2');

      final reviews1 = await goalReviewDao.listByGoalId('test-goal-2');
      final reviews2 = await goalReviewDao.listByGoalId('test-goal-3');

      expect(reviews1.length, equals(0));
      expect(reviews2.length, equals(1));
    });
  });

  group('GoalReviewDao Query Operations', () {
    test('should list goal reviews by goal id in order', () async {
      final now = DateTime.now();
      await goalReviewDao.insert(GoalReviewsCompanion.insert(
        id: 'test-review-8',
        goalId: 'test-goal-4',
        title: 'Review 1',
        reviewDate: now.subtract(const Duration(days: 1)),
        createdAt: now,
      ));
      await goalReviewDao.insert(GoalReviewsCompanion.insert(
        id: 'test-review-9',
        goalId: 'test-goal-4',
        title: 'Review 2',
        reviewDate: now,
        createdAt: now,
      ));

      final reviews = await goalReviewDao.listByGoalId('test-goal-4');
      expect(reviews.length, equals(2));
      expect(reviews[0].reviewDate.isAfter(reviews[1].reviewDate), isTrue);
    });
  });

  group('GoalReviewDao Watch Operations', () {
    test('should watch goal reviews by goal id', () async {
      final now = DateTime.now();
      await goalReviewDao.insert(GoalReviewsCompanion.insert(
        id: 'watch-review-1',
        goalId: 'watch-goal-1',
        title: 'Watch Review',
        reviewDate: now,
        createdAt: now,
      ));

      final reviews = await goalReviewDao.watchByGoalId('watch-goal-1').first;
      expect(reviews.length, equals(1));
      expect(reviews[0].title, equals('Watch Review'));
    });
  });
}
