import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/services/restore_service.dart';

class TrashPage extends ConsumerStatefulWidget {
  const TrashPage({super.key});

  @override
  ConsumerState<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends ConsumerState<TrashPage> {
  List<DeletedRecord> _deletedRecords = [];
  bool _isLoading = true;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadDeletedRecords();
  }

  Future<void> _loadDeletedRecords() async {
    setState(() => _isLoading = true);
    
    final db = ref.read(appDatabaseProvider);
    final service = RestoreService(db);
    final records = await service.getAllDeletedRecords();
    
    if (mounted) {
      setState(() {
        _deletedRecords = records;
        _isLoading = false;
      });
    }
  }

  Future<void> _restoreRecord(DeletedRecord record) async {
    final db = ref.read(appDatabaseProvider);
    final service = RestoreService(db);
    await service.restoreRecord(record.type, record.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已恢复: ${record.title}')),
      );
      _loadDeletedRecords();
    }
  }

  Future<void> _restoreSelected() async {
    if (_selectedIds.isEmpty) return;
    
    final db = ref.read(appDatabaseProvider);
    final service = RestoreService(db);
    
    final selectedRecords = _deletedRecords
        .where((r) => _selectedIds.contains('${r.type}_${r.id}'))
        .map((r) => (type: r.type, id: r.id))
        .toList();
    
    await service.restoreMultiple(selectedRecords);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已恢复 ${selectedRecords.length} 条记录')),
      );
      _selectedIds.clear();
      _loadDeletedRecords();
    }
  }

  Future<void> _permanentlyDelete(DeletedRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('永久删除'),
        content: Text('确定要永久删除"${record.title}"吗？此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('永久删除'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final db = ref.read(appDatabaseProvider);
      final service = RestoreService(db);
      await service.permanentlyDelete(record.type, record.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已永久删除')),
        );
        _loadDeletedRecords();
      }
    }
  }

  Future<void> _emptyTrash() async {
    if (_deletedRecords.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空回收站'),
        content: Text('确定要永久删除全部 ${_deletedRecords.length} 条记录吗？此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final db = ref.read(appDatabaseProvider);
      final service = RestoreService(db);
      final count = await service.emptyTrash();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已清空 $count 条记录')),
        );
        _loadDeletedRecords();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.white60 : Colors.black54;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('回收站 (${_deletedRecords.length})'),
        backgroundColor: surfaceColor,
        foregroundColor: textMain,
        elevation: 0,
        actions: [
          if (_selectedIds.isNotEmpty)
            TextButton(
              onPressed: _restoreSelected,
              child: Text('恢复选中 (${_selectedIds.length})'),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'empty') {
                _emptyTrash();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'empty',
                child: Text('清空回收站'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _deletedRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, size: 64, color: textMuted),
                      const SizedBox(height: 16),
                      Text('回收站是空的', style: TextStyle(color: textMuted, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _deletedRecords.length,
                  itemBuilder: (ctx, index) {
                    final record = _deletedRecords[index];
                    final key = '${record.type}_${record.id}';
                    final isSelected = _selectedIds.contains(key);
                    
                    return Card(
                      color: surfaceColor,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedIds.add(key);
                              } else {
                                _selectedIds.remove(key);
                              }
                            });
                          },
                        ),
                        title: Text(record.title),
                        subtitle: Text(
                          '${record.typeName} · ${DateFormat('yyyy-MM-dd HH:mm').format(record.deletedAt)}删除',
                          style: TextStyle(color: textMuted, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.restore),
                              onPressed: () => _restoreRecord(record),
                              tooltip: '恢复',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_forever, color: Colors.red[400]),
                              onPressed: () => _permanentlyDelete(record),
                              tooltip: '永久删除',
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedIds.remove(key);
                            } else {
                              _selectedIds.add(key);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
