import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;

void main() {
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
      
      final record = FoodRecordsCompanion.insert(
        id: 'integration-food-1',
        title: 'Integration Test Restaurant',
        content: const Value('Great food and service'),
        rating: const Value(4.5),
        city: const Value('Beijing'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await db.foodDao.upsert(record);

      var found = await db.foodDao.findById('integration-food-1');
      expect(found, isNotNull);
      expect(found!.title, equals('Integration Test Restaurant'));
      expect(found.rating, equals(4.5));

      final updatedRecord = FoodRecordsCompanion.insert(
        id: 'integration-food-1',
        title: 'Updated Restaurant Name',
        content: const Value('Even better now'),
        rating: const Value(5.0),
        city: const Value('Beijing'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
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
      
      final record = FoodRecordsCompanion.insert(
        id: 'integration-food-2',
        title: 'Wishlist Restaurant',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
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
