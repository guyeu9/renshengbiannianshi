import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class GoalPage extends StatelessWidget {
  const GoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: const [
            _GoalHeader(),
            Expanded(child: _GoalHomeBody()),
          ],
        ),
      ),
    );
  }
}

class _GoalHeader extends StatelessWidget {
  const _GoalHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('目标', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2BCDEE),
                  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                child: const Text('解析'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Color(0xFF9CA3AF), size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '搜索目标、标签..',
                          style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _CircleButton(icon: Icons.tune, onTap: () {}),
              const SizedBox(width: 12),
              _CircleButton(
                icon: Icons.add,
                iconColor: const Color(0xFF2BCDEE),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GoalCreatePage())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap, this.iconColor});

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(width: 48, height: 48, child: Icon(icon, color: iconColor ?? const Color(0xFF6B7280), size: 22)),
      ),
    );
  }
}

class _GoalHomeBody extends StatelessWidget {
  const _GoalHomeBody();

  static const _items = <GoalItem>[
    GoalItem(title: '读完 24 本书', category: '成长', progress: 0.58, accent: Color(0xFF8B5CF6)),
    GoalItem(title: '跑步 300 公里', category: '健康', progress: 0.36, accent: Color(0xFF22C55E)),
    GoalItem(title: '去 3 个国家', category: '旅行', progress: 0.67, accent: Color(0xFF06B6D4)),
    GoalItem(title: '完成一门课程', category: '技能', progress: 0.22, accent: Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 140),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('人生目标看板', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                    SizedBox(height: 6),
                    Text('年度进度 · 专注当下', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFE2E8F0))),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.flag, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('进行中', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        const SizedBox(height: 12),
        for (final item in _items) ...[
          _GoalCard(item: item),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 6),
        const Text('已完成', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF22C55E)),
              SizedBox(width: 10),
              Expanded(child: Text('完成一次 10 公里跑', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
              Text('2025', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ],
    );
  }
}

class GoalItem {
  const GoalItem({required this.title, required this.category, required this.progress, required this.accent});

