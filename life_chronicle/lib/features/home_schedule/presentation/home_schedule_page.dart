import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_theme.dart';
import '../../../core/config/module_management_config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../core/router/route_navigation.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/file_logger.dart';
import '../../../core/widgets/app_image.dart';
import '../../travel/presentation/travel_page.dart' show TravelItem;
import '../providers/flashback_provider.dart';
import '../providers/reminder_provider.dart';

List<String> _parseMomentTags(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  final value = raw.trim();
  if (value.startsWith('[')) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList(growable: false);
      }
    } catch (e) {
      FileLogger.instance.logSync('HomeSchedule', '解析模块标签JSON失败: $e');
    }
  }
  return value
      .split(RegExp(r'[,\s，、/]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);
}

ModuleTag? _matchMomentTag(ModuleConfig momentModule, String? rawTags) {
  final tags = _parseMomentTags(rawTags);
  if (tags.isEmpty) return null;
  for (final tagName in tags) {
    for (final tag in momentModule.tags) {
      if (tag.name == tagName) {
        return tag;
      }
    }
  }
  return null;
}

ModuleTag? _matchBondTag(ModuleConfig bondModule, String? rawTags) {
  final tags = _parseMomentTags(rawTags);
  if (tags.isEmpty) return null;
  for (final tagName in tags) {
    for (final tag in bondModule.tags) {
      if (tag.name == tagName) {
        return tag;
      }
    }
  }
  return null;
}

bool _isCompletedDailyGoal(GoalRecord record) {
  return record.level == 'daily' && record.isCompleted && !record.isDeleted;
}

String _greetingByHour(int hour) {
  if (hour < 6) return '夜深了';
  if (hour < 11) return '早上好';
  if (hour < 13) return '中午好';
  if (hour < 18) return '下午好';
  return '晚上好';
}

class HomeSchedulePage extends ConsumerStatefulWidget {
  const HomeSchedulePage({super.key});

  @override
  ConsumerState<HomeSchedulePage> createState() => _HomeSchedulePageState();
}

class _HomeSchedulePageState extends ConsumerState<HomeSchedulePage> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  Future<void> _refreshData() async {
    ref.invalidate(flashbackItemsProvider);
    await ref.read(flashbackItemsProvider(defaultFlashbackYears).future);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: const _GlassHeader(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.primary,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.paddingOf(context).bottom + kBottomNavigationBarHeight + 56,
          ),
          children: [
            const _FlashbackSection(),
            const SizedBox(height: 16),
            const _TodayReminder(),
            const SizedBox(height: 16),
            _CalendarCard(
              selectedDay: _selectedDay,
              onSelectDay: (day) => setState(() => _selectedDay = day),
            ),
            const SizedBox(height: 16),
            _EventStream(selectedDay: _selectedDay),
          ],
        ),
      ),
    );
  }
}

class _GlassHeader extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const _GlassHeader();

  static const _defaultAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBYyAsCsUFotbFS4IxBHOEJ1DA-wBDR1IVfg1d3rW9bLa4YuRfV882W0Gj9D_oJHRv8cju9gfQyluVHnzjDzJMCZbPKUGwAA7SVIlLiY0SznM-y2S8DAks2kYgua7mWcEmcQPOrxDT1oZJJhDdKMwYsdMM7G5NPreBxZIp3VhN08wAO3i6DxKMN9Hp3_QOj-9i5MV5rtBRoa0PirbUtvk_dBOMFEDLzALxQasPjHhvOaXLyEbgAEOptmcXA27XD2JM8qtcZ_u2eFR_T';

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  ConsumerState<_GlassHeader> createState() => _GlassHeaderState();
}

class _GlassHeaderState extends ConsumerState<_GlassHeader> {
  Future<String?>? _avatarFuture;
  int? _lastProfileRevision;

  @override
  void initState() {
    super.initState();
    _avatarFuture = _loadAvatarPath();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final revision = ref.read(profileRevisionProvider);
    if (_lastProfileRevision != null && _lastProfileRevision != revision) {
      _refreshAvatar();
    }
    _lastProfileRevision = revision;
  }

