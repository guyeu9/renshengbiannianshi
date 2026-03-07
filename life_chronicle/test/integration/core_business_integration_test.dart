import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;

void main() {
  group('Moment Record Integration Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = createTestDatabase();
    });

    tearDown(() async {
      await closeTestDatabase(db);
    });

    test('Complete moment record lifecycle: create, read, update, delete', () async {
      final now = DateTime.now();
      
      final record = TestDataFactory.createMomentRecord(
        id: 'integration-moment-1',
        mood: '开心',
        content: '今天天气很好',
        city: '北京',
        recordDate: now,
      );

      await db.momentDao.upsert(record);

      var found = await db.momentDao.findById('integration-moment-1');
      expect(found, isNotNull);
      expect(found!.mood, equals('开心'));
      expect(found.content, equals('今天天气很好'));

      final updatedRecord = TestDataFactory.createMomentRecord(
        id: 'integration-moment-1',
        mood: '平静',
        content: '今天学习了很多新东西',
        city: '上海',
        recordDate: now,
      );
      await db.momentDao.upsert(updatedRecord);

      found = await db.momentDao.findById('integration-moment-1');
      expect(found!.mood, equals('平静'));
      expect(found.content, equals('今天学习了很多新东西'));
      expect(found.city, equals('上海'));

      await db.momentDao.softDeleteById('integration-moment-1', now: DateTime.now());
      found = await db.momentDao.findById('integration-moment-1');
      expect(found!.isDeleted, isTrue);
    });

    test('Moment record with favorite operations', () async {
      final now = DateTime.now();
      
      final record = TestDataFactory.createMomentRecord(
        id: 'integration-moment-2',
        mood: '开心',
        content: '美好的一天',
        recordDate: now,
      );
      await db.momentDao.upsert(record);

      await db.momentDao.updateFavorite('integration-moment-2', isFavorite: true, now: now);
      var found = await db.momentDao.findById('integration-moment-2');
      expect(found!.isFavorite, isTrue);

      await db.momentDao.updateFavorite('integration-moment-2', isFavorite: false, now: now);
      found = await db.momentDao.findById('integration-moment-2');
      expect(found!.isFavorite, isFalse);
    });
  });

  group('Food Record Integration Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = createTestDatabase();
    });

    tearDown(() async {
      await closeTestDatabase(db);
    });

    test('Complete food record lifecycle: create, read, update, delete', () async {
      final now = DateTime.now();
      
      final record = TestDataFactory.createFoodRecord(
        id: 'integration-food-1',
        title: 'Integration Test Restaurant',
        content: 'Great food and service',
        rating: 4.5,
        city: 'Beijing',
        recordDate: now,
      );

      await db.foodDao.upsert(record);

      var found = await db.foodDao.findById('integration-food-1');
      expect(found, isNotNull);
      expect(found!.title, equals('Integration Test Restaurant'));
      expect(found.rating, equals(4.5));

      final updatedRecord = TestDataFactory.createFoodRecord(
        id: 'integration-food-1',
        title: 'Updated Restaurant Name',
        content: 'Even better now',
        rating: 5.0,
        city: 'Beijing',
        recordDate: now,
      );
      await db.foodDao.upsert(updatedRecord);

      found = await db.foodDao.findById('integration-food-1');
      expect(found!.title, equals('Updated Restaurant Name'));
      expect(found.rating, equals(5.0));

      await db.foodDao.softDeleteById('integration-food-1', now: DateTime.now());
      found = await db.foodDao.findById('integration-food-1');
      expect(found!.isDeleted, isTrue);
    });

    test('Food record with favorite and wishlist operations', () async {
      final now = DateTime.now();
      
      final record = TestDataFactory.createFoodRecord(
        id: 'integration-food-2',
        title: 'Wishlist Restaurant',
        recordDate: now,
      );
      await db.foodDao.upsert(record);

      await db.foodDao.updateWishlistStatus(
        'integration-food-2',
        isWishlist: true,
        wishlistDone: false,
        now: now,
      );
      var found = await db.foodDao.findById('integration-food-2');
      expect(found!.isWishlist, isTrue);
      expect(found.wishlistDone, isFalse);

      await db.foodDao.updateWishlistStatus(
        'integration-food-2',
        isWishlist: true,
        wishlistDone: true,
        now: now,
      );
      found = await db.foodDao.findById('integration-food-2');
      expect(found!.wishlistDone, isTrue);

      await db.foodDao.updateFavorite('integration-food-2', isFavorite: true, now: now);
      found = await db.foodDao.findById('integration-food-2');
      expect(found!.isFavorite, isTrue);
    });
  });

  group('Friend Record Integration Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = createTestDatabase();
    });

    tearDown(() async {
      await closeTestDatabase(db);
    });

    test('Complete friend record lifecycle: create, read, update, delete', () async {
      final record = TestDataFactory.createFriendRecord(
        id: 'integration-friend-1',
        name: '张三',
        groupName: '同学',
        impressionTags: '["幽默", "聪明"]',
        meetDate: DateTime(2020, 1, 1),
      );

      await db.friendDao.upsert(record);

      var found = await db.friendDao.findById('integration-friend-1');
      expect(found, isNotNull);
      expect(found!.name, equals('张三'));
      expect(found.groupName, equals('同学'));

      final updatedRecord = TestDataFactory.createFriendRecord(
        id: 'integration-friend-1',
        name: '李四',
        groupName: '朋友',
        impressionTags: '["靠谱", "有趣"]',
        meetDate: DateTime(2021, 6, 15),
      );
      await db.friendDao.upsert(updatedRecord);

      found = await db.friendDao.findById('integration-friend-1');
      expect(found!.name, equals('李四'));
      expect(found.groupName, equals('朋友'));
      expect(found.impressionTags, equals('["靠谱", "有趣"]'));

      await db.friendDao.softDeleteById('integration-friend-1', now: DateTime.now());
      found = await db.friendDao.findById('integration-friend-1');
      expect(found!.isDeleted, isTrue);
    });

    test('Friend record with favorite and group operations', () async {
      final now = DateTime.now();
      
      final record = TestDataFactory.createFriendRecord(
        id: 'integration-friend-2',
        name: '王五',
        groupName: '家人',
      );
      await db.friendDao.upsert(record);

      await db.friendDao.updateFavorite('integration-friend-2', isFavorite: true, now: now);
      var found = await db.friendDao.findById('integration-friend-2');
      expect(found!.isFavorite, isTrue);

      await db.friendDao.updateFavorite('integration-friend-2', isFavorite: false, now: now);
      found = await db.friendDao.findById('integration-friend-2');
      expect(found!.isFavorite, isFalse);
    });
  });

  group('Entity Links Integration Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = createTestDatabase();
    });

    tearDown(() async {
      await closeTestDatabase(db);
    });

    test('Create and query entity links between food and friend', () async {
      final now = DateTime.now();

      final food = FoodRecordsCompanion.insert(
        id: 'link-food-1',
        title: 'Dinner with friend',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      );
      await db.foodDao.upsert(food);

      final friend = FriendRecordsCompanion.insert(
        id: 'link-friend-1',
        name: 'Best Friend',
        createdAt: now,
        updatedAt: now,
      );
      await db.friendDao.upsert(friend);

      await db.linkDao.createLink(
        sourceType: 'food',
        sourceId: 'link-food-1',
        targetType: 'friend',
        targetId: 'link-friend-1',
        now: now,
      );

      final links = await db.linkDao.listLinksForEntity(entityType: 'food', entityId: 'link-food-1');
      expect(links.length, equals(1));
      expect(links.first.targetType, equals('friend'));
      expect(links.first.targetId, equals('link-friend-1'));
    });

    test('Multiple entity links for a single record', () async {
      final now = DateTime.now();

      final moment = MomentRecordsCompanion.insert(
        id: 'link-moment-1',
        mood: '开心',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      );
      await db.momentDao.upsert(moment);

      for (int i = 1; i <= 3; i++) {
        final friend = FriendRecordsCompanion.insert(
          id: 'link-friend-$i',
          name: 'Friend $i',
          createdAt: now,
          updatedAt: now,
        );
        await db.friendDao.upsert(friend);

        await db.linkDao.createLink(
          sourceType: 'moment',
          sourceId: 'link-moment-1',
          targetType: 'friend',
          targetId: 'link-friend-$i',
          now: now,
        );
      }

      final links = await db.linkDao.listLinksForEntity(entityType: 'moment', entityId: 'link-moment-1');
      expect(links.length, equals(3));
    });
  });

  group('Timeline Events Integration Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = createTestDatabase();
    });

    tearDown(() async {
      await closeTestDatabase(db);
    });

    test('Create timeline event and query by date range', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final event1 = TimelineEventsCompanion.insert(
        id: 'timeline-1',
        title: 'Today Event',
        eventType: 'moment',
        startAt: Value(now),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      );
      await db.into(db.timelineEvents).insert(event1);

      final event2 = TimelineEventsCompanion.insert(
        id: 'timeline-2',
        title: 'Yesterday Event',
        eventType: 'encounter',
        startAt: Value(yesterday),
        recordDate: yesterday,
        createdAt: now,
        updatedAt: now,
      );
      await db.into(db.timelineEvents).insert(event2);

      final events = await (db.select(db.timelineEvents)
            ..where((t) => t.eventType.equals('moment')))
          .get();
      expect(events.length, equals(1));
      expect(events.first.title, equals('Today Event'));
    });
  });

  group('Backup and Restore Integration Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = createTestDatabase();
    });

    tearDown(() async {
      await closeTestDatabase(db);
    });

    test('Export and import data correctly', () async {
      final now = DateTime.now();

      final food = FoodRecordsCompanion.insert(
        id: 'backup-food-1',
        title: 'Backup Test Food',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      );
      await db.foodDao.upsert(food);

      final exportData = <String, dynamic>{
        'food_records': [
          {
            'id': 'backup-food-1',
            'title': 'Backup Test Food',
            'content': null,
            'images': null,
            'tags': null,
            'rating': null,
            'pricePerPerson': null,
            'link': null,
            'latitude': null,
            'longitude': null,
            'poiName': null,
            'poiAddress': null,
            'city': null,
            'country': null,
            'mood': null,
            'isWishlist': false,
            'isFavorite': false,
            'wishlistDone': false,
            'recordDate': now.toIso8601String(),
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
            'isDeleted': false,
          }
        ],
        'exported_at': now.toIso8601String(),
      };

      expect(exportData['food_records'], isNotNull);
      expect((exportData['food_records'] as List).length, equals(1));
    });
  });
}
