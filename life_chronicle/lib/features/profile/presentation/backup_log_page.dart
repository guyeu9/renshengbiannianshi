import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';

class BackupLogPage extends ConsumerStatefulWidget {
  const BackupLogPage({super.key});

  @override
  ConsumerState<BackupLogPage> createState() => _BackupLogPageState();
}

class _BackupLogPageState extends ConsumerState<BackupLogPage> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final db = ref.watch(appDatabaseProvider);

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
          '备份日志',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterTabs(isDark),
          Expanded(
            child: StreamBuilder<List<BackupLog>>(
              stream: _selectedFilter == 'all'
                  ? db.backupLogDao.watchAll()
                  : db.backupLogDao.watchByStorageType(_selectedFilter),
              builder: (context, snapshot) {
                final logs = snapshot.data ?? [];

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (logs.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    return _buildLogCard(logs[index], isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    final tabs = [
      {'key': 'all', 'label': '全部'},
      {'key': 'local', 'label': '本地'},
      {'key': 'webdav', 'label': '云端'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedFilter == tab['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Text(tab['label'] as String),
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = tab['key'] as String;
                });
              },
              selectedColor: AppTheme.primary,
              backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.primary : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无备份记录',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '完成备份后记录将显示在这里',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[600] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(BackupLog log, bool isDark) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final statusInfo = _getStatusInfo(log.status);
    final typeInfo = _getTypeInfo(log.backupType, log.storageType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeInfo['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      typeInfo['icon'] as IconData,
                      size: 14,
                      color: typeInfo['color'],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      typeInfo['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: typeInfo['color'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusInfo['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusInfo['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusInfo['color'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                dateFormat.format(log.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.insert_drive_file_outlined,
                  '文件名',
                  log.fileName,
                  isDark,
                ),
              ),
              if (log.fileSize != null) ...[
                const SizedBox(width: 16),
                _buildInfoItem(
                  Icons.storage_outlined,
                  '大小',
                  _formatFileSize(log.fileSize!),
                  isDark,
                ),
              ],
            ],
          ),
          if (log.recordCount != null || log.mediaCount != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (log.recordCount != null)
                  _buildInfoItem(
                    Icons.data_object,
                    '记录数',
                    '${log.recordCount}',
                    isDark,
                  ),
                if (log.recordCount != null && log.mediaCount != null)
                  const SizedBox(width: 16),
                if (log.mediaCount != null)
                  _buildInfoItem(
                    Icons.image_outlined,
                    '媒体数',
                    '${log.mediaCount}',
                    isDark,
                  ),
              ],
            ),
          ],
          if (log.status == 'completed' && log.completedAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '耗时: ${_formatDuration(log.startedAt, log.completedAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
          if (log.status == 'failed' && log.errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 14,
                    color: Colors.red[400],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      log.errorMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'completed':
        return {'label': '成功', 'color': Colors.green};
      case 'failed':
        return {'label': '失败', 'color': Colors.red};
      case 'in_progress':
        return {'label': '进行中', 'color': Colors.orange};
      default:
        return {'label': '未知', 'color': Colors.grey};
    }
  }

  Map<String, dynamic> _getTypeInfo(String backupType, String storageType) {
    final isFull = backupType == 'full';
    final isLocal = storageType == 'local';

    if (isLocal) {
      return {
        'label': isFull ? '本地全量' : '本地增量',
        'icon': Icons.phone_android,
        'color': Colors.blue,
      };
    } else {
      return {
        'label': isFull ? '云端全量' : '云端增量',
        'icon': Icons.cloud_outlined,
        'color': Colors.purple,
      };
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}秒';
    }
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}分${duration.inSeconds % 60}秒';
    }
    return '${duration.inHours}时${duration.inMinutes % 60}分';
  }
}
