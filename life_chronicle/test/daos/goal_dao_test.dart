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
  Future<GoalRecord> _insertGoal({
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
      await _insertGoal(id: 'fav-1', isFavorite: false);
      final now = DateTime.now();

      await goalDao.updateFavorite('fav-1', isFavorite: true, now: now);

      final found = await goalDao.findById('fav-1');
      expect(found, isNotNull);
      expect(found!.isFavorite, isTrue);
    });

    test('从 true 改为 false，isFavorite 字段正确更新', () async {
      await _insertGoal(id: 'fav-2', isFavorite: true);
      final now = DateTime.now();

      await goalDao.updateFavorite('fav-2', isFavorite: false, now: now);

      final found = await goalDao.findById('fav-2');
      expect(found, isNotNull);
      expect(found!.isFavorite, isFalse);
    });

    test('更新后 updatedAt 时间戳被刷新', () async {
      await _insertGoal(id: 'fav-3', isFavorite: false);
      final original = await goalDao.findById('fav-3');
      final updateTime = DateTime(2026, 8, 5, 12, 0, 0);

      await goalDao.updateFavorite('fav-3', isFavorite: true, now: updateTime);

      final found = await goalDao.findById('fav-3');
      expect(found, isNotNull);
      expect(found!.updatedAt, equals(updateTime));
      expect(found.updatedAt, isNot(equals(original!.updatedAt)));
    });

    test('记录 ChangeLog（changedFields 包含 isFavorite）', () async {
      await _insertGoal(id: 'fav-4', isFavorite: false);
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
      await _insertGoal(id: 'fav-5', isFavorite: false);
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
      await _insertGoal(id: 'watch-1', title: '已收藏', isFavorite: true);
      await _insertGoal(id: 'watch-2', title: '未收藏', isFavorite: false);
      await _insertGoal(id: 'watch-3', title: '已收藏但已删除', isFavorite: true, isDeleted: true);

      final favorites = await goalDao.watchFavorites().first;

      final ids = favorites.map((g) => g.id).toList();
      expect(ids, contains('watch-1'));
      expect(ids, isNot(contains('watch-2')));
      expect(ids, isNot(contains('watch-3')));
    });

    test('软删除后不再出现在收藏列表中', () async {
      await _insertGoal(id: 'watch-4', title: '将被软删除的收藏', isFavorite: true);

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
      await _insertGoal(id: 'watch-5', title: '将收藏', isFavorite: false);
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
}
