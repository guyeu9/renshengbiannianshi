import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:amap_flutter/amap_flutter.dart' as amap;

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/utils/media_storage.dart';

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

String _momentTitleFromRecord(MomentRecord record) {
  final content = (record.content ?? '').trim();
  if (content.isEmpty) return '小确幸';
  final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
  return lines.isEmpty ? '小确幸' : lines.first.trim();
}

String _momentContentFromRecord(MomentRecord record) {
  final content = (record.content ?? '').trim();
  if (content.isEmpty) return '';
  return content;
}

class MomentPage extends StatefulWidget {
  const MomentPage({super.key});

  @override
  State<MomentPage> createState() => _MomentPageState();
}

class _MomentPageState extends State<MomentPage> {
  var _filterDateIndex = 0;
  DateTimeRange? _filterCustomRange;
  Set<String> _filterFriendIds = {};

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
            _MomentHeader(onFilterTap: _openFilterSheet),
            const Expanded(child: _MomentHomeBody()),
          ],
        ),
      ),
    );
  }
}

class _MomentHeader extends StatelessWidget {
  const _MomentHeader({required this.onFilterTap});

  final VoidCallback onFilterTap;

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
                          '搜索心情、标签、地理位置..',
                          style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _HeaderCircle(icon: Icons.tune, onTap: onFilterTap),
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
              children: const [
                _MoodChip(active: true, label: '全部', color: Color(0xFF2BCDEE)),
                SizedBox(width: 10),
                _MoodChip(active: false, label: '开心', color: Color(0xFFF59E0B)),
                SizedBox(width: 10),
                _MoodChip(active: false, label: '平静', color: Color(0xFF22C55E)),
                SizedBox(width: 10),
                _MoodChip(active: false, label: '感动', color: Color(0xFFA855F7)),
                SizedBox(width: 10),
                _MoodChip(active: false, label: '治愈', color: Color(0xFF60A5FA)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCircle extends StatelessWidget {
  const _HeaderCircle({required this.icon, required this.onTap, this.iconColor});

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
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: iconColor ?? const Color(0xFF6B7280), size: 22),
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.active, required this.label, required this.color});

  final bool active;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
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

class _MomentHomeBody extends ConsumerWidget {
  const _MomentHomeBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder<List<MomentRecord>>(
      stream: db.momentDao.watchAllActive(),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <MomentRecord>[];
        final items = <MomentCardData>[];
        for (var i = 0; i < records.length; i++) {
          final record = records[i];
          final images = _parseMomentImages(record.images);
          final accent = _parseMomentMoodColor(record.moodColor, const Color(0xFF2BCDEE));
          final title = _momentTitleFromRecord(record);
          final content = _momentContentFromRecord(record);
          items.add(
            MomentCardData(
              recordId: record.id,
              moodName: record.mood,
              moodColor: accent.withValues(alpha: 0.12),
              moodAccent: accent,
              title: title,
              content: content,
              imageUrl: images.isEmpty ? '' : images.first,
              imageHeight: 180 + (i % 3) * 20,
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
              Row(
                children: const [
                  Expanded(
                    child: Text('今日心情', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  ),
                  Text('年度心情', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2BCDEE))),
                ],
              ),
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
    required this.imageUrl,
    required this.imageHeight,
  });

  final String? recordId;
  final String moodName;
  final Color moodColor;
  final Color moodAccent;
  final String title;
  final String content;
  final String imageUrl;
  final double imageHeight;
}

class _MomentCard extends StatelessWidget {
  const _MomentCard({required this.item});

  final MomentCardData item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
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
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(height: item.imageHeight, child: _buildLocalImage(item.imageUrl, fit: BoxFit.cover)),
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
                        const Icon(Icons.favorite, size: 14, color: Color(0xFFF43F5E)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    const SizedBox(height: 6),
                    Text(
                      item.content,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280), height: 1.4),
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
}

class MomentDetailPage extends ConsumerWidget {
  const MomentDetailPage({super.key, this.item, this.recordId});

