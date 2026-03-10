import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/module_management_config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/utils/media_storage.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/ai_parse_button.dart';
import '../../../core/widgets/custom_bottom_sheet.dart';
import '../../../core/router/route_navigation.dart';
import '../../travel/presentation/travel_page.dart' show TravelItem;
import '../providers/encounter_timeline_provider.dart';
import 'bond_filter_components.dart';

// ==================== Provider ====================

final friendsStreamProvider = StreamProvider<List<FriendRecord>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.friendDao.watchAllActive();
});

// ==================== 扩展方法 ====================

extension FilterResultMatcher on FilterResult {
  bool matches(FriendRecord friend) {
    if (friendIds.isNotEmpty && !friendIds.contains(friend.id)) {
      return false;
    }

    if (dateIndex == 0) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime? startDate;
    DateTime? endDate;
    switch (dateIndex) {
      case 1:
        startDate = today;
        endDate = today;
        break;
      case 2:
        startDate = today.subtract(const Duration(days: 7));
        endDate = today;
        break;
      case 3:
        startDate = today.subtract(const Duration(days: 30));
        endDate = today;
        break;
      case 4:
        if (customRange != null) {
          startDate = customRange!.start;
          endDate = customRange!.end;
        }
        break;
    }

    if (startDate == null || endDate == null) return true;

    final meetDate = friend.meetDate;
    if (meetDate == null) return false;
    final meetDay = DateTime(meetDate.year, meetDate.month, meetDate.day);
    return !meetDay.isBefore(startDate) && !meetDay.isAfter(endDate);
  }
}

class BondPage extends StatefulWidget {
  const BondPage({super.key});

  @override
  State<BondPage> createState() => _BondPageState();
}

