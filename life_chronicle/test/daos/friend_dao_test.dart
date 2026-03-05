import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/test/test_utils/test_utils.dart';

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
}
