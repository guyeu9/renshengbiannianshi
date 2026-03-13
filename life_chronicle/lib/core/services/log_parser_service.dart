import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/log_entry.dart';
import 'file_logger.dart' hide LogLevel;

class LogParserService {
  static final RegExp _logLineRegex = RegExp(
    r'^\[(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\.\d{3})\]\s+\[(DEBUG|INFO\s|WARN\s|ERROR)\]\s+\[([^\]]+)\]\s+(.*)$',
  );

  Future<List<LogEntry>> parseLogFile(String content) async {
    final lines = content.split('\n');
    final entries = <LogEntry>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      final entry = parseLine(line);
      if (entry != null) {
        entries.add(entry);
      }
    }

    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  LogEntry? parseLine(String line) {
    if (line.trim().isEmpty) return null;

    final match = _logLineRegex.firstMatch(line);
    if (match == null) {
      return LogEntry(
        timestamp: DateTime.now(),
        level: LogLevel.info,
        tag: 'unknown',
        message: line,
        rawLine: line,
      );
    }

    final timestampStr = match.group(1)!;
    final levelStr = match.group(2)!.trim();
    final tag = match.group(3)!;
    final restOfLine = match.group(4)!;

    DateTime timestamp;
    try {
      timestamp = DateTime.parse(timestampStr);
    } catch (e) {
      debugPrint('时间戳解析失败: $e, 使用当前时间代替');
      timestamp = DateTime.now();
    }

    LogLevel level;
    switch (levelStr.toUpperCase()) {
      case 'DEBUG':
        level = LogLevel.debug;
        break;
      case 'INFO':
        level = LogLevel.info;
        break;
      case 'WARN':
        level = LogLevel.warn;
        break;
      case 'ERROR':
        level = LogLevel.error;
        break;
      default:
        level = LogLevel.info;
    }

    String message = restOfLine;
    Map<String, dynamic>? data;
    String? stackTrace;

    final dataMatch = RegExp(r'\| 数据: (.+)$').firstMatch(message);
    if (dataMatch != null) {
      try {
        data = jsonDecode(dataMatch.group(1)!) as Map<String, dynamic>;
        message = message.substring(0, dataMatch.start).trim();
      } catch (e) {
        debugPrint('日志数据JSON解析失败: $e');
      }
    }

    final stackMatch = RegExp(r'堆栈: (.+)$').firstMatch(message);
    if (stackMatch != null) {
      stackTrace = stackMatch.group(1);
      message = message.substring(0, stackMatch.start).trim();
    }

    return LogEntry(
      timestamp: timestamp,
      level: level,
      tag: tag,
      message: message,
      data: data,
      stackTrace: stackTrace,
      rawLine: line,
    );
  }

  Future<List<LogEntry>> loadAllLogs() async {
    final content = await FileLogger.instance.getLogContent();
    if (content == null || content.isEmpty) {
      return [];
    }
    return parseLogFile(content);
  }

  Future<List<LogEntry>> loadLogsWithFilter(LogFilter filter) async {
    final allEntries = await loadAllLogs();
    return allEntries.where((entry) => filter.matches(entry)).toList();
  }

  String exportToTxt(List<LogEntry> entries) {
    final buffer = StringBuffer();
    buffer.writeln('=== 系统日志导出 ===');
    buffer.writeln('导出时间: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('日志条数: ${entries.length}');
    buffer.writeln('');
    buffer.writeln('=' * 60);
    buffer.writeln('');

    for (final entry in entries) {
      buffer.write(entry.toExportString());
      buffer.writeln('-' * 40);
    }

    return buffer.toString();
  }

  Future<void> clearLogs() async {
    await FileLogger.instance.clearLog();
  }
}