class _BondPageState extends State<BondPage> {
  var _tabIndex = 0;
  var _filterDateIndex = 0;
  DateTimeRange? _filterCustomRange;
  Set<String> _filterFriendIds = {};
  var _filterFavorite = false;
  final _searchController = TextEditingController();
  var _searchText = '';

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final db = ref.read(appDatabaseProvider);
            return FilterBottomSheet(
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

  void _handleAdd() {
    if (_tabIndex == 0) {
      RouteNavigation.goToFriendCreate(context);
      return;
    }
    if (_tabIndex == 1) {
      RouteNavigation.goToEncounterCreate(context);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _BondHeader(
              tabIndex: _tabIndex,
              searchController: _searchController,
              hasSearchText: _searchText.isNotEmpty,
              onSearchChanged: (value) => setState(() => _searchText = value),
              onClearSearch: () {
                _searchController.clear();
                setState(() => _searchText = '');
              },
              onTabChanged: (next) => setState(() => _tabIndex = next),
              onAddTap: _handleAdd,
              onFilterTap: _openFilterSheet,
              hasActiveFilter: _filterDateIndex != 0 || _filterFriendIds.isNotEmpty || _filterFavorite,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    fit: StackFit.expand,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: _tabIndex == 0
                    ? _FriendArchiveList(
                        searchQuery: _searchText,
                        filterDateIndex: _filterDateIndex,
                        filterCustomRange: _filterCustomRange,
                        filterFriendIds: _filterFriendIds,
                        filterFavorite: _filterFavorite,
                      )
                    : _EncounterTimeline(filterFavorite: _filterFavorite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BondHeader extends StatelessWidget {
  const _BondHeader({
    required this.tabIndex,
    required this.searchController,
    required this.hasSearchText,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onTabChanged,
    required this.onAddTap,
    required this.onFilterTap,
    this.hasActiveFilter = false,
  });

  final int tabIndex;
  final TextEditingController searchController;
  final bool hasSearchText;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onAddTap;
  final VoidCallback onFilterTap;
  final bool hasActiveFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '羁绊',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                ),
              ),
              AiParseButton(
                text: '解析',
                onPressed: () => RouteNavigation.goToAiHistorianForModule(
                  context,
                  moduleType: 'bond',
                  moduleName: '羁绊',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SegmentedPill(
            tabIndex: tabIndex,
            onChanged: onTabChanged,
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
                          decoration: InputDecoration(
                            hintText: tabIndex == 1 ? '搜索相遇回忆...' : '搜索朋友档案...',
                            hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                      if (hasSearchText)
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: onClearSearch,
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.close, size: 18, color: Color(0xFF9CA3AF)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _CircleIconButton(icon: Icons.tune, onTap: onFilterTap, hasActiveFilter: hasActiveFilter),
              const SizedBox(width: 12),
              _CircleIconButton(icon: Icons.add, iconColor: const Color(0xFF2BCDEE), onTap: onAddTap),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.hasActiveFilter = false,
  });

  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final bool hasActiveFilter;

  @override
  Widget build(BuildContext context) {
    final bgColor = hasActiveFilter ? const Color(0xFF2BCDEE).withValues(alpha: 0.12) : Colors.white;
    final borderColor = hasActiveFilter ? const Color(0xFF2BCDEE).withValues(alpha: 0.35) : Colors.transparent;
    final fgColor = hasActiveFilter ? const Color(0xFF2BCDEE) : (iconColor ?? const Color(0xFF6B7280));
    
    return Material(
      color: bgColor,
      shape: CircleBorder(side: BorderSide(color: borderColor, width: 2)),
      elevation: 0,
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

class _SegmentedPill extends StatelessWidget {
  const _SegmentedPill({required this.tabIndex, required this.onChanged});

  final int tabIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: tabIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2BCDEE),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [BoxShadow(color: const Color(0xFF2BCDEE).withValues(alpha: 0.22), blurRadius: 18, offset: const Offset(0, 8))],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onChanged(0),
                  child: Center(
                    child: Text(
                      '朋友档案',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: tabIndex == 0 ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onChanged(1),
                  child: Center(
                    child: Text(
                      '相遇',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: tabIndex == 1 ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FriendArchiveList extends ConsumerWidget {
  const _FriendArchiveList({
    required this.searchQuery,
    required this.filterDateIndex,
    required this.filterCustomRange,
    required this.filterFriendIds,
    required this.filterFavorite,
  });

  final String searchQuery;
  final int filterDateIndex;
  final DateTimeRange? filterCustomRange;
  final Set<String> filterFriendIds;
  final bool filterFavorite;

  DateTimeRange? _resolveMeetDateRange() {
    if (filterDateIndex == 0) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (filterDateIndex) {
      case 1:
        return DateTimeRange(start: today, end: today);
      case 2:
        return DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today);
      case 3:
        return DateTimeRange(start: today.subtract(const Duration(days: 29)), end: today);
      case 4:
        return filterCustomRange;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder<List<FriendRecord>>(
      stream: db.friendDao.watchAllActive(),
      builder: (context, snapshot) {
        final friends = snapshot.data ?? const <FriendRecord>[];
        if (friends.isEmpty) {
          return const Center(
            child: Text('暂无朋友档案，点击右上角 + 新建', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
          );
        }

        final query = searchQuery.trim().toLowerCase();
        final range = _resolveMeetDateRange();
        final start = range == null ? null : DateTime(range.start.year, range.start.month, range.start.day);
        final endExclusive = range == null ? null : DateTime(range.end.year, range.end.month, range.end.day).add(const Duration(days: 1));

        final filtered = friends.where((f) {
          if (filterFriendIds.isNotEmpty && !filterFriendIds.contains(f.id)) {
            return false;
          }

          if (filterFavorite && !f.isFavorite) {
            return false;
          }

          if (start != null && endExclusive != null) {
            final meet = f.meetDate;
            if (meet == null) return false;
            final date = DateTime(meet.year, meet.month, meet.day);
            if (date.isBefore(start) || !date.isBefore(endExclusive)) {
              return false;
            }
          }

          if (query.isEmpty) return true;
          final name = f.name.toLowerCase();
          final meetWay = (f.meetWay ?? '').toLowerCase();
          final contact = (f.contact ?? '').toLowerCase();
          final tags = (f.impressionTags ?? '').toLowerCase();
          return name.contains(query) || meetWay.contains(query) || contact.contains(query) || tags.contains(query);
        }).toList(growable: false);

        filtered.sort((a, b) {
          final fav = (b.isFavorite ? 1 : 0) - (a.isFavorite ? 1 : 0);
          if (fav != 0) return fav;
          return b.updatedAt.compareTo(a.updatedAt);
        });

        if (filtered.isEmpty) {
          return const Center(
            child: Text('未找到匹配的朋友档案', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
          );
        }

        final left = <FriendRecord>[];
        final right = <FriendRecord>[];
        for (var i = 0; i < filtered.length; i++) {
          (i.isEven ? left : right).add(filtered[i]);
        }
        return SingleChildScrollView(
          key: const ValueKey('friend_archives'),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (final item in left) ...[
                      _FriendCard(friend: item),
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
                      _FriendCard(friend: item),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({required this.friend});

  final FriendRecord friend;

  @override
  Widget build(BuildContext context) {
    final tags = _parseTags(friend.impressionTags);
    final displayTags = tags.isEmpty ? const ['未标记'] : tags;
    final daysText = _formatDays(friend.meetDate);
    final lastMeetText = _formatLastMeet(friend.lastMeetDate ?? friend.meetDate);
    final avatarPath = (friend.avatarPath ?? '').trim();
    final imageHeight = 150 + (friend.id.hashCode % 4) * 20.0;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 0,
      child: InkWell(
        onTap: () => RouteNavigation.goToFriendProfile(context, friend.id),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SizedBox(
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (avatarPath.isNotEmpty)
                        AppImage(source: avatarPath, fit: BoxFit.cover)
                      else
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFE2E8F0), Color(0xFFF8FAFC)],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _initialLetter(friend.name),
                              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0x33000000), Color(0x00000000)],
                          ),
                        ),
                      ),
                      if (friend.isFavorite)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: const Icon(Icons.favorite, size: 16, color: Color(0xFFF43F5E)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            friend.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0x1A2BCDEE), borderRadius: BorderRadius.circular(999)),
                          child: Text(
                            daysText,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2BCDEE)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final t in displayTags)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(999)),
                            child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: const Color(0xFFF3F4F6)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.history, size: 14, color: Color(0xFFFB923C)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            lastMeetText,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFB923C)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

class _EncounterTimelineItem {
  const _EncounterTimelineItem({
    required this.id,
    required this.type,
    required this.recordDate,
    required this.title,
    required this.content,
    required this.poiName,
    required this.poiAddress,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.linkedFriendIds,
    this.isFavorite = false,
  });

  final String id;
  final String type;
  final DateTime recordDate;
  final String title;
  final String content;
  final String poiName;
  final String poiAddress;
  final double? latitude;
  final double? longitude;
  final List<String> images;
  final List<String> linkedFriendIds;
  final bool isFavorite;

  IconData get typeIcon {
    switch (type) {
      case 'encounter':
        return Icons.diversity_3;
      case 'food':
        return Icons.restaurant;
      case 'moment':
        return Icons.auto_awesome;
      case 'travel':
        return Icons.airplanemode_active;
      default:
        return Icons.event;
    }
  }

  String get typeLabel {
    switch (type) {
      case 'encounter':
        return '相遇';
      case 'food':
        return '美食';
      case 'moment':
        return '小确幸';
      case 'travel':
        return '旅行';
      default:
        return '记录';
    }
  }

  Color get typeColor {
    switch (type) {
      case 'encounter':
        return const Color(0xFF2BCDEE);
      case 'food':
        return const Color(0xFFFF9F43);
      case 'moment':
        return const Color(0xFFFF87AB);
      case 'travel':
        return const Color(0xFF42A5F5);
      default:
        return const Color(0xFF2BCDEE);
    }
  }
}

class _EncounterTimeline extends ConsumerStatefulWidget {
  const _EncounterTimeline({required this.filterFavorite});

  final bool filterFavorite;

  @override
  ConsumerState<_EncounterTimeline> createState() => _EncounterTimelineState();
}

class _EncounterTimelineState extends ConsumerState<_EncounterTimeline> {
  int _filterDateIndex = 0;
  DateTimeRange? _filterCustomRange;
  Set<String> _filterFriendIds = {};

  DateTimeRange? _resolveDateRange() {
    if (_filterDateIndex == 0) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_filterDateIndex) {
      case 1:
        return DateTimeRange(start: today, end: today);
      case 2:
        return DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today);
      case 3:
        return DateTimeRange(start: today.subtract(const Duration(days: 29)), end: today);
      case 4:
        return _filterCustomRange;
    }
    return null;
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final db = ref.read(appDatabaseProvider);
            return FilterBottomSheet(
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

  bool _itemMatchesFilter(_EncounterTimelineItem item) {
    final dateRange = _resolveDateRange();
    if (dateRange != null) {
      final itemDate = DateTime(item.recordDate.year, item.recordDate.month, item.recordDate.day);
      if (itemDate.isBefore(dateRange.start) || itemDate.isAfter(dateRange.end)) {
        return false;
      }
    }
    if (_filterFriendIds.isNotEmpty) {
      final hasMatchingFriend = item.linkedFriendIds.any((id) => _filterFriendIds.contains(id));
      if (!hasMatchingFriend) {
        return false;
      }
    }
    if (widget.filterFavorite && !item.isFavorite) {
      return false;
    }
    return true;
  }

  List<String> _decodeStringList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const <String>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList(growable: false);
      }
    } catch (_) {}
    return const <String>[];
  }

  _EncounterTimelineItem _encounterFromTimelineEvent(TimelineEvent event, List<String> friendIds) {
    String content = '';
    List<String> images = [];
    if (event.note != null) {
      final lines = event.note!.split('\n');
      for (final line in lines) {
        if (line.startsWith('心情分享：')) {
          content = line.substring(5).trim();
        } else if (line.startsWith('图片：')) {
          try {
            final jsonStr = line.substring(3).trim();
            final list = jsonDecode(jsonStr) as List;
            images = list.map((e) => e.toString()).toList();
          } catch (_) {}
        }
      }
    }
    return _EncounterTimelineItem(
      id: event.id,
      type: 'encounter',
      recordDate: event.recordDate,
      title: event.title,
      content: content,
      poiName: event.poiName ?? '',
      poiAddress: event.poiAddress ?? '',
      latitude: event.latitude,
      longitude: event.longitude,
      images: images,
      linkedFriendIds: friendIds,
      isFavorite: event.isFavorite,
    );
  }

  _EncounterTimelineItem _itemFromFoodRecord(FoodRecord record, List<String> friendIds) {
    return _EncounterTimelineItem(
      id: record.id,
      type: 'food',
      recordDate: record.recordDate,
      title: record.title,
      content: record.content ?? '',
      poiName: record.poiName ?? '',
      poiAddress: record.poiAddress ?? '',
      latitude: record.latitude,
      longitude: record.longitude,
      images: _decodeStringList(record.images),
      linkedFriendIds: friendIds,
      isFavorite: record.isFavorite,
    );
  }

  _EncounterTimelineItem _itemFromMomentRecord(MomentRecord record, List<String> friendIds) {
    final content = (record.content ?? '').trim();
    final lines = content.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(growable: false);
    final title = lines.isEmpty ? '小确幸' : lines.first;
    final body = lines.length > 1 ? lines.skip(1).join('\n') : '';
    return _EncounterTimelineItem(
      id: record.id,
      type: 'moment',
      recordDate: record.recordDate,
      title: title,
      content: body,
      poiName: record.poiName ?? '',
      poiAddress: record.poiAddress ?? '',
      latitude: record.latitude,
      longitude: record.longitude,
      images: _decodeStringList(record.images),
      linkedFriendIds: friendIds,
      isFavorite: record.isFavorite,
    );
  }

  _EncounterTimelineItem _itemFromTravelRecord(TravelRecord record, List<String> friendIds) {
    final title = (record.title ?? '').trim();
    final displayTitle = title.isNotEmpty ? title : (record.destination ?? '旅行记录');
    return _EncounterTimelineItem(
      id: record.id,
      type: 'travel',
      recordDate: record.recordDate,
      title: displayTitle,
      content: record.content ?? '',
      poiName: record.poiName ?? '',
      poiAddress: record.poiAddress ?? '',
      latitude: record.latitude,
      longitude: record.longitude,
      images: _decodeStringList(record.images),
      linkedFriendIds: friendIds,
      isFavorite: record.isFavorite,
    );
  }

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(encounterTimelineProvider);

    return timelineAsync.when(
      data: (state) {
        final allItems = <_EncounterTimelineItem>[
          for (final e in state.encounters)
            _encounterFromTimelineEvent(e, state.friendLinks[e.id] ?? const <String>[]),
          for (final f in state.foods)
            _itemFromFoodRecord(f, state.friendLinks[f.id] ?? const <String>[]),
          for (final m in state.moments)
            _itemFromMomentRecord(m, state.friendLinks[m.id] ?? const <String>[]),
          for (final t in state.travels)
            _itemFromTravelRecord(t, state.friendLinks[t.id] ?? const <String>[]),
        ]..sort((a, b) => b.recordDate.compareTo(a.recordDate));

        final filteredItems = allItems.where(_itemMatchesFilter).toList();

        return Column(
          children: [
            if (allItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _openFilterSheet,
                      icon: const Icon(Icons.filter_list, size: 18),
                      label: Text(_filterDateIndex == 0 && _filterFriendIds.isEmpty ? '筛选' : '已筛选'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(
                      child: Text(
                        '还没有相遇记录，去新建一次相遇或在美食/小确幸/旅行中关联朋友吧',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF)),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Stack(
                      children: [
                        Positioned(
                          left: 36,
                          top: 0,
                          bottom: 0,
                          child: Container(width: 2, color: const Color(0xFFE5E7EB)),
                        ),
                        ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                          itemCount: filteredItems.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(height: 18),
                          itemBuilder: (context, index) {
                            if (index == filteredItems.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 26),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.55),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
                                    ),
                                    child: const Text('已加载全部相遇', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                                  ),
                                ),
                              );
                            }

                            final item = filteredItems[index];
                            return _EncounterItemRow(item: item);
                          },
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('加载失败')),
    );
  }
}

class _EncounterItemRow extends ConsumerWidget {
  const _EncounterItemRow({required this.item});

  final _EncounterTimelineItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final date = item.recordDate;
    final dateText = '${date.year}年${date.month}月${date.day}日';
    final contentPreview = item.content.length > 60 ? '${item.content.substring(0, 60)}…' : item.content;
    final locationDisplay = item.poiName.isNotEmpty
        ? (item.poiAddress.isNotEmpty && !item.poiName.contains(item.poiAddress) ? '${item.poiName} · ${item.poiAddress}' : item.poiName)
        : item.poiAddress;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 6),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.typeColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFF6F6F6), width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Icon(item.typeIcon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            child: InkWell(
              onTap: () => _navigateToDetail(context),
              borderRadius: BorderRadius.circular(28),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0x00000000)),
                  boxShadow: [BoxShadow(color: item.typeColor.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.typeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(item.typeLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: item.typeColor)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(dateText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: item.typeColor)),
                        ),
                        const Icon(Icons.chevron_right, size: 18, color: Color(0x809CA3AF)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1.2)),
                    if (contentPreview.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(contentPreview, style: const TextStyle(fontSize: 13, color: Color(0xFF78909C), height: 1.4)),
                    ],
                    if (locationDisplay.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.place, size: 16, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              locationDisplay,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (item.linkedFriendIds.isNotEmpty)
                      StreamBuilder<List<FriendRecord>>(
                        stream: db.friendDao.watchAllActive(),
                        builder: (context, friendSnapshot) {
                          final friends = friendSnapshot.data ?? const <FriendRecord>[];
                          final selected = friends.where((f) => item.linkedFriendIds.contains(f.id)).toList(growable: false);
                          if (selected.isEmpty) return const SizedBox.shrink();
                          final display = selected.take(4).toList(growable: false);
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                for (final f in display) ...[
                                  _AvatarCircle(name: f.name, imagePath: f.avatarPath),
                                  const SizedBox(width: 8),
                                ],
                                if (selected.length > 4)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(999)),
                                    child: Text('+${selected.length - 4}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToDetail(BuildContext context) {
    switch (item.type) {
      case 'encounter':
        RouteNavigation.goToEncounterDetail(context, item.id);
        break;
      case 'food':
        RouteNavigation.goToFoodDetail(context, item.id);
        break;
      case 'moment':
        RouteNavigation.goToMomentDetail(context, item.id);
        break;
      case 'travel':
        RouteNavigation.goToTravelDetail(context, item.id, item: TravelItem(
          travelId: item.id,
          tripId: '',
          recordDate: item.recordDate,
          date: '${item.recordDate.year}年${item.recordDate.month}月${item.recordDate.day}日',
          title: item.title,
          subtitle: item.content,
          imageUrl: item.images.isNotEmpty ? item.images.first : '',
        ));
        break;
    }
  }
}

class FriendProfilePage extends ConsumerWidget {
  const FriendProfilePage({super.key, required this.friendId});

  final String friendId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _BondFriendDetailPage(friendId: friendId);
  }
}

class _BondFriendDetailPage extends ConsumerWidget {
  const _BondFriendDetailPage({required this.friendId});

  final String friendId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder<FriendRecord?>(
      stream: db.friendDao.watchById(friendId),
      builder: (context, snapshot) {
        final friend = snapshot.data;

        Future<void> deleteFriend() async {
          final confirmed = await showCustomBottomSheet<bool>(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '删除档案',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '删除后将解除已关联的万物互联关系，且无法在列表中恢复显示。',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
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
                          onPressed: () => Navigator.of(context).pop(true),
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

          final now = DateTime.now();
          await db.transaction(() async {
            final links = await db.linkDao.listLinksForEntity(entityType: 'friend', entityId: friendId);
            for (final link in links) {
              await db.linkDao.deleteLink(
                sourceType: link.sourceType,
                sourceId: link.sourceId,
                targetType: link.targetType,
                targetId: link.targetId,
                linkType: link.linkType,
                now: now,
              );
            }
            await db.friendDao.softDeleteById(friendId, now: now);
          });

          if (!context.mounted) return;
          Navigator.of(context).pop();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: const Text('档案详情', style: TextStyle(fontWeight: FontWeight.w900)),
                actions: [
                  if (friend != null)
                    IconButton(
                      onPressed: () async {
                        await showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (sheetContext) {
                            return SafeArea(
                              top: false,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                                ),
                                padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + MediaQuery.paddingOf(sheetContext).bottom),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5E7EB),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                                      title: const Text('删除档案', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFEF4444))),
                                      onTap: () async {
                                        Navigator.of(sheetContext).pop();
                                        await deleteFriend();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.more_vert),
                    ),
                ],
              ),
              if (friend == null)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
                    child: Center(
                      child: Text('档案已删除或不存在', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      children: [
                        _FriendProfileCard(
                          friend: friend,
                          onToggleFavorite: () async {
                            final now = DateTime.now();
                            await db.friendDao.updateFavorite(friend.id, isFavorite: !friend.isFavorite, now: now);
                          },
                          onEdit: () {
                            RouteNavigation.goToFriendCreate(context, initialFriend: friend);
                          },
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('AI 洞察报告功能正在开发中，敬请期待'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: const Color(0x332BCDEE)),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 6))],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, color: Color(0xFF2BCDEE), size: 18),
                                  SizedBox(width: 8),
                                  Text('AI 洞察报告', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
                                  SizedBox(width: 6),
                                  Icon(Icons.chevron_right, color: Color(0xFF2BCDEE), size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                _FriendMemorySliver(friend: friend),
                const SliverPadding(padding: EdgeInsets.only(bottom: 140)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FriendProfileCard extends StatelessWidget {
  const _FriendProfileCard({
    required this.friend,
    required this.onToggleFavorite,
    required this.onEdit,
  });

  final FriendRecord friend;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 88,
              height: 88,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0x332BCDEE),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: (friend.avatarPath ?? '').trim().isEmpty
                    ? Container(
                        color: const Color(0xFFF1F5F9),
                        alignment: Alignment.center,
                        child: Text(
                          _initialLetter(friend.name),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                        ),
                      )
                    : AppImage(source: friend.avatarPath!, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: Text(friend.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.center,
            child: Text('已认识 ${_formatDays(friend.meetDate)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFFB923C))),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _InfoPair(label: '朋友生日', value: _formatBirthday(friend.birthday))),
              const SizedBox(width: 12),
              Expanded(child: _InfoPair(label: '认识途径', value: _formatOrFallback(friend.meetWay, '未记录'))),
            ],
          ),
          const SizedBox(height: 12),
          _InfoPair(label: '备注', value: _formatOrFallback(friend.contact, '未填写')),
          if (_formatOrFallback(friend.contactFrequency, '').isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoPair(label: '联络频率', value: _formatOrFallback(friend.contactFrequency, '未设置')),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('印象标签', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in _tagsOrFallback(friend.impressionTags))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0x1A2BCDEE), borderRadius: BorderRadius.circular(999)),
                        child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onToggleFavorite,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: friend.isFavorite ? const Color(0xFFF43F5E) : const Color(0xFFE5E7EB)),
                    foregroundColor: friend.isFavorite ? const Color(0xFFF43F5E) : const Color(0xFF6B7280),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Colors.transparent,
                  ),
                  icon: Icon(friend.isFavorite ? Icons.favorite : Icons.favorite_border, size: 18),
                  label: Text(friend.isFavorite ? '已收藏' : '收藏', style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    foregroundColor: const Color(0xFF111827),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: const Color(0xFFF3F4F6),
                  ),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('编辑档案', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPair extends StatelessWidget {
  const _InfoPair({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
        ],
      ),
    );
  }
}

class _FriendMemorySliver extends ConsumerStatefulWidget {
  const _FriendMemorySliver({required this.friend});

  final FriendRecord friend;

  @override
  ConsumerState<_FriendMemorySliver> createState() => _FriendMemorySliverState();
}

class _FriendMemorySliverState extends ConsumerState<_FriendMemorySliver> {
  var _filterIndex = 0;
  int _filterDateIndex = 0;
  DateTimeRange? _filterCustomRange;

  Map<String, List<String>> _groupLinkIds(List<EntityLink> links, String selfType, String selfId) {
    final result = <String, List<String>>{};
    for (final link in links) {
      final isSource = link.sourceType == selfType && link.sourceId == selfId;
      final otherType = isSource ? link.targetType : link.sourceType;
      final otherId = isSource ? link.targetId : link.sourceId;
      (result[otherType] ??= <String>[]).add(otherId);
    }
    return result;
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final db = ref.read(appDatabaseProvider);
            return FilterBottomSheet(
              initialDateIndex: _filterDateIndex,
              initialCustomRange: _filterCustomRange,
              initialFriendIds: const <String>{},
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
    });
  }

  DateTimeRange? _resolveDateRange() {
    if (_filterDateIndex == 0) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_filterDateIndex) {
      case 1:
        return DateTimeRange(start: today, end: today);
      case 2:
        return DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today);
      case 3:
        return DateTimeRange(start: today.subtract(const Duration(days: 29)), end: today);
      case 4:
        return _filterCustomRange;
    }
    return null;
  }

  bool _itemMatchesDateFilter(_FriendMemoryItem item) {
    final dateRange = _resolveDateRange();
    if (dateRange == null) return true;
    final itemDate = DateTime(item.recordDate.year, item.recordDate.month, item.recordDate.day);
    return !itemDate.isBefore(dateRange.start) && !itemDate.isAfter(dateRange.end);
  }

  Stream<List<MomentRecord>> _watchMomentsByIds(AppDatabase db, List<String> ids) {
    if (ids.isEmpty) return Stream.value(const <MomentRecord>[]);
    return (db.select(db.momentRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.id.isIn(ids)))
        .watch();
  }

  Stream<List<FoodRecord>> _watchFoodsByIds(AppDatabase db, List<String> ids) {
    if (ids.isEmpty) return Stream.value(const <FoodRecord>[]);
    return (db.select(db.foodRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.id.isIn(ids)))
        .watch();
  }

  Stream<List<TravelRecord>> _watchTravelsByIds(AppDatabase db, List<String> ids) {
    if (ids.isEmpty) return Stream.value(const <TravelRecord>[]);
    return (db.select(db.travelRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.id.isIn(ids)))
        .watch();
  }

  Stream<List<TimelineEvent>> _watchEncountersByIds(AppDatabase db, List<String> ids) {
    if (ids.isEmpty) return Stream.value(const <TimelineEvent>[]);
    return (db.select(db.timelineEvents)
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.eventType.equals('encounter'))
          ..where((t) => t.id.isIn(ids))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)]))
        .watch();
  }

  List<String> _decodeStringList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const <String>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList(growable: false);
      }
    } catch (_) {}
    return const <String>[];
  }