  Future<String?> _loadAvatarPath() async {
    if (kIsWeb) return null;
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'profile', 'avatar.json'));
    if (!await file.exists()) return null;
    try {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map && decoded['path'] is String) {
        final path = (decoded['path'] as String).trim();
        if (path.isNotEmpty && await File(path).exists()) {
          return path;
        }
      }
    } catch (e) {
      FileLogger.instance.logSync('HomeSchedule', '加载头像配置失败: $e');
    }
    return null;
  }

  ImageProvider _avatarProvider(String? path) {
    final value = path?.trim() ?? '';
    if (value.isEmpty) {
      return const NetworkImage(_GlassHeader._defaultAvatarUrl);
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }
    return FileImage(File(value));
  }

  void _refreshAvatar() {
    setState(() {
      _avatarFuture = _loadAvatarPath();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AppBar(
          toolbarHeight: 72,
          titleSpacing: 16,
          title: Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  context.go(AppRoutes.profile);
                  if (!mounted) return;
                  _refreshAvatar();
                },
                child: Stack(
                  children: [
                    FutureBuilder<String?>(
                      future: _avatarFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const CircleAvatar(child: Icon(Icons.person));
                        }
                        return CircleAvatar(
                          radius: 22,
                          backgroundImage: _avatarProvider(snapshot.data),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greetingByHour(DateTime.now().hour),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Consumer(
                      builder: (context, ref, _) {
                        final nameAsync = ref.watch(userDisplayNameProvider);
                        return nameAsync.when(
                          data: (name) => Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: AppTheme.textMain,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          loading: () => const Text(
                            '...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: AppTheme.textMain,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          error: (_, __) => const Text(
                            '未设置',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: AppTheme.textMain,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      backgroundColor: const Color(0xFFEEFCFC),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                        side: const BorderSide(color: AppTheme.primary),
                      ),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    onPressed: () {
                      RouteNavigation.goToAiHistorian(context);
                    },
                    child: const Text('AI史官'),
                  ),
                  const SizedBox(width: 4),
                  Consumer(
                    builder: (context, ref, _) {
                      final hasUnreadAsync = ref.watch(hasUnreadRemindersProvider);
                      return hasUnreadAsync.maybeWhen(
                        data: (hasUnread) => _HeaderIconButton(
                          icon: Icons.notifications,
                          showDot: hasUnread,
                          onTap: () => RouteNavigation.pushToReminderList(context),
                        ),
                        orElse: () => _HeaderIconButton(
                          icon: Icons.notifications,
                          showDot: false,
                          onTap: () => RouteNavigation.pushToReminderList(context),
                        ),
                      );
                    },
                  ),
                  _HeaderIconButton(
                    icon: Icons.settings,
                    showDot: false,
                    onTap: () async {
                      context.go(AppRoutes.profile);
                      if (!mounted) return;
                      _refreshAvatar();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.showDot,
    required this.onTap,
  });

  final IconData icon;
  final bool showDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            onTap();
          },
          icon: Icon(icon, color: const Color(0xFF4B5563)),
          splashRadius: 22,
        ),
        if (showDot)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
      ],
    );
  }
}

class _FlashbackSection extends ConsumerWidget {
  const _FlashbackSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashbackAsync = ref.watch(flashbackItemsProvider(defaultFlashbackYears));

    return flashbackAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildEmptyState();
        }
        return _buildDataState(context, items);
      },
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState(),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const Icon(Icons.history_edu, color: AppTheme.primary, size: 22),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              '那年今日',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
            ),
          ),
          Text(
            '未来的今天，会有故事发生',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDataState(BuildContext context, List<FlashbackItem> items) {
    final displayItems = items.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Icon(Icons.history_edu, color: AppTheme.primary, size: 22),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  '那年今日',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
                ),
              ),
              TextButton(
                onPressed: () => RouteNavigation.pushToFlashback(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppTheme.primary,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                child: const Text('查看全部'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 208,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            itemCount: displayItems.length,
            itemBuilder: (context, index) {
              final item = displayItems[index];
              return _FlashbackItemCard(item: item);
            },
            separatorBuilder: (_, __) => const SizedBox(width: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const Icon(Icons.history_edu, color: AppTheme.primary, size: 22),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              '那年今日',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
            ),
          ),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const Icon(Icons.history_edu, color: AppTheme.primary, size: 22),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              '那年今日',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
            ),
          ),
          Text(
            '加载失败',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _FlashbackItemCard extends StatelessWidget {
  final FlashbackItem item;

  const _FlashbackItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 160,
          height: 208,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                AppImage(
                  source: item.imageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    color: _getTypeColor(item.type),
                    child: Center(
                      child: Icon(_getTypeIcon(item.type), color: Colors.white, size: 48),
                    ),
                  ),
                )
              else
                Container(
                  color: _getTypeColor(item.type),
                  child: Center(
                    child: Icon(_getTypeIcon(item.type), color: Colors.white, size: 48),
                  ),
                ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x99000000)],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.yearLabel,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ),
                        if (item.isFavorite) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    switch (item.type) {
      case 'food':
        RouteNavigation.pushToFoodDetail(context, item.recordId);
        break;
      case 'moment':
        RouteNavigation.pushToMomentDetail(context, item.recordId);
        break;
      case 'travel':
        if (item.isJournal) {
          RouteNavigation.pushToJournalDetail(context, item.recordId);
        } else {
          RouteNavigation.goToTravelDetail(context, item.recordId);
        }
        break;
      case 'goal':
        RouteNavigation.pushToGoalDetail(context, item.recordId);
        break;
      case 'encounter':
        RouteNavigation.pushToEncounterDetail(context, item.recordId);
        break;
      default:
        FileLogger.instance.logSync('HomeSchedule.Flashback', '未知记录类型: ${item.type}, recordId=${item.recordId}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('未知记录类型: ${item.type}')),
        );
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'food':
        return Colors.orange;
      case 'moment':
        return const Color(0xFF4ADE80);
      case 'travel':
        return Colors.purple;
      case 'goal':
        return const Color(0xFFA855F7);
      case 'encounter':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'food':
        return Icons.restaurant;
      case 'moment':
        return Icons.auto_awesome;
      case 'travel':
        return Icons.airplanemode_active;
      case 'goal':
        return Icons.outlined_flag;
      case 'encounter':
        return Icons.people;
      default:
        return Icons.event;
    }
  }
}

