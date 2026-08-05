import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late TravelDao travelDao;

  setUp(() async {
    db = createTestDatabase();
    travelDao = TravelDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  // TravelDao 共 9 个 watch* 方法，每个方法设计 A/B/C/D 四类标准化测试
  // 带参数的 watch 方法额外设计边界参数测试

  group('TravelDao Stream Reliability - watchById（0.1.160）', () {
    test('A: 初始状态（不存在的 id）应返回 null', () async {
      final result = await travelDao.watchById('non-existent').first;
      expect(result, isNull);
    });

    test('B: 插入数据后流应发出新值', () async {
      final now = DateTime.now();
      final stream = travelDao.watchById('t-stream-byid-1');
      final future = expectLater(
        stream,
        emitsInOrder([
          isNull,
          isNotNull,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-byid-1',
        tripId: 't-stream-trip-1',
        title: const Value('Stream Test'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出新值', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-byid-2',
        tripId: 't-stream-trip-2',
        title: const Value('Old Title'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = travelDao.watchById('t-stream-byid-2');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((TravelRecord? r) => r?.title == 'Old Title'),
          predicate((TravelRecord? r) => r?.title == 'New Title'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-byid-2',
        tripId: 't-stream-trip-2',
        title: const Value('New Title'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除后流应发出 null（watchById 过滤 isDeleted）', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-byid-3',
        tripId: 't-stream-trip-3',
        title: const Value('To Delete'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = travelDao.watchById('t-stream-byid-3');
      final future = expectLater(
        stream,
        emitsInOrder([
          isNotNull,
          isNull,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.softDeleteById('t-stream-byid-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 空字符串 id 应返回 null', () async {
      final result = await travelDao.watchById('').first;
      expect(result, isNull);
    });

    test('边界2: 软删除的记录应返回 null', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-byid-4',
        tripId: 't-stream-trip-4',
        title: const Value('Already Deleted'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await travelDao.softDeleteById('t-stream-byid-4', now: now);
      final result = await travelDao.watchById('t-stream-byid-4').first;
      expect(result, isNull);
    });
  });

  group('TravelDao Stream Reliability - watchAllActive（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await travelDao.watchAllActive().first;
      expect(result, isEmpty);
    });

    test('B: 插入数据后流应发出包含新记录的列表', () async {
      final now = DateTime.now();
      final stream = travelDao.watchAllActive();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-all-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-all-1',
        tripId: 't-stream-trip-all-1',
        title: const Value('Stream All Test'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出包含更新后记录的列表', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-all-2',
        tripId: 't-stream-trip-all-2',
        title: const Value('Old Title'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = travelDao.watchAllActive();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<TravelRecord> list) =>
              list.firstWhere((r) => r.id == 't-stream-all-2').title ==
              'Old Title'),
          predicate((List<TravelRecord> list) =>
              list.firstWhere((r) => r.id == 't-stream-all-2').title ==
              'Updated Title'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-all-2',
        tripId: 't-stream-trip-all-2',
        title: const Value('Updated Title'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除后流应发出不包含已删除记录的列表', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-all-3',
        tripId: 't-stream-trip-all-3',
        title: const Value('To Delete'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = travelDao.watchAllActive();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-all-3')),
          predicate((List<TravelRecord> list) =>
              !list.any((r) => r.id == 't-stream-all-3')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.softDeleteById('t-stream-all-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 插入多条后应按 recordDate 降序排序', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-order-1',
        tripId: 't-stream-trip-order-1',
        title: const Value('Old'),
        recordDate: now.subtract(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
      ));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-order-2',
        tripId: 't-stream-trip-order-2',
        title: const Value('New'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await travelDao.watchAllActive().first;
      expect(result.first.id, equals('t-stream-order-2'));
      expect(result.last.id, equals('t-stream-order-1'));
    });

    test('边界2: 软删除后再插入新记录应只返回活跃记录', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-mixed-1',
        tripId: 't-stream-trip-mixed-1',
        title: const Value('Will Delete'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await travelDao.softDeleteById('t-stream-mixed-1', now: now);
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-mixed-2',
        tripId: 't-stream-trip-mixed-2',
        title: const Value('Active'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await travelDao.watchAllActive().first;
      expect(result.any((r) => r.id == 't-stream-mixed-1'), isFalse);
      expect(result.any((r) => r.id == 't-stream-mixed-2'), isTrue);
    });
  });

  group('TravelDao Stream Reliability - watchTrips（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await travelDao.watchTrips().first;
      expect(result, isEmpty);
    });

    test('B: 插入 trip 后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      final stream = travelDao.watchTrips();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-trips-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-trips-1',
        tripId: 't-stream-trip-trips-1',
        title: const Value('Trip Test'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新 trip 后流应发出新值', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-trips-2',
        tripId: 't-stream-trip-trips-2',
        title: const Value('Old Trip'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = travelDao.watchTrips();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<TravelRecord> list) =>
              list.firstWhere((r) => r.id == 't-stream-trips-2').title ==
              'Old Trip'),
          predicate((List<TravelRecord> list) =>
              list.firstWhere((r) => r.id == 't-stream-trips-2').title ==
              'New Trip'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-trips-2',
        tripId: 't-stream-trip-trips-2',
        title: const Value('New Trip'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除 trip 后流应发出空列表', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-trips-3',
        tripId: 't-stream-trip-trips-3',
        title: const Value('To Delete Trip'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = travelDao.watchTrips();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-trips-3')),
          predicate((List<TravelRecord> list) =>
              !list.any((r) => r.id == 't-stream-trips-3')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.softDeleteById('t-stream-trips-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: journal 记录不应出现在 trips 列表中（isJournal 边界）', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-trips-journal',
        tripId: 't-stream-trip-journal-boundary',
        title: const Value('Journal Not Trip'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isJournal: const Value(true),
      ));
      final result = await travelDao.watchTrips().first;
      expect(result.any((r) => r.id == 't-stream-trips-journal'), isFalse);
    });

    test('边界2: 软删除的 trip 不应出现在 trips 列表中', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-trips-deleted',
        tripId: 't-stream-trip-deleted-boundary',
        title: const Value('Deleted Trip'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await travelDao.softDeleteById('t-stream-trips-deleted', now: now);
      final result = await travelDao.watchTrips().first;
      expect(result.any((r) => r.id == 't-stream-trips-deleted'), isFalse);
    });
  });

  group('TravelDao Stream Reliability - watchFavoriteTrips（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await travelDao.watchFavoriteTrips().first;
      expect(result, isEmpty);
    });

    test('B: 收藏 trip 后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-fav-trips-1',
        tripId: 't-stream-trip-fav-trips-1',
        title: const Value('Fav Trip Test'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = travelDao.watchFavoriteTrips();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-fav-trips-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.updateFavorite('t-stream-fav-trips-1',
          isFavorite: true, now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 取消收藏后流应发出空列表', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-fav-trips-2',
        tripId: 't-stream-trip-fav-trips-2',
        title: const Value('Toggle Fav Trip'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
      ));
      final stream = travelDao.watchFavoriteTrips();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-fav-trips-2')),
          isEmpty,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.updateFavorite('t-stream-fav-trips-2',
          isFavorite: false, now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除收藏 trip 后流应发出空列表', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-fav-trips-3',
        tripId: 't-stream-trip-fav-trips-3',
        title: const Value('Delete Fav Trip'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
      ));
      final stream = travelDao.watchFavoriteTrips();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-fav-trips-3')),
          isEmpty,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.softDeleteById('t-stream-fav-trips-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 未收藏的 trip 不应出现在收藏列表中', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-fav-trips-4',
        tripId: 't-stream-trip-fav-trips-4',
        title: const Value('Not Favorite Trip'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await travelDao.watchFavoriteTrips().first;
      expect(result.any((r) => r.id == 't-stream-fav-trips-4'), isFalse);
    });

    test('边界2: 收藏的 journal 不应出现在收藏 trip 列表中（isJournal 边界）',
        () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-fav-trips-journal',
        tripId: 't-stream-trip-fav-journal-boundary',
        title: const Value('Fav Journal Not Trip'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
        isJournal: const Value(true),
      ));
      final result = await travelDao.watchFavoriteTrips().first;
      expect(result.any((r) => r.id == 't-stream-fav-trips-journal'), isFalse);
    });
  });

  group('TravelDao Stream Reliability - watchFavoriteJournals（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await travelDao.watchFavoriteJournals().first;
      expect(result, isEmpty);
    });

    test('B: 收藏 journal 后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-fav-jrn-1',
        tripId: 't-stream-trip-fav-jrn-1',
        title: const Value('Fav Journal Test'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isJournal: const Value(true),
      ));
      final stream = travelDao.watchFavoriteJournals();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-fav-jrn-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.updateFavorite('t-stream-fav-jrn-1',
          isFavorite: true, now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 取消收藏后流应发出空列表', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-fav-jrn-2',
        tripId: 't-stream-trip-fav-jrn-2',
        title: const Value('Toggle Fav Journal'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
        isJournal: const Value(true),
      ));
      final stream = travelDao.watchFavoriteJournals();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-fav-jrn-2')),
          isEmpty,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.updateFavorite('t-stream-fav-jrn-2',
          isFavorite: false, now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除收藏 journal 后流应发出空列表', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-fav-jrn-3',
        tripId: 't-stream-trip-fav-jrn-3',
        title: const Value('Delete Fav Journal'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
        isJournal: const Value(true),
      ));
      final stream = travelDao.watchFavoriteJournals();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-fav-jrn-3')),
          isEmpty,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.softDeleteById('t-stream-fav-jrn-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 未收藏的 journal 不应出现在收藏列表中', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-fav-jrn-4',
        tripId: 't-stream-trip-fav-jrn-4',
        title: const Value('Not Favorite Journal'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isJournal: const Value(true),
      ));
      final result = await travelDao.watchFavoriteJournals().first;
      expect(result.any((r) => r.id == 't-stream-fav-jrn-4'), isFalse);
    });

    test('边界2: 收藏的 trip 不应出现在收藏 journal 列表中（isJournal 边界）',
        () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-fav-jrn-trip',
        tripId: 't-stream-trip-fav-trip-boundary',
        title: const Value('Fav Trip Not Journal'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
        isJournal: const Value(false),
      ));
      final result = await travelDao.watchFavoriteJournals().first;
      expect(result.any((r) => r.id == 't-stream-fav-jrn-trip'), isFalse);
    });
  });

  group('TravelDao Stream Reliability - watchJournals（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result =
          await travelDao.watchJournals('t-stream-trip-jrn-A').first;
      expect(result, isEmpty);
    });

    test('B: 插入 journal 后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      final stream = travelDao.watchJournals('t-stream-trip-jrn-1');
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-jrn-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-jrn-1',
        tripId: 't-stream-trip-jrn-1',
        title: const Value('Journal Test'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isJournal: const Value(true),
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新 journal 后流应发出新值', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-jrn-2',
        tripId: 't-stream-trip-jrn-2',
        title: const Value('Old Journal'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isJournal: const Value(true),
      ));
      final stream = travelDao.watchJournals('t-stream-trip-jrn-2');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<TravelRecord> list) =>
              list.firstWhere((r) => r.id == 't-stream-jrn-2').title ==
              'Old Journal'),
          predicate((List<TravelRecord> list) =>
              list.firstWhere((r) => r.id == 't-stream-jrn-2').title ==
              'New Journal'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-jrn-2',
        tripId: 't-stream-trip-jrn-2',
        title: const Value('New Journal'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isJournal: const Value(true),
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除 journal 后流应发出空列表', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-jrn-3',
        tripId: 't-stream-trip-jrn-3',
        title: const Value('To Delete Journal'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isJournal: const Value(true),
      ));
      final stream = travelDao.watchJournals('t-stream-trip-jrn-3');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-jrn-3')),
          isEmpty,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.softDeleteById('t-stream-jrn-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 不存在的 tripId 应返回空列表', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-jrn-other',
        tripId: 't-stream-trip-jrn-real',
        title: const Value('Other Journal'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isJournal: const Value(true),
      ));
      final result =
          await travelDao.watchJournals('t-stream-trip-jrn-nonexistent').first;
      expect(result, isEmpty);
    });

    test('边界2: 非该 tripId 的 journal 不应出现', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-jrn-other-2',
        tripId: 't-stream-trip-jrn-other',
        title: const Value('Other Trip Journal'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isJournal: const Value(true),
      ));
      final result =
          await travelDao.watchJournals('t-stream-trip-jrn-target').first;
      expect(result.any((r) => r.id == 't-stream-jrn-other-2'), isFalse);
    });
  });

  group('TravelDao Stream Reliability - watchByRecordDateRange（0.1.160 边界参数全覆盖）',
      () {
    test('A: 初始状态应返回空列表', () async {
      final now = DateTime.now();
      final result = await travelDao
          .watchByRecordDateRange(now, now.add(const Duration(days: 1)))
          .first;
      expect(result, isEmpty);
    });

    test('B: 插入范围内记录后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      final recordDate = now.add(const Duration(hours: 12));
      final stream = travelDao.watchByRecordDateRange(
          now, now.add(const Duration(days: 1)));
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-range-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-range-1',
        tripId: 't-stream-trip-range-1',
        title: const Value('In Range'),
        recordDate: recordDate,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新范围内记录后流应发出新值', () async {
      final now = DateTime.now();
      final recordDate = now.add(const Duration(hours: 12));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-range-2',
        tripId: 't-stream-trip-range-2',
        title: const Value('Old Range Title'),
        recordDate: recordDate,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = travelDao.watchByRecordDateRange(
          now, now.add(const Duration(days: 1)));
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<TravelRecord> list) => list
              .any((r) => r.id == 't-stream-range-2' && r.title == 'Old Range Title')),
          predicate((List<TravelRecord> list) => list
              .any((r) => r.id == 't-stream-range-2' && r.title == 'New Range Title')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-range-2',
        tripId: 't-stream-trip-range-2',
        title: const Value('New Range Title'),
        recordDate: recordDate,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除范围内记录后流应发出空列表', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-range-3',
        tripId: 't-stream-trip-range-3',
        title: const Value('Range Delete'),
        recordDate: now.add(const Duration(hours: 12)),
        createdAt: now,
        updatedAt: now,
      ));
      final stream = travelDao.watchByRecordDateRange(
          now, now.add(const Duration(days: 1)));
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-range-3')),
          predicate((List<TravelRecord> list) =>
              !list.any((r) => r.id == 't-stream-range-3')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.softDeleteById('t-stream-range-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 空范围（start == end）应返回空列表', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-empty-range',
        tripId: 't-stream-trip-empty-range',
        title: const Value('Test'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await travelDao.watchByRecordDateRange(now, now).first;
      expect(result, isEmpty);
    });

    test('边界2: 单点范围（start == recordDate, end == start+1s）应包含该记录',
        () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-single-point',
        tripId: 't-stream-trip-single-point',
        title: const Value('Exact Start'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await travelDao
          .watchByRecordDateRange(now, now.add(const Duration(seconds: 1)))
          .first;
      expect(result.any((r) => r.id == 't-stream-single-point'), isTrue);
    });

    test('边界3: 跨年范围应包含跨年记录', () async {
      final dec31 = DateTime(2025, 12, 31);
      final jan1 = DateTime(2026, 1, 1);
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-cross-year',
        tripId: 't-stream-trip-cross-year',
        title: const Value('New Year'),
        recordDate: jan1,
        createdAt: jan1,
        updatedAt: jan1,
      ));
      final result = await travelDao
          .watchByRecordDateRange(dec31, jan1.add(const Duration(days: 1)))
          .first;
      expect(result.any((r) => r.id == 't-stream-cross-year'), isTrue);
    });

    test('边界4: 未来日期范围应不包含过去记录', () async {
      final now = DateTime.now();
      final futureStart = now.add(const Duration(days: 10));
      final futureEnd = now.add(const Duration(days: 20));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-past-record',
        tripId: 't-stream-trip-past-record',
        title: const Value('Past'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result =
          await travelDao.watchByRecordDateRange(futureStart, futureEnd).first;
      expect(result, isEmpty);
    });

    test('边界5: recordDate == start 应包含（isBiggerOrEqualValue）', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-boundary-start',
        tripId: 't-stream-trip-boundary-start',
        title: const Value('At Start'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await travelDao
          .watchByRecordDateRange(now, now.add(const Duration(days: 1))).first;
      expect(result.any((r) => r.id == 't-stream-boundary-start'), isTrue);
    });

    test('边界6: recordDate == end 应不包含（isSmallerThanValue）', () async {
      final now = DateTime.now();
      final end = now.add(const Duration(days: 1));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-boundary-end',
        tripId: 't-stream-trip-boundary-end',
        title: const Value('At End'),
        recordDate: end,
        createdAt: now,
        updatedAt: now,
      ));
      final result =
          await travelDao.watchByRecordDateRange(now, end).first;
      expect(result.any((r) => r.id == 't-stream-boundary-end'), isFalse);
    });

    test('边界7: 软删除的记录不应出现在范围内', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-range-deleted',
        tripId: 't-stream-trip-range-deleted',
        title: const Value('Deleted In Range'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await travelDao.softDeleteById('t-stream-range-deleted', now: now);
      final result = await travelDao
          .watchByRecordDateRange(
              now.subtract(const Duration(days: 1)), now.add(const Duration(days: 1)))
          .first;
      expect(result.any((r) => r.id == 't-stream-range-deleted'), isFalse);
    });
  });

  group('TravelDao Stream Reliability - watchTripById（0.1.160）', () {
    test('A: 初始状态（不存在的 id）应返回 null', () async {
      final result = await travelDao.watchTripById('non-existent').first;
      expect(result, isNull);
    });

    test('B: 插入 trip 后流应发出新值', () async {
      final now = DateTime.now();
      final stream = travelDao.watchTripById('t-stream-tripid-1');
      final future = expectLater(
        stream,
        emitsInOrder([
          isNull,
          isNotNull,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.upsertTrip(TripsCompanion.insert(
        id: 't-stream-tripid-1',
        name: 'Stream Trip Test',
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新 trip 后流应发出新值', () async {
      final now = DateTime.now();
      await travelDao.upsertTrip(TripsCompanion.insert(
        id: 't-stream-tripid-2',
        name: 'Old Trip Name',
        createdAt: now,
        updatedAt: now,
      ));
      final stream = travelDao.watchTripById('t-stream-tripid-2');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((Trip? t) => t?.name == 'Old Trip Name'),
          predicate((Trip? t) => t?.name == 'New Trip Name'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.upsertTrip(TripsCompanion.insert(
        id: 't-stream-tripid-2',
        name: 'New Trip Name',
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 删除 trip 后流应发出 null（Trips 表无软删除，物理删除）', () async {
      final now = DateTime.now();
      await travelDao.upsertTrip(TripsCompanion.insert(
        id: 't-stream-tripid-3',
        name: 'To Delete Trip',
        createdAt: now,
        updatedAt: now,
      ));
      final stream = travelDao.watchTripById('t-stream-tripid-3');
      final future = expectLater(
        stream,
        emitsInOrder([
          isNotNull,
          isNull,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      // Trips 表没有软删除字段，直接物理删除以验证 Stream 可靠性
      await (db.delete(db.trips)
            ..where((t) => t.id.equals('t-stream-tripid-3')))
          .go();
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });
  });

  group('TravelDao Stream Reliability - watchTripsOnly（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await travelDao.watchTripsOnly().first;
      expect(result, isEmpty);
    });

    test('B: 插入 trip 后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      final stream = travelDao.watchTripsOnly();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-tripsonly-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-tripsonly-1',
        tripId: 't-stream-trip-tripsonly-1',
        title: const Value('TripsOnly Test'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新 trip 后流应发出新值', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-tripsonly-2',
        tripId: 't-stream-trip-tripsonly-2',
        title: const Value('Old TripsOnly'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = travelDao.watchTripsOnly();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<TravelRecord> list) =>
              list.firstWhere((r) => r.id == 't-stream-tripsonly-2').title ==
              'Old TripsOnly'),
          predicate((List<TravelRecord> list) =>
              list.firstWhere((r) => r.id == 't-stream-tripsonly-2').title ==
              'New TripsOnly'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-tripsonly-2',
        tripId: 't-stream-trip-tripsonly-2',
        title: const Value('New TripsOnly'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除 trip 后流应发出空列表', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-tripsonly-3',
        tripId: 't-stream-trip-tripsonly-3',
        title: const Value('To Delete TripsOnly'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = travelDao.watchTripsOnly();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<TravelRecord> list) =>
              list.any((r) => r.id == 't-stream-tripsonly-3')),
          predicate((List<TravelRecord> list) =>
              !list.any((r) => r.id == 't-stream-tripsonly-3')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await travelDao.softDeleteById('t-stream-tripsonly-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: journal 记录不应出现在 trips 列表中（isJournal 边界）', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-tripsonly-journal',
        tripId: 't-stream-trip-tripsonly-journal',
        title: const Value('Journal Not Trip'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isJournal: const Value(true),
      ));
      final result = await travelDao.watchTripsOnly().first;
      expect(result.any((r) => r.id == 't-stream-tripsonly-journal'), isFalse);
    });

    test('边界2: 软删除的 trip 不应出现在 trips 列表中', () async {
      final now = DateTime.now();
      await travelDao.upsert(TravelRecordsCompanion.insert(
        id: 't-stream-tripsonly-deleted',
        tripId: 't-stream-trip-tripsonly-deleted',
        title: const Value('Deleted Trip'),
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await travelDao.softDeleteById('t-stream-tripsonly-deleted', now: now);
      final result = await travelDao.watchTripsOnly().first;
      expect(result.any((r) => r.id == 't-stream-tripsonly-deleted'), isFalse);
    });
  });
}
