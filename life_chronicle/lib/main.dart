import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/backup/background_backup_service.dart';
import 'core/services/file_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FileLogger.instance.init();
  
  final backgroundBackupService = BackgroundBackupService();
  await backgroundBackupService.initialize();
  
  runZonedGuarded(() {
    runApp(const ProviderScope(child: LifeChronicleApp()));
  }, (error, stack) {
    debugPrint('Global error: $error');
    debugPrintStack(stackTrace: stack);
    FileLogger.instance.logWithLevel('Global', 'Unhandled error: $error\n$stack', LogLevel.error);
  });
}