class _TodayReminder extends ConsumerWidget {
  const _TodayReminder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayReminders = ref.watch(todayRemindersProvider);

    return todayReminders.when(
      data: (reminders) {
        if (reminders.isEmpty) {
          return const SizedBox.shrink();
        }

        final reminder = reminders.first;
        final typeColor = _getTypeColor(reminder.type);
        final typeIcon = _getTypeIcon(reminder.type);
        final hasMore = reminders.length > 1;

        return GestureDetector(
          onTap: () => RouteNavigation.pushToReminderList(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeIcon, size: 16, color: typeColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    reminder.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF374151), fontWeight: FontWeight.w600),
                  ),
                ),
                if (hasMore) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '+${reminders.length - 1}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
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
}

class _CalendarCard extends ConsumerStatefulWidget {
  const _CalendarCard({
    required this.selectedDay,
    required this.onSelectDay,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelectDay;

  @override
  ConsumerState<_CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends ConsumerState<_CalendarCard> {
  late DateTime _focusMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusMonth = DateTime(now.year, now.month, 1);
  }

  void _goPrevMonth() {
    setState(() {
      _focusMonth = DateTime(_focusMonth.year, _focusMonth.month - 1, 1);
      final newSelected = _clampSelectedDay(widget.selectedDay, _focusMonth);
      if (newSelected != widget.selectedDay) {
        widget.onSelectDay(newSelected);
      }
    });
  }

  void _goNextMonth() {
    setState(() {
      _focusMonth = DateTime(_focusMonth.year, _focusMonth.month + 1, 1);
      final newSelected = _clampSelectedDay(widget.selectedDay, _focusMonth);
      if (newSelected != widget.selectedDay) {
        widget.onSelectDay(newSelected);
      }
    });
  }

  DateTime _clampSelectedDay(DateTime day, DateTime focusMonth) {
    final maxDay = DateUtils.getDaysInMonth(focusMonth.year, focusMonth.month);
    final clampedDay = day.day.clamp(1, maxDay);
    return DateTime(focusMonth.year, focusMonth.month, clampedDay);
  }

  Future<void> _openMonthPicker() async {
    final result = await showModalBottomSheet<_MonthYearValue>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MonthYearPickerSheet(
        initialYear: _focusMonth.year,
        initialMonth: _focusMonth.month,
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _focusMonth = DateTime(result.year, result.month, 1);
      final newSelected = _clampSelectedDay(widget.selectedDay, _focusMonth);
      if (newSelected != widget.selectedDay) {
        widget.onSelectDay(newSelected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    // 使用 moduleManagementConfigProvider 获取模块配置（已监听 revision 变化）
    final configAsync = ref.watch(moduleManagementConfigProvider);
    final config = configAsync.maybeWhen(
      data: (c) => c,
      orElse: () => ModuleManagementConfig.defaults(),
    );
    final monthStart = DateTime(_focusMonth.year, _focusMonth.month, 1);
    final monthEnd = DateTime(_focusMonth.year, _focusMonth.month + 1, 1);
    return StreamBuilder<List<FoodRecord>>(
      stream: db.foodDao.watchByRecordDateRange(monthStart, monthEnd),
      builder: (context, foodSnapshot) {
        final foods = foodSnapshot.data ?? const <FoodRecord>[];
        return StreamBuilder<List<MomentRecord>>(
          stream: db.momentDao.watchByRecordDateRange(monthStart, monthEnd),
          builder: (context, momentSnapshot) {
            final moments = momentSnapshot.data ?? const <MomentRecord>[];
            return StreamBuilder<List<TravelRecord>>(
              stream: db.watchTravelRecordsByRange(monthStart, monthEnd),
              builder: (context, travelSnapshot) {
                final travels = travelSnapshot.data ?? const <TravelRecord>[];
                return StreamBuilder<List<GoalRecord>>(
                  stream: db.goalDao.watchByRecordDateRange(monthStart, monthEnd),
                  builder: (context, goalSnapshot) {
                    final goals = goalSnapshot.data ?? const <GoalRecord>[];
                    return StreamBuilder<List<TimelineEvent>>(
                      stream: db.watchEventsForMonth(_focusMonth),
                      builder: (context, snapshot) {
                        final events = snapshot.data ?? [];
                        return StreamBuilder<List<FriendRecord>>(
                          stream: db.friendDao.watchAllActive(),
                          builder: (context, friendSnapshot) {
                            final friends = friendSnapshot.data ?? const <FriendRecord>[];
                            return Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1A2BCDEE),
                                    blurRadius: 20,
                                    offset: Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _CalendarHeader(
                                    month: _focusMonth.month,
                                    year: _focusMonth.year,
                                    onPrev: _goPrevMonth,
                                    onNext: _goNextMonth,
                                    onPick: _openMonthPicker,
                                  ),
                                  const SizedBox(height: 14),
                                  const _WeekdayRow(),
                                  const SizedBox(height: 10),
                                  _CalendarGrid(
                                    focusMonth: _focusMonth,
                                    selectedDay: widget.selectedDay,
                                    onSelectDay: widget.onSelectDay,
                                    events: events,
                                    foods: foods,
                                    moments: moments,
                                    travels: travels,
                                    goals: goals,
                                    friends: friends,
                                    config: config,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.month,
    required this.year,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
  });

  final int month;
  final int year;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CalendarIconButton(icon: Icons.chevron_left, onTap: onPrev),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPick,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$year年$month月',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textMain),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more, size: 18, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
        ),
        _CalendarIconButton(icon: Icons.chevron_right, onTap: onNext),
      ],
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    const labels = ['日', '一', '二', '三', '四', '五', '六'];
    return Row(
      children: [
        for (final label in labels)
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)),
            ),
          ),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.focusMonth,
    required this.selectedDay,
    required this.onSelectDay,
    required this.events,
    required this.foods,
    required this.moments,
    required this.travels,
    required this.goals,
    required this.friends,
    required this.config,
  });

  final DateTime focusMonth;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelectDay;
  final List<TimelineEvent> events;
  final List<FoodRecord> foods;
  final List<MomentRecord> moments;
  final List<TravelRecord> travels;
  final List<GoalRecord> goals;
  final List<FriendRecord> friends;
  final ModuleManagementConfig config;

  List<_CalendarCellData> _buildCells() {
    final year = focusMonth.year;
    final month = focusMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstDay = DateTime(year, month, 1);
    final leadingDays = firstDay.weekday % 7;
    final prevMonthDays = DateTime(year, month, 0).day;

    const dotBlue = Color(0xFF60A5FA);
    const dotOrange = Color(0xFFFB923C);

    final iconsByDay = <int, Set<IconData>>{};

    void addIcon(int day, IconData icon) {
      iconsByDay.putIfAbsent(day, () => <IconData>{}).add(icon);
    }

    final foodModule = config.moduleOf('food');
    final travelModule = config.moduleOf('travel');
    final momentModule = config.moduleOf('moment');
    final bondModule = config.moduleOf('bond');
    final goalModule = config.moduleOf('goal');

    if (foodModule.showOnCalendar) {
      for (final record in foods) {
        if (record.isWishlist) continue;
        final date = record.recordDate;
        if (date.year == year && date.month == month) {
          addIcon(date.day, IconUtils.fromName(foodModule.iconName));
        }
      }
    }

    if (travelModule.showOnCalendar) {
      for (final record in travels) {
        final date = record.recordDate;
        if (date.year == year && date.month == month) {
          addIcon(date.day, IconUtils.fromName(travelModule.iconName));
        }
      }
    }

    if (goalModule.showOnCalendar) {
      for (final record in goals) {
        if (!_isCompletedDailyGoal(record)) continue;
        final date = record.recordDate;
        if (date.year == year && date.month == month) {
          addIcon(date.day, IconUtils.fromName(goalModule.iconName));
        }
      }
    }

    if (bondModule.showOnCalendar) {
      // bond 模块日历显示 friend 记录（按相遇日期 meetDate，meetDate 为空时回退到 createdAt）
      for (final friend in friends) {
        final date = friend.meetDate ?? friend.createdAt;
        if (date.year != year || date.month != month) continue;
        // 印象标签匹配：若标签关闭日历显示则跳过
        final match = _matchBondTag(bondModule, friend.impressionTags);
        if (match != null && !match.showOnCalendar) {
          continue;
        }
        final iconName = match?.iconName ?? bondModule.iconName;
        addIcon(date.day, IconUtils.fromName(iconName));
      }
    }

    if (momentModule.showOnCalendar) {
      for (final record in moments) {
        final date = record.recordDate;
        if (date.year != year || date.month != month) continue;
        final match = _matchMomentTag(momentModule, record.tags);
        if (match != null && !match.showOnCalendar) {
          continue;
        }
        final iconName = match?.iconName ?? momentModule.iconName;
        addIcon(date.day, IconUtils.fromName(iconName));
      }
    }

    return List.generate(42, (index) {
      final dayOffset = index - leadingDays + 1;
      final isPrevMonth = dayOffset <= 0;
      final isNextMonth = dayOffset > daysInMonth;
      final muted = isPrevMonth || isNextMonth;

      final displayDay = isPrevMonth
          ? prevMonthDays + dayOffset
          : isNextMonth
              ? dayOffset - daysInMonth
              : dayOffset;

      final selected = !muted && displayDay == selectedDay.day;

      if (muted) {
        return _CalendarCellData(day: '$displayDay', muted: true);
      }

      final date = DateTime(year, month, displayDay);
      final dayEvents = events.where((e) {
        final eDate = e.recordDate;
        return eDate.year == year && eDate.month == month && eDate.day == displayDay;
      }).toList();

      final dots = <Color>[];

      if (dayEvents.isNotEmpty) {
        dots.add(dotBlue);
        final hasNote = dayEvents.any((e) => e.note != null && e.note!.isNotEmpty);
        if (hasNote) dots.add(dotOrange);
      }

      final icons = iconsByDay[displayDay]?.toList(growable: false) ?? const <IconData>[];
      final displayIcons = icons.length > 3 ? icons.take(3).toList(growable: false) : icons;
      final extraCount = icons.length > 3 ? icons.length - 3 : 0;
      return _CalendarCellData(
        day: '$displayDay',
        date: date,
        selected: selected,
        dots: dots,
        icons: displayIcons,
        extraIconCount: extraCount,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cells = _buildCells();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 0,
        childAspectRatio: 1.2,
      ),
      itemCount: cells.length,
      itemBuilder: (context, index) => _CalendarCell(
        data: cells[index],
        onTap: cells[index].date == null ? null : () => onSelectDay(cells[index].date!),
      ),
    );
  }
}

class _CalendarCellData {
  const _CalendarCellData({
    required this.day,
    this.date,
    this.muted = false,
    this.selected = false,
    this.dots = const [],
    this.icons = const [],
    this.extraIconCount = 0,
  });

  final String day;
  final DateTime? date;
  final bool muted;
  final bool selected;
  final List<Color> dots;
  final List<IconData> icons;
  final int extraIconCount;
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({required this.data, required this.onTap});

  final _CalendarCellData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dayText = Text(
      data.day,
      style: TextStyle(
        fontSize: 14,
        fontWeight: data.selected ? FontWeight.w800 : FontWeight.w600,
        color: data.muted ? const Color(0xFFD1D5DB) : AppTheme.textMain,
      ),
    );

    Widget dayWidget = dayText;
    if (data.selected) {
      dayWidget = Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(data.day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
      );
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dayWidget,
        const SizedBox(height: 4),
        if (data.dots.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final c in data.dots)
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
            ],
          )
        else
          const SizedBox(height: 6),
        if (data.icons.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final icon in data.icons)
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 12, color: const Color(0xFF0F766E)),
                ),
              if (data.extraIconCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    '+${data.extraIconCount}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F766E)),
                  ),
                ),
            ],
          )
        else
          const SizedBox(height: 18),
      ],
    );
    if (data.muted || onTap == null) {
      return content;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onTap!();
      },
      child: content,
    );
  }
}

class _CalendarIconButton extends StatelessWidget {
  const _CalendarIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, size: 18, color: AppTheme.textMuted),
      ),
    );
  }
}

