import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../ai_historian/presentation/ai_historian_chat_page.dart';
import '../../profile/presentation/profile_page.dart';

class HomeSchedulePage extends StatelessWidget {
  const HomeSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: const _GlassHeader(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
        children: const [
          _FlashbackSection(),
          SizedBox(height: 16),
          _TodayReminder(),
          SizedBox(height: 16),
          _CalendarCard(),
          SizedBox(height: 16),
          _EventStream(),
        ],
      ),
    );
  }
}

class _GlassHeader extends StatelessWidget implements PreferredSizeWidget {
  const _GlassHeader();

  @override
  Size get preferredSize => const Size.fromHeight(72);

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
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBYyAsCsUFotbFS4IxBHOEJ1DA-wBDR1IVfg1d3rW9bLa4YuRfV882W0Gj9D_oJHRv8cju9gfQyluVHnzjDzJMCZbPKUGwAA7SVIlLiY0SznM-y2S8DAks2kYgua7mWcEmcQPOrxDT1oZJJhDdKMwYsdMM7G5NPreBxZIp3VhN08wAO3i6DxKMN9Hp3_QOj-9i5MV5rtBRoa0PirbUtvk_dBOMFEDLzALxQasPjHhvOaXLyEbgAEOptmcXA27XD2JM8qtcZ_u2eFR_T',
                      ),
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

class _CalendarCard extends StatelessWidget {
  const _CalendarCard();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final focusMonth = DateTime(now.year, now.month, 1);
    final selectedDay = DateTime(now.year, now.month, now.day);

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
          _CalendarHeader(month: focusMonth.month, year: focusMonth.year),
          const SizedBox(height: 14),
          const _WeekdayRow(),
          const SizedBox(height: 10),
          _CalendarGrid(focusMonth: focusMonth, selectedDay: selectedDay),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({required this.month, required this.year});

  final int month;
  final int year;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$month月',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textMain),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Text(
            '$year',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF)),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: const Text(
                  '月',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  '周',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
        ),
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
  const _CalendarGrid({required this.focusMonth, required this.selectedDay});

  final DateTime focusMonth;
  final DateTime selectedDay;

  List<_CalendarCellData> _buildCells() {
    final year = focusMonth.year;
    final month = focusMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstDay = DateTime(year, month, 1);
    final leadingDays = firstDay.weekday % 7;
    final prevMonthDays = DateTime(year, month, 0).day;

    const dotBlue = Color(0xFF60A5FA);

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

      if (displayDay == 1) {
        return _CalendarCellData(day: '$displayDay', selected: selected, dots: const [dotBlue]);
      }
      if (displayDay == 2) {
        return _CalendarCellData(day: '$displayDay', selected: selected, icon: Icons.star, iconColor: const Color(0xFFFBBF24));
      }
      if (displayDay == 4) {
        return _CalendarCellData(
          day: '$displayDay',
          selected: selected,
          icon: Icons.fitness_center,
          iconColor: const Color(0xFFC084FC),
        );
      }
      if (displayDay == 6) {
        return _CalendarCellData(day: '$displayDay', selected: selected, icon: Icons.favorite, iconColor: const Color(0xFFF87171));
      }
      if (displayDay == 9) {
        return _CalendarCellData(
          day: '$displayDay',
          selected: selected,
          multiIcons: const [
            _MiniIcon(Icons.restaurant, Color(0xFFFB923C)),
            _MiniIcon(Icons.flight, dotBlue),
          ],
        );
      }
      if (displayDay == 13) {
        return _CalendarCellData(
          day: '$displayDay',
          selected: selected,
          icon: Icons.energy_savings_leaf,
          iconColor: const Color(0xFF22C55E),
        );
      }

      return _CalendarCellData(day: '$displayDay', selected: selected);
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
        mainAxisSpacing: 12,
        crossAxisSpacing: 0,
        childAspectRatio: 1.2,
      ),
      itemCount: cells.length,
      itemBuilder: (context, index) => _CalendarCell(data: cells[index]),
    );
  }
}

class _CalendarCellData {
  const _CalendarCellData({
    required this.day,
    this.muted = false,
    this.selected = false,
    this.icon,
    this.iconColor,
    this.dots = const [],
    this.multiIcons = const [],
  });

  final String day;
  final bool muted;
  final bool selected;
  final IconData? icon;
  final Color? iconColor;
  final List<Color> dots;
  final List<_MiniIcon> multiIcons;
}

class _MiniIcon {
  const _MiniIcon(this.icon, this.color);

  final IconData icon;
  final Color color;
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({required this.data});

  final _CalendarCellData data;

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

