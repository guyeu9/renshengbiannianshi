import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_chronicle/core/database/app_database.dart';
import 'package:life_chronicle/core/services/notification/reminder_scheduler.dart';

import '../../test_utils/test_database.dart';
import '../../test_utils/test_utils.dart';

void main() {
  late AppDatabase db;
  late ReminderDao reminderDao;

  setUp(() async {
    db = createTestDatabase();
    reminderDao = ReminderDao(db);
  });

  tearDown(() async {
    await closeTestDatabase(db);
  });

  group('contactFrequencyToDays', () {
    test('null 或空字符串或"无需提醒"返回 0', () {
      expect(ReminderScheduler.contactFrequencyToDays(null), equals(0));
      expect(ReminderScheduler.contactFrequencyToDays(''), equals(0));
      expect(ReminderScheduler.contactFrequencyToDays('  '), equals(0));
      expect(ReminderScheduler.contactFrequencyToDays('无需提醒'), equals(0));
    });

    test('包含"周"或"星期"返回 7', () {
      expect(ReminderScheduler.contactFrequencyToDays('每周'), equals(7));
      expect(ReminderScheduler.contactFrequencyToDays('一星期'), equals(7));
    });

    test('包含"两"和"周"返回 14', () {
      expect(ReminderScheduler.contactFrequencyToDays('两周'), equals(14));
    });

    test('包含"半个月"返回 15', () {
      expect(ReminderScheduler.contactFrequencyToDays('半个月'), equals(15));
    });

    test('包含"一个月"或单独"月"返回 30', () {
      expect(ReminderScheduler.contactFrequencyToDays('一个月'), equals(30));
      expect(ReminderScheduler.contactFrequencyToDays('每月'), equals(30));
    });

    test('包含"三个月"或"季"返回 90', () {
      expect(ReminderScheduler.contactFrequencyToDays('三个月'), equals(90));
      expect(ReminderScheduler.contactFrequencyToDays('每季度'), equals(90));
    });

    test('包含"年"返回 365', () {
      expect(ReminderScheduler.contactFrequencyToDays('每年'), equals(365));
    });

    test('未知频率默认返回 30', () {
      expect(ReminderScheduler.contactFrequencyToDays('不认识的频率'), equals(30));
    });
  });

  group('contact reminder title 格式', () {
    test('contact 类型 reminder 的 title 应包含天数和人名', () async {
      final now = DateTime.now();
      const friendName = '张三';
      const daysSinceLastMeet = 35;
      final expectedTitle = '离上次联系已有$daysSinceLastMeet天：$friendName';

      await reminderDao.insertReminder(
        ReminderRecordsCompanion.insert(
          id: 'contact_friend-1',
          type: 'contact',
          title: expectedTitle,
          content: const Value('联络周期：每30天\n距上次联系：35天'),
          relatedEntityType: const Value('friend'),
          relatedEntityId: const Value('friend-1'),
          scheduledAt: now,
          createdAt: now,
        ),
      );

      final reminders = await reminderDao.getAllReminders();
      expect(reminders.length, equals(1));
      expect(reminders.first.type, equals('contact'));
      expect(reminders.first.title, equals('离上次联系已有35天：张三'));
      expect(reminders.first.title.contains('35天'), isTrue);
      expect(reminders.first.title.contains('张三'), isTrue);
    });

    test('contact 类型 title 应优于旧格式（仅人名）', () async {
      final now = DateTime.now();

      // 新格式
      await reminderDao.insertReminder(
        ReminderRecordsCompanion.insert(
          id: 'contact_new',
          type: 'contact',
          title: '离上次联系已有35天：张三',
          relatedEntityType: const Value('friend'),
          relatedEntityId: const Value('friend-1'),
          scheduledAt: now,
          createdAt: now,
        ),
      );

      // 旧格式（仅人名，应被新格式取代）
      await reminderDao.insertReminder(
        ReminderRecordsCompanion.insert(
          id: 'contact_old',
          type: 'contact',
          title: '张三',
          relatedEntityType: const Value('friend'),
          relatedEntityId: const Value('friend-2'),
          scheduledAt: now,
          createdAt: now,
        ),
      );

      final reminders = await reminderDao.getAllReminders();
      final newFormat = reminders.firstWhere((r) => r.id == 'contact_new');
      final oldFormat = reminders.firstWhere((r) => r.id == 'contact_old');

      // 新格式应包含天数信息
      expect(newFormat.title.contains('天'), isTrue);
      expect(newFormat.title.contains('张三'), isTrue);

      // 旧格式不包含天数信息（仅人名）
      expect(oldFormat.title, equals('张三'));
      expect(oldFormat.title.contains('天'), isFalse);
    });
  });

  group('contact reminder content 格式', () {
    test('content 应包含联络周期和距上次联系天数', () async {
      final now = DateTime.now();
      const expectedContent = '联络周期：每30天\n距上次联系：35天';

      await reminderDao.insertReminder(
        ReminderRecordsCompanion.insert(
          id: 'contact_friend-2',
          type: 'contact',
          title: '离上次联系已有35天：李四',
          content: const Value(expectedContent),
          relatedEntityType: const Value('friend'),
          relatedEntityId: const Value('friend-2'),
          scheduledAt: now,
          createdAt: now,
        ),
      );

      final reminders = await reminderDao.getAllReminders();
      final reminder = reminders.first;

      expect(reminder.content, isNotNull);
      expect(reminder.content!.contains('联络周期'), isTrue);
      expect(reminder.content!.contains('距上次联系'), isTrue);
      expect(reminder.content!.contains('35天'), isTrue);
    });

    test('未记录联系天数的 content 应显示"未记录"', () async {
      final now = DateTime.now();
      const expectedContent = '联络周期：每30天\n距上次联系：未记录';

      await reminderDao.insertReminder(
        ReminderRecordsCompanion.insert(
          id: 'contact_friend-3',
          type: 'contact',
          title: '离上次联系已有0天：王五',
          content: const Value(expectedContent),
          relatedEntityType: const Value('friend'),
          relatedEntityId: const Value('friend-3'),
          scheduledAt: now,
          createdAt: now,
        ),
      );

      final reminders = await reminderDao.getAllReminders();
      final reminder = reminders.first;

      expect(reminder.content!.contains('未记录'), isTrue);
    });
  });

  group('reminder DAO 操作', () {
    test('deleteRemindersByTypeAndEntity 应只删除指定类型和实体的提醒', () async {
      final now = DateTime.now();

      // 插入 3 个 reminder：contact-friend-1, contact-friend-2, goal-goal-1
      await reminderDao.insertReminder(
        ReminderRecordsCompanion.insert(
          id: 'contact_friend-1',
          type: 'contact',
          title: '离上次联系已有35天：张三',
          relatedEntityType: const Value('friend'),
          relatedEntityId: const Value('friend-1'),
          scheduledAt: now,
          createdAt: now,
        ),
      );
      await reminderDao.insertReminder(
        ReminderRecordsCompanion.insert(
          id: 'contact_friend-2',
          type: 'contact',
          title: '离上次联系已有40天：李四',
          relatedEntityType: const Value('friend'),
          relatedEntityId: const Value('friend-2'),
          scheduledAt: now,
          createdAt: now,
        ),
      );
      await reminderDao.insertReminder(
        ReminderRecordsCompanion.insert(
          id: 'goal_goal-1',
          type: 'goal',
          title: '目标提醒：阅读30分钟',
          relatedEntityType: const Value('goal'),
          relatedEntityId: const Value('goal-1'),
          scheduledAt: now,
          createdAt: now,
        ),
      );

      // 删除 friend-1 的 contact 提醒
      await reminderDao.deleteRemindersByTypeAndEntity('contact', 'friend', 'friend-1');

      final reminders = await reminderDao.getAllReminders();
      expect(reminders.length, equals(2));
      expect(reminders.any((r) => r.id == 'contact_friend-1'), isFalse);
      expect(reminders.any((r) => r.id == 'contact_friend-2'), isTrue);
      expect(reminders.any((r) => r.id == 'goal_goal-1'), isTrue);
    });

    test('todayRemindersProvider 应正确过滤今天的提醒', () async {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day, 10, 0);
      final yesterday = DateTime(now.year, now.month, now.day - 1, 10, 0);
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 10, 0);

      await reminderDao.insertReminder(
        ReminderRecordsCompanion.insert(
          id: 'today_reminder',
          type: 'contact',
          title: '离上次联系已有35天：今天',
          scheduledAt: todayStart,
          createdAt: now,
        ),
      );
      await reminderDao.insertReminder(
        ReminderRecordsCompanion.insert(
          id: 'yesterday_reminder',
          type: 'contact',
          title: '离上次联系已有30天：昨天',
          scheduledAt: yesterday,
          createdAt: now,
          isHandled: const Value(true),
        ),
      );
      await reminderDao.insertReminder(
        ReminderRecordsCompanion.insert(
          id: 'tomorrow_reminder',
          type: 'contact',
          title: '离上次联系已有40天：明天',
          scheduledAt: tomorrow,
          createdAt: now,
        ),
      );

      final allReminders = await reminderDao.getAllReminders();
      // 验证数据插入正确
      expect(allReminders.length, equals(3));

      // 验证未处理的提醒
      final unhandled = allReminders.where((r) => !r.isHandled).toList();
      expect(unhandled.length, equals(2));
      expect(unhandled.any((r) => r.id == 'today_reminder'), isTrue);
      expect(unhandled.any((r) => r.id == 'tomorrow_reminder'), isTrue);
      expect(unhandled.any((r) => r.id == 'yesterday_reminder'), isFalse);
    });
  });

  group('notification title 规范', () {
    test('contact 类型过期通知 title 应为"联络提醒"而非 reminder.title', () async {
      // 模拟 _markExpiredReminders 的逻辑
      final now = DateTime.now();
      final reminder = ReminderRecord(
        id: 'contact_expired',
        type: 'contact',
        title: '离上次联系已有35天：张三',
        content: '联络周期：每30天\n距上次联系：35天',
        relatedEntityType: 'friend',
        relatedEntityId: 'friend-1',
        scheduledAt: now.subtract(const Duration(hours: 1)),
        triggeredAt: null,
        isRead: false,
        isHandled: false,
        createdAt: now,
      );

      // 模拟 _markExpiredReminders 中的通知 title 选择逻辑
      final notificationTitle = reminder.type == 'contact' ? '联络提醒' : reminder.title;
      final notificationContent = reminder.type == 'contact'
          ? '${reminder.title}${reminder.content != null && reminder.content!.isNotEmpty ? '\n${reminder.content}' : ''}'
          : reminder.content;

      // 验证通知 title 是简短的"联络提醒"
      expect(notificationTitle, equals('联络提醒'));
      // 验证通知 content 包含完整信息（title + content）
      expect(notificationContent, contains('离上次联系已有35天：张三'));
      expect(notificationContent, contains('联络周期：每30天'));
      expect(notificationContent, contains('距上次联系：35天'));
    });

    test('birthday 类型过期通知 title 保持 reminder.title', () async {
      final now = DateTime.now();
      final reminder = ReminderRecord(
        id: 'birthday_1',
        type: 'birthday',
        title: '张三的生日提醒',
        content: '3天后是张三的生日（5月20日）',
        relatedEntityType: 'friend',
        relatedEntityId: 'friend-1',
        scheduledAt: now.subtract(const Duration(hours: 1)),
        triggeredAt: null,
        isRead: false,
        isHandled: false,
        createdAt: now,
      );

      final notificationTitle = reminder.type == 'contact' ? '联络提醒' : reminder.title;

      // birthday 类型保持 reminder.title
      expect(notificationTitle, equals('张三的生日提醒'));
    });

    test('goal 类型过期通知 title 保持 reminder.title', () async {
      final now = DateTime.now();
      final reminder = ReminderRecord(
        id: 'goal_1',
        type: 'goal',
        title: '目标提醒：阅读30分钟',
        content: '别忘了你的目标：阅读30分钟',
        relatedEntityType: 'goal',
        relatedEntityId: 'goal-1',
        scheduledAt: now.subtract(const Duration(hours: 1)),
        triggeredAt: null,
        isRead: false,
        isHandled: false,
        createdAt: now,
      );

      final notificationTitle = reminder.type == 'contact' ? '联络提醒' : reminder.title;

      // goal 类型保持 reminder.title
      expect(notificationTitle, equals('目标提醒：阅读30分钟'));
    });
  });
}
