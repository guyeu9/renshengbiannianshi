import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

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
        id: 'test-food-1',
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
        id: 'test-food-2',
        title: 'Original Title',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await foodDao.upsert(record);

      final updatedRecord = FoodRecordsCompanion.insert(
        id: 'test-food-2',
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
        id: 'test-food-3',
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
        id: 'test-food-fav-1',
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
        id: 'test-food-fav-2',
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
        id: 'test-food-wish-1',
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
        id: 'test-food-wish-2',
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
        id: 'watch-food-1',
        title: 'Food 1',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final record2 = FoodRecordsCompanion.insert(
        id: 'watch-food-2',
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
        id: 'watch-food-3',
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
        id: 'watch-food-4',
        title: 'Active',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final record2 = FoodRecordsCompanion.insert(
        id: 'watch-food-5',
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
        id: 'date-food-1',
        title: 'Date Test 1',
        recordDate: now.subtract(const Duration(days: 5)),
        createdAt: now,
        updatedAt: now,
      );
      final record2 = FoodRecordsCompanion.insert(
        id: 'date-food-2',
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

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('FoodDao Stream Reliability - watchById（0.1.160）', () {
    test('A: 初始状态（不存在的 id）应返回 null', () async {
      final result = await foodDao.watchById('non-existent').first;
      expect(result, isNull);
    });

    test('B: 插入数据后流应发出新值', () async {
      final now = DateTime.now();
      final stream = foodDao.watchById('stream-byid-1');
      final future = expectLater(
        stream,
        emitsInOrder([
          isNull,                 // 初始值
          isNotNull,              // 插入后
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-byid-1',
        title: 'Stream Test',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出新值', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-byid-2',
        title: 'Old Title',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = foodDao.watchById('stream-byid-2');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((FoodRecord? r) => r?.title == 'Old Title'),
          predicate((FoodRecord? r) => r?.title == 'New Title'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-byid-2',
        title: 'New Title',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除后流应发出 null（watchById 过滤 isDeleted）', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-byid-3',
        title: 'To Delete',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = foodDao.watchById('stream-byid-3');
      final future = expectLater(
        stream,
        emitsInOrder([
          isNotNull,    // 软删除前
          isNull,       // 软删除后
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await foodDao.softDeleteById('stream-byid-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 不存在的 id 应返回 null', () async {
      final result = await foodDao.watchById('').first;
      expect(result, isNull);
    });

    test('边界2: 软删除的记录应返回 null', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-byid-4',
        title: 'Already Deleted',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await foodDao.softDeleteById('stream-byid-4', now: now);
      final result = await foodDao.watchById('stream-byid-4').first;
      expect(result, isNull);
    });
  });

  group('FoodDao Stream Reliability - watchAllActive（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await foodDao.watchAllActive().first;
      expect(result, isEmpty);
    });

    test('B: 插入数据后流应发出包含新记录的列表', () async {
      final now = DateTime.now();
      final stream = foodDao.watchAllActive();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<FoodRecord> list) => list.any((r) => r.id == 'stream-all-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-all-1',
        title: 'Stream All Test',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出包含更新后记录的列表', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-all-2',
        title: 'Old Title',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = foodDao.watchAllActive();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<FoodRecord> list) => list.firstWhere((r) => r.id == 'stream-all-2').title == 'Old Title'),
          predicate((List<FoodRecord> list) => list.firstWhere((r) => r.id == 'stream-all-2').title == 'Updated Title'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-all-2',
        title: 'Updated Title',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除后流应发出不包含已删除记录的列表', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-all-3',
        title: 'To Delete',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = foodDao.watchAllActive();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<FoodRecord> list) => list.any((r) => r.id == 'stream-all-3')),
          predicate((List<FoodRecord> list) => !list.any((r) => r.id == 'stream-all-3')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await foodDao.softDeleteById('stream-all-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 插入多条后应按 recordDate 降序排序', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-order-1',
        title: 'Old',
        recordDate: now.subtract(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
      ));
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-order-2',
        title: 'New',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await foodDao.watchAllActive().first;
      expect(result.first.id, equals('stream-order-2'));
      expect(result.last.id, equals('stream-order-1'));
    });

    test('边界2: 软删除后再插入新记录应只返回活跃记录', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-mixed-1',
        title: 'Will Delete',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await foodDao.softDeleteById('stream-mixed-1', now: now);
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-mixed-2',
        title: 'Active',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await foodDao.watchAllActive().first;
      expect(result.any((r) => r.id == 'stream-mixed-1'), isFalse);
      expect(result.any((r) => r.id == 'stream-mixed-2'), isTrue);
    });
  });

  group('FoodDao Stream Reliability - watchFavorites（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await foodDao.watchFavorites().first;
      expect(result, isEmpty);
    });

    test('B: 收藏后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-fav-1',
        title: 'Fav Test',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = foodDao.watchFavorites();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<FoodRecord> list) => list.any((r) => r.id == 'stream-fav-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await foodDao.updateFavorite('stream-fav-1', isFavorite: true, now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 取消收藏后流应发出空列表', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-fav-2',
        title: 'Toggle Fav',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
      ));
      final stream = foodDao.watchFavorites();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<FoodRecord> list) => list.any((r) => r.id == 'stream-fav-2')),
          isEmpty,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await foodDao.updateFavorite('stream-fav-2', isFavorite: false, now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除收藏记录后流应发出空列表', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-fav-3',
        title: 'Delete Fav',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
      ));
      final stream = foodDao.watchFavorites();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<FoodRecord> list) => list.any((r) => r.id == 'stream-fav-3')),
          isEmpty,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await foodDao.softDeleteById('stream-fav-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 未收藏的记录不应出现在收藏列表中', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-fav-4',
        title: 'Not Favorite',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await foodDao.watchFavorites().first;
      expect(result.any((r) => r.id == 'stream-fav-4'), isFalse);
    });

    test('边界2: 多条收藏记录切换状态后流应正确反映', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-fav-5',
        title: 'Fav A',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
      ));
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-fav-6',
        title: 'Fav B',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
      ));
      final stream = foodDao.watchFavorites();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<FoodRecord> list) => list.length == 2),
          predicate((List<FoodRecord> list) => list.length == 1 && list.first.id == 'stream-fav-6'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await foodDao.updateFavorite('stream-fav-5', isFavorite: false, now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });
  });

  group('FoodDao Stream Reliability - watchByRecordDateRange（0.1.160 边界参数全覆盖）', () {
    test('A: 初始状态应返回空列表', () async {
      final now = DateTime.now();
      final result = await foodDao.watchByRecordDateRange(now, now.add(const Duration(days: 1))).first;
      expect(result, isEmpty);
    });

    test('B: 插入范围内记录后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      final recordDate = now.add(const Duration(hours: 12));
      final stream = foodDao.watchByRecordDateRange(now, now.add(const Duration(days: 1)));
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<FoodRecord> list) => list.any((r) => r.id == 'stream-range-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-range-1',
        title: 'In Range',
        recordDate: recordDate,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 空范围（start == end）应返回空列表', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-empty-range',
        title: 'Test',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await foodDao.watchByRecordDateRange(now, now).first;
      expect(result, isEmpty);
    });

    test('边界2: 单点范围（start == recordDate, end == start+1s）应包含该记录', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-single-point',
        title: 'Exact Start',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await foodDao.watchByRecordDateRange(now, now.add(const Duration(seconds: 1))).first;
      expect(result.any((r) => r.id == 'stream-single-point'), isTrue);
    });

    test('边界3: 跨年范围应包含跨年记录', () async {
      final dec31 = DateTime(2025, 12, 31);
      final jan1 = DateTime(2026, 1, 1);
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-cross-year',
        title: 'New Year',
        recordDate: jan1,
        createdAt: jan1,
        updatedAt: jan1,
      ));
      final result = await foodDao.watchByRecordDateRange(dec31, jan1.add(const Duration(days: 1))).first;
      expect(result.any((r) => r.id == 'stream-cross-year'), isTrue);
    });

    test('边界4: 未来日期范围应不包含过去记录', () async {
      final now = DateTime.now();
      final futureStart = now.add(const Duration(days: 10));
      final futureEnd = now.add(const Duration(days: 20));
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-past-record',
        title: 'Past',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await foodDao.watchByRecordDateRange(futureStart, futureEnd).first;
      expect(result, isEmpty);
    });

    test('边界5: recordDate == start 应包含（isBiggerOrEqualValue）', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-boundary-start',
        title: 'At Start',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await foodDao.watchByRecordDateRange(now, now.add(const Duration(days: 1))).first;
      expect(result.any((r) => r.id == 'stream-boundary-start'), isTrue);
    });

    test('边界6: recordDate == end 应不包含（isSmallerThanValue）', () async {
      final now = DateTime.now();
      final end = now.add(const Duration(days: 1));
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-boundary-end',
        title: 'At End',
        recordDate: end,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await foodDao.watchByRecordDateRange(now, end).first;
      expect(result.any((r) => r.id == 'stream-boundary-end'), isFalse);
    });

    test('边界7: 软删除的记录不应出现在范围内', () async {
      final now = DateTime.now();
      await foodDao.upsert(FoodRecordsCompanion.insert(
        id: 'stream-range-deleted',
        title: 'Deleted In Range',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await foodDao.softDeleteById('stream-range-deleted', now: now);
      final result = await foodDao.watchByRecordDateRange(now.subtract(const Duration(days: 1)), now.add(const Duration(days: 1))).first;
      expect(result.any((r) => r.id == 'stream-range-deleted'), isFalse);
    });
  });
}
