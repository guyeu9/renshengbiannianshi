import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:confetti/confetti.dart';
import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibration/vibration.dart';

import '../../../app/app_theme.dart';
import '../../../core/config/module_management_config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/providers/uuid_provider.dart';
import '../../../core/utils/media_storage.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../core/utils/tag_color_utils.dart';
import '../../../core/widgets/ai_parse_button.dart';
import '../../../core/widgets/app_image.dart';
import '../providers/goal_detail_provider.dart';
import '../../food/presentation/food_page.dart';
import '../../travel/presentation/travel_page.dart';
import '../../moment/presentation/moment_page.dart';
import '../../bond/presentation/bond_page.dart';

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

const _defaultGoalTypeOptions = <_GoalTypeOption>[
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
    icon: Icons.airplanemode_active,
    accent: Color(0xFF10B981),
    background: Color(0xFFDCFCE7),
  ),
];

List<_GoalTypeOption> _buildGoalTypeOptionsFromConfig(List<ModuleTag> configTags) {
  if (configTags.isEmpty) return _defaultGoalTypeOptions;
  return configTags.map((tag) {
    final accent = TagColorUtils.colorFromHex(tag.color);
    return _GoalTypeOption(
      value: tag.name,
      label: tag.name,
      icon: IconUtils.fromName(tag.iconName),
      accent: accent,
      background: accent.withAlpha(38),
    );
  }).toList();
}

_GoalTypeOption? _goalTypeFor(String? value, [List<_GoalTypeOption>? options]) {
  if (value == null) return null;
  final opts = options ?? _defaultGoalTypeOptions;
  for (final option in opts) {
    if (option.value == value || option.label == value) return option;
  }
  return _GoalTypeOption(
    value: value,
    label: value,
    icon: Icons.flag,
    accent: AppTheme.primary,
    background: const Color(0xFFEFF6FF),
  );
}

Color _goalAccentFor(String? value, [List<_GoalTypeOption>? options]) {
  return _goalTypeFor(value, options)?.accent ?? AppTheme.primary;
}

String _goalLabelFor(String? value, [List<_GoalTypeOption>? options]) {
  final type = _goalTypeFor(value, options);
  return type?.label ?? (value?.isNotEmpty == true ? value! : '未分类');
}

