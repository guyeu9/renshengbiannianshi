import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

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
          await service.showImmediateReminder(
            id: reminder.id,
            title: reminder.title,
            content: reminder.content,
            type: reminder.type,
            payload: '${reminder.type}:${reminder.relatedEntityId ?? ''}',
          );

          triggeredCount++;
          debugPrint('Background reminder check: triggered reminder ${reminder.id} (${reminder.title})');
        }
      }

      if (triggeredCount > 0) {
        debugPrint('Background reminder check: triggered $triggeredCount reminders');
      }

      await db.close();
      return Future.value(true);
    } catch (e) {
      debugPrint('Background reminder check failed: $e');
      if (db != null) {
        try {
          await db.close();
        } catch (closeError) {
          debugPrint('关闭数据库失败: $closeError');
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
    debugPrint('BackgroundReminderService initialized');
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

    debugPrint('Registered periodic reminder check task (every 15 minutes)');
  }

  Future<void> cancelReminderCheck() async {
    await Workmanager().cancelByTag(reminderCheckTaskTag);
    debugPrint('Cancelled periodic reminder check task');
  }
}
