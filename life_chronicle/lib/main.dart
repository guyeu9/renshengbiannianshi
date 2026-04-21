import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/services/backup/background_backup_service.dart';
import 'core/services/file_logger.dart';
import 'core/services/notification/reminder_scheduler.dart';
import 'core/services/notification/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FileLogger.instance.init();
  
  FlutterError.onError = (FlutterErrorDetails details) {
    FileLogger.instance.logWithLevel('FlutterError', '${details.exception}\n${details.stack}', LogLevel.error);
  };

  final backgroundBackupService = BackgroundBackupService();
  await backgroundBackupService.initialize();

  await _initReminderSystem();

  runZonedGuarded(() {
    runApp(const ProviderScope(child: LifeChronicleApp()));
  }, (error, stack) {
    debugPrint('Global error: $error');
    debugPrintStack(stackTrace: stack);
    FileLogger.instance.logWithLevel('Global', 'Unhandled error: $error\n$stack', LogLevel.error);
  });
}

Future<void> _initReminderSystem() async {
  try {
    await ReminderService.instance.initialize();
    final db = AppDatabase();
    await ReminderScheduler.instance.scheduleAllReminders(db);
  } catch (e) {
    debugPrint('Failed to initialize reminder system: $e');
  }
}
