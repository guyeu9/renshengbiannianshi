import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import '../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late ChronicleDao chronicleDao;

  setUp(() async {
    db = createTestDatabase();
    chronicleDao = ChronicleDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('ChronicleDao Stream Reliability - watchAll（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await chronicleDao.watchAll().first;
      expect(result, isEmpty);
    });

    test('B: 插入数据后流应发出包含新记录的列表', () async {
      final now = DateTime.now();
      final stream = chronicleDao.watchAll();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<Chronicle> list) =>
              list.any((c) => c.id == 'c-stream-all-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-all-1',
        title: 'Stream Test',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出包含更新后记录的列表', () async {
      final now = DateTime.now();
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-all-2',
        title: 'Old Title',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = chronicleDao.watchAll();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<Chronicle> list) =>
              list.firstWhere((c) => c.id == 'c-stream-all-2').title ==
              'Old Title'),
          predicate((List<Chronicle> list) =>
              list.firstWhere((c) => c.id == 'c-stream-all-2').title ==
              'New Title'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-all-2',
        title: 'New Title',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 物理删除后流应发出不包含该记录的列表', () async {
      final now = DateTime.now();
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-all-3',
        title: 'To Delete',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = chronicleDao.watchAll();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<Chronicle> list) =>
              list.any((c) => c.id == 'c-stream-all-3')),
          predicate((List<Chronicle> list) =>
              !list.any((c) => c.id == 'c-stream-all-3')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chronicleDao.deleteById('c-stream-all-3');
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 插入多条后应按 createdAt 降序排序', () async {
      final now = DateTime.now();
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-order-1',
        title: 'Old',
        startDate: now,
        endDate: now,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ));
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-order-2',
        title: 'New',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await chronicleDao.watchAll().first;
      expect(result.first.id, equals('c-stream-order-2'));
      expect(result.last.id, equals('c-stream-order-1'));
    });

    test('边界2: 物理删除后不返回该记录', () async {
      final now = DateTime.now();
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-del-1',
        title: 'Will Delete',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await chronicleDao.deleteById('c-stream-del-1');
      final result = await chronicleDao.watchAll().first;
      expect(result.any((c) => c.id == 'c-stream-del-1'), isFalse);
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('ChronicleDao Stream Reliability - watchFeatured（0.1.160）', () {
    test('A: 初始状态应返回空列表', () async {
      final result = await chronicleDao.watchFeatured().first;
      expect(result, isEmpty);
    });

    test('B: 插入 featured 数据后流应发出包含新记录的列表', () async {
      final now = DateTime.now();
      final stream = chronicleDao.watchFeatured();
      final future = expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          predicate((List<Chronicle> list) =>
              list.any((c) => c.id == 'c-stream-feat-1')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-feat-1',
        title: 'Featured',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
        isFeatured: const Value(true),
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新 featured 数据后流应发出更新后的列表', () async {
      final now = DateTime.now();
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-feat-2',
        title: 'Old Title',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
        isFeatured: const Value(true),
      ));
      final stream = chronicleDao.watchFeatured();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<Chronicle> list) =>
              list.firstWhere((c) => c.id == 'c-stream-feat-2').title ==
              'Old Title'),
          predicate((List<Chronicle> list) =>
              list.firstWhere((c) => c.id == 'c-stream-feat-2').title ==
              'New Title'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-feat-2',
        title: 'New Title',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
        isFeatured: const Value(true),
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 物理删除 featured 后流应发出不包含该记录的列表', () async {
      final now = DateTime.now();
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-feat-3',
        title: 'To Delete',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
        isFeatured: const Value(true),
      ));
      final stream = chronicleDao.watchFeatured();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<Chronicle> list) =>
              list.any((c) => c.id == 'c-stream-feat-3')),
          predicate((List<Chronicle> list) =>
              !list.any((c) => c.id == 'c-stream-feat-3')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chronicleDao.deleteById('c-stream-feat-3');
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: isFeatured=false 不应出现在 featured 列表中', () async {
      final now = DateTime.now();
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-feat-4',
        title: 'Not Featured',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final result = await chronicleDao.watchFeatured().first;
      expect(result.any((c) => c.id == 'c-stream-feat-4'), isFalse);
    });

    test('边界2: 切换 featured 状态后流应正确响应', () async {
      final now = DateTime.now();
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-feat-5',
        title: 'Toggle',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
        isFeatured: const Value(true),
      ));
      final stream = chronicleDao.watchFeatured();
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((List<Chronicle> list) =>
              list.any((c) => c.id == 'c-stream-feat-5')),
          predicate((List<Chronicle> list) =>
              !list.any((c) => c.id == 'c-stream-feat-5')),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chronicleDao.updateFeatured('c-stream-feat-5', false);
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });
  });

  // 0.1.160 流式响应与状态同步可靠性测试
  // 防护 0.1.159 同类 bug：watch* 方法在表数据变化时必须可靠发出新值
  group('ChronicleDao Stream Reliability - watchById（0.1.160）', () {
    test('A: 初始状态（不存在的 id）应返回 null', () async {
      final result = await chronicleDao.watchById('non-existent').first;
      expect(result, isNull);
    });

    test('B: 插入数据后流应发出新值', () async {
      final now = DateTime.now();
      final stream = chronicleDao.watchById('c-stream-byid-1');
      final future = expectLater(
        stream,
        emitsInOrder([
          isNull,
          isNotNull,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-byid-1',
        title: 'Stream Test',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('C: 更新数据后流应发出新值', () async {
      final now = DateTime.now();
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-byid-2',
        title: 'Old Title',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = chronicleDao.watchById('c-stream-byid-2');
      final future = expectLater(
        stream,
        emitsInOrder([
          predicate((Chronicle? c) => c?.title == 'Old Title'),
          predicate((Chronicle? c) => c?.title == 'New Title'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-byid-2',
        title: 'New Title',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('D: 物理删除后流应发出 null', () async {
      final now = DateTime.now();
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-byid-3',
        title: 'Will Delete',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      final stream = chronicleDao.watchById('c-stream-byid-3');
      final future = expectLater(
        stream,
        emitsInOrder([
          isNotNull,
          isNull,
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await chronicleDao.deleteById('c-stream-byid-3');
      await Future.delayed(const Duration(milliseconds: 50));
      await future;
    });

    test('边界1: 不存在的 id 应返回 null', () async {
      final result = await chronicleDao.watchById('').first;
      expect(result, isNull);
    });

    test('边界2: 物理删除后应返回 null', () async {
      final now = DateTime.now();
      await chronicleDao.upsert(ChroniclesCompanion.insert(
        id: 'c-stream-byid-4',
        title: 'Will Delete',
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
      ));
      await chronicleDao.deleteById('c-stream-byid-4');
      final result = await chronicleDao.watchById('c-stream-byid-4').first;
      expect(result, isNull);
    });
  });
}
