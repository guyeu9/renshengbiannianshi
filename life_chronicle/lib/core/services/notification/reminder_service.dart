import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService.instance;
});

class ReminderService {
  static final ReminderService instance = ReminderService._internal();
  ReminderService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('ReminderService initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final ios = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    bool granted = true;

    if (android != null) {
      granted = await android.requestNotificationsPermission() ?? false;
    }

    if (ios != null) {
      final iosGranted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (iosGranted == false) {
        granted = false;
      }
    }

    return granted;
  }

  Future<void> scheduleBirthdayReminder({
    required String friendId,
    required String friendName,
    required DateTime birthday,
    int daysBefore = 3,
  }) async {
    if (!_initialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final globalEnabled = prefs.getBool('global_reminder_enabled') ?? true;
    if (!globalEnabled) return;

    final now = DateTime.now();
    var nextBirthday = DateTime(now.year, birthday.month, birthday.day);

    if (nextBirthday.isBefore(now) || nextBirthday.isAtSameMomentAs(now)) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
    }

    final reminderDate = nextBirthday.subtract(Duration(days: daysBefore));

    if (reminderDate.isBefore(now)) {
      return;
    }

    final scheduledTime = tz.TZDateTime.from(
      DateTime(reminderDate.year, reminderDate.month, reminderDate.day, 9, 0),
      tz.local,
    );

    final notificationId = friendName.hashCode;

    await _notifications.zonedSchedule(
      notificationId,
      '生日提醒',
      '$friendName的生日还有$daysBefore天就要到了！',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'birthday_reminders',
          '生日提醒',
          channelDescription: '朋友生日提醒通知',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'birthday:$friendId',
    );

    debugPrint('Scheduled birthday reminder for $friendName at $scheduledTime');
  }

  Future<void> scheduleContactReminder({
    required String friendId,
    required String friendName,
    required int intervalDays,
  }) async {
    if (!_initialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final globalEnabled = prefs.getBool('global_reminder_enabled') ?? true;
    if (!globalEnabled) return;

    final now = DateTime.now();
    final scheduledTime = tz.TZDateTime.from(
      DateTime(now.year, now.month, now.day, 9, 0).add(Duration(days: intervalDays)),
      tz.local,
    );

    final notificationId = '${friendId}_contact'.hashCode;

    await _notifications.zonedSchedule(
      notificationId,
      '联络提醒',
      '已经$intervalDays天没联系$friendName了，该打个招呼啦！',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'contact_reminders',
          '联络提醒',
          channelDescription: '朋友联络提醒通知',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'contact:$friendId',
    );

    debugPrint('Scheduled contact reminder for $friendName at $scheduledTime');
  }

  Future<void> scheduleGoalReminder({
    required String goalId,
    required String goalTitle,
    required String frequency,
  }) async {
    if (!_initialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final globalEnabled = prefs.getBool('global_reminder_enabled') ?? true;
    if (!globalEnabled || frequency == 'none') return;

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
        scheduledTime = DateTime(now.year, now.month, now.day, 9, 0).add(Duration(days: daysUntilMonday));
        break;
      case 'monthly':
        scheduledTime = DateTime(now.year, now.month + 1, 1, 9, 0);
        break;
      default:
        return;
    }

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    final notificationId = 'goal_$goalId'.hashCode;

    await _notifications.zonedSchedule(
      notificationId,
      '目标提醒',
      '别忘了你的目标：$goalTitle',
      tzScheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'goal_reminders',
          '目标提醒',
          channelDescription: '目标提醒通知',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'goal:$goalId',
    );

    debugPrint('Scheduled goal reminder for $goalTitle at $tzScheduledTime');
  }

  Future<void> cancelReminder(String id) async {
    final notificationId = id.hashCode;
    await _notifications.cancel(notificationId);
    debugPrint('Cancelled reminder: $id');
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    debugPrint('Cancelled all reminders');
  }

  Future<List<PendingNotificationRequest>> getPendingReminders() async {
    return await _notifications.pendingNotificationRequests();
  }
}
