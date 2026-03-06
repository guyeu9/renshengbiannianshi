import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late GoalPostponementDao goalPostponementDao;

  setUp(() async {
    db = createTestDatabase();
    goalPostponementDao = GoalPostponementDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('GoalPostponementDao CRUD Operations', () {
    test('should insert a goal postponement', () async {
      final now = DateTime.now();
      final entry = GoalPostponementsCompanion.insert(
        id: 'test-post-1',
        goalId: 'test-goal-1',
        reason: const Value('Test reason'),
        daysAdded: const Value(7),
        createdAt: now,
      );

      await goalPostponementDao.insert(entry);

      final found = await goalPostponementDao.findById('test-post-1');
      expect(found, isNotNull);
      expect(found!.reason, equals('Test reason'));
      expect(found.daysAdded, equals(7));
    });

    test('should upsert a goal postponement', () async {
      final now = DateTime.now();
      final entry = GoalPostponementsCompanion.insert(
        id: 'test-post-2',
        goalId: 'test-goal-1',
        reason: const Value('Old reason'),
        daysAdded: const Value(7),
        createdAt: now,
      );

      await goalPostponementDao.upsert(entry);

      final updatedEntry = GoalPostponementsCompanion.insert(
        id: 'test-post-2',
        goalId: 'test-goal-1',
        reason: const Value('New reason'),
        daysAdded: const Value(14),
        createdAt: now,
      );

      await goalPostponementDao.upsert(updatedEntry);

      final found = await goalPostponementDao.findById('test-post-2');
      expect(found!.reason, equals('New reason'));
      expect(found.daysAdded, equals(14));
    });

    test('should delete a goal postponement by id', () async {
      final now = DateTime.now();
      final entry = GoalPostponementsCompanion.insert(
        id: 'test-post-3',
        goalId: 'test-goal-1',
        reason: const Value('Test reason'),
        createdAt: now,
      );

      await goalPostponementDao.insert(entry);
      await goalPostponementDao.deleteById('test-post-3');

      final found = await goalPostponementDao.findById('test-post-3');
      expect(found, isNull);
    });

    test('should delete all goal postponements by goal id', () async {
      final now = DateTime.now();
      await goalPostponementDao.insert(GoalPostponementsCompanion.insert(
        id: 'test-post-4',
        goalId: 'test-goal-2',
        reason: const Value('Reason 1'),
        createdAt: now,
      ));
      await goalPostponementDao.insert(GoalPostponementsCompanion.insert(
        id: 'test-post-5',
        goalId: 'test-goal-2',
        reason: const Value('Reason 2'),
        createdAt: now,
      ));
      await goalPostponementDao.insert(GoalPostponementsCompanion.insert(
        id: 'test-post-6',
        goalId: 'test-goal-3',
        reason: const Value('Reason 3'),
        createdAt: now,
      ));

      await goalPostponementDao.deleteByGoalId('test-goal-2');

      final posts1 = await goalPostponementDao.listByGoalId('test-goal-2');
      final posts2 = await goalPostponementDao.listByGoalId('test-goal-3');

      expect(posts1.length, equals(0));
      expect(posts2.length, equals(1));
    });
  });

  group('GoalPostponementDao Query Operations', () {
    test('should list goal postponements by goal id in order', () async {
      final now = DateTime.now();
      await goalPostponementDao.insert(GoalPostponementsCompanion.insert(
        id: 'test-post-7',
        goalId: 'test-goal-4',
        reason: const Value('Reason 1'),
        createdAt: now.subtract(const Duration(days: 1)),
      ));
      await goalPostponementDao.insert(GoalPostponementsCompanion.insert(
        id: 'test-post-8',
        goalId: 'test-goal-4',
        reason: const Value('Reason 2'),
        createdAt: now,
      ));

      final posts = await goalPostponementDao.listByGoalId('test-goal-4');
      expect(posts.length, equals(2));
      expect(posts[0].createdAt.isAfter(posts[1].createdAt), isTrue);
    });
  });

  group('GoalPostponementDao Watch Operations', () {
    test('should watch goal postponements by goal id', () async {
      final now = DateTime.now();
      await goalPostponementDao.insert(GoalPostponementsCompanion.insert(
        id: 'watch-post-1',
        goalId: 'watch-goal-1',
        reason: const Value('Watch reason'),
        createdAt: now,
      ));

      final posts = await goalPostponementDao.watchByGoalId('watch-goal-1').first;
      expect(posts.length, equals(1));
      expect(posts[0].reason, equals('Watch reason'));
    });
  });
}
