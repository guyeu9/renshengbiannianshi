import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/module_management_config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/providers/uuid_provider.dart';
import '../../../core/utils/media_storage.dart';
import '../../../core/utils/tag_color_utils.dart';
import '../../../core/widgets/ai_parse_button.dart';
import '../../../core/widgets/amap_location_page.dart';
import '../../../core/widgets/custom_bottom_sheet.dart';
import '../../../core/widgets/app_image.dart';
import '../providers/moment_detail_provider.dart';

List<String> _parseMomentImages(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.whereType<String>().toList(growable: false);
    }
  } catch (_) {}
  return const [];
}

Color _parseMomentMoodColor(String? raw, Color fallback) {
  if (raw == null || raw.trim().isEmpty) return fallback;
  final hex = raw.replaceAll('#', '');
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return fallback;
  if (hex.length <= 6) {
    return Color(0xFF000000 | value);
  }
  return Color(value);
}

({String title, String content}) _splitMomentText(String? raw) {
  final text = (raw ?? '').trim();
  if (text.isEmpty) {
    return (title: '', content: '');
  }
  final splitIndex = text.indexOf('\n\n');
  if (splitIndex >= 0) {
    final title = text.substring(0, splitIndex).trim();
    final content = text.substring(splitIndex + 2).trim();
    return (title: title, content: content);
  }
  final lines = text.split('\n');
  final title = lines.first.trim();
  final content = lines.skip(1).join('\n').trim();
  return (title: title, content: content);
}

List<String> _parseSceneTags(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  final value = raw.trim();
  if (value.startsWith('[')) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList(growable: false);
      }
    } catch (_) {}
  }
  final parts = value.split(RegExp(r'[,\s，、/]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  return parts;
}

String? _encodeSceneTags(List<String> tags) {
  final cleaned = tags.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  if (cleaned.isEmpty) return null;
  return jsonEncode(cleaned);
}

String _momentTitleFromRecord(MomentRecord record) {
  final split = _splitMomentText(record.content);
  return split.title.isEmpty ? '小确幸' : split.title;
}

String _momentContentFromRecord(MomentRecord record) {
  final split = _splitMomentText(record.content);
  return split.content;
}

String _formatMomentCardDate(DateTime date) {
  return '${date.month}月${date.day}日';
}

const _momentMoodOptions = <_MoodOption>[
  _MoodOption(label: '开心', emoji: '😊', color: Color(0xFFFCA5A5)),
  _MoodOption(label: '平静', emoji: '😌', color: Color(0xFF22C55E)),
  _MoodOption(label: '治愈', emoji: '🌿', color: Color(0xFF60A5FA)),
  _MoodOption(label: '思考', emoji: '🤔', color: Color(0xFFA855F7)),
  _MoodOption(label: '放空', emoji: '☁️', color: Color(0xFF64748B)),
  _MoodOption(label: 'emo', emoji: '😶', color: Color(0xFF3B82F6)),
];

class MomentPage extends StatefulWidget {
  const MomentPage({super.key});

  @override
  State<MomentPage> createState() => _MomentPageState();
}

class _MomentPageState extends State<MomentPage> {
  var _filterDateIndex = 0;
  DateTimeRange? _filterCustomRange;
  Set<String> _filterFriendIds = {};
  var _filterFavorite = false;
  final _searchController = TextEditingController();
  var _searchQuery = '';
  var _selectedMood = '全部';

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
    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final db = ref.read(appDatabaseProvider);
            return _FilterBottomSheet(
              initialDateIndex: _filterDateIndex,
              initialCustomRange: _filterCustomRange,
              initialFriendIds: _filterFriendIds,
              initialFilterFavorite: _filterFavorite,
              friendsStream: db.friendDao.watchAllActive(),
            );
          },
        );
      },
    );
    if (result == null) return;
    setState(() {
      _filterDateIndex = result.dateIndex;
      _filterCustomRange = result.customRange;
      _filterFriendIds = result.friendIds;
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
            _MomentHeader(
              onFilterTap: _openFilterSheet,
              searchController: _searchController,
              onSearchChanged: (v) => setState(() => _searchQuery = v),
              selectedMood: _selectedMood,
              onMoodSelected: (mood) => setState(() => _selectedMood = mood),
              hasActiveFilter: _filterDateIndex != 0 || _filterFriendIds.isNotEmpty || _filterFavorite || _selectedMood != '全部',
            ),
            Expanded(
              child: _MomentHomeBody(
                searchQuery: _searchQuery,
                selectedMood: _selectedMood,
                filterDateIndex: _filterDateIndex,
                filterCustomRange: _filterCustomRange,
                filterFriendIds: _filterFriendIds,
                filterFavorite: _filterFavorite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MomentHeader extends StatelessWidget {
  const _MomentHeader({
    required this.onFilterTap,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedMood,
    required this.onMoodSelected,
    this.hasActiveFilter = false,
  });

  final VoidCallback onFilterTap;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String selectedMood;
  final ValueChanged<String> onMoodSelected;
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
                child: Text(
                  '小确幸',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                ),
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
                            hintText: '搜索心情、标签、地理位置..',
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
              _HeaderCircle(icon: Icons.tune, onTap: onFilterTap, hasActiveFilter: hasActiveFilter),
              const SizedBox(width: 12),
              _HeaderCircle(
                icon: Icons.add,
                iconColor: const Color(0xFF2BCDEE),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MomentCreatePage())),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _MoodChip(
                  active: selectedMood == '全部',
                  label: '全部',
                  color: const Color(0xFF2BCDEE),
                  onTap: () => onMoodSelected('全部'),
                ),
                const SizedBox(width: 10),
                for (var i = 0; i < _momentMoodOptions.length; i++) ...[
                  _MoodChip(
                    active: selectedMood == _momentMoodOptions[i].label,
                    label: _momentMoodOptions[i].label,
                    color: _momentMoodOptions[i].color,
                    onTap: () => onMoodSelected(_momentMoodOptions[i].label),
                  ),
                  if (i != _momentMoodOptions.length - 1) const SizedBox(width: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCircle extends StatelessWidget {
  const _HeaderCircle({required this.icon, required this.onTap, this.iconColor, this.hasActiveFilter = false});

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
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: fgColor, size: 22),
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.active, required this.label, required this.color, this.onTap});

  final bool active;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? color : const Color(0xFFE5E7EB)),
          boxShadow: active ? [BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 6))] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
    );
  }
}