  final String title;
  final String category;
  final double progress;
  final Color accent;
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.item});

  final GoalItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GoalDetailPage(item: item))),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: item.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                    child: Text(item.category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: item.accent)),
                  ),
                  const Spacer(),
                  Text('${(item.progress * 100).round()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: item.accent)),
                ],
              ),
              const SizedBox(height: 10),
              Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: item.progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation(item.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoalDetailPage extends StatelessWidget {
  const GoalDetailPage({super.key, required this.item});

  final GoalItem item;

  @override
  Widget build(BuildContext context) {
    return _GoalBreakdownDetailPage(item: item);
  }
}

class _GoalBreakdownDetailPage extends StatefulWidget {
  const _GoalBreakdownDetailPage({required this.item});

  final GoalItem item;

  @override
  State<_GoalBreakdownDetailPage> createState() => _GoalBreakdownDetailPageState();
}

class _GoalBreakdownDetailPageState extends State<_GoalBreakdownDetailPage> {
  bool _day12Done = true;
  bool _day13Done = false;

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime(2026, 12, 31);
    final now = DateTime.now();
    final leftDays = dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    final leftText = leftDays >= 0 ? '剩 $leftDays 天' : '已超期 ${-leftDays} 天';
    final progressPercent = (widget.item.progress * 100).round().clamp(0, 100);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Container(
                  height: 320,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x1A2BCDEE), Color(0x00FFFFFF)],
                    ),
                  ),
                ),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text('目标详情', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        ),
                      ),
                      _CircleIconButton(icon: Icons.more_horiz, onTap: () {}),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 140),
                    children: [
                      const SizedBox(height: 2),
                      _HeroProgressRing(progress: widget.item.progress, percentText: '$progressPercent%'),
                      const SizedBox(height: 16),
                      Text(
                        widget.item.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFF3F4F6)),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.event, size: 16, color: AppTheme.primary),
                              const SizedBox(width: 6),
                              const Text('截止: 2026.12.31', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
                              const SizedBox(width: 12),
                              Container(width: 1, height: 14, color: const Color(0xFFD1D5DB)),
                              const SizedBox(width: 12),
                              const Icon(Icons.hourglass_bottom, size: 16, color: AppTheme.primary),
                              const SizedBox(width: 6),
                              Text(leftText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _QuarterNode(
                        quarter: 'Q1',
                        title: '基础词汇积累',
                        progress: 1.0,
                        state: _QuarterState.done,
                        children: const [
                          _QuarterDoneItem(text: '1月: 核心500词'),
                          _QuarterDoneItem(text: '2月: 常用短语100句'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _QuarterNode(
                        quarter: 'Q2',
                        title: '语法与听力强化',
                        progress: 0.45,
                        state: _QuarterState.active,
                        child: _MonthCard(
                          title: '5月目标: 完成 A1 语法课程',
                          tasks: [
                            _DayTaskTile(
                              checked: _day12Done,
                              enabled: true,
                              style: _DayTaskStyle.done,
                              title: 'Day 12: 动词变位练习',
                              onChanged: (v) => setState(() => _day12Done = v),
                            ),
                            _DayTaskTile(
                              checked: _day13Done,
                              enabled: true,
                              style: _DayTaskStyle.today,
                              title: 'Day 13: 虚拟语气专向',
                              subtitle: '今日任务',
                              onChanged: (v) => setState(() => _day13Done = v),
                            ),
                            const _DayTaskTile(
                              checked: false,
                              enabled: false,
                              style: _DayTaskStyle.future,
                              title: 'Day 14: 单元测试',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _QuarterNode(
                        quarter: 'Q3',
                        title: '口语实战演练',
                        progress: 0.0,
                        state: _QuarterState.locked,
                        lockedHint: '需完成 Q2 目标后解锁',
                        hideConnector: true,
                      ),
                      const SizedBox(height: 18),
                      Container(height: 1, color: const Color(0xFFE5E7EB)),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(child: Text('关联记忆', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(foregroundColor: AppTheme.primary, textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                            child: const Text('查看全部'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 186,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: const [
                            _MemoryCard(
                              typeIcon: Icons.restaurant,
                              typeColor: Color(0xFFF97316),
                              title: '第一次尝试法式吐司',
                              date: '2023.04.15',
                              imageUrl:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAIz9iyBW7XYz1OXJn7PODVjs8ztawCp0fymdJCX3pWnlHJRdwvyiy-ymkpQeIrJaOaUUT6P4TgmbmE_45c5D7O03bKoAuRJ8bKsKTry8bq97ZTyuffJXnLK8SH6aSBEw0bY6G2OFDTfluLPFwXs1LN1dJARFwA5UbeIE3SIZIsyJJPNrdGSBY-c65ENonTHuxpaG7AuQ_WI-AhTUZPNsqBbpEOrQN1BbI1Tgt-Te5clV1zGoLyKHYheS5Norc7Atu-Ni9puF3S3nc4',
                            ),
                            SizedBox(width: 12),
                            _MemoryCard(
                              typeIcon: Icons.flight,
                              typeColor: Color(0xFF3B82F6),
                              title: '巴黎旅行计划灵感',
                              date: '2023.05.01',
                              imageUrl:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDGq_E_dEf6r-NRzup0qz7D171fL9-xHigTMP_23Po7lznnOefHD3aJUpMeGOUjkl06qbXk1GeaZQjnS-loSrAAJkg6KbRVvIaQGWn6cKcwV47NBSKNW0Jp6QhbDHVgmt-4mO6cI8zN9gTh6VwjuO_BJMTFTlHqgzdV5MFI0qy1k-LMK-fUteEQ-tdyJZqXwyTjMlIpBfEhPg5pFdAqTWcSKZ_RRvJhaiYhLPm4EaCq2pNBM2hBSTmL25iOS_glMDjJKULprE_EFm48',
                            ),
                            SizedBox(width: 12),
                            _TextMemoryCard(title: '学习日记 #42', excerpt: '“今天背单词感觉很顺...”', date: '2023.05.12'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.update, size: 18),
                  label: const Text('顺延计划'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.rate_review, size: 18),
                  label: const Text('阶段复盘'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.65), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF111827), size: 20),
        ),
      ),
    );
  }
}

class _HeroProgressRing extends StatelessWidget {
  const _HeroProgressRing({required this.progress, required this.percentText});

  final double progress;
  final String percentText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 192,
        height: 192,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 192,
              height: 192,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 12,
                valueColor: const AlwaysStoppedAnimation(Color(0xFFE5E7EB)),
              ),
            ),
            SizedBox(
              width: 192,
              height: 192,
              child: CircularProgressIndicator(
                value: progress.clamp(0, 1),
                strokeWidth: 12,
                valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  percentText,
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.primary, height: 1),
                ),
                const SizedBox(height: 6),
                const Text('进行中', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _QuarterState { done, active, locked }

class _QuarterNode extends StatelessWidget {
  const _QuarterNode({
    required this.quarter,
    required this.title,
    required this.progress,
    required this.state,
    this.children = const [],
    this.child,
    this.lockedHint,
    this.hideConnector = false,
  });

  final String quarter;
  final String title;
  final double progress;
  final _QuarterState state;
  final List<Widget> children;
  final Widget? child;
  final String? lockedHint;
  final bool hideConnector;

  @override
  Widget build(BuildContext context) {
    final isDone = state == _QuarterState.done;
    final isActive = state == _QuarterState.active;
    final isLocked = state == _QuarterState.locked;

    final circle = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDone ? AppTheme.primary : (isLocked ? const Color(0xFFE5E7EB) : Colors.white),
        shape: BoxShape.circle,
        border: isDone || isLocked ? null : Border.all(color: AppTheme.primary, width: 2),
      ),
      child: Center(
        child: Text(
          quarter,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isDone ? Colors.white : (isLocked ? const Color(0xFF6B7280) : AppTheme.primary),
          ),
        ),
      ),
    );

    final headerCard = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFFF9FAFB) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isLocked ? const Color(0xFFD1D5DB) : const Color(0xFFF3F4F6), style: isLocked ? BorderStyle.solid : BorderStyle.solid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isLocked ? const Color(0xFF6B7280) : const Color(0xFF111827),
                  ),
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(8)),
                  child: const Text('进行中', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                ),
            ],
          ),
          if (isLocked && lockedHint != null) ...[
            const SizedBox(height: 6),
            Text(lockedHint!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
          ],
          if (!isLocked) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 6,
                backgroundColor: const Color(0xFFF3F4F6),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              ),
            ),
          ],
        ],
      ),
    );

    return Stack(
      children: [
        if (!hideConnector)
          Positioned(
            left: 19,
            top: 44,
            bottom: 0,
            child: Container(width: 2, color: const Color(0xFFE5E7EB)),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                circle,
                const SizedBox(width: 12),
                Expanded(child: Opacity(opacity: isLocked ? 0.60 : 1, child: headerCard)),
              ],
            ),
            if (children.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: AppTheme.primary.withValues(alpha: 0.25), width: 2, style: BorderStyle.solid)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
                ),
              ),
            ],
            if (child != null) ...[
              const SizedBox(height: 10),
              child!,
            ],
          ],
        ),
      ],
    );
  }
}

