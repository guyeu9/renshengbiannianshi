import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/features/bond/providers/encounter_timeline_provider.dart';

void main() {
  group('EncounterTimelineState', () {
    late EncounterTimelineState state;
    late List<TimelineEvent> testEncounters;
    late List<FoodRecord> testFoods;
    late List<MomentRecord> testMoments;
    late List<TravelRecord> testTravels;
    late Map<String, List<String>> testFriendLinks;

    setUp(() {
      final now = DateTime.now();

      testEncounters = [
        TimelineEvent(
          id: 'encounter-1',
          title: '第一次见面',
          eventType: 'encounter',
          note: '今天第一次认识了张三',
          recordDate: now,
          isFavorite: false,
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
        ),
        TimelineEvent(
          id: 'encounter-2',
          title: '再次相遇',
          eventType: 'encounter',
          note: '在咖啡馆又遇到了张三',
          recordDate: now.add(const Duration(days: 7)),
          isFavorite: true,
          isDeleted: false,
          createdAt: now.add(const Duration(days: 7)),
          updatedAt: now.add(const Duration(days: 7)),
        ),
      ];

      testFoods = [
        FoodRecord(
          id: 'food-1',
          title: '火锅店聚餐',
          isDeleted: false,
          isFavorite: true,
          isWishlist: false,
          wishlistDone: false,
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testMoments = [
        MomentRecord(
          id: 'moment-1',
          mood: '开心',
          content: '今天很快乐',
          isDeleted: false,
          isFavorite: false,
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testTravels = [
        TravelRecord(
          id: 'travel-1',
          tripId: 'trip-1',
          title: '一起旅行',
          isDeleted: false,
          isFavorite: true,
          isWishlist: false,
          wishlistDone: false,
          isJournal: false,
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testFriendLinks = {
        'encounter-1': ['friend-1', 'friend-2'],
        'food-1': ['friend-1'],
        'moment-1': ['friend-2'],
        'travel-1': ['friend-1', 'friend-2', 'friend-3'],
      };

      state = EncounterTimelineState(
        encounters: testEncounters,
        foods: testFoods,
        moments: testMoments,
        travels: testTravels,
        friendLinks: testFriendLinks,
      );
    });

    test('empty() should create empty state', () {
      final emptyState = EncounterTimelineState.empty();

      expect(emptyState.encounters, isEmpty);
      expect(emptyState.foods, isEmpty);
      expect(emptyState.moments, isEmpty);
      expect(emptyState.travels, isEmpty);
      expect(emptyState.friendLinks, isEmpty);
    });

    test('should retain all provided data', () {
      expect(state.encounters, equals(testEncounters));
      expect(state.foods, equals(testFoods));
      expect(state.moments, equals(testMoments));
      expect(state.travels, equals(testTravels));
      expect(state.friendLinks, equals(testFriendLinks));
    });

    test('should have correct number of encounters', () {
      expect(state.encounters.length, equals(2));
    });

    test('should have correct encounter data', () {
      expect(state.encounters[0].id, equals('encounter-1'));
      expect(state.encounters[0].title, equals('第一次见面'));
      expect(state.encounters[1].id, equals('encounter-2'));
      expect(state.encounters[1].title, equals('再次相遇'));
    });

    test('should have friend links for encounter-1', () {
      expect(state.friendLinks['encounter-1'], isNotNull);
      expect(state.friendLinks['encounter-1']!.length, equals(2));
      expect(state.friendLinks['encounter-1'], contains('friend-1'));
      expect(state.friendLinks['encounter-1'], contains('friend-2'));
    });

    test('should have friend links for travel-1', () {
      expect(state.friendLinks['travel-1'], isNotNull);
      expect(state.friendLinks['travel-1']!.length, equals(3));
      expect(state.friendLinks['travel-1'], contains('friend-1'));
      expect(state.friendLinks['travel-1'], contains('friend-2'));
      expect(state.friendLinks['travel-1'], contains('friend-3'));
    });

    test('should return empty friend links for non-existent event', () {
      expect(state.friendLinks['non-existent-id'], isNull);
    });

    test('should have correct food record', () {
      expect(state.foods.length, equals(1));
      expect(state.foods[0].id, equals('food-1'));
      expect(state.foods[0].title, equals('火锅店聚餐'));
      expect(state.foods[0].isFavorite, isTrue);
    });

    test('should have correct moment record', () {
      expect(state.moments.length, equals(1));
      expect(state.moments[0].id, equals('moment-1'));
      expect(state.moments[0].mood, equals('开心'));
    });

    test('should have correct travel record', () {
      expect(state.travels.length, equals(1));
      expect(state.travels[0].id, equals('travel-1'));
      expect(state.travels[0].title, equals('一起旅行'));
    });
  });
}