  String _formatDateCN(DateTime date) {
    return '${date.year}年 ${date.month}月 ${date.day}日';
  }

  String _momentTitleFromContent(String? raw) {
    final content = (raw ?? '').trim();
    if (content.isEmpty) return '小确幸';
    final lines = content.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(growable: false);
    return lines.isEmpty ? '小确幸' : lines.first;
  }

  String _momentBodyFromContent(String? raw) {
    final content = (raw ?? '').trim();
    if (content.isEmpty) return '';
    final lines = content.split('\n');
    var foundTitle = false;
    final rest = <String>[];
    for (final line in lines) {
      if (!foundTitle) {
        if (line.trim().isNotEmpty) {
          foundTitle = true;
        }
        continue;
      }
      rest.add(line);
    }
    return rest.join('\n').trim();
  }

  String _travelTitle(TravelRecord record) {
    final title = (record.title ?? '').trim();
    if (title.isNotEmpty) return title;
    final destination = (record.destination ?? '').trim();
    return destination.isNotEmpty ? destination : '旅行记录';
  }

  List<_FriendMemoryItem> _parseEncounters(List<TimelineEvent> events) {
    return events.map((e) {
      String place = (e.poiName ?? '').trim();
      String address = (e.poiAddress ?? '').trim();
      String content = '';
      List<String> images = [];

      if (e.note != null) {
        final lines = e.note!.split('\n');
        for (final line in lines) {
          if (line.startsWith('地点：')) {
            if (place.isEmpty && address.isEmpty) {
              place = line.substring(3).trim();
            }
          } else if (line.startsWith('心情分享：')) {
            content = line.substring(5).trim();
          } else if (line.startsWith('图片：')) {
            try {
              final jsonStr = line.substring(3).trim();
              final list = jsonDecode(jsonStr) as List;
              images = list.map((e) => e.toString()).toList();
            } catch (_) {}
          }
        }
      }

      final placeDisplay = place.isNotEmpty && address.isNotEmpty && !place.contains(address) ? '$place · $address' : (place.isNotEmpty ? place : address);
      return _FriendMemoryItem(
        recordDate: e.recordDate,
        typeKey: 'encounter',
        date: '${e.recordDate.year}年 ${e.recordDate.month}月 ${e.recordDate.day}日',
        typeLabel: '相遇',
        typeIcon: Icons.diversity_3,
        title: e.title,
        content: content,
        place: placeDisplay,
        poiName: place,
        poiAddress: address,
        city: '',
        latitude: e.latitude,
        longitude: e.longitude,
        images: images,
      );
    }).toList();
  }

