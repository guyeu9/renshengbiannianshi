import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileLogger {
  static FileLogger? _instance;
  static FileLogger get instance => _instance ??= FileLogger._();
  FileLogger._();

  File? _logFile;
  static const int _maxLogSizeBytes = 2 * 1024 * 1024;
  static const int _maxLogFiles = 3;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${dir.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      final now = DateTime.now();
      final fileName = 'amap_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.log';
      _logFile = File('${logDir.path}/$fileName');
      await _cleanOldLogs(logDir);
      _initialized = true;
      debugPrint('[FileLogger] Initialized at ${_logFile?.path}');
    } catch (e) {
      debugPrint('[FileLogger] Init failed: $e');
    }
  }

  Future<void> _cleanOldLogs(Directory logDir) async {
    try {
      final files = await logDir.list().where((f) => f.path.endsWith('.log')).toList();
      if (files.length > _maxLogFiles) {
        files.sort((a, b) => a.path.compareTo(b.path));
        for (int i = 0; i < files.length - _maxLogFiles; i++) {
          await files[i].delete();
          debugPrint('[FileLogger] Deleted old log: ${files[i].path}');
        }
      }
      for (final file in files) {
        if (file is File) {
          final size = await file.length();
          if (size > _maxLogSizeBytes) {
            await file.delete();
            debugPrint('[FileLogger] Deleted oversized log: ${file.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('[FileLogger] Clean old logs failed: $e');
    }
  }

  Future<void> log(String tag, String message) async {
    if (!_initialized) await init();
    final timestamp = DateTime.now().toString();
    final logLine = '[$timestamp] [$tag] $message\n';
    debugPrint('[$tag] $message');
    try {
      await _logFile?.writeAsString(logLine, mode: FileMode.append);
    } catch (e) {
      debugPrint('[FileLogger] Write failed: $e');
    }
  }

  Future<String?> getLogContent() async {
    if (!_initialized) await init();
    try {
      if (_logFile != null && await _logFile!.exists()) {
        return await _logFile!.readAsString();
      }
    } catch (e) {
      debugPrint('[FileLogger] Read failed: $e');
    }
    return null;
  }

  Future<String?> getLogFilePath() async {
    if (!_initialized) await init();
    return _logFile?.path;
  }

  Future<void> clearLog() async {
    try {
      if (_logFile != null && await _logFile!.exists()) {
        await _logFile!.delete();
        debugPrint('[FileLogger] Log cleared');
      }
    } catch (e) {
      debugPrint('[FileLogger] Clear failed: $e');
    }
  }

  Future<List<String>> listLogFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${dir.path}/logs');
      if (!await logDir.exists()) return [];
      final files = await logDir.list().where((f) => f.path.endsWith('.log')).toList();
      return files.map((f) => f.path).toList()..sort();
    } catch (e) {
      debugPrint('[FileLogger] List logs failed: $e');
      return [];
    }
  }
}

Future<void> amapLog(String tag, String message) async {
  await FileLogger.instance.log(tag, message);
}
