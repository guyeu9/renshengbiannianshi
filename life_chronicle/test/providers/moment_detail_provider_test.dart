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
  });
}