  final MomentCardData? item;
  final String? recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    if (recordId == null) {
      return _buildScaffold(
        context,
        imageUrl: item?.imageUrl ?? '',
        moodName: item?.moodName ?? '心情',
        moodColor: item?.moodColor ?? const Color(0xFFF3F4F6),
        moodAccent: item?.moodAccent ?? const Color(0xFF475569),
        title: item?.title ?? '小确幸',
        content: item?.content ?? '',
        linkChips: const [],
        onEdit: null,
        locationText: '',
        latitude: null,
        longitude: null,
      );
    }
    return StreamBuilder<MomentRecord?>(
      stream: db.momentDao.watchById(recordId!),
      builder: (context, snapshot) {
        final record = snapshot.data;
        if (record == null) {
          return _buildScaffold(
            context,
            imageUrl: '',
            moodName: '心情',
            moodColor: const Color(0xFFF3F4F6),
            moodAccent: const Color(0xFF475569),
            title: '记录不存在或已删除',
            content: '',
            linkChips: const [],
            onEdit: null,
            locationText: '',
            latitude: null,
            longitude: null,
          );
        }
        final images = _parseImages(record.images);
        final imageUrl = images.isEmpty ? '' : images.first;
        final moodAccent = _parseMoodColor(record.moodColor, const Color(0xFF2BCDEE));
        final moodColor = moodAccent.withValues(alpha: 0.12);
        final title = _momentTitle(record);
        final content = _momentContent(record);
        final locationText = (record.city ?? '').trim();
        final latitude = record.latitude;
        final longitude = record.longitude;
        return StreamBuilder<List<EntityLink>>(
          stream: db.linkDao.watchLinksForEntity(entityType: 'moment', entityId: record.id),
          builder: (context, linkSnapshot) {
            final linkIds = _groupLinkIds(linkSnapshot.data ?? const <EntityLink>[], 'moment', record.id);
            return StreamBuilder<List<FriendRecord>>(
              stream: db.friendDao.watchAllActive(),
              builder: (context, friendSnapshot) {
                final friends = friendSnapshot.data ?? const <FriendRecord>[];
                final friendLabels = _buildLinkLabels(
                  '关联羁绊',
                  _mapNames(linkIds['friend'] ?? const <String>[], {for (final f in friends) f.id: f.name}),
                );
                return StreamBuilder<List<FoodRecord>>(
                  stream: db.foodDao.watchAllActive(),
                  builder: (context, foodSnapshot) {
                    final foods = foodSnapshot.data ?? const <FoodRecord>[];
                    final foodLabels = _buildLinkLabels(
                      '关联美食',
                      _mapNames(linkIds['food'] ?? const <String>[], {for (final f in foods) f.id: f.title}),
                    );
                    return StreamBuilder<List<TravelRecord>>(
                      stream: db.watchAllActiveTravelRecords(),
                      builder: (context, travelSnapshot) {
                        final travels = travelSnapshot.data ?? const <TravelRecord>[];
                        final travelLabels = _buildLinkLabels(
                          '关联旅行',
                          _mapNames(linkIds['travel'] ?? const <String>[], {for (final t in travels) t.id: _travelTitle(t)}),
                        );
                        return StreamBuilder<List<TimelineEvent>>(
                          stream: (db.select(db.timelineEvents)
                                ..where((t) => t.isDeleted.equals(false))
                                ..where((t) => t.eventType.equals('goal')))
                              .watch(),
                          builder: (context, goalSnapshot) {
                            final goals = goalSnapshot.data ?? const <TimelineEvent>[];
                            final goalLabels = _buildLinkLabels(
                              '人生目标',
                              _mapNames(linkIds['goal'] ?? const <String>[], {for (final g in goals) g.id: g.title}),
                            );
                            final linkChips = [
                              ...goalLabels,
                              ...travelLabels,
                              ...friendLabels,
                              ...foodLabels,
                            ];
                            return _buildScaffold(
                              context,
                              imageUrl: imageUrl,
                              moodName: record.mood,
                              moodColor: moodColor,
                              moodAccent: moodAccent,
                              title: title,
                              content: content,
                              linkChips: linkChips,
                              onEdit: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => MomentCreatePage(initialRecord: record)),
                                );
                              },
                              locationText: locationText,
                              latitude: latitude,
                              longitude: longitude,
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

  Widget _buildScaffold(
    BuildContext context, {
    required String imageUrl,
    required String moodName,
    required Color moodColor,
    required Color moodAccent,
    required String title,
    required String content,
    required List<String> linkChips,
    required VoidCallback? onEdit,
    required String locationText,
    required double? latitude,
    required double? longitude,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        title: const Text('小确幸详情', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          if (onEdit != null) IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: imageUrl.isEmpty
                  ? Container(color: const Color(0xFFF3F4F6))
                  : _buildLocalImage(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: moodColor, borderRadius: BorderRadius.circular(999)),
                child: Text(moodName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: moodAccent)),
              ),
              const Spacer(),
              const Icon(Icons.favorite, color: Color(0xFFF43F5E)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
            child: Text(
              content.isEmpty ? '暂无内容' : content,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569), height: 1.5),
            ),
          ),
          if (locationText.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoRow(
              iconBackground: const Color(0xFFFFEDD5),
              icon: Icons.location_on,
              iconColor: const Color(0xFFFB923C),
              label: '地理位置',
              value: locationText.trim(),
              trailingIcon: Icons.chevron_right,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _MomentMapPage.preview(
                      title: title,
                      poiName: locationText.trim(),
                      address: '',
                      latitude: latitude,
                      longitude: longitude,
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
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
    );
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
    final content = (record.content ?? '').trim();
    if (content.isEmpty) return '小确幸';
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    return lines.isEmpty ? '小确幸' : lines.first.trim();
  }

  String _momentContent(MomentRecord record) {
    final content = (record.content ?? '').trim();
    if (content.isEmpty) return '';
    return content;
  }

  Map<String, List<String>> _groupLinkIds(List<EntityLink> links, String entityType, String entityId) {
    final grouped = <String, List<String>>{};
    for (final link in links) {
      final isSource = link.sourceType == entityType && link.sourceId == entityId;
      final otherType = isSource ? link.targetType : link.sourceType;
      final otherId = isSource ? link.targetId : link.sourceId;
      final list = grouped.putIfAbsent(otherType, () => <String>[]);
      if (!list.contains(otherId)) {
        list.add(otherId);
      }
    }
    return grouped;
  }

  List<String> _mapNames(List<String> ids, Map<String, String> nameById) {
    return [for (final id in ids) if (nameById.containsKey(id)) nameById[id]!];
  }

  List<String> _buildLinkLabels(String prefix, List<String> names) {
    return [for (final name in names) '$prefix · $name'];
  }

  String _travelTitle(TravelRecord record) {
    final title = record.title?.trim() ?? '';
    if (title.isNotEmpty) return title;
    final destination = record.destination?.trim() ?? '';
    return destination.isEmpty ? '旅行记录' : destination;
  }
}

class MomentCreatePage extends ConsumerStatefulWidget {
  const MomentCreatePage({super.key, this.initialRecord});

  final MomentRecord? initialRecord;

  @override
  ConsumerState<MomentCreatePage> createState() => _MomentCreatePageState();
}

class _MomentCreatePageState extends ConsumerState<MomentCreatePage> {
  static const _uuid = Uuid();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  DateTime _recordAt = DateTime.now();
  String _locationName = '';
  String _locationAddress = '';
  double? _latitude;
  double? _longitude;

  final List<String> _tags = ['读书', '搬家', '桌面布置', '电影'];
  int _selectedTagIndex = 0;

  final List<String> _imageUrls = [];

  final Set<String> _linkedFriendIds = {};
  final Set<String> _linkedFoodIds = {};
  final Set<String> _linkedTravelIds = {};
  final Set<String> _linkedGoalIds = {};

  static const _moods = <_MoodOption>[
    _MoodOption(label: '开心', emoji: '😊', color: Color(0xFF2BCDEE)),
    _MoodOption(label: '平静', emoji: '😌', color: Color(0xFF22C55E)),
    _MoodOption(label: '治愈', emoji: '🌿', color: Color(0xFF60A5FA)),
    _MoodOption(label: '思考', emoji: '🤔', color: Color(0xFFA855F7)),
    _MoodOption(label: '放空', emoji: '☁️', color: Color(0xFF64748B)),
  ];
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
      _locationName = (record.city ?? '').trim();
      _latitude = record.latitude;
      _longitude = record.longitude;
      _imageUrls
        ..clear()
        ..addAll(_parseMomentImages(record.images));
      final tag = (record.sceneTag ?? '').trim();
      if (tag.isNotEmpty) {
        if (!_tags.contains(tag)) {
          _tags.insert(0, tag);
        }
        _selectedTagIndex = _tags.indexOf(tag).clamp(0, _tags.length - 1);
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
    final result = await Navigator.of(context).push<_MomentMapPickResult>(
      MaterialPageRoute(
        builder: (_) => _MomentMapPage.pick(
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

  Future<void> _addCustomTag() async {
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
    setState(() {
      _tags.insert(0, tag);
      _selectedTagIndex = 0;
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

  Future<void> _selectLinkedGoals() async {
    final db = ref.read(appDatabaseProvider);
    final goalsStream = (db.select(db.timelineEvents)
          ..where((t) => t.eventType.equals('goal'))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StreamBuilder<List<TimelineEvent>>(
          stream: goalsStream,
          builder: (context, snapshot) {
            final goals = snapshot.data ?? const <TimelineEvent>[];
            return _MultiSelectBottomSheet(
              title: '关联人生目标',
              items: goals
                  .map(
                    (g) => _SelectItem(
                      id: g.id,
                      title: g.title,
                      leading: const _IconSquare(color: Color(0xFFE0F2FE), icon: Icons.flag, iconColor: Color(0xFF0284C7)),
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
    final momentId = existing?.id ?? _uuid.v4();
    final createdAt = existing?.createdAt ?? now;

    final content = _contentController.text.trim();
    final mergedContent = content.isEmpty ? title : '$title\n\n$content';

    final mood = _moods[_selectedMoodIndex];
    final tag = _tags.isEmpty ? null : _tags[_selectedTagIndex.clamp(0, _tags.length - 1)];
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
        moodColor: Value('#${mood.color.toARGB32().toRadixString(16).padLeft(8, '0')}'),
        sceneTag: Value(tag?.trim().isEmpty == true ? null : tag),
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
                        final selected = index == _selectedTagIndex;
                        return InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => setState(() => _selectedTagIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF2BCDEE).withValues(alpha: 0.12) : Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: selected ? const Color(0xFF2BCDEE).withValues(alpha: 0.25) : const Color(0xFFF3F4F6)),
                            ),
                            child: Text(
                              '# ${_tags[index]}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: selected ? const Color(0xFF2BCDEE) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemCount: _tags.length,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _addCustomTag,
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
                    icon: Icons.flight_takeoff,
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
  }
}

class _MomentMapPickResult {
  const _MomentMapPickResult({
    required this.poiName,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String poiName;
  final String address;
  final double? latitude;
  final double? longitude;
}

enum _MomentMapPageMode { pick, preview }

class _MomentMapPoi {
  const _MomentMapPoi({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
}

class _MomentMapPage extends StatefulWidget {
  const _MomentMapPage.pick({
    required this.initialPoiName,
    required this.initialAddress,
    required this.initialLatitude,
    required this.initialLongitude,
  })  : mode = _MomentMapPageMode.pick,
        title = null,
        poiName = '',
        address = '',
        latitude = null,
        longitude = null;

  const _MomentMapPage.preview({
    required this.title,
    required this.poiName,
    required this.address,
    required this.latitude,
    required this.longitude,
  })  : mode = _MomentMapPageMode.preview,
        initialPoiName = '',
        initialAddress = '',
        initialLatitude = null,
        initialLongitude = null;

  final _MomentMapPageMode mode;

  final String? title;
  final String poiName;
  final String address;
  final double? latitude;
  final double? longitude;

  final String initialPoiName;
  final String initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<_MomentMapPage> createState() => _MomentMapPageState();
}

class _MomentMapPageState extends State<_MomentMapPage> {
  static const String _amapAndroidKey = String.fromEnvironment('AMAP_ANDROID_KEY', defaultValue: '');
  static const String _amapIosKey = String.fromEnvironment('AMAP_IOS_KEY', defaultValue: '');
  static const String _amapWebKey = String.fromEnvironment('AMAP_WEB_KEY', defaultValue: '76e66f23c7045fbe296f9aa9b7e7f12c');

  static const _primary = Color(0xFF2BCDEE);

  final _searchController = TextEditingController();
  final _poiNameController = TextEditingController();
  final _addressController = TextEditingController();

  var _loading = false;
  var _errorText = '';
  var _pois = <_MomentMapPoi>[];

  String get _pickedPoiName => _poiNameController.text.trim();
  String get _pickedAddress => _addressController.text.trim();

  double? _pickedLatitude;
  double? _pickedLongitude;

  amap.AMapController? _mapController;
  var _sdkReady = false;
  var _sdkErrorText = '';

  bool get _hasMapKey {
    if (kIsWeb) return _amapWebKey.trim().isNotEmpty;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _amapAndroidKey.trim().isNotEmpty;
      case TargetPlatform.iOS:
        return _amapIosKey.trim().isNotEmpty;
      default:
        return _amapAndroidKey.trim().isNotEmpty || _amapIosKey.trim().isNotEmpty;
    }
  }

  bool get _hasWebKey => _amapWebKey.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.mode == _MomentMapPageMode.preview) {
      _poiNameController.text = widget.poiName;
      _addressController.text = widget.address;
      _pickedLatitude = widget.latitude;
      _pickedLongitude = widget.longitude;
      _searchController.text = widget.poiName.trim().isNotEmpty ? widget.poiName.trim() : widget.address.trim();
    } else {
      _poiNameController.text = widget.initialPoiName;
      _addressController.text = widget.initialAddress;
      _pickedLatitude = widget.initialLatitude;
      _pickedLongitude = widget.initialLongitude;
      _searchController.text = widget.initialPoiName.trim().isNotEmpty ? widget.initialPoiName.trim() : widget.initialAddress.trim();
    }

    _initAmapSdk();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _poiNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _initAmapSdk() async {
    if (!_hasMapKey) return;
    try {
      await amap.AMapFlutter.init(
        apiKey: amap.ApiKey(
          iosKey: _amapIosKey,
          androidKey: _amapAndroidKey,
          webKey: _amapWebKey,
        ),
        agreePrivacy: true,
      );
      if (!mounted) return;
      setState(() {
        _sdkReady = true;
        _sdkErrorText = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sdkReady = false;
        _sdkErrorText = '$e';
      });
    }
  }

  void _syncMarkerAndCamera() {
    final controller = _mapController;
    if (controller == null) return;
    controller.removeMarker('picked');
    final lat = _pickedLatitude;
    final lng = _pickedLongitude;
    if (lat == null || lng == null) return;
    controller.addMarker(
      amap.Marker(
        id: 'picked',
        position: amap.Position(latitude: lat, longitude: lng),
      ),
    );
    controller.moveCamera(
      amap.CameraPosition(
        position: amap.Position(latitude: lat, longitude: lng),
        zoom: 15,
      ),
      const Duration(milliseconds: 220),
    );
  }

  Future<void> _searchPoi() async {
    if (!_hasWebKey) {
      setState(() {
        _errorText = '未配置高德 Web Key（AMAP_WEB_KEY）';
        _pois = [];
      });
      return;
    }
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _errorText = '请输入地点关键词';
        _pois = [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorText = '';
      _pois = [];
    });

    try {
      final uri = Uri.https('restapi.amap.com', '/v3/place/text', {
        'keywords': keyword,
        'offset': '20',
        'page': '1',
        'extensions': 'base',
        'key': _amapWebKey,
      });
      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close(force: true);

      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw const FormatException('invalid json');
      }
      final status = '${decoded['status'] ?? ''}'.trim();
      if (status != '1') {
        final info = '${decoded['info'] ?? '搜索失败'}';
        throw Exception(info);
      }
      final poisRaw = decoded['pois'];
      final next = <_MomentMapPoi>[];
      if (poisRaw is List) {
        for (final p in poisRaw) {
          if (p is! Map) continue;
          final name = '${p['name'] ?? ''}'.trim();
          final address = '${p['address'] ?? ''}'.trim();
          final location = '${p['location'] ?? ''}'.trim();
          double? lng;
          double? lat;
          if (location.contains(',')) {
            final parts = location.split(',');
            if (parts.length >= 2) {
              lng = double.tryParse(parts[0].trim());
              lat = double.tryParse(parts[1].trim());
            }
          }
          if (name.isEmpty && address.isEmpty) continue;
          next.add(_MomentMapPoi(name: name, address: address, latitude: lat, longitude: lng));
        }
      }

      if (!mounted) return;
      setState(() {
        _pois = next;
        if (next.isEmpty) _errorText = '未找到结果';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = '搜索失败：$e';
        _pois = [];
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _showManualEditSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _BottomSheetShell(
          title: '手动填写地点',
          actionText: '完成',
          onAction: () {
            Navigator.of(sheetContext).pop();
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _poiNameController,
                  decoration: InputDecoration(
                    labelText: '地点名称',
                    hintText: '例如：海底捞（中关村店）',
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: '地址',
                    hintText: '例如：北京市海淀区…',
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _pickedLatitude = null;
                      _pickedLongitude = null;
                    });
                    Navigator.of(sheetContext).pop();
                  },
                  child: const Text('清除坐标'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openExternalNavigation() async {
    final lat = _pickedLatitude;
    final lng = _pickedLongitude;
    final name = Uri.encodeComponent(_pickedPoiName.isEmpty ? '目的地' : _pickedPoiName);
    final addr = Uri.encodeComponent(_pickedAddress);
    if (lat == null || lng == null) {
      final q = Uri.encodeComponent((_pickedPoiName.isNotEmpty ? _pickedPoiName : _pickedAddress).trim());
      final url = Uri.parse('https://uri.amap.com/search?keyword=$q');
      await _launchExternal(url);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _BottomSheetShell(
          title: '选择导航方式',
          actionText: '关闭',
          onAction: () => Navigator.of(sheetContext).pop(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.map, color: Color(0xFF22BEBE)),
                title: const Text('高德地图', style: TextStyle(fontWeight: FontWeight.w800)),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final url = Uri.parse('https://uri.amap.com/marker?position=$lng,$lat&name=$name&src=life_chronicle');
                  await _launchExternal(url);
                },
              ),
              ListTile(
                leading: const Icon(Icons.public, color: Color(0xFF3B82F6)),
                title: const Text('百度地图', style: TextStyle(fontWeight: FontWeight.w800)),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final url = Uri.parse('https://api.map.baidu.com/marker?location=$lat,$lng&title=$name&content=$addr&output=html');
                  await _launchExternal(url);
                },
              ),
              ListTile(
                leading: const Icon(Icons.navigation, color: Color(0xFF10B981)),
                title: const Text('腾讯地图', style: TextStyle(fontWeight: FontWeight.w800)),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final url = Uri.parse('https://apis.map.qq.com/uri/v1/marker?marker=coord:$lat,$lng;title:$name;addr:$addr&referer=life_chronicle');
                  await _launchExternal(url);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchExternal(Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('无法打开外部地图应用')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPreview = widget.mode == _MomentMapPageMode.preview;
    final title = isPreview ? (widget.title ?? '地图预览') : '选择地点';

    final mapTargetLat = _pickedLatitude ?? 39.908722;
    final mapTargetLng = _pickedLongitude ?? 116.397499;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (isPreview)
            IconButton(
              onPressed: _openExternalNavigation,
              icon: const Icon(Icons.near_me),
            ),
          if (!isPreview)
            TextButton(
              onPressed: _showManualEditSheet,
              child: const Text('手动填写', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 220,
              color: Colors.white,
              child: !_hasMapKey
                  ? const Center(
                      child: Text('未配置高德 Key', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                    )
                  : (_sdkErrorText.isNotEmpty
                      ? Center(
                          child: Text(
                            _sdkErrorText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
                          ),
                        )
                      : (!_sdkReady
                          ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                          : amap.AMapFlutter(
                              initCameraPosition: amap.CameraPosition(
                                position: amap.Position(latitude: mapTargetLat, longitude: mapTargetLng),
                                zoom: 15,
                              ),
                              onMapCreated: (controller) {
                                _mapController = controller;
                                _syncMarkerAndCamera();
                              },
                              onPoiClick: isPreview
                                  ? null
                                  : (poi) {
                                      setState(() {
                                        _poiNameController.text = poi.name;
                                        _pickedLatitude = poi.position.latitude;
                                        _pickedLongitude = poi.position.longitude;
                                      });
                                      _syncMarkerAndCamera();
                                    },
                              onMapLongPress: isPreview
                                  ? null
                                  : (position) {
                                      setState(() {
                                        _pickedLatitude = position.latitude;
                                        _pickedLongitude = position.longitude;
                                      });
                                      _syncMarkerAndCamera();
                                    },
                            ))),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_pickedPoiName.isEmpty ? '未选择地点' : _pickedPoiName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(_pickedAddress.isEmpty ? '未填写地址' : _pickedAddress, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFFF1F5F9))),
                      child: Text(
                        (_pickedLatitude == null || _pickedLongitude == null) ? '无坐标' : '$_pickedLatitude, $_pickedLongitude',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                      ),
                    ),
                    const Spacer(),
                    if (isPreview)
                      TextButton(
                        onPressed: _openExternalNavigation,
                        child: const Text('外部导航', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (!isPreview) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchPoi(),
                    decoration: InputDecoration(
                      hintText: '搜索地点名称/地址',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: const Color(0xFF102222),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  onPressed: _loading ? null : _searchPoi,
                  child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('搜索'),
                ),
              ],
            ),
            if (_errorText.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(_errorText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFEF4444))),
            ],
            const SizedBox(height: 12),
            if (!_hasWebKey)
              const Text('可通过 AMAP_WEB_KEY 启用地点搜索', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
            if (_hasWebKey && _pois.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pois.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final p = _pois[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        _poiNameController.text = p.name;
                        _addressController.text = p.address;
                        _pickedLatitude = p.latitude;
                        _pickedLongitude = p.longitude;
                      });
                      _syncMarkerAndCamera();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name.isEmpty ? '未命名地点' : p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(p.address.isEmpty ? '无地址' : p.address, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
      bottomNavigationBar: widget.mode == _MomentMapPageMode.pick
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: const Color(0xFF102222),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(
                      _MomentMapPickResult(
                        poiName: _pickedPoiName,
                        address: _pickedAddress,
                        latitude: _pickedLatitude,
                        longitude: _pickedLongitude,
                      ),
                    );
                  },
                  child: const Text('使用此地点'),
                ),
              ),
            )
          : null,
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
          _buildLocalImage(url, fit: BoxFit.cover),
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

Widget _buildLocalImage(String path, {BoxFit fit = BoxFit.cover}) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) {
    return const SizedBox.shrink();
  }
  final isNetwork = trimmed.startsWith('http://') || trimmed.startsWith('https://');
  if (isNetwork) {
    return Image.network(trimmed, fit: fit);
  }
  return FutureBuilder<Uint8List>(
    future: XFile(trimmed).readAsBytes(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return Image.memory(snapshot.data!, fit: fit);
      }
      return Container(color: const Color(0xFFF1F5F9));
    },
  );
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
  });

  final int dateIndex;
  final DateTimeRange? customRange;
  final Set<String> friendIds;
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet({
    required this.initialDateIndex,
    required this.initialCustomRange,
    required this.initialFriendIds,
    required this.friendsStream,
  });

  final int initialDateIndex;
  final DateTimeRange? initialCustomRange;
  final Set<String> initialFriendIds;
  final Stream<List<FriendRecord>> friendsStream;

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  static const _dateOptions = ['不限', '今日', '近7天', '近30天', '自定义'];

  late int _dateIndex;
  DateTimeRange? _customRange;
  late Set<String> _selectedFriendIds;

  @override
  void initState() {
    super.initState();
    _dateIndex = widget.initialDateIndex;
    _customRange = widget.initialCustomRange;
    _selectedFriendIds = {...widget.initialFriendIds};
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
      onTap: onTap,
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