  List<_FriendMemoryItem> _parseMoments(List<MomentRecord> records) {
    return records.map((r) {
      final poiName = (r.poiName ?? '').trim();
      final poiAddress = (r.poiAddress ?? '').trim();
      final city = (r.city ?? '').trim();
      final place = poiName.isNotEmpty ? poiName : (poiAddress.isNotEmpty ? poiAddress : city);
      final title = _momentTitleFromContent(r.content);
      final body = _momentBodyFromContent(r.content);
      return _FriendMemoryItem(
        recordDate: r.recordDate,
        typeKey: 'moment',
        date: _formatDateCN(r.recordDate),
        typeLabel: '小确幸',
        typeIcon: Icons.auto_awesome,
        title: title,
        content: body,
        place: place,
        poiName: poiName,
        poiAddress: poiAddress,
        city: city,
        latitude: r.latitude,
        longitude: r.longitude,
        images: _decodeStringList(r.images),
      );
    }).toList(growable: false);
  }

  List<_FriendMemoryItem> _parseFoods(List<FoodRecord> records) {
    return records.map((r) {
      final poiName = (r.poiName ?? '').trim();
      final poiAddress = (r.poiAddress ?? r.city ?? '').trim();
      final place = poiName.isNotEmpty ? poiName : poiAddress;
      return _FriendMemoryItem(
        recordDate: r.recordDate,
        typeKey: 'food',
        date: _formatDateCN(r.recordDate),
        typeLabel: '美食',
        typeIcon: Icons.restaurant,
        title: r.title,
        content: (r.content ?? '').trim(),
        place: place,
        poiName: poiName,
        poiAddress: poiAddress,
        city: (r.city ?? '').trim(),
        latitude: r.latitude,
        longitude: r.longitude,
        images: _decodeStringList(r.images),
      );
    }).toList(growable: false);
  }

