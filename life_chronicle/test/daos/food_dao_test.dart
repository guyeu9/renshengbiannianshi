import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/test/test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late FoodDao foodDao;

  setUp(() async {
    db = createTestDatabase();
    foodDao = FoodDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('FoodDao CRUD Operations', () {
    test('should insert a food record', () async {
      final record = FoodRecordsCompanion.insert(
        id: const Value('test-food-1'),
        title: 'Test Restaurant',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await foodDao.upsert(record);

      final found = await foodDao.findById('test-food-1');
      expect(found, isNotNull);
      expect(found!.title, equals('Test Restaurant'));
    });

    test('should update an existing food record', () async {
      final record = FoodRecordsCompanion.insert(
        id: const Value('test-food-2'),
        title: 'Original Title',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await foodDao.upsert(record);

      final updatedRecord = FoodRecordsCompanion.insert(
        id: const Value('test-food-2'),
        title: 'Updated Title',
        content: const Value('Updated content'),
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await foodDao.upsert(updatedRecord);

      final found = await foodDao.findById('test-food-2');
      expect(found!.title, equals('Updated Title'));
      expect(found.content, equals('Updated content'));
    });

    test('should soft delete a food record', () async {
      final record = FoodRecordsCompanion.insert(
        id: const Value('test-food-3'),
        title: 'To Be Deleted',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await foodDao.upsert(record);
      await foodDao.softDeleteById('test-food-3', now: DateTime.now());

      final found = await foodDao.findById('test-food-3');
      expect(found!.isDeleted, isTrue);
    });

    test('should return null for non-existent record', () async {
      final found = await foodDao.findById('non-existent-id');
      expect(found, isNull);
    });
  });

  group('FoodDao Favorite Operations', () {
    test('should update favorite status', () async {
      final record = FoodRecordsCompanion.insert(
        id: const Value('test-food-fav-1'),
        title: 'Favorite Test',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await foodDao.upsert(record);
      await foodDao.updateFavorite('test-food-fav-1', isFavorite: true, now: DateTime.now());

      final found = await foodDao.findById('test-food-fav-1');
      expect(found!.isFavorite, isTrue);
    });

    test('should toggle favorite status', () async {
      final record = FoodRecordsCompanion.insert(
        id: const Value('test-food-fav-2'),
        title: 'Toggle Favorite',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await foodDao.upsert(record);
      
      await foodDao.updateFavorite('test-food-fav-2', isFavorite: true, now: DateTime.now());
      var found = await foodDao.findById('test-food-fav-2');
      expect(found!.isFavorite, isTrue);

      await foodDao.updateFavorite('test-food-fav-2', isFavorite: false, now: DateTime.now());
      found = await foodDao.findById('test-food-fav-2');
      expect(found!.isFavorite, isFalse);
    });
  });

  group('FoodDao Wishlist Operations', () {
    test('should update wishlist status', () async {
      final record = FoodRecordsCompanion.insert(
        id: const Value('test-food-wish-1'),
        title: 'Wishlist Test',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await foodDao.upsert(record);
      await foodDao.updateWishlistStatus(
        'test-food-wish-1',
        isWishlist: true,
        wishlistDone: false,
        now: DateTime.now(),
      );

      final found = await foodDao.findById('test-food-wish-1');
      expect(found!.isWishlist, isTrue);
      expect(found.wishlistDone, isFalse);
    });

    test('should mark wishlist as done', () async {
      final record = FoodRecordsCompanion.insert(
        id: const Value('test-food-wish-2'),
        title: 'Wishlist Done Test',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await foodDao.upsert(record);
      await foodDao.updateWishlistStatus(
        'test-food-wish-2',
        isWishlist: true,
        wishlistDone: true,
        now: DateTime.now(),
      );

      final found = await foodDao.findById('test-food-wish-2');
      expect(found!.isWishlist, isTrue);
      expect(found.wishlistDone, isTrue);
    });
  });

  group('FoodDao Watch Operations', () {
    test('should watch all active records', () async {
      final record1 = FoodRecordsCompanion.insert(
        id: const Value('watch-food-1'),
        title: 'Food 1',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final record2 = FoodRecordsCompanion.insert(
        id: const Value('watch-food-2'),
        title: 'Food 2',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await foodDao.upsert(record1);
      await foodDao.upsert(record2);

      final records = await foodDao.watchAllActive().first;
      expect(records.length, greaterThanOrEqualTo(2));
    });

    test('should watch record by id', () async {
      final record = FoodRecordsCompanion.insert(
        id: const Value('watch-food-3'),
        title: 'Watch Test',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await foodDao.upsert(record);

      final watched = await foodDao.watchById('watch-food-3').first;
      expect(watched, isNotNull);
      expect(watched!.title, equals('Watch Test'));
    });

    test('should not return soft deleted records in watchAllActive', () async {
      final record1 = FoodRecordsCompanion.insert(
        id: const Value('watch-food-4'),
        title: 'Active',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final record2 = FoodRecordsCompanion.insert(
        id: const Value('watch-food-5'),
        title: 'Deleted',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await foodDao.upsert(record1);
      await foodDao.upsert(record2);
      await foodDao.softDeleteById('watch-food-5', now: DateTime.now());

      final records = await foodDao.watchAllActive().first;
      final deletedRecord = records.where((r) => r.id == 'watch-food-5').firstOrNull;
      expect(deletedRecord, isNull);
    });
  });

  group('FoodDao Date Range Query', () {
    test('should filter by record date range', () async {
      final now = DateTime.now();
      final record1 = FoodRecordsCompanion.insert(
        id: const Value('date-food-1'),
        title: 'Date Test 1',
        recordDate: now.subtract(const Duration(days: 5)),
        createdAt: now,
        updatedAt: now,
      );
      final record2 = FoodRecordsCompanion.insert(
        id: const Value('date-food-2'),
        title: 'Date Test 2',
        recordDate: now.subtract(const Duration(days: 1)),
        createdAt: now,
        updatedAt: now,
      );

      await foodDao.upsert(record1);
      await foodDao.upsert(record2);

      final start = now.subtract(const Duration(days: 3));
      final end = now;
      final records = await foodDao.watchByRecordDateRange(start, end).first;
      
      expect(records.any((r) => r.id == 'date-food-2'), isTrue);
      expect(records.any((r) => r.id == 'date-food-1'), isFalse);
    });
  });
}
