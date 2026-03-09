import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/log_entry.dart';
import '../services/log_parser_service.dart';

final logParserServiceProvider = Provider<LogParserService>((ref) {
  return LogParserService();
});

final logEntriesProvider = StateNotifierProvider<LogNotifier, AsyncValue<List<LogEntry>>>((ref) {
  return LogNotifier(ref.watch(logParserServiceProvider));
});

final logFilterProvider = StateProvider<LogFilter>((ref) => const LogFilter());

final filteredLogEntriesProvider = Provider<List<LogEntry>>((ref) {
  final entries = ref.watch(logEntriesProvider).valueOrNull ?? [];
  final filter = ref.watch(logFilterProvider);
  return entries.where((entry) => filter.matches(entry)).toList();
});

final logStatsProvider = Provider<LogStats>((ref) {
  final entries = ref.watch(logEntriesProvider).valueOrNull ?? [];
  return LogStats.fromEntries(entries);
});

class LogNotifier extends StateNotifier<AsyncValue<List<LogEntry>>> {
  final LogParserService _parser;

  LogNotifier(this._parser) : super(const AsyncValue.loading()) {
    loadLogs();
  }

  Future<void> loadLogs() async {
    state = const AsyncValue.loading();
    try {
      final entries = await _parser.loadAllLogs();
      state = AsyncValue.data(entries);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await loadLogs();
  }

  Future<void> clearLogs() async {
    state = const AsyncValue.loading();
    try {
      await _parser.clearLogs();
      state = const AsyncValue.data([]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<String> exportToTxt(LogFilter filter) async {
    final entries = state.valueOrNull ?? [];
    final filtered = entries.where((entry) => filter.matches(entry)).toList();
    return _parser.exportToTxt(filtered);
  }
}

class LogStats {
  final int totalCount;
  final int errorCount;
  final int warnCount;
  final int infoCount;
  final int debugCount;
  final int todayCount;

  const LogStats({
    required this.totalCount,
    required this.errorCount,
    required this.warnCount,
    required this.infoCount,
    required this.debugCount,
    required this.todayCount,
  });

  factory LogStats.fromEntries(List<LogEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int errorCount = 0;
    int warnCount = 0;
    int infoCount = 0;
    int debugCount = 0;
    int todayCount = 0;

    for (final entry in entries) {
      switch (entry.level) {
        case LogLevel.error:
          errorCount++;
          break;
        case LogLevel.warn:
          warnCount++;
          break;
        case LogLevel.info:
          infoCount++;
          break;
        case LogLevel.debug:
          debugCount++;
          break;
      }

      if (entry.timestamp.isAfter(today)) {
        todayCount++;
      }
    }

    return LogStats(
      totalCount: entries.length,
      errorCount: errorCount,
      warnCount: warnCount,
      infoCount: infoCount,
      debugCount: debugCount,
      todayCount: todayCount,
    );
  }
}
