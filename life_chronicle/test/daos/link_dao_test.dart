import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late LinkDao linkDao;

  setUp(() async {
    db = createTestDatabase();
    linkDao = LinkDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('LinkDao Basic Operations', () {
    test('should check if link exists', () async {
      expect(await linkDao.linkExists(
        sourceType: 'moment',
        sourceId: 'test-moment-1',
        targetType: 'food',
        targetId: 'test-food-1',
      ), isFalse);
    });

    test('should create a link and verify it exists', () async {
      final now = DateTime.now();
      
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-1',
        targetType: 'food',
        targetId: 'test-food-1',
        linkType: 'manual',
        now: now,
      );

      expect(await linkDao.linkExists(
        sourceType: 'moment',
        sourceId: 'test-moment-1',
        targetType: 'food',
        targetId: 'test-food-1',
      ), isTrue);
    });

    test('should delete a link and verify it does not exist', () async {
      final now = DateTime.now();
      
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-2',
        targetType: 'food',
        targetId: 'test-food-2',
        now: now,
      );

      await linkDao.deleteLink(
        sourceType: 'moment',
        sourceId: 'test-moment-2',
        targetType: 'food',
        targetId: 'test-food-2',
        now: now,
      );

      expect(await linkDao.linkExists(
        sourceType: 'moment',
        sourceId: 'test-moment-2',
        targetType: 'food',
        targetId: 'test-food-2',
      ), isFalse);
    });

    test('should delete links by source', () async {
      final now = DateTime.now();
      
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-3',
        targetType: 'food',
        targetId: 'test-food-3',
        now: now,
      );
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-3',
        targetType: 'travel',
        targetId: 'test-travel-3',
        now: now,
      );

      await linkDao.deleteLinksBySource('moment', 'test-moment-3');

      final links = await linkDao.listLinksForEntity(
        entityType: 'moment',
        entityId: 'test-moment-3',
      );
      expect(links.length, equals(0));
    });
  });

  group('LinkDao Query Operations', () {
    test('should list links for an entity', () async {
      final now = DateTime.now();
      
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-4',
        targetType: 'food',
        targetId: 'test-food-4',
        now: now,
      );

      final links = await linkDao.listLinksForEntity(
        entityType: 'moment',
        entityId: 'test-moment-4',
      );
      expect(links.length, equals(1));
      expect(links.first.targetType, equals('food'));
      expect(links.first.targetId, equals('test-food-4'));
    });

    test('should list links when entity is target', () async {
      final now = DateTime.now();
      
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-5',
        targetType: 'food',
        targetId: 'test-food-5',
        now: now,
      );

      final links = await linkDao.listLinksForEntity(
        entityType: 'food',
        entityId: 'test-food-5',
      );
      expect(links.length, equals(1));
      expect(links.first.sourceType, equals('moment'));
      expect(links.first.sourceId, equals('test-moment-5'));
    });
  });

  group('LinkDao Watch Operations', () {
    test('should watch links for an entity', () async {
      final now = DateTime.now();
      
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'watch-moment-1',
        targetType: 'food',
        targetId: 'watch-food-1',
        now: now,
      );

      final links = await linkDao.watchLinksForEntity(
        entityType: 'moment',
        entityId: 'watch-moment-1',
      ).first;
      expect(links.length, equals(1));
    });
  });

  group('LinkDao Idempotent Operations', () {
    test('should not create duplicate links', () async {
      final now = DateTime.now();
      
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-6',
        targetType: 'food',
        targetId: 'test-food-6',
        now: now,
      );
      await linkDao.createLink(
        sourceType: 'moment',
        sourceId: 'test-moment-6',
        targetType: 'food',
        targetId: 'test-food-6',
        now: now,
      );

      final links = await linkDao.listLinksForEntity(
        entityType: 'moment',
        entityId: 'test-moment-6',
      );
      expect(links.length, equals(1));
    });
  });
}
