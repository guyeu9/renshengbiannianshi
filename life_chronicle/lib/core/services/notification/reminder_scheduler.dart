import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/app_database.dart';
import 'reminder_service.dart';

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return ReminderScheduler.instance;
});

class ReminderScheduler {
  static final ReminderScheduler instance = ReminderScheduler._internal();
  ReminderScheduler._internal();

  final ReminderService _service = ReminderService.instance;

  static int contactFrequencyToDays(String? frequency) {
    if (frequency == null || frequency.trim().isEmpty || frequency == '无需提醒') return 0;
    if (frequency.contains('三个月') || frequency.contains('季')) return 90;
    if (frequency.contains('一个月') || frequency.contains('月') && !frequency.contains('三个')) return 30;
    if (frequency.contains('周') || frequency.contains('星期')) return 7;
    if (frequency.contains('年')) return 365;
    if (frequency.contains('两') && frequency.contains('周')) return 14;
    if (frequency.contains('半') && frequency.contains('月')) return 15;
    return 30;
  }

  Future<void> scheduleAllReminders(AppDatabase db) async {
    final prefs = await SharedPreferences.getInstance();
    final globalEnabled = prefs.getBool('global_reminder_enabled') ?? true;
    debugPrint('ReminderScheduler: scheduleAllReminders called, globalEnabled=$globalEnabled');
    
    if (!globalEnabled) {
      await _service.cancelAllReminders();
      debugPrint('ReminderScheduler: global reminder disabled, cancelled all');
      return;
    }

    await _service.initialize();
    await _service.requestPermissions();

    debugPrint('ReminderScheduler: scheduling birthday reminders...');
    await _scheduleAllBirthdayReminders(db, prefs);
    debugPrint('ReminderScheduler: scheduling contact reminders...');
    await _scheduleAllContactReminders(db, prefs);
    debugPrint('ReminderScheduler: scheduling goal reminders...');
    await _scheduleAllGoalReminders(db);

    await _markExpiredReminders(db);

    final allReminders = await db.reminderDao.getAllReminders();
    debugPrint('ReminderScheduler: all reminders scheduled, total ${allReminders.length} records in database');
  }

  Future<void> rescheduleForFriend(AppDatabase db, String friendId) async {
    final prefs = await SharedPreferences.getInstance();
    final globalEnabled = prefs.getBool('global_reminder_enabled') ?? true;
    if (!globalEnabled) return;

    await _service.cancelReminder('birthday_$friendId');
    await _service.cancelReminder('contact_$friendId');

    await db.reminderDao.deleteRemindersByEntity('friend', friendId);

    final friend = await db.friendDao.findById(friendId);
    if (friend == null) return;

    if (friend.birthday != null) {
      await _scheduleBirthdayReminderForFriend(db, friend, prefs);
    }
    await _scheduleContactReminderForFriend(db, friend, prefs);
  }

  Future<void> rescheduleForGoal(AppDatabase db, String goalId) async {
    final prefs = await SharedPreferences.getInstance();
    final globalEnabled = prefs.getBool('global_reminder_enabled') ?? true;
    if (!globalEnabled) return;

    await _service.cancelReminder('goal_$goalId');

    await db.reminderDao.deleteRemindersByEntity('goal', goalId);

    final goal = await db.goalDao.findById(goalId);
    if (goal == null) return;

    await _scheduleGoalReminderForRecord(db, goal);
  }

  Future<void> cancelRemindersForFriend(AppDatabase db, String friendId) async {
    await _service.cancelReminder('birthday_$friendId');
    await _service.cancelReminder('contact_$friendId');
    await db.reminderDao.deleteRemindersByEntity('friend', friendId);
  }

  Future<void> cancelRemindersForGoal(AppDatabase db, String goalId) async {
    await _service.cancelReminder('goal_$goalId');
    await db.reminderDao.deleteRemindersByEntity('goal', goalId);
  }

  Future<void> _scheduleAllBirthdayReminders(AppDatabase db, SharedPreferences prefs) async {
    final friends = await db.friendDao.watchAllActive().first;
    final daysBefore = prefs.getInt('birthday_reminder_days') ?? 3;

    for (final friend in friends) {
      if (friend.birthday == null) continue;
      await _service.cancelReminder('birthday_${friend.id}');
    }

    for (final friend in friends) {
      if (friend.birthday == null) continue;
      await _scheduleBirthdayReminderForFriend(db, friend, prefs, daysBefore: daysBefore);
    }
  }

