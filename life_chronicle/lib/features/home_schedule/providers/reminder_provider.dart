import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';

final allRemindersProvider = StreamProvider<List<ReminderRecord>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.reminderDao.watchAllReminders();
});

final unreadRemindersProvider = StreamProvider<List<ReminderRecord>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.reminderDao.watchUnreadReminders();
});

final unhandledRemindersProvider = StreamProvider<List<ReminderRecord>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.reminderDao.watchUnhandledReminders().map(
    (reminders) => reminders.where((r) => r.scheduledAt.isBefore(DateTime.now())).toList(),
  );
});

final unreadReminderCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.reminderDao.watchUnreadCount();
});

final remindersByTypeProvider = StreamProvider.family<List<ReminderRecord>, String?>((ref, type) {
  final db = ref.watch(appDatabaseProvider);
  final stream = db.reminderDao.watchAllReminders();
  if (type == null) return stream;
  return stream.map((reminders) => reminders.where((r) => r.type == type).toList());
});

final hasUnreadRemindersProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.reminderDao.watchUnreadCount().map((count) => count > 0);
});

final upcomingRemindersProvider = StreamProvider<List<ReminderRecord>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.reminderDao.watchAllReminders().map(
    (reminders) {
      final now = DateTime.now();
      return reminders
          .where((r) => !r.isHandled && r.scheduledAt.isAfter(now))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    },
  );
});
