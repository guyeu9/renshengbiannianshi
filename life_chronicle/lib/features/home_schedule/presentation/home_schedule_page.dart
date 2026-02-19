import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../app/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../ai_historian/presentation/ai_historian_chat_page.dart';
import '../../profile/presentation/profile_page.dart';

class HomeSchedulePage extends StatefulWidget {
  const HomeSchedulePage({super.key});

  @override
  State<HomeSchedulePage> createState() => _HomeSchedulePageState();
}

class _HomeSchedulePageState extends State<HomeSchedulePage> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: const _GlassHeader(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
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
    );
  }
}

class _GlassHeader extends StatelessWidget implements PreferredSizeWidget {
  const _GlassHeader();

  static const _defaultAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBYyAsCsUFotbFS4IxBHOEJ1DA-wBDR1IVfg1d3rW9bLa4YuRfV882W0Gj9D_oJHRv8cju9gfQyluVHnzjDzJMCZbPKUGwAA7SVIlLiY0SznM-y2S8DAks2kYgua7mWcEmcQPOrxDT1oZJJhDdKMwYsdMM7G5NPreBxZIp3VhN08wAO3i6DxKMN9Hp3_QOj-9i5MV5rtBRoa0PirbUtvk_dBOMFEDLzALxQasPjHhvOaXLyEbgAEOptmcXA27XD2JM8qtcZ_u2eFR_T';

  @override
  Size get preferredSize => const Size.fromHeight(72);

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
    } catch (_) {}
    return null;
  }

  ImageProvider _avatarProvider(String? path) {
    final value = path?.trim() ?? '';
    if (value.isEmpty) {
      return const NetworkImage(_defaultAvatarUrl);
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }
    return FileImage(File(value));
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
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
                child: Stack(
                  children: [
                    FutureBuilder<String?>(
                      future: _loadAvatarPath(),
                      builder: (context, snapshot) {
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
                  children: const [
                    Text(
                      '早上好',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '林晓梦',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: AppTheme.textMain,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AiHistorianChatPage()),
                      );
                    },
                    child: const Text('AI史官'),
                  ),
                  const SizedBox(width: 4),
                  _HeaderIconButton(
                    icon: Icons.notifications,
                    showDot: true,
                    onTap: () {},
                  ),
                  _HeaderIconButton(
                    icon: Icons.settings,
                    showDot: false,
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
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
          onPressed: onTap,
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

class _FlashbackSection extends StatelessWidget {
  const _FlashbackSection();

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {},
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
            itemBuilder: (context, index) {
              const items = [
                _FlashbackItem(
                  year: '2020年',
                  title: '京都之旅',
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAsJBzDdfeS11TyD-1cqHJq_9G-Vw7SIu91Xqg9sf-Z8rWwTdxLbyxmT0V4m-h499LovcoZM7UquYeAkDvq8PzCzti_Gd9KPvABltL36GorEihS00Q1WQfZbbs2qKP725v6TeXBbbnXyw24x7sVbBhia3-IOfmck4ef0sx6MIGhWezXCTHiwHRq-3ys196RVyQcOl8SBzUfWvQCjkNcZcKY7LrbNWKdt0Ch3LsRMXiEbZW_KlrfAqXMx6O-hXkk65qGX5dRuxMmA96M',
                ),
                _FlashbackItem(
                  year: '2021年',
                  title: '毕业聚餐',
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAX_r4kxgvpQYvypR_RF0YAJZAw52PhW6TR5_IJrx5xuClBJjvG60Be4hZ29hlgNDYNTxst1hIGyftAKGVU_ZeXhXRMpzZ-dWMCWPWDmJKrGwskGz5aAyp6ILOVKbGO7eOoEXtriK3It1UaJ88ITU_XSbXD_xMjr9DMB4OhDbvOe-xTRup_sRthPrG37YiL9gosZWDelVEFDPIIwMrhV5YpuW92cyP4tMEr9u5HkHiOUIkX8x9FZBICQFiiAv2s-ASTnbykZxt3Vf0O',
                ),
                _FlashbackItem(
                  year: '2018年',
                  title: '瑞士滑雪',
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuA5lNkMZP8lzhAYUfC_VTKiokDBAuZngbPVBMBYzPENVfmKvfs62McJJ8qPhRz63_3ieVJYb36HMkb_-GLgQkJXUoz8cAUVuKXGKCLIqcuLI1Vn1cRcqSefVw2OR_z0ypFw035yhhwHlSBpxKs03a_IIg3bVM_cWzSfmZSwjKe5VEecoMpRaY0IRHXqDPIaKlpg_lUMzWAX-saGXwxlUjRtRRyqCqtozDLt053M7STJOBL0uMNNQDOmn1T-Q2GFsMc2vWJAZOKJRcqZ',
                ),
              ];
              return items[index];
            },
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemCount: 3,
          ),
        ),
      ],
    );
  }
}