  Future<void> _scheduleBirthdayReminderForFriend(
    AppDatabase db,
    FriendRecord friend,
    SharedPreferences prefs, {
    int? daysBefore,
  }) async {
    final advanceDays = daysBefore ?? prefs.getInt('birthday_reminder_days') ?? 3;
    final birthday = friend.birthday!;

    final now = DateTime.now();
    var nextBirthday = DateTime(now.year, birthday.month, birthday.day);
    if (nextBirthday.isBefore(DateTime(now.year, now.month, now.day))) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
    }

    final reminderDate = nextBirthday.subtract(Duration(days: advanceDays));
    if (reminderDate.isBefore(now)) {
      if (nextBirthday.year == now.year) {
        nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
        final nextReminderDate = nextBirthday.subtract(Duration(days: advanceDays));
        if (nextReminderDate.isBefore(now)) return;
        await _doScheduleBirthdayReminder(db, friend, nextBirthday, nextReminderDate, advanceDays);
      }
      return;
    }

    await _doScheduleBirthdayReminder(db, friend, nextBirthday, reminderDate, advanceDays);
  }

  Future<void> _doScheduleBirthdayReminder(
    AppDatabase db,
    FriendRecord friend,
    DateTime nextBirthday,
    DateTime reminderDate,
    int advanceDays,
  ) async {
    var scheduledTime = DateTime(reminderDate.year, reminderDate.month, reminderDate.day, 9, 0);
    scheduledTime = await _applyDoNotDisturb(scheduledTime);

    await _service.scheduleBirthdayReminder(
      friendId: friend.id,
      friendName: friend.name,
      birthday: friend.birthday!,
      daysBefore: advanceDays,
    );

    final reminderId = 'birthday_${friend.id}_${nextBirthday.year}';
    await _upsertReminderRecord(
      db,
      id: reminderId,
      type: 'birthday',
      title: '${friend.name}的生日提醒',
      content: '$advanceDays天后是${friend.name}的生日（${friend.birthday!.month}月${friend.birthday!.day}日）',
      relatedEntityType: 'friend',
      relatedEntityId: friend.id,
      scheduledAt: scheduledTime,
    );
  }

  Future<void> _scheduleAllContactReminders(AppDatabase db, SharedPreferences prefs) async {
    final friends = await db.friendDao.watchAllActive().first;

    for (final friend in friends) {
      await _service.cancelReminder('contact_${friend.id}');
    }

    for (final friend in friends) {
      await _scheduleContactReminderForFriend(db, friend, prefs);
    }
  }

  Future<void> _scheduleContactReminderForFriend(
    AppDatabase db,
    FriendRecord friend,
    SharedPreferences prefs,
  ) async {
    final freqDays = contactFrequencyToDays(friend.contactFrequency);
    if (freqDays == 0) {
      debugPrint('Skip contact reminder for ${friend.name}: contactFrequency is ${friend.contactFrequency}');
      return;
    }

    final reminderEnabled = prefs.getBool('reminder_${friend.id}') ?? false;
    final customDays = prefs.getInt('reminder_${friend.id}_days');

    int intervalDays;
    if (reminderEnabled && customDays != null && customDays > 0) {
      intervalDays = customDays;
    } else {
      intervalDays = freqDays;
    }

    if (intervalDays <= 0) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final baseDate = friend.lastMeetDate ?? friend.createdAt;
    final baseDay = DateTime(baseDate.year, baseDate.month, baseDate.day);

    var scheduledTime = baseDay.add(Duration(days: intervalDays));
    scheduledTime = DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day, 9, 0);

    if (scheduledTime.isBefore(today)) {
      scheduledTime = DateTime(today.year, today.month, today.day, 9, 0);
    }

    scheduledTime = await _applyDoNotDisturb(scheduledTime);

    await _service.scheduleContactReminder(
      friendId: friend.id,
      friendName: friend.name,
      intervalDays: intervalDays,
      scheduledTime: scheduledTime,
    );

    final reminderId = 'contact_${friend.id}';
    await db.reminderDao.deleteRemindersByTypeAndEntity('contact', 'friend', friend.id);
    
    final daysSinceLastMeet = friend.lastMeetDate != null 
        ? now.difference(friend.lastMeetDate!).inDays 
        : -1;
    
    await db.reminderDao.insertReminder(
      ReminderRecordsCompanion.insert(
        id: reminderId,
        type: 'contact',
        title: friend.name,
        content: Value(_buildContactReminderContent(friend, intervalDays, daysSinceLastMeet)),
        relatedEntityType: const Value('friend'),
        relatedEntityId: Value(friend.id),
        scheduledAt: scheduledTime,
        createdAt: DateTime.now(),
      ),
    );

    debugPrint('Scheduled contact reminder for ${friend.name} at $scheduledTime (baseDate: $baseDate, intervalDays: $intervalDays, daysSinceLastMeet: $daysSinceLastMeet)');
  }

  String _buildContactReminderContent(FriendRecord friend, int intervalDays, int daysSinceLastMeet) {
    final buffer = StringBuffer();
    buffer.writeln('联络周期：${friend.contactFrequency ?? '每$intervalDays天'}');
    if (daysSinceLastMeet >= 0) {
      buffer.writeln('距上次联系：$daysSinceLastMeet天');
    } else {
      buffer.writeln('距上次联系：未记录');
    }
    return buffer.toString().trimRight();
  }

  Future<void> _scheduleAllGoalReminders(AppDatabase db) async {
    final goals = await db.goalDao.watchAllActive().first;

    for (final goal in goals) {
      await _service.cancelReminder('goal_${goal.id}');
    }

    for (final goal in goals) {
      await _scheduleGoalReminderForRecord(db, goal);
    }
  }

  Future<void> _scheduleGoalReminderForRecord(AppDatabase db, GoalRecord goal) async {
    final frequency = goal.remindFrequency;
    if (frequency == null || frequency == 'none') return;

    final now = DateTime.now();
    DateTime scheduledTime;

    switch (frequency) {
      case 'daily':
        scheduledTime = DateTime(now.year, now.month, now.day, 9, 0);
        if (scheduledTime.isBefore(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }
        break;
      case 'weekly':
        final daysUntilMonday = (8 - now.weekday) % 7;
        if (daysUntilMonday == 0 && now.weekday == DateTime.monday) {
          final today9am = DateTime(now.year, now.month, now.day, 9, 0);
          if (today9am.isAfter(now)) {
            scheduledTime = today9am;
          } else {
            scheduledTime = DateTime(now.year, now.month, now.day, 9, 0).add(const Duration(days: 7));
          }
        } else {
          scheduledTime = DateTime(now.year, now.month, now.day, 9, 0).add(Duration(days: daysUntilMonday));
        }
        break;
      case 'monthly':
        scheduledTime = DateTime(now.year, now.month + 1, 1, 9, 0);
        break;
      default:
        return;
    }

    scheduledTime = await _applyDoNotDisturb(scheduledTime);

    await _service.scheduleGoalReminder(
      goalId: goal.id,
      goalTitle: goal.title,
      frequency: frequency,
      scheduledTime: scheduledTime,
    );

    final reminderId = 'goal_${goal.id}';
    await db.reminderDao.deleteRemindersByTypeAndEntity('goal', 'goal', goal.id);
    await db.reminderDao.insertReminder(
      ReminderRecordsCompanion.insert(
        id: reminderId,
        type: 'goal',
        title: '目标提醒：${goal.title}',
        content: Value('别忘了你的目标：${goal.title}'),
        relatedEntityType: const Value('goal'),
        relatedEntityId: Value(goal.id),
        scheduledAt: scheduledTime,
        createdAt: DateTime.now(),
      ),
    );

    debugPrint('Scheduled goal reminder for ${goal.title} at $scheduledTime (frequency: $frequency)');
  }

  Future<DateTime> _applyDoNotDisturb(DateTime scheduledTime) async {
    final prefs = await SharedPreferences.getInstance();
    final dndEnabled = prefs.getBool('dnd_enabled') ?? true;
    if (!dndEnabled) return scheduledTime;

    final startHour = prefs.getInt('dnd_start_hour') ?? 22;
    final endHour = prefs.getInt('dnd_end_hour') ?? 8;

    if (scheduledTime.hour >= startHour || scheduledTime.hour < endHour) {
      return DateTime(
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        endHour,
        0,
      );
    }

    return scheduledTime;
  }

  Future<void> _upsertReminderRecord(
    AppDatabase db, {
    required String id,
    required String type,
    required String title,
    String? content,
    String? relatedEntityType,
    String? relatedEntityId,
    required DateTime scheduledAt,
  }) async {
    final existing = await (db.select(db.reminderRecords)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing != null) return;

    await db.reminderDao.insertReminder(
      ReminderRecordsCompanion.insert(
        id: id,
        type: type,
        title: title,
        content: Value(content),
        relatedEntityType: Value(relatedEntityType),
        relatedEntityId: Value(relatedEntityId),
        scheduledAt: scheduledAt,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _markExpiredReminders(AppDatabase db) async {
    final now = DateTime.now();
    final allReminders = await db.reminderDao.getAllReminders();
    for (final reminder in allReminders) {
      if (!reminder.isHandled && reminder.scheduledAt.isBefore(now) && reminder.triggeredAt == null) {
        await db.reminderDao.updateReminder(reminder.id, triggeredAt: now);
      }
    }
  }
}
