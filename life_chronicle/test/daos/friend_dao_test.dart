import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late FriendDao friendDao;

  setUp(() async {
    db = createTestDatabase();
    friendDao = FriendDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('FriendDao CRUD Operations', () {
    test('should insert a friend record', () async {
      final record = FriendRecordsCompanion.insert(
        id: 'test-friend-1',
        name: 'Test Friend',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await friendDao.upsert(record);

      final found = await friendDao.findById('test-friend-1');
      expect(found, isNotNull);
      expect(found!.name, equals('Test Friend'));
    });

    test('should update an existing friend record', () async {
      final record = FriendRecordsCompanion.insert(
        id: 'test-friend-2',
        name: 'Original Name',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await friendDao.upsert(record);

      final updatedRecord = FriendRecordsCompanion.insert(
        id: 'test-friend-2',
        name: 'Updated Name',
        groupName: const Value('家人'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await friendDao.upsert(updatedRecord);

      final found = await friendDao.findById('test-friend-2');
      expect(found!.name, equals('Updated Name'));
      expect(found.groupName, equals('家人'));
    });

    test('should soft delete a friend record', () async {
      final record = FriendRecordsCompanion.insert(
        id: 'test-friend-3',
        name: 'To Be Deleted',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await friendDao.upsert(record);
      await friendDao.softDeleteById('test-friend-3', now: DateTime.now());

      final found = await friendDao.findById('test-friend-3');
      expect(found!.isDeleted, isTrue);
    });

    test('should return null for non-existent record', () async {
      final found = await friendDao.findById('non-existent-id');
      expect(found, isNull);
    });
  });

  group('FriendDao Favorite Operations', () {
    test('should update favorite status', () async {
      final record = FriendRecordsCompanion.insert(
        id: 'test-friend-fav-1',
        name: 'Favorite Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await friendDao.upsert(record);
      await friendDao.updateFavorite('test-friend-fav-1', isFavorite: true, now: DateTime.now());

      final found = await friendDao.findById('test-friend-fav-1');
      expect(found!.isFavorite, isTrue);
    });

    test('should toggle favorite status', () async {
      final record = FriendRecordsCompanion.insert(
        id: 'test-friend-fav-2',
        name: 'Toggle Favorite',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await friendDao.upsert(record);
      
      await friendDao.updateFavorite('test-friend-fav-2', isFavorite: true, now: DateTime.now());
      var found = await friendDao.findById('test-friend-fav-2');
      expect(found!.isFavorite, isTrue);

      await friendDao.updateFavorite('test-friend-fav-2', isFavorite: false, now: DateTime.now());
      found = await friendDao.findById('test-friend-fav-2');
      expect(found!.isFavorite, isFalse);
    });
  });

  group('FriendDao Watch Operations', () {
    test('should watch all active records', () async {
      final record1 = FriendRecordsCompanion.insert(
        id: 'watch-friend-1',
        name: 'Friend 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final record2 = FriendRecordsCompanion.insert(
        id: 'watch-friend-2',
        name: 'Friend 2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await friendDao.upsert(record1);
      await friendDao.upsert(record2);

      final records = await friendDao.watchAllActive().first;
      expect(records.length, greaterThanOrEqualTo(2));
    });

    test('should watch record by id', () async {
      final record = FriendRecordsCompanion.insert(
        id: 'watch-friend-3',
        name: 'Watch Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await friendDao.upsert(record);

      final watched = await friendDao.watchById('watch-friend-3').first;
      expect(watched, isNotNull);
      expect(watched!.name, equals('Watch Test'));
    });

    test('should not return soft deleted records in watchAllActive', () async {
      final record1 = FriendRecordsCompanion.insert(
        id: 'watch-friend-4',
        name: 'Active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final record2 = FriendRecordsCompanion.insert(
        id: 'watch-friend-5',
        name: 'Deleted',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await friendDao.upsert(record1);
      await friendDao.upsert(record2);
      await friendDao.softDeleteById('watch-friend-5', now: DateTime.now());

      final records = await friendDao.watchAllActive().first;
      final deletedRecord = records.where((r) => r.id == 'watch-friend-5').firstOrNull;
      expect(deletedRecord, isNull);
    });
  });

  group('FriendDao Group Operations', () {
    test('should store group name correctly', () async {
      final record = FriendRecordsCompanion.insert(
        id: 'group-friend-1',
        name: 'Group Test',
        groupName: const Value('家人'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await friendDao.upsert(record);

      final found = await friendDao.findById('group-friend-1');
      expect(found!.groupName, equals('家人'));
    });

    test('should store impression tags correctly', () async {
      final record = FriendRecordsCompanion.insert(
        id: 'tags-friend-1',
        name: 'Tags Test',
        impressionTags: const Value('["幽默", "聪明", "靠谱"]'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await friendDao.upsert(record);

      final found = await friendDao.findById('tags-friend-1');
      expect(found!.impressionTags, isNotNull);
    });
  });

  group('FriendDao updateFavorite ChangeLog（修复点：收藏操作记录变更日志）', () {
    test('updateFavorite 记录 ChangeLog（changedFields 包含 isFavorite）', () async {
      await friendDao.upsert(FriendRecordsCompanion.insert(
        id: 'changelog-fav-1',
        name: 'ChangeLog Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await friendDao.updateFavorite('changelog-fav-1', isFavorite: true, now: DateTime.now());

      final logs = await (db.select(db.changeLogs)
            ..where((t) => t.entityType.equals('friend_records'))
            ..where((t) => t.entityId.equals('changelog-fav-1'))
            ..where((t) => t.action.equals('update')))
          .get();

      expect(logs, isNotEmpty, reason: '应该记录一条 update 类型的 ChangeLog');
      expect(logs.first.changedFields, isNotNull);
      expect(logs.first.changedFields, contains('isFavorite'));
    });

    test('多次切换收藏状态，每次都记录 ChangeLog', () async {
      await friendDao.upsert(FriendRecordsCompanion.insert(
        id: 'changelog-fav-2',
        name: 'Multi Toggle',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      final now = DateTime.now();

      await friendDao.updateFavorite('changelog-fav-2', isFavorite: true, now: now);
      await friendDao.updateFavorite('changelog-fav-2', isFavorite: false, now: now);
      await friendDao.updateFavorite('changelog-fav-2', isFavorite: true, now: now);

      final logs = await (db.select(db.changeLogs)
            ..where((t) => t.entityType.equals('friend_records'))
            ..where((t) => t.entityId.equals('changelog-fav-2'))
            ..where((t) => t.action.equals('update')))
          .get();

      expect(logs.length, equals(3), reason: '三次切换应记录三条 ChangeLog');
    });

    test('updateFavorite 刷新 updatedAt 时间戳', () async {
      await friendDao.upsert(FriendRecordsCompanion.insert(
        id: 'changelog-fav-3',
        name: 'Timestamp Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      final original = await friendDao.findById('changelog-fav-3');
      final updateTime = DateTime(2026, 8, 5, 12, 0, 0);

      await friendDao.updateFavorite('changelog-fav-3', isFavorite: true, now: updateTime);

      final found = await friendDao.findById('changelog-fav-3');
      expect(found!.updatedAt, equals(updateTime));
      expect(found.updatedAt, isNot(equals(original!.updatedAt)));
    });
  });

  group('FriendDao watchFavorites（收藏列表查询）', () {
    test('只返回 isFavorite=true 且 isDeleted=false 的记录', () async {
      await friendDao.upsert(FriendRecordsCompanion.insert(
        id: 'watch-fav-1',
        name: '已收藏',
        isFavorite: const Value(true),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await friendDao.upsert(FriendRecordsCompanion.insert(
        id: 'watch-fav-2',
        name: '未收藏',
        isFavorite: const Value(false),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await friendDao.upsert(FriendRecordsCompanion.insert(
        id: 'watch-fav-3',
        name: '已收藏但已删除',
        isFavorite: const Value(true),
        isDeleted: const Value(true),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final favorites = await friendDao.watchFavorites().first;
      final ids = favorites.map((f) => f.id).toList();

      expect(ids, contains('watch-fav-1'));
      expect(ids, isNot(contains('watch-fav-2')));
      expect(ids, isNot(contains('watch-fav-3')));
    });

    test('软删除后不再出现在收藏列表中', () async {
      await friendDao.upsert(FriendRecordsCompanion.insert(
        id: 'watch-fav-4',
        name: '将被软删除的收藏',
        isFavorite: const Value(true),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // 确认初始在收藏列表中
      var favorites = await friendDao.watchFavorites().first;
      expect(favorites.any((f) => f.id == 'watch-fav-4'), isTrue);

      // 软删除
      await friendDao.softDeleteById('watch-fav-4', now: DateTime.now());

      // 确认不再在收藏列表中
      favorites = await friendDao.watchFavorites().first;
      expect(favorites.any((f) => f.id == 'watch-fav-4'), isFalse);
    });

    test('updateFavorite 后 watchFavorites 实时反映变化', () async {
      await friendDao.upsert(FriendRecordsCompanion.insert(
        id: 'watch-fav-5',
        name: '将收藏',
        isFavorite: const Value(false),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // 初始不在收藏列表
      var favorites = await friendDao.watchFavorites().first;
      expect(favorites.any((f) => f.id == 'watch-fav-5'), isFalse);

      // 收藏
      await friendDao.updateFavorite('watch-fav-5', isFavorite: true, now: DateTime.now());

      // 确认在收藏列表中
      favorites = await friendDao.watchFavorites().first;
      expect(favorites.any((f) => f.id == 'watch-fav-5'), isTrue);
    });
  });

  group('FriendDao softDeleteById 级联清理', () {
    test('软删除后 isDeleted=true 且 watchById 返回 null（过滤已删除）', () async {
      await friendDao.upsert(FriendRecordsCompanion.insert(
        id: 'soft-del-1',
        name: 'Soft Delete Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await friendDao.softDeleteById('soft-del-1', now: DateTime.now());

      // findById 不过滤 isDeleted，仍可查到
      final found = await friendDao.findById('soft-del-1');
      expect(found, isNotNull);
      expect(found!.isDeleted, isTrue, reason: '软删除后 isDeleted 应为 true');

      // watchById 过滤 isDeleted，返回 null
      final watched = await friendDao.watchById('soft-del-1').first;
      expect(watched, isNull, reason: 'watchById 过滤 isDeleted，应返回 null');
    });

    test('软删除后 watchAllActive 不返回该记录', () async {
      await friendDao.upsert(FriendRecordsCompanion.insert(
        id: 'soft-del-2',
        name: 'Will Be Deleted',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await friendDao.softDeleteById('soft-del-2', now: DateTime.now());

      final active = await friendDao.watchAllActive().first;
      expect(active.any((f) => f.id == 'soft-del-2'), isFalse,
          reason: '软删除后不应出现在 watchAllActive 中');
    });
  });
}
