import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late LinkDao linkDao;
  late FriendDao friendDao;
  late FoodDao foodDao;
  late GoalDao goalDao;

  setUp(() async {
    db = createTestDatabase();
    linkDao = LinkDao(db);
    friendDao = FriendDao(db);
    foodDao = FoodDao(db);
    goalDao = GoalDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('LinkDao Basic Operations', () {
    test('should check if link exists', () async {
      expect(await linkDao.linkExists(
        sourceType: 'moment',
        sourceId: 'test-moment-1',
        targetType: 'food',
        targetId: 'test-food-1',
      ), isFalse);
    });

    test('should create a link and verify it exists', () async {
      final now = DateTime.now();
      
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-1',
        targetType: 'food',
        targetId: 'test-food-1',
        linkType: 'manual',
        now: now,
      );

      expect(await linkDao.linkExists(
        sourceType: 'moment',
        sourceId: 'test-moment-1',
        targetType: 'food',
        targetId: 'test-food-1',
      ), isTrue);
    });

    test('should delete a link and verify it does not exist', () async {
      final now = DateTime.now();
      
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-2',
        targetType: 'food',
        targetId: 'test-food-2',
        now: now,
      );

      await linkDao.deleteLink(
        sourceType: 'moment',
        sourceId: 'test-moment-2',
        targetType: 'food',
        targetId: 'test-food-2',
        now: now,
      );

      expect(await linkDao.linkExists(
        sourceType: 'moment',
        sourceId: 'test-moment-2',
        targetType: 'food',
        targetId: 'test-food-2',
      ), isFalse);
    });

    test('should delete links by source', () async {
      final now = DateTime.now();
      
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-3',
        targetType: 'food',
        targetId: 'test-food-3',
        now: now,
      );
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-3',
        targetType: 'travel',
        targetId: 'test-travel-3',
        now: now,
      );

      await linkDao.deleteLinksBySource('moment', 'test-moment-3');

      final links = await linkDao.listLinksForEntity(
        entityType: 'moment',
        entityId: 'test-moment-3',
      );
      expect(links.length, equals(0));
    });
  });

  group('LinkDao Query Operations', () {
    test('should list links for an entity', () async {
      final now = DateTime.now();
      
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-4',
        targetType: 'food',
        targetId: 'test-food-4',
        now: now,
      );

      final links = await linkDao.listLinksForEntity(
        entityType: 'moment',
        entityId: 'test-moment-4',
      );
      expect(links.length, equals(1));
      expect(links.first.targetType, equals('food'));
      expect(links.first.targetId, equals('test-food-4'));
    });

    test('should list links when entity is target', () async {
      final now = DateTime.now();
      
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-5',
        targetType: 'food',
        targetId: 'test-food-5',
        now: now,
      );

      final links = await linkDao.listLinksForEntity(
        entityType: 'food',
        entityId: 'test-food-5',
      );
      expect(links.length, equals(1));
      expect(links.first.sourceType, equals('moment'));
      expect(links.first.sourceId, equals('test-moment-5'));
    });
  });

  group('LinkDao Watch Operations', () {
    test('should watch links for an entity', () async {
      final now = DateTime.now();
      
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'watch-moment-1',
        targetType: 'food',
        targetId: 'watch-food-1',
        now: now,
      );

      final links = await linkDao.watchLinksForEntity(
        entityType: 'moment',
        entityId: 'watch-moment-1',
      ).first;
      expect(links.length, equals(1));
    });
  });

  group('LinkDao Idempotent Operations', () {
    test('should not create duplicate links', () async {
      final now = DateTime.now();
      
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-6',
        targetType: 'food',
        targetId: 'test-food-6',
        now: now,
      );
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-6',
        targetType: 'food',
        targetId: 'test-food-6',
        now: now,
      );

      final links = await linkDao.listLinksForEntity(
        entityType: 'moment',
        entityId: 'test-moment-6',
      );
      expect(links.length, equals(1));
    });
  });

  group('LinkDao Friend lastMeetDate Integration', () {
    test('should update friend lastMeetDate when creating link', () async {
      final now = DateTime.now();
      
      final friendId = 'test-friend-lastmeet-1';
      await friendDao.upsert(
        FriendRecordsCompanion.insert(
          id: friendId,
          name: 'Test Friend',
          createdAt: now,
          updatedAt: now,
        ),
      );

      var friend = await friendDao.findById(friendId);
      expect(friend?.lastMeetDate, isNull);

      final foodId = 'test-food-lastmeet-1';
      await foodDao.upsert(
        FoodRecordsCompanion.insert(
          id: foodId,
          title: 'Test Food',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'friend',
        targetId: friendId,
        now: now,
      );

      friend = await friendDao.findById(friendId);
      expect(friend?.lastMeetDate, isNotNull);
    });

    test('should recalculate friend lastMeetDate when deleting link', () async {
      final now = DateTime.now();
      
      final friendId = 'test-friend-lastmeet-2';
      await friendDao.upsert(
        FriendRecordsCompanion.insert(
          id: friendId,
          name: 'Test Friend 2',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final foodId1 = 'test-food-lastmeet-2a';
      final foodId2 = 'test-food-lastmeet-2b';
      
      final earlierDate = DateTime(now.year, now.month, now.day, now.hour - 1, now.minute, 0);
      final laterDate = DateTime(now.year, now.month, now.day, now.hour, now.minute, 0);
      
      await foodDao.upsert(
        FoodRecordsCompanion.insert(
          id: foodId1,
          title: 'Test Food 2a',
          recordDate: earlierDate,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await foodDao.upsert(
        FoodRecordsCompanion.insert(
          id: foodId2,
          title: 'Test Food 2b',
          recordDate: laterDate,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId1,
        targetType: 'friend',
        targetId: friendId,
        now: now,
      );

      var friend = await friendDao.findById(friendId);
      expect(friend?.lastMeetDate?.year, equals(earlierDate.year));
      expect(friend?.lastMeetDate?.month, equals(earlierDate.month));
      expect(friend?.lastMeetDate?.day, equals(earlierDate.day));
      expect(friend?.lastMeetDate?.hour, equals(earlierDate.hour));
      expect(friend?.lastMeetDate?.minute, equals(earlierDate.minute));

      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId2,
        targetType: 'friend',
        targetId: friendId,
        now: now,
      );

      friend = await friendDao.findById(friendId);
      expect(friend?.lastMeetDate?.year, equals(laterDate.year));
      expect(friend?.lastMeetDate?.month, equals(laterDate.month));
      expect(friend?.lastMeetDate?.day, equals(laterDate.day));
      expect(friend?.lastMeetDate?.hour, equals(laterDate.hour));
      expect(friend?.lastMeetDate?.minute, equals(laterDate.minute));

      await linkDao.deleteLink(
        sourceType: 'food',
        sourceId: foodId1,
        targetType: 'friend',
        targetId: friendId,
        now: now,
      );

      friend = await friendDao.findById(friendId);
      expect(friend?.lastMeetDate?.year, equals(laterDate.year));
      expect(friend?.lastMeetDate?.month, equals(laterDate.month));
      expect(friend?.lastMeetDate?.day, equals(laterDate.day));
      expect(friend?.lastMeetDate?.hour, equals(laterDate.hour));
      expect(friend?.lastMeetDate?.minute, equals(laterDate.minute));
    });
  });

  group('LinkDao Goal Progress Integration', () {
    test('should sync goal progress when creating link', () async {
      final now = DateTime.now();
      
      final goalId = 'test-goal-progress-1';
      await goalDao.upsert(
        GoalRecordsCompanion.insert(
          id: goalId,
          title: 'Test Goal',
          level: 'task',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      var goal = await goalDao.findById(goalId);
      final initialProgress = goal?.progress ?? 0.0;

      final foodId = 'test-food-goal-1';
      await foodDao.upsert(
        FoodRecordsCompanion.insert(
          id: foodId,
          title: 'Test Food for Goal',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'goal',
        targetId: goalId,
        now: now,
      );

      goal = await goalDao.findById(goalId);
      expect(goal?.progress, greaterThanOrEqualTo(initialProgress));
    });

    test('should recalculate goal progress when deleting link', () async {
      final now = DateTime.now();
      
      final goalId = 'test-goal-progress-2';
      await goalDao.upsert(
        GoalRecordsCompanion.insert(
          id: goalId,
          title: 'Test Goal 2',
          level: 'task',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final foodId1 = 'test-food-goal-2a';
      final foodId2 = 'test-food-goal-2b';
      await foodDao.upsert(
        FoodRecordsCompanion.insert(
          id: foodId1,
          title: 'Test Food 2a',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await foodDao.upsert(
        FoodRecordsCompanion.insert(
          id: foodId2,
          title: 'Test Food 2b',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId1,
        targetType: 'goal',
        targetId: goalId,
        now: now,
      );
      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId2,
        targetType: 'goal',
        targetId: goalId,
        now: now,
      );

      var goal = await goalDao.findById(goalId);
      final progressWithTwo = goal?.progress ?? 0.0;

      await linkDao.deleteLink(
        sourceType: 'food',
        sourceId: foodId1,
        targetType: 'goal',
        targetId: goalId,
        now: now,
      );

      goal = await goalDao.findById(goalId);
      expect(goal?.progress, lessThanOrEqualTo(progressWithTwo));
    });
  });

  group('LinkDao collectAffectedEntities', () {
    test('should collect affected friends when deleting entity', () async {
      final now = DateTime.now();
      
      final friendId1 = 'test-friend-collect-1';
      final friendId2 = 'test-friend-collect-2';
      await friendDao.upsert(
        FriendRecordsCompanion.insert(
          id: friendId1,
          name: 'Test Friend 1',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await friendDao.upsert(
        FriendRecordsCompanion.insert(
          id: friendId2,
          name: 'Test Friend 2',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final foodId = 'test-food-collect-1';
      await foodDao.upsert(
        FoodRecordsCompanion.insert(
          id: foodId,
          title: 'Test Food',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'friend',
        targetId: friendId1,
        now: now,
      );
      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'friend',
        targetId: friendId2,
        now: now,
      );

      final affected = await linkDao.collectAffectedEntities(
        entityType: 'food',
        entityId: foodId,
      );

      expect(affected.hasFriends, isTrue);
      expect(affected.friendIds.length, equals(2));
      expect(affected.friendIds, contains(friendId1));
      expect(affected.friendIds, contains(friendId2));
    });

    test('should collect affected goals when deleting entity', () async {
      final now = DateTime.now();
      
      final goalId1 = 'test-goal-collect-1';
      final goalId2 = 'test-goal-collect-2';
      await goalDao.upsert(
        GoalRecordsCompanion.insert(
          id: goalId1,
          title: 'Test Goal 1',
          level: 'task',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await goalDao.upsert(
        GoalRecordsCompanion.insert(
          id: goalId2,
          title: 'Test Goal 2',
          level: 'task',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final foodId = 'test-food-collect-goals';
      await foodDao.upsert(
        FoodRecordsCompanion.insert(
          id: foodId,
          title: 'Test Food for Goals',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'goal',
        targetId: goalId1,
        now: now,
      );
      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'goal',
        targetId: goalId2,
        now: now,
      );

      final affected = await linkDao.collectAffectedEntities(
        entityType: 'food',
        entityId: foodId,
      );

      expect(affected.hasGoals, isTrue);
      expect(affected.goalIds.length, equals(2));
      expect(affected.goalIds, contains(goalId1));
      expect(affected.goalIds, contains(goalId2));
    });

    test('should return empty when no affected entities', () async {
      final now = DateTime.now();
      
      final foodId = 'test-food-no-links';
      await foodDao.upsert(
        FoodRecordsCompanion.insert(
          id: foodId,
          title: 'Test Food No Links',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final affected = await linkDao.collectAffectedEntities(
        entityType: 'food',
        entityId: foodId,
      );

      expect(affected.isEmpty, isTrue);
      expect(affected.hasFriends, isFalse);
      expect(affected.hasGoals, isFalse);
    });

    test('should collect both friends and goals', () async {
      final now = DateTime.now();
      
      final friendId = 'test-friend-both-1';
      final goalId = 'test-goal-both-1';
      await friendDao.upsert(
        FriendRecordsCompanion.insert(
          id: friendId,
          name: 'Test Friend Both',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await goalDao.upsert(
        GoalRecordsCompanion.insert(
          id: goalId,
          title: 'Test Goal Both',
          level: 'task',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final foodId = 'test-food-both';
      await foodDao.upsert(
        FoodRecordsCompanion.insert(
          id: foodId,
          title: 'Test Food Both',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'friend',
        targetId: friendId,
        now: now,
      );
      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'goal',
        targetId: goalId,
        now: now,
      );

      final affected = await linkDao.collectAffectedEntities(
        entityType: 'food',
        entityId: foodId,
      );

      expect(affected.hasFriends, isTrue);
      expect(affected.hasGoals, isTrue);
      expect(affected.friendIds, contains(friendId));
      expect(affected.goalIds, contains(goalId));
    });
  });

  group('LinkDao deleteLinksBySource Integration', () {
    test('should recalculate friend lastMeetDate after deleteLinksBySource', () async {
      final now = DateTime.now();
      
      final friendId = 'test-friend-delete-source';
      await friendDao.upsert(
        FriendRecordsCompanion.insert(
          id: friendId,
          name: 'Test Friend Delete Source',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final foodId = 'test-food-delete-source';
      await foodDao.upsert(
        FoodRecordsCompanion.insert(
          id: foodId,
          title: 'Test Food Delete Source',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'friend',
        targetId: friendId,
        now: now,
      );

      var friend = await friendDao.findById(friendId);
      expect(friend?.lastMeetDate, isNotNull);

      await linkDao.deleteLinksBySource('food', foodId);

      friend = await friendDao.findById(friendId);
      expect(friend?.lastMeetDate, isNull);
    });

    test('should sync goal progress after deleteLinksBySource', () async {
      final now = DateTime.now();
      
      final goalId = 'test-goal-delete-source';
      await goalDao.upsert(
        GoalRecordsCompanion.insert(
          id: goalId,
          title: 'Test Goal Delete Source',
          level: 'task',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final foodId = 'test-food-delete-source-goal';
      await foodDao.upsert(
        FoodRecordsCompanion.insert(
          id: foodId,
          title: 'Test Food Delete Source Goal',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'goal',
        targetId: goalId,
        now: now,
      );

      var goal = await goalDao.findById(goalId);
      expect(goal?.progress, greaterThan(0));

      await linkDao.deleteLinksBySource('food', foodId);

      goal = await goalDao.findById(goalId);
      expect(goal?.progress, equals(0));
    });
  });

  group('LinkDao Bidirectional Link Collection', () {
    test('should collect links when entity is source', () async {
      final now = DateTime.now();
      
      final foodId = 'test-food-bidirectional-source';
      await foodDao.upsert(
        FoodRecordsCompanion.insert(
          id: foodId,
          title: 'Test Food Source',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final friendId = 'test-friend-bidirectional';
      await friendDao.upsert(
        FriendRecordsCompanion.insert(
          id: friendId,
          name: 'Test Friend',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'friend',
        targetId: friendId,
        now: now,
      );

      final affected = await linkDao.collectAffectedEntities(
        entityType: 'food',
        entityId: foodId,
      );

      expect(affected.hasFriends, isTrue);
      expect(affected.friendIds.first, equals(friendId));
    });

    test('should collect links when entity is target', () async {
      final now = DateTime.now();
      
      final foodId = 'test-food-bidirectional-target';
      await foodDao.upsert(
        FoodRecordsCompanion.insert(
          id: foodId,
          title: 'Test Food Target',
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final friendId = 'test-friend-bidirectional-2';
      await friendDao.upsert(
        FriendRecordsCompanion.insert(
          id: friendId,
          name: 'Test Friend 2',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await linkDao.createLink(
        sourceType: 'friend',
        sourceId: friendId,
        targetType: 'food',
        targetId: foodId,
        now: now,
      );

      final affected = await linkDao.collectAffectedEntities(
        entityType: 'food',
        entityId: foodId,
      );

      expect(affected.hasFriends, isTrue);
      expect(affected.friendIds.first, equals(friendId));
    });
  });

  group('AffectedEntities Class', () {
    test('should correctly report empty state', () {
      final affected = AffectedEntities(friendIds: [], goalIds: []);
      expect(affected.isEmpty, isTrue);
      expect(affected.isNotEmpty, isFalse);
      expect(affected.hasFriends, isFalse);
      expect(affected.hasGoals, isFalse);
    });

    test('should correctly report non-empty state', () {
      final affected = AffectedEntities(
        friendIds: ['friend-1'],
        goalIds: ['goal-1'],
      );
      expect(affected.isEmpty, isFalse);
      expect(affected.isNotEmpty, isTrue);
      expect(affected.hasFriends, isTrue);
      expect(affected.hasGoals, isTrue);
    });

    test('should correctly report partial state', () {
      final affectedWithFriends = AffectedEntities(
        friendIds: ['friend-1'],
        goalIds: [],
      );
      expect(affectedWithFriends.isEmpty, isFalse);
      expect(affectedWithFriends.hasFriends, isTrue);
      expect(affectedWithFriends.hasGoals, isFalse);

      final affectedWithGoals = AffectedEntities(
        friendIds: [],
        goalIds: ['goal-1'],
      );
      expect(affectedWithGoals.isEmpty, isFalse);
      expect(affectedWithGoals.hasFriends, isFalse);
      expect(affectedWithGoals.hasGoals, isTrue);
    });
  });
}
