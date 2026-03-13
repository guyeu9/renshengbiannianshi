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
      
      // 创建朋友记录
      final friendId = 'test-friend-lastmeet-1';
      await friendDao.create(
        id: friendId,
        name: 'Test Friend',
        createdAt: now,
        now: now,
      );

      // 确认初始 lastMeetDate 为 null
      var friend = await friendDao.getById(friendId);
      expect(friend?.lastMeetDate, isNull);

      // 创建美食记录
      final foodId = 'test-food-lastmeet-1';
      await foodDao.create(
        id: foodId,
        name: 'Test Food',
        createdAt: now,
        now: now,
      );

      // 关联美食和朋友
      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'friend',
        targetId: friendId,
        now: now,
      );

      // 验证朋友的 lastMeetDate 已更新
      friend = await friendDao.getById(friendId);
      expect(friend?.lastMeetDate, isNotNull);
    });

    test('should recalculate friend lastMeetDate when deleting link', () async {
      final now = DateTime.now();
      
      // 创建朋友记录
      final friendId = 'test-friend-lastmeet-2';
      await friendDao.create(
        id: friendId,
        name: 'Test Friend 2',
        createdAt: now,
        now: now,
      );

      // 创建两个美食记录
      final foodId1 = 'test-food-lastmeet-2a';
      final foodId2 = 'test-food-lastmeet-2b';
      await foodDao.create(
        id: foodId1,
        name: 'Test Food 2a',
        createdAt: now,
        now: now,
      );
      await foodDao.create(
        id: foodId2,
        name: 'Test Food 2b',
        createdAt: now,
        now: now,
      );

      // 创建第一个关联（设置初始 lastMeetDate）
      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId1,
        targetType: 'friend',
        targetId: friendId,
        now: now,
      );

      var friend = await friendDao.getById(friendId);
      final initialLastMeet = friend?.lastMeetDate;

      // 等待一小段时间确保时间差异
      await Future.delayed(const Duration(milliseconds: 10));
      final laterNow = DateTime.now();

      // 创建第二个关联（更新 lastMeetDate）
      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId2,
        targetType: 'friend',
        targetId: friendId,
        now: laterNow,
      );

      friend = await friendDao.getById(friendId);
      expect(friend?.lastMeetDate?.isAfter(initialLastMeet!), isTrue);

      // 删除第一个关联
      await linkDao.deleteLink(
        sourceType: 'food',
        sourceId: foodId1,
        targetType: 'friend',
        targetId: friendId,
        now: laterNow,
      );

      // 验证 lastMeetDate 重新计算为第二个关联的时间
      friend = await friendDao.getById(friendId);
      expect(friend?.lastMeetDate, equals(friend?.lastMeetDate));
    });
  });

  group('LinkDao Goal Progress Integration', () {
    test('should sync goal progress when creating link', () async {
      final now = DateTime.now();
      
      // 创建目标记录
      final goalId = 'test-goal-progress-1';
      await goalDao.create(
        id: goalId,
        title: 'Test Goal',
        createdAt: now,
        now: now,
      );

      // 获取初始进度
      var goal = await goalDao.getById(goalId);
      final initialProgress = goal?.progress ?? 0.0;

      // 创建美食记录
      final foodId = 'test-food-goal-1';
      await foodDao.create(
        id: foodId,
        name: 'Test Food for Goal',
        createdAt: now,
        now: now,
      );

      // 关联美食和目标
      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'goal',
        targetId: goalId,
        now: now,
      );

      // 验证目标进度已更新
      goal = await goalDao.getById(goalId);
      expect(goal?.progress, greaterThan(initialProgress));
    });

    test('should recalculate goal progress when deleting link', () async {
      final now = DateTime.now();
      
      // 创建目标记录
      final goalId = 'test-goal-progress-2';
      await goalDao.create(
        id: goalId,
        title: 'Test Goal 2',
        createdAt: now,
        now: now,
      );

      // 创建美食记录
      final foodId1 = 'test-food-goal-2a';
      final foodId2 = 'test-food-goal-2b';
      await foodDao.create(
        id: foodId1,
        name: 'Test Food 2a',
        createdAt: now,
        now: now,
      );
      await foodDao.create(
        id: foodId2,
        name: 'Test Food 2b',
        createdAt: now,
        now: now,
      );

      // 创建两个关联
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

      var goal = await goalDao.getById(goalId);
      final progressWithTwo = goal?.progress ?? 0.0;

      // 删除一个关联
      await linkDao.deleteLink(
        sourceType: 'food',
        sourceId: foodId1,
        targetType: 'goal',
        targetId: goalId,
        now: now,
      );

      // 验证进度重新计算
      goal = await goalDao.getById(goalId);
      expect(goal?.progress, lessThan(progressWithTwo));
    });
  });

  group('LinkDao collectAffectedEntities', () {
    test('should collect affected friends when deleting entity', () async {
      final now = DateTime.now();
      
      // 创建朋友记录
      final friendId1 = 'test-friend-collect-1';
      final friendId2 = 'test-friend-collect-2';
      await friendDao.create(
        id: friendId1,
        name: 'Test Friend 1',
        createdAt: now,
        now: now,
      );
      await friendDao.create(
        id: friendId2,
        name: 'Test Friend 2',
        createdAt: now,
        now: now,
      );

      // 创建美食记录
      final foodId = 'test-food-collect-1';
      await foodDao.create(
        id: foodId,
        name: 'Test Food',
        createdAt: now,
        now: now,
      );

      // 关联美食到两个朋友
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

      // 收集受影响的实体
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
      
      // 创建目标记录
      final goalId1 = 'test-goal-collect-1';
      final goalId2 = 'test-goal-collect-2';
      await goalDao.create(
        id: goalId1,
        title: 'Test Goal 1',
        createdAt: now,
        now: now,
      );
      await goalDao.create(
        id: goalId2,
        title: 'Test Goal 2',
        createdAt: now,
        now: now,
      );

      // 创建美食记录
      final foodId = 'test-food-collect-goals';
      await foodDao.create(
        id: foodId,
        name: 'Test Food for Goals',
        createdAt: now,
        now: now,
      );

      // 关联美食到两个目标
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

      // 收集受影响的实体
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
      
      // 创建没有关联的美食记录
      final foodId = 'test-food-no-links';
      await foodDao.create(
        id: foodId,
        name: 'Test Food No Links',
        createdAt: now,
        now: now,
      );

      // 收集受影响的实体
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
      
      // 创建朋友和目标
      final friendId = 'test-friend-both-1';
      final goalId = 'test-goal-both-1';
      await friendDao.create(
        id: friendId,
        name: 'Test Friend Both',
        createdAt: now,
        now: now,
      );
      await goalDao.create(
        id: goalId,
        title: 'Test Goal Both',
        createdAt: now,
        now: now,
      );

      // 创建美食记录
      final foodId = 'test-food-both';
      await foodDao.create(
        id: foodId,
        name: 'Test Food Both',
        createdAt: now,
        now: now,
      );

      // 关联到朋友和目标
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

      // 收集受影响的实体
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
      
      // 创建朋友
      final friendId = 'test-friend-delete-source';
      await friendDao.create(
        id: friendId,
        name: 'Test Friend Delete Source',
        createdAt: now,
        now: now,
      );

      // 创建美食记录
      final foodId = 'test-food-delete-source';
      await foodDao.create(
        id: foodId,
        name: 'Test Food Delete Source',
        createdAt: now,
        now: now,
      );

      // 关联
      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'friend',
        targetId: friendId,
        now: now,
      );

      var friend = await friendDao.getById(friendId);
      expect(friend?.lastMeetDate, isNotNull);

      // 使用 deleteLinksBySource 删除
      await linkDao.deleteLinksBySource('food', foodId);

      // 验证 lastMeetDate 重新计算
      friend = await friendDao.getById(friendId);
      expect(friend?.lastMeetDate, isNull);
    });

    test('should sync goal progress after deleteLinksBySource', () async {
      final now = DateTime.now();
      
      // 创建目标
      final goalId = 'test-goal-delete-source';
      await goalDao.create(
        id: goalId,
        title: 'Test Goal Delete Source',
        createdAt: now,
        now: now,
      );

      // 创建美食记录
      final foodId = 'test-food-delete-source-goal';
      await foodDao.create(
        id: foodId,
        name: 'Test Food Delete Source Goal',
        createdAt: now,
        now: now,
      );

      // 关联
      await linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'goal',
        targetId: goalId,
        now: now,
      );

      var goal = await goalDao.getById(goalId);
      expect(goal?.progress, greaterThan(0));

      // 使用 deleteLinksBySource 删除
      await linkDao.deleteLinksBySource('food', foodId);

      // 验证进度重新计算
      goal = await goalDao.getById(goalId);
      expect(goal?.progress, equals(0));
    });
  });
}
