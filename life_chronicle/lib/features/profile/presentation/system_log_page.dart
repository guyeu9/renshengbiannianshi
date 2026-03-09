import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/log_entry.dart';
import '../../core/providers/log_providers.dart';

class SystemLogPage extends ConsumerStatefulWidget {
  const SystemLogPage({super.key});

  @override
  ConsumerState<SystemLogPage> createState() => _SystemLogPageState();
}

class _SystemLogPageState extends ConsumerState<SystemLogPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  LogEntry? _selectedEntry;
  int _timeFilterIndex = 2;

  final List<String> _timeFilterOptions = ['今日', '近7天', '全部'];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleLevelFilter(LogLevel level) {
    final currentFilter = ref.read(logFilterProvider);
    final newLevels = Set<LogLevel>.from(currentFilter.levels);
    if (newLevels.contains(level)) {
      newLevels.remove(level);
    } else {
      newLevels.add(level);
    }
    ref.read(logFilterProvider.notifier).state = currentFilter.copyWith(levels: newLevels);
  }

  void _setTimeFilter(int index) {
    setState(() {
      _timeFilterIndex = index;
    });

    final currentFilter = ref.read(logFilterProvider);
    final now = DateTime.now();

    DateTime? startTime;
    DateTime? endTime;

    switch (index) {
      case 0:
        startTime = DateTime(now.year, now.month, now.day);
        break;
      case 1:
        startTime = now.subtract(const Duration(days: 7));
        break;
      case 2:
        break;
    }

    ref.read(logFilterProvider.notifier).state = currentFilter.copyWith(
      startTime: startTime,
      endTime: endTime,
      clearStartTime: index == 2,
      clearEndTime: true,
    );
  }

  Future<void> _exportLogs() async {
    try {
      final filter = ref.read(logFilterProvider);
      final content = await ref.read(logEntriesProvider.notifier).exportToTxt(filter);

      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final fileName = 'system_log_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.txt';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(content);

      if (mounted) {
        await Share.shareXFiles([XFile(file.path)], subject: '系统日志导出');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空日志'),
        content: const Text('确定要清空所有日志吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(logEntriesProvider.notifier).clearLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日志已清空')),
        );
      }
    }
  }

  void _showDetailSheet(LogEntry entry) {
    setState(() {
      _selectedEntry = entry;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LogDetailSheet(
        entry: entry,
        onCopy: () => _copyEntry(entry),
      ),
    ).whenComplete(() {
      setState(() {
        _selectedEntry = null;
      });
    });
  }

  void _copyEntry(LogEntry entry) {
    Clipboard.setData(ClipboardData(text: entry.toFullString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(logEntriesProvider);
    final filteredEntries = ref.watch(filteredLogEntriesProvider);
    final stats = ref.watch(logStatsProvider);
    final filter = ref.watch(logFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        title: const Text('系统日志', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _exportLogs,
            tooltip: '导出',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearLogs,
            tooltip: '清空',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsBar(stats),
          _buildSearchBar(),
          _buildFilterBar(filter),
          Expanded(
            child: entriesAsync.when(
              data: (_) => filteredEntries.isEmpty
                  ? _buildEmptyState()
                  : _buildLogList(filteredEntries),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(LogStats stats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          _buildStatItem('❌', stats.errorCount, Colors.red),
          const SizedBox(width: 16),
          _buildStatItem('⚠️', stats.warnCount, Colors.orange),
          const SizedBox(width: 16),
          _buildStatItem('ℹ️', stats.infoCount, Colors.blue),
          const SizedBox(width: 16),
          _buildStatItem('📊', stats.todayCount, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索日志...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(logFilterProvider.notifier).state = ref.read(logFilterProvider).copyWith(keyword: '');
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF2F4F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          ref.read(logFilterProvider.notifier).state = ref.read(logFilterProvider).copyWith(keyword: value);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildFilterBar(LogFilter filter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildLevelChip('全部', null, filter.levels.isEmpty),
                  _buildLevelChip('ERROR', LogLevel.error, filter.levels.contains(LogLevel.error)),
                  _buildLevelChip('WARN', LogLevel.warn, filter.levels.contains(LogLevel.warn)),
                  _buildLevelChip('INFO', LogLevel.info, filter.levels.contains(LogLevel.info)),
                  _buildLevelChip('DEBUG', LogLevel.debug, filter.levels.contains(LogLevel.debug)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<int>(
              value: _timeFilterIndex,
              underline: const SizedBox(),
              items: _timeFilterOptions.asMap().entries.map((e) {
                return DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (index) {
                if (index != null) _setTimeFilter(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelChip(String label, LogLevel? level, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          if (level == null) {
            ref.read(logFilterProvider.notifier).state = ref.read(logFilterProvider).copyWith(levels: {});
          } else {
            _toggleLevelFilter(level);
          }
        },
        backgroundColor: const Color(0xFFF2F4F6),
        selectedColor: const Color(0xFF4F46E5).withValues(alpha: 0.2),
        checkmarkColor: const Color(0xFF4F46E5),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.article_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('暂无日志记录', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => ref.read(logEntriesProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList(List<LogEntry> entries) {
    return RefreshIndicator(
      onRefresh: () => ref.read(logEntriesProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _LogListTile(
            entry: entry,
            isSelected: _selectedEntry == entry,
            onTap: () => _showDetailSheet(entry),
          );
        },
      ),
    );
  }
}

class _LogListTile extends StatelessWidget {
  const _LogListTile({
    required this.entry,
    required this.isSelected,
    required this.onTap,
  });

  final LogEntry entry;
  final bool isSelected;
  final VoidCallback onTap;

  Color _getLevelColor() {
    switch (entry.level) {
      case LogLevel.error:
        return Colors.red;
      case LogLevel.warn:
        return Colors.orange;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.debug:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 0,
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Colors.blue.shade200)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getLevelColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.levelString,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getLevelColor(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.tag,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    entry.formatTime(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.message,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogDetailSheet extends StatelessWidget {
  const _LogDetailSheet({
    required this.entry,
    required this.onCopy,
  });

  final LogEntry entry;
  final VoidCallback onCopy;

  Color _getLevelColor() {
    switch (entry.level) {
      case LogLevel.error:
        return Colors.red;
      case LogLevel.warn:
        return Colors.orange;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.debug:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getLevelColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${entry.levelEmoji} ${entry.levelString}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _getLevelColor(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.tag,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            entry.formatTimestamp(),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('消息', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(entry.message),
                      ),
                      if (entry.data != null && entry.data!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text('上下文数据', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            entry.data.toString(),
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        ),
                      ],
                      if (entry.stackTrace != null && entry.stackTrace!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text('堆栈跟踪', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            entry.stackTrace!,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy),
                      label: const Text('复制全部'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