class _QuarterDoneItem extends StatelessWidget {
  const _QuarterDoneItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF6B7280), decoration: TextDecoration.lineThrough),
            ),
          ),
          const Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
        ],
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.title, required this.tasks});

  final String title;
  final List<Widget> tasks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Stack(
        children: [
          Positioned(
            left: 24,
            top: 20,
            child: Container(width: 16, height: 1, color: const Color(0xFFD1D5DB)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0EA5B7))),
                  const SizedBox(height: 10),
                  ...tasks.expand((e) => [e, const SizedBox(height: 10)]).toList()..removeLast(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _DayTaskStyle { done, today, future }

class _DayTaskTile extends StatelessWidget {
  const _DayTaskTile({
    required this.checked,
    required this.enabled,
    required this.style,
    required this.title,
    this.subtitle,
    this.onChanged,
  });

  final bool checked;
  final bool enabled;
  final _DayTaskStyle style;
  final String title;
  final String? subtitle;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final borderColor = style == _DayTaskStyle.today ? AppTheme.primary.withValues(alpha: 0.30) : const Color(0xFFF3F4F6);
    final fillColor = enabled ? Colors.white : Colors.white.withValues(alpha: 0.50);
    final opacity = enabled ? 1.0 : 0.60;
    final titleStyle = TextStyle(
      fontSize: 13,
      fontWeight: style == _DayTaskStyle.today ? FontWeight.w900 : FontWeight.w800,
      color: checked ? const Color(0xFF9CA3AF) : const Color(0xFF374151),
      decoration: checked ? TextDecoration.lineThrough : TextDecoration.none,
    );

    return Opacity(
      opacity: opacity,
      child: Material(
        color: fillColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled && onChanged != null ? () => onChanged!(!checked) : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor)),
            child: Row(
              children: [
                Checkbox.adaptive(
                  value: checked,
                  onChanged: enabled && onChanged != null ? (v) => onChanged!(v ?? false) : null,
                  activeColor: AppTheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: subtitle == null
                      ? Text(title, style: titleStyle)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: titleStyle.copyWith(color: const Color(0xFF111827), decoration: TextDecoration.none)),
                            const SizedBox(height: 2),
                            Text(subtitle!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.typeIcon, required this.typeColor, required this.title, required this.date, required this.imageUrl});

  final IconData typeIcon;
  final Color typeColor;
  final String title;
  final String date;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 128,
                  height: 128,
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
                  child: Icon(typeIcon, size: 14, color: typeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

class _TextMemoryCard extends StatelessWidget {
  const _TextMemoryCard({required this.title, required this.excerpt, required this.date});

  final String title;
  final String excerpt;
  final String date;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 128,
            height: 128,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A).withValues(alpha: 0.50)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_stories, size: 30, color: Color(0xFFFBBF24)),
                const SizedBox(height: 8),
                Text(excerpt, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF92400E), height: 1.25)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

class GoalCreatePage extends StatelessWidget {
  const GoalCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.75),
        title: const Text('新建目标', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          TextButton(onPressed: () {}, child: const Text('保存', style: TextStyle(fontWeight: FontWeight.w900))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('标题', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                SizedBox(height: 10),
                TextField(decoration: InputDecoration(hintText: '例如：读完24本书', border: InputBorder.none)),
                SizedBox(height: 12),
                Text('分类', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                SizedBox(height: 10),
                TextField(decoration: InputDecoration(hintText: '成长/健康/旅行…', border: InputBorder.none)),
                SizedBox(height: 12),
                Text('截止时间', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                SizedBox(height: 10),
                TextField(decoration: InputDecoration(hintText: 'YYYY-MM-DD', border: InputBorder.none)),
                SizedBox(height: 12),
                Text('描述', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                SizedBox(height: 10),
                TextField(minLines: 4, maxLines: 10, decoration: InputDecoration(hintText: '写下你的目标规划…', border: InputBorder.none)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    SizedBox(width: 4),
                    SizedBox(width: 4, height: 16, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFF2BCDEE), borderRadius: BorderRadius.all(Radius.circular(999))))),
                    SizedBox(width: 10),
                    Text('万物关联', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  ],
                ),
                const SizedBox(height: 12),
                _GoalLinkRow(
                  iconBackground: Color(0xFFEFF6FF),
                  icon: Icons.auto_awesome,
                  iconColor: Color(0xFF60A5FA),
                  title: '关联小确幸',
                  trailingText: '选择小确幸',
                ),
                _GoalLinkRow(
                  iconBackground: Color(0xFFFFEDD5),
                  icon: Icons.restaurant,
                  iconColor: Color(0xFFFB923C),
                  title: '关联美食',
                  trailingText: '选择美食记录',
                ),
                _GoalLinkRow(
                  iconBackground: Color(0xFFFCE7F3),
                  icon: Icons.people,
                  iconColor: Color(0xFFEC4899),
                  title: '关联羁绊',
                  trailingText: '选择朋友/相遇',
                ),
                _GoalLinkRow(
                  iconBackground: Color(0xFFF0FDF4),
                  icon: Icons.flight_takeoff,
                  iconColor: Color(0xFF22C55E),
                  title: '关联旅行',
                  trailingText: '选择旅行记录',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalLinkRow extends StatelessWidget {
  const _GoalLinkRow({
    required this.iconBackground,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailingText,
  });

  final Color iconBackground;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String trailingText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
            Text(trailingText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }
}