class _MonthYearValue {
  const _MonthYearValue(this.year, this.month);

  final int year;
  final int month;
}

class _MonthYearPickerSheet extends StatefulWidget {
  const _MonthYearPickerSheet({required this.initialYear, required this.initialMonth});

  final int initialYear;
  final int initialMonth;

  @override
  State<_MonthYearPickerSheet> createState() => _MonthYearPickerSheetState();
}

class _MonthYearPickerSheetState extends State<_MonthYearPickerSheet> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final years = List.generate(7, (index) => now.year - 6 + index);
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.paddingOf(context).bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(999)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('快速切换', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_MonthYearValue(_year, _month)),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.primary, textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                  child: const Text('确定'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('年份', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final y in years)
                  _SelectChip(
                    label: '$y年',
                    selected: y == _year,
                    onTap: () => setState(() => _year = y),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('月份', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var m = 1; m <= 12; m++)
                  _SelectChip(
                    label: '$m月',
                    selected: m == _month,
                    onTap: () => setState(() => _month = m),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  const _SelectChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppTheme.primary : const Color(0xFFF3F4F6);
    final fg = selected ? Colors.white : AppTheme.textMain;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: fg)),
      ),
    );
  }
}

class _EventStream extends ConsumerWidget {
  const _EventStream({required this.selectedDay});

