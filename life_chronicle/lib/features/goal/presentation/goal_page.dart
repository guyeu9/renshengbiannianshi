import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../app/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/utils/media_storage.dart';

class _GoalTypeOption {
  const _GoalTypeOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.accent,
    required this.background,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color accent;
  final Color background;
}

const _goalTypeOptions = <_GoalTypeOption>[
  _GoalTypeOption(
    value: '职业',
    label: '职业发展',
    icon: Icons.work,
    accent: Color(0xFF3B82F6),
    background: Color(0xFFEFF6FF),
  ),
  _GoalTypeOption(
    value: '健康',
    label: '身心健康',
    icon: Icons.favorite,
    accent: Color(0xFFEF4444),
    background: Color(0xFFFEE2E2),
  ),
  _GoalTypeOption(
    value: '旅行',
    label: '环球旅行',
    icon: Icons.flight_takeoff,
    accent: Color(0xFF10B981),
    background: Color(0xFFDCFCE7),
  ),
];

_GoalTypeOption? _goalTypeFor(String? value) {
  if (value == null) return null;
  for (final option in _goalTypeOptions) {
    if (option.value == value || option.label == value) return option;
  }
  return null;
}

Color _goalAccentFor(String? value) {
  return _goalTypeFor(value)?.accent ?? AppTheme.primary;
}

String _goalLabelFor(String? value) {
  return _goalTypeFor(value)?.label ?? (value?.isNotEmpty == true ? value! : '未分类');
}

_GoalTypeOption _goalMetaForLabel(String label) {
  for (final option in _goalTypeOptions) {
    if (option.label == label || option.value == label) {
      return option;
    }
  }
  return _GoalTypeOption(
    value: label,
    label: label.isEmpty ? '未分类' : label,
    icon: Icons.flag,
    accent: AppTheme.primary,
    background: const Color(0xFFEFF6FF),
  );
}

String _formatYearMonth(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  return '${date.year}年$month月';
}

String _goalDeadlineLabel(GoalRecord record) {
  if (record.dueDate != null) {
    return '截止: ${_formatYearMonth(record.dueDate!)}';
  }
  if (record.targetYear != null && record.targetMonth != null) {
    return '截止: ${record.targetYear}年${record.targetMonth}月';
  }
  if (record.targetYear != null) {
    return '截止: ${record.targetYear}年';
  }
  return '截止: 未设置';
}

class _RemindOption {
  const _RemindOption({required this.value, required this.label, required this.detail});

  final String value;
  final String label;
  final String detail;
}

const _remindOptions = <_RemindOption>[
  _RemindOption(value: 'weekly', label: '每周一', detail: '每周一 · 上午 09:00'),
  _RemindOption(value: 'daily', label: '每天', detail: '每天 · 上午 09:00'),
  _RemindOption(value: 'monthly', label: '每月1日', detail: '每月1日 · 上午 09:00'),
  _RemindOption(value: 'none', label: '不提醒', detail: '不提醒'),
];

_RemindOption _remindOptionFor(String value) {
  return _remindOptions.firstWhere((option) => option.value == value, orElse: () => _remindOptions.first);
}

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

class _GoalHomeBody extends ConsumerStatefulWidget {
  const _GoalHomeBody();

  @override
  ConsumerState<_GoalHomeBody> createState() => _GoalHomeBodyState();
}

class _GoalHomeBodyState extends ConsumerState<_GoalHomeBody> {
  int _selectedYear = DateTime.now().year;

  Stream<List<GoalRecord>> _watchYearGoals(AppDatabase db) {
    final query = db.select(db.goalRecords)
      ..where((t) => t.level.equals('year'))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  int _goalYear(GoalRecord record) {
    return record.targetYear ?? record.recordDate.year;
  }

  Future<void> _pickYear(List<int> years, int activeYear) async {
    if (years.isEmpty) return;
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: years.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              final year = years[index];
              final isActive = year == activeYear;
              return ListTile(
                title: Text('$year年', style: TextStyle(fontWeight: FontWeight.w800, color: isActive ? const Color(0xFF2BCDEE) : const Color(0xFF111827))),
                trailing: isActive ? const Icon(Icons.check, color: Color(0xFF2BCDEE)) : null,
                onTap: () => Navigator.of(context).pop(year),
              );
            },
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    setState(() => _selectedYear = selected);
  }

  void _shiftYear(List<int> years, int activeYear, int delta) {
    if (years.isEmpty) return;
    final index = years.indexOf(activeYear);
    if (index == -1) return;
    final nextIndex = index + delta;
    if (nextIndex < 0 || nextIndex >= years.length) return;
    setState(() => _selectedYear = years[nextIndex]);
  }

