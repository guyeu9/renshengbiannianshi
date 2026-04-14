import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/router/route_navigation.dart';
import '../providers/reminder_provider.dart';

final _selectedTypeProvider = StateProvider<String?>((ref) => null);

class ReminderListPage extends ConsumerStatefulWidget {
  const ReminderListPage({super.key});

  @override
  ConsumerState<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends ConsumerState<ReminderListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCountAsync = ref.watch(unreadReminderCountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '提醒',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1F2937)),
            ),
            unreadCountAsync.when(
              data: (count) => count > 0
                  ? Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF374151)),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => _markAllAsRead(),
            child: const Text('全部已读', style: TextStyle(fontSize: 13)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: AppTheme.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          onTap: (index) {
            final types = [null, 'birthday', 'contact', 'goal'];
            ref.read(_selectedTypeProvider.notifier).state = types[index];
          },
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '生日'),
            Tab(text: '联络'),
            Tab(text: '目标'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ReminderList(type: null),
          _ReminderList(type: 'birthday'),
          _ReminderList(type: 'contact'),
          _ReminderList(type: 'goal'),
        ],
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    final db = ref.read(appDatabaseProvider);
    await db.reminderDao.markAllAsRead();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已全部标记为已读')),
      );
    }
  }
}

class _ReminderList extends ConsumerWidget {
  final String? type;

  const _ReminderList({this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = type == null
        ? ref.watch(allRemindersProvider)
        : ref.watch(allRemindersProvider).whenData(
            (reminders) => reminders.where((r) => r.type == type).toList(),
          );

    return remindersAsync.when(
      data: (reminders) {
        if (reminders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  '暂无提醒',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        final now = DateTime.now();
        final pending = reminders.where((r) => !r.isHandled && r.scheduledAt.isBefore(now)).toList();
        final upcoming = reminders.where((r) => !r.isHandled && r.scheduledAt.isAfter(now)).toList();
        final handled = reminders.where((r) => r.isHandled).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (pending.isNotEmpty) ...[
              _SectionHeader(title: '待处理', count: pending.length),
              ...pending.map((r) => _ReminderCard(reminder: r)),
              const SizedBox(height: 16),
            ],
            if (upcoming.isNotEmpty) ...[
              _SectionHeader(title: '即将到来', count: upcoming.length),
              ...upcoming.map((r) => _ReminderCard(reminder: r)),
              const SizedBox(height: 16),
            ],
            if (handled.isNotEmpty) ...[
              _SectionHeader(title: '已处理', count: handled.length),
              ...handled.map((r) => _ReminderCard(reminder: r)),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('加载失败: $e', style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends ConsumerWidget {
  final ReminderRecord reminder;

  const _ReminderCard({required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = !reminder.isHandled && reminder.scheduledAt.isBefore(DateTime.now());

    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        final db = ref.read(appDatabaseProvider);
        await db.reminderDao.deleteReminder(reminder.id);
      },
      child: GestureDetector(
        onTap: () => _handleTap(context, ref),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isPending && !reminder.isRead
                ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 2)
                : null,
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTypeColor(reminder.type).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTypeIcon(reminder.type),
                  color: _getTypeColor(reminder.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTypeColor(reminder.type).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getTypeName(reminder.type),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getTypeColor(reminder.type),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!reminder.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      reminder.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    if (reminder.content != null && reminder.content!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        reminder.content!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(reminder.scheduledAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              if (isPending) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: AppTheme.primary,
                  onPressed: () => _markAsHandled(context, ref),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);

    if (!reminder.isRead) {
      await db.reminderDao.updateReminder(reminder.id, isRead: true);
    }

    if (reminder.relatedEntityType != null && reminder.relatedEntityId != null) {
      if (!context.mounted) return;
      switch (reminder.relatedEntityType) {
        case 'friend':
          RouteNavigation.goToFriendProfile(context, reminder.relatedEntityId!);
          break;
        case 'goal':
          RouteNavigation.goToGoalDetail(context, reminder.relatedEntityId!);
          break;
      }
    }
  }

  Future<void> _markAsHandled(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    await db.reminderDao.updateReminder(
      reminder.id,
      isHandled: true,
      triggeredAt: DateTime.now(),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(time.year, time.month, time.day);

    final diff = targetDay.difference(today).inDays;

    if (diff == 0) {
      return '今天 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff == 1) {
      return '明天';
    } else if (diff == -1) {
      return '昨天';
    } else if (diff > 0 && diff <= 7) {
      return '$diff天后';
    } else if (diff < 0 && diff >= -7) {
      return '${-diff}天前';
    } else {
      return '${time.month}月${time.day}日';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'birthday':
        return Colors.red;
      case 'contact':
        return Colors.blue;
      case 'goal':
        return const Color(0xFFA855F7);
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'birthday':
        return Icons.cake;
      case 'contact':
        return Icons.people;
      case 'goal':
        return Icons.outlined_flag;
      default:
        return Icons.notifications;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'birthday':
        return '生日';
      case 'contact':
        return '联络';
      case 'goal':
        return '目标';
      default:
        return type;
    }
  }
}
