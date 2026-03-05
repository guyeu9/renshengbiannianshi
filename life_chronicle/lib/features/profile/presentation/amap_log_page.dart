import 'package:flutter/material.dart';
import '../../../core/services/file_logger.dart';

class AmapLogPage extends StatefulWidget {
  const AmapLogPage({super.key});

  @override
  State<AmapLogPage> createState() => _AmapLogPageState();
}

class _AmapLogPageState extends State<AmapLogPage> {
  String? _logContent;
  bool _loading = true;
  String? _logPath;

  @override
  void initState() {
    super.initState();
    _loadLog();
  }

  Future<void> _loadLog() async {
    setState(() => _loading = true);
    try {
      final content = await FileLogger.instance.getLogContent();
      final path = await FileLogger.instance.getLogFilePath();
      setState(() {
        _logContent = content ?? '暂无日志';
        _logPath = path;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _logContent = '读取日志失败: $e';
        _loading = false;
      });
    }
  }

  Future<void> _clearLog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空日志'),
        content: const Text('确定要清空地图诊断日志吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await FileLogger.instance.clearLog();
      await _loadLog();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日志已清空')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101F22) : const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A2E31) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '地图诊断日志',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black),
            onPressed: _loadLog,
            tooltip: '刷新',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _clearLog,
            tooltip: '清空',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_logPath != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                    child: Text(
                      '日志路径: $_logPath',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      _logContent ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
