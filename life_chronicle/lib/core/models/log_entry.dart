import 'dart:convert';

enum LogLevel { debug, info, warn, error }

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final Map<String, dynamic>? data;
  final String? stackTrace;
  final String? rawLine;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.data,
    this.stackTrace,
    this.rawLine,
  });

  String get levelString {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warn:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  String get levelEmoji {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warn:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }

  String formatTimestamp() {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  String formatTime() {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  String toExportString() {
    final buffer = StringBuffer();
    buffer.writeln('[${formatTimestamp()}] [$levelString] [$tag] $message');
    if (data != null && data!.isNotEmpty) {
      buffer.writeln('  数据: $data');
    }
    if (stackTrace != null && stackTrace!.isNotEmpty) {
      buffer.writeln('  堆栈: $stackTrace');
    }
    return buffer.toString();
  }

  String toFullString() {
    final buffer = StringBuffer();
    buffer.writeln('[$levelString] [$tag] ${formatTimestamp()}');
    buffer.writeln('消息: $message');
    if (data != null && data!.isNotEmpty) {
      buffer.writeln('数据: ${const JsonEncoder.withIndent('  ').convert(data)}');
    }
    if (stackTrace != null && stackTrace!.isNotEmpty) {
      buffer.writeln('堆栈跟踪:');
      buffer.writeln(stackTrace);
    }
    return buffer.toString();
  }
}

class LogFilter {
  final String keyword;
  final bool caseSensitive;
  final Set<LogLevel> levels;
  final DateTime? startTime;
  final DateTime? endTime;

  const LogFilter({
    this.keyword = '',
    this.caseSensitive = false,
    this.levels = const {},
    this.startTime,
    this.endTime,
  });

  bool get hasKeyword => keyword.isNotEmpty;
  bool get hasLevelFilter => levels.isNotEmpty;
  bool get hasTimeFilter => startTime != null || endTime != null;

  LogFilter copyWith({
    String? keyword,
    bool? caseSensitive,
    Set<LogLevel>? levels,
    DateTime? startTime,
    DateTime? endTime,
    bool clearStartTime = false,
    bool clearEndTime = false,
  }) {
    return LogFilter(
      keyword: keyword ?? this.keyword,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      levels: levels ?? this.levels,
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
    );
  }

  bool matches(LogEntry entry) {
    if (hasLevelFilter && !levels.contains(entry.level)) {
      return false;
    }

    if (startTime != null && entry.timestamp.isBefore(startTime!)) {
      return false;
    }

    if (endTime != null && entry.timestamp.isAfter(endTime!)) {
      return false;
    }

    if (hasKeyword) {
      final searchIn = caseSensitive
          ? '${entry.tag} ${entry.message} ${entry.data} ${entry.stackTrace}'
          : '${entry.tag} ${entry.message} ${entry.data} ${entry.stackTrace}'.toLowerCase();
      final searchTerm = caseSensitive ? keyword : keyword.toLowerCase();
      if (!searchIn.contains(searchTerm)) {
        return false;
      }
    }

    return true;
  }
}
