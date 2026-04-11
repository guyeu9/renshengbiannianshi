import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/app_theme.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/notification/reminder_scheduler.dart';
import '../../../core/services/notification/reminder_service.dart';

final _globalReminderEnabledProvider = StateProvider<bool>((ref) => false);
final _birthdayReminderDaysProvider = StateProvider<int>((ref) => 3);
final _dndEnabledProvider = StateProvider<bool>((ref) => true);

class ReminderSettingsPage extends ConsumerStatefulWidget {
  const ReminderSettingsPage({super.key});

  @override
  ConsumerState<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends ConsumerState<ReminderSettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final globalEnabled = prefs.getBool('global_reminder_enabled') ?? true;
    final birthdayDays = prefs.getInt('birthday_reminder_days') ?? 3;
    final dndEnabled = prefs.getBool('dnd_enabled') ?? true;

    ref.read(_globalReminderEnabledProvider.notifier).state = globalEnabled;
    ref.read(_birthdayReminderDaysProvider.notifier).state = birthdayDays;
    ref.read(_dndEnabledProvider.notifier).state = dndEnabled;

    setState(() {
      _loading = false;
    });
  }

  Future<void> _toggleGlobalReminder(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('global_reminder_enabled', enabled);
    ref.read(_globalReminderEnabledProvider.notifier).state = enabled;

    if (enabled) {
      await ReminderService.instance.initialize();
      final db = ref.read(appDatabaseProvider);
      await ReminderScheduler.instance.scheduleAllReminders(db);
    } else {
      await ReminderService.instance.cancelAllReminders();
    }
  }

  Future<void> _setBirthdayReminderDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('birthday_reminder_days', days);
    ref.read(_birthdayReminderDaysProvider.notifier).state = days;

    final globalEnabled = ref.read(_globalReminderEnabledProvider);
    if (globalEnabled) {
      final db = ref.read(appDatabaseProvider);
      await ReminderScheduler.instance.scheduleAllReminders(db);
    }
  }

  Future<void> _toggleDnd(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dnd_enabled', enabled);
    ref.read(_dndEnabledProvider.notifier).state = enabled;

    final globalEnabled = ref.read(_globalReminderEnabledProvider);
    if (globalEnabled) {
      final db = ref.read(appDatabaseProvider);
      await ReminderScheduler.instance.scheduleAllReminders(db);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.primary;
    final surface = AppTheme.surface;
    final textMain = AppTheme.textMain;
    final textMuted = AppTheme.textMuted;

    final globalEnabled = ref.watch(_globalReminderEnabledProvider);

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        title: Text('提醒设置', style: TextStyle(color: textMain, fontWeight: FontWeight.w700)),
        backgroundColor: surface,
        elevation: 0,
        iconTheme: IconThemeData(color: textMain),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primary,
          unselectedLabelColor: textMuted,
          indicatorColor: primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: '通用'),
            Tab(text: '生日'),
            Tab(text: '联络'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: globalEnabled ? primary.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: globalEnabled ? primary : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '提醒总开关',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textMain),
                            ),
                            Text(
                              globalEnabled ? '已开启所有提醒' : '已关闭所有提醒',
                              style: TextStyle(fontSize: 12, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: globalEnabled,
                        onChanged: _toggleGlobalReminder,
                        activeColor: primary,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _GeneralSettingsTab(
                        globalEnabled: globalEnabled,
                        onBirthdayDaysChanged: _setBirthdayReminderDays,
                        onDndChanged: _toggleDnd,
                      ),
                      _BirthdaySettingsTab(globalEnabled: globalEnabled),
                      _ContactSettingsTab(globalEnabled: globalEnabled),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _GeneralSettingsTab extends ConsumerWidget {
  final bool globalEnabled;
  final Function(int) onBirthdayDaysChanged;
  final Function(bool) onDndChanged;

  const _GeneralSettingsTab({
    required this.globalEnabled,
    required this.onBirthdayDaysChanged,
    required this.onDndChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = AppTheme.primary;
    final textMain = AppTheme.textMain;
    final textMuted = AppTheme.textMuted;
    final birthdayDays = ref.watch(_birthdayReminderDaysProvider);
    final dndEnabled = ref.watch(_dndEnabledProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SettingsSection(title: '生日提醒'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cake, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text('提前提醒天数', style: TextStyle(fontWeight: FontWeight.w600, color: textMain)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [1, 3, 7, 14].map((days) {
                    final selected = birthdayDays == days;
                    return ChoiceChip(
                      label: Text('$days天前'),
                      selected: selected,
                      selectedColor: primary.withValues(alpha: 0.2),
                      onSelected: globalEnabled ? (_) => onBirthdayDaysChanged(days) : null,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  '在朋友生日前$birthdayDays天发送提醒通知',
                  style: TextStyle(fontSize: 12, color: textMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _SettingsSection(title: '目标提醒'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.outlined_flag, color: const Color(0xFFA855F7), size: 20),
                    const SizedBox(width: 8),
                    Text('目标提醒时间', style: TextStyle(fontWeight: FontWeight.w600, color: textMain)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '目标提醒在创建/编辑目标时设置，支持每日、每周、每月提醒',
                  style: TextStyle(fontSize: 12, color: textMuted),
                ),
                const SizedBox(height: 8),
                Text(
                  '提醒时间固定为上午 09:00',
                  style: TextStyle(fontSize: 12, color: textMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _SettingsSection(title: '免打扰时段'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.bedtime, color: Colors.indigo, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('免打扰模式', style: TextStyle(fontWeight: FontWeight.w600, color: textMain)),
                      Text(
                        dndEnabled ? '22:00 - 08:00 期间不发送提醒' : '免打扰已关闭',
                        style: TextStyle(fontSize: 12, color: textMuted),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: dndEnabled,
                  onChanged: globalEnabled ? onDndChanged : null,
                  activeColor: primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;

  const _SettingsSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _BirthdaySettingsTab extends ConsumerStatefulWidget {
  final bool globalEnabled;

  const _BirthdaySettingsTab({required this.globalEnabled});

  @override
  ConsumerState<_BirthdaySettingsTab> createState() => _BirthdaySettingsTabState();
}

class _BirthdaySettingsTabState extends ConsumerState<_BirthdaySettingsTab> {
  Map<String, bool> _birthdayEnabled = {};

  @override
  void initState() {
    super.initState();
    _loadBirthdaySettings();
  }

  Future<void> _loadBirthdaySettings() async {
    final prefs = await SharedPreferences.getInstance();
    final db = ref.read(appDatabaseProvider);
    final friends = await db.friendDao.watchAllActive().first;

    final Map<String, bool> enabled = {};
    for (final f in friends) {
      if (f.birthday != null) {
        enabled[f.id] = prefs.getBool('birthday_reminder_${f.id}') ?? true;
      }
    }

    if (!mounted) return;
    setState(() {
      _birthdayEnabled = enabled;
    });
  }

  Future<void> _toggleBirthdayReminder(String friendId, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('birthday_reminder_$friendId', enabled);
    setState(() {
      _birthdayEnabled[friendId] = enabled;
    });

    final db = ref.read(appDatabaseProvider);
    if (enabled) {
      await ReminderScheduler.instance.rescheduleForFriend(db, friendId);
    } else {
      await ReminderService.instance.cancelReminder('birthday_$friendId');
      await db.reminderDao.deleteRemindersByEntity('friend', friendId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final textMuted = AppTheme.textMuted;
    final primary = AppTheme.primary;

    return StreamBuilder(
      stream: db.friendDao.watchAllActive(),
      builder: (context, snapshot) {
        final friends = snapshot.data ?? [];
        final friendsWithBirthday = friends.where((f) => f.birthday != null).toList();

        if (friendsWithBirthday.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cake_outlined, size: 64, color: textMuted),
                const SizedBox(height: 16),
                Text('暂无生日记录', style: TextStyle(color: textMuted)),
                const SizedBox(height: 8),
                Text('为朋友添加生日后可设置提醒', style: TextStyle(color: textMuted, fontSize: 12)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: friendsWithBirthday.length,
          itemBuilder: (context, index) {
            final friend = friendsWithBirthday[index];
            final enabled = _birthdayEnabled[friend.id] ?? true;
            return _BirthdayReminderCard(
              friend: friend,
              enabled: enabled && widget.globalEnabled,
              globalEnabled: widget.globalEnabled,
              onToggle: (v) => _toggleBirthdayReminder(friend.id, v),
              primary: primary,
            );
          },
        );
      },
    );
  }
}

class _BirthdayReminderCard extends StatelessWidget {
  final FriendRecord friend;
  final bool enabled;
  final bool globalEnabled;
  final Function(bool) onToggle;
  final Color primary;

  const _BirthdayReminderCard({
    required this.friend,
    required this.enabled,
    required this.globalEnabled,
    required this.onToggle,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final textMain = AppTheme.textMain;
    final textMuted = AppTheme.textMuted;

    final birthday = friend.birthday!;
    final now = DateTime.now();
    var nextBirthday = DateTime(now.year, birthday.month, birthday.day);
    if (nextBirthday.isBefore(DateTime(now.year, now.month, now.day))) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
    }
    final daysUntil = nextBirthday.difference(DateTime(now.year, now.month, now.day)).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  friend.name.isNotEmpty ? friend.name[0] : '?',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textMain),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${birthday.month}月${birthday.day}日',
                    style: TextStyle(fontSize: 14, color: textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: daysUntil <= 7 ? Colors.red.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                daysUntil == 0 ? '今天' : daysUntil == 1 ? '明天' : '$daysUntil天后',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: daysUntil <= 7 ? Colors.red : textMuted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: enabled,
              onChanged: globalEnabled ? onToggle : null,
              activeColor: primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactSettingsTab extends ConsumerStatefulWidget {
  final bool globalEnabled;

  const _ContactSettingsTab({required this.globalEnabled});

  @override
  ConsumerState<_ContactSettingsTab> createState() => _ContactSettingsTabState();
}

class _ContactSettingsTabState extends ConsumerState<_ContactSettingsTab> {
  List<FriendRecord> _friends = [];
  Map<String, bool> _reminderEnabled = {};
  Map<String, int> _reminderDays = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final db = ref.read(appDatabaseProvider);
    final friends = await db.friendDao.watchAllActive().first;

    final prefs = await SharedPreferences.getInstance();

    final Map<String, bool> enabled = {};
    final Map<String, int> days = {};

    for (final f in friends) {
      final key = 'reminder_${f.id}';
      final freqDays = ReminderScheduler.contactFrequencyToDays(f.contactFrequency);
      enabled[f.id] = prefs.getBool(key) ?? (freqDays > 0);
      days[f.id] = prefs.getInt('${key}_days') ?? (freqDays > 0 ? freqDays : 7);
    }

    if (!mounted) return;
    setState(() {
      _friends = friends;
      _reminderEnabled = enabled;
      _reminderDays = days;
      _loading = false;
    });
  }

  Future<void> _toggleReminder(String friendId, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_$friendId', enabled);
    setState(() {
      _reminderEnabled[friendId] = enabled;
    });

    final db = ref.read(appDatabaseProvider);
    if (enabled) {
      await ReminderScheduler.instance.rescheduleForFriend(db, friendId);
    } else {
      await ReminderService.instance.cancelReminder('contact_$friendId');
      await db.reminderDao.deleteRemindersByEntity('friend', friendId);
    }
  }

  Future<void> _setReminderDays(String friendId, int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_${friendId}_days', days);
    setState(() {
      _reminderDays[friendId] = days;
    });

    final db = ref.read(appDatabaseProvider);
    await ReminderScheduler.instance.rescheduleForFriend(db, friendId);
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.primary;
    final textMain = AppTheme.textMain;
    final textMuted = AppTheme.textMuted;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: textMuted),
            const SizedBox(height: 16),
            Text('暂无好友记录', style: TextStyle(color: textMuted)),
            const SizedBox(height: 8),
            Text('添加好友后可设置联络提醒', style: TextStyle(color: textMuted, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _friends.length,
      itemBuilder: (ctx, i) {
        final friend = _friends[i];
        final enabled = _reminderEnabled[friend.id] ?? false;
        final days = _reminderDays[friend.id] ?? 7;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: primary.withValues(alpha: 0.1),
                      child: Text(
                        friend.name.isNotEmpty ? friend.name[0] : '?',
                        style: TextStyle(color: primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(friend.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textMain)),
                          if (friend.contactFrequency != null && friend.contactFrequency!.isNotEmpty)
                            Text('期望频率：${friend.contactFrequency}', style: TextStyle(fontSize: 12, color: textMuted)),
                        ],
                      ),
                    ),
                    Switch(
                      value: enabled && widget.globalEnabled,
                      onChanged: widget.globalEnabled ? (v) => _toggleReminder(friend.id, v) : null,
                      activeColor: primary,
                    ),
                  ],
                ),
                if (enabled && widget.globalEnabled) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('提醒周期', style: TextStyle(color: textMuted)),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: days,
                        items: const [
                          DropdownMenuItem(value: 3, child: Text('每3天')),
                          DropdownMenuItem(value: 7, child: Text('每7天')),
                          DropdownMenuItem(value: 14, child: Text('每14天')),
                          DropdownMenuItem(value: 30, child: Text('每30天')),
                          DropdownMenuItem(value: 60, child: Text('每60天')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            _setReminderDays(friend.id, v);
                          }
                        },
                        underline: const SizedBox(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '超过$days天未联络时发送提醒',
                    style: TextStyle(fontSize: 12, color: textMuted, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