class _MomentHomeBody extends ConsumerStatefulWidget {
  const _MomentHomeBody({
    required this.searchQuery,
    required this.selectedMood,
    required this.filterDateIndex,
    required this.filterCustomRange,
    required this.filterFriendIds,
    required this.filterFavorite,
  });

  final String searchQuery;
  final String selectedMood;
  final int filterDateIndex;
  final DateTimeRange? filterCustomRange;
  final Set<String> filterFriendIds;
  final bool filterFavorite;

  @override
  ConsumerState<_MomentHomeBody> createState() => _MomentHomeBodyState();
}

class _MomentHomeBodyState extends ConsumerState<_MomentHomeBody> {
  int _selectedYear = DateTime.now().year;

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

  bool _matchesDateFilter(MomentRecord record) {
    if (widget.filterDateIndex == 0) return true;
    final now = DateTime.now();
    final date = record.recordDate;
    switch (widget.filterDateIndex) {
      case 1: // 今日
        return date.year == now.year && date.month == now.month && date.day == now.day;
      case 2: // 近7天
        final weekAgo = now.subtract(const Duration(days: 7));
        return date.isAfter(weekAgo) || date.isAtSameMomentAs(weekAgo);
      case 3: // 近30天
        final monthAgo = now.subtract(const Duration(days: 30));
        return date.isAfter(monthAgo) || date.isAtSameMomentAs(monthAgo);
      case 4: // 自定义
        if (widget.filterCustomRange == null) return true;
        return (date.isAfter(widget.filterCustomRange!.start) || date.isAtSameMomentAs(widget.filterCustomRange!.start)) &&
               (date.isBefore(widget.filterCustomRange!.end) || date.isAtSameMomentAs(widget.filterCustomRange!.end));
      default:
        return true;
    }
  }

  bool _matchesSearch(MomentRecord record) {
    final query = widget.searchQuery.toLowerCase().trim();
    if (query.isEmpty) return true;
    final title = _momentTitleFromRecord(record).toLowerCase();
    final content = _momentContentFromRecord(record).toLowerCase();
    final tags = _parseSceneTags(record.tags).join(' ').toLowerCase();
    final location = (record.poiName ?? '').toLowerCase();
    final city = (record.city ?? '').toLowerCase();
    return title.contains(query) || content.contains(query) || tags.contains(query) || location.contains(query) || city.contains(query);
  }

  bool _matchesMood(MomentRecord record) {
    if (widget.selectedMood == '全部') return true;
    return record.mood == widget.selectedMood;
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder<List<MomentRecord>>(
      stream: db.momentDao.watchAllActive(),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <MomentRecord>[];

        return StreamBuilder<List<EntityLink>>(
          stream: db.select(db.entityLinks).watch(),
          builder: (context, linkSnapshot) {
            final allLinks = linkSnapshot.data ?? const <EntityLink>[];
            final links = allLinks.where((l) => l.sourceType == 'moment' || l.targetType == 'moment').toList();

            // 应用所有筛选条件
            var filteredRecords = records.where((r) {
              return _matchesDateFilter(r) && _matchesSearch(r) && _matchesMood(r);
            }).toList();

            // 羁绊筛选（需要查询关联数据）
            if (widget.filterFriendIds.isNotEmpty) {
              final momentIdsWithFriends = <String>{};
              for (final link in links) {
                final isMomentSource = link.sourceType == 'moment';
                final isMomentTarget = link.targetType == 'moment';
                final isFriendSource = link.sourceType == 'friend';
                final isFriendTarget = link.targetType == 'friend';

                if (isMomentSource && isFriendTarget && widget.filterFriendIds.contains(link.targetId)) {
                  momentIdsWithFriends.add(link.sourceId);
                } else if (isFriendSource && isMomentTarget && widget.filterFriendIds.contains(link.sourceId)) {
                  momentIdsWithFriends.add(link.targetId);
                }
              }
              filteredRecords = filteredRecords.where((r) => momentIdsWithFriends.contains(r.id)).toList();
            }

            // 收藏筛选
            if (widget.filterFavorite) {
              filteredRecords = filteredRecords.where((r) => r.isFavorite).toList();
            }

        final years = records.map((e) => e.recordDate.year).toSet().toList()..sort((a, b) => b.compareTo(a));
        final activeYear = years.contains(_selectedYear) ? _selectedYear : (years.isNotEmpty ? years.first : _selectedYear);
        final moodCounts = <String, int>{};
        for (final record in records) {
          if (record.recordDate.year != activeYear) continue;
          moodCounts.update(record.mood, (value) => value + 1, ifAbsent: () => 1);
        }
        final items = <MomentCardData>[];
        for (var i = 0; i < filteredRecords.length; i++) {
          final record = filteredRecords[i];
          final images = _parseMomentImages(record.images);
          final accent = _parseMomentMoodColor(record.moodColor, const Color(0xFF2BCDEE));
          final title = _momentTitleFromRecord(record);
          final content = _momentContentFromRecord(record);
          final tags = _parseSceneTags(record.tags);
          items.add(
            MomentCardData(
              recordId: record.id,
              moodName: record.mood,
              moodColor: accent.withValues(alpha: 0.12),
              moodAccent: accent,
              title: title,
              content: content,
              tags: tags,
              recordDate: record.recordDate,
              imageUrl: images.isEmpty ? '' : images.first,
              imageHeight: 180 + (i % 3) * 20,
              isFavorite: record.isFavorite,
            ),
          );
        }
        final left = <MomentCardData>[];
        final right = <MomentCardData>[];
        for (var i = 0; i < items.length; i++) {
          (i.isEven ? left : right).add(items[i]);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('年度心情', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        const Spacer(),
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => _pickYear(years, activeYear),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Row(
                              children: [
                                Text('$activeYear', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2BCDEE))),
                                const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF2BCDEE)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (moodCounts.isEmpty)
                      const Text('暂无心情记录', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)))
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final option in _momentMoodOptions)
                            if (moodCounts.containsKey(option.label))
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: option.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text('${option.emoji} ${option.label} ${moodCounts[option.label]}',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: option.color)),
                              ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('今日心情', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text('暂无小确幸记录', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          for (final item in left) ...[
                            _MomentCard(item: item),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          for (final item in right) ...[
                            _MomentCard(item: item),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
          },
        );
      },
    );
  }
}

