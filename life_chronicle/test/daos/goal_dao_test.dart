import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late GoalDao goalDao;

  setUp(() async {
    db = createTestDatabase();
    goalDao = GoalDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  /// 插入一条目标记录用于测试
  Future<GoalRecord> insertGoal({
    String id = 'test-goal-1',
    String title = '测试目标',
    bool isFavorite = false,
    bool isDeleted = false,
  }) async {
    final now = DateTime.now();
    final companion = GoalRecordsCompanion.insert(
      id: id,
      level: 'yearly',
      title: title,
      isFavorite: Value(isFavorite),
      isDeleted: Value(isDeleted),
      recordDate: now,
      createdAt: now,
      updatedAt: now,
    );
    await db.into(db.goalRecords).insert(companion);
    return (db.select(db.goalRecords)..where((t) => t.id.equals(id))).getSingle();
  }

  group('GoalDao.updateFavorite（修复点6：收藏操作改用 DAO 记录 ChangeLog）', () {
    test('从 false 改为 true，isFavorite 字段正确更新', () async {
      await insertGoal(id: 'fav-1', isFavorite: false);
      final now = DateTime.now();

      await goalDao.updateFavorite('fav-1', isFavorite: true, now: now);

      final found = await goalDao.findById('fav-1');
      expect(found, isNotNull);
      expect(found!.isFavorite, isTrue);
    });

    test('从 true 改为 false，isFavorite 字段正确更新', () async {
      await insertGoal(id: 'fav-2', isFavorite: true);
      final now = DateTime.now();

      await goalDao.updateFavorite('fav-2', isFavorite: false, now: now);

      final found = await goalDao.findById('fav-2');
      expect(found, isNotNull);
      expect(found!.isFavorite, isFalse);
    });

    test('更新后 updatedAt 时间戳被刷新', () async {
      await insertGoal(id: 'fav-3', isFavorite: false);
      final original = await goalDao.findById('fav-3');
      final updateTime = DateTime(2026, 8, 5, 12, 0, 0);

      await goalDao.updateFavorite('fav-3', isFavorite: true, now: updateTime);

      final found = await goalDao.findById('fav-3');
      expect(found, isNotNull);
      expect(found!.updatedAt, equals(updateTime));
      expect(found.updatedAt, isNot(equals(original!.updatedAt)));
    });

    test('记录 ChangeLog（changedFields 包含 isFavorite）', () async {
      await insertGoal(id: 'fav-4', isFavorite: false);
      final now = DateTime.now();

      await goalDao.updateFavorite('fav-4', isFavorite: true, now: now);

      final logs = await (db.select(db.changeLogs)
            ..where((t) => t.entityType.equals('goal_records'))
            ..where((t) => t.entityId.equals('fav-4'))
            ..where((t) => t.action.equals('update')))
          .get();

      expect(logs, isNotEmpty, reason: '应该记录一条 update 类型的 ChangeLog');
      final log = logs.first;
      expect(log.changedFields, isNotNull);
      expect(log.changedFields, contains('isFavorite'));
    });

    test('多次切换收藏状态，每次都记录 ChangeLog', () async {
      await insertGoal(id: 'fav-5', isFavorite: false);
      final now = DateTime.now();

      await goalDao.updateFavorite('fav-5', isFavorite: true, now: now);
      await goalDao.updateFavorite('fav-5', isFavorite: false, now: now);
      await goalDao.updateFavorite('fav-5', isFavorite: true, now: now);

      final logs = await (db.select(db.changeLogs)
            ..where((t) => t.entityType.equals('goal_records'))
            ..where((t) => t.entityId.equals('fav-5'))
            ..where((t) => t.action.equals('update')))
          .get();

      expect(logs.length, equals(3), reason: '三次切换应记录三条 ChangeLog');
      for (final log in logs) {
        expect(log.changedFields, contains('isFavorite'));
      }
    });
  });

  group('GoalDao.watchFavorites（收藏列表查询）', () {
    test('只返回 isFavorite=true 且 isDeleted=false 的记录', () async {
      await insertGoal(id: 'watch-1', title: '已收藏', isFavorite: true);
      await insertGoal(id: 'watch-2', title: '未收藏', isFavorite: false);
      await insertGoal(id: 'watch-3', title: '已收藏但已删除', isFavorite: true, isDeleted: true);

      final favorites = await goalDao.watchFavorites().first;

      final ids = favorites.map((g) => g.id).toList();
      expect(ids, contains('watch-1'));
      expect(ids, isNot(contains('watch-2')));
      expect(ids, isNot(contains('watch-3')));
    });

    test('软删除后不再出现在收藏列表中', () async {
      await insertGoal(id: 'watch-4', title: '将被软删除的收藏', isFavorite: true);

      // 确认初始在收藏列表中
      var favorites = await goalDao.watchFavorites().first;
      expect(favorites.any((g) => g.id == 'watch-4'), isTrue);

      // 软删除
      await goalDao.softDeleteById('watch-4', now: DateTime.now());

      // 确认不再在收藏列表中
      favorites = await goalDao.watchFavorites().first;
      expect(favorites.any((g) => g.id == 'watch-4'), isFalse);
    });

    test('updateFavorite 后 watchFavorites 实时反映变化', () async {
      await insertGoal(id: 'watch-5', title: '将收藏', isFavorite: false);
      final now = DateTime.now();

      // 初始不在收藏列表
      var favorites = await goalDao.watchFavorites().first;
      expect(favorites.any((g) => g.id == 'watch-5'), isFalse);

      // 收藏
      await goalDao.updateFavorite('watch-5', isFavorite: true, now: now);

      // 确认在收藏列表中
      favorites = await goalDao.watchFavorites().first;
      expect(favorites.any((g) => g.id == 'watch-5'), isTrue);
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('GoalDao Stream Reliability - watchById（0.1.160）', () {
    test('A: 初始状态（不存在的 id）应返回 null', () async {
      final result = await goalDao.watchById('non-existent').first;
      expect(result, isNull);
    });

    test('B: 插入数据后流应发出新值', () async {
      final now = DateTime.now();
      final stream = goalDao.watchById('g-stream-byid-1');
      final future = expectLater(
        stream,
        emitsInOrder([isNull, isNotNull]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-byid-1',
        level: 'year',
        title: '年度目标',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出新值', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-byid-2',
        level: 'year',
        title: '旧标题',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = goalDao.watchById('g-stream-byid-2');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((GoalRecord? r) => r?.title == '旧标题'),
          predicate((GoalRecord? r) => r?.title == '新标题'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-byid-2',
        level: 'year',
        title: '新标题',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除后流应发出 null（watchById 过滤 isDeleted）', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-byid-3',
        level: 'year',
        title: '将删除',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = goalDao.watchById('g-stream-byid-3');
      final future = expectLater(
        stream,
        emitsInOrder([isNotNull, isNull]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.softDeleteById('g-stream-byid-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 不存在的 id 应返回 null', () async {
      final result = await goalDao.watchById('').first;
      expect(result, isNull);
    });

    test('边界2: 软删除的记录应返回 null', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-byid-4',
        level: 'year',
        title: '已删除',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await goalDao.softDeleteById('g-stream-byid-4', now: now);
      final result = await goalDao.watchById('g-stream-byid-4').first;
      expect(result, isNull);
    });
  });

  group('GoalDao Stream Reliability - watchAllActive（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await goalDao.watchAllActive().first;
      expect(result, isEmpty);
    });

    test('B: 插入数据后流应发出包含新记录的列表', () async {
      final now = DateTime.now();
      final stream = goalDao.watchAllActive();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<GoalRecord> list) => list.any((r) => r.id == 'g-stream-all-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-all-1',
        level: 'year',
        title: '目标',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出包含更新后记录的列表', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-all-2',
        level: 'year',
        title: '旧标题',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = goalDao.watchAllActive();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<GoalRecord> list) => list.firstWhere((r) => r.id == 'g-stream-all-2').title == '旧标题'),
          predicate((List<GoalRecord> list) => list.firstWhere((r) => r.id == 'g-stream-all-2').title == '新标题'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-all-2',
        level: 'year',
        title: '新标题',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除后流应发出不包含已删除记录的列表', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-all-3',
        level: 'year',
        title: '将删除',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = goalDao.watchAllActive();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<GoalRecord> list) => list.any((r) => r.id == 'g-stream-all-3')),
          predicate((List<GoalRecord> list) => !list.any((r) => r.id == 'g-stream-all-3')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.softDeleteById('g-stream-all-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 插入多条后应按 recordDate 降序排序', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-order-1',
        level: 'year',
        title: '旧',
        recordDate: now.subtract(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
      ));
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-order-2',
        level: 'year',
        title: '新',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await goalDao.watchAllActive().first;
      expect(result.first.id, equals('g-stream-order-2'));
      expect(result.last.id, equals('g-stream-order-1'));
    });

    test('边界2: 软删除后再插入新记录应只返回活跃记录', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-mixed-1',
        level: 'year',
        title: '将删除',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await goalDao.softDeleteById('g-stream-mixed-1', now: now);
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-mixed-2',
        level: 'year',
        title: '活跃',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await goalDao.watchAllActive().first;
      expect(result.any((r) => r.id == 'g-stream-mixed-1'), isFalse);
      expect(result.any((r) => r.id == 'g-stream-mixed-2'), isTrue);
    });
  });

  group('GoalDao Stream Reliability - watchFavorites（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await goalDao.watchFavorites().first;
      expect(result, isEmpty);
    });

    test('B: 收藏后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-fav-1',
        level: 'year',
        title: '目标',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = goalDao.watchFavorites();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<GoalRecord> list) => list.any((r) => r.id == 'g-stream-fav-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.updateFavorite('g-stream-fav-1', isFavorite: true, now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 取消收藏后流应发出空列表', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-fav-2',
        level: 'year',
        title: '目标',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
      ));
      final stream = goalDao.watchFavorites();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<GoalRecord> list) => list.any((r) => r.id == 'g-stream-fav-2')),
          isEmpty,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.updateFavorite('g-stream-fav-2', isFavorite: false, now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 软删除收藏记录后流应发出空列表', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-fav-3',
        level: 'year',
        title: '目标',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
      ));
      final stream = goalDao.watchFavorites();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<GoalRecord> list) => list.any((r) => r.id == 'g-stream-fav-3')),
          isEmpty,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.softDeleteById('g-stream-fav-3', now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 未收藏的记录不应出现在收藏列表中', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-fav-4',
        level: 'year',
        title: '未收藏',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await goalDao.watchFavorites().first;
      expect(result.any((r) => r.id == 'g-stream-fav-4'), isFalse);
    });

    test('边界2: 多条收藏记录切换状态后流应正确反映', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-fav-5',
        level: 'year',
        title: '收藏A',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
      ));
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-fav-6',
        level: 'year',
        title: '收藏B',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isFavorite: const Value(true),
      ));
      final stream = goalDao.watchFavorites();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<GoalRecord> list) => list.length == 2),
          predicate((List<GoalRecord> list) => list.length == 1 && list.first.id == 'g-stream-fav-6'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.updateFavorite('g-stream-fav-5', isFavorite: false, now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });
  });

  group('GoalDao Stream Reliability - watchUncompletedYearGoals（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await goalDao.watchUncompletedYearGoals().first;
      expect(result, isEmpty);
    });

    test('B: 插入未完成年目标后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      final stream = goalDao.watchUncompletedYearGoals();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<GoalRecord> list) => list.any((r) => r.id == 'g-stream-year-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-year-1',
        level: 'year',
        title: '年度目标',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 完成年目标后流应发出不包含该记录的列表', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-year-2',
        level: 'year',
        title: '将完成',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = goalDao.watchUncompletedYearGoals();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<GoalRecord> list) => list.any((r) => r.id == 'g-stream-year-2')),
          predicate((List<GoalRecord> list) => !list.any((r) => r.id == 'g-stream-year-2')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.updateCompletion('g-stream-year-2', isCompleted: true, now: now);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界2: 非 year level 的目标不应出现在列表中', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-year-3',
        level: 'quarter',
        title: '季度目标',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await goalDao.watchUncompletedYearGoals().first;
      expect(result.any((r) => r.id == 'g-stream-year-3'), isFalse);
    });

    test('边界3: 已完成的年目标不应出现在列表中', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-year-4',
        level: 'year',
        title: '已完成',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        isCompleted: const Value(true),
      ));
      final result = await goalDao.watchUncompletedYearGoals().first;
      expect(result.any((r) => r.id == 'g-stream-year-4'), isFalse);
    });

    test('边界4: 软删除的年目标不应出现在列表中', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-stream-year-5',
        level: 'year',
        title: '将删除',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await goalDao.softDeleteById('g-stream-year-5', now: now);
      final result = await goalDao.watchUncompletedYearGoals().first;
      expect(result.any((r) => r.id == 'g-stream-year-5'), isFalse);
    });
  });

  group('GoalDao Stream Reliability - watchByParentId（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await goalDao.watchByParentId('parent-1').first;
      expect(result, isEmpty);
    });

    test('B: 插入子目标后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      // 先插入父目标
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-parent-1',
        level: 'year',
        title: '父目标',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = goalDao.watchByParentId('g-parent-1');
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<GoalRecord> list) => list.any((r) => r.id == 'g-child-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-child-1',
        level: 'quarter',
        title: '子目标',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        parentId: const Value('g-parent-1'),
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 不存在子目标的 parentId 应返回空列表', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-orphan-1',
        level: 'year',
        title: '无父',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await goalDao.watchByParentId('non-existent-parent').first;
      expect(result, isEmpty);
    });

    test('边界2: 软删除的子目标不应出现在列表中', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-child-del-1',
        level: 'quarter',
        title: '将删除子目标',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
        parentId: const Value('g-parent-del'),
      ));
      await goalDao.softDeleteById('g-child-del-1', now: now);
      final result = await goalDao.watchByParentId('g-parent-del').first;
      expect(result.any((r) => r.id == 'g-child-del-1'), isFalse);
    });
  });

  group('GoalDao Stream Reliability - watchByLevel（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await goalDao.watchByLevel('year').first;
      expect(result, isEmpty);
    });

    test('B: 插入对应 level 目标后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      final stream = goalDao.watchByLevel('year');
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<GoalRecord> list) => list.any((r) => r.id == 'g-level-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-level-1',
        level: 'year',
        title: '年度',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 不同 level 的目标不应出现在列表中', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-level-2',
        level: 'quarter',
        title: '季度',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await goalDao.watchByLevel('year').first;
      expect(result.any((r) => r.id == 'g-level-2'), isFalse);
    });

    test('边界2: 软删除的对应 level 目标不应出现在列表中', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-level-3',
        level: 'year',
        title: '将删除',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await goalDao.softDeleteById('g-level-3', now: now);
      final result = await goalDao.watchByLevel('year').first;
      expect(result.any((r) => r.id == 'g-level-3'), isFalse);
    });

    test('边界3: daily level 应正确查询', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-level-4',
        level: 'daily',
        title: '每日目标',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await goalDao.watchByLevel('daily').first;
      expect(result.any((r) => r.id == 'g-level-4'), isTrue);
    });
  });

  group('GoalDao Stream Reliability - watchByRecordDateRange（0.1.160 边界参数全覆盖）', () {
    test('A: 初始状态应返回空列表', () async {
      final now = DateTime.now();
      final result = await goalDao.watchByRecordDateRange(now, now.add(const Duration(days: 1))).first;
      expect(result, isEmpty);
    });

    test('B: 插入范围内记录后流应发出包含该记录的列表', () async {
      final now = DateTime.now();
      final recordDate = now.add(const Duration(hours: 12));
      final stream = goalDao.watchByRecordDateRange(now, now.add(const Duration(days: 1)));
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<GoalRecord> list) => list.any((r) => r.id == 'g-range-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-range-1',
        level: 'year',
        title: '范围内',
        recordDate: recordDate,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 空范围（start == end）应返回空列表', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-empty-range',
        level: 'year',
        title: '测试',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await goalDao.watchByRecordDateRange(now, now).first;
      expect(result, isEmpty);
    });

    test('边界2: 单点范围（start == recordDate, end == start+1s）应包含该记录', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-single-point',
        level: 'year',
        title: '精确开始',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await goalDao.watchByRecordDateRange(now, now.add(const Duration(seconds: 1))).first;
      expect(result.any((r) => r.id == 'g-single-point'), isTrue);
    });

    test('边界3: 跨年范围应包含跨年记录', () async {
      final dec31 = DateTime(2025, 12, 31);
      final jan1 = DateTime(2026, 1, 1);
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-cross-year',
        level: 'year',
        title: '新年',
        recordDate: jan1,
        createdAt: jan1,
        updatedAt: jan1,
      ));
      final result = await goalDao.watchByRecordDateRange(dec31, jan1.add(const Duration(days: 1))).first;
      expect(result.any((r) => r.id == 'g-cross-year'), isTrue);
    });

    test('边界4: 未来日期范围应不包含过去记录', () async {
      final now = DateTime.now();
      final futureStart = now.add(const Duration(days: 10));
      final futureEnd = now.add(const Duration(days: 20));
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-past-record',
        level: 'year',
        title: '过去',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await goalDao.watchByRecordDateRange(futureStart, futureEnd).first;
      expect(result, isEmpty);
    });

    test('边界5: recordDate == start 应包含（isBiggerOrEqualValue）', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-boundary-start',
        level: 'year',
        title: '开始边界',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await goalDao.watchByRecordDateRange(now, now.add(const Duration(days: 1))).first;
      expect(result.any((r) => r.id == 'g-boundary-start'), isTrue);
    });

    test('边界6: recordDate == end 应不包含（isSmallerThanValue）', () async {
      final now = DateTime.now();
      final end = now.add(const Duration(days: 1));
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-boundary-end',
        level: 'year',
        title: '结束边界',
        recordDate: end,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await goalDao.watchByRecordDateRange(now, end).first;
      expect(result.any((r) => r.id == 'g-boundary-end'), isFalse);
    });

    test('边界7: 软删除的记录不应出现在范围内', () async {
      final now = DateTime.now();
      await goalDao.upsert(GoalRecordsCompanion.insert(
        id: 'g-range-deleted',
        level: 'year',
        title: '范围内删除',
        recordDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await goalDao.softDeleteById('g-range-deleted', now: now);
      final result = await goalDao.watchByRecordDateRange(now.subtract(const Duration(days: 1)), now.add(const Duration(days: 1))).first;
      expect(result.any((r) => r.id == 'g-range-deleted'), isFalse);
    });
  });
}