class _FlashbackItem extends StatelessWidget {
  const _FlashbackItem({
    required this.year,
    required this.title,
    required this.imageUrl,
  });

  final String year;
  final String title;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 160,
        height: 208,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
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
                  Text(
                    year,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _TodayReminder extends StatelessWidget {
  const _TodayReminder();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            decoration: const BoxDecoration(
              color: Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cake, size: 16, color: Color(0xFFEF4444)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: const TextSpan(
                style: TextStyle(fontSize: 14, color: Color(0xFF374151), fontWeight: FontWeight.w600),
                children: [
                  TextSpan(text: '张三', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w800)),
                  TextSpan(text: ' 的生日还有 '),
                  TextSpan(text: '2天', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
        ],
      ),
    );
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
    return StreamBuilder<List<TimelineEvent>>(
      stream: db.watchEventsForMonth(_focusMonth),
      builder: (context, snapshot) {
        final events = snapshot.data ?? [];
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
              ),
            ],
          ),
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
  });

  final DateTime focusMonth;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelectDay;
  final List<TimelineEvent> events;

  List<_CalendarCellData> _buildCells() {
    final year = focusMonth.year;
    final month = focusMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstDay = DateTime(year, month, 1);
    final leadingDays = firstDay.weekday % 7;
    final prevMonthDays = DateTime(year, month, 0).day;

    const dotBlue = Color(0xFF60A5FA);
    const dotOrange = Color(0xFFFB923C);

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

      // Keep hardcoded examples for demonstration if no real events, 
      // but prioritize real events if available.
      // Actually, let's mix them or just use real events. 
      // Given the user wants "notes to show", let's rely on real events primarily.
      // But to preserve the "demo" look if database is empty, we might keep the logic?
      // No, better to be clean. But I will keep the special icons logic if it was based on specific dates?
      // The previous code had hardcoded logic for day 1, 2, 4, 6, 9, 13.
      // I will remove the hardcoded logic to fully switch to dynamic data, 
      // as requested "ensure TimelineEvent note content displays".

      return _CalendarCellData(
        day: '$displayDay', 
        date: date, 
        selected: selected, 
        dots: dots,
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
  });

  final String day;
  final DateTime? date;
  final bool muted;
  final bool selected;
  final List<Color> dots;
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
          const SizedBox(height: 12),
      ],
    );
    if (data.muted || onTap == null) {
      return content;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
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
      onTap: onTap,
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
    final years = List.generate(13, (index) => now.year - 6 + index);
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
      onTap: onTap,
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
    return StreamBuilder<List<TimelineEvent>>(
      stream: db.watchEventsForDate(selectedDay),
      builder: (context, snapshot) {
        final events = snapshot.data ?? [];
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
                      text: '  ${events.length}个记录',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (events.isEmpty)
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
              for (final event in events)
                _TimelineItem(
                  time: _formatTime(event.startAt),
                  title: event.title,
                  subtitle: event.note,
                  leadingIcon: _getIconForType(event.eventType),
                  leadingBg: _getColorForType(event.eventType).withValues(alpha: 0.1),
                  leadingFg: _getColorForType(event.eventType),
                  showLine: event != events.last,
                ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'work':
        return Icons.work;
      case 'personal':
        return Icons.person;
      case 'travel':
        return Icons.flight;
      case 'food':
        return Icons.restaurant;
      case 'encounter':
        return Icons.people;
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
      default:
        return Colors.grey;
    }
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
  });

  final String time;
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Color leadingBg;
  final Color leadingFg;
  final bool showLine;

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
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        height: 64,
        color: bg,
        child: Icon(icon ?? Icons.event, size: 32, color: fg),
      ),
    );
  }
}