class MomentCardData {
  const MomentCardData({
    this.recordId,
    required this.moodName,
    required this.moodColor,
    required this.moodAccent,
    required this.title,
    required this.content,
    required this.tags,
    required this.recordDate,
    required this.imageUrl,
    required this.imageHeight,
    this.isFavorite = false,
  });

  final String? recordId;
  final String moodName;
  final Color moodColor;
  final Color moodAccent;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime recordDate;
  final String imageUrl;
  final double imageHeight;
  final bool isFavorite;
}

class _MomentCard extends StatelessWidget {
  const _MomentCard({required this.item});

  final MomentCardData item;

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl.trim().isNotEmpty;
    final contentText = item.content.trim().isEmpty ? '暂无内容' : item.content.trim();
    final compactContent = contentText.length > 100 ? '${contentText.substring(0, 100)}…' : contentText;
    return Material(
      color: item.moodColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MomentDetailPage(item: item, recordId: item.recordId),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(height: item.imageHeight, child: AppImage(source: item.imageUrl, fit: BoxFit.cover)),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: item.moodColor, borderRadius: BorderRadius.circular(999)),
                          child: Text(
                            item.moodName,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: item.moodAccent),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          item.isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 14,
                          color: item.isFavorite ? const Color(0xFFF43F5E) : const Color(0xFFD1D5DB),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    const SizedBox(height: 6),
                    Text(
                      hasImage ? contentText : compactContent,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280), height: 1.4),
                      maxLines: hasImage ? 2 : 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    if (item.tags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final tag in item.tags)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                              child: Text('#$tag', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                            ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _formatMomentCardDate(item.recordDate),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
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
}

class MomentDetailPage extends ConsumerStatefulWidget {
  const MomentDetailPage({super.key, this.item, this.recordId});

  final MomentCardData? item;
  final String? recordId;

  @override
  ConsumerState<MomentDetailPage> createState() => _MomentDetailPageState();
}

class _MomentDetailPageState extends ConsumerState<MomentDetailPage> {
  final GlobalKey _shareKey = GlobalKey();