  final DateTime selectedDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final dayStart = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    // 使用 ref.watch 监听模块配置变化（响应 moduleManagementRevisionProvider）
    final config = ref.watch(moduleManagementConfigProvider).value ?? ModuleManagementConfig.defaults();
    return StreamBuilder<List<TimelineEvent>>(
      stream: db.watchEventsForDate(selectedDay),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        final events = snapshot.data ?? [];
        return StreamBuilder<List<FoodRecord>>(
          stream: db.foodDao.watchByRecordDateRange(dayStart, dayEnd),
          builder: (context, foodSnapshot) {
            if (foodSnapshot.hasError) {
              return const SizedBox.shrink();
            }
            final foods = (foodSnapshot.data ?? const <FoodRecord>[]).where((e) => e.isWishlist == false).toList(growable: false);
            return StreamBuilder<List<MomentRecord>>(
              stream: db.momentDao.watchByRecordDateRange(dayStart, dayEnd),
              builder: (context, momentSnapshot) {
                if (momentSnapshot.hasError) {
                  return const SizedBox.shrink();
                }
                final moments = momentSnapshot.data ?? const <MomentRecord>[];
                return StreamBuilder<List<GoalRecord>>(
                  stream: db.goalDao.watchByRecordDateRange(dayStart, dayEnd),
                  builder: (context, goalSnapshot) {
                    if (goalSnapshot.hasError) {
                      return const SizedBox.shrink();
                    }
                    final completedGoals = (goalSnapshot.data ?? const <GoalRecord>[])
                        .where(_isCompletedDailyGoal)
                        .toList(growable: false);
                    final momentMap = <String, MomentRecord>{};
                    for (final m in moments) {
                      momentMap[m.id] = m;
                    }

                    final nonGoalEvents = events.where((e) => e.eventType != 'goal');
                    final items = <({DateTime? time, String title, String? subtitle, String type, String? id, VoidCallback? onTap})>[
                      for (final e in nonGoalEvents)
                        (
                          time: e.startAt,
                          title: e.title,
                          subtitle: e.note,
                          type: e.eventType,
                          id: e.id,
                          onTap: _canOpenEventDetail(e.eventType)
                              ? () {
                                  switch (e.eventType) {
                                    case 'encounter':
                                      _openEncounterDetail(context, e.id);
                                      break;
                                    case 'travel':
                                      _openTravelDetail(context, ref, e.id);
                                      break;
                                    case 'moment':
                                      _openMomentDetail(context, e.id);
                                      break;
                                  }
                                }
                              : null,
                        ),
                      for (final goal in completedGoals)
                        (
                          time: goal.completedAt ?? goal.recordDate,
                          title: goal.title,
                          subtitle: _goalTimelineSubtitle(goal),
                          type: 'goal',
                          id: goal.id,
                          onTap: () {
                            _openGoalDetail(context, ref, goal.id);
                          },
                        ),
                      for (final f in foods)
                        (
                          time: f.recordDate,
                          title: f.title,
                          subtitle: (f.poiName ?? '').trim().isNotEmpty
                              ? (f.poiName ?? '').trim()
                              : ((f.content ?? '').trim().isNotEmpty ? (f.content ?? '').trim() : null),
                          type: 'food',
                          id: f.id,
                          onTap: () {
                            RouteNavigation.pushToFoodDetail(context, f.id);
                          },
                        ),
                    ];

                    items.sort((a, b) {
                      final at = a.time;
                      final bt = b.time;
                      if (at == null && bt == null) return 0;
                      if (at == null) return 1;
                      if (bt == null) return -1;
                      return at.compareTo(bt);
                    });

                    final momentModule = config.moduleOf('moment');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                              children: [
                                const TextSpan(text: '日程记录'),
                                TextSpan(
                                  text: '  ${items.length}个记录',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                '${selectedDay.month}月${selectedDay.day}日 暂无日程',
                                style: const TextStyle(color: AppTheme.textMuted),
                              ),
                            ),
                          )
                        else
                          for (var i = 0; i < items.length; i++)
                            _buildTimelineItem(items[i], i, items.length, momentModule, momentMap),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTimelineItem(
    ({DateTime? time, String title, String? subtitle, String type, String? id, VoidCallback? onTap}) item,
    int index,
    int totalItems,
    ModuleConfig momentModule,
    Map<String, MomentRecord> momentMap,
  ) {
    IconData? icon;
    Color? color;
    
    if (item.type == 'moment' && item.id != null) {
      final moment = momentMap[item.id!];
      if (moment != null) {
        final match = _matchMomentTag(momentModule, moment.tags);
        final iconName = match?.iconName ?? momentModule.iconName;
        icon = IconUtils.fromName(iconName);
        color = const Color(0xFF4ADE80);
      }
    }
    
    icon ??= _getIconForType(item.type);
    color ??= _getColorForType(item.type);
    
    return _TimelineItem(
      time: _formatTime(item.time),
      title: item.title,
      subtitle: item.subtitle,
      leadingIcon: icon,
      leadingBg: color.withValues(alpha: 0.1),
      leadingFg: color,
      showLine: index != totalItems - 1,
      onTap: item.onTap,
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  bool _canOpenEventDetail(String eventType) {
    return eventType == 'encounter' || eventType == 'travel' || eventType == 'moment';
  }

  String? _goalTimelineSubtitle(GoalRecord goal) {
    if (goal.completedAt == null) return null;
    final completedAt = goal.completedAt!;
    return '完成于 ${completedAt.hour.toString().padLeft(2, '0')}:${completedAt.minute.toString().padLeft(2, '0')}';
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'work':
        return Icons.work;
      case 'personal':
        return Icons.person;
      case 'travel':
        return Icons.airplanemode_active;
      case 'food':
        return Icons.restaurant;
      case 'encounter':
        return Icons.people;
      case 'goal':
        return Icons.outlined_flag;
      case 'moment':
        return Icons.auto_awesome;
      default:
        return Icons.event;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'work':
        return Colors.blue;
      case 'personal':
        return Colors.green;
      case 'travel':
        return Colors.purple;
      case 'food':
        return Colors.orange;
      case 'encounter':
        return Colors.pink;
      case 'goal':
        return const Color(0xFFA855F7);
      case 'moment':
        return const Color(0xFF4ADE80);
      default:
        return Colors.grey;
    }
  }

  Future<void> _openEncounterDetail(BuildContext context, String encounterId) async {
    RouteNavigation.pushToEncounterDetail(context, encounterId);
  }

  Future<void> _openTravelDetail(BuildContext context, WidgetRef ref, String travelId) async {
    FileLogger.instance.log('HomeSchedule._openTravelDetail', 'travelId=$travelId');
    final db = ref.read(appDatabaseProvider);
    final record = await (db.select(db.travelRecords)
          ..where((t) => t.id.equals(travelId))
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .getSingleOrNull();
    if (!context.mounted) return;
    if (record == null) {
      FileLogger.instance.logWithLevel('HomeSchedule._openTravelDetail', 'record not found: travelId=$travelId', LogLevel.warn);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('未找到旅行记录')));
      return;
    }
    FileLogger.instance.log('HomeSchedule._openTravelDetail', 'record found: id=${record.id} isJournal=${record.isJournal} '
        'tripId=${record.tripId} title=${record.title}');
    if (record.isJournal) {
      FileLogger.instance.log('HomeSchedule._openTravelDetail', 'navigating to JournalDetail: ${record.id}');
      RouteNavigation.pushToJournalDetail(context, record.id);
    } else {
      final item = TravelItem.fromRecord(record);
      FileLogger.instance.log('HomeSchedule._openTravelDetail', 'navigating to TravelDetail: ${item.travelId} tripId=${item.tripId}');
      RouteNavigation.goToTravelDetail(context, item.travelId, item: item);
    }
  }

  Future<void> _openMomentDetail(BuildContext context, String momentId) async {
    RouteNavigation.pushToMomentDetail(context, momentId);
  }

  Future<void> _openGoalDetail(BuildContext context, WidgetRef ref, String goalId) async {
    final db = ref.read(appDatabaseProvider);
    final record = await (db.select(db.goalRecords)
          ..where((t) => t.id.equals(goalId))
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .getSingleOrNull();
    if (!context.mounted) return;
    if (record == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('未找到目标记录')));
      return;
    }

    GoalRecord yearGoal = record;
    if (record.level != 'year') {
      String? currentParentId = record.parentId;
      const maxDepth = 10;
      var depth = 0;
      final visitedIds = <String>{record.id};
      while (currentParentId != null && depth < maxDepth) {
        if (visitedIds.contains(currentParentId)) {
          FileLogger.instance.logSync('HomeSchedule._openGoalDetail', '检测到循环引用: goalId=$goalId, visited=$visitedIds');
          break;
        }
        visitedIds.add(currentParentId);
        depth++;
        final parent = await (db.select(db.goalRecords)
              ..where((t) => t.id.equals(currentParentId!))
              ..where((t) => t.isDeleted.equals(false))
              ..limit(1))
            .getSingleOrNull();
        if (parent == null) break;
        yearGoal = parent;
        if (parent.level == 'year') break;
        currentParentId = parent.parentId;
      }
      if (yearGoal.level != 'year') {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('未找到关联的年度目标')));
        return;
      }
    }
    if (!context.mounted) return;
    RouteNavigation.pushToGoalDetail(context, yearGoal.id, record: yearGoal);
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.time,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leadingBg = const Color(0xFFF3F4F6),
    this.leadingFg = const Color(0xFF6B7280),
    this.showLine = true,
    this.onTap,
  });

  final String time;
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Color leadingBg;
  final Color leadingFg;
  final bool showLine;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Column(
                children: [
                  Text(
                    time,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textMain),
                  ),
                  const SizedBox(height: 8),
                  if (showLine)
                    Expanded(
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Color(0x05000000),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LeadingBox(
                          icon: leadingIcon,
                          bg: leadingBg,
                          fg: leadingFg,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textMain),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadingBox extends StatelessWidget {
  const _LeadingBox({
    required this.icon,
    required this.bg,
    required this.fg,
  });

  final IconData? icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon ?? Icons.event, size: 32, color: fg),
    );
  }
}
