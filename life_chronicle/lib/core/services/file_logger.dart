import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel { debug, info, warn, error }

class FileLogger {
  static FileLogger? _instance;
  static FileLogger get instance => _instance ??= FileLogger._();
  FileLogger._();

  File? _logFile;
  static const int _maxLogSizeBytes = 2 * 1024 * 1024;
  static const int _maxLogFiles = 3;
  bool _initialized = false;
  
  static LogLevel minLevel = LogLevel.debug;
  static bool enableConsole = true;
  static bool enableFile = true;

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

  String _formatTimestamp() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
           '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';
  }

  String _levelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug: return 'DEBUG';
      case LogLevel.info:  return 'INFO ';
      case LogLevel.warn:  return 'WARN ';
      case LogLevel.error: return 'ERROR';
    }
  }

  bool _shouldLog(LogLevel level) {
    return level.index >= minLevel.index;
  }

  Future<void> log(String tag, String message) async {
    await logWithLevel(tag, message, LogLevel.info);
  }

  Future<void> logWithLevel(String tag, String message, LogLevel level) async {
    if (!_shouldLog(level)) return;
    
    final timestamp = _formatTimestamp();
    final levelStr = _levelPrefix(level);
    final logLine = '[$timestamp] [$levelStr] [$tag] $message\n';
    
    if (enableConsole) {
      final consoleOutput = '[$levelStr] [$tag] $message';
      if (level == LogLevel.error) {
        debugPrint('\x1B[31m$consoleOutput\x1B[0m');
      } else if (level == LogLevel.warn) {
        debugPrint('\x1B[33m$consoleOutput\x1B[0m');
      } else if (level == LogLevel.debug) {
        debugPrint('\x1B[90m$consoleOutput\x1B[0m');
      } else {
        debugPrint(consoleOutput);
      }
    }
    
    if (enableFile) {
      if (!_initialized) await init();
      try {
        await _logFile?.writeAsString(logLine, mode: FileMode.append);
      } catch (e) {
        debugPrint('[FileLogger] Write failed: $e');
      }
    }
  }

  Future<void> perf(String tag, String operation, int durationMs, {int? sizeBytes}) async {
    final sizeStr = sizeBytes != null ? ', size=${_formatBytes(sizeBytes)}' : '';
    final message = '[PERF] $operation: duration=${durationMs}ms$sizeStr';
    await logWithLevel(tag, message, LogLevel.info);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String maskApiKey(String? key) {
    if (key == null || key.isEmpty) return '<empty>';
    if (key.length <= 8) return '****';
    return '${key.substring(0, 4)}****${key.substring(key.length - 4)}';
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

Future<void> amapDebug(String tag, String message) async {
  await FileLogger.instance.logWithLevel(tag, message, LogLevel.debug);
}

Future<void> amapInfo(String tag, String message) async {
  await FileLogger.instance.logWithLevel(tag, message, LogLevel.info);
}

Future<void> amapWarn(String tag, String message) async {
  await FileLogger.instance.logWithLevel(tag, message, LogLevel.warn);
}

Future<void> amapError(String tag, String message) async {
  await FileLogger.instance.logWithLevel(tag, message, LogLevel.error);
}

Future<void> amapPerf(String tag, String operation, int durationMs, {int? sizeBytes}) async {
  await FileLogger.instance.perf(tag, operation, durationMs, sizeBytes: sizeBytes);
}

String maskApiKey(String? key) {
  return FileLogger.instance.maskApiKey(key);
}