  void _handleYearSwipe(List<int> years, int activeYear, DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity == 0) return;
    if (velocity > 0) {
      _shiftYear(years, activeYear, 1);
    } else {
      _shiftYear(years, activeYear, -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder<List<GoalRecord>>(
      stream: _watchYearGoals(db),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <GoalRecord>[];
        final years = records.map(_goalYear).toSet().toList()..sort((a, b) => b.compareTo(a));
        final activeYear = years.contains(_selectedYear) ? _selectedYear : (years.isNotEmpty ? years.first : _selectedYear);
        final yearGoals = records.where((r) => _goalYear(r) == activeYear).toList(growable: false);
        final inProgress = yearGoals.where((r) => !r.isCompleted).length;
        final completed = yearGoals.where((r) => r.isCompleted).length;
        final total = yearGoals.length;
        final completionRate = total == 0 ? 0 : (completed / total);
        final grouped = <String, List<GoalRecord>>{};
        for (final goal in yearGoals) {
          final label = _goalLabelFor(goal.category);
          grouped.putIfAbsent(label, () => []).add(goal);
        }
        final orderedLabels = <String>[
          for (final option in _goalTypeOptions)
            if (grouped.containsKey(option.label)) option.label,
          for (final label in grouped.keys)
            if (!_goalTypeOptions.any((o) => o.label == label)) label,
        ];

        final yearIndex = years.indexOf(activeYear);
        final canPrev = yearIndex >= 0 && yearIndex < years.length - 1;
        final canNext = yearIndex > 0;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 140),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('年度目标', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AnnualGoalSummaryPage(initialYear: activeYear, availableYears: years)),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  child: const Text('历史年度总结'),
                ),
              ],
            ),
            GestureDetector(
              onHorizontalDragEnd: (details) => _handleYearSwipe(years, activeYear, details),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _shiftYear(years, activeYear, 1),
                    icon: Icon(Icons.chevron_left, color: canPrev ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0)),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => _pickYear(years, activeYear),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Text('$activeYear年', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
                          const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF2BCDEE)),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _shiftYear(years, activeYear, -1),
                    icon: Icon(Icons.chevron_right, color: canNext ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _YearOverviewCard(
                    value: '$inProgress',
                    label: '进行中',
                    valueColor: const Color(0xFFA855F7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _YearOverviewCard(
                    value: '$completed',
                    label: '已完成',
                    valueColor: const Color(0xFFA855F7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _YearOverviewCard(
                    value: '${(completionRate * 100).round()}%',
                    label: '完成率',
                    valueColor: const Color(0xFFA855F7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (yearGoals.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
                child: const Text('暂无年度目标', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
              )
            else
              for (final label in orderedLabels) ...[
                _GoalCategorySection(
                  label: label,
                  goals: grouped[label] ?? const [],
                  db: db,
                ),
                const SizedBox(height: 18),
              ],
          ],
        );
      },
    );
  }
}

class _YearOverviewCard extends StatelessWidget {
  const _YearOverviewCard({required this.value, required this.label, required this.valueColor});

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: valueColor)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

class _GoalCategorySection extends StatelessWidget {
  const _GoalCategorySection({required this.label, required this.goals, required this.db});

  final String label;
  final List<GoalRecord> goals;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    final meta = _goalMetaForLabel(label);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: meta.background, borderRadius: BorderRadius.circular(10)),
              child: Icon(meta.icon, size: 16, color: meta.accent),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            for (final goal in goals) ...[
              _AnnualGoalCard(record: goal, db: db),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class _AnnualGoalCard extends StatelessWidget {
  const _AnnualGoalCard({required this.record, required this.db});

  final GoalRecord record;
  final AppDatabase db;

  Stream<List<GoalRecord>> _watchQuarters() {
    final query = db.select(db.goalRecords)
      ..where((t) => t.parentId.equals(record.id))
      ..where((t) => t.level.equals('quarter'))
      ..where((t) => t.isDeleted.equals(false));
    return query.watch();
  }

  Stream<List<GoalRecord>> _watchDailyTasks(List<String> quarterIds) {
    if (quarterIds.isEmpty) {
      return Stream.value(const <GoalRecord>[]);
    }
    final query = db.select(db.goalRecords)
      ..where((t) => t.parentId.isIn(quarterIds))
      ..where((t) => t.level.equals('daily'))
      ..where((t) => t.isDeleted.equals(false));
    return query.watch();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _goalAccentFor(record.category);
    final progress = record.progress.clamp(0, 1).toDouble();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GoalDetailPage(record: record))),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(record.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  ),
                  Text('${(progress * 100).round()}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: accent)),
                ],
              ),
              const SizedBox(height: 4),
              Text(_goalDeadlineLabel(record), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<GoalRecord>>(
                stream: _watchQuarters(),
                builder: (context, quarterSnapshot) {
                  final quarters = quarterSnapshot.data ?? const <GoalRecord>[];
                  final quarterIds = quarters.map((q) => q.id).toList(growable: false);
                  return StreamBuilder<List<GoalRecord>>(
                    stream: _watchDailyTasks(quarterIds),
                    builder: (context, taskSnapshot) {
                      final tasks = (taskSnapshot.data ?? const <GoalRecord>[]).take(3).toList(growable: false);
                      if (tasks.isEmpty) {
                        return const Text('暂无阶段任务', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFCBD5F5)));
                      }
                      return Column(
                        children: [
                          for (final task in tasks) ...[
                            Row(
                              children: [
                                Icon(task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: task.isCompleted ? accent : const Color(0xFFCBD5F5)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: task.isCompleted ? const Color(0xFF64748B) : const Color(0xFF111827),
                                      decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnnualGoalSummaryPage extends ConsumerStatefulWidget {
  const AnnualGoalSummaryPage({super.key, required this.initialYear, required this.availableYears});

  final int initialYear;
  final List<int> availableYears;

  @override
  ConsumerState<AnnualGoalSummaryPage> createState() => _AnnualGoalSummaryPageState();
}

class _AnnualGoalSummaryPageState extends ConsumerState<AnnualGoalSummaryPage> {
  final GlobalKey _shareKey = GlobalKey();
  final TextEditingController _reviewController = TextEditingController();
  final List<String> _reviewImages = [];
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  List<int> _resolveYears(List<GoalRecord> records) {
    final years = <int>{...widget.availableYears};
    for (final record in records) {
      years.add(record.targetYear ?? record.recordDate.year);
    }
    if (years.isEmpty) {
      final now = DateTime.now().year;
      return List<int>.generate(6, (index) => now - index);
    }
    final sorted = years.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  Future<void> _pickYear(List<int> years, int activeYear) async {
    if (years.isEmpty) return;
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: years.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              final year = years[index];
              final isActive = year == activeYear;
              return ListTile(
                title: Text('$year年', style: TextStyle(fontWeight: FontWeight.w800, color: isActive ? const Color(0xFF2BCDEE) : const Color(0xFF111827))),
                trailing: isActive ? const Icon(Icons.check, color: Color(0xFF2BCDEE)) : null,
                onTap: () => Navigator.of(context).pop(year),
              );
            },
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    setState(() => _selectedYear = selected);
  }

  void _shiftYear(List<int> years, int activeYear, int delta) {
    if (years.isEmpty) return;
    final index = years.indexOf(activeYear);
    if (index == -1) return;
    final nextIndex = index + delta;
    if (nextIndex < 0 || nextIndex >= years.length) return;
    setState(() => _selectedYear = years[nextIndex]);
  }

  void _handleYearSwipe(List<int> years, int activeYear, DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity == 0) return;
    if (velocity > 0) {
      _shiftYear(years, activeYear, 1);
    } else {
      _shiftYear(years, activeYear, -1);
    }
  }

  Future<void> _pickReviewImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;
    final stored = await persistImageFiles(files, folder: 'goal_review', prefix: 'goal_review');
    if (stored.isEmpty) return;
    if (!mounted) return;
    setState(() => _reviewImages.addAll(stored));
  }

  Future<void> _shareLongImage() async {
    final boundary = _shareKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('当前页面无法导出分享图片')));
      return;
    }
    try {
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/goal_summary_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)]);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('导出失败，请稍后重试')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    color: const Color(0xFF111827),
                  ),
                  const Expanded(
                    child: Text('年度目标总结', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  ),
                  IconButton(
                    onPressed: _shareLongImage,
                    icon: const Icon(Icons.share),
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<GoalRecord>>(
                stream: (db.select(db.goalRecords)
                      ..where((t) => t.level.equals('year'))
                      ..where((t) => t.isDeleted.equals(false)))
                    .watch(),
                builder: (context, snapshot) {
                  final records = snapshot.data ?? const <GoalRecord>[];
                  final years = _resolveYears(records);
                  final activeYear = years.contains(_selectedYear) ? _selectedYear : years.first;
                  final yearGoals = records.where((r) => (r.targetYear ?? r.recordDate.year) == activeYear).toList(growable: false);
                  final inProgress = yearGoals.where((r) => !r.isCompleted).length;
                  final completed = yearGoals.where((r) => r.isCompleted).length;
                  final total = yearGoals.length;
                  final completionRate = total == 0 ? 0 : completed / total;
                  final yearIndex = years.indexOf(activeYear);
                  final canPrev = yearIndex >= 0 && yearIndex < years.length - 1;
                  final canNext = yearIndex > 0;
                  final grouped = <String, List<GoalRecord>>{};
                  for (final goal in yearGoals) {
                    final label = _goalLabelFor(goal.category);
                    grouped.putIfAbsent(label, () => []).add(goal);
                  }
                  final orderedLabels = <String>[
                    for (final option in _goalTypeOptions)
                      if (grouped.containsKey(option.label)) option.label,
                    for (final label in grouped.keys)
                      if (!_goalTypeOptions.any((o) => o.label == label)) label,
                  ];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
                    child: RepaintBoundary(
                      key: _shareKey,
                      child: Container(
                        color: const Color(0xFFF6F8F8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onHorizontalDragEnd: (details) => _handleYearSwipe(years, activeYear, details),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () => _shiftYear(years, activeYear, 1),
                                    icon: Icon(Icons.chevron_left, color: canPrev ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0)),
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(999),
                                    onTap: () => _pickYear(years, activeYear),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      child: Column(
                                        children: [
                                          const Text('人生编年史', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF8B5CF6))),
                                          Text(
                                            '$activeYear',
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF8B5CF6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _shiftYear(years, activeYear, -1),
                                    icon: Icon(Icons.chevron_right, color: canNext ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _YearOverviewCard(
                                    value: '$inProgress',
                                    label: '进行中',
                                    valueColor: const Color(0xFF8B5CF6),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _YearOverviewCard(
                                    value: '$completed',
                                    label: '已完成',
                                    valueColor: const Color(0xFFD946EF),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _YearOverviewCard(
                                    value: '${(completionRate * 100).round()}%',
                                    label: '总达成率',
                                    valueColor: const Color(0xFF8B5CF6),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFF6366F1)]),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                const Text('AI 年度洞察', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFF3F4F6)),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '基于本年度数据分析，你在职业发展领域表现尤为优异，提前完成了关键认证。建议下半年在保持职业冲劲的同时，加强健康投入。',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569), height: 1.6),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Text('Life Museum AI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xFF8B5CF6),
                                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                        ),
                                        child: const Text('查看完整分析'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (yearGoals.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
                                child: const Text('暂无年度目标', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
                              )
                            else
                              for (final label in orderedLabels) ...[
                                _GoalCategorySection(label: label, goals: grouped[label] ?? const [], db: db),
                                const SizedBox(height: 18),
                              ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E8FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.edit_note, size: 16, color: Color(0xFFD946EF)),
                                ),
                                const SizedBox(width: 8),
                                const Text('个人复盘', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                const Spacer(),
                                const Text('记录你的心得', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFF3F4F6)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: _reviewController,
                                    minLines: 4,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      hintText: '在这里写下你的年度经验教训、高光时刻或是遗憾...',
                                      border: InputBorder.none,
                                    ),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569), height: 1.6),
                                  ),
                                  const SizedBox(height: 10),
                                  if (_reviewImages.isNotEmpty)
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _reviewImages.length + 1,
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                      ),
                                      itemBuilder: (context, index) {
                                        if (index == _reviewImages.length) {
                                          return InkWell(
                                            onTap: _pickReviewImages,
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFC),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                              ),
                                              child: const Icon(Icons.add, color: Color(0xFF94A3B8)),
                                            ),
                                          );
                                        }
                                        final imageUrl = _reviewImages[index];
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(child: _buildLocalImage(imageUrl, fit: BoxFit.cover)),
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: InkWell(
                                                  onTap: () => setState(() => _reviewImages.removeAt(index)),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withValues(alpha: 0.5),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(Icons.close, size: 12, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  else
                                    InkWell(
                                      onTap: _pickReviewImages,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.image, size: 16, color: Color(0xFF94A3B8)),
                                            SizedBox(width: 8),
                                            Text('添加图片', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存年度复盘')));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF8B5CF6),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                                      ),
                                      child: const Text('保存记录'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalDetailPage extends StatelessWidget {
  const GoalDetailPage({super.key, required this.record});

  final GoalRecord record;

  @override
  Widget build(BuildContext context) {
    return _GoalBreakdownDetailPage(record: record);
  }
}

class _GoalBreakdownDetailPage extends ConsumerStatefulWidget {
  const _GoalBreakdownDetailPage({required this.record});

  final GoalRecord record;

  @override
  ConsumerState<_GoalBreakdownDetailPage> createState() => _GoalBreakdownDetailPageState();
}

class _GoalBreakdownDetailPageState extends ConsumerState<_GoalBreakdownDetailPage> {
  DateTime _addMonths(DateTime base, int months) {
    final totalMonths = base.month - 1 + months;
    final year = base.year + totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = base.day > lastDay ? lastDay : base.day;
    return DateTime(year, month, day);
  }

  Future<void> _showPostponePlan(GoalRecord record) async {
    final now = DateTime.now();
    final baseDate = record.dueDate ?? DateTime(now.year, now.month, now.day);
    final selection = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetShell(
          title: '顺延计划',
          actionText: '关闭',
          onAction: () => Navigator.of(context).pop(),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            children: [
              ListTile(
                title: const Text('顺延一个月', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('新的目标日期：${_formatDotDate(_addMonths(baseDate, 1))}'),
                onTap: () => Navigator.of(context).pop('month'),
              ),
              ListTile(
                title: const Text('顺延一个季度', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('新的目标日期：${_formatDotDate(_addMonths(baseDate, 3))}'),
                onTap: () => Navigator.of(context).pop('quarter'),
              ),
              ListTile(
                title: const Text('顺延一年', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('新的目标日期：${_formatDotDate(_addMonths(baseDate, 12))}'),
                onTap: () => Navigator.of(context).pop('year'),
              ),
              ListTile(
                title: const Text('自定义日期', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: const Text('选择新的目标截止日'),
                onTap: () => Navigator.of(context).pop('custom'),
              ),
            ],
          ),
        );
      },
    );
    if (selection == null) return;
    if (!mounted) return;

    DateTime? newDate;
    if (selection == 'custom') {
      newDate = await showDatePicker(
        context: context,
        initialDate: baseDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (!mounted) return;
      if (newDate == null) return;
    } else if (selection == 'month') {
      newDate = _addMonths(baseDate, 1);
    } else if (selection == 'quarter') {
      newDate = _addMonths(baseDate, 3);
    } else if (selection == 'year') {
      newDate = _addMonths(baseDate, 12);
    }
    if (newDate == null) return;

    final db = ref.read(appDatabaseProvider);
    final targetQuarter = ((newDate.month - 1) ~/ 3) + 1;
    await (db.update(db.goalRecords)..where((t) => t.id.equals(record.id))).write(
      GoalRecordsCompanion(
        dueDate: Value(newDate),
        targetYear: Value(newDate.year),
        targetQuarter: Value(targetQuarter),
        targetMonth: Value(newDate.month),
        isPostponed: const Value(true),
        updatedAt: Value(now),
      ),
    );
    await (db.update(db.timelineEvents)..where((t) => t.id.equals(record.id))).write(
      TimelineEventsCompanion(
        startAt: Value(newDate),
        updatedAt: Value(now),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('顺延计划已更新')));
  }

  Future<void> _showStageReview(GoalRecord record) async {
    final summaryController = TextEditingController(text: record.summary ?? '');
    final noteController = TextEditingController(text: record.note ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('阶段复盘'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: summaryController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '总结',
                  border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '复盘',
                  border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('取消')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('保存')),
          ],
        );
      },
    );
    if (confirmed != true) return;

    final summary = summaryController.text.trim();
    final note = noteController.text.trim();
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    await (db.update(db.goalRecords)..where((t) => t.id.equals(record.id))).write(
      GoalRecordsCompanion(
        summary: Value(summary.isEmpty ? null : summary),
        note: Value(note.isEmpty ? null : note),
        updatedAt: Value(now),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('阶段复盘已保存')));
  }

  Stream<List<GoalRecord>> _watchChildren(AppDatabase db, String parentId, String level) {
    final query = db.select(db.goalRecords)
      ..where((t) => t.parentId.equals(parentId))
      ..where((t) => t.level.equals(level))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.targetQuarter, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.asc),
      ]);
    return query.watch();
  }

  Stream<List<GoalRecord>> _watchDailyTasks(AppDatabase db, List<String> parentIds) {
    if (parentIds.isEmpty) return Stream.value(const <GoalRecord>[]);
    final query = db.select(db.goalRecords)
      ..where((t) => t.parentId.isIn(parentIds))
      ..where((t) => t.level.equals('daily'))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
      ]);
    return query.watch();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final goalStream = (db.select(db.goalRecords)..where((t) => t.id.equals(widget.record.id))).watchSingle();
    return StreamBuilder<GoalRecord>(
      stream: goalStream,
      builder: (context, snapshot) {
        final record = snapshot.data ?? widget.record;
        final now = DateTime.now();
        final dueDate = record.dueDate;
        final leftText = dueDate == null
            ? '未设置'
            : (dueDate.difference(DateTime(now.year, now.month, now.day)).inDays >= 0
                ? '剩 ${dueDate.difference(DateTime(now.year, now.month, now.day)).inDays} 天'
                : '已超期 ${-dueDate.difference(DateTime(now.year, now.month, now.day)).inDays} 天');
        final progressPercent = (record.progress * 100).round().clamp(0, 100);

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
                          _CircleIconButton(
                            icon: Icons.edit_note,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => GoalBreakdownMaintenancePage(goal: record)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 140),
                        children: [
                          const SizedBox(height: 2),
                          _HeroProgressRing(progress: record.progress, percentText: '$progressPercent%'),
                          const SizedBox(height: 16),
                          Text(
                            record.title,
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
                                  Text(
                                    dueDate == null ? '截止: 未设置' : '截止: ${_formatDotDate(dueDate)}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF6B7280)),
                                  ),
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
                          StreamBuilder<List<GoalRecord>>(
                            stream: _watchChildren(db, record.id, 'quarter'),
                            builder: (context, quarterSnapshot) {
                              final quarters = quarterSnapshot.data ?? const <GoalRecord>[];
                              return StreamBuilder<List<GoalRecord>>(
                                stream: _watchDailyTasks(db, quarters.map((q) => q.id).toList()),
                                builder: (context, taskSnapshot) {
                                  final tasks = taskSnapshot.data ?? const <GoalRecord>[];
                                  if (quarters.isEmpty) {
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF3F4F6))),
                                      child: const Text('暂无阶段目标，点击右上角维护开始拆解', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                                    );
                                  }
                                  return Column(
                                    children: [
                                      for (var index = 0; index < quarters.length; index++) ...[
                                        Builder(
                                          builder: (context) {
                                            final quarter = quarters[index];
                                            final quarterTasks = tasks.where((t) => t.parentId == quarter.id).toList();
                                            final doneCount = quarterTasks.where((t) => t.isCompleted).length;
                                            final totalCount = quarterTasks.length;
                                            final computedProgress = totalCount == 0 ? quarter.progress : doneCount / totalCount;
                                            final state = (quarter.isCompleted || (computedProgress >= 1 && totalCount > 0))
                                                ? _QuarterState.done
                                                : (computedProgress > 0 || totalCount > 0)
                                                    ? _QuarterState.active
                                                    : _QuarterState.locked;
                                            final quarterLabel = quarter.targetQuarter != null ? 'Q${quarter.targetQuarter}' : 'Q${index + 1}';
                                            return _QuarterNode(
                                              quarter: quarterLabel,
                                              title: quarter.title,
                                              progress: computedProgress,
                                              state: state,
                                              children: const [],
                                              lockedHint: null,
                                              hideConnector: false,
                                              child: _MonthCard(
                                                title: quarter.summary?.isNotEmpty == true ? quarter.summary! : quarter.title,
                                                tasks: [
                                                  for (final task in quarterTasks)
                                                    _DayTaskTile(
                                                      checked: task.isCompleted,
                                                      enabled: true,
                                                      style: _taskStyleFor(task),
                                                      title: task.title,
                                                      subtitle: _taskSubtitleFor(task),
                                                      onChanged: (v) => _updateTaskCompletionForGoal(db, task, v, record.id),
                                                    ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        if (index != quarters.length - 1) const SizedBox(height: 18),
                                      ],
                                    ],
                                  );
                                },
                              );
                            },
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
                      onPressed: () => _showPostponePlan(record),
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
                      onPressed: () => _showStageReview(record),
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
      },
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

class GoalBreakdownMaintenancePage extends ConsumerStatefulWidget {
  const GoalBreakdownMaintenancePage({super.key, required this.goal});

  final GoalRecord goal;

  @override
  ConsumerState<GoalBreakdownMaintenancePage> createState() => _GoalBreakdownMaintenancePageState();
}

class _GoalBreakdownMaintenancePageState extends ConsumerState<GoalBreakdownMaintenancePage> {
  late final TextEditingController _summaryController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _summaryController = TextEditingController(text: widget.goal.summary ?? '');
    _noteController = TextEditingController(text: widget.goal.note ?? '');
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Stream<List<GoalRecord>> _watchStages(AppDatabase db) {
    final query = db.select(db.goalRecords)
      ..where((t) => t.parentId.equals(widget.goal.id))
      ..where((t) => t.level.equals('quarter'))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.targetQuarter, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.asc),
      ]);
    return query.watch();
  }

  Stream<List<GoalRecord>> _watchTasks(AppDatabase db, List<String> parentIds) {
    if (parentIds.isEmpty) return Stream.value(const <GoalRecord>[]);
    final query = db.select(db.goalRecords)
      ..where((t) => t.parentId.isIn(parentIds))
      ..where((t) => t.level.equals('daily'))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
      ]);
    return query.watch();
  }

  Future<void> _saveSummary() async {
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    await (db.update(db.goalRecords)..where((t) => t.id.equals(widget.goal.id))).write(
      GoalRecordsCompanion(
        summary: Value(_summaryController.text.trim()),
        note: Value(_noteController.text.trim()),
        updatedAt: Value(now),
      ),
    );
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  Future<void> _showStageEditor({GoalRecord? stage}) async {
    final titleController = TextEditingController(text: stage?.title ?? '');
    int targetQuarter = stage?.targetQuarter ?? 1;
    final result = await showDialog<_StageEditResult>(
      context: context,
      builder: (context) {
        return _StageEditDialog(
          titleController: titleController,
          initialQuarter: targetQuarter,
        );
      },
    );
    if (result == null) return;
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    if (stage == null) {
      const uuid = Uuid();
      await db.into(db.goalRecords).insert(
            GoalRecordsCompanion.insert(
              id: uuid.v4(),
              parentId: Value(widget.goal.id),
              level: 'quarter',
              title: result.title,
              recordDate: DateTime(now.year, now.month, now.day),
              createdAt: now,
              updatedAt: now,
              targetQuarter: Value(result.quarter),
            ),
          );
      return;
    }
    await (db.update(db.goalRecords)..where((t) => t.id.equals(stage.id))).write(
      GoalRecordsCompanion(
        title: Value(result.title),
        targetQuarter: Value(result.quarter),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> _deleteStage(GoalRecord stage) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除阶段'),
        content: const Text('确认删除该阶段及其任务吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('删除')),
        ],
      ),
    );
    if (confirmed != true) return;
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    await (db.update(db.goalRecords)..where((t) => t.id.equals(stage.id))).write(
      GoalRecordsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    await (db.update(db.goalRecords)..where((t) => t.parentId.equals(stage.id))).write(
      GoalRecordsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> _addTask(GoalRecord stage) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _TaskEditDialog(controller: controller),
    );
    if (result == null || result.trim().isEmpty) return;
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    const uuid = Uuid();
    await db.into(db.goalRecords).insert(
          GoalRecordsCompanion.insert(
            id: uuid.v4(),
            parentId: Value(stage.id),
            level: 'daily',
            title: result.trim(),
            recordDate: DateTime(now.year, now.month, now.day),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> _deleteTask(GoalRecord task) async {
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    await (db.update(db.goalRecords)..where((t) => t.id.equals(task.id))).write(
      GoalRecordsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('取消', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('目标拆解维护', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  TextButton(
                    onPressed: _saveSummary,
                    child: const Text('保存', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('目标摘要', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        const SizedBox(height: 12),
                        const Text('总结', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _summaryController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: '记录阶段成果，给未来的自己鼓励',
                            border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text('复盘', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _noteController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: '记录下遇到的问题与改进点',
                            border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Text('阶段信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
                      TextButton(
                        onPressed: _showStageEditor,
                        style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                        child: const Text('添加新的阶段'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<GoalRecord>>(
                    stream: _watchStages(db),
                    builder: (context, stageSnapshot) {
                      final stages = stageSnapshot.data ?? const <GoalRecord>[];
                      return StreamBuilder<List<GoalRecord>>(
                        stream: _watchTasks(db, stages.map((s) => s.id).toList()),
                        builder: (context, taskSnapshot) {
                          final tasks = taskSnapshot.data ?? const <GoalRecord>[];
                          if (stages.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF3F4F6))),
                              child: const Text('暂无阶段，点击右上角添加', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                            );
                          }
                          return Column(
                            children: [
                              for (final stage in stages) ...[
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '阶段 ${stage.targetQuarter != null ? 'Q${stage.targetQuarter}' : ''} · ${stage.title}',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 18, color: Color(0xFF94A3B8)),
                                            onPressed: () => _showStageEditor(stage: stage),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF94A3B8)),
                                            onPressed: () => _deleteStage(stage),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Column(
                                        children: [
                                          for (final task in tasks.where((t) => t.parentId == stage.id)) ...[
                                            _MaintainTaskTile(
                                              title: task.title,
                                              checked: task.isCompleted,
                                              onChanged: (v) => _updateTaskCompletionForGoal(db, task, v, widget.goal.id),
                                              onRemove: () => _deleteTask(task),
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                        ],
                                      ),
                                      TextButton.icon(
                                        onPressed: () => _addTask(stage),
                                        icon: const Icon(Icons.add_circle_outline, size: 18),
                                        label: const Text('添加具体任务'),
                                        style: TextButton.styleFrom(foregroundColor: AppTheme.primary, textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, size: 18, color: Color(0xFF94A3B8)),
                        SizedBox(width: 8),
                        Expanded(child: Text('长按拖动排序（当前版本暂未开放）', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)))),
                      ],
                    ),
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

class _MaintainTaskTile extends StatelessWidget {
  const _MaintainTaskTile({
    required this.title,
    required this.checked,
    required this.onChanged,
    required this.onRemove,
  });

  final String title;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: checked,
          onChanged: (v) => onChanged(v ?? false),
          activeColor: AppTheme.primary,
        ),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: checked ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
              decoration: checked ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 16, color: Color(0xFF94A3B8)),
          onPressed: onRemove,
        ),
      ],
    );
  }
}

class _StageEditDialog extends StatefulWidget {
  const _StageEditDialog({required this.titleController, required this.initialQuarter});

  final TextEditingController titleController;
  final int initialQuarter;

  @override
  State<_StageEditDialog> createState() => _StageEditDialogState();
}

class _StageEditDialogState extends State<_StageEditDialog> {
  late int _quarter;

  @override
  void initState() {
    super.initState();
    _quarter = widget.initialQuarter;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('阶段设置'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            value: _quarter,
            decoration: const InputDecoration(labelText: '季度'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Q1')),
              DropdownMenuItem(value: 2, child: Text('Q2')),
              DropdownMenuItem(value: 3, child: Text('Q3')),
              DropdownMenuItem(value: 4, child: Text('Q4')),
            ],
            onChanged: (value) => setState(() => _quarter = value ?? 1),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.titleController,
            decoration: const InputDecoration(labelText: '阶段目标'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
        TextButton(
          onPressed: () {
            final title = widget.titleController.text.trim();
            if (title.isEmpty) return;
            Navigator.of(context).pop(_StageEditResult(title: title, quarter: _quarter));
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class _TaskEditDialog extends StatelessWidget {
  const _TaskEditDialog({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新增任务'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: '输入任务内容'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
        TextButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('添加')),
      ],
    );
  }
}

class _StageEditResult {
  const _StageEditResult({required this.title, required this.quarter});

  final String title;
  final int quarter;
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String _formatDotDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}.$month.$day';
}

Widget _buildLocalImage(String path, {BoxFit fit = BoxFit.cover}) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) {
    return const SizedBox.shrink();
  }
  final isNetwork = trimmed.startsWith('http://') || trimmed.startsWith('https://');
  if (isNetwork || kIsWeb) {
    return Image.network(trimmed, fit: fit, gaplessPlayback: true);
  }
  return Image.file(File(trimmed), fit: fit, gaplessPlayback: true);
}

_DayTaskStyle _taskStyleFor(GoalRecord task) {
  if (task.isCompleted) return _DayTaskStyle.done;
  final today = _dateOnly(DateTime.now());
  final taskDate = _dateOnly(task.recordDate);
  if (taskDate == today) return _DayTaskStyle.today;
  return _DayTaskStyle.future;
}

String? _taskSubtitleFor(GoalRecord task) {
  final today = _dateOnly(DateTime.now());
  final taskDate = _dateOnly(task.recordDate);
  if (taskDate == today) return '今日任务';
  return null;
}

Future<void> _updateTaskCompletionForGoal(AppDatabase db, GoalRecord task, bool checked, String goalId) async {
  final now = DateTime.now();
  await (db.update(db.goalRecords)..where((t) => t.id.equals(task.id))).write(
    GoalRecordsCompanion(
      isCompleted: Value(checked),
      updatedAt: Value(now),
    ),
  );

  final quarterId = task.parentId;
  if (quarterId != null) {
    final quarterTasks = await (db.select(db.goalRecords)
          ..where((t) => t.parentId.equals(quarterId))
          ..where((t) => t.level.equals('daily'))
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    final quarterProgress = quarterTasks.isEmpty ? 0.0 : quarterTasks.where((t) => t.isCompleted).length / quarterTasks.length;
    await (db.update(db.goalRecords)..where((t) => t.id.equals(quarterId))).write(
      GoalRecordsCompanion(
        progress: Value(quarterProgress),
        isCompleted: Value(quarterProgress >= 1 && quarterTasks.isNotEmpty),
        updatedAt: Value(now),
      ),
    );
  }

  final quarters = await (db.select(db.goalRecords)
        ..where((t) => t.parentId.equals(goalId))
        ..where((t) => t.level.equals('quarter'))
        ..where((t) => t.isDeleted.equals(false)))
      .get();
  final quarterIds = quarters.map((q) => q.id).toList();
  if (quarterIds.isEmpty) {
    await (db.update(db.goalRecords)..where((t) => t.id.equals(goalId))).write(
      GoalRecordsCompanion(
        progress: const Value(0),
        isCompleted: const Value(false),
        updatedAt: Value(now),
      ),
    );
    return;
  }
  final tasks = await (db.select(db.goalRecords)
        ..where((t) => t.parentId.isIn(quarterIds))
        ..where((t) => t.level.equals('daily'))
        ..where((t) => t.isDeleted.equals(false)))
      .get();
  final goalProgress = tasks.isEmpty ? 0.0 : tasks.where((t) => t.isCompleted).length / tasks.length;
  await (db.update(db.goalRecords)..where((t) => t.id.equals(goalId))).write(
    GoalRecordsCompanion(
      progress: Value(goalProgress),
      isCompleted: Value(goalProgress >= 1 && tasks.isNotEmpty),
      updatedAt: Value(now),
    ),
  );
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
                value: progress.clamp(0, 1).toDouble(),
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
                value: progress.clamp(0, 1).toDouble(),
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

class GoalCreatePage extends ConsumerStatefulWidget {
  const GoalCreatePage({super.key});

  @override
  ConsumerState<GoalCreatePage> createState() => _GoalCreatePageState();
}

class _GoalCreatePageState extends ConsumerState<GoalCreatePage> {
  final Set<String> _linkedMomentIds = {};
  final Set<String> _linkedFoodIds = {};
  final Set<String> _linkedFriendIds = {};
  final Set<String> _linkedTravelIds = {};
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedGoalType = _goalTypeOptions.first.value;
  DateTime? _dueDate;
  String _remindFrequency = _remindOptions.first.value;

  Future<void> _selectLinkedMoments() async {
    final db = ref.read(appDatabaseProvider);
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StreamBuilder<List<MomentRecord>>(
          stream: db.momentDao.watchAllActive(),
          builder: (context, snapshot) {
            final moments = snapshot.data ?? const <MomentRecord>[];
            return _MultiSelectBottomSheet(
              title: '关联小确幸',
              items: moments
                  .map(
                    (m) => _SelectItem(
                      id: m.id,
                      title: m.content?.isNotEmpty == true ? m.content! : '小确幸记录',
                      leading: const _IconSquare(color: Color(0xFFEFF6FF), icon: Icons.auto_awesome, iconColor: Color(0xFF60A5FA)),
                    ),
                  )
                  .toList(growable: false),
              initialSelected: _linkedMomentIds,
            );
          },
        );
      },
    );
    if (selected == null) return;
    setState(() {
      _linkedMomentIds
        ..clear()
        ..addAll(selected);
    });
  }

  Future<void> _selectLinkedFoods() async {
    final db = ref.read(appDatabaseProvider);
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StreamBuilder<List<FoodRecord>>(
          stream: db.foodDao.watchAllActive(),
          builder: (context, snapshot) {
            final foods = snapshot.data ?? const <FoodRecord>[];
            return _MultiSelectBottomSheet(
              title: '关联美食',
              items: foods
                  .map(
                    (f) => _SelectItem(
                      id: f.id,
                      title: f.title,
                      leading: const _IconSquare(color: Color(0xFFFFEDD5), icon: Icons.restaurant, iconColor: Color(0xFFFB923C)),
                    ),
                  )
                  .toList(growable: false),
              initialSelected: _linkedFoodIds,
            );
          },
        );
      },
    );
    if (selected == null) return;
    setState(() {
      _linkedFoodIds
        ..clear()
        ..addAll(selected);
    });
  }

  Future<void> _selectLinkedFriends() async {
    final db = ref.read(appDatabaseProvider);
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StreamBuilder<List<FriendRecord>>(
          stream: db.friendDao.watchAllActive(),
          builder: (context, snapshot) {
            final friends = snapshot.data ?? const <FriendRecord>[];
            return _MultiSelectBottomSheet(
              title: '关联羁绊',
              items: friends
                  .map(
                    (f) => _SelectItem(
                      id: f.id,
                      title: f.name,
                      leading: _AvatarCircle(name: f.name),
                    ),
                  )
                  .toList(growable: false),
              initialSelected: _linkedFriendIds,
            );
          },
        );
      },
    );
    if (selected == null) return;
    setState(() {
      _linkedFriendIds
        ..clear()
        ..addAll(selected);
    });
  }

  Future<void> _selectLinkedTravels() async {
    final db = ref.read(appDatabaseProvider);
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StreamBuilder<List<TravelRecord>>(
          stream: db.watchAllActiveTravelRecords(),
          builder: (context, snapshot) {
            final travels = snapshot.data ?? const <TravelRecord>[];
            return _MultiSelectBottomSheet(
              title: '关联旅行',
              items: travels
                  .map(
                    (t) => _SelectItem(
                      id: t.id,
                      title: t.title?.isNotEmpty == true ? t.title! : '旅行记录',
                      leading: const _IconSquare(color: Color(0xFFF0FDF4), icon: Icons.flight_takeoff, iconColor: Color(0xFF22C55E)),
                    ),
                  )
                  .toList(growable: false),
              initialSelected: _linkedTravelIds,
            );
          },
        );
      },
    );
    if (selected == null) return;
    setState(() {
      _linkedTravelIds
        ..clear()
        ..addAll(selected);
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先填写目标标题')));
      return;
    }

    final db = ref.read(appDatabaseProvider);
    const uuid = Uuid();
    final now = DateTime.now();
    final recordDate = DateTime(now.year, now.month, now.day);
    final goalId = uuid.v4();

    final description = _descriptionController.text.trim();
    final noteParts = <String>[];
    if (_selectedGoalType.isNotEmpty) noteParts.add('分类：${_goalLabelFor(_selectedGoalType)}');
    if (_dueDate != null) noteParts.add('截止：${_formatDotDate(_dueDate!)}');
    if (description.isNotEmpty) noteParts.add(description);
    final note = noteParts.isEmpty ? null : noteParts.join('\n');

    await db.into(db.goalRecords).insert(
          GoalRecordsCompanion.insert(
            id: goalId,
            parentId: const Value(null),
            level: 'year',
            title: title,
            note: Value(description.isEmpty ? null : description),
            category: Value(_selectedGoalType),
            progress: const Value(0.0),
            isCompleted: const Value(false),
            isPostponed: const Value(false),
            remindFrequency: Value(_remindFrequency),
            targetYear: Value((_dueDate ?? recordDate).year),
            dueDate: Value(_dueDate),
            recordDate: recordDate,
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.timelineEvents).insertOnConflictUpdate(
          TimelineEventsCompanion.insert(
            id: goalId,
            title: title,
            eventType: 'goal',
            startAt: Value(_dueDate ?? recordDate),
            endAt: const Value(null),
            note: Value(note),
            recordDate: recordDate,
            createdAt: now,
            updatedAt: now,
          ),
        );

    for (final id in _linkedMomentIds) {
      await db.linkDao.createLink(
        sourceType: 'goal',
        sourceId: goalId,
        targetType: 'moment',
        targetId: id,
        now: now,
      );
    }
    for (final id in _linkedFoodIds) {
      await db.linkDao.createLink(
        sourceType: 'goal',
        sourceId: goalId,
        targetType: 'food',
        targetId: id,
        now: now,
      );
    }
    for (final id in _linkedFriendIds) {
      await db.linkDao.createLink(
        sourceType: 'goal',
        sourceId: goalId,
        targetType: 'friend',
        targetId: id,
        now: now,
      );
    }
    for (final id in _linkedTravelIds) {
      await db.linkDao.createLink(
        sourceType: 'goal',
        sourceId: goalId,
        targetType: 'travel',
        targetId: id,
        now: now,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final initialDate = _dueDate ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null) return;
    setState(() {
      _dueDate = selected;
    });
  }

  Future<void> _pickRemindFrequency() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetShell(
          title: '目标提醒',
          actionText: '完成',
          onAction: () => Navigator.of(context).pop(_remindFrequency),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            children: [
              for (final option in _remindOptions)
                ListTile(
                  title: Text(option.label, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(option.detail),
                  trailing: option.value == _remindFrequency ? const Icon(Icons.check, color: AppTheme.primary) : null,
                  onTap: () => Navigator.of(context).pop(option.value),
                ),
            ],
          ),
        );
      },
    );
    if (selected == null) return;
    setState(() => _remindFrequency = selected);
  }

  @override
  Widget build(BuildContext context) {
    final remindOption = _remindOptionFor(_remindFrequency);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('取消', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('新建目标', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  TextButton(
                    onPressed: _save,
                    child: const Text('创建', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('目标标题', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        const SizedBox(height: 10),
                        TextField(controller: _titleController, decoration: const InputDecoration(hintText: '输入目标', border: InputBorder.none)),
                        const SizedBox(height: 14),
                        const Text('目标类别', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (final option in _goalTypeOptions) ...[
                              Expanded(
                                child: _GoalTypeCard(
                                  option: option,
                                  selected: _selectedGoalType == option.value,
                                  onTap: () => setState(() => _selectedGoalType = option.value),
                                ),
                              ),
                              if (option != _goalTypeOptions.last) const SizedBox(width: 10),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text('目标提醒', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        const SizedBox(height: 10),
                        _GoalMetaTile(
                          icon: Icons.notifications_active,
                          title: remindOption.label,
                          subtitle: remindOption.detail,
                          onTap: _pickRemindFrequency,
                        ),
                        const SizedBox(height: 14),
                        const Text('完成日期', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        const SizedBox(height: 10),
                        _GoalMetaTile(
                          icon: Icons.event,
                          title: _dueDate == null ? '设定完成期限' : _formatDotDate(_dueDate!),
                          subtitle: _dueDate == null ? '点击选择日期' : '目标截止时间',
                          onTap: _pickDueDate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('目标描述', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _descriptionController,
                          minLines: 4,
                          maxLines: 8,
                          decoration: const InputDecoration(hintText: '写下对目标的期望与计划', border: InputBorder.none),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            SizedBox(width: 4),
                            SizedBox(width: 4, height: 16, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFF2BCDEE), borderRadius: BorderRadius.all(Radius.circular(999))))),
                            SizedBox(width: 10),
                            Text('目标链接', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _GoalLinkTile(
                          iconBackground: Color(0xFFEFF6FF),
                          icon: Icons.auto_awesome,
                          iconColor: Color(0xFF60A5FA),
                          title: '关联小确幸',
                          trailingText: _linkedMomentIds.isEmpty ? '选择小确幸' : '已选 ${_linkedMomentIds.length} 条',
                          onTap: _selectLinkedMoments,
                        ),
                        _GoalLinkTile(
                          iconBackground: Color(0xFFFFEDD5),
                          icon: Icons.restaurant,
                          iconColor: Color(0xFFFB923C),
                          title: '关联美食',
                          trailingText: _linkedFoodIds.isEmpty ? '选择美食记录' : '已选 ${_linkedFoodIds.length} 条',
                          onTap: _selectLinkedFoods,
                        ),
                        _GoalLinkTile(
                          iconBackground: Color(0xFFFCE7F3),
                          icon: Icons.people,
                          iconColor: Color(0xFFEC4899),
                          title: '关联羁绊',
                          trailingText: _linkedFriendIds.isEmpty ? '选择朋友/相遇' : '已选 ${_linkedFriendIds.length} 位',
                          onTap: _selectLinkedFriends,
                        ),
                        _GoalLinkTile(
                          iconBackground: Color(0xFFF0FDF4),
                          icon: Icons.flight_takeoff,
                          iconColor: Color(0xFF22C55E),
                          title: '关联旅行',
                          trailingText: _linkedTravelIds.isEmpty ? '选择旅行记录' : '已选 ${_linkedTravelIds.length} 条',
                          onTap: _selectLinkedTravels,
                        ),
                      ],
                    ),
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

class _GoalTypeCard extends StatelessWidget {
  const _GoalTypeCard({required this.option, required this.selected, required this.onTap});

  final _GoalTypeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? option.background : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? option.accent : const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Icon(option.icon, color: option.accent, size: 20),
              const SizedBox(height: 8),
              Text(option.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: option.accent)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalMetaTile extends StatelessWidget {
  const _GoalMetaTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFFD1D5DB)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalLinkTile extends StatelessWidget {
  const _GoalLinkTile({
    required this.iconBackground,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailingText,
    this.onTap,
  });

  final Color iconBackground;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String trailingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
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
        ),
      ),
    );
  }
}

class _BottomSheetShell extends StatelessWidget {
  const _BottomSheetShell({
    required this.title,
    required this.actionText,
    required this.onAction,
    required this.child,
  });

  final String title;
  final String actionText;
  final VoidCallback onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: Material(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280), textStyle: const TextStyle(fontWeight: FontWeight.w800)),
                      child: const Text('取消'),
                    ),
                    Expanded(
                      child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    ),
                    TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF2BCDEE), textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                      child: Text(actionText),
                    ),
                  ],
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectItem {
  const _SelectItem({required this.id, required this.title, required this.leading});

  final String id;
  final String title;
  final Widget leading;
}

class _MultiSelectBottomSheet extends StatefulWidget {
  const _MultiSelectBottomSheet({
    required this.title,
    required this.items,
    required this.initialSelected,
  });

  final String title;
  final List<_SelectItem> items;
  final Set<String> initialSelected;

  @override
  State<_MultiSelectBottomSheet> createState() => _MultiSelectBottomSheetState();
}

class _MultiSelectBottomSheetState extends State<_MultiSelectBottomSheet> {
  late final Set<String> _selected = {...widget.initialSelected};

  @override
  Widget build(BuildContext context) {
    return _BottomSheetShell(
      title: widget.title,
      actionText: '确定',
      onAction: () => Navigator.of(context).pop(_selected),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final checked = _selected.contains(item.id);
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  if (checked) {
                    _selected.remove(item.id);
                  } else {
                    _selected.add(item.id);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: checked ? const Color(0xFF2BCDEE).withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: checked ? const Color(0xFF2BCDEE).withValues(alpha: 0.22) : const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    item.leading,
                    const SizedBox(width: 10),
                    Expanded(child: Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827)))),
                    Icon(checked ? Icons.check_circle : Icons.radio_button_unchecked, color: checked ? const Color(0xFF2BCDEE) : const Color(0xFFCBD5E1)),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: widget.items.length,
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter = trimmed.isEmpty ? '?' : trimmed.substring(0, 1);
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(letter, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF334155))),
    );
  }
}

class _IconSquare extends StatelessWidget {
  const _IconSquare({required this.color, required this.icon, required this.iconColor});

  final Color color;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }
}