  List<_FriendMemoryItem> _parseTravels(List<TravelRecord> records) {
    return records.map((r) {
      final poiName = (r.poiName ?? '').trim();
      final poiAddress = (r.poiAddress ?? r.destination ?? '').trim();
      final place = poiName.isNotEmpty ? poiName : poiAddress;
      return _FriendMemoryItem(
        recordDate: r.recordDate,
        typeKey: 'travel',
        date: _formatDateCN(r.recordDate),
        typeLabel: '旅行',
        typeIcon: Icons.airplanemode_active,
        title: _travelTitle(r),
        content: (r.content ?? '').trim(),
        place: place,
        poiName: poiName,
        poiAddress: poiAddress,
        city: (r.destination ?? '').trim(),
        latitude: r.latitude,
        longitude: r.longitude,
        images: _decodeStringList(r.images),
      );
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);

    return StreamBuilder<List<EntityLink>>(
      stream: db.linkDao.watchLinksForEntity(entityType: 'friend', entityId: widget.friend.id),
      builder: (context, linkSnapshot) {
        final links = linkSnapshot.data ?? const <EntityLink>[];
        final grouped = _groupLinkIds(links, 'friend', widget.friend.id);
        final momentIds = grouped['moment'] ?? const <String>[];
        final foodIds = grouped['food'] ?? const <String>[];
        final travelIds = grouped['travel'] ?? const <String>[];
        final encounterIds = grouped['encounter'] ?? const <String>[];

        return StreamBuilder<List<MomentRecord>>(
          stream: _watchMomentsByIds(db, momentIds),
          builder: (context, momentSnapshot) {
            return StreamBuilder<List<FoodRecord>>(
              stream: _watchFoodsByIds(db, foodIds),
              builder: (context, foodSnapshot) {
                return StreamBuilder<List<TravelRecord>>(
                  stream: _watchTravelsByIds(db, travelIds),
                  builder: (context, travelSnapshot) {
                    return StreamBuilder<List<TimelineEvent>>(
                      stream: _watchEncountersByIds(db, encounterIds),
                      builder: (context, encounterSnapshot) {
                        final moments = momentSnapshot.data ?? const <MomentRecord>[];
                        final foods = foodSnapshot.data ?? const <FoodRecord>[];
                        final travels = travelSnapshot.data ?? const <TravelRecord>[];
                        final encounters = encounterSnapshot.data ?? const <TimelineEvent>[];

                        final items = <_FriendMemoryItem>[
                          ..._parseEncounters(encounters),
                          ..._parseMoments(moments),
                          ..._parseFoods(foods),
                          ..._parseTravels(travels),
                        ]..sort((a, b) => b.recordDate.compareTo(a.recordDate));

                        final typeFilteredItems = _filterIndex == 0
                            ? items
                            : items
                                .where((e) {
                                  if (_filterIndex == 1) return e.typeKey == 'food';
                                  if (_filterIndex == 2) return e.typeKey == 'travel';
                                  if (_filterIndex == 3) return e.typeKey == 'moment';
                                  return true;
                                })
                                .toList(growable: false);

                        final displayItems = typeFilteredItems.where(_itemMatchesDateFilter).toList();

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('共同回忆轴', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                                const SizedBox(height: 4),
                                                Text('共 ${displayItems.length} 个美好瞬间', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                                              ],
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: _openFilterSheet,
                                            icon: const Icon(Icons.filter_list, size: 18),
                                            label: Text(_filterDateIndex == 0 ? '筛选' : '已筛选'),
                                            style: TextButton.styleFrom(foregroundColor: const Color(0xFF2BCDEE), textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            _PillTab(label: '全部', active: _filterIndex == 0, onTap: () => setState(() => _filterIndex = 0)),
                                            const SizedBox(width: 10),
                                            _PillTab(label: '🍽️ 美食', active: _filterIndex == 1, onTap: () => setState(() => _filterIndex = 1)),
                                            const SizedBox(width: 10),
                                            _PillTab(label: '✈️ 旅行', active: _filterIndex == 2, onTap: () => setState(() => _filterIndex = 2)),
                                            const SizedBox(width: 10),
                                            _PillTab(label: '✨ 小确幸', active: _filterIndex == 3, onTap: () => setState(() => _filterIndex = 3)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                    ],
                                  ),
                                );
                              }

                              if (displayItems.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                                  child: Center(child: Text('还没有共同回忆哦，快去记录一次相遇/小确幸/美食/旅行吧！', style: TextStyle(color: Color(0xFF9CA3AF)))),
                                );
                              }

                              final itemIndex = index - 1;
                              final item = displayItems[itemIndex];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                child: _TimelineEntry(item: item, isLast: itemIndex == displayItems.length - 1),
                              );
                            },
                            childCount: displayItems.isEmpty ? 2 : displayItems.length + 1,
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
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? const Color(0xFF2BCDEE) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: active ? const Color(0xFF2BCDEE) : const Color(0xFFF3F4F6)),
            boxShadow: active ? [BoxShadow(color: const Color(0xFF2BCDEE).withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 6))] : null,
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: active ? Colors.white : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}

class _FriendMemoryItem {
  const _FriendMemoryItem({
    required this.recordDate,
    required this.typeKey,
    required this.date,
    required this.typeLabel,
    required this.typeIcon,
    required this.title,
    required this.content,
    required this.place,
    required this.poiName,
    required this.poiAddress,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.images,
  });

  final DateTime recordDate;
  final String typeKey;
  final String date;
  final String typeLabel;
  final IconData typeIcon;
  final String title;
  final String content;
  final String place;
  final String poiName;
  final String poiAddress;
  final String city;
  final double? latitude;
  final double? longitude;
  final List<String> images;
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.item,
    this.isLast = false,
  });

  final _FriendMemoryItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final hasImage = item.images.isNotEmpty;
    return Stack(
      children: [
        Positioned(
          left: 24,
          top: 0,
          bottom: isLast ? null : 0,
          height: isLast ? 24 : null, // Stop at dot center (approx) if last
          child: Container(
            width: 2,
            color: const Color(0xFFFB923C).withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 10),
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: hasImage ? const Color(0xFF2BCDEE) : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFF8FAFC), width: 2),
                  boxShadow: hasImage ? [BoxShadow(color: const Color(0xFF2BCDEE).withValues(alpha: 0.20), blurRadius: 14, offset: const Offset(0, 6))] : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.date, style: TextStyle(fontSize: 12, fontWeight: hasImage ? FontWeight.w900 : FontWeight.w700, color: hasImage ? const Color(0xFF2BCDEE) : const Color(0xFF9CA3AF))),
                    const SizedBox(height: 8),
                    _buildCard(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    if (item.images.isEmpty) {
      return _NoImageMemoryCard(item: item);
    } else if (item.images.length == 1) {
      return _SingleImageMemoryCard(item: item);
    } else {
      return _MultiImageMemoryCard(item: item);
    }
  }
}

class _SingleImageMemoryCard extends StatelessWidget {
  const _SingleImageMemoryCard({required this.item});

  final _FriendMemoryItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x1A2BCDEE)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: SizedBox(
                  height: 164,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage(source: item.images.first, fit: BoxFit.cover),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.typeIcon, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(item.typeLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    const SizedBox(height: 8),
                    Text(item.content, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B), height: 1.45)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: item.poiName.trim().isNotEmpty || item.poiAddress.trim().isNotEmpty
                                ? () {
                                    RouteNavigation.openMapPreview(
                                      context,
                                      title: '地点',
                                      poiName: item.poiName,
                                      address: item.poiAddress,
                                      city: item.city,
                                      latitude: item.latitude,
                                      longitude: item.longitude,
                                    );
                                  }
                                : null,
                            child: Row(
                              children: [
                                const Icon(Icons.place, size: 16, color: Color(0xFF9CA3AF)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(item.place, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border), color: const Color(0xFF9CA3AF)),
                      ],
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

class _MultiImageMemoryCard extends StatelessWidget {
  const _MultiImageMemoryCard({required this.item});

  final _FriendMemoryItem item;

  @override
  Widget build(BuildContext context) {
    final displayCount = item.images.length > 9 ? 9 : item.images.length;
    final displayImages = item.images.take(displayCount).toList();
    final remaining = item.images.length - 9;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x1A2BCDEE)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        ),
                        Icon(item.typeIcon, size: 16, color: const Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Text(item.typeLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(item.content, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B), height: 1.45)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: displayImages.length,
                  itemBuilder: (context, index) {
                    final isLast = index == 8 && remaining > 0;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AppImage(source: displayImages[index], fit: BoxFit.cover),
                          if (isLast)
                            Container(
                              color: Colors.black.withValues(alpha: 0.5),
                              alignment: Alignment.center,
                              child: Text(
                                '+$remaining',
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: item.poiName.trim().isNotEmpty || item.poiAddress.trim().isNotEmpty
                            ? () {
                                RouteNavigation.openMapPreview(
                                  context,
                                  title: '地点',
                                  poiName: item.poiName,
                                  address: item.poiAddress,
                                  city: item.city,
                                  latitude: item.latitude,
                                  longitude: item.longitude,
                                );
                              }
                            : null,
                        child: Row(
                          children: [
                            const Icon(Icons.place, size: 16, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(item.place, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border), color: const Color(0xFF9CA3AF)),
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

class _NoImageMemoryCard extends StatelessWidget {
  const _NoImageMemoryCard({required this.item});

  final _FriendMemoryItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x1A2BCDEE)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  ),
                  if (item.place.isNotEmpty)
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: item.poiName.trim().isNotEmpty || item.poiAddress.trim().isNotEmpty
                          ? () {
                              RouteNavigation.openMapPreview(
                                context,
                                title: '地点',
                                poiName: item.poiName,
                                address: item.poiAddress,
                                city: item.city,
                                latitude: item.latitude,
                                longitude: item.longitude,
                              );
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.place, size: 14, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Text(item.place, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(item.content, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B), height: 1.45)),
            ],
          ),
        ),
      ),
    );
  }
}

class FriendCreatePage extends ConsumerStatefulWidget {
  const FriendCreatePage({super.key, this.initialFriend});

  final FriendRecord? initialFriend;

  @override
  ConsumerState<FriendCreatePage> createState() => _FriendCreatePageState();
}

class _FriendCreatePageState extends ConsumerState<FriendCreatePage> {
  static const _uuid = Uuid();
  static const _frequencyOptions = ['无需提醒', '每一个月提醒一次', '每三个月提醒一次', '每年提醒一次'];

  final _nameController = TextEditingController();
  final _meetWayController = TextEditingController();
  final _remarkController = TextEditingController();

  String? _friendId;
  DateTime? _createdAt;
  bool _isFavorite = false;
  String? _avatarPath;
  DateTime? _birthday;
  DateTime? _meetDate;
  String? _contactFrequency = '无需提醒';
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialFriend;
    if (initial != null) {
      _friendId = initial.id;
      _createdAt = initial.createdAt;
      _isFavorite = initial.isFavorite;
      _avatarPath = (initial.avatarPath ?? '').trim().isEmpty ? null : initial.avatarPath!.trim();
      _birthday = initial.birthday;
      _meetDate = initial.meetDate == null ? null : DateTime(initial.meetDate!.year, initial.meetDate!.month, initial.meetDate!.day);
      _contactFrequency = (initial.contactFrequency ?? '').trim().isEmpty ? '无需提醒' : initial.contactFrequency!.trim();
      _nameController.text = initial.name;
      _meetWayController.text = initial.meetWay ?? '';
      _remarkController.text = initial.contact ?? '';
      _selectedTags
        ..clear()
        ..addAll(_parseTags(initial.impressionTags));
      return;
    }

    final now = DateTime.now();
    _meetDate = DateTime(now.year, now.month, now.day);
    _contactFrequency = '每三个月提醒一次';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _meetWayController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final stored = await persistImageFile(file, folder: 'friend', prefix: 'friend');
    if (!mounted) return;
    setState(() => _avatarPath = stored ?? file.path);
  }

  Future<DateTime?> _pickDateOnly(DateTime? initial) async {
    final base = initial ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('zh', 'CN'),
    );
    if (pickedDate == null) return null;
    return DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
  }

  String _formatDateOnly(DateTime? date) {
    if (date == null) return '未设置';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  String _formatMeetDate(DateTime? date) {
    if (date == null) return '今天';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return '今天';
    return _formatDateOnly(d);
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
                  hintText: '例如：超级会聊天',
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
    final tag = (result ?? '').replaceAll('#', '').trim();
    if (tag.isEmpty) return;
    if (_selectedTags.contains(tag)) return;
    await syncTagToModuleConfig('bond', tag);
    setState(() => _selectedTags.add(tag));
  }

  Future<void> _openFrequencySheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetShell(
          title: '联络频率提醒',
          actionText: '完成',
          onAction: () => Navigator.of(context).pop(_contactFrequency),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                for (final option in _frequencyOptions)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    trailing: Radio<String>(
                      value: option,
                      groupValue: _contactFrequency,
                      onChanged: (v) => Navigator.of(context).pop(v),
                      activeColor: const Color(0xFF0EA5E9),
                    ),
                    onTap: () => Navigator.of(context).pop(option),
                  ),
              ],
            ),
          ),
        );
      },
    );
    final next = (result ?? '').trim();
    if (next.isEmpty) return;
    if (!mounted) return;
    setState(() => _contactFrequency = next);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写朋友名字')));
      return;
    }
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final friendId = _friendId ?? _uuid.v4();
    final createdAt = _createdAt ?? now;
    final impressionTags = _selectedTags.isEmpty ? null : jsonEncode(_selectedTags);
    final remark = _remarkController.text.trim();
    final meetWay = _meetWayController.text.trim();
    final avatar = (_avatarPath ?? '').trim().isNotEmpty ? _avatarPath!.trim() : null;

    await db.friendDao.upsert(
      FriendRecordsCompanion.insert(
        id: friendId,
        name: name,
        avatarPath: Value(avatar),
        birthday: Value(_birthday),
        contact: Value(remark.isEmpty ? null : remark),
        meetWay: Value(meetWay.isEmpty ? null : meetWay),
        meetDate: Value(_meetDate),
        impressionTags: Value(impressionTags),
        groupName: const Value(null),
        lastMeetDate: Value(_meetDate),
        contactFrequency: Value(_contactFrequency?.trim().isEmpty == true ? null : _contactFrequency),
        isFavorite: Value(_isFavorite),
        createdAt: createdAt,
        updatedAt: now,
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final avatarPath = (_avatarPath ?? '').trim();
    final isEdit = widget.initialFriend != null;
    final configAsync = ref.watch(moduleManagementConfigProvider);
    return configAsync.when(
      data: (config) {
        final availableTags = getTagsForModule(config, 'bond');
        final allTags = {...availableTags, ..._selectedTags}.toList();
        final module = config.moduleOf('bond');
        final tagColorMap = <String, String?>{};
        for (final t in module.tags) {
          tagColorMap[t.name] = t.color;
        }
        Color colorFromHex(String? hex) {
          if (hex == null || hex.isEmpty) return const Color(0xFFF3F4F6);
          try {
            final cleanHex = hex.replaceFirst('#', '');
            return Color(int.parse('FF$cleanHex', radix: 16));
          } catch (_) {
            return const Color(0xFFF3F4F6);
          }
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 88, 16, 120),
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 2))],
                              ),
                              child: ClipOval(
                                child: avatarPath.isEmpty
                                    ? Center(
                                        child: Text(
                                          _initialLetter(_nameController.text),
                                          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8)),
                                        ),
                                      )
                                    : AppImage(source: avatarPath, fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 2))],
                                ),
                                child: const Icon(Icons.camera_alt, size: 14, color: Color(0xFF0EA5E9)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _pickAvatar,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0EA5E9),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                        child: const Text('修改头像'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 14, offset: Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('朋友姓名', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF999999))),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Sarah',
                        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0EA5E9))),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('朋友生日', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF999999))),
                              InkWell(
                                onTap: () async {
                                  final picked = await _pickDateOnly(_birthday);
                                  if (picked == null) return;
                                  setState(() => _birthday = picked);
                                },
                                child: Container(
                                  height: 40,
                                  alignment: Alignment.centerLeft,
                                  decoration: const BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                                  ),
                                  child: Text(
                                    _formatDateOnly(_birthday),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _birthday == null ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('认识日期', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF999999))),
                              InkWell(
                                onTap: () async {
                                  final picked = await _pickDateOnly(_meetDate);
                                  if (picked == null) return;
                                  setState(() => _meetDate = picked);
                                },
                                child: Container(
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _formatMeetDate(_meetDate),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: _meetDate == null ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF94A3B8)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('认识途径', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF999999))),
                    TextField(
                      controller: _meetWayController,
                      decoration: const InputDecoration(
                        hintText: '市一中 高中同学',
                        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0EA5E9))),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _openFrequencySheet,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('联络频率提醒', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF999999))),
                              const SizedBox(height: 6),
                              Text(
                                (_contactFrequency ?? '').trim().isEmpty ? '无需提醒' : _contactFrequency!,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 26, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('备注', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF999999))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _remarkController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '高中死党，超级火锅爱好者...',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: const Color(0xFFE2E8F0).withValues(alpha: 0.8))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: const Color(0xFFE2E8F0).withValues(alpha: 0.8))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF0EA5E9))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155), height: 1.35),
                    ),
                    const SizedBox(height: 16),
                    const Text('印象标签', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF999999))),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final tag in allTags)
                          Builder(builder: (context) {
                            final isSelected = _selectedTags.contains(tag);
                            final tagColorHex = tagColorMap[tag];
                            final tagColor = colorFromHex(tagColorHex);
                            final unselectedBg = tagColorHex != null ? tagColor.withValues(alpha: 0.15) : const Color(0xFFF3F4F6);
                            final bgColor = isSelected ? const Color(0x1A0EA5E9) : unselectedBg;
                            final textColor = isSelected ? const Color(0xFF0EA5E9) : (tagColorHex != null ? tagColor : const Color(0xFF64748B));
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedTags.remove(tag);
                                  } else {
                                    _selectedTags.add(tag);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            );
                          }),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _addCustomTag,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 16, color: Color(0xFF64748B)),
                                SizedBox(width: 6),
                                Text('添加标签', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xF2F8FAFC),
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF475569)),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(isEdit ? '编辑档案' : '新建档案', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                        ),
                      ),
                      TextButton(
                        onPressed: _save,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0EA5E9),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                        child: const Text('保存'),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  },
  loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
  error: (_, __) => const Scaffold(body: Center(child: Text('加载配置失败'))),
);
  }
}

