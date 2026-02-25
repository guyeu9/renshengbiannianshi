// bond_page.dart
// 本文件已重构：将 EncounterCreatePage 和 EncounterDetailPage 提取到 encounter_pages.dart
// 辅助函数和组件类已移至文件顶部，避免前向引用错误

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import 'bond_filter_components.dart';
import 'encounter_pages.dart';

// ==================== Provider ====================

final friendsStreamProvider = StreamProvider<List<FriendRecord>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.friendDao.watchAllActive();
});

// ==================== 顶层辅助函数（必须在类定义之前声明）====================

Widget _buildLocalImage(String path, {BoxFit fit = BoxFit.cover}) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) {
    return const SizedBox.shrink();
  }
  final isNetwork = trimmed.startsWith('http://') || trimmed.startsWith('https://');
  if (isNetwork) {
    return Image.network(trimmed, fit: fit, gaplessPlayback: true);
  }
  return Image.file(File(trimmed), fit: fit, gaplessPlayback: true);
}



List<String> _parseTags(String? raw) {
  if (raw == null || raw.trim().isEmpty) return [];
  return raw
      .split(RegExp(r'[,，]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

List<String> _tagsOrFallback(String? raw, String fallback) {
  final list = _parseTags(raw);
  return list.isEmpty ? [fallback] : list;
}

String _formatLastMeet(DateTime? dt) {
  if (dt == null) return '—';
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return '今天';
  if (diff.inDays == 1) return '昨天';
  if (diff.inDays < 7) return '${diff.inDays}天前';
  if (diff.inDays < 30) return '${diff.inDays ~/ 7}周前';
  if (diff.inDays < 365) return '${diff.inDays ~/ 30}个月前';
  return '${diff.inDays ~/ 365}年前';
}

String _formatBirthday(DateTime? dt) {
  if (dt == null) return '';
  return DateFormat('MM-dd').format(dt);
}

// ==================== 扩展方法 ====================

extension FilterResultMatcher on FilterResult {
  bool matches(FriendRecord friend) {
    // 检查好友ID筛选
    if (friendIds.isNotEmpty && !friendIds.contains(friend.id)) {
      return false;
    }

    // 检查日期筛选
    if (dateIndex == 0) return true; // 不限

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime? startDate;
    switch (dateIndex) {
      case 1: // 今日
        startDate = today;
        break;
      case 2: // 近7天
        startDate = today.subtract(const Duration(days: 7));
        break;
      case 3: // 近30天
        startDate = today.subtract(const Duration(days: 30));
        break;
      case 4: // 自定义
        if (customRange != null) {
          startDate = customRange!.start;
        }
        break;
    }

    if (startDate == null) return true;

    // 这里简化处理，实际应该检查相遇记录的日期
    // 暂时返回 true，因为 FriendRecord 本身没有日期字段
    return true;
  }
}

// ==================== 小型辅助组件类（必须在类定义之前声明）====================

class _AvatarCircle extends StatelessWidget {
  final String? url;
  final double size;
  const _AvatarCircle({this.url, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null && url!.isNotEmpty
          ? _buildLocalImage(url!, fit: BoxFit.cover)
          : Center(child: Icon(Icons.person, size: size * 0.5, color: theme.colorScheme.outline)),
    );
  }
}

// ==================== 主页面类 ====================

class BondPage extends StatefulWidget {
  const BondPage({super.key});

  @override
  State<BondPage> createState() => _BondPageState();
}

class _BondPageState extends State<BondPage> {
  String _query = '';
  FilterResult? _filter;

  Future<void> _showFilterSheet(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final result = await showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FilterBottomSheet(
        initialDateIndex: _filter?.dateIndex ?? 0,
        initialCustomRange: _filter?.customRange,
        initialFriendIds: _filter?.friendIds ?? {},
        friendsStream: db.friendDao.watchAllActive(),
      ),
    );
    if (result != null) {
      setState(() => _filter = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('羁绊'),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              return IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterSheet(context, ref),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索好友...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final friendsAsync = ref.watch(friendsStreamProvider);
                return friendsAsync.when(
                  data: (friends) {
                    var list = friends.where((f) {
                      final matchQuery = _query.isEmpty ||
                          (f.name.toLowerCase().contains(_query.toLowerCase()));
                      final matchFilter = _filter?.matches(f) ?? true;
                      return matchQuery && matchFilter;
                    }).toList();

                    if (list.isEmpty) {
                      return const Center(child: Text('暂无好友'));
                    }

                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final friend = list[index];
                        return _FriendCard(friend: friend);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('加载失败: $e')),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EncounterCreatePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final FriendRecord friend;
  const _FriendCard({required this.friend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = _tagsOrFallback(friend.impressionTags, '好友');
    final lastMeet = _formatLastMeet(friend.lastMeetDate);
    final birthday = _formatBirthday(friend.birthday);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _AvatarCircle(url: friend.avatarPath, size: 48),
        title: Text(friend.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: tags.map((tag) => Chip(
                label: Text(tag),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
            const SizedBox(height: 4),
            Text('上次见面: $lastMeet', style: theme.textTheme.bodySmall),
            if (birthday.isNotEmpty)
              Text('生日: $birthday', style: theme.textTheme.bodySmall),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EncounterDetailPage(encounterId: friend.id)),
          );
        },
      ),
    );
  }
}
