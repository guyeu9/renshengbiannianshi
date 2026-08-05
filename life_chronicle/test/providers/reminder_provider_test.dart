// 0.1.166 Provider层状态同步可靠性测试
// 防护 0.1.159 同类 bug：Provider 在 DAO 数据变化后必须正确刷新
// 0.1.159 修复了 watchUnreadCount 聚合查询 Stream 不可靠的问题，
// 此测试文件验证所有 reminder Provider 在 DAO 数据变化后能正确发出新值。
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/database/database_providers.dart';
import 'package:life_chronicle/features/home_schedule/providers/reminder_provider.dart';
import '../test_utils/test_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = createTestDatabase();
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await closeTestDatabase(db);
  });

  // 构造 ReminderRecordsCompanion.insert 的辅助方法
  ReminderRecordsCompanion makeReminder({
    required String id,
    String type = 'contact',
    String title = '测试提醒',
    String? content,
    DateTime? scheduledAt,
    bool isRead = false,
    bool isHandled = false,
  }) {
    final now = DateTime.now();
    return ReminderRecordsCompanion.insert(
      id: id,
      type: type,
      title: title,
      content: content != null ? Value(content) : const Value.absent(),
      scheduledAt: scheduledAt ?? now,
      isRead: Value(isRead),
      isHandled: Value(isHandled),
      createdAt: now,
    );
  }

  // ==================== allRemindersProvider ====================
  group('allRemindersProvider（0.1.166 Provider层状态同步可靠性测试）', () {
    // rp-stream-all-A: 初始状态返回空列表
    test('rp-stream-all-A 初始状态返回空列表', () async {
      final sub = container.listen(allRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(allRemindersProvider).value, isEmpty);

      sub.close();
    });

    // rp-stream-all-B: 插入reminder后Provider发出包含新记录的列表
    test('rp-stream-all-B 插入reminder后Provider发出包含新记录的列表', () async {
      final sub = container.listen(allRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(allRemindersProvider).value, isEmpty);

      await db.reminderDao.insertReminder(makeReminder(id: 'rp-stream-all-B'));

      await Future.delayed(const Duration(milliseconds: 100));
      final list = container.read(allRemindersProvider).value!;
      expect(list.length, equals(1));
      expect(list.first.id, equals('rp-stream-all-B'));

      sub.close();
    });

    // rp-stream-all-C: 删除reminder后Provider发出不包含该记录的列表
    test('rp-stream-all-C 删除reminder后Provider发出不包含该记录的列表', () async {
      await db.reminderDao.insertReminder(makeReminder(id: 'rp-stream-all-C'));
      final sub = container.listen(allRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(allRemindersProvider).value!.length, equals(1));

      await db.reminderDao.deleteReminder('rp-stream-all-C');

      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(allRemindersProvider).value, isEmpty);

      sub.close();
    });
  });

  // ==================== unreadRemindersProvider ====================
  group('unreadRemindersProvider（0.1.166 Provider层状态同步可靠性测试）', () {
    // rp-stream-unread-A: 初始状态返回空列表
    test('rp-stream-unread-A 初始状态返回空列表', () async {
      final sub = container.listen(unreadRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(unreadRemindersProvider).value, isEmpty);

      sub.close();
    });

    // rp-stream-unread-B: 插入未读reminder后Provider发出包含新记录的列表
    test('rp-stream-unread-B 插入未读reminder后Provider发出包含新记录的列表', () async {
      final sub = container.listen(unreadRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(unreadRemindersProvider).value, isEmpty);

      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-unread-B', isRead: false));

      await Future.delayed(const Duration(milliseconds: 100));
      final list = container.read(unreadRemindersProvider).value!;
      expect(list.length, equals(1));
      expect(list.first.id, equals('rp-stream-unread-B'));

      sub.close();
    });

    // rp-stream-unread-C: 标记已读后Provider发出不包含该记录的列表
    test('rp-stream-unread-C 标记已读后Provider发出不包含该记录的列表', () async {
      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-unread-C', isRead: false));
      final sub = container.listen(unreadRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(unreadRemindersProvider).value!.length, equals(1));

      await db.reminderDao.updateReminder('rp-stream-unread-C', isRead: true);

      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(unreadRemindersProvider).value, isEmpty);

      sub.close();
    });

    // rp-stream-unread-D: markAllAsRead后Provider发出空列表
    test('rp-stream-unread-D markAllAsRead后Provider发出空列表', () async {
      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-unread-D1', isRead: false));
      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-unread-D2', isRead: false));
      final sub = container.listen(unreadRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(unreadRemindersProvider).value!.length, equals(2));

      await db.reminderDao.markAllAsRead();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(unreadRemindersProvider).value, isEmpty);

      sub.close();
    });
  });

  // ==================== unreadReminderCountProvider ====================
  // 防护 0.1.159 同类 bug：聚合查询 Stream 必须在数据变化后正确发出新值
  group('unreadReminderCountProvider（0.1.166 防护 0.1.159 同类 bug）', () {
    // rp-stream-count-A: 初始状态返回0
    test('rp-stream-count-A 初始状态返回0', () async {
      final sub = container.listen(unreadReminderCountProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(unreadReminderCountProvider).value, equals(0));

      sub.close();
    });

    // rp-stream-count-B: 插入未读reminder后count增加
    test('rp-stream-count-B 插入未读reminder后count增加', () async {
      final sub = container.listen(unreadReminderCountProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(unreadReminderCountProvider).value, equals(0));

      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-count-B', isRead: false));

      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(unreadReminderCountProvider).value, equals(1));

      sub.close();
    });

    // rp-stream-count-C: 单条标记已读后count减少
    test('rp-stream-count-C 单条标记已读后count减少', () async {
      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-count-C1', isRead: false));
      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-count-C2', isRead: false));
      final sub = container.listen(unreadReminderCountProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(unreadReminderCountProvider).value, equals(2));

      await db.reminderDao.updateReminder('rp-stream-count-C1', isRead: true);

      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(unreadReminderCountProvider).value, equals(1));

      sub.close();
    });

    // rp-stream-count-D: markAllAsRead后count归零（0.1.159修复的核心场景）
    test('rp-stream-count-D markAllAsRead后count归零', () async {
      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-count-D1', isRead: false));
      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-count-D2', isRead: false));
      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-count-D3', isRead: false));
      final sub = container.listen(unreadReminderCountProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(unreadReminderCountProvider).value, equals(3));

      await db.reminderDao.markAllAsRead();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(unreadReminderCountProvider).value, equals(0));

      sub.close();
    });

    // rp-stream-count-edge1: 插入已读reminder后count不变
    test('rp-stream-count-edge1 插入已读reminder后count不变', () async {
      final sub = container.listen(unreadReminderCountProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(unreadReminderCountProvider).value, equals(0));

      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-count-edge1', isRead: true));

      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(unreadReminderCountProvider).value, equals(0));

      sub.close();
    });

    // rp-stream-count-edge2: 插入多条后count正确
    test('rp-stream-count-edge2 插入多条后count正确', () async {
      final sub = container.listen(unreadReminderCountProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));

      for (var i = 0; i < 5; i++) {
        await db.reminderDao
            .insertReminder(makeReminder(id: 'rp-stream-count-edge2-$i', isRead: false));
      }

      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(unreadReminderCountProvider).value, equals(5));

      sub.close();
    });
  });

  // ==================== hasUnreadRemindersProvider ====================
  group('hasUnreadRemindersProvider（0.1.166 Provider层状态同步可靠性测试）', () {
    // rp-stream-has-A: 初始状态返回false
    test('rp-stream-has-A 初始状态返回false', () async {
      final sub = container.listen(hasUnreadRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(hasUnreadRemindersProvider).value, isFalse);

      sub.close();
    });

    // rp-stream-has-B: 插入未读reminder后返回true
    test('rp-stream-has-B 插入未读reminder后返回true', () async {
      final sub = container.listen(hasUnreadRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(hasUnreadRemindersProvider).value, isFalse);

      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-has-B', isRead: false));

      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(hasUnreadRemindersProvider).value, isTrue);

      sub.close();
    });

    // rp-stream-has-C: markAllAsRead后返回false
    test('rp-stream-has-C markAllAsRead后返回false', () async {
      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-has-C1', isRead: false));
      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-has-C2', isRead: false));
      final sub = container.listen(hasUnreadRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(hasUnreadRemindersProvider).value, isTrue);

      await db.reminderDao.markAllAsRead();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(hasUnreadRemindersProvider).value, isFalse);

      sub.close();
    });
  });

  // ==================== remindersByTypeProvider ====================
  group('remindersByTypeProvider（0.1.166 Provider层状态同步可靠性测试）', () {
    // rp-stream-type-A: 初始状态返回空列表
    test('rp-stream-type-A 初始状态返回空列表', () async {
      final sub = container.listen(remindersByTypeProvider('contact'), (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(remindersByTypeProvider('contact')).value, isEmpty);

      sub.close();
    });

    // rp-stream-type-B: 插入指定type的reminder后Provider发出包含新记录的列表
    test('rp-stream-type-B 插入指定type的reminder后Provider发出包含新记录的列表', () async {
      final sub = container.listen(remindersByTypeProvider('birthday'), (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(remindersByTypeProvider('birthday')).value, isEmpty);

      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-type-B', type: 'birthday'));

      await Future.delayed(const Duration(milliseconds: 100));
      final list = container.read(remindersByTypeProvider('birthday')).value!;
      expect(list.length, equals(1));
      expect(list.first.id, equals('rp-stream-type-B'));

      sub.close();
    });

    // rp-stream-type-C: 插入不同type的reminder后Provider不发出该记录
    test('rp-stream-type-C 插入不同type的reminder后Provider不发出该记录', () async {
      final sub = container.listen(remindersByTypeProvider('birthday'), (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(remindersByTypeProvider('birthday')).value, isEmpty);

      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-type-C', type: 'goal'));

      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(remindersByTypeProvider('birthday')).value, isEmpty);

      sub.close();
    });

    // rp-stream-type-edge1: type=null时返回所有reminder
    test('rp-stream-type-edge1 type=null时返回所有reminder', () async {
      final sub = container.listen(remindersByTypeProvider(null), (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(remindersByTypeProvider(null)).value, isEmpty);

      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-type-edge1a', type: 'birthday'));
      await db.reminderDao
          .insertReminder(makeReminder(id: 'rp-stream-type-edge1b', type: 'goal'));

      await Future.delayed(const Duration(milliseconds: 100));
      final list = container.read(remindersByTypeProvider(null)).value!;
      expect(list.length, equals(2));

      sub.close();
    });
  });

  // ==================== todayRemindersProvider ====================
  group('todayRemindersProvider（0.1.166 Provider层状态同步可靠性测试）', () {
    // rp-stream-today-A: 初始状态返回空列表
    test('rp-stream-today-A 初始状态返回空列表', () async {
      final sub = container.listen(todayRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(todayRemindersProvider).value, isEmpty);

      sub.close();
    });

    // rp-stream-today-B: 插入今天scheduledAt的reminder后Provider发出包含新记录的列表
    test('rp-stream-today-B 插入今天scheduledAt的reminder后Provider发出包含新记录的列表', () async {
      final sub = container.listen(todayRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(todayRemindersProvider).value, isEmpty);

      await db.reminderDao.insertReminder(
        makeReminder(id: 'rp-stream-today-B', scheduledAt: DateTime.now()),
      );

      await Future.delayed(const Duration(milliseconds: 100));
      final list = container.read(todayRemindersProvider).value!;
      expect(list.length, equals(1));
      expect(list.first.id, equals('rp-stream-today-B'));

      sub.close();
    });

    // rp-stream-today-edge1: 插入明天的reminder后Provider不发出该记录
    test('rp-stream-today-edge1 插入明天的reminder后Provider不发出该记录', () async {
      final sub = container.listen(todayRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(todayRemindersProvider).value, isEmpty);

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await db.reminderDao.insertReminder(
        makeReminder(id: 'rp-stream-today-edge1', scheduledAt: tomorrow),
      );

      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(todayRemindersProvider).value, isEmpty);

      sub.close();
    });
  });

  // ==================== upcomingRemindersProvider ====================
  group('upcomingRemindersProvider（0.1.166 Provider层状态同步可靠性测试）', () {
    // rp-stream-upcoming-A: 初始状态返回空列表
    test('rp-stream-upcoming-A 初始状态返回空列表', () async {
      final sub = container.listen(upcomingRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(upcomingRemindersProvider).value, isEmpty);

      sub.close();
    });

    // rp-stream-upcoming-B: 插入未来scheduledAt的reminder后Provider发出包含新记录的列表
    test('rp-stream-upcoming-B 插入未来scheduledAt的reminder后Provider发出包含新记录的列表', () async {
      final sub = container.listen(upcomingRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(upcomingRemindersProvider).value, isEmpty);

      final future = DateTime.now().add(const Duration(hours: 2));
      await db.reminderDao.insertReminder(
        makeReminder(id: 'rp-stream-upcoming-B', scheduledAt: future),
      );

      await Future.delayed(const Duration(milliseconds: 100));
      final list = container.read(upcomingRemindersProvider).value!;
      expect(list.length, equals(1));
      expect(list.first.id, equals('rp-stream-upcoming-B'));

      sub.close();
    });

    // rp-stream-upcoming-edge1: 插入已处理的reminder后Provider不发出该记录
    test('rp-stream-upcoming-edge1 插入已处理的reminder后Provider不发出该记录', () async {
      final sub = container.listen(upcomingRemindersProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(upcomingRemindersProvider).value, isEmpty);

      final future = DateTime.now().add(const Duration(hours: 2));
      await db.reminderDao.insertReminder(
        makeReminder(id: 'rp-stream-upcoming-edge1', scheduledAt: future, isHandled: true),
      );

      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(upcomingRemindersProvider).value, isEmpty);

      sub.close();
    });
  });
}