    return Column(
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
        else if (data.multiIcons.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final m in data.multiIcons)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Icon(m.icon, size: 12, color: m.color),
                ),
            ],
          )
        else if (data.icon != null)
          Icon(data.icon, size: 12, color: data.iconColor ?? AppTheme.textMuted)
        else
          const SizedBox(height: 12),
      ],
    );
  }
}

class _EventStream extends StatelessWidget {
  const _EventStream();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain),
              children: [
                TextSpan(text: '日程记录'),
                TextSpan(
                  text: '  5个记录',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _TimelineItem(
          time: '09:00',
          title: '早午餐会议',
          leadingImageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDvDIrPwminF7o-n2aPp44blUUlZDGZBcEI5o-oOA0cHuiXoT8GYx0Ye4DVLakU2Yu9JPJ-YYd3mmooidnjMqs6zLkkMHHw8wfXE09l7HeU65odVplHfu_Ld2A2Nac6n98F6pfnuv7kj3Iz9F5IbNih56g2lW0SXgs0G0Amt8wm2ZCGY3VRxJ_rfQkSkx5hvgtUFqBq42t43Rva5NpiXEwviX9HtXmtHhZnD4G9Yf95-wMgdksNQ5g7JmnR3fS04L5onQSXyZxih5BO',
          tags: [
            _TagData(icon: Icons.restaurant, label: '美食', bg: Color(0xFFFFF7ED), fg: Color(0xFFEA580C), border: Color(0xFFFFEDD5)),
            _TagData(icon: Icons.place, label: '蓝山咖啡馆', bg: Color(0xFFF9FAFB), fg: Color(0xFF4B5563), border: Color(0xFFF3F4F6)),
          ],
        ),
        const _TimelineItem(
          time: '11:30',
          title: '出差准备：整理行李与行程',
          leadingIcon: Icons.park,
          leadingBg: Color(0xFFF0FDF4),
          leadingFg: Color(0xFF22C55E),
          tags: [
            _TagData(icon: Icons.travel_explore, label: '旅行', bg: Color(0xFFEFF6FF), fg: Color(0xFF2563EB), border: Color(0xFFDBEAFE)),
          ],
        ),
        const _TimelineItem(
          time: '17:30',
          title: '完成每日30分钟阅读任务',
          leadingIcon: Icons.menu_book,
          leadingBg: Color(0xFFF0FDFA),
          leadingFg: Color(0xFF14B8A6),
          tags: [
            _TagData(icon: Icons.track_changes, label: '目标', bg: Color(0xFFF0FDFA), fg: Color(0xFF0D9488), border: Color(0xFFCCFBF1)),
          ],
        ),
        const _TimelineItem(
          time: '14:00',
          title: '出差准备',
          subtitle: '整理行李，确认机票信息，打印会议资料。',
          leadingIcon: Icons.flight_takeoff,
          leadingBg: Color(0xFFEFF6FF),
          leadingFg: Color(0xFF60A5FA),
          tags: [
            _TagData(icon: Icons.tag, label: '工作', bg: Color(0x80EFF6FF), fg: Color(0xFF2563EB), border: Color(0xFFDBEAFE)),
          ],
        ),
        const _TimelineItem(
          time: '19:30',
          title: '能量时刻：与老友视频通话',
          leadingIcon: Icons.videocam,
          leadingBg: Color(0xFFF5F3FF),
          leadingFg: Color(0xFFA78BFA),
          tags: [
            _TagData(icon: Icons.groups, label: '羁绊', bg: Color(0xFFF5F3FF), fg: Color(0xFF7C3AED), border: Color(0xFFEDE9FE)),
          ],
          showLine: false,
        ),
      ],
    );
  }
}

class _TagData {
  const _TagData({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.border,
  });

  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final Color border;
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.time,
    required this.title,
    this.subtitle,
    this.leadingImageUrl,
    this.leadingIcon,
    this.leadingBg = const Color(0xFFF3F4F6),
    this.leadingFg = const Color(0xFF6B7280),
    this.tags = const [],
    this.showLine = true,
  });

  final String time;
  final String title;
  final String? subtitle;
  final String? leadingImageUrl;
  final IconData? leadingIcon;
  final Color leadingBg;
  final Color leadingFg;
  final List<_TagData> tags;
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
                      imageUrl: leadingImageUrl,
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
                          if (tags.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final t in tags)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: t.bg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: t.border),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(t.icon, size: 12, color: t.fg),
                                        const SizedBox(width: 4),
                                        Text(
                                          t.label,
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: t.fg),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
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
    required this.imageUrl,
    required this.icon,
    required this.bg,
    required this.fg,
  });

  final String? imageUrl;
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
        child: imageUrl != null
            ? Image.network(imageUrl!, fit: BoxFit.cover)
            : Icon(icon ?? Icons.event, size: 32, color: fg),
      ),
    );
  }
}
