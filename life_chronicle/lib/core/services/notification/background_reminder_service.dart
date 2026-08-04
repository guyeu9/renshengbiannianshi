import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:workmanager/workmanager.dart';

import '../file_logger.dart';

import '../../database/app_database.dart';
import '../../database/db_connection_io.dart' as dbconn;
import 'reminder_service.dart';

const String reminderCheckTaskName = 'life_chronicle_reminder_check';
const String reminderCheckTaskTag = 'reminder_check';

@pragma('vm:entry-point')
void reminderCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    AppDatabase? db;
    try {
      db = AppDatabase.connect(dbconn.openConnection());

      final now = DateTime.now();
      final allReminders = await db.reminderDao.getAllReminders();
      int triggeredCount = 0;

      for (final reminder in allReminders) {
        if (!reminder.isHandled &&
            reminder.scheduledAt.isBefore(now) &&
            reminder.triggeredAt == null) {
          await db.reminderDao.updateReminder(reminder.id, triggeredAt: now);

          final service = ReminderService.instance;
          await service.initialize();
          // 与 _markExpiredReminders 保持一致：contact 类型通知 title 用"联络提醒"，完整信息放入 content
          final notificationTitle = reminder.type == 'contact' ? '联络提醒' : reminder.title;
          final notificationContent = reminder.type == 'contact'
              ? '${reminder.title}${reminder.content != null && reminder.content!.isNotEmpty ? '\n${reminder.content}' : ''}'
              : reminder.content;
          await service.showImmediateReminder(
            id: reminder.id,
            title: notificationTitle,
            content: notificationContent,
            type: reminder.type,
            payload: '${reminder.type}:${reminder.relatedEntityId ?? ''}',
          );

          triggeredCount++;
          FileLogger.instance.logSync('BackgroundReminder', 'triggered reminder ${reminder.id} (${reminder.title})');
        }
      }

      if (triggeredCount > 0) {
        FileLogger.instance.logSync('BackgroundReminder', 'triggered $triggeredCount reminders');
      }

      await db.close();
      return Future.value(true);
    } catch (e) {
      FileLogger.instance.logSync('BackgroundReminder', 'check failed: $e');
      if (db != null) {
        try {
          await db.close();
        } catch (closeError) {
          FileLogger.instance.logSync('BackgroundReminder', '关闭数据库失败: $closeError');
        }
      }
      return Future.value(false);
    }
  });
}

class BackgroundReminderService {
  static final BackgroundReminderService _instance = BackgroundReminderService._internal();
  factory BackgroundReminderService() => _instance;
  BackgroundReminderService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await Workmanager().initialize(
      reminderCallbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    _initialized = true;
    FileLogger.instance.logSync('BackgroundReminder', 'initialized');
  }

  Future<void> registerPeriodicReminderCheck() async {
    if (!_initialized) await initialize();

    await Workmanager().registerPeriodicTask(
      reminderCheckTaskName,
      reminderCheckTaskName,
      tag: reminderCheckTaskTag,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    FileLogger.instance.logSync('BackgroundReminder', 'Registered periodic reminder check task (every 15 minutes)');
  }

  Future<void> cancelReminderCheck() async {
    await Workmanager().cancelByTag(reminderCheckTaskTag);
    FileLogger.instance.logSync('BackgroundReminder', 'Cancelled periodic reminder check task');
  }
}
