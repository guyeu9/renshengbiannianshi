import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'webdav_config_service.dart';
import 'backup_service.dart';
import '../../database/app_database.dart';
import '../../database/db_connection_io.dart' as dbconn;

const String backupTaskName = 'life_chronicle_backup';
const String backupTaskTag = 'backup';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    AppDatabase? db;
    try {
      final configService = WebDavConfigService();
      final config = await configService.loadConfig();
      
      if (config == null || !config.autoBackup) {
        return Future.value(true);
      }
      
      if (config.backupOnWifiOnly) {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult != ConnectivityResult.wifi) {
          return Future.value(true);
        }
      }
      
      final encryptionPassword = await configService.loadEncryptionPassword();
      if (encryptionPassword == null || encryptionPassword.isEmpty) {
        await _showNotification(
          title: '备份失败',
          body: '未设置加密密码',
          isError: true,
        );
        return Future.value(false);
      }
      
      db = AppDatabase.connect(dbconn.openConnection());
      final backupService = BackupService(db);
      
      await _showNotification(
        title: '开始备份',
        body: '正在执行自动备份...',
      );
      
      await backupService.performIncrementalBackup(
        config: config,
        encryptionPassword: encryptionPassword,
      );
      
      await _showNotification(
        title: '备份成功',
        body: '自动备份已完成',
      );
      
      await db.close();
      return Future.value(true);
    } catch (e) {
      debugPrint('Backup task failed: $e');
      await _showNotification(
        title: '备份失败',
        body: '自动备份出错: $e',
        isError: true,
      );
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

Future<void> _showNotification({
  required String title,
  required String body,
  bool isError = false,
}) async {
  final notifications = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await notifications.initialize(settings);
  
  const androidDetails = AndroidNotificationDetails(
    'backup_channel',
    '备份通知',
    channelDescription: '数据备份相关通知',
    importance: Importance.high,
    priority: Priority.high,
  );
  const iosDetails = DarwinNotificationDetails();
  const details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );
  
  await notifications.show(
    isError ? 2 : 1,
    title,
    body,
    details,
  );
}

class BackgroundBackupService {
  static final BackgroundBackupService _instance = BackgroundBackupService._internal();
  factory BackgroundBackupService() => _instance;
  BackgroundBackupService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(settings);
  }

  Future<void> registerPeriodicBackup({
    required String frequency,
    required bool wifiOnly,
  }) async {
    Duration duration;
    switch (frequency) {
      case 'daily':
        duration = const Duration(days: 1);
        break;
      case 'weekly':
        duration = const Duration(days: 7);
        break;
      case 'monthly':
        duration = const Duration(days: 30);
        break;
      default:
        duration = const Duration(days: 1);
    }

    await Workmanager().registerPeriodicTask(
      backupTaskName,
      backupTaskName,
      tag: backupTaskTag,
      frequency: duration,
      constraints: Constraints(
        networkType: wifiOnly ? NetworkType.unmetered : NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  Future<void> cancelBackup() async {
    await Workmanager().cancelByTag(backupTaskTag);
  }

  Future<void> showNotification({
    required String title,
    required String body,
    bool isError = false,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'backup_channel',
      '备份通知',
      channelDescription: '数据备份相关通知',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      isError ? 2 : 1,
      title,
      body,
      details,
    );
  }

  Future<bool> isWifiConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.wifi;
  }

  Future<bool> isNetworkAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
