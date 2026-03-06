import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late ChecklistDao checklistDao;

  setUp(() async {
    db = createTestDatabase();
    checklistDao = ChecklistDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('ChecklistDao CRUD Operations', () {
    test('should insert a checklist item', () async {
      final now = DateTime.now();
      final entry = ChecklistItemsCompanion.insert(
        id: 'test-item-1',
        tripId: 'test-trip-1',
        title: 'Test Item',
        createdAt: now,
        updatedAt: now,
      );

      await checklistDao.insert(entry);

      final found = await checklistDao.findById('test-item-1');
      expect(found, isNotNull);
      expect(found!.title, equals('Test Item'));
    });

    test('should upsert a checklist item', () async {
      final now = DateTime.now();
      final entry = ChecklistItemsCompanion.insert(
        id: 'test-item-2',
        tripId: 'test-trip-1',
        title: 'Old Title',
        createdAt: now,
        updatedAt: now,
      );

      await checklistDao.upsert(entry);

      final updatedEntry = ChecklistItemsCompanion.insert(
        id: 'test-item-2',
        tripId: 'test-trip-1',
        title: 'New Title',
        createdAt: now,
        updatedAt: now,
      );

      await checklistDao.upsert(updatedEntry);

      final found = await checklistDao.findById('test-item-2');
      expect(found!.title, equals('New Title'));
    });

    test('should update done status', () async {
      final now = DateTime.now();
      final entry = ChecklistItemsCompanion.insert(
        id: 'test-item-3',
        tripId: 'test-trip-1',
        title: 'Test Item',
        createdAt: now,
        updatedAt: now,
      );

      await checklistDao.insert(entry);
      await checklistDao.updateDone('test-item-3', isDone: true, now: now);

      final found = await checklistDao.findById('test-item-3');
      expect(found!.isDone, isTrue);
    });

    test('should update item title and note', () async {
      final now = DateTime.now();
      final entry = ChecklistItemsCompanion.insert(
        id: 'test-item-4',
        tripId: 'test-trip-1',
        title: 'Old Title',
        note: const Value('Old Note'),
        createdAt: now,
        updatedAt: now,
      );

      await checklistDao.insert(entry);
      await checklistDao.updateItem('test-item-4', title: 'New Title', note: 'New Note', now: now);

      final found = await checklistDao.findById('test-item-4');
      expect(found!.title, equals('New Title'));
      expect(found.note, equals('New Note'));
    });

    test('should delete a checklist item by id', () async {
      final now = DateTime.now();
      final entry = ChecklistItemsCompanion.insert(
        id: 'test-item-5',
        tripId: 'test-trip-1',
        title: 'Test Item',
        createdAt: now,
        updatedAt: now,
      );

      await checklistDao.insert(entry);
      await checklistDao.deleteById('test-item-5');

      final found = await checklistDao.findById('test-item-5');
      expect(found, isNull);
    });

    test('should delete all checklist items by trip id', () async {
      final now = DateTime.now();
      await checklistDao.insert(ChecklistItemsCompanion.insert(
        id: 'test-item-6',
        tripId: 'test-trip-2',
        title: 'Item 1',
        createdAt: now,
        updatedAt: now,
      ));
      await checklistDao.insert(ChecklistItemsCompanion.insert(
        id: 'test-item-7',
        tripId: 'test-trip-2',
        title: 'Item 2',
        createdAt: now,
        updatedAt: now,
      ));
      await checklistDao.insert(ChecklistItemsCompanion.insert(
        id: 'test-item-8',
        tripId: 'test-trip-3',
        title: 'Item 3',
        createdAt: now,
        updatedAt: now,
      ));

      await checklistDao.deleteByTripId('test-trip-2');

      final items1 = await checklistDao.listByTripId('test-trip-2');
      final items2 = await checklistDao.listByTripId('test-trip-3');

      expect(items1.length, equals(0));
      expect(items2.length, equals(1));
    });
  });

  group('ChecklistDao Query Operations', () {
    test('should list checklist items by trip id in order', () async {
      final now = DateTime.now();
      await checklistDao.insert(ChecklistItemsCompanion.insert(
        id: 'test-item-9',
        tripId: 'test-trip-4',
        title: 'Item 1',
        orderIndex: const Value(2),
        createdAt: now,
        updatedAt: now,
      ));
      await checklistDao.insert(ChecklistItemsCompanion.insert(
        id: 'test-item-10',
        tripId: 'test-trip-4',
        title: 'Item 2',
        orderIndex: const Value(1),
        createdAt: now,
        updatedAt: now,
      ));

      final items = await checklistDao.listByTripId('test-trip-4');
      expect(items.length, equals(2));
      expect(items[0].orderIndex, lessThanOrEqualTo(items[1].orderIndex));
    });
  });

  group('ChecklistDao Watch Operations', () {
    test('should watch checklist items by trip id', () async {
      final now = DateTime.now();
      await checklistDao.insert(ChecklistItemsCompanion.insert(
        id: 'watch-item-1',
        tripId: 'watch-trip-1',
        title: 'Watch Item',
        createdAt: now,
        updatedAt: now,
      ));

      final items = await checklistDao.watchByTripId('watch-trip-1').first;
      expect(items.length, equals(1));
      expect(items[0].title, equals('Watch Item'));
    });
  });
}