  Future<void> _shareLongImage() async {
    try {
      final boundary = _shareKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // 稍微延迟以确保渲染完成
      await Future.delayed(const Duration(milliseconds: 20));

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/moment_share_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(pngBytes);

      final xFile = XFile(file.path);
      await Share.shareXFiles([xFile], text: '分享我的小确幸');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('分享失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordId = widget.recordId;

    if (recordId == null) {
      return _buildScaffold(
        context,
        imageUrl: widget.item?.imageUrl ?? '',
        moodName: widget.item?.moodName ?? '心情',
        moodColor: widget.item?.moodColor ?? const Color(0xFFF3F4F6),
        moodAccent: widget.item?.moodAccent ?? const Color(0xFF475569),
        title: widget.item?.title ?? '小确幸',
        content: widget.item?.content ?? '',
        tags: widget.item?.tags ?? const [],
        linkChips: const [],
        onEdit: null,
        poiName: '',
        poiAddress: '',
        city: '',
        latitude: null,
        longitude: null,
        recordDate: DateTime.now(),
        images: [],
        isFavorite: false,
        onToggleFavorite: null,
        onDelete: null,
      );
    }

    final detailAsync = ref.watch(momentDetailProvider(recordId));

    return detailAsync.when(
      data: (state) {
        if (state == null) {
          return _buildScaffold(
            context,
            imageUrl: '',
            moodName: '心情',
            moodColor: const Color(0xFFF3F4F6),
            moodAccent: const Color(0xFF475569),
            title: '记录不存在或已删除',
            content: '',
            tags: const [],
            linkChips: const [],
            onEdit: null,
            poiName: '',
            poiAddress: '',
            city: '',
            latitude: null,
            longitude: null,
            recordDate: DateTime.now(),
            images: [],
            isFavorite: false,
            onToggleFavorite: null,
            onDelete: null,
          );
        }

        final record = state.record;
        final images = _parseImages(record.images);
        final imageUrl = images.isEmpty ? '' : images.first;
        final moodAccent = _parseMoodColor(record.moodColor, const Color(0xFF2BCDEE));
        final moodColor = moodAccent.withValues(alpha: 0.12);
        final title = _momentTitle(record);
        final content = _momentContent(record);
        final tags = _parseSceneTags(record.tags);
        final poiName = (record.poiName ?? '').trim().isNotEmpty ? record.poiName!.trim() : (record.city ?? '').trim();
        final poiAddress = (record.poiAddress ?? '').trim();
        final city = (record.city ?? '').trim();
        final latitude = record.latitude;
        final longitude = record.longitude;

        final linkChips = <String>[
          ..._buildLinkLabels('人生目标', state.goalTitles),
          ..._buildLinkLabels('关联旅行', state.travelTitles),
          ..._buildLinkLabels('关联羁绊', state.friendNames),
          ..._buildLinkLabels('关联美食', state.foodTitles),
        ];

        final db = ref.read(appDatabaseProvider);

        return _buildScaffold(
          context,
          imageUrl: imageUrl,
          moodName: record.mood,
          moodColor: moodColor,
          moodAccent: moodAccent,
          title: title,
          content: content,
          tags: tags,
          linkChips: linkChips,
          onEdit: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MomentCreatePage(initialRecord: record)),
            );
          },
          poiName: poiName,
          poiAddress: poiAddress,
          city: city,
          latitude: latitude,
          longitude: longitude,
          recordDate: record.recordDate,
          images: images,
          isFavorite: record.isFavorite,
          onToggleFavorite: () async {
            await db.momentDao.updateFavorite(
              record.id,
              isFavorite: !record.isFavorite,
              now: DateTime.now(),
            );
          },
          onDelete: () async {
            final now = DateTime.now();
            final linkDao = LinkDao(db);
            final links = await linkDao.listLinksForEntity(entityType: 'moment', entityId: record.id);
            for (final link in links) {
              await linkDao.deleteLink(
                sourceType: link.sourceType,
                sourceId: link.sourceId,
                targetType: link.targetType,
                targetId: link.targetId,
                linkType: link.linkType,
                now: now,
              );
            }
            await db.momentDao.deleteById(record.id);
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
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

  Widget _buildScaffold(
    BuildContext context, {
    required String imageUrl,
    required String moodName,
    required Color moodColor,
    required Color moodAccent,
    required String title,
    required String content,
    required List<String> tags,
    required List<String> linkChips,
    required VoidCallback? onEdit,
    required String poiName,
    required String poiAddress,
    required String city,
    required double? latitude,
    required double? longitude,
    required DateTime recordDate,
    required List<String> images,
    required bool isFavorite,
    required VoidCallback? onToggleFavorite,
    required VoidCallback? onDelete,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        title: const SizedBox.shrink(), // 顶部标题留空
        actions: [
          IconButton(
            onPressed: onDelete == null
                ? null
                : () {
                    showModalBottomSheet<void>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (sheetContext) {
                        return _BottomSheetShell(
                          title: '更多操作',
                          actionText: '完成',
                          onAction: () => Navigator.of(sheetContext).pop(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                                title: const Text('删除此条小确幸', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                                subtitle: const Text('删除后将不可恢复，并同步删除万物互联关系', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                                onTap: () async {
                                  Navigator.of(sheetContext).pop();
                                  final confirmed = await showCustomBottomSheet<bool>(
                                    context: context,
                                    builder: (dialogContext) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          const Text(
                                            '确认删除',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            '确定要删除这条小确幸记录吗？',
                                            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () => Navigator.of(dialogContext).pop(false),
                                                  style: OutlinedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  child: const Text('取消', style: TextStyle(fontWeight: FontWeight.w800)),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () => Navigator.of(dialogContext).pop(true),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFFEF4444),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  child: const Text('删除', style: TextStyle(fontWeight: FontWeight.w800)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (confirmed != true) return;
                                  onDelete();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _shareKey,
        child: Container(
          color: const Color(0xFFF6F8F8), // 确保分享时有背景色
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              // 1. 标题
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              const SizedBox(height: 12),

              // 2. 描述内容
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Text(
                  content.isEmpty ? '暂无内容' : content,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF475569), height: 1.6),
                ),
              ),
              const SizedBox(height: 14),

              // 3. 标签
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: moodColor, borderRadius: BorderRadius.circular(999)),
                    child: Text(moodName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: moodAccent)),
                  ),
                  for (final tag in tags)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                      child: Text('#$tag', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // 4. 地理位置
              if (poiName.trim().isNotEmpty || poiAddress.trim().isNotEmpty) ...[
                _InfoRow(
                  iconBackground: const Color(0xFFFFEDD5),
                  icon: Icons.location_on,
                  iconColor: const Color(0xFFFB923C),
                  label: '地理位置',
                  value: poiName.trim().isNotEmpty ? poiName.trim() : poiAddress.trim(),
                  trailingIcon: Icons.chevron_right,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AmapLocationPage.preview(
                          title: title,
                          poiName: poiName.trim(),
                          address: poiAddress.trim(),
                          city: city.trim(),
                          latitude: latitude,
                          longitude: longitude,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
              ],

              // 5. 发布时间
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 6),
                  Text(
                    _formatDateTime(recordDate),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 6. 图片展示（动态调整）
              if (images.isNotEmpty) ...[
                _buildImageGrid(context, images),
                const SizedBox(height: 14),
              ],

              // 7. 万物互联
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('万物互联', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    const SizedBox(height: 10),
                    if (linkChips.isEmpty)
                      const Text('暂无关联内容', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [for (final label in linkChips) _LinkChip(label: label)],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomMenuButton(
                icon: Icons.edit,
                label: '编辑',
                onTap: onEdit,
              ),
              _BottomMenuButton(
                icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                label: '收藏',
                iconColor: isFavorite ? const Color(0xFFF43F5E) : null,
                onTap: onToggleFavorite,
              ),
              _BottomMenuButton(
                icon: Icons.share,
                label: '分享',
                onTap: _shareLongImage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return GestureDetector(
        onTap: () => ImagePreview.show(context, imageUrl: images[0]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: AppImage(source: images[0], fit: BoxFit.cover),
          ),
        ),
      );
    }

    if (images.length == 2) {
      return Row(
        children: images.map((img) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: images.indexOf(img) == 0 ? 8 : 0),
              child: GestureDetector(
                onTap: () => ImagePreview.showGallery(context, images: images, initialIndex: images.indexOf(img)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: AppImage(source: img, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    if (images.length == 3) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => ImagePreview.showGallery(context, images: images, initialIndex: 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: AppImage(source: images[0], fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => ImagePreview.showGallery(context, images: images, initialIndex: 1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: AppImage(source: images[1], fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => ImagePreview.showGallery(context, images: images, initialIndex: 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: AppImage(source: images[2], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // 4张及以上，九宫格布局
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => ImagePreview.showGallery(context, images: images, initialIndex: index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppImage(source: images[index], fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  List<String> _parseImages(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toList(growable: false);
      }
    } catch (_) {}
    return const [];
  }

  Color _parseMoodColor(String? raw, Color fallback) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final hex = raw.replaceAll('#', '');
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return fallback;
    if (hex.length <= 6) {
      return Color(0xFF000000 | value);
    }
    return Color(value);
  }

  String _momentTitle(MomentRecord record) {
    final split = _splitMomentText(record.content);
    return split.title.isEmpty ? '小确幸' : split.title;
  }

  String _momentContent(MomentRecord record) {
    final split = _splitMomentText(record.content);
    return split.content;
  }

  List<String> _buildLinkLabels(String prefix, List<String> names) {
    return [for (final name in names) '$prefix · $name'];
  }
}

class _BottomMenuButton extends StatelessWidget {
  const _BottomMenuButton({
    required this.icon,
    required this.label,
    this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              FocusManager.instance.primaryFocus?.unfocus();
              onTap!();
            },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor ?? const Color(0xFF6B7280), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: iconColor ?? const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MomentCreatePage extends ConsumerStatefulWidget {
  const MomentCreatePage({super.key, this.initialRecord});

  final MomentRecord? initialRecord;

  @override
  ConsumerState<MomentCreatePage> createState() => _MomentCreatePageState();
}

class _MomentCreatePageState extends ConsumerState<MomentCreatePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  DateTime _recordAt = DateTime.now();
  String _locationName = '';
  String _locationAddress = '';
  double? _latitude;
  double? _longitude;

  final Set<String> _selectedTags = {};

  final List<String> _imageUrls = [];

  final Set<String> _linkedFriendIds = {};
  final Set<String> _linkedFoodIds = {};
  final Set<String> _linkedTravelIds = {};
  final Set<String> _linkedGoalIds = {};

  static const _moods = _momentMoodOptions;
  int _selectedMoodIndex = 0;

  @override
  void initState() {
    super.initState();
    final record = widget.initialRecord;
    if (record != null) {
      final split = _splitContent(record.content);
      _titleController.text = split.title;
      _contentController.text = split.content;
      _recordAt = record.recordDate;
      _locationName = (record.poiName ?? '').trim().isNotEmpty ? record.poiName!.trim() : (record.city ?? '').trim();
      _locationAddress = (record.poiAddress ?? '').trim();
      _latitude = record.latitude;
      _longitude = record.longitude;
      _imageUrls
        ..clear()
        ..addAll(_parseMomentImages(record.images));
      final tags = _parseSceneTags(record.tags);
      if (tags.isNotEmpty) {
        _selectedTags.addAll(tags);
      }
      final moodIndex = _moods.indexWhere((m) => m.label == record.mood);
      if (moodIndex >= 0) {
        _selectedMoodIndex = moodIndex;
      }
      _loadInitialLinks(record.id);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String get _locationDisplay {
    final name = _locationName.trim();
    final address = _locationAddress.trim();
    if (name.isEmpty && address.isEmpty) return '';
    if (name.isEmpty) return address;
    if (address.isEmpty) return name;
    return '$name · $address';
  }

  ({String title, String content}) _splitContent(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) {
      return (title: '', content: '');
    }
    final splitIndex = text.indexOf('\n\n');
    if (splitIndex >= 0) {
      final title = text.substring(0, splitIndex).trim();
      final content = text.substring(splitIndex + 2).trim();
      return (title: title, content: content);
    }
    final lines = text.split('\n');
    final title = lines.first.trim();
    final content = lines.skip(1).join('\n').trim();
    return (title: title, content: content);
  }

  Future<void> _loadInitialLinks(String momentId) async {
    final db = ref.read(appDatabaseProvider);
    final links = await db.linkDao.listLinksForEntity(entityType: 'moment', entityId: momentId);
    if (!mounted) return;
    setState(() {
      _linkedFriendIds
        ..clear()
        ..addAll(_collectLinkIds(links, 'moment', momentId, 'friend'));
      _linkedFoodIds
        ..clear()
        ..addAll(_collectLinkIds(links, 'moment', momentId, 'food'));
      _linkedTravelIds
        ..clear()
        ..addAll(_collectLinkIds(links, 'moment', momentId, 'travel'));
      _linkedGoalIds
        ..clear()
        ..addAll(_collectLinkIds(links, 'moment', momentId, 'goal'));
    });
  }

  Set<String> _collectLinkIds(
    List<EntityLink> links,
    String entityType,
    String entityId,
    String targetType,
  ) {
    final result = <String>{};
    for (final link in links) {
      final isSource = link.sourceType == entityType && link.sourceId == entityId;
      final otherType = isSource ? link.targetType : link.sourceType;
      if (otherType != targetType) continue;
      final otherId = isSource ? link.targetId : link.sourceId;
      result.add(otherId);
    }
    return result;
  }

  String _formatRecordAt(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}年 ${two(t.month)}月 ${two(t.day)}日 ${two(t.hour)}:${two(t.minute)}';
  }

  Future<void> _editRecordAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _recordAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('zh', 'CN'),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_recordAt),
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('zh', 'CN'),
          child: child,
        );
      },
    );
    if (time == null) return;
    setState(() {
      _recordAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _editLocation() async {
    final result = await Navigator.of(context).push<AmapLocationPickResult>(
      MaterialPageRoute(
        builder: (_) => AmapLocationPage.pick(
          initialPoiName: _locationName,
          initialAddress: _locationAddress,
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      _locationName = result.poiName;
      _locationAddress = result.address;
      _latitude = result.latitude;
      _longitude = result.longitude;
    });
  }

  Future<void> _addCustomTag(List<String> allTags) async {
    final controller = TextEditingController();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: _BottomSheetShell(
            title: '自定义标签',
            actionText: '添加',
            onAction: () => Navigator.of(context).pop(controller.text.trim()),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '例如：运动 / 电影 / 桌游',
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),
        );
      },
    );
    controller.dispose();
    if (result == null) return;
    final tag = result.replaceAll('#', '').trim();
    if (tag.isEmpty) return;
    await syncTagToModuleConfig('moment', tag);
    setState(() {
      _selectedTags.add(tag);
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

  Future<void> _selectLinkedGoals() async {
    final db = ref.read(appDatabaseProvider);
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StreamBuilder<List<GoalRecord>>(
          stream: db.watchUncompletedYearGoals(),
          builder: (context, snapshot) {
            final goals = snapshot.data ?? const <GoalRecord>[];
            return _MultiSelectBottomSheet(
              title: '关联人生目标',
              items: goals
                  .map(
                    (g) => _SelectItem(
                      id: g.id,
                      title: g.title,
                      leading: const _IconSquare(color: Color(0xFFF3E8FF), icon: Icons.outlined_flag, iconColor: Color(0xFFA855F7)),
                    ),
                  )
                  .toList(growable: false),
              initialSelected: _linkedGoalIds,
            );
          },
        );
      },
    );
    if (selected == null) return;
    setState(() {
      _linkedGoalIds
        ..clear()
        ..addAll(selected);
    });
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先填写标题')));
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final existing = widget.initialRecord;
    final String momentId = existing?.id ?? ref.read(uuidProvider).v4();
    final createdAt = existing?.createdAt ?? now;

    final content = _contentController.text.trim();
    final mergedContent = content.isEmpty ? title : '$title\n\n$content';

    final mood = _moods[_selectedMoodIndex];
    final selectedTags = _selectedTags.toList();
    final tag = _encodeSceneTags(selectedTags);
    final locationName = _locationName.trim();
    final locationAddress = _locationAddress.trim();
    final location = locationName.isNotEmpty ? locationName : locationAddress;
    final recordDate = _recordAt;
    final eventRecordDate = DateTime(recordDate.year, recordDate.month, recordDate.day);

    await db.momentDao.upsert(
      MomentRecordsCompanion.insert(
        id: momentId,
        content: Value(mergedContent.isEmpty ? null : mergedContent),
        images: Value(_imageUrls.isEmpty ? null : jsonEncode(_imageUrls)),
        mood: mood.label,
        moodColor: Value('#${mood.color.value.toRadixString(16).padLeft(8, '0')}'),
        tags: Value(tag),
        poiName: Value(locationName.isEmpty ? null : locationName),
        poiAddress: Value(locationAddress.isEmpty ? null : locationAddress),
        city: Value(location.isEmpty ? null : location),
        latitude: Value(_latitude),
        longitude: Value(_longitude),
        recordDate: recordDate,
        createdAt: createdAt,
        updatedAt: now,
      ),
    );

    await db.into(db.timelineEvents).insertOnConflictUpdate(
          TimelineEventsCompanion.insert(
            id: momentId,
            title: title,
            eventType: 'moment',
            startAt: Value(recordDate),
            endAt: const Value(null),
            note: Value(content.isEmpty ? null : content),
            poiName: Value(locationName.isEmpty ? null : locationName),
            poiAddress: Value(locationAddress.isEmpty ? null : locationAddress),
            latitude: Value(_latitude),
            longitude: Value(_longitude),
            recordDate: eventRecordDate,
            createdAt: createdAt,
            updatedAt: now,
          ),
        );

    if (existing != null) {
      final links = await db.linkDao.listLinksForEntity(entityType: 'moment', entityId: momentId);
      for (final link in links) {
        await db.linkDao.deleteLink(
          sourceType: link.sourceType,
          sourceId: link.sourceId,
          targetType: link.targetType,
          targetId: link.targetId,
          now: now,
        );
      }
    }

    for (final id in _linkedFriendIds) {
      await db.linkDao.createLink(
        sourceType: 'moment',
        sourceId: momentId,
        targetType: 'friend',
        targetId: id,
        now: now,
      );
    }
    for (final id in _linkedFoodIds) {
      await db.linkDao.createLink(
        sourceType: 'moment',
        sourceId: momentId,
        targetType: 'food',
        targetId: id,
        now: now,
      );
    }
    for (final id in _linkedTravelIds) {
      await db.linkDao.createLink(
        sourceType: 'moment',
        sourceId: momentId,
        targetType: 'travel',
        targetId: id,
        now: now,
      );
    }
    for (final id in _linkedGoalIds) {
      await db.linkDao.createLink(
        sourceType: 'moment',
        sourceId: momentId,
        targetType: 'goal',
        targetId: id,
        now: now,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _addPlaceholderImage() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;
    final stored = await _persistImages(files);
    if (stored.isEmpty) return;
    setState(() => _imageUrls.addAll(stored));
  }

  Future<List<String>> _persistImages(List<XFile> files) async {
    return persistImageFiles(files, folder: 'moment', prefix: 'moment');
  }

  void _removeImageAt(int index) {
    setState(() => _imageUrls.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialRecord != null;
    final mood = _moods[_selectedMoodIndex];
    final configAsync = ref.watch(moduleManagementConfigProvider);

    return configAsync.when(
      data: (config) {
        final availableTags = getTagsForModule(config, 'moment');
        final allTags = {...availableTags, ..._selectedTags}.toList();
        final module = config.moduleOf('moment');
        final tagColorMap = <String, String?>{};
        for (final t in module.tags) {
          tagColorMap[t.name] = t.color;
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8F8),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _CreateTopBar(
                  title: isEditing ? '编辑小确幸' : '记录小确幸',
                  onCancel: () => Navigator.of(context).maybePop(),
                  actionText: isEditing ? '保存' : '发布',
                  onAction: _publish,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _titleController,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, height: 1.2),
                              decoration: const InputDecoration(
                                hintText: '给这份小确幸起个标题...',
                                border: InputBorder.none,
                              ),
                            ),
                            const Divider(height: 18, color: Color(0xFFF3F4F6)),
                            TextField(
                              controller: _contentController,
                              minLines: 5,
                              maxLines: 12,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.45, color: Color(0xFF334155)),
                              decoration: const InputDecoration(
                                hintText: '记录此刻的美好瞬间，哪怕是微不足道的小事...',
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final tag = allTags[index];
                            final selected = _selectedTags.contains(tag);
                            final tagColorHex = tagColorMap[tag];
                            final colors = TagColorUtils.getTagColors(tagColorHex, selected);
                            return InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () {
                                setState(() {
                                  if (selected) {
                                    _selectedTags.remove(tag);
                                  } else {
                                    _selectedTags.add(tag);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: colors.background,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Text(
                                  '# $tag',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: colors.text,
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox(width: 10),
                          itemCount: allTags.length,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => _addCustomTag(allTags),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF9800),
                            side: BorderSide(color: const Color(0xFFFF9800).withValues(alpha: 0.35), style: BorderStyle.solid),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('自定义标签', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: _imageUrls.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _imageUrls.length) {
                            return _PhotoAddTile(onTap: _addPlaceholderImage);
                          }
                          return _PhotoTile(
                            url: _imageUrls[index],
                            onRemove: () => _removeImageAt(index),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      Container(height: 1, color: const Color(0xFFE5E7EB)),
                      const SizedBox(height: 16),
                      Text('此刻心情', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF6B7280).withValues(alpha: 0.9))),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 78,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final option = _moods[index];
                            final selected = index == _selectedMoodIndex;
                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => setState(() => _selectedMoodIndex = index),
                              child: SizedBox(
                                width: 60,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: selected ? option.color.withValues(alpha: 0.12) : Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: selected ? option.color.withValues(alpha: 0.6) : const Color(0xFFF3F4F6)),
                                        boxShadow: selected
                                            ? [BoxShadow(color: option.color.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 6))]
                                            : const [],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(option.emoji, style: const TextStyle(fontSize: 20)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      option.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: selected ? option.color : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemCount: _moods.length,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        iconBackground: mood.color.withValues(alpha: 0.12),
                        icon: Icons.calendar_today,
                        iconColor: mood.color,
                        label: '记录时间',
                        value: _formatRecordAt(_recordAt),
                        trailingIcon: Icons.edit,
                        onTap: _editRecordAt,
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        iconBackground: const Color(0xFFFFEDD5),
                        icon: Icons.location_on,
                        iconColor: const Color(0xFFFB923C),
                        label: '地理位置',
                        value: _locationDisplay.isEmpty ? '添加位置信息' : _locationDisplay,
                        trailingIcon: Icons.chevron_right,
                        onTap: _editLocation,
                      ),
                      const SizedBox(height: 18),
                      Text('万物互联', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF6B7280).withValues(alpha: 0.9))),
                      const SizedBox(height: 10),
                      _UniversalLinkCard(
                        title: '关联人生目标',
                        subtitle: _linkedGoalIds.isEmpty ? '让小确幸充满意义' : '已选 ${_linkedGoalIds.length} 条',
                        icon: Icons.flag,
                        gradientStart: const Color(0xFF2BCDEE),
                        gradientEnd: const Color(0xFF22D3EE),
                        trailingIcon: _linkedGoalIds.isEmpty ? Icons.add_circle : Icons.check_circle,
                        onTap: _selectLinkedGoals,
                      ),
                      const SizedBox(height: 10),
                      _UniversalLinkCard(
                        title: '关联旅行',
                        subtitle: _linkedTravelIds.isEmpty ? '记录旅途中的点滴' : '已选 ${_linkedTravelIds.length} 条',
                        icon: Icons.airplanemode_active,
                        gradientStart: const Color(0xFF34D399),
                        gradientEnd: const Color(0xFF14B8A6),
                        trailingIcon: _linkedTravelIds.isEmpty ? Icons.add_circle : Icons.check_circle,
                        onTap: _selectLinkedTravels,
                      ),
                      const SizedBox(height: 10),
                      _UniversalLinkCard(
                        title: '关联羁绊',
                        subtitle: _linkedFriendIds.isEmpty ? '与朋友共享此刻' : '已选 ${_linkedFriendIds.length} 人',
                        icon: Icons.diversity_1,
                        gradientStart: const Color(0xFFFB7185),
                        gradientEnd: const Color(0xFFEC4899),
                        trailingIcon: _linkedFriendIds.isEmpty ? Icons.add_circle : Icons.check_circle,
                        onTap: _selectLinkedFriends,
                      ),
                      const SizedBox(height: 10),
                      _UniversalLinkCard(
                        title: '关联美食',
                        subtitle: _linkedFoodIds.isEmpty ? '记录舌尖上的幸福' : '已选 ${_linkedFoodIds.length} 条',
                        icon: Icons.restaurant,
                        gradientStart: const Color(0xFFFBBF24),
                        gradientEnd: const Color(0xFFF97316),
                        trailingIcon: _linkedFoodIds.isEmpty ? Icons.add_circle : Icons.check_circle,
                        onTap: _selectLinkedFoods,
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
}

class _MoodOption {
  const _MoodOption({required this.label, required this.emoji, required this.color});

  final String label;
  final String emoji;
  final Color color;
}

class _CreateTopBar extends StatelessWidget {
  const _CreateTopBar({
    required this.title,
    required this.onCancel,
    required this.actionText,
    required this.onAction,
  });

  final String title;
  final VoidCallback onCancel;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280), textStyle: const TextStyle(fontWeight: FontWeight.w800)),
            child: const Text('取消'),
          ),
          Expanded(
            child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          ),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2BCDEE),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.url, required this.onRemove});

  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppImage(source: url, fit: BoxFit.cover),
          Positioned(
            right: 6,
            top: 6,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(999)),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoAddTile extends StatelessWidget {
  const _PhotoAddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2BCDEE).withValues(alpha: 0.25), width: 2, style: BorderStyle.solid),
        ),
        child: const Center(child: Icon(Icons.add, color: Color(0xFF2BCDEE))),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.iconBackground,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.trailingIcon,
    required this.onTap,
  });

  final Color iconBackground;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final IconData trailingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                ],
              ),
            ),
            Icon(trailingIcon, size: 18, color: const Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

class _UniversalLinkCard extends StatelessWidget {
  const _UniversalLinkCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
    this.trailingIcon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final trailingColor = enabled ? const Color(0xFF2BCDEE) : const Color(0xFF9CA3AF);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(colors: [gradientStart, gradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: gradientStart.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 10))],
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            Icon(trailingIcon ?? Icons.chevron_right, color: trailingColor),
          ],
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

class _FilterResult {
  const _FilterResult({
    required this.dateIndex,
    required this.customRange,
    required this.friendIds,
    this.filterFavorite = false,
  });

  final int dateIndex;
  final DateTimeRange? customRange;
  final Set<String> friendIds;
  final bool filterFavorite;
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet({
    required this.initialDateIndex,
    required this.initialCustomRange,
    required this.initialFriendIds,
    required this.friendsStream,
    this.initialFilterFavorite = false,
  });

  final int initialDateIndex;
  final DateTimeRange? initialCustomRange;
  final Set<String> initialFriendIds;
  final Stream<List<FriendRecord>> friendsStream;
  final bool initialFilterFavorite;

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  static const _dateOptions = ['不限', '今日', '近7天', '近30天', '自定义'];

  late int _dateIndex;
  DateTimeRange? _customRange;
  late Set<String> _selectedFriendIds;
  late bool _filterFavorite;

  @override
  void initState() {
    super.initState();
    _dateIndex = widget.initialDateIndex;
    _customRange = widget.initialCustomRange;
    _selectedFriendIds = {...widget.initialFriendIds};
    _filterFavorite = widget.initialFilterFavorite;
  }

  String _formatDate(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${date.year}.${two(date.month)}.${two(date.day)}';
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final initial = _customRange ?? DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('zh', 'CN'),
    );
    if (picked == null) return;
    setState(() {
      _customRange = picked;
      _dateIndex = 4;
    });
  }

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
                    const Expanded(
                      child: Text('筛选', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(
                        _FilterResult(
                          dateIndex: _dateIndex,
                          customRange: _customRange,
                          friendIds: _selectedFriendIds,
                          filterFavorite: _filterFavorite,
                        ),
                      ),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF2BCDEE), textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                      child: const Text('完成'),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('日期', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (var i = 0; i < _dateOptions.length; i++)
                            _FilterOptionChip(
                              label: _dateOptions[i],
                              selected: i == _dateIndex,
                              onTap: () async {
                                if (i == 4) {
                                  await _pickCustomRange();
                                } else {
                                  setState(() => _dateIndex = i);
                                }
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_dateIndex == 4)
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _pickCustomRange,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Text(
                              _customRange == null
                                  ? '请选择日期范围'
                                  : '${_formatDate(_customRange!.start)} - ${_formatDate(_customRange!.end)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _customRange == null ? const Color(0xFF94A3B8) : const Color(0xFF111827),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      const Text('羁绊', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      const SizedBox(height: 10),
                      StreamBuilder<List<FriendRecord>>(
                        stream: widget.friendsStream,
                        builder: (context, snapshot) {
                          final friends = snapshot.data ?? const <FriendRecord>[];
                          if (friends.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Text('暂无朋友档案', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: friends.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final friend = friends[index];
                              final checked = _selectedFriendIds.contains(friend.id);
                              return _FilterFriendTile(
                                name: friend.name,
                                checked: checked,
                                onTap: () {
                                  setState(() {
                                    if (checked) {
                                      _selectedFriendIds.remove(friend.id);
                                    } else {
                                      _selectedFriendIds.add(friend.id);
                                    }
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('收藏', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      const SizedBox(height: 10),
                      _FilterOptionChip(
                        label: '仅收藏',
                        selected: _filterFavorite,
                        onTap: () => setState(() => _filterFavorite = !_filterFavorite),
                      ),
                    ],
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

class _FilterOptionChip extends StatelessWidget {
  const _FilterOptionChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2BCDEE).withValues(alpha: 0.12) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? const Color(0xFF2BCDEE).withValues(alpha: 0.3) : const Color(0xFFF3F4F6)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: selected ? const Color(0xFF2BCDEE) : const Color(0xFF64748B)),
        ),
      ),
    );
  }
}

class _FilterFriendTile extends StatelessWidget {
  const _FilterFriendTile({required this.name, required this.checked, required this.onTap});

  final String name;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter = trimmed.isEmpty ? '?' : trimmed.characters.first;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: checked ? const Color(0xFF2BCDEE).withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: checked ? const Color(0xFF2BCDEE).withValues(alpha: 0.22) : const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE5E7EB),
              child: Text(letter, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827)))),
            Icon(checked ? Icons.check_circle : Icons.radio_button_unchecked, color: checked ? const Color(0xFF2BCDEE) : const Color(0xFFCBD5E1)),
          ],
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