_GoalTypeOption _goalMetaForLabel(String label, [List<_GoalTypeOption>? options]) {
  final opts = options ?? _defaultGoalTypeOptions;
  for (final option in opts) {
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

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  final _searchController = TextEditingController();
  var _searchQuery = '';
  var _filterStatusIndex = 0; // 0: 全部, 1: 进行中, 2: 已完成, 3: 已放弃
  var _filterTypeIndex = 0; // 0: 全部, 1: 职业, 2: 健康, 3: 旅行
  var _filterFavorite = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_GoalFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _GoalFilterBottomSheet(
          initialStatusIndex: _filterStatusIndex,
          initialTypeIndex: _filterTypeIndex,
          initialFilterFavorite: _filterFavorite,
        );
      },
    );
    if (result == null) return;
    setState(() {
      _filterStatusIndex = result.statusIndex;
      _filterTypeIndex = result.typeIndex;
      _filterFavorite = result.filterFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _GoalHeader(
              searchController: _searchController,
              onSearchChanged: (v) => setState(() => _searchQuery = v),
              onFilterTap: _openFilterSheet,
              hasActiveFilter: _filterStatusIndex != 0 || _filterTypeIndex != 0 || _filterFavorite,
            ),
            Expanded(
              child: _GoalHomeBody(
                searchQuery: _searchQuery,
                filterStatusIndex: _filterStatusIndex,
                filterTypeIndex: _filterTypeIndex,
                filterFavorite: _filterFavorite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalHeader extends StatelessWidget {
  const _GoalHeader({
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterTap,
    this.hasActiveFilter = false,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final bool hasActiveFilter;

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
              AiParseButton(text: '解析', onPressed: () {}),
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
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          decoration: const InputDecoration(
                            hintText: '搜索目标、标签..',
                            hintStyle: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 15, color: Color(0xFF111827), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _CircleButton(icon: Icons.tune, onTap: onFilterTap, hasActiveFilter: hasActiveFilter),
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
  const _CircleButton({required this.icon, required this.onTap, this.iconColor, this.hasActiveFilter = false});

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool hasActiveFilter;

  @override
  Widget build(BuildContext context) {
    final bgColor = hasActiveFilter ? const Color(0xFF2BCDEE).withValues(alpha: 0.12) : Colors.white;
    final borderColor = hasActiveFilter ? const Color(0xFF2BCDEE).withValues(alpha: 0.35) : Colors.transparent;
    final fgColor = hasActiveFilter ? const Color(0xFF2BCDEE) : (iconColor ?? const Color(0xFF6B7280));
    
    return Material(
      color: bgColor,
      shape: CircleBorder(side: BorderSide(color: borderColor, width: 2)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(width: 48, height: 48, child: Icon(icon, color: fgColor, size: 22)),
      ),
    );
  }
}

class _GoalHomeBody extends ConsumerStatefulWidget {
  const _GoalHomeBody({
    required this.searchQuery,
    required this.filterStatusIndex,
    required this.filterTypeIndex,
    required this.filterFavorite,
  });

  final String searchQuery;
  final int filterStatusIndex;
  final int filterTypeIndex;
  final bool filterFavorite;

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

  bool _matchesSearch(GoalRecord record) {
    final query = widget.searchQuery.toLowerCase().trim();
    if (query.isEmpty) return true;
    final title = record.title.toLowerCase();
    final category = (record.category ?? '').toLowerCase();
    return title.contains(query) || category.contains(query);
  }

  bool _matchesStatusFilter(GoalRecord record) {
    switch (widget.filterStatusIndex) {
      case 0: // 全部
        return true;
      case 1: // 进行中
        return !record.isCompleted && !record.isPostponed;
      case 2: // 已完成
        return record.isCompleted;
      case 3: // 已顺延
        return record.isPostponed;
      default:
        return true;
    }
  }

  bool _matchesTypeFilter(GoalRecord record, List<String> configTags) {
    if (widget.filterTypeIndex == 0) return true;
    if (widget.filterTypeIndex <= configTags.length) {
      final selectedTag = configTags[widget.filterTypeIndex - 1];
      final category = record.category ?? '';
      return category == selectedTag;
    }
    return true;
  }

  bool _matchesFavoriteFilter(GoalRecord record) {
    if (!widget.filterFavorite) return true;
    return record.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final configAsync = ref.watch(moduleManagementConfigProvider);
    
    return configAsync.when(
      data: (config) {
        final goalTags = config.moduleOf('goal').tags;
        final goalTypeOptions = _buildGoalTypeOptionsFromConfig(goalTags);
        final configTags = goalTags.map((t) => t.name).toList();
        
        return StreamBuilder<List<GoalRecord>>(
          stream: _watchYearGoals(db),
          builder: (context, snapshot) {
            final records = snapshot.data ?? const <GoalRecord>[];

            var filteredRecords = records.where((r) {
              return _matchesSearch(r) && _matchesStatusFilter(r) && _matchesTypeFilter(r, configTags) && _matchesFavoriteFilter(r);
            }).toList();

            final years = records.map(_goalYear).toSet().toList()..sort((a, b) => b.compareTo(a));
            final activeYear = years.contains(_selectedYear) ? _selectedYear : (years.isNotEmpty ? years.first : _selectedYear);
            final yearGoals = filteredRecords.where((r) => _goalYear(r) == activeYear).toList(growable: false);
            final inProgress = yearGoals.where((r) => !r.isCompleted && !r.isPostponed).length;
            final completed = yearGoals.where((r) => r.isCompleted).length;
            final total = yearGoals.length;
            final completionRate = total == 0 ? 0 : (completed / total);
            final grouped = <String, List<GoalRecord>>{};
            for (final goal in yearGoals) {
              final label = _goalLabelFor(goal.category, goalTypeOptions);
              grouped.putIfAbsent(label, () => []).add(goal);
            }
            final orderedLabels = <String>[
              for (final option in goalTypeOptions)
                if (grouped.containsKey(option.label)) option.label,
              for (final label in grouped.keys)
                if (!goalTypeOptions.any((o) => o.label == label)) label,
            ];

            final yearIndex = years.indexOf(activeYear);
            final canPrev = yearIndex >= 0 && yearIndex < years.length - 1;
            final canNext = yearIndex > 0;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
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
                                  Text('$activeYear年', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2BCDEE))),
                                  const Icon(Icons.keyboard_arrow_down, size: 24, color: Color(0xFF2BCDEE)),
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
                    TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AnnualGoalSummaryPage(initialYear: activeYear, availableYears: years)),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('历史年度总结'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: _YearOverviewCard(
                      value: '$inProgress',
                      label: '进行中',
                      valueColor: const Color(0xFFA855F7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _YearOverviewCard(
                      value: '$completed',
                      label: '已完成',
                      valueColor: const Color(0xFFA855F7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _YearOverviewCard(
                      value: '${(completionRate * 100).round()}%',
                      label: '完成率',
                      valueColor: const Color(0xFFA855F7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                  goalTypeOptions: goalTypeOptions,
                ),
              ],
          ],
        );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('加载配置失败')),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: valueColor)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _GoalCategorySection extends StatelessWidget {
  const _GoalCategorySection({required this.label, required this.goals, required this.db, this.goalTypeOptions});

  final String label;
  final List<GoalRecord> goals;
  final AppDatabase db;
  final List<_GoalTypeOption>? goalTypeOptions;

  @override
  Widget build(BuildContext context) {
    final meta = _goalMetaForLabel(label, goalTypeOptions);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: meta.background, borderRadius: BorderRadius.circular(8)),
              child: Icon(meta.icon, size: 20, color: meta.accent),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            for (final goal in goals) ...[
              _AnnualGoalCard(record: goal, db: db, goalTypeOptions: goalTypeOptions),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ],
    );
  }
}

class _AnnualGoalCard extends StatefulWidget {
  const _AnnualGoalCard({required this.record, required this.db, this.goalTypeOptions});

  final GoalRecord record;
  final AppDatabase db;
  final List<_GoalTypeOption>? goalTypeOptions;

  @override
  State<_AnnualGoalCard> createState() => _AnnualGoalCardState();
}

class _AnnualGoalCardState extends State<_AnnualGoalCard> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0;

  Stream<List<GoalRecord>> _watchQuarters() {
    final query = widget.db.select(widget.db.goalRecords)
      ..where((t) => t.parentId.equals(widget.record.id))
      ..where((t) => t.level.equals('quarter'))
      ..where((t) => t.isDeleted.equals(false));
    return query.watch();
  }

  Stream<List<GoalRecord>> _watchDailyTasks(List<String> quarterIds) {
    if (quarterIds.isEmpty) {
      return Stream.value(const <GoalRecord>[]);
    }
    final query = widget.db.select(widget.db.goalRecords)
      ..where((t) => t.parentId.isIn(quarterIds))
      ..where((t) => t.level.equals('daily'))
      ..where((t) => t.isDeleted.equals(false));
    return query.watch();
  }

  @override
  void initState() {
    super.initState();
    _previousProgress = widget.record.progress.clamp(0, 1).toDouble();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: _previousProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.forward();
  }

  @override
  void didUpdateWidget(_AnnualGoalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newProgress = widget.record.progress.clamp(0, 1).toDouble();
    if (newProgress != _previousProgress) {
      _progressAnimation = Tween<double>(begin: _previousProgress, end: newProgress).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
      );
      _progressController.reset();
      _progressController.forward();
      _previousProgress = newProgress;
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _goalAccentFor(widget.record.category, widget.goalTypeOptions);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GoalDetailPage(record: widget.record))),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.record.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  if (widget.record.isFavorite)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE7F3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite, size: 14, color: Color(0xFFEC4899)),
                    ),
                  const SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Text(
                        '${(_progressAnimation.value * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA855F7),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _goalDeadlineLabel(widget.record),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: _progressAnimation.value,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              StreamBuilder<List<GoalRecord>>(
                stream: _watchQuarters(),
                builder: (context, quarterSnapshot) {
                  final quarters = quarterSnapshot.data ?? const <GoalRecord>[];
                  final quarterIds = quarters.map((q) => q.id).toList(growable: false);
                  return StreamBuilder<List<GoalRecord>>(
                    stream: _watchDailyTasks(quarterIds),
                    builder: (context, taskSnapshot) {
                      final tasks = taskSnapshot.data ?? const <GoalRecord>[];
                      if (tasks.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F8F8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 14,
                                  color: accent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${tasks.where((t) => t.isCompleted).length}/${tasks.length} 任务',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...tasks.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TaskItem(task: task, accent: accent),
                          )),
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

class _TaskItem extends StatefulWidget {
  const _TaskItem({required this.task, required this.accent});

  final GoalRecord task;
  final Color accent;

  @override
  State<_TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<_TaskItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _wasCompleted = false;

  @override
  void initState() {
    super.initState();
    _wasCompleted = widget.task.isCompleted;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.task.isCompleted) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_TaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.isCompleted != _wasCompleted) {
      _wasCompleted = widget.task.isCompleted;
      if (widget.task.isCompleted) {
        _controller.forward();
        _triggerVibration();
      } else {
        _controller.reverse();
      }
    }
  }

  Future<void> _triggerVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 50, amplitude: 128);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: widget.task.isCompleted ? const Color(0xFF22D3EE) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: widget.task.isCompleted
                        ? null
                        : Border.all(
                            color: const Color(0xFFD1D5DB),
                            width: 2,
                          ),
                  ),
                  child: widget.task.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.task.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.task.isCompleted ? const Color(0xFF6B7280) : const Color(0xFF111827),
                  decoration: widget.task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  decorationColor: const Color(0xFFD1D5DB),
                ),
              ),
              if (widget.task.isCompleted && widget.task.completedAt != null)
                AnimatedOpacity(
                  opacity: widget.task.isCompleted ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '完成于：${_formatCompletedTime(widget.task.completedAt!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
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
  String? _existingReviewId;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _loadAnnualReview();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadAnnualReview() async {
    final db = ref.read(appDatabaseProvider);
    final existing = await db.annualReviewDao.findByYear(_selectedYear);
    if (existing != null && mounted) {
      setState(() {
        _reviewController.text = existing.content ?? '';
        if (existing.images != null && existing.images!.isNotEmpty) {
          try {
            final List<dynamic> imageList = jsonDecode(existing.images!);
            _reviewImages.clear();
            _reviewImages.addAll(imageList.cast<String>());
          } catch (_) {}
        }
        _existingReviewId = existing.id;
      });
    } else if (mounted) {
      setState(() {
        _reviewController.clear();
        _reviewImages.clear();
        _existingReviewId = null;
      });
    }
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
    setState(() {
      _selectedYear = selected;
    });
    await _loadAnnualReview();
  }

  void _shiftYear(List<int> years, int activeYear, int delta) {
    if (years.isEmpty) return;
    final index = years.indexOf(activeYear);
    if (index == -1) return;
    final nextIndex = index + delta;
    if (nextIndex < 0 || nextIndex >= years.length) return;
    setState(() {
      _selectedYear = years[nextIndex];
    });
    _loadAnnualReview();
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
    final configAsync = ref.watch(moduleManagementConfigProvider);
    
    return configAsync.when(
      data: (config) {
        final goalTags = config.moduleOf('goal').tags;
        final goalTypeOptions = _buildGoalTypeOptionsFromConfig(goalTags);
        
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
                        final label = _goalLabelFor(goal.category, goalTypeOptions);
                        grouped.putIfAbsent(label, () => []).add(goal);
                      }
                      final orderedLabels = <String>[
                        for (final option in goalTypeOptions)
                          if (grouped.containsKey(option.label)) option.label,
                        for (final label in grouped.keys)
                          if (!goalTypeOptions.any((o) => o.label == label)) label,
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
                                    _GoalCategorySection(label: label, goals: grouped[label] ?? const [], db: db, goalTypeOptions: goalTypeOptions),
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
                                                  Positioned.fill(child: AppImage(source: imageUrl, fit: BoxFit.cover)),
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
                                          onPressed: () async {
                                            FocusManager.instance.primaryFocus?.unfocus();
                                            final db = ref.read(appDatabaseProvider);
                                            final now = DateTime.now();

                                            final imagesJson = _reviewImages.isEmpty ? null : jsonEncode(_reviewImages);

                                            await db.annualReviewDao.upsert(
                                              AnnualReviewsCompanion(
                                                id: Value(_existingReviewId ?? ref.read(uuidProvider).v4()),
                                                year: Value(_selectedYear),
                                                content: Value(_reviewController.text.trim().isEmpty ? null : _reviewController.text.trim()),
                                                images: Value(imagesJson),
                                                createdAt: Value(_existingReviewId != null ? now : now),
                                                updatedAt: Value(now),
                                              ),
                                            );

                                            if (!mounted) return;
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存年度复盘')));
                                            }
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
      },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, __) => const Scaffold(body: Center(child: Text('加载配置失败'))),
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
  late ConfettiController _confettiController;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _previousProgress = widget.record.progress.clamp(0, 1).toDouble();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onTaskCompleted() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    final db = ref.read(appDatabaseProvider);
    final updatedRecord = await (db.select(db.goalRecords)..where((t) => t.id.equals(widget.record.id))).getSingleOrNull();
    if (updatedRecord == null || !mounted) return;
    final newProgress = updatedRecord.progress.clamp(0, 1).toDouble();
    if (newProgress > _previousProgress) {
      _confettiController.play();
      _triggerCelebrationVibration();
    }
    _previousProgress = newProgress;
  }

  Future<void> _triggerCelebrationVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 50, amplitude: 128);
      }
    } catch (_) {}
  }

  void _showActionMenu() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetShell(
          title: '操作',
          actionText: '关闭',
          onAction: () => Navigator.of(context).pop(),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            children: [
              ListTile(
                leading: const Icon(Icons.hub, color: AppTheme.primary),
                title: const Text('拆解维护', style: TextStyle(fontWeight: FontWeight.w900)),
                onTap: () => Navigator.of(context).pop('maintain'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.edit, color: AppTheme.primary),
                title: const Text('编辑', style: TextStyle(fontWeight: FontWeight.w900)),
                onTap: () => Navigator.of(context).pop('edit'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                title: const Text('删除', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFEF4444))),
                onTap: () => Navigator.of(context).pop('delete'),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    if (result == 'maintain') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GoalBreakdownMaintenancePage(goal: widget.record),
      ));
    } else if (result == 'edit') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GoalCreatePage(goal: widget.record),
      ));
    } else if (result == 'delete') {
      _showDeleteConfirmation();
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除目标'),
        content: const Text('确认删除该目标及其所有子目标吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();

    await (db.update(db.goalRecords)..where((t) => t.id.equals(widget.record.id))).write(
      GoalRecordsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );

    final children = await (db.select(db.goalRecords)
          ..where((t) => t.parentId.equals(widget.record.id))
          ..where((t) => t.isDeleted.equals(false)))
        .get();

    for (final child in children) {
      await (db.update(db.goalRecords)..where((t) => t.id.equals(child.id))).write(
        GoalRecordsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
      final grandchildren = await (db.select(db.goalRecords)
            ..where((t) => t.parentId.equals(child.id))
            ..where((t) => t.isDeleted.equals(false)))
          .get();
      for (final grandchild in grandchildren) {
        await (db.update(db.goalRecords)..where((t) => t.id.equals(grandchild.id))).write(
          GoalRecordsCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(now),
          ),
        );
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _editSummary(GoalRecord record) async {
    final summaryController = TextEditingController(text: record.summary ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('编辑总结'),
          content: TextField(
            controller: summaryController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: '目标总结',
              hintText: '写下这个目标的最终总结...',
              border: OutlineInputBorder(),
            ),
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
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    await (db.update(db.goalRecords)..where((t) => t.id.equals(record.id))).write(
      GoalRecordsCompanion(
        summary: Value(summary.isEmpty ? null : summary),
        updatedAt: Value(now),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('总结已保存')));
  }

  Future<void> _addStageReview(GoalRecord record) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新增阶段复盘'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '复盘标题',
                  hintText: '例如：第一季度进展',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '复盘内容',
                  hintText: '写下这个阶段的进展和反思...',
                  border: OutlineInputBorder(),
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

    final title = titleController.text.trim();
    if (title.isEmpty) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入复盘标题')));
      }
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    await db.goalReviewDao.insert(
      GoalReviewsCompanion.insert(
        id: ref.read(uuidProvider).v4(),
        goalId: record.id,
        title: title,
        content: Value(contentController.text.trim().isEmpty ? null : contentController.text.trim()),
        reviewDate: now,
        createdAt: now,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('阶段复盘已保存')));
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(goalDetailProvider(widget.record.id));

    return detailAsync.when(
      data: (state) {
        if (state == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6F8F8),
            appBar: AppBar(title: const Text('目标不存在')),
            body: const Center(child: Text('该目标已被删除')),
          );
        }

        final record = state.goal;
        final now = DateTime.now();
        final dueDate = record.dueDate;
        final leftText = dueDate == null
            ? '未设置'
            : (dueDate.difference(DateTime(now.year, now.month, now.day)).inDays >= 0
                ? '剩 ${dueDate.difference(DateTime(now.year, now.month, now.day)).inDays} 天'
                : '已超期 ${-dueDate.difference(DateTime(now.year, now.month, now.day)).inDays} 天');
        final progressPercent = (record.progress * 100).round().clamp(0, 100);
        final db = ref.read(appDatabaseProvider);

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
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 30,
                  gravity: 0.2,
                  colors: const [
                    Color(0xFF2BCDEE),
                    Color(0xFFA855F7),
                    Color(0xFF22D3EE),
                    Color(0xFFF97316),
                    Color(0xFFEC4899),
                    Color(0xFF10B981),
                  ],
                  createParticlePath: (size) {
                    final path = Path();
                    path.addOval(Rect.fromCircle(center: Offset.zero, radius: 6));
                    return path;
                  },
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
                            icon: Icons.more_vert,
                            onTap: _showActionMenu,
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
                          const SizedBox(height: 14),
                          if (record.note?.isNotEmpty == true) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFF3F4F6)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.description_outlined, size: 16, color: AppTheme.primary),
                                      SizedBox(width: 6),
                                      Text('目标描述', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    record.note!,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151), height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (record.summary?.isNotEmpty == true) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFFEF3C7)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.auto_awesome, size: 16, color: Color(0xFFF59E0B)),
                                      SizedBox(width: 6),
                                      Text('目标总结', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    record.summary!,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF78350F), height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (state.reviews.isNotEmpty) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('阶段复盘', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFF3F4F6)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (int i = 0; i < state.reviews.length; i++) ...[
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                state.reviews[i].title,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _formatDotDate(state.reviews[i].reviewDate),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF94A3B8),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (state.reviews[i].content?.isNotEmpty == true) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            state.reviews[i].content!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                        if (i != state.reviews.length - 1) const Divider(height: 24, color: Color(0xFFE5E7EB)),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ],
                          if (state.postponements.isNotEmpty) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('顺延记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFF3F4F6)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (int i = 0; i < state.postponements.length; i++) ...[
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF7ED),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.update,
                                                size: 20,
                                                color: Color(0xFFF97316),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      if (state.postponements[i].oldDueDate != null)
                                                        Text(
                                                          _formatDotDate(state.postponements[i].oldDueDate!),
                                                          style: const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w700,
                                                            color: Color(0xFF94A3B8),
                                                            decoration: TextDecoration.lineThrough,
                                                          ),
                                                        ),
                                                      const SizedBox(width: 8),
                                                      const Icon(
                                                        Icons.arrow_forward,
                                                        size: 14,
                                                        color: Color(0xFF6B7280),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      if (state.postponements[i].newDueDate != null)
                                                        Text(
                                                          _formatDotDate(state.postponements[i].newDueDate!),
                                                          style: const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w900,
                                                            color: Color(0xFF111827),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  if (state.postponements[i].reason?.isNotEmpty == true) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      state.postponements[i].reason!,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF6B7280),
                                                      ),
                                                    ),
                                                  ],
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _formatDotDate(state.postponements[i].createdAt),
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: Color(0xFF94A3B8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (i != state.postponements.length - 1) const Divider(height: 24, color: Color(0xFFE5E7EB)),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          _buildQuarterNodes(state.quarterGoals, state.dailyTasks, db, record.id),
                          const SizedBox(height: 18),
                          Container(height: 1, color: const Color(0xFFE5E7EB)),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(child: Text('关联记忆', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
                              TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => GoalAllLinksPage(goalId: record.id)),
                                ),
                                style: TextButton.styleFrom(foregroundColor: AppTheme.primary, textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                                child: const Text('查看全部'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _RelatedMemoryList(goalId: record.id, db: db),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(record, db),
        );
      },
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFF6F8F8),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: const Color(0xFFF6F8F8),
        body: const Center(child: Text('加载失败')),
      ),
    );
  }

  Widget _buildQuarterNodes(List<GoalRecord> quarters, List<GoalRecord> tasks, AppDatabase db, String goalId) {
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
                  : _QuarterState.active;
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
                        completedAt: task.completedAt,
                        onChanged: (v) => _updateTaskCompletionForGoal(db, task, v, goalId),
                        onTaskCompleted: _onTaskCompleted,
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
  }

  Widget _buildBottomBar(GoalRecord record, AppDatabase db) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => GoalPostponePage(goal: record),
                )),
                icon: const Icon(Icons.update, size: 16),
                label: const Text('顺延计划'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _editSummary(record),
                icon: const Icon(Icons.edit_note, size: 16),
                label: const Text('编辑总结'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  await (db.update(db.goalRecords)..where((t) => t.id.equals(record.id))).write(
                    GoalRecordsCompanion(
                      isFavorite: Value(!record.isFavorite),
                      updatedAt: Value(now),
                    ),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(record.isFavorite ? '已取消收藏' : '已添加到收藏'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                icon: Icon(record.isFavorite ? Icons.favorite : Icons.favorite_border, size: 16),
                label: Text(record.isFavorite ? '已收藏' : '收藏'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: record.isFavorite ? const Color(0xFFEC4899) : const Color(0xFF6B7280),
                  side: BorderSide(color: record.isFavorite ? const Color(0xFFEC4899) : const Color(0xFFE5E7EB)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _addStageReview(record),
                icon: const Icon(Icons.rate_review, size: 16),
                label: const Text('新增复盘'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
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
      await db.into(db.goalRecords).insert(
            GoalRecordsCompanion.insert(
              id: ref.read(uuidProvider).v4(),
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
    await db.into(db.goalRecords).insert(
          GoalRecordsCompanion.insert(
            id: ref.read(uuidProvider).v4(),
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
                      colors: [Color(0x0A2BCDEE), Color(0x00FFFFFF)],
                    ),
                  ),
                ),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Material(
                  color: Colors.white.withValues(alpha: 0.8),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      border: const Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                    ),
                    child: Row(
                      children: [
                        _CircleIconButton(
                          icon: Icons.arrow_back_ios_new,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text('目标拆解维护', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                          ),
                        ),
                        TextButton(
                          onPressed: _saveSummary,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                          child: const Text('保存'),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCF8FD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.flag, size: 28, color: AppTheme.primary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('当前父级目标', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.goal.title,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1.2),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 14, color: Color(0xFF94A3B8)),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.goal.targetYear != null ? '${widget.goal.targetYear} 年度目标' : '目标',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Text('阶段拆解', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                          const Spacer(),
                          const Text('长按拖动排序', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<List<GoalRecord>>(
                        stream: _watchStages(db),
                        builder: (context, stageSnapshot) {
                          final stages = stageSnapshot.data ?? const <GoalRecord>[];
                          return StreamBuilder<List<GoalRecord>>(
                            stream: _watchTasks(db, stages.map((s) => s.id).toList()),
                            builder: (context, taskSnapshot) {
                              final tasks = taskSnapshot.data ?? const <GoalRecord>[];
                              if (stages.isEmpty) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 40),
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFF3F4F6)),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '暂无阶段，点击下方按钮添加',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  for (int i = 0; i < stages.length; i++) ...[
                                    _StageNode(
                                      stage: stages[i],
                                      tasks: tasks.where((t) => t.parentId == stages[i].id).toList(),
                                      isLast: i == stages.length - 1,
                                      onEdit: () => _showStageEditor(stage: stages[i]),
                                      onDelete: () => _deleteStage(stages[i]),
                                      onAddTask: () => _addTask(stages[i]),
                                      onDeleteTask: (task) => _deleteTask(task),
                                      onTaskToggle: (task, checked) => _updateTaskCompletionForGoal(db, task, checked, widget.goal.id),
                                    ),
                                    if (i < stages.length - 1) const SizedBox(height: 8),
                                  ],
                                ],
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(left: 56),
                        child: OutlinedButton(
                          onPressed: _showStageEditor,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(color: Color(0x4D2BCDEE), width: 2),
                            backgroundColor: const Color(0x0A2BCDEE),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0x332BCDEE),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Icon(Icons.add, size: 16, color: AppTheme.primary),
                              ),
                              const SizedBox(width: 8),
                              const Text('添加新的阶段 (季度/月度)'),
                            ],
                          ),
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
    );
  }
}

class _StageNode extends StatelessWidget {
  const _StageNode({
    required this.stage,
    required this.tasks,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
    required this.onAddTask,
    required this.onDeleteTask,
    required this.onTaskToggle,
  });

  final GoalRecord stage;
  final List<GoalRecord> tasks;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddTask;
  final void Function(GoalRecord) onDeleteTask;
  final void Function(GoalRecord, bool) onTaskToggle;

  String _getStageLabel(GoalRecord stage) {
    final quarter = stage.targetQuarter;
    if (quarter == null) return '';
    final startMonth = (quarter - 1) * 3 + 1;
    final endMonth = quarter * 3;
    return '$startMonth月 - $endMonth月';
  }

  String _getStageStatus() {
    if (tasks.isEmpty) return '未开始';
    final completedCount = tasks.where((t) => t.isCompleted).length;
    if (completedCount == 0) return '未开始';
    if (completedCount == tasks.length) return '已完成';
    return '进行中';
  }

  @override
  Widget build(BuildContext context) {
    final status = _getStageStatus();
    final isActive = status == '进行中';
    final isCompleted = status == '已完成';

    return Stack(
      children: [
        if (!isLast)
          Positioned(
            left: 20,
            top: 48,
            bottom: 0,
            child: Container(
              width: 2,
              color: const Color(0xFFE5E7EB),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: isCompleted ? AppTheme.primary : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? AppTheme.primary
                      : isCompleted
                          ? AppTheme.primary
                          : const Color(0xFFE5E7EB),
                  width: isActive || isCompleted ? 0 : 2,
                ),
                boxShadow: isActive || isCompleted
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  'Q${stage.targetQuarter ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isActive || isCompleted ? Colors.white : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isActive
                      ? Border(
                          left: BorderSide(color: AppTheme.primary, width: 4),
                          top: const BorderSide(color: Color(0xFFF3F4F6)),
                          right: const BorderSide(color: Color(0xFFF3F4F6)),
                          bottom: const BorderSide(color: Color(0xFFF3F4F6)),
                        )
                      : Border.all(color: const Color(0xFFF3F4F6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: isActive
                          ? BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.05),
                              border: const Border(bottom: BorderSide(color: Color(0xFFF9FAFB))),
                            )
                          : null,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stage.title,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_getStageLabel(stage)} · $status',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              InkWell(
                                onTap: onEdit,
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Icon(Icons.edit, size: 20, color: Color(0xFF94A3B8)),
                                ),
                              ),
                              InkWell(
                                onTap: onDelete,
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF94A3B8)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (tasks.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB).withValues(alpha: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.subdirectory_arrow_right, size: 16, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 4),
                                const Text(
                                  '任务详情',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF94A3B8),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            for (int i = 0; i < tasks.length; i++) ...[
                              _MaintainTaskItem(
                                task: tasks[i],
                                onToggle: (checked) => onTaskToggle(tasks[i], checked),
                                onDelete: () => onDeleteTask(tasks[i]),
                              ),
                              if (i < tasks.length - 1) const SizedBox(height: 12),
                            ],
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: onAddTask,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF94A3B8),
                                side: const BorderSide(color: Color(0xFFD1D5DB), style: BorderStyle.solid),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add, size: 16),
                                  const SizedBox(width: 4),
                                  const Text('添加具体任务'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (tasks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: OutlinedButton(
                          onPressed: onAddTask,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF94A3B8),
                            side: const BorderSide(color: Color(0xFFD1D5DB), style: BorderStyle.solid),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add, size: 16),
                              const SizedBox(width: 4),
                              const Text('添加具体任务'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MaintainTaskItem extends StatelessWidget {
  const _MaintainTaskItem({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  final GoalRecord task;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, size: 20, color: Color(0xFFD1D5DB)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: task.isCompleted ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
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

String _formatCompletedTime(DateTime date) {
  final year = date.year.toString();
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
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
  
  await db.transaction(() async {
    await (db.update(db.goalRecords)..where((t) => t.id.equals(task.id))).write(
      GoalRecordsCompanion(
        isCompleted: Value(checked),
        completedAt: Value(checked ? now : null),
        updatedAt: Value(now),
      ),
    );

    if (task.level == 'daily') {
      if (checked) {
        final eventRecordDate = DateTime(task.recordDate.year, task.recordDate.month, task.recordDate.day);
        await db.into(db.timelineEvents).insertOnConflictUpdate(
          TimelineEventsCompanion.insert(
            id: task.id,
            title: task.title,
            eventType: 'goal',
            startAt: Value(task.recordDate),
            recordDate: eventRecordDate,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        final deletedCount = await (db.delete(db.timelineEvents)
              ..where((t) => t.id.equals(task.id))
              ..where((t) => t.eventType.equals('goal')))
            .go();
        debugPrint('Goal task ${task.id} unchecked, deleted $deletedCount timeline events');
      }
    }

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
  });
}

class GoalPostponePage extends ConsumerStatefulWidget {
  const GoalPostponePage({super.key, required this.goal});

  final GoalRecord goal;

  @override
  ConsumerState<GoalPostponePage> createState() => _GoalPostponePageState();
}

class _GoalPostponePageState extends ConsumerState<GoalPostponePage> {
  late DateTime _newDueDate;
  final TextEditingController _reasonController = TextEditingController();
  final List<String> _selectedTags = [];

  static const List<String> _reasonTags = [
    '工作太忙',
    '难度超预期',
    '身体抱恙',
    '计划变更',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _newDueDate = widget.goal.dueDate ?? DateTime(now.year, now.month, now.day).add(const Duration(days: 90));
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _confirmPostpone() async {
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();

    final oldDueDate = widget.goal.dueDate;
    final daysDiff = _newDueDate.difference(oldDueDate ?? now).inDays;

    await db.goalPostponementDao.insert(GoalPostponementsCompanion.insert(
      id: ref.read(uuidProvider).v4(),
      goalId: widget.goal.id,
      oldDueDate: Value(oldDueDate),
      newDueDate: Value(_newDueDate),
      reason: Value(_reasonController.text.trim().isEmpty ? null : _reasonController.text.trim()),
      daysAdded: Value(daysDiff),
      createdAt: now,
    ));

    final targetQuarter = ((_newDueDate.month - 1) ~/ 3) + 1;
    await (db.update(db.goalRecords)..where((t) => t.id.equals(widget.goal.id))).write(
      GoalRecordsCompanion(
        dueDate: Value(_newDueDate),
        targetYear: Value(_newDueDate.year),
        targetQuarter: Value(targetQuarter),
        targetMonth: Value(_newDueDate.month),
        isPostponed: const Value(true),
        updatedAt: Value(now),
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('顺延计划已确认')));
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final progressPercent = (widget.goal.progress * 100).round().clamp(0, 100);
    final oldDueDate = widget.goal.dueDate;
    final daysDiff = _newDueDate.difference(oldDueDate ?? DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
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
                          child: Text('顺延计划', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        ),
                      ),
                      _CircleIconButton(
                        icon: Icons.history,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 2, 24, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.goal.title,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.event, size: 16, color: AppTheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  oldDueDate == null ? '当前截止: 未设置' : '当前截止: ${_formatDotDate(oldDueDate)}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: CircularProgressIndicator(
                                value: 1,
                                color: const Color(0xFFE5E7EB),
                                strokeWidth: 5,
                              ),
                            ),
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: Transform.rotate(
                                angle: -3.14159 / 2,
                                child: CircularProgressIndicator(
                                  value: widget.goal.progress.clamp(0, 1).toDouble(),
                                  color: AppTheme.primary,
                                  strokeWidth: 5,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                            ),
                            Text(
                              '$progressPercent%',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 2, 24, 120),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCF8FD),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.edit_calendar, size: 20, color: AppTheme.primary),
                                ),
                                const SizedBox(width: 8),
                                const Text('调整截止日期', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () async {
                                final selected = await showDatePicker(
                                  context: context,
                                  initialDate: _newDueDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (selected != null && mounted) {
                                  setState(() => _newDueDate = selected);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F8F8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_month, size: 20, color: Color(0xFF6B7280)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${_newDueDate.year}-${_newDueDate.month.toString().padLeft(2, '0')}-${_newDueDate.day.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, size: 24, color: AppTheme.primary),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  oldDueDate == null ? '当前: 未设置' : '当前: ${_formatDotDate(oldDueDate)}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                                ),
                                Text(
                                  '+$daysDiff 天',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF4E5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.psychology_alt, size: 20, color: Color(0xFFFB923C)),
                                ),
                                const SizedBox(width: 8),
                                const Text('顺延原因与复盘', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _reasonController,
                              maxLines: 6,
                              decoration: const InputDecoration(
                                hintText: '最近遇到了什么困难？为什么需要更多时间？写下来也许能理清思路...',
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Color(0xFFF6F8F8),
                                contentPadding: EdgeInsets.all(16),
                              ),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827), height: 1.6),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final tag in _reasonTags) ...[
                                    FilterChip(
                                      label: Text(tag),
                                      selected: _selectedTags.contains(tag),
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedTags.add(tag);
                                          } else {
                                            _selectedTags.remove(tag);
                                          }
                                        });
                                      },
                                      backgroundColor: const Color(0xFFF3F4F6),
                                      selectedColor: const Color(0xFFDCF8FD),
                                      checkmarkColor: AppTheme.primary,
                                      labelStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _selectedTags.contains(tag) ? AppTheme.primary : const Color(0xFF6B7280),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            const Text('过往顺延记录', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
                            const Spacer(),
                            StreamBuilder<List<GoalPostponement>>(
                              stream: db.goalPostponementDao.watchByGoalId(widget.goal.id),
                              builder: (context, snapshot) {
                                final count = snapshot.data?.length ?? 0;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '$count次',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<List<GoalPostponement>>(
                        stream: db.goalPostponementDao.watchByGoalId(widget.goal.id),
                        builder: (context, snapshot) {
                          final postponements = snapshot.data ?? const <GoalPostponement>[];
                          if (postponements.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFF3F4F6)),
                              ),
                              child: const Text('暂无顺延记录', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                            );
                          }
                          return Column(
                            children: [
                              for (int i = 0; i < postponements.length; i++) ...[
                                _PostponementHistoryItem(
                                  postponement: postponements[i],
                                  isLast: i == postponements.length - 1,
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    border: Border(top: BorderSide(color: const Color(0xFFE5E7EB))),
                  ),
                  child: ElevatedButton(
                    onPressed: _confirmPostpone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                      shadowColor: AppTheme.primary.withValues(alpha: 0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: const AlwaysStoppedAnimation(0),
                          builder: (context, child) => Transform.rotate(
                            angle: 0,
                            child: child,
                          ),
                          child: const Icon(Icons.update, size: 20),
                        ),
                        const SizedBox(width: 8),
                        const Text('确认顺延'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostponementHistoryItem extends StatelessWidget {
  const _PostponementHistoryItem({required this.postponement, required this.isLast});

  final GoalPostponement postponement;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 12, bottom: isLast ? 0 : 24),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatDotDate(postponement.createdAt),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4E5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+${postponement.daysAdded ?? 0}天',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFF97316)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (postponement.oldDueDate != null)
                          Text(
                            _formatDotDate(postponement.oldDueDate!),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        if (postponement.oldDueDate != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_right_alt, size: 18, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _formatDotDate(postponement.newDueDate ?? DateTime.now()),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                        ),
                      ],
                    ),
                    if (postponement.reason != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '"${postponement.reason!}"',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

class _HeroProgressRing extends StatefulWidget {
  const _HeroProgressRing({required this.progress, required this.percentText});

  final double progress;
  final String percentText;

  @override
  State<_HeroProgressRing> createState() => _HeroProgressRingState();
}

class _HeroProgressRingState extends State<_HeroProgressRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0;
  int _displayPercent = 0;

  @override
  void initState() {
    super.initState();
    _previousProgress = widget.progress.clamp(0, 1).toDouble();
    _displayPercent = (_previousProgress * 100).round();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: _previousProgress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.addListener(_updatePercent);
    _controller.forward();
  }

  void _updatePercent() {
    final newPercent = (_progressAnimation.value * 100).round();
    if (newPercent != _displayPercent) {
      setState(() {
        _displayPercent = newPercent;
      });
    }
  }

  @override
  void didUpdateWidget(_HeroProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newProgress = widget.progress.clamp(0, 1).toDouble();
    if ((newProgress - _previousProgress).abs() > 0.001) {
      _progressAnimation = Tween<double>(begin: _previousProgress, end: newProgress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
      _previousProgress = newProgress;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updatePercent);
    _controller.dispose();
    super.dispose();
  }

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
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return SizedBox(
                  width: 192,
                  height: 192,
                  child: CircularProgressIndicator(
                    value: _progressAnimation.value.clamp(0, 1).toDouble(),
                    strokeWidth: 12,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                  ),
                );
              },
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_displayPercent%',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.primary, height: 1),
                ),
                const SizedBox(height: 6),
                Text(
                  _displayPercent >= 100 ? '已完成' : '进行中',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF)),
                ),
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

class _DayTaskTile extends StatefulWidget {
  const _DayTaskTile({
    required this.checked,
    required this.enabled,
    required this.style,
    required this.title,
    this.subtitle,
    this.completedAt,
    this.onChanged,
    this.onTaskCompleted,
  });

  final bool checked;
  final bool enabled;
  final _DayTaskStyle style;
  final String title;
  final String? subtitle;
  final DateTime? completedAt;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTaskCompleted;

  @override
  State<_DayTaskTile> createState() => _DayTaskTileState();
}

class _DayTaskTileState extends State<_DayTaskTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _wasChecked = false;

  @override
  void initState() {
    super.initState();
    _wasChecked = widget.checked;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.checked) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_DayTaskTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checked != _wasChecked) {
      _wasChecked = widget.checked;
      if (widget.checked) {
        _controller.forward();
        _triggerVibration();
        widget.onTaskCompleted?.call();
      } else {
        _controller.reverse();
      }
    }
  }

  Future<void> _triggerVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 50, amplitude: 128);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.style == _DayTaskStyle.today ? AppTheme.primary.withValues(alpha: 0.30) : const Color(0xFFF3F4F6);
    final fillColor = widget.enabled ? Colors.white : Colors.white.withValues(alpha: 0.50);
    final opacity = widget.enabled ? 1.0 : 0.60;
    final titleStyle = TextStyle(
      fontSize: 13,
      fontWeight: widget.style == _DayTaskStyle.today ? FontWeight.w900 : FontWeight.w800,
      color: widget.checked ? const Color(0xFF9CA3AF) : const Color(0xFF374151),
      decoration: widget.checked ? TextDecoration.lineThrough : TextDecoration.none,
    );

    return Opacity(
      opacity: opacity,
      child: Material(
        color: fillColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: widget.enabled && widget.onChanged != null ? () => widget.onChanged!(!widget.checked) : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor)),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: Checkbox.adaptive(
                          value: widget.checked,
                          onChanged: widget.enabled && widget.onChanged != null ? (v) => widget.onChanged!(v ?? false) : null,
                          activeColor: AppTheme.primary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: widget.subtitle == null
                            ? titleStyle
                            : titleStyle.copyWith(color: const Color(0xFF111827), decoration: TextDecoration.none),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(widget.subtitle!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                      ],
                      if (widget.checked && widget.completedAt != null)
                        AnimatedOpacity(
                          opacity: widget.checked ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '完成于：${_formatCompletedTime(widget.completedAt!)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ),
                        ),
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

class _RelatedMemoryList extends StatelessWidget {
  const _RelatedMemoryList({required this.goalId, required this.db});

  final String goalId;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EntityLink>>(
      stream: db.linkDao.watchLinksForEntity(entityType: 'goal', entityId: goalId),
      builder: (context, snapshot) {
        final links = snapshot.data ?? const <EntityLink>[];
        if (links.isEmpty) {
          return _buildEmptyState(context);
        }
        return SizedBox(
          height: 186,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: links.length,
            itemBuilder: (context, index) {
              final link = links[index];
              return Padding(
                padding: EdgeInsets.only(right: index < links.length - 1 ? 12 : 0),
                child: _RelatedMemoryCard(link: link, goalId: goalId, db: db),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_off, size: 32, color: const Color(0xFF9CA3AF)),
            const SizedBox(height: 8),
            const Text('暂无关联记忆', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}

class _RelatedMemoryCard extends StatelessWidget {
  const _RelatedMemoryCard({required this.link, required this.goalId, required this.db});

  final EntityLink link;
  final String goalId;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    final isSource = link.sourceType == 'goal' && link.sourceId == goalId;
    final otherType = isSource ? link.targetType : link.sourceType;
    final otherId = isSource ? link.targetId : link.sourceId;

    switch (otherType) {
      case 'food':
        return _FoodMemoryCard(foodId: otherId, db: db);
      case 'travel':
        return _TravelMemoryCard(travelId: otherId, db: db);
      case 'moment':
        return _MomentMemoryCard(momentId: otherId, db: db);
      case 'friend':
        return _FriendMemoryCard(friendId: otherId, db: db);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _FoodMemoryCard extends StatelessWidget {
  const _FoodMemoryCard({required this.foodId, required this.db});

  final String foodId;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FoodRecord?>(
      stream: db.foodDao.watchById(foodId),
      builder: (context, snapshot) {
        final food = snapshot.data;
        if (food == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => FoodDetailPage(recordId: foodId)),
          ),
          child: SizedBox(
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
                        child: food.images != null && food.images!.isNotEmpty
                            ? (food.images!.startsWith('http')
                                ? Image.network(food.images!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder())
                                : Image.file(File(food.images!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder()))
                            : _buildPlaceholder(),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
                        child: const Icon(Icons.restaurant, size: 14, color: Color(0xFFF97316)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(food.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(_formatDate(food.recordDate), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFFED7AA),
      child: const Center(child: Icon(Icons.restaurant, size: 40, color: Color(0xFFF97316))),
    );
  }
}

class _TravelMemoryCard extends StatelessWidget {
  const _TravelMemoryCard({required this.travelId, required this.db});

  final String travelId;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TravelRecord?>(
      stream: db.watchTravelById(travelId),
      builder: (context, snapshot) {
        final travel = snapshot.data;
        if (travel == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TravelDetailPage(item: TravelItem.fromRecord(travel))),
          ),
          child: SizedBox(
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
                        child: travel.images != null && travel.images!.isNotEmpty
                            ? (travel.images!.startsWith('http')
                                ? Image.network(travel.images!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder())
                                : Image.file(File(travel.images!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder()))
                            : _buildPlaceholder(),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
                        child: const Icon(Icons.airplanemode_active, size: 14, color: Color(0xFF3B82F6)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(travel.title ?? '未命名', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(_formatDate(travel.recordDate), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFBFDBFE),
      child: const Center(child: Icon(Icons.airplanemode_active, size: 40, color: Color(0xFF3B82F6))),
    );
  }
}

class _MomentMemoryCard extends StatelessWidget {
  const _MomentMemoryCard({required this.momentId, required this.db});

  final String momentId;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MomentRecord?>(
      stream: db.momentDao.watchById(momentId),
      builder: (context, snapshot) {
        final moment = snapshot.data;
        if (moment == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MomentDetailPage(recordId: momentId)),
          ),
          child: SizedBox(
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
                        child: moment.images != null && moment.images!.isNotEmpty
                            ? (moment.images!.startsWith('http')
                                ? Image.network(moment.images!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder())
                                : Image.file(File(moment.images!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder()))
                            : _buildPlaceholder(),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
                        child: const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFEC4899)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(moment.content?.isNotEmpty == true ? moment.content! : '小确幸', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(_formatDate(moment.recordDate), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFFBCFE8),
      child: const Center(child: Icon(Icons.auto_awesome, size: 40, color: Color(0xFFEC4899))),
    );
  }
}

class _FriendMemoryCard extends StatelessWidget {
  const _FriendMemoryCard({required this.friendId, required this.db});

  final String friendId;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FriendRecord?>(
      stream: db.friendDao.watchById(friendId),
      builder: (context, snapshot) {
        final friend = snapshot.data;
        if (friend == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => FriendProfilePage(friendId: friendId)),
          ),
          child: SizedBox(
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
                        child: friend.avatarPath != null && friend.avatarPath!.isNotEmpty
                            ? (friend.avatarPath!.startsWith('http')
                                ? Image.network(friend.avatarPath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder(friend.name))
                                : Image.file(File(friend.avatarPath!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder(friend.name)))
                            : _buildPlaceholder(friend.name),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
                        child: const Icon(Icons.people, size: 14, color: Color(0xFFEF4444)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(friend.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(_formatDate(friend.meetDate), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(String? name) {
    return Container(
      color: const Color(0xFFFECACA),
      child: Center(
        child: Text(
          name?.isNotEmpty == true ? name!.substring(0, 1) : '?',
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Color(0xFFEF4444)),
        ),
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '';
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}

class GoalAllLinksPage extends ConsumerStatefulWidget {
  const GoalAllLinksPage({super.key, required this.goalId});

  final String goalId;

  @override
  ConsumerState<GoalAllLinksPage> createState() => _GoalAllLinksPageState();
}

class _GoalAllLinksPageState extends ConsumerState<GoalAllLinksPage> {
  String _selectedFilter = 'all';

  static const List<_FilterOption> _filters = [
    _FilterOption(value: 'all', label: '全部', icon: Icons.apps),
    _FilterOption(value: 'food', label: '美食', icon: Icons.restaurant),
    _FilterOption(value: 'travel', label: '旅行', icon: Icons.airplanemode_active),
    _FilterOption(value: 'moment', label: '小确幸', icon: Icons.auto_awesome),
    _FilterOption(value: 'friend', label: '羁绊', icon: Icons.group),
  ];

  @override
  Widget build(BuildContext context) {
    final db = ref.read(appDatabaseProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('全部关联', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: StreamBuilder<List<EntityLink>>(
              stream: db.linkDao.watchLinksForEntity(entityType: 'goal', entityId: widget.goalId),
              builder: (context, snapshot) {
                final links = snapshot.data ?? const <EntityLink>[];
                final filteredLinks = _selectedFilter == 'all' 
                    ? links 
                    : links.where((l) {
                        final isSource = l.sourceType == 'goal' && l.sourceId == widget.goalId;
                        final otherType = isSource ? l.targetType : l.sourceType;
                        return otherType == _selectedFilter;
                      }).toList();

                if (filteredLinks.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredLinks.length,
                  itemBuilder: (context, index) {
                    final link = filteredLinks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RelatedMemoryListItem(link: link, goalId: widget.goalId, db: db),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(filter.icon, size: 14, color: isSelected ? Colors.white : const Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(filter.label),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = filter.value),
              backgroundColor: const Color(0xFFF1F5F9),
              selectedColor: AppTheme.primary,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link_off, size: 64, color: const Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          const Text('暂无关联记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

class _FilterOption {
  const _FilterOption({required this.value, required this.label, required this.icon});

  final String value;
  final String label;
  final IconData icon;
}

class _RelatedMemoryListItem extends StatelessWidget {
  const _RelatedMemoryListItem({required this.link, required this.goalId, required this.db});

  final EntityLink link;
  final String goalId;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    final isSource = link.sourceType == 'goal' && link.sourceId == goalId;
    final otherType = isSource ? link.targetType : link.sourceType;
    final otherId = isSource ? link.targetId : link.sourceId;

    switch (otherType) {
      case 'food':
        return _FoodListItem(foodId: otherId, db: db);
      case 'travel':
        return _TravelListItem(travelId: otherId, db: db);
      case 'moment':
        return _MomentListItem(momentId: otherId, db: db);
      case 'friend':
        return _FriendListItem(friendId: otherId, db: db);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _FoodListItem extends StatelessWidget {
  const _FoodListItem({required this.foodId, required this.db});

  final String foodId;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FoodRecord?>(
      stream: db.foodDao.watchById(foodId),
      builder: (context, snapshot) {
        final food = snapshot.data;
        if (food == null) return const SizedBox.shrink();

        return ListTile(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FoodDetailPage(recordId: foodId))),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFFFED7AA), borderRadius: BorderRadius.circular(8)),
            child: food.images != null && food.images!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: food.images!.startsWith('http')
                        ? Image.network(food.images!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: Color(0xFFF97316)))
                        : Image.file(File(food.images!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: Color(0xFFF97316))),
                  )
                : const Icon(Icons.restaurant, color: Color(0xFFF97316)),
          ),
          title: Text(food.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          subtitle: Text(_formatDate(food.recordDate), style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
        );
      },
    );
  }
}

class _TravelListItem extends StatelessWidget {
  const _TravelListItem({required this.travelId, required this.db});

  final String travelId;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TravelRecord?>(
      stream: db.watchTravelById(travelId),
      builder: (context, snapshot) {
        final travel = snapshot.data;
        if (travel == null) return const SizedBox.shrink();

        return ListTile(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TravelDetailPage(item: TravelItem.fromRecord(travel)))),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFFBFDBFE), borderRadius: BorderRadius.circular(8)),
            child: travel.images != null && travel.images!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: travel.images!.startsWith('http')
                        ? Image.network(travel.images!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.airplanemode_active, color: Color(0xFF3B82F6)))
                        : Image.file(File(travel.images!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.airplanemode_active, color: Color(0xFF3B82F6))),
                  )
                : const Icon(Icons.airplanemode_active, color: Color(0xFF3B82F6)),
          ),
          title: Text(travel.title ?? '未命名', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          subtitle: Text(_formatDate(travel.recordDate), style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
        );
      },
    );
  }
}

class _MomentListItem extends StatelessWidget {
  const _MomentListItem({required this.momentId, required this.db});

  final String momentId;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MomentRecord?>(
      stream: db.momentDao.watchById(momentId),
      builder: (context, snapshot) {
        final moment = snapshot.data;
        if (moment == null) return const SizedBox.shrink();

        return ListTile(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MomentDetailPage(recordId: momentId))),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFFFBCFE8), borderRadius: BorderRadius.circular(8)),
            child: moment.images != null && moment.images!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: moment.images!.startsWith('http')
                        ? Image.network(moment.images!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome, color: Color(0xFFEC4899)))
                        : Image.file(File(moment.images!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome, color: Color(0xFFEC4899))),
                  )
                : const Icon(Icons.auto_awesome, color: Color(0xFFEC4899)),
          ),
          title: Text(moment.content?.isNotEmpty == true ? moment.content! : '小确幸', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          subtitle: Text(_formatDate(moment.recordDate), style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
        );
      },
    );
  }
}

class _FriendListItem extends StatelessWidget {
  const _FriendListItem({required this.friendId, required this.db});

  final String friendId;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FriendRecord?>(
      stream: db.friendDao.watchById(friendId),
      builder: (context, snapshot) {
        final friend = snapshot.data;
        if (friend == null) return const SizedBox.shrink();

        return ListTile(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FriendProfilePage(friendId: friendId))),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFFFECACA), shape: BoxShape.circle),
            child: friend.avatarPath != null && friend.avatarPath!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: friend.avatarPath!.startsWith('http')
                        ? Image.network(friend.avatarPath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(friend.name))
                        : Image.file(File(friend.avatarPath!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(friend.name)),
                  )
                : _buildAvatarPlaceholder(friend.name),
          ),
          title: Text(friend.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          subtitle: Text(_formatDate(friend.meetDate), style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
        );
      },
    );
  }

  Widget _buildAvatarPlaceholder(String? name) {
    return Center(
      child: Text(
        name?.isNotEmpty == true ? name!.substring(0, 1) : '?',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFEF4444)),
      ),
    );
  }
}

class GoalCreatePage extends ConsumerStatefulWidget {
  const GoalCreatePage({super.key, this.goal});

  final GoalRecord? goal;

  @override
  ConsumerState<GoalCreatePage> createState() => _GoalCreatePageState();
}

class _GoalCreatePageState extends ConsumerState<GoalCreatePage> {
  final Set<String> _linkedMomentIds = {};
  final Set<String> _linkedFoodIds = {};
  final Set<String> _linkedFriendIds = {};
  final Set<String> _linkedTravelIds = {};
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _selectedGoalType;
  late DateTime? _dueDate;
  late String _remindFrequency;

  bool get _isEditMode => widget.goal != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _titleController = TextEditingController(text: widget.goal!.title);
      _descriptionController = TextEditingController(text: widget.goal!.note ?? '');
      _selectedGoalType = widget.goal!.category ?? '';
      _dueDate = widget.goal!.dueDate;
      _remindFrequency = widget.goal!.remindFrequency ?? _remindOptions.first.value;
      _loadExistingLinks();
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedGoalType = '';
      _dueDate = null;
      _remindFrequency = _remindOptions.first.value;
    }
  }

  Future<void> _loadExistingLinks() async {
    if (!_isEditMode) return;
    final db = ref.read(appDatabaseProvider);
    final links = await db.linkDao.listLinksForEntity(
      entityType: 'goal',
      entityId: widget.goal!.id,
    );
    for (final link in links) {
      final isSource = link.sourceType == 'goal' && link.sourceId == widget.goal!.id;
      if (isSource) {
        switch (link.targetType) {
          case 'moment':
            _linkedMomentIds.add(link.targetId);
            break;
          case 'food':
            _linkedFoodIds.add(link.targetId);
            break;
          case 'friend':
            _linkedFriendIds.add(link.targetId);
            break;
          case 'travel':
            _linkedTravelIds.add(link.targetId);
            break;
        }
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
                      leading: const _IconSquare(color: Color(0xFFF0FDF4), icon: Icons.airplanemode_active, iconColor: Color(0xFF22C55E)),
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

    if (_selectedGoalType.isNotEmpty) {
      await syncTagToModuleConfig('goal', _selectedGoalType);
    }

    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final recordDate = DateTime(now.year, now.month, now.day);
    final goalId = _isEditMode ? widget.goal!.id : ref.read(uuidProvider).v4();

    final description = _descriptionController.text.trim();

    if (_isEditMode) {
      await (db.update(db.goalRecords)..where((t) => t.id.equals(goalId))).write(
            GoalRecordsCompanion(
              title: Value(title),
              note: Value(description.isEmpty ? null : description),
              category: Value(_selectedGoalType),
              remindFrequency: Value(_remindFrequency),
              targetYear: Value((_dueDate ?? recordDate).year),
              dueDate: Value(_dueDate),
              updatedAt: Value(now),
            ),
          );

      await (db.update(db.timelineEvents)..where((t) => t.id.equals(goalId))).write(
            TimelineEventsCompanion(
              title: Value(title),
              note: Value(description.isEmpty ? null : description),
              startAt: Value(_dueDate ?? recordDate),
              updatedAt: Value(now),
            ),
          );

      await db.linkDao.deleteLinksBySource('goal', goalId);
    } else {
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
    }

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
    final configAsync = ref.watch(moduleManagementConfigProvider);
    
    return configAsync.when(
      data: (config) {
        final configTags = getTagsForModule(config, 'goal');
        final goalTypeOptions = _buildGoalTypeOptions(configTags);
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
                  Expanded(
                    child: Center(
                      child: Text(_isEditMode ? '编辑目标' : '新建目标', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  TextButton(
                    onPressed: _save,
                    child: Text(_isEditMode ? '保存' : '创建', style: const TextStyle(fontWeight: FontWeight.w900)),
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
                            for (final option in goalTypeOptions) ...[
                              Expanded(
                                child: _GoalTypeCard(
                                  option: option,
                                  selected: _selectedGoalType == option.value,
                                  onTap: () => setState(() => _selectedGoalType = option.value),
                                ),
                              ),
                              if (option != goalTypeOptions.last) const SizedBox(width: 10),
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
                          icon: Icons.airplanemode_active,
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
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(body: Center(child: Text('加载配置失败'))),
    );
  }
  
  List<_GoalTypeOption> _buildGoalTypeOptions(List<String> tags) {
    final defaultOptions = <_GoalTypeOption>[
      const _GoalTypeOption(
        value: '职业发展',
        label: '职业发展',
        icon: Icons.work,
        accent: Color(0xFF3B82F6),
        background: Color(0xFFEFF6FF),
      ),
      const _GoalTypeOption(
        value: '身心健康',
        label: '身心健康',
        icon: Icons.favorite,
        accent: Color(0xFFEF4444),
        background: Color(0xFFFEE2E2),
      ),
      const _GoalTypeOption(
        value: '环球旅行',
        label: '环球旅行',
        icon: Icons.airplanemode_active,
        accent: Color(0xFF10B981),
        background: Color(0xFFDCFCE7),
      ),
    ];
    
    if (tags.isEmpty) return defaultOptions;
    
    final options = <_GoalTypeOption>[];
    for (final tag in tags) {
      final existing = defaultOptions.where((o) => o.label == tag || o.value == tag).firstOrNull;
      if (existing != null) {
        options.add(existing);
      } else {
        options.add(_GoalTypeOption(
          value: tag,
          label: tag,
          icon: Icons.flag,
          accent: AppTheme.primary,
          background: const Color(0xFFEFF6FF),
        ));
      }
    }
    return options;
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

// 目标筛选结果数据类
class _GoalFilterResult {
  const _GoalFilterResult({
    required this.statusIndex,
    required this.typeIndex,
    this.filterFavorite = false,
  });

  final int statusIndex;
  final int typeIndex;
  final bool filterFavorite;
}

// 目标筛选底部弹窗
class _GoalFilterBottomSheet extends StatefulWidget {
  const _GoalFilterBottomSheet({
    required this.initialStatusIndex,
    required this.initialTypeIndex,
    this.initialFilterFavorite = false,
  });

  final int initialStatusIndex;
  final int initialTypeIndex;
  final bool initialFilterFavorite;

  @override
  State<_GoalFilterBottomSheet> createState() => _GoalFilterBottomSheetState();
}

class _GoalFilterBottomSheetState extends State<_GoalFilterBottomSheet> {
  late int _statusIndex;
  late int _typeIndex;
  late bool _filterFavorite;

  static const _statusOptions = ['全部', '进行中', '已完成', '已顺延'];
  static const _typeOptions = ['全部', '职业发展', '身心健康', '环球旅行'];

  @override
  void initState() {
    super.initState();
    _statusIndex = widget.initialStatusIndex;
    _typeIndex = widget.initialTypeIndex;
    _filterFavorite = widget.initialFilterFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetShell(
      title: '筛选目标',
      actionText: '确定',
      onAction: () => Navigator.of(context).pop(
        _GoalFilterResult(statusIndex: _statusIndex, typeIndex: _typeIndex, filterFavorite: _filterFavorite),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('目标状态', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < _statusOptions.length; i++)
                    _FilterOptionChip(
                      label: _statusOptions[i],
                      selected: _statusIndex == i,
                      onTap: () => setState(() => _statusIndex = i),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('目标类型', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < _typeOptions.length; i++)
                    _FilterOptionChip(
                      label: _typeOptions[i],
                      selected: _typeIndex == i,
                      onTap: () => setState(() => _typeIndex = i),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('收藏', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              const SizedBox(height: 12),
              _FilterOptionChip(
                label: '仅收藏',
                selected: _filterFavorite,
                onTap: () => setState(() => _filterFavorite = !_filterFavorite),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterOptionChip extends StatelessWidget {
  const _FilterOptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2BCDEE) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? const Color(0xFF2BCDEE) : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