String _initialLetter(String name) {
  final trimmed = name.trim();
  return trimmed.isEmpty ? '?' : trimmed.characters.first;
}

List<String> _parseTags(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return [];
  try {
    final decoded = jsonDecode(value);
    if (decoded is List) {
      return decoded.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList(growable: false);
    }
  } catch (_) {}
  return value
      .split(RegExp(r'[，,;；/|]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);
}

List<String> _tagsOrFallback(String? raw) {
  final tags = _parseTags(raw);
  return tags.isEmpty ? const ['未标记'] : tags;
}

String _formatDays(DateTime? meetDate) {
  if (meetDate == null) return '未知';
  final now = DateTime.now();
  final start = DateTime(meetDate.year, meetDate.month, meetDate.day);
  final end = DateTime(now.year, now.month, now.day);
  final days = end.difference(start).inDays;
  return '${days <= 0 ? 1 : days}天';
}

String _formatLastMeet(DateTime? lastMeet) {
  if (lastMeet == null) return '上次见面：未记录';
  final now = DateTime.now();
  final date = DateTime(lastMeet.year, lastMeet.month, lastMeet.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(date).inDays;
  if (diff <= 0) return '上次见面：今天';
  return '上次见面：$diff天前';
}

String _formatBirthday(DateTime? date) {
  if (date == null) return '未设置';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(date.month)}月${two(date.day)}日';
}

String _formatOrFallback(String? value, String fallback) {
  final trimmed = (value ?? '').trim();
  return trimmed.isEmpty ? fallback : trimmed;
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

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.name, this.imagePath});

  final String name;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter = trimmed.isEmpty ? '?' : trimmed.characters.first;
    final path = imagePath?.trim() ?? '';
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: path.isEmpty
          ? Text(letter, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF334155)))
          : ClipOval(child: AppImage(source: path, fit: BoxFit.cover)),
    );
  }
}
