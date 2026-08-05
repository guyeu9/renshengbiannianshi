import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late MomentDao momentDao;

  setUp(() async {
    db = createTestDatabase();
    momentDao = MomentDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('MomentDao CRUD Operations', () {
    test('should insert a moment record', () async {
      final record = MomentRecordsCompanion.insert(
        id: 'test-moment-1',
        mood: '开心',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await momentDao.upsert(record);

      final found = await momentDao.findById('test-moment-1');
      expect(found, isNotNull);
      expect(found!.mood, equals('开心'));
    });

    test('should update an existing moment record', () async {
      final record = MomentRecordsCompanion.insert(
        id: 'test-moment-2',
        mood: '开心',
        content: const Value('Original content'),
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await momentDao.upsert(record);

      final updatedRecord = MomentRecordsCompanion.insert(
        id: 'test-moment-2',
        mood: '平静',
        content: const Value('Updated content'),
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await momentDao.upsert(updatedRecord);

      final found = await momentDao.findById('test-moment-2');
      expect(found!.mood, equals('平静'));
      expect(found.content, equals('Updated content'));
    });

    test('should soft delete a moment record', () async {
      final record = MomentRecordsCompanion.insert(
        id: 'test-moment-3',
        mood: '开心',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await momentDao.upsert(record);
      await momentDao.softDeleteById('test-moment-3', now: DateTime.now());

      final found = await momentDao.findById('test-moment-3');
      expect(found!.isDeleted, isTrue);
    });

    test('should return null for non-existent record', () async {
      final found = await momentDao.findById('non-existent-id');
      expect(found, isNull);
    });
  });

  group('MomentDao Favorite Operations', () {
    test('should update favorite status', () async {
      final record = MomentRecordsCompanion.insert(
        id: 'test-moment-fav-1',
        mood: '开心',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await momentDao.upsert(record);
      await momentDao.updateFavorite('test-moment-fav-1', isFavorite: true, now: DateTime.now());

      final found = await momentDao.findById('test-moment-fav-1');
      expect(found!.isFavorite, isTrue);
    });
  });

  group('MomentDao Watch Operations', () {
    test('should watch all active records', () async {
      final record1 = MomentRecordsCompanion.insert(
        id: 'watch-moment-1',
        mood: '开心',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final record2 = MomentRecordsCompanion.insert(
        id: 'watch-moment-2',
        mood: '平静',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await momentDao.upsert(record1);
      await momentDao.upsert(record2);

      final records = await momentDao.watchAllActive().first;
      expect(records.length, greaterThanOrEqualTo(2));
    });

    test('should watch record by id', () async {
      final record = MomentRecordsCompanion.insert(
        id: 'watch-moment-3',
        mood: '开心',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await momentDao.upsert(record);

      final watched = await momentDao.watchById('watch-moment-3').first;
      expect(watched, isNotNull);
      expect(watched!.mood, equals('开心'));
    });

    test('should not return soft deleted records in watchAllActive', () async {
      final record1 = MomentRecordsCompanion.insert(
        id: 'watch-moment-4',
        mood: '开心',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final record2 = MomentRecordsCompanion.insert(
        id: 'watch-moment-5',
        mood: '平静',
        recordDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await momentDao.upsert(record1);
      await momentDao.upsert(record2);
      await momentDao.softDeleteById('watch-moment-5', now: DateTime.now());

      final records = await momentDao.watchAllActive().first;
      final deletedRecord = records.where((r) => r.id == 'watch-moment-5').firstOrNull;
      expect(deletedRecord, isNull);
    });
  });

  group('MomentDao Date Range Query', () {
    test('should filter by record date range', () async {
      final now = DateTime.now();
      final record1 = MomentRecordsCompanion.insert(
        id: 'date-moment-1',
        mood: '开心',
        recordDate: now.subtract(const Duration(days: 5)),
        createdAt: now,
        updatedAt: now,
      );
      final record2 = MomentRecordsCompanion.insert(
        id: 'date-moment-2',
        mood: '平静',
        recordDate: now.subtract(const Duration(days: 1)),
        createdAt: now,
        updatedAt: now,
      );

      await momentDao.upsert(record1);
      await momentDao.upsert(record2);

      final start = now.subtract(const Duration(days: 3));
      final end = now;
      final records = await momentDao.watchByRecordDateRange(start, end).first;

      expect(records.any((r) => r.id == 'date-moment-2'), isTrue);
      expect(records.any((r) => r.id == 'date-moment-1'), isFalse);
    });
  });

  // === 修复点 B1: softDeleteById 完整行为测试 ===
  group('MomentDao softDeleteById complete behavior', () {
    test('should mark moment record as deleted', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'softdel-moment-1',
        mood: '开心',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));

      await momentDao.softDeleteById('softdel-moment-1', now: now);

      final found = await momentDao.findById('softdel-moment-1');
      expect(found, isNotNull);
      expect(found!.isDeleted, isTrue);
    });

    test('should delete entityLinks where moment is source', () async {
      final now = DateTime.now();
      const momentId = 'softdel-moment-2';
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: momentId,
        mood: '开心',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));

      await db.into(db.entityLinks).insert(EntityLinksCompanion.insert(
        id: 'link-src-1',
        sourceType: 'moment',
        sourceId: momentId,
        targetType: 'friend',
        targetId: 'friend-x',
        linkType: const Value('manual'),
        createdAt: now,
      ));

      await momentDao.softDeleteById(momentId, now: now);

      final remaining = await (db.select(db.entityLinks)
            ..where((t) => t.sourceType.equals('moment'))
            ..where((t) => t.sourceId.equals(momentId)))
          .get();
      expect(remaining, isEmpty);
    });

    test('should delete entityLinks where moment is target', () async {
      final now = DateTime.now();
      const momentId = 'softdel-moment-3';
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: momentId,
        mood: '开心',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));

      await db.into(db.entityLinks).insert(EntityLinksCompanion.insert(
        id: 'link-tgt-1',
        sourceType: 'goal',
        sourceId: 'goal-x',
        targetType: 'moment',
        targetId: momentId,
        linkType: const Value('manual'),
        createdAt: now,
      ));

      await momentDao.softDeleteById(momentId, now: now);

      final remaining = await (db.select(db.entityLinks)
            ..where((t) => t.targetType.equals('moment'))
            ..where((t) => t.targetId.equals(momentId)))
          .get();
      expect(remaining, isEmpty);
    });

    test('should not affect other entities\' links', () async {
      final now = DateTime.now();
      const momentId = 'softdel-moment-4';
      const otherMomentId = 'softdel-moment-5';
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: momentId,
        mood: '开心',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: otherMomentId,
        mood: '平静',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));

      await db.into(db.entityLinks).insert(EntityLinksCompanion.insert(
        id: 'link-other-1',
        sourceType: 'moment',
        sourceId: otherMomentId,
        targetType: 'friend',
        targetId: 'friend-y',
        linkType: const Value('manual'),
        createdAt: now,
      ));

      await momentDao.softDeleteById(momentId, now: now);

      final otherLinks = await (db.select(db.entityLinks)
            ..where((t) => t.sourceId.equals(otherMomentId)))
          .get();
      expect(otherLinks.length, equals(1));
      expect(otherLinks.first.id, equals('link-other-1'));
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('MomentDao Stream Reliability - watchById（0.1.160）', () {
    test('A: 初始状态（不存在的 id）应返回 null', () async {
      final result = await momentDao.watchById('non-existent').first;
      expect(result, isNull);
    });

    test('B: 插入数据后流应发出新值', () async {
      final now = DateTime.now();
      final stream = momentDao.watchById('m-stream-byid-1');
      final future = expectLater(
        stream,
        emitsInOrder([
          isNull,
          isNotNull,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-byid-1',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出新值', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-byid-2',
        mood: 'sad',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = momentDao.watchById('m-stream-byid-2');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((MomentRecord? r) => r?.mood == 'sad'),
          predicate((MomentRecord? r) => r?.mood == 'happy'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-byid-2',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除后流应发出 null（watchById 过滤 isDeleted）', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-byid-3',
        mood: 'calm',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = momentDao.watchById('m-stream-byid-3');
      final future = expectLater(
        stream,
        emitsInOrder([
          isNotNull,
          isNull,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await momentDao.softDeleteById('m-stream-byid-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 不存在的 id 应返回 null', () async {
      final result = await momentDao.watchById('').first;
      expect(result, isNull);
    });

    test('边界2: 软删除的记录应返回 null', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-byid-4',
        mood: 'angry',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await momentDao.softDeleteById('m-stream-byid-4', now: now);
      final result = await momentDao.watchById('m-stream-byid-4').first;
      expect(result, isNull);
    });
  });

  group('MomentDao Stream Reliability - watchAllActive（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await momentDao.watchAllActive().first;
      expect(result, isEmpty);
    });

    test('B: 插入数据后流应发出包含新记录的列表', () async {
      final now = DateTime.now();
      final stream = momentDao.watchAllActive();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<MomentRecord> list) => list.any((r) => r.id == 'm-stream-all-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-all-1',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出包含更新后记录的列表', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-all-2',
        mood: 'sad',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = momentDao.watchAllActive();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<MomentRecord> list) => list.firstWhere((r) => r.id == 'm-stream-all-2').mood == 'sad'),
          predicate((List<MomentRecord> list) => list.firstWhere((r) => r.id == 'm-stream-all-2').mood == 'happy'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-all-2',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除后流应发出不包含已删除记录的列表', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-all-3',
        mood: 'calm',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = momentDao.watchAllActive();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<MomentRecord> list) => list.any((r) => r.id == 'm-stream-all-3')),
          predicate((List<MomentRecord> list) => !list.any((r) => r.id == 'm-stream-all-3')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await momentDao.softDeleteById('m-stream-all-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 插入多条后应按 recordDate 降序排序', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-order-1',
        mood: 'sad',
        recordDate: now.subtract(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
      ));
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-order-2',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await momentDao.watchAllActive().first;
      expect(result.first.id, equals('m-stream-order-2'));
      expect(result.last.id, equals('m-stream-order-1'));
    });

    test('边界2: 软删除后再插入新记录应只返回活跃记录', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-mixed-1',
        mood: 'angry',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await momentDao.softDeleteById('m-stream-mixed-1', now: now);
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-mixed-2',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await momentDao.watchAllActive().first;
      expect(result.any((r) => r.id == 'm-stream-mixed-1'), isFalse);
      expect(result.any((r) => r.id == 'm-stream-mixed-2'), isTrue);
    });
  });

  group('MomentDao Stream Reliability - watchFavorites（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await momentDao.watchFavorites().first;
      expect(result, isEmpty);
    });

    test('B: 收藏后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-fav-1',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = momentDao.watchFavorites();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<MomentRecord> list) => list.any((r) => r.id == 'm-stream-fav-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await momentDao.updateFavorite('m-stream-fav-1', isFavorite: true, now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 取消收藏后流应发出空列表', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-fav-2',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
      ));
      final stream = momentDao.watchFavorites();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<MomentRecord> list) => list.any((r) => r.id == 'm-stream-fav-2')),
          isEmpty,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await momentDao.updateFavorite('m-stream-fav-2', isFavorite: false, now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除收藏记录后流应发出空列表', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-fav-3',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
      ));
      final stream = momentDao.watchFavorites();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<MomentRecord> list) => list.any((r) => r.id == 'm-stream-fav-3')),
          isEmpty,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await momentDao.softDeleteById('m-stream-fav-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 未收藏的记录不应出现在收藏列表中', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-fav-4',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await momentDao.watchFavorites().first;
      expect(result.any((r) => r.id == 'm-stream-fav-4'), isFalse);
    });

    test('边界2: 多条收藏记录切换状态后流应正确反映', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-fav-5',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
      ));
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-fav-6',
        mood: 'calm',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
      ));
      final stream = momentDao.watchFavorites();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<MomentRecord> list) => list.length == 2),
          predicate((List<MomentRecord> list) => list.length == 1 && list.first.id == 'm-stream-fav-6'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await momentDao.updateFavorite('m-stream-fav-5', isFavorite: false, now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });
  });

  group('MomentDao Stream Reliability - watchByRecordDateRange（0.1.160 边界参数全覆盖）', () {
    test('A: 初始状态应返回空列表', () async {
      final now = DateTime.now();
      final result = await momentDao.watchByRecordDateRange(now, now.add(const Duration(days: 1))).first;
      expect(result, isEmpty);
    });

    test('B: 插入范围内记录后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      final recordDate = now.add(const Duration(hours: 12));
      final stream = momentDao.watchByRecordDateRange(now, now.add(const Duration(days: 1)));
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<MomentRecord> list) => list.any((r) => r.id == 'm-stream-range-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-range-1',
        mood: 'happy',
        recordDate: recordDate,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 空范围（start == end）应返回空列表', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-empty-range',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await momentDao.watchByRecordDateRange(now, now).first;
      expect(result, isEmpty);
    });

    test('边界2: 单点范围（start == recordDate, end == start+1s）应包含该记录', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-single-point',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await momentDao.watchByRecordDateRange(now, now.add(const Duration(seconds: 1))).first;
      expect(result.any((r) => r.id == 'm-stream-single-point'), isTrue);
    });

    test('边界3: 跨年范围应包含跨年记录', () async {
      final dec31 = DateTime(2025, 12, 31);
      final jan1 = DateTime(2026, 1, 1);
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-cross-year',
        mood: 'excited',
        recordDate: jan1,
        createdAt: jan1,
        updatedAt: jan1,
      ));
      final result = await momentDao.watchByRecordDateRange(dec31, jan1.add(const Duration(days: 1))).first;
      expect(result.any((r) => r.id == 'm-stream-cross-year'), isTrue);
    });

    test('边界4: 未来日期范围应不包含过去记录', () async {
      final now = DateTime.now();
      final futureStart = now.add(const Duration(days: 10));
      final futureEnd = now.add(const Duration(days: 20));
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-past-record',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await momentDao.watchByRecordDateRange(futureStart, futureEnd).first;
      expect(result, isEmpty);
    });

    test('边界5: recordDate == start 应包含（isBiggerOrEqualValue）', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-boundary-start',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await momentDao.watchByRecordDateRange(now, now.add(const Duration(days: 1))).first;
      expect(result.any((r) => r.id == 'm-stream-boundary-start'), isTrue);
    });

    test('边界6: recordDate == end 应不包含（isSmallerThanValue）', () async {
      final now = DateTime.now();
      final end = now.add(const Duration(days: 1));
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-boundary-end',
        mood: 'happy',
        recordDate: end,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await momentDao.watchByRecordDateRange(now, end).first;
      expect(result.any((r) => r.id == 'm-stream-boundary-end'), isFalse);
    });

    test('边界7: 软删除的记录不应出现在范围内', () async {
      final now = DateTime.now();
      await momentDao.upsert(MomentRecordsCompanion.insert(
        id: 'm-stream-range-deleted',
        mood: 'happy',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await momentDao.softDeleteById('m-stream-range-deleted', now: now);
      final result = await momentDao.watchByRecordDateRange(now.subtract(const Duration(days: 1)), now.add(const Duration(days: 1))).first;
      expect(result.any((r) => r.id == 'm-stream-range-deleted'), isFalse);
    });
  });
}
