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
}
