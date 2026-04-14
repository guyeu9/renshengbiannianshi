import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

typedef NotificationTapCallback = void Function(String type, String entityId);

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService.instance;
});

class ReminderService {
  static final ReminderService instance = ReminderService._internal();
  ReminderService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  NotificationTapCallback? _onTapCallback;
  GoRouter? _router;

  void setOnTapCallback(NotificationTapCallback callback) {
    _onTapCallback = callback;
  }

  void setRouter(GoRouter router) {
    _router = router;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

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
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    debugPrint('Notification tapped: $payload');

    final parts = payload.split(':');
    if (parts.length != 2) return;

    final type = parts[0];
    final entityId = parts[1];

    if (_onTapCallback != null) {
      _onTapCallback!(type, entityId);
      return;
    }

    _defaultNavigate(type, entityId);
  }

  void _defaultNavigate(String type, String entityId) {
    try {
      final router = _router;
      if (router == null) return;
      switch (type) {
        case 'birthday':
        case 'contact':
          router.push('/bond/friend/$entityId');
          break;
        case 'goal':
          router.push('/goal/$entityId');
          break;
      }
    } catch (e) {
      debugPrint('Failed to navigate from notification: $e');
    }
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

    if (nextBirthday.isBefore(DateTime(now.year, now.month, now.day))) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
    }

    final reminderDate = nextBirthday.subtract(Duration(days: daysBefore));

    if (reminderDate.isBefore(now)) {
      return;
    }

    var scheduledTime = DateTime(reminderDate.year, reminderDate.month, reminderDate.day, 9, 0);
    scheduledTime = _applyDoNotDisturb(scheduledTime, prefs);

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    final notificationId = 'birthday_$friendId'.hashCode;

    await _notifications.zonedSchedule(
      notificationId,
      '生日提醒',
      '$friendName的生日还有$daysBefore天就要到了！',
      tzScheduledTime,
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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'birthday:$friendId',
    );

    debugPrint('Scheduled birthday reminder for $friendName at $tzScheduledTime');
  }

  Future<void> scheduleContactReminder({
    required String friendId,
    required String friendName,
    required int intervalDays,
    DateTime? scheduledTime,
  }) async {
    if (!_initialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final globalEnabled = prefs.getBool('global_reminder_enabled') ?? true;
    if (!globalEnabled) return;

    final effectiveScheduledTime = scheduledTime ?? DateTime.now().add(Duration(days: intervalDays));
    final tzScheduledTime = tz.TZDateTime.from(effectiveScheduledTime, tz.local);
    final notificationId = 'contact_$friendId'.hashCode;

    await _notifications.zonedSchedule(
      notificationId,
      '联络提醒',
      '已经$intervalDays天没联系$friendName了，该打个招呼啦！',
      tzScheduledTime,
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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'contact:$friendId',
    );

    debugPrint('Scheduled contact reminder for $friendName at $tzScheduledTime');
  }

  Future<void> scheduleGoalReminder({
    required String goalId,
    required String goalTitle,
    required String frequency,
    DateTime? scheduledTime,
  }) async {
    if (!_initialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final globalEnabled = prefs.getBool('global_reminder_enabled') ?? true;
    if (!globalEnabled || frequency == 'none') return;

    DateTime effectiveScheduledTime;
    if (scheduledTime != null) {
      effectiveScheduledTime = scheduledTime;
    } else {
      final now = DateTime.now();
      switch (frequency) {
        case 'daily':
          effectiveScheduledTime = DateTime(now.year, now.month, now.day, 9, 0);
          if (effectiveScheduledTime.isBefore(now)) {
            effectiveScheduledTime = effectiveScheduledTime.add(const Duration(days: 1));
          }
          break;
        case 'weekly':
          final daysUntilMonday = (8 - now.weekday) % 7;
          if (daysUntilMonday == 0 && now.weekday == DateTime.monday) {
            final today9am = DateTime(now.year, now.month, now.day, 9, 0);
            if (today9am.isAfter(now)) {
              effectiveScheduledTime = today9am;
            } else {
              effectiveScheduledTime = DateTime(now.year, now.month, now.day, 9, 0).add(const Duration(days: 7));
            }
          } else {
            effectiveScheduledTime = DateTime(now.year, now.month, now.day, 9, 0).add(Duration(days: daysUntilMonday));
          }
          break;
        case 'monthly':
          effectiveScheduledTime = DateTime(now.year, now.month + 1, 1, 9, 0);
          break;
        default:
          return;
      }
      effectiveScheduledTime = _applyDoNotDisturb(effectiveScheduledTime, prefs);
    }

    final tzScheduledTime = tz.TZDateTime.from(effectiveScheduledTime, tz.local);
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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'goal:$goalId',
    );

    debugPrint('Scheduled goal reminder for $goalTitle at $tzScheduledTime');
  }

  DateTime _applyDoNotDisturb(DateTime scheduledTime, SharedPreferences prefs) {
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

  Future<void> showTestNotification() async {
    if (!_initialized) await initialize();

    await _notifications.show(
      999999,
      '测试通知',
      '如果你看到这条通知，说明通知系统工作正常！',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'test_notifications',
          '测试通知',
          channelDescription: '用于测试通知是否正常工作',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    debugPrint('Test notification sent');
  }
}
