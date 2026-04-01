import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/features/travel/providers/travel_detail_provider.dart';

void main() {
  group('TravelDetailState', () {
    late TravelDetailState state;
    late TravelRecord testRecord;
    late Trip testTrip;
    late List<TravelRecord> testJournals;
    late List<ChecklistItem> testChecklistItems;
    late List<FriendRecord> testLinkedFriends;
    late List<FoodRecord> testLinkedFoods;
    late List<EntityLink> testEntityLinks;
    late Set<String> testAllTravelIds;

    setUp(() {
      final now = DateTime.now();
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);

      testRecord = TravelRecord(
        id: 'travel-1',
        tripId: 'trip-1',
        title: '成都之旅',
        destination: '成都',
        poiName: '春熙路',
        poiAddress: '四川省成都市锦江区春熙路',
        isDeleted: false,
        isFavorite: true,
        isWishlist: false,
        wishlistDone: false,
        isJournal: false,
        planDate: startDate,
        recordDate: startDate,
        tags: jsonEncode(['美食', '旅行', '放松']),
        images: jsonEncode(['image1.jpg', 'image2.jpg']),
        createdAt: now,
        updatedAt: now,
      );

      testTrip = Trip(
        id: 'trip-1',
        name: '成都 7 日游',
        startDate: startDate,
        endDate: endDate,
        createdAt: now,
        updatedAt: now,
      );

      testJournals = [
        TravelRecord(
          id: 'journal-1',
          tripId: 'trip-1',
          title: '第一天：到达成都',
          isDeleted: false,
          isFavorite: false,
          isWishlist: false,
          wishlistDone: false,
          isJournal: true,
          recordDate: startDate,
          createdAt: now,
          updatedAt: now,
        ),
        TravelRecord(
          id: 'journal-2',
          tripId: 'trip-1',
          title: '第二天：逛春熙路',
          isDeleted: false,
          isFavorite: true,
          isWishlist: false,
          wishlistDone: false,
          isJournal: true,
          recordDate: startDate.add(const Duration(days: 1)),
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testChecklistItems = [
        ChecklistItem(
          id: 'checklist-1',
          tripId: 'trip-1',
          title: '订机票',
          isDone: true,
          orderIndex: 0,
          createdAt: now,
          updatedAt: now,
        ),
        ChecklistItem(
          id: 'checklist-2',
          tripId: 'trip-1',
          title: '订酒店',
          isDone: false,
          orderIndex: 1,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testLinkedFriends = [
        FriendRecord(
          id: 'friend-1',
          name: '张三',
          isDeleted: false,
          isFavorite: true,
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

      testLinkedFoods = [
        FoodRecord(
          id: 'food-1',
          title: '火锅',
          isDeleted: false,
          isFavorite: true,
          isWishlist: false,
          wishlistDone: false,
          recordDate: startDate,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testEntityLinks = [
        EntityLink(
          id: 'link-1',
          sourceType: 'travel',
          sourceId: 'journal-1',
          targetType: 'friend',
          targetId: 'friend-1',
          linkType: 'association',
          createdAt: now,
        ),
        EntityLink(
          id: 'link-2',
          sourceType: 'food',
          sourceId: 'food-1',
          targetType: 'travel',
          targetId: 'journal-2',
          linkType: 'association',
          createdAt: now,
        ),
      ];

      testAllTravelIds = {'travel-1', 'journal-1', 'journal-2'};

      state = TravelDetailState(
        record: testRecord,
        trip: testTrip,
        journals: testJournals,
        checklistItems: testChecklistItems,
        linkedFriends: testLinkedFriends,
        linkedFoods: testLinkedFoods,
        entityLinks: testEntityLinks,
        allTravelIds: testAllTravelIds,
      );
    });

    test('should have all properties set correctly', () {
      expect(state.record, equals(testRecord));
      expect(state.trip, equals(testTrip));
      expect(state.journals, equals(testJournals));
      expect(state.checklistItems, equals(testChecklistItems));
      expect(state.linkedFriends, equals(testLinkedFriends));
      expect(state.linkedFoods, equals(testLinkedFoods));
      expect(state.entityLinks, equals(testEntityLinks));
      expect(state.allTravelIds, equals(testAllTravelIds));
    });

    group('title getter', () {
      test('should return record title when record exists', () {
        expect(state.title, equals('成都之旅'));
      });

      test('should return trip name when record is null', () {
        final noRecordState = TravelDetailState(
          record: null,
          trip: testTrip,
          journals: testJournals,
          checklistItems: testChecklistItems,
          linkedFriends: testLinkedFriends,
          linkedFoods: testLinkedFoods,
          entityLinks: testEntityLinks,
          allTravelIds: testAllTravelIds,
        );
        expect(noRecordState.title, equals('成都 7 日游'));
      });

      test('should return empty string when both record and trip are null', () {
        final emptyState = TravelDetailState(
          record: null,
          trip: null,
          journals: const [],
          checklistItems: const [],
          linkedFriends: const [],
          linkedFoods: const [],
          entityLinks: const [],
          allTravelIds: const {},
        );
        expect(emptyState.title, equals(''));
      });
    });

    group('place getter', () {
      test('should return destination when available', () {
        expect(state.place, equals('成都'));
      });

      test('should return empty string when record is null', () {
        final noRecordState = TravelDetailState(
          record: null,
          trip: testTrip,
          journals: testJournals,
          checklistItems: testChecklistItems,
          linkedFriends: testLinkedFriends,
          linkedFoods: testLinkedFoods,
          entityLinks: testEntityLinks,
          allTravelIds: testAllTravelIds,
        );
        expect(noRecordState.place, equals(''));
      });
    });

    group('duration calculations', () {
      test('should calculate correct duration days', () {
        expect(state.durationDays, equals(7));
      });

      test('should return 1 day when start and end are same', () {
        final sameDayTrip = Trip(
          id: 'trip-same',
          name: '单日游',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 1),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final sameDayState = TravelDetailState(
          record: testRecord,
          trip: sameDayTrip,
          journals: testJournals,
          checklistItems: testChecklistItems,
          linkedFriends: testLinkedFriends,
          linkedFoods: testLinkedFoods,
          entityLinks: testEntityLinks,
          allTravelIds: testAllTravelIds,
        );
        expect(sameDayState.durationDays, equals(1));
      });

      test('should format duration label correctly', () {
        expect(state.durationLabel, equals('7 天'));
      });

      test('should format date range correctly', () {
        expect(state.dateLabel, equals('1.1 - 1.7'));
      });
    });

    group('cover image', () {
      test('should return first image from record', () {
        expect(state.cover, equals('image1.jpg'));
      });

      test('should fallback to journal image when record has no image', () {
        final noCoverRecord = testRecord.copyWith(images: const Value(null));
        final journalsWithImage = [
          testJournals.first.copyWith(images: Value(jsonEncode(['journal-cover.jpg']))),
          testJournals.last,
        ];
        final fallbackState = TravelDetailState(
          record: noCoverRecord,
          trip: testTrip,
          journals: journalsWithImage,
          checklistItems: testChecklistItems,
          linkedFriends: testLinkedFriends,
          linkedFoods: testLinkedFoods,
          entityLinks: testEntityLinks,
          allTravelIds: testAllTravelIds,
        );
        expect(fallbackState.cover, equals('journal-cover.jpg'));
      });

      test('should return empty string when record is null', () {
        final noRecordState = TravelDetailState(
          record: null,
          trip: testTrip,
          journals: testJournals,
          checklistItems: testChecklistItems,
          linkedFriends: testLinkedFriends,
          linkedFoods: testLinkedFoods,
          entityLinks: testEntityLinks,
          allTravelIds: testAllTravelIds,
        );
        expect(noRecordState.cover, equals(''));
      });

      test('should parse history cover image from comma separated string', () {
        final historyRecord = testRecord.copyWith(images: Value('old1.jpg, old2.jpg'));
        final historyState = TravelDetailState(
          record: historyRecord,
          trip: testTrip,
          journals: testJournals,
          checklistItems: testChecklistItems,
          linkedFriends: testLinkedFriends,
          linkedFoods: testLinkedFoods,
          entityLinks: testEntityLinks,
          allTravelIds: testAllTravelIds,
        );
        expect(historyState.cover, equals('old1.jpg'));
      });

    test('should calculate duration days by natural date boundary', () {
      final timedTrip = Trip(
        id: 'trip-timed',
        name: '跨午夜旅行',
        startDate: DateTime(2024, 1, 1, 23, 30),
        endDate: DateTime(2024, 1, 2, 0, 30),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final timedState = TravelDetailState(
        record: testRecord,
        trip: timedTrip,
        journals: testJournals,
        checklistItems: testChecklistItems,
        linkedFriends: testLinkedFriends,
        linkedFoods: testLinkedFoods,
        entityLinks: testEntityLinks,
        allTravelIds: testAllTravelIds,
      );
      expect(timedState.durationDays, equals(2));
    });
    });

    group('tags', () {
      test('should parse and sort tags correctly with destination', () {
        expect(state.tags, equals(['成都', '放松', '旅行', '美食']));
      });
    });

    group('flags', () {
      test('should have correct isJournal flag', () {
        expect(state.isJournal, isFalse);
      });

      test('should have correct isWishlist flag', () {
        expect(state.isWishlist, isFalse);
      });

      test('should have correct wishlistDone flag', () {
        expect(state.wishlistDone, isFalse);
      });
    });

    group('other getters', () {
      test('should return correct tripId', () {
        expect(state.tripId, equals('trip-1'));
      });

      test('should return correct tripTitle', () {
        expect(state.tripTitle, equals('成都 7 日游'));
      });

      test('should return correct recordId', () {
        expect(state.recordId, equals('travel-1'));
      });

      test('should return empty recordId when record is null', () {
        final noRecordState = TravelDetailState(
          record: null,
          trip: testTrip,
          journals: testJournals,
          checklistItems: testChecklistItems,
          linkedFriends: testLinkedFriends,
          linkedFoods: testLinkedFoods,
          entityLinks: testEntityLinks,
          allTravelIds: testAllTravelIds,
        );
        expect(noRecordState.recordId, equals(''));
      });

      test('should expose entity links for timeline rendering', () {
        expect(state.entityLinks, hasLength(2));
        expect(state.entityLinks.map((link) => link.id), containsAll(['link-1', 'link-2']));
      });
    });
  });

  group('JournalDetailState', () {
    late JournalDetailState state;
    late TravelRecord testJournal;
    late Trip testTrip;
    late List<FriendRecord> testLinkedFriends;
    late List<FoodRecord> testLinkedFoods;
    late List<GoalRecord> testLinkedGoals;
    late List<TravelRecord> testLinkedTravels;

    setUp(() {
      final now = DateTime.now();

      testJournal = TravelRecord(
        id: 'journal-1',
        tripId: 'trip-1',
        title: '游记：成都第一天',
        poiName: '锦里古街',
        poiAddress: '四川省成都市武侯区锦里古街',
        isDeleted: false,
        isFavorite: true,
        isWishlist: false,
        wishlistDone: false,
        isJournal: true,
        recordDate: now,
        tags: jsonEncode(['古街', '文化']),
        images: jsonEncode(['journal1.jpg', 'journal2.jpg']),
        createdAt: now,
        updatedAt: now,
      );

      testTrip = Trip(
        id: 'trip-1',
        name: '成都之旅',
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        createdAt: now,
        updatedAt: now,
      );

      testLinkedFriends = [
        FriendRecord(
          id: 'friend-1',
          name: '张三',
          isDeleted: false,
          isFavorite: true,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testLinkedFoods = [
        FoodRecord(
          id: 'food-1',
          title: '串串香',
          isDeleted: false,
          isFavorite: true,
          isWishlist: false,
          wishlistDone: false,
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testLinkedGoals = [
        GoalRecord(
          id: 'goal-1',
          title: '探索成都文化',
          level: 'monthly',
          isDeleted: false,
          isFavorite: false,
          isCompleted: false,
          isPostponed: false,
          progress: 0.5,
          recordDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testLinkedTravels = [
        TravelRecord(
          id: 'travel-2',
          tripId: 'trip-1',
          title: '第二天：武侯祠',
          isDeleted: false,
          isFavorite: false,
          isWishlist: false,
          wishlistDone: false,
          isJournal: true,
          recordDate: now.add(const Duration(days: 1)),
          createdAt: now,
          updatedAt: now,
        ),
      ];

      state = JournalDetailState(
        record: testJournal,
        trip: testTrip,
        linkedFriends: testLinkedFriends,
        linkedFoods: testLinkedFoods,
        linkedGoals: testLinkedGoals,
        linkedTravels: testLinkedTravels,
      );
    });

    test('should have all properties set correctly', () {
      expect(state.record, equals(testJournal));
      expect(state.trip, equals(testTrip));
      expect(state.linkedFriends, equals(testLinkedFriends));
      expect(state.linkedFoods, equals(testLinkedFoods));
      expect(state.linkedGoals, equals(testLinkedGoals));
      expect(state.linkedTravels, equals(testLinkedTravels));
    });

    test('should have correct title from record', () {
      expect(state.title, equals('游记：成都第一天'));
    });

    test('place should prefer poiName over poiAddress', () {
      expect(state.place, equals('锦里古街'));
    });

    test('images should parse correctly', () {
      expect(state.images, equals(['journal1.jpg', 'journal2.jpg']));
    });

    test('images should support comma separated history format', () {
      final historyJournal = testJournal.copyWith(images: const Value('old-a.jpg, old-b.jpg'));
      final historyState = JournalDetailState(
        record: historyJournal,
        trip: testTrip,
        linkedFriends: testLinkedFriends,
        linkedFoods: testLinkedFoods,
        linkedGoals: testLinkedGoals,
        linkedTravels: testLinkedTravels,
      );
      expect(historyState.images, equals(['old-a.jpg', 'old-b.jpg']));
    });

    test('images should support single path history format', () {
      final historyJournal = testJournal.copyWith(images: const Value('single-history.jpg'));
      final historyState = JournalDetailState(
        record: historyJournal,
        trip: testTrip,
        linkedFriends: testLinkedFriends,
        linkedFoods: testLinkedFoods,
        linkedGoals: testLinkedGoals,
        linkedTravels: testLinkedTravels,
      );
      expect(historyState.images, equals(['single-history.jpg']));
    });

    test('tags should parse correctly', () {
      expect(state.tags, equals(['古街', '文化']));
    });
  });

  group('resolveTravelDetailTripId', () {
    test('优先使用记录自身的 tripId，避免详情页依赖脏的路由参数', () {
      final record = TravelRecord(
        id: 'travel-1',
        tripId: 'trip-real',
        title: '藏兵洞',
        isDeleted: false,
        isFavorite: false,
        isWishlist: false,
        wishlistDone: false,
        isJournal: false,
        recordDate: DateTime(2024, 3, 22),
        createdAt: DateTime(2024, 3, 22),
        updatedAt: DateTime(2024, 3, 22),
      );

      final resolved = resolveTravelDetailTripId(record, 'trip-stale');

      expect(resolved, 'trip-real');
    });

    test('当记录缺少 tripId 时回退到路由参数中的 tripId', () {
      final record = TravelRecord(
        id: 'travel-1',
        tripId: '',
        title: '藏兵洞',
        isDeleted: false,
        isFavorite: false,
        isWishlist: false,
        wishlistDone: false,
        isJournal: false,
        recordDate: DateTime(2024, 3, 22),
        createdAt: DateTime(2024, 3, 22),
        updatedAt: DateTime(2024, 3, 22),
      );

      final resolved = resolveTravelDetailTripId(record, 'trip-fallback');

      expect(resolved, 'trip-fallback');
    });
  });
}
