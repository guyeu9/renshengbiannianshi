import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/features/moment/providers/moment_detail_provider.dart';

void main() {
  group('MomentDetailState', () {
    late MomentDetailState state;
    late MomentRecord testRecord;
    late List<EntityLink> testLinks;
    late List<FriendRecord> testFriends;
    late List<FoodRecord> testFoods;
    late List<TravelRecord> testTravels;
    late List<GoalRecord> testGoals;

    setUp(() {
      final now = DateTime.now();
      
      testRecord = MomentRecord(
        id: 'moment-1',
        mood: '开心',
        content: 'Test content',
        isDeleted: false,
        isFavorite: false,
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      );

      testLinks = [
        EntityLink(
          id: 'link-1',
          sourceType: 'moment',
          sourceId: 'moment-1',
          targetType: 'friend',
          targetId: 'friend-1',
          linkType: 'manual',
          createdAt: now,
        ),
        EntityLink(
          id: 'link-2',
          sourceType: 'moment',
          sourceId: 'moment-1',
          targetType: 'food',
          targetId: 'food-1',
          linkType: 'manual',
          createdAt: now,
        ),
        EntityLink(
          id: 'link-3',
          sourceType: 'travel',
          sourceId: 'travel-1',
          targetType: 'moment',
          targetId: 'moment-1',
          linkType: 'manual',
          createdAt: now,
        ),
        EntityLink(
          id: 'link-4',
          sourceType: 'moment',
          sourceId: 'moment-1',
          targetType: 'goal',
          targetId: 'goal-1',
          linkType: 'manual',
          createdAt: now,
        ),
      ];

      testFriends = [
        FriendRecord(
          id: 'friend-1',
          name: '张三',
          isDeleted: false,
          isFavorite: false,
          createdAt: now,
          updatedAt: now,
        ),
        FriendRecord(
          id: 'friend-2',
          name: '李四',
          isDeleted: false,
          isFavorite: false,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testFoods = [
        FoodRecord(
          id: 'food-1',
          title: '海底捞',
          isDeleted: false,
          isFavorite: false,
          isWishlist: false,
          wishlistDone: false,
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testTravels = [
        TravelRecord(
          id: 'travel-1',
          tripId: 'trip-1',
          title: '成都之旅',
          isDeleted: false,
          isFavorite: false,
          isWishlist: false,
          wishlistDone: false,
          isJournal: false,
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testGoals = [
        GoalRecord(
          id: 'goal-1',
          title: '学习 Flutter',
          level: 'yearly',
          isDeleted: false,
          isFavorite: false,
          isCompleted: false,
          isPostponed: false,
          progress: 0.0,
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      state = MomentDetailState(
        record: testRecord,
        links: testLinks,
        friends: testFriends,
        foods: testFoods,
        travels: testTravels,
        goals: testGoals,
      );
    });

    group('groupedLinkIds', () {
      test('should group link ids by entity type', () {
        final grouped = state.groupedLinkIds;
        
        expect(grouped['friend'], isNotNull);
        expect(grouped['friend'], contains('friend-1'));
        
        expect(grouped['food'], isNotNull);
        expect(grouped['food'], contains('food-1'));
        
        expect(grouped['travel'], isNotNull);
        expect(grouped['travel'], contains('travel-1'));
        
        expect(grouped['goal'], isNotNull);
        expect(grouped['goal'], contains('goal-1'));
      });

      test('should handle empty links', () {
        final emptyState = MomentDetailState(
          record: testRecord,
          links: [],
          friends: testFriends,
          foods: testFoods,
          travels: testTravels,
          goals: testGoals,
        );
        
        expect(emptyState.groupedLinkIds, isEmpty);
      });
    });

    group('friendNames', () {
      test('should return friend names for linked friends', () {
        final names = state.friendNames;
        
        expect(names, contains('张三'));
        expect(names, isNot(contains('李四')));
      });

      test('should return empty list when no friends linked', () {
        final noLinkState = MomentDetailState(
          record: testRecord,
          links: [],
          friends: testFriends,
          foods: testFoods,
          travels: testTravels,
          goals: testGoals,
        );
        
        expect(noLinkState.friendNames, isEmpty);
      });

      test('should handle missing friend data', () {
        final missingFriendState = MomentDetailState(
          record: testRecord,
          links: testLinks,
          friends: [],
          foods: testFoods,
          travels: testTravels,
          goals: testGoals,
        );
        
        expect(missingFriendState.friendNames, isEmpty);
      });
    });

    group('foodTitles', () {
      test('should return food titles for linked foods', () {
        final titles = state.foodTitles;
        
        expect(titles, contains('海底捞'));
      });

      test('should return empty list when no foods linked', () {
        final noLinkState = MomentDetailState(
          record: testRecord,
          links: [],
          friends: testFriends,
          foods: testFoods,
          travels: testTravels,
          goals: testGoals,
        );
        
        expect(noLinkState.foodTitles, isEmpty);
      });
    });

    group('travelTitles', () {
      test('should return travel titles for linked travels', () {
        final titles = state.travelTitles;
        
        expect(titles, contains('成都之旅'));
      });

      test('should return empty list when no travels linked', () {
        final noLinkState = MomentDetailState(
          record: testRecord,
          links: [],
          friends: testFriends,
          foods: testFoods,
          travels: testTravels,
          goals: testGoals,
        );
        
        expect(noLinkState.travelTitles, isEmpty);
      });
    });

    group('goalTitles', () {
      test('should return goal titles for linked goals', () {
        final titles = state.goalTitles;

        expect(titles, contains('学习 Flutter'));
      });

      test('should return empty list when no goals linked', () {
        final noLinkState = MomentDetailState(
          record: testRecord,
          links: [],
          friends: testFriends,
          foods: testFoods,
          travels: testTravels,
          goals: testGoals,
        );

        expect(noLinkState.goalTitles, isEmpty);
      });
    });

    // === 修复点 C1: linkedXxx 对象列表 getter 测试 ===

    group('linkedFriends', () {
      test('should return FriendRecord objects for linked friends', () {
        final linked = state.linkedFriends;

        expect(linked.length, equals(1));
        expect(linked.first.id, equals('friend-1'));
        expect(linked.first.name, equals('张三'));
      });

      test('should not include unlinked friends', () {
        final linked = state.linkedFriends;

        expect(linked.any((f) => f.id == 'friend-2'), isFalse);
      });

      test('should return empty list when no friends linked', () {
        final noLinkState = MomentDetailState(
          record: testRecord,
          links: [],
          friends: testFriends,
          foods: testFoods,
          travels: testTravels,
          goals: testGoals,
        );

        expect(noLinkState.linkedFriends, isEmpty);
      });

      test('should return empty list when friend data is missing', () {
        final missingFriendState = MomentDetailState(
          record: testRecord,
          links: testLinks,
          friends: [],
          foods: testFoods,
          travels: testTravels,
          goals: testGoals,
        );

        expect(missingFriendState.linkedFriends, isEmpty);
      });
    });

    group('linkedFoods', () {
      test('should return FoodRecord objects for linked foods', () {
        final linked = state.linkedFoods;

        expect(linked.length, equals(1));
        expect(linked.first.id, equals('food-1'));
        expect(linked.first.title, equals('海底捞'));
      });

      test('should return empty list when no foods linked', () {
        final noLinkState = MomentDetailState(
          record: testRecord,
          links: [],
          friends: testFriends,
          foods: testFoods,
          travels: testTravels,
          goals: testGoals,
        );

        expect(noLinkState.linkedFoods, isEmpty);
      });

      test('should return empty list when food data is missing', () {
        final missingFoodState = MomentDetailState(
          record: testRecord,
          links: testLinks,
          friends: testFriends,
          foods: [],
          travels: testTravels,
          goals: testGoals,
        );

        expect(missingFoodState.linkedFoods, isEmpty);
      });
    });

    group('linkedTravels', () {
      test('should return TravelRecord objects for linked travels', () {
        final linked = state.linkedTravels;

        expect(linked.length, equals(1));
        expect(linked.first.id, equals('travel-1'));
        expect(linked.first.title, equals('成都之旅'));
      });

      test('should return empty list when no travels linked', () {
        final noLinkState = MomentDetailState(
          record: testRecord,
          links: [],
          friends: testFriends,
          foods: testFoods,
          travels: testTravels,
          goals: testGoals,
        );

        expect(noLinkState.linkedTravels, isEmpty);
      });

      test('should return empty list when travel data is missing', () {
        final missingTravelState = MomentDetailState(
          record: testRecord,
          links: testLinks,
          friends: testFriends,
          foods: testFoods,
          travels: [],
          goals: testGoals,
        );

        expect(missingTravelState.linkedTravels, isEmpty);
      });
    });

    group('linkedGoals', () {
      test('should return GoalRecord objects for linked goals', () {
        final linked = state.linkedGoals;

        expect(linked.length, equals(1));
        expect(linked.first.id, equals('goal-1'));
        expect(linked.first.title, equals('学习 Flutter'));
      });

      test('should return empty list when no goals linked', () {
        final noLinkState = MomentDetailState(
          record: testRecord,
          links: [],
          friends: testFriends,
          foods: testFoods,
          travels: testTravels,
          goals: testGoals,
        );

        expect(noLinkState.linkedGoals, isEmpty);
      });

      test('should return empty list when goal data is missing', () {
        final missingGoalState = MomentDetailState(
          record: testRecord,
          links: testLinks,
          friends: testFriends,
          foods: testFoods,
          travels: testTravels,
          goals: [],
        );

        expect(missingGoalState.linkedGoals, isEmpty);
      });
    });
  });
}
