import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/utils/media_storage.dart';
import '../../../core/widgets/amap_location_page.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  var _modeIndex = 0;
  var _filterDateIndex = 0;
  DateTimeRange? _filterCustomRange;
  Set<int> _filterRatings = {};
  Set<String> _filterCities = {};
  Set<String> _filterFriendIds = {};
  var _filterSolo = false;
  final _searchController = TextEditingController();
  var _searchQuery = '';

  Future<void> _openDateFilter() async {
    final result = await showModalBottomSheet<_DateFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DateFilterSheet(
          initialDateIndex: _filterDateIndex,
          initialCustomRange: _filterCustomRange,
        );
      },
    );
    if (result == null) return;
    setState(() {
      _filterDateIndex = result.dateIndex;
      _filterCustomRange = result.customRange;
    });
  }

  Future<void> _openRatingFilter() async {
    final result = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RatingFilterSheet(initialRatings: _filterRatings);
      },
    );
    if (result == null) return;
    setState(() => _filterRatings = result);
  }

  Future<void> _openCityFilter() async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final db = ref.read(appDatabaseProvider);
            return _CityFilterSheet(
              initialCities: _filterCities,
              recordsStream: db.foodDao.watchAllActive(),
            );
          },
        );
      },
    );
    if (result == null) return;
    setState(() => _filterCities = result);
  }

  Future<void> _openCompanionFilter() async {
    final result = await showModalBottomSheet<_CompanionFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final db = ref.read(appDatabaseProvider);
            return _CompanionFilterSheet(
              initialFriendIds: _filterFriendIds,
              initialSolo: _filterSolo,
              friendsStream: db.friendDao.watchAllActive(),
            );
          },
        );
      },
    );
    if (result == null) return;
    setState(() {
      _filterFriendIds = result.friendIds;
      _filterSolo = result.solo;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _FoodHeader(
              modeIndex: _modeIndex,
              onModeChanged: (next) => setState(() => _modeIndex = next),
              onDateFilterTap: _openDateFilter,
              onRatingFilterTap: _openRatingFilter,
              onCityFilterTap: _openCityFilter,
              onCompanionFilterTap: _openCompanionFilter,
              isDateFilterActive: _filterDateIndex != 0,
              isRatingFilterActive: _filterRatings.isNotEmpty,
              isCityFilterActive: _filterCities.isNotEmpty,
              isCompanionFilterActive: _filterSolo || _filterFriendIds.isNotEmpty,
              searchController: _searchController,
              onSearchChanged: (v) => setState(() => _searchQuery = v),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _modeIndex == 0
                    ? _FoodRecordBody(
                        key: const ValueKey('food_records'),
                        searchQuery: _searchQuery,
                        filterDateIndex: _filterDateIndex,
                        filterCustomRange: _filterCustomRange,
                        filterRatings: _filterRatings,
                        filterCities: _filterCities,
                        filterFriendIds: _filterFriendIds,
                        filterSolo: _filterSolo,
                      )
                    : _FoodWishlistBody(
                        key: const ValueKey('food_wishlist'),
                        searchQuery: _searchQuery,
                        filterDateIndex: _filterDateIndex,
                        filterCustomRange: _filterCustomRange,
                        filterRatings: _filterRatings,
                        filterCities: _filterCities,
                        filterFriendIds: _filterFriendIds,
                        filterSolo: _filterSolo,
                        onSwitchToRecords: () => setState(() => _modeIndex = 0),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodHeader extends StatelessWidget {
  const _FoodHeader({
    required this.modeIndex,
    required this.onModeChanged,
    required this.onDateFilterTap,
    required this.onRatingFilterTap,
    required this.onCityFilterTap,
    required this.onCompanionFilterTap,
    required this.isDateFilterActive,
    required this.isRatingFilterActive,
    required this.isCityFilterActive,
    required this.isCompanionFilterActive,
    required this.searchController,
    required this.onSearchChanged,
  });

  final int modeIndex;
  final ValueChanged<int> onModeChanged;
  final VoidCallback onDateFilterTap;
  final VoidCallback onRatingFilterTap;
  final VoidCallback onCityFilterTap;
  final VoidCallback onCompanionFilterTap;
  final bool isDateFilterActive;
  final bool isRatingFilterActive;
  final bool isCityFilterActive;
  final bool isCompanionFilterActive;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

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
                  '美食诱惑',
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
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          decoration: const InputDecoration(
                            hintText: '搜索店名、标签、地理位置...',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 15, color: Color(0xFF111827), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _HeaderCircle(icon: Icons.tune, onTap: onDateFilterTap),
            ],
          ),
          const SizedBox(height: 12),
          _SegmentedPill(modeIndex: modeIndex, onChanged: onModeChanged),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: '日期范围', icon: Icons.calendar_month, selected: isDateFilterActive, onTap: onDateFilterTap),
                const SizedBox(width: 10),
                _FilterChip(label: '评分', icon: Icons.star, selected: isRatingFilterActive, onTap: onRatingFilterTap),
                const SizedBox(width: 10),
                _FilterChip(label: '位置', icon: Icons.location_on, selected: isCityFilterActive, onTap: onCityFilterTap),
                const SizedBox(width: 10),
                _FilterChip(label: '同伴', icon: Icons.group, selected: isCompanionFilterActive, onTap: onCompanionFilterTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCircle extends StatelessWidget {
  const _HeaderCircle({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

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
          child: Icon(icon, color: const Color(0xFF6B7280), size: 22),
        ),
      ),
    );
  }
}

class _SegmentedPill extends StatelessWidget {
  const _SegmentedPill({
    required this.modeIndex,
    required this.onChanged,
  });

  final int modeIndex;
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
            alignment: modeIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
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
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    onChanged(0);
                  },
                  child: Center(
                    child: Text(
                      '美食记录',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: modeIndex == 0 ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    onChanged(1);
                  },
                  child: Center(
                    child: Text(
                      '心愿清单',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: modeIndex == 1 ? Colors.white : const Color(0xFF6B7280),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF2BCDEE).withValues(alpha: 0.12) : Colors.white;
    final border = selected ? const Color(0xFF2BCDEE).withValues(alpha: 0.35) : const Color(0xFFF3F4F6);
    final fg = selected ? const Color(0xFF2BCDEE) : const Color(0xFF6B7280);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: fg)),
              const SizedBox(width: 8),
              Icon(icon, size: 16, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodRecordBody extends ConsumerWidget {
  const _FoodRecordBody({
    super.key,
    required this.searchQuery,
    required this.filterDateIndex,
    required this.filterCustomRange,
    required this.filterRatings,
    required this.filterCities,
    required this.filterFriendIds,
    required this.filterSolo,
  });

  final String searchQuery;
  final int filterDateIndex;
  final DateTimeRange? filterCustomRange;
  final Set<int> filterRatings;
  final Set<String> filterCities;
  final Set<String> filterFriendIds;
  final bool filterSolo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final range = _resolveDateRange(filterDateIndex, filterCustomRange);
    final stream = range == null ? db.foodDao.watchAllActive() : db.foodDao.watchByRecordDateRange(range.$1, range.$2);
    return StreamBuilder<List<FoodRecord>>(
      stream: stream,
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <FoodRecord>[];
        final base = all.where((e) => e.isWishlist == false).toList(growable: false);
        final byRatingAndCity = _applyRatingAndCity(base);

        if (filterFriendIds.isEmpty && !filterSolo) {
          final filtered = _applySearch(byRatingAndCity, searchQuery);
          return _FoodRecordListView(records: filtered);
        }

        final selectedFriendIds = filterFriendIds.toList(growable: false);
        final friendLinksStream = selectedFriendIds.isEmpty
            ? const Stream<List<EntityLink>>.empty()
            : (db.select(db.entityLinks)
                  ..where((t) => t.sourceType.equals('food'))
                  ..where((t) => t.targetType.equals('friend'))
                  ..where((t) => t.targetId.isIn(selectedFriendIds)))
                .watch();

        final anyFriendLinksStream = (db.select(db.entityLinks)
              ..where((t) => t.sourceType.equals('food'))
              ..where((t) => t.targetType.equals('friend')))
            .watch();

        return StreamBuilder<List<EntityLink>>(
          stream: friendLinksStream,
          builder: (context, friendLinkSnapshot) {
            final friendLinks = friendLinkSnapshot.data ?? const <EntityLink>[];
            final bySelectedFriends = <String>{for (final l in friendLinks) l.sourceId};
            if (!filterSolo) {
              final byFriend = byRatingAndCity.where((e) => bySelectedFriends.contains(e.id)).toList(growable: false);
              final filtered = _applySearch(byFriend, searchQuery);
              return _FoodRecordListView(records: filtered);
            }

            return StreamBuilder<List<EntityLink>>(
              stream: anyFriendLinksStream,
              builder: (context, anyLinkSnapshot) {
                final anyLinks = anyLinkSnapshot.data ?? const <EntityLink>[];
                final hasAnyFriend = <String>{for (final l in anyLinks) l.sourceId};
                final byCompanion = byRatingAndCity.where((e) {
                  final isSolo = !hasAnyFriend.contains(e.id);
                  if (isSolo) return true;
                  if (selectedFriendIds.isEmpty) return false;
                  return bySelectedFriends.contains(e.id);
                }).toList(growable: false);
                final filtered = _applySearch(byCompanion, searchQuery);
                return _FoodRecordListView(records: filtered);
              },
            );
          },
        );
      },
    );
  }

  (DateTime, DateTime)? _resolveDateRange(int index, DateTimeRange? customRange) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (index) {
      case 1:
        return (today, today.add(const Duration(days: 1)));
      case 2:
        return (today.subtract(const Duration(days: 6)), today.add(const Duration(days: 1)));
      case 3:
        return (today.subtract(const Duration(days: 29)), today.add(const Duration(days: 1)));
      case 4:
        if (customRange == null) return null;
        final start = DateTime(customRange.start.year, customRange.start.month, customRange.start.day);
        final end = DateTime(customRange.end.year, customRange.end.month, customRange.end.day).add(const Duration(days: 1));
        return (start, end);
      default:
        return null;
    }
  }

  List<FoodRecord> _applySearch(List<FoodRecord> input, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return input;
    return input.where((r) {
      final tags = _decodeStringList(r.tags).join(' ');
      final fields = [
        r.title,
        r.content ?? '',
        r.poiName ?? '',
        r.poiAddress ?? r.city ?? '',
        tags,
      ].join(' ').toLowerCase();
      return fields.contains(q);
    }).toList(growable: false);
  }

  List<String> _decodeStringList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.whereType<String>().toList(growable: false);
    } catch (_) {}
    return const [];
  }

  List<FoodRecord> _applyRatingAndCity(List<FoodRecord> input) {
    var out = input;
    if (filterRatings.isNotEmpty) {
      out = out.where((r) {
        final v = r.rating;
        if (v == null) return false;
        return filterRatings.contains(v.round().clamp(1, 5));
      }).toList(growable: false);
    }
    if (filterCities.isNotEmpty) {
      out = out.where((r) {
        final city = _resolveFoodCity(r);
        return city.isNotEmpty && filterCities.contains(city);
      }).toList(growable: false);
    }
    return out;
  }
}

class _FoodRecordListView extends StatelessWidget {
  const _FoodRecordListView({required this.records});

  final List<FoodRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text('暂无美食记录', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 140),
      itemBuilder: (context, index) => _FoodRecordCard(record: records[index]),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemCount: records.length,
    );
  }
}

class _FoodRecordCard extends StatelessWidget {
  const _FoodRecordCard({required this.record});

  final FoodRecord record;

  @override
  Widget build(BuildContext context) {
    final images = _decodeStringList(record.images);
    final tags = _decodeStringList(record.tags);
    final cover = images.isEmpty ? '' : images.first;
    final subtitle = (record.content ?? '').trim();
    final location = [
      (record.poiName ?? '').trim(),
      (record.poiAddress ?? record.city ?? '').trim(),
    ].where((e) => e.isNotEmpty).join(' · ');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FoodDetailPage(recordId: record.id))),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: SizedBox(
                  height: 180,
                  child: cover.isEmpty
                      ? Container(
                          color: const Color(0xFFF1F5F9),
                          alignment: Alignment.center,
                          child: const Icon(Icons.restaurant, color: Color(0xFF94A3B8), size: 40),
                        )
                      : _buildLocalImage(cover, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)),
                      ),
                    ],
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.place, size: 14, color: Color(0xFF2BCDEE)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Color(0xFFFB923C)),
                        const SizedBox(width: 4),
                        Text(
                          record.rating == null ? '--' : record.rating!.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.payments_outlined, size: 14, color: Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        Text(
                          record.pricePerPerson == null ? '--' : '¥${record.pricePerPerson!.toStringAsFixed(0)}/人',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                        ),
                        const Spacer(),
                        Text(
                          '${record.recordDate.month}月${record.recordDate.day}日',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final t in tags.take(6))
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0x1A2BCDEE), borderRadius: BorderRadius.circular(999)),
                              child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
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
    );
  }

  List<String> _decodeStringList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.whereType<String>().toList(growable: false);
    } catch (_) {}
    return const [];
  }
}

class FoodCardData {
  const FoodCardData({
    required this.title,
    required this.subtitle,
    required this.location,
    required this.rating,
    required this.price,
    required this.tags,
    required this.imageUrl,
    required this.imageHeight,
  });

  final String title;
  final String subtitle;
  final String location;
  final double rating;
  final String price;
  final List<String> tags;
  final String imageUrl;
  final double imageHeight;
}

class FoodWishlistItem {
  const FoodWishlistItem({
    required this.title,
    required this.subtitle,
    required this.location,
    required this.rating,
    required this.price,
    required this.tags,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String location;
  final double rating;
  final String price;
  final List<String> tags;
  final String imageUrl;
}

class _FoodWishlistBody extends ConsumerWidget {
  const _FoodWishlistBody({
    super.key,
    required this.searchQuery,
    required this.filterDateIndex,
    required this.filterCustomRange,
    required this.filterRatings,
    required this.filterCities,
    required this.filterFriendIds,
    required this.filterSolo,
    required this.onSwitchToRecords,
  });

  final String searchQuery;
  final int filterDateIndex;
  final DateTimeRange? filterCustomRange;
  final Set<int> filterRatings;
  final Set<String> filterCities;
  final Set<String> filterFriendIds;
  final bool filterSolo;
  final VoidCallback onSwitchToRecords;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final range = _resolveDateRange(filterDateIndex, filterCustomRange);
    final stream = range == null ? db.foodDao.watchAllActive() : db.foodDao.watchByRecordDateRange(range.$1, range.$2);
    return StreamBuilder<List<FoodRecord>>(
      stream: stream,
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <FoodRecord>[];
        final base = all.where((e) => e.isWishlist == true).toList(growable: false);
        final byRatingAndCity = _applyRatingAndCity(base);

        if (filterFriendIds.isEmpty && !filterSolo) {
          final filtered = _applySearch(byRatingAndCity, searchQuery);
          return _FoodWishlistListView(records: filtered, onSwitchToRecords: onSwitchToRecords);
        }

        final selectedFriendIds = filterFriendIds.toList(growable: false);
        final friendLinksStream = selectedFriendIds.isEmpty
            ? const Stream<List<EntityLink>>.empty()
            : (db.select(db.entityLinks)
                  ..where((t) => t.sourceType.equals('food'))
                  ..where((t) => t.targetType.equals('friend'))
                  ..where((t) => t.targetId.isIn(selectedFriendIds)))
                .watch();

        final anyFriendLinksStream = (db.select(db.entityLinks)
              ..where((t) => t.sourceType.equals('food'))
              ..where((t) => t.targetType.equals('friend')))
            .watch();

        return StreamBuilder<List<EntityLink>>(
          stream: friendLinksStream,
          builder: (context, friendLinkSnapshot) {
            final friendLinks = friendLinkSnapshot.data ?? const <EntityLink>[];
            final bySelectedFriends = <String>{for (final l in friendLinks) l.sourceId};
            if (!filterSolo) {
              final byFriend = byRatingAndCity.where((e) => bySelectedFriends.contains(e.id)).toList(growable: false);
              final filtered = _applySearch(byFriend, searchQuery);
              return _FoodWishlistListView(records: filtered, onSwitchToRecords: onSwitchToRecords);
            }

            return StreamBuilder<List<EntityLink>>(
              stream: anyFriendLinksStream,
              builder: (context, anyLinkSnapshot) {
                final anyLinks = anyLinkSnapshot.data ?? const <EntityLink>[];
                final hasAnyFriend = <String>{for (final l in anyLinks) l.sourceId};
                final byCompanion = byRatingAndCity.where((e) {
                  final isSolo = !hasAnyFriend.contains(e.id);
                  if (isSolo) return true;
                  if (selectedFriendIds.isEmpty) return false;
                  return bySelectedFriends.contains(e.id);
                }).toList(growable: false);
                final filtered = _applySearch(byCompanion, searchQuery);
                return _FoodWishlistListView(records: filtered, onSwitchToRecords: onSwitchToRecords);
              },
            );
          },
        );
      },
    );
  }

  (DateTime, DateTime)? _resolveDateRange(int index, DateTimeRange? customRange) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (index) {
      case 1:
        return (today, today.add(const Duration(days: 1)));
      case 2:
        return (today.subtract(const Duration(days: 6)), today.add(const Duration(days: 1)));
      case 3:
        return (today.subtract(const Duration(days: 29)), today.add(const Duration(days: 1)));
      case 4:
        if (customRange == null) return null;
        final start = DateTime(customRange.start.year, customRange.start.month, customRange.start.day);
        final end = DateTime(customRange.end.year, customRange.end.month, customRange.end.day).add(const Duration(days: 1));
        return (start, end);
      default:
        return null;
    }
  }

  List<FoodRecord> _applySearch(List<FoodRecord> input, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return input;
    return input.where((r) {
      final tags = _decodeStringList(r.tags).join(' ');
      final fields = [
        r.title,
        r.content ?? '',
        r.poiName ?? '',
        r.poiAddress ?? r.city ?? '',
        tags,
      ].join(' ').toLowerCase();
      return fields.contains(q);
    }).toList(growable: false);
  }

  List<String> _decodeStringList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.whereType<String>().toList(growable: false);
    } catch (_) {}
    return const [];
  }

  List<FoodRecord> _applyRatingAndCity(List<FoodRecord> input) {
    var out = input;
    if (filterRatings.isNotEmpty) {
      out = out.where((r) {
        final v = r.rating;
        if (v == null) return false;
        return filterRatings.contains(v.round().clamp(1, 5));
      }).toList(growable: false);
    }
    if (filterCities.isNotEmpty) {
      out = out.where((r) {
        final city = _resolveFoodCity(r);
        return city.isNotEmpty && filterCities.contains(city);
      }).toList(growable: false);
    }
    return out;
  }
}

class _FoodWishlistListView extends StatelessWidget {
  const _FoodWishlistListView({required this.records, required this.onSwitchToRecords});

  final List<FoodRecord> records;
  final VoidCallback onSwitchToRecords;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text('暂无心愿清单', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 140),
      itemBuilder: (context, index) => _FoodWishlistRecordCard(record: records[index], onSwitchToRecords: onSwitchToRecords),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemCount: records.length,
    );
  }
}

class _FoodWishlistRecordCard extends StatelessWidget {
  const _FoodWishlistRecordCard({required this.record, required this.onSwitchToRecords});

  final FoodRecord record;
  final VoidCallback onSwitchToRecords;

  @override
  Widget build(BuildContext context) {
    final images = _decodeStringList(record.images);
    final tags = _decodeStringList(record.tags);
    final cover = images.isEmpty ? '' : images.first;
    final subtitle = (record.content ?? '').trim();
    final location = [
      (record.poiName ?? '').trim(),
      (record.poiAddress ?? record.city ?? '').trim(),
    ].where((e) => e.isNotEmpty).join(' · ');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () async {
          final converted = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => FoodDetailPage(recordId: record.id)),
          );
          if (converted == true) onSwitchToRecords();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                child: SizedBox(
                  width: 108,
                  height: 108,
                  child: cover.isEmpty
                      ? Container(
                          color: const Color(0xFFF1F5F9),
                          alignment: Alignment.center,
                          child: const Icon(Icons.bookmark_border, color: Color(0xFF94A3B8), size: 28),
                        )
                      : _buildLocalImage(cover, fit: BoxFit.cover),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)),
                        ),
                      ],
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          if (tags.isNotEmpty)
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (final t in tags.take(2))
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: const Color(0x1A2BCDEE), borderRadius: BorderRadius.circular(999)),
                                      child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
                                    ),
                                ],
                              ),
                            )
                          else
                            const Spacer(),
                          const SizedBox(width: 8),
                          Text(
                            record.wishlistDone ? '已打卡' : '想去',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: record.wishlistDone ? const Color(0xFF10B981) : const Color(0xFF2BCDEE),
                            ),
                          ),
                        ],
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

  List<String> _decodeStringList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.whereType<String>().toList(growable: false);
    } catch (_) {}
    return const [];
  }
}

class FoodWishlistDetailPage extends StatelessWidget {
  const FoodWishlistDetailPage({super.key, required this.item});

  final FoodWishlistItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white.withValues(alpha: 0.8),
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900)),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: _buildLocalImage(item.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0x1AFB923C), borderRadius: BorderRadius.circular(999)),
                        child: Text('评分 ${item.rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFFB923C))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 16, color: Color(0xFF2BCDEE)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(item.location, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                      ),
                      Text(item.price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFFB923C))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in item.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(999)),
                          child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('备注', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: const Text(
                      '想在周末去打卡，最好提前预约。也可以约朋友一起。',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569), height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('万物互联', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 10),
                  _LinkBlock(icon: Icons.group, title: '计划同伴', chips: const ['小明', 'Sarah']),
                  const SizedBox(height: 10),
                  _LinkBlock(icon: Icons.flight_takeoff, title: '关联旅行', chips: const ['京都慢旅行']),
                  const SizedBox(height: 10),
                  _LinkBlock(icon: Icons.flag, title: '关联目标', chips: const ['每月探索一家新餐厅']),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    foregroundColor: const Color(0xFF111827),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {},
                  child: const Text('编辑', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2BCDEE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: const Text('标记已吃', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FoodDetailPage extends ConsumerWidget {
  const FoodDetailPage({super.key, this.item, this.recordId});

  final FoodCardData? item;
  final String? recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    if (recordId == null) {
      return _buildScaffold(
        context,
        isWishlist: false,
        title: item?.title ?? '美食详情',
        pricePerPerson: null,
        rating: item?.rating,
        tags: const [],
        images: (item?.imageUrl ?? '').isEmpty ? const [] : [item!.imageUrl],
        locationTitle: item?.location ?? '',
        locationSubtitle: '',
        latitude: null,
        longitude: null,
        note: item?.subtitle ?? '',
        recordDate: DateTime.now(),
        isFavorite: false,
        linkSection: _buildLinkSection(
          db,
          entityId: '',
          entityType: 'food',
          showContent: false,
        ),
        onEdit: null,
        onToggleFavorite: null,
        onShare: null,
        onDelete: null,
        onCheckInAgain: null,
        onMarkAsTasted: null,
      );
    }
    return StreamBuilder<FoodRecord?>(
      stream: db.foodDao.watchById(recordId!),
      builder: (context, snapshot) {
        final record = snapshot.data;
        if (record == null) {
          return _buildScaffold(
            context,
            isWishlist: false,
            title: '美食详情',
            pricePerPerson: null,
            tags: const [],
            images: const [],
            locationTitle: '',
            locationSubtitle: '',
            latitude: null,
            longitude: null,
            rating: null,
            note: '记录不存在或已删除',
            recordDate: DateTime.now(),
            isFavorite: false,
            linkSection: _buildLinkSection(
              db,
              entityId: recordId!,
              entityType: 'food',
              showContent: false,
            ),
            onEdit: null,
            onToggleFavorite: null,
            onShare: null,
            onDelete: null,
            onCheckInAgain: null,
            onMarkAsTasted: null,
          );
        }
        final images = _parseImages(record.images);
        final tags = _parseStringList(record.tags);
        final note = (record.content ?? '').trim();
        final isWishlist = record.isWishlist;
        return _buildScaffold(
          context,
          isWishlist: isWishlist,
          title: record.title,
          pricePerPerson: record.pricePerPerson,
          rating: record.rating,
          tags: tags,
          images: images,
          locationTitle: (record.poiName ?? '').trim(),
          locationSubtitle: (record.poiAddress ?? record.city ?? '').trim(),
          latitude: record.latitude,
          longitude: record.longitude,
          note: note,
          recordDate: record.recordDate,
          isFavorite: record.isFavorite,
          linkSection: _buildLinkSection(
            db,
            entityId: record.id,
            entityType: 'food',
            showContent: true,
          ),
          onEdit: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FoodCreatePage(initialRecord: record)),
            );
          },
          onToggleFavorite: () async {
            await db.foodDao.updateFavorite(
              record.id,
              isFavorite: !record.isFavorite,
              now: DateTime.now(),
            );
          },
          onShare: () {},
          onDelete: () async {
            final now = DateTime.now();
            final linkDao = LinkDao(db);
            final links = await linkDao.listLinksForEntity(entityType: 'food', entityId: record.id);
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
            await db.foodDao.softDeleteById(record.id, now: now);
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          onCheckInAgain: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FoodCreatePage(
                  prefillTitle: record.title,
                  prefillPoiName: (record.poiName ?? '').trim().isEmpty ? record.title : record.poiName,
                  prefillPoiAddress: (record.poiAddress ?? record.city ?? '').trim(),
                  prefillPricePerPerson: record.pricePerPerson,
                ),
              ),
            );
          },
          onMarkAsTasted: !isWishlist
              ? null
              : () async {
                  final converted = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => FoodCreatePage(
                        initialRecord: record,
                        overrideIsWishlist: false,
                        overrideWishlistDone: true,
                        popWithResultOnPublish: true,
                      ),
                    ),
                  );
                  if (!context.mounted) return;
                  if (converted == true) Navigator.of(context).pop(true);
                },
        );
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context, {
    required bool isWishlist,
    required String title,
    required double? pricePerPerson,
    required double? rating,
    required List<String> tags,
    required List<String> images,
    required String locationTitle,
    required String locationSubtitle,
    required double? latitude,
    required double? longitude,
    required String note,
    required DateTime recordDate,
    required bool isFavorite,
    required Widget linkSection,
    required VoidCallback? onEdit,
    required VoidCallback? onToggleFavorite,
    required VoidCallback? onShare,
    required VoidCallback? onDelete,
    required VoidCallback? onCheckInAgain,
    required Future<void> Function()? onMarkAsTasted,
  }) {
    final shareKey = GlobalKey();
    void openMapPreview() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AmapLocationPage.preview(
            title: title,
            poiName: locationTitle,
            address: locationSubtitle,
            latitude: latitude,
            longitude: longitude,
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white.withValues(alpha: 0.85),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: isWishlist ? const SizedBox.shrink() : Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            actions: [
              IconButton(onPressed: onShare == null ? null : () => _shareLongImage(context, shareKey), icon: const Icon(Icons.ios_share)),
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
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                                    title: const Text('删除此条美食', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                                    subtitle: const Text('删除后将不可恢复', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                                    onTap: () async {
                                      Navigator.of(sheetContext).pop();
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) {
                                          return AlertDialog(
                                            title: const Text('确认删除'),
                                            content: const Text('确定要删除这条美食记录吗？'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('取消')),
                                              TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('删除')),
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
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.white.withValues(alpha: 0.85)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: RepaintBoundary(
              key: shareKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('人均', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                            const SizedBox(height: 2),
                            Text(
                              pricePerPerson == null ? '¥ --' : '¥ ${pricePerPerson.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF22BEBE)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (!isWishlist) ...[
                      Row(
                        children: [
                          _RatingStars(rating: rating),
                          const SizedBox(width: 6),
                          Text(
                            rating == null ? '--' : rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(width: 6),
                          const Text('|', style: TextStyle(fontSize: 10, color: Color(0xFFD1D5DB))),
                          const SizedBox(width: 6),
                          Text(
                            tags.isEmpty ? '美食' : tags.first,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      const SizedBox(height: 4),
                    ],
                    InkWell(
                      onTap: openMapPreview,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(color: const Color(0x1A2BCDEE), borderRadius: BorderRadius.circular(999)),
                              child: const Icon(Icons.location_on, size: 16, color: Color(0xFF22BEBE)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    locationTitle.isEmpty ? '未填写地点' : locationTitle,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    locationSubtitle.isEmpty ? '未填写地址' : locationSubtitle,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: const Color(0xFFF3F4F6)),
                              ),
                              child: const Icon(Icons.near_me, size: 14, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isWishlist) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(color: const Color(0x1A2BCDEE), borderRadius: BorderRadius.circular(999)),
                                  child: const Icon(Icons.bookmark_border, size: 16, color: Color(0xFF22BEBE)),
                                ),
                                const SizedBox(width: 10),
                                const Text('心愿备注', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              note.isEmpty ? '暂无心愿备注' : note,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827), height: 1.6),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(999)),
                                  child: const Icon(Icons.local_offer_outlined, size: 16, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(width: 10),
                                const Text('美食标签', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (tags.isEmpty)
                              const Text('暂无标签', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)))
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (var i = 0; i < tags.length; i++)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: i == 0 ? const Color(0x1A2BCDEE) : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(color: i == 0 ? const Color(0x332BCDEE) : const Color(0xFFF3F4F6)),
                                      ),
                                      child: Text(
                                        '#${tags[i]}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: i == 0 ? const Color(0xFF22BEBE) : const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(999)),
                                  child: const Icon(Icons.photo_library_outlined, size: 16, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(width: 10),
                                const Text('打卡相册', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                const Spacer(),
                                Text(
                                  images.isEmpty ? '0' : '${images.length}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (images.isEmpty)
                              const Text('暂无图片', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)))
                            else
                              _ImageGrid(images: images),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(height: 1, color: const Color(0xFFF1F5F9)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(color: const Color(0xFF2BCDEE), borderRadius: BorderRadius.circular(999)),
                          ),
                          const SizedBox(width: 8),
                          const Text('万物关联', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0x1A2BCDEE), borderRadius: BorderRadius.circular(999)),
                            child: const Text('计划关联', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF22BEBE))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      linkSection,
                    ] else ...[
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < tags.length; i++)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: i == 0 ? const Color(0x1A2BCDEE) : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: i == 0 ? const Color(0x332BCDEE) : const Color(0xFFF3F4F6)),
                                ),
                                child: Text(
                                  '#${tags[i]}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: i == 0 ? const Color(0xFF22BEBE) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),
                      Text(
                        note.isEmpty ? '暂无记录' : note,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF000000), height: 1.7),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 6),
                          Text(
                            '记录于 ${_formatRecordDate(recordDate)}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (images.isNotEmpty) _ImageGrid(images: images),
                      const SizedBox(height: 16),
                      Container(height: 1, color: const Color(0xFFF1F5F9)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(color: const Color(0xFF2BCDEE), borderRadius: BorderRadius.circular(999)),
                          ),
                          const SizedBox(width: 8),
                          const Text('万物互联', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0x1A2BCDEE), borderRadius: BorderRadius.circular(999)),
                            child: const Text('关联', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF22BEBE))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      linkSection,
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: openMapPreview,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 96,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            border: Border.all(color: const Color(0xFFF3F4F6)),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('查看地图详情', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                                  SizedBox(height: 4),
                                  Text('Navigation', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 6))],
                ),
                child: Row(
                  children: isWishlist
                      ? [
                          _BottomAction(
                            icon: Icons.edit,
                            label: '编辑',
                            onTap: onEdit,
                          ),
                          _BottomDivider(),
                          _BottomAction(
                            icon: Icons.share,
                            label: '分享',
                            onTap: onShare == null ? null : () => _shareLongImage(context, shareKey),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2BCDEE),
                                foregroundColor: const Color(0xFF102222),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                              ),
                              onPressed: onMarkAsTasted == null
                                  ? null
                                  : () {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      onMarkAsTasted();
                                    },
                              icon: const Icon(Icons.check_circle_outline, size: 16),
                              label: const Text('标记为已品尝'),
                            ),
                          ),
                        ]
                      : [
                          _BottomAction(
                            icon: Icons.edit,
                            label: '编辑',
                            onTap: onEdit,
                          ),
                          _BottomDivider(),
                          _BottomAction(
                            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                            label: '收藏',
                            active: isFavorite,
                            onTap: onToggleFavorite,
                          ),
                          _BottomDivider(),
                          _BottomAction(
                            icon: Icons.share,
                            label: '分享',
                            onTap: onShare == null ? null : () => _shareLongImage(context, shareKey),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2BCDEE),
                                foregroundColor: const Color(0xFF102222),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                              ),
                              onPressed: onCheckInAgain == null
                                  ? null
                                  : () {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      onCheckInAgain();
                                    },
                              icon: const Icon(Icons.restaurant, size: 16),
                              label: const Text('再次打卡'),
                            ),
                          ),
                        ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkSection(
    AppDatabase db, {
    required String entityId,
    required String entityType,
    required bool showContent,
  }) {
    if (!showContent) {
      return Column(
        children: [
          _LinkBlock(icon: Icons.people, title: '关联人物', chips: const []),
          const SizedBox(height: 10),
          _LinkBlock(icon: Icons.auto_awesome, title: '关联小确幸', chips: const []),
          const SizedBox(height: 10),
          _LinkBlock(icon: Icons.flight_takeoff, title: '关联旅行', chips: const []),
          const SizedBox(height: 10),
          _LinkBlock(icon: Icons.flag, title: '关联目标', chips: const []),
        ],
      );
    }
    return StreamBuilder<List<EntityLink>>(
      stream: db.linkDao.watchLinksForEntity(entityType: entityType, entityId: entityId),
      builder: (context, linkSnapshot) {
        final linkIds = _groupLinkIds(linkSnapshot.data ?? const <EntityLink>[], entityType, entityId);
        return StreamBuilder<List<FriendRecord>>(
          stream: db.friendDao.watchAllActive(),
          builder: (context, friendSnapshot) {
            final friends = friendSnapshot.data ?? const <FriendRecord>[];
            final friendNames = _mapNames(
              linkIds['friend'] ?? const <String>[],
              {for (final f in friends) f.id: f.name},
            );
            return StreamBuilder<List<MomentRecord>>(
              stream: db.momentDao.watchAllActive(),
              builder: (context, momentSnapshot) {
                final moments = momentSnapshot.data ?? const <MomentRecord>[];
                final momentTitles = _mapNames(
                  linkIds['moment'] ?? const <String>[],
                  {for (final m in moments) m.id: _momentTitle(m)},
                );
                return StreamBuilder<List<TravelRecord>>(
                  stream: db.watchAllActiveTravelRecords(),
                  builder: (context, travelSnapshot) {
                    final travels = travelSnapshot.data ?? const <TravelRecord>[];
                    final travelTitles = _mapNames(
                      linkIds['travel'] ?? const <String>[],
                      {for (final t in travels) t.id: _travelTitle(t)},
                    );
                    return StreamBuilder<List<TimelineEvent>>(
                      stream: (db.select(db.timelineEvents)
                            ..where((t) => t.isDeleted.equals(false))
                            ..where((t) => t.eventType.equals('goal')))
                          .watch(),
                      builder: (context, goalSnapshot) {
                        final goals = goalSnapshot.data ?? const <TimelineEvent>[];
                        final goalTitles = _mapNames(
                          linkIds['goal'] ?? const <String>[],
                          {for (final g in goals) g.id: g.title},
                        );
                        return Column(
                          children: [
                            _LinkBlock(icon: Icons.people, title: '关联人物', chips: friendNames),
                            const SizedBox(height: 10),
                            _LinkBlock(icon: Icons.auto_awesome, title: '关联小确幸', chips: momentTitles),
                            const SizedBox(height: 10),
                            _LinkBlock(icon: Icons.flight_takeoff, title: '关联旅行', chips: travelTitles),
                            const SizedBox(height: 10),
                            _LinkBlock(icon: Icons.flag, title: '关联目标', chips: goalTitles),
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
      },
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

  List<String> _parseStringList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toList(growable: false);
      }
    } catch (_) {}
    return const [];
  }

  String _formatRecordDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}年$month月$day日';
  }

  Future<void> _shareLongImage(BuildContext context, GlobalKey shareKey) async {
    final boundary = shareKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
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
      final file = File('${dir.path}/food_detail_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)]);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('导出失败，请稍后重试')));
      }
    }
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

  String _momentTitle(MomentRecord record) {
    final content = (record.content ?? '').trim();
    if (content.isEmpty) return '小确幸';
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines.isEmpty ? '小确幸' : lines.first.trim();
  }

  String _travelTitle(TravelRecord record) {
    final title = record.title?.trim() ?? '';
    if (title.isNotEmpty) return title;
    final destination = record.destination?.trim() ?? '';
    return destination.isEmpty ? '旅行记录' : destination;
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final double? rating;

  @override
  Widget build(BuildContext context) {
    final filled = rating == null ? 0 : rating!.round().clamp(0, 5);
    return Row(
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            Icons.star,
            size: 16,
            color: i < filled ? const Color(0xFF2BCDEE) : const Color(0xFFE5E7EB),
          ),
      ],
    );
  }
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final cell = (constraints.maxWidth - gap * 2) / 3;
        final big = cell * 2 + gap;
        final height = cell * 3 + gap * 2;
        final thirdX = big + gap;
        final row2 = cell + gap;
        final row3 = cell * 2 + gap * 2;
        final moreCount = images.length > 5 ? images.length - 5 : 0;

        Widget buildCell({
          required double left,
          required double top,
          required double width,
          required double height,
          String? imageUrl,
          bool showMore = false,
          int more = 0,
          BorderRadius? radius,
        }) {
          return Positioned(
            left: left,
            top: top,
            width: width,
            height: height,
            child: ClipRRect(
              borderRadius: radius ?? BorderRadius.circular(16),
              child: Container(
                color: const Color(0xFFF3F4F6),
                child: imageUrl == null || imageUrl.isEmpty
                    ? (showMore
                        ? Container(
                            color: const Color(0xFFF8FAFC),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('+$more', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF6B7280))),
                                const SizedBox(height: 4),
                                const Text('查看更多', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                              ],
                            ),
                          )
                        : Container())
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildLocalImage(imageUrl, fit: BoxFit.cover),
                          if (showMore)
                            Container(
                              color: Colors.black.withValues(alpha: 0.35),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('+$more', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  const Text('查看更多', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70)),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          );
        }

        return SizedBox(
          height: height,
          child: Stack(
            children: [
              buildCell(
                left: 0,
                top: 0,
                width: big,
                height: big,
                imageUrl: images.isNotEmpty ? images[0] : null,
                radius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              buildCell(
                left: thirdX,
                top: 0,
                width: cell,
                height: cell,
                imageUrl: images.length > 1 ? images[1] : null,
                radius: const BorderRadius.only(topRight: Radius.circular(20)),
              ),
              buildCell(
                left: thirdX,
                top: row2,
                width: cell,
                height: cell,
                imageUrl: images.length > 2 ? images[2] : null,
              ),
              buildCell(
                left: 0,
                top: row3,
                width: cell,
                height: cell,
                imageUrl: images.length > 3 ? images[3] : null,
              ),
              buildCell(
                left: cell + gap,
                top: row3,
                width: cell,
                height: cell,
                imageUrl: images.length > 4 ? images[4] : null,
              ),
              buildCell(
                left: thirdX,
                top: row3,
                width: cell,
                height: cell,
                imageUrl: moreCount == 0 && images.length > 5 ? images[5] : (moreCount == 0 ? null : (images.length > 5 ? images[5] : null)),
                showMore: moreCount > 0,
                more: moreCount,
                radius: const BorderRadius.only(bottomRight: Radius.circular(20)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF2BCDEE) : const Color(0xFF6B7280);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap == null
          ? null
          : () {
              FocusManager.instance.primaryFocus?.unfocus();
              onTap!();
            },
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: onTap == null ? const Color(0xFFCBD5E1) : color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: onTap == null ? const Color(0xFFCBD5E1) : color),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color(0xFFE5E7EB),
    );
  }
}

class _LinkBlock extends StatelessWidget {
  const _LinkBlock({required this.icon, required this.title, required this.chips});

  final IconData icon;
  final String title;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2BCDEE), size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in chips)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0x1A2BCDEE), borderRadius: BorderRadius.circular(999)),
                  child: Text(c, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF2BCDEE))),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(999)),
                child: const Text('+ 添加', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FoodCreatePage extends ConsumerStatefulWidget {
  const FoodCreatePage({
    super.key,
    this.initialRecord,
    this.prefillTitle,
    this.prefillPoiName,
    this.prefillPoiAddress,
    this.prefillPricePerPerson,
    this.overrideIsWishlist,
    this.overrideWishlistDone,
    this.popWithResultOnPublish = false,
  });

  final FoodRecord? initialRecord;
  final String? prefillTitle;
  final String? prefillPoiName;
  final String? prefillPoiAddress;
  final double? prefillPricePerPerson;
  final bool? overrideIsWishlist;
  final bool? overrideWishlistDone;
  final bool popWithResultOnPublish;

  @override
  ConsumerState<FoodCreatePage> createState() => _FoodCreatePageState();
}

class _FoodCreatePageState extends ConsumerState<FoodCreatePage> {
  static const _primary = Color(0xFF2BCDEE);
  static const _backgroundDark = Color(0xFF102222);
  static const List<String> _systemTags = [
    '必吃榜',
    '周末探店',
    '辣',
    '火锅',
    '烤肉',
    '日料',
    '甜品',
    '咖啡',
  ];

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _priceController = TextEditingController();
  final _linkController = TextEditingController();

  var _rating = 4;
  var _isWishlist = false;
  var _wishlistDone = false;
  var _selectedMood = '开心';

  var _poiName = '';
  var _poiAddress = '';
  double? _latitude;
  double? _longitude;

  final _imageUrls = <String>[];
  final _availableTags = <String>[..._systemTags];
  final Set<String> _selectedTags = {};

  final _linkedFriends = <FriendRecord>[];
  final Set<String> _linkedTravelIds = {};
  final Set<String> _linkedGoalIds = {};

  @override
  void initState() {
    super.initState();
    final record = widget.initialRecord;
    if (record != null) {
      _titleController.text = record.title;
      _contentController.text = record.content ?? '';
      _linkController.text = record.link ?? '';
      if (record.pricePerPerson != null) {
        _priceController.text = record.pricePerPerson!.toString();
      }
      _rating = record.rating?.round() ?? _rating;
      _isWishlist = record.isWishlist;
      _wishlistDone = record.wishlistDone;
      _selectedMood = (record.mood ?? '').trim().isEmpty ? _selectedMood : record.mood!.trim();
      _poiName = (record.poiName ?? '').trim().isEmpty ? _poiName : record.poiName!.trim();
      _poiAddress = (record.city ?? '').trim().isEmpty ? _poiAddress : record.city!.trim();
      _latitude = record.latitude;
      _longitude = record.longitude;
      _imageUrls
        ..clear()
        ..addAll(_decodeStringList(record.images));
      final tags = _decodeStringList(record.tags);
      if (tags.isNotEmpty) {
        _selectedTags
          ..clear()
          ..addAll(tags);
        for (final t in tags) {
          if (!_availableTags.contains(t)) _availableTags.add(t);
        }
      }
      _loadInitialLinks(record.id);
    } else {
      if ((widget.prefillTitle ?? '').trim().isNotEmpty) {
        _titleController.text = widget.prefillTitle!.trim();
      }
      if ((widget.prefillPoiName ?? '').trim().isNotEmpty) {
        _poiName = widget.prefillPoiName!.trim();
      }
      if ((widget.prefillPoiAddress ?? '').trim().isNotEmpty) {
        _poiAddress = widget.prefillPoiAddress!.trim();
      }
      if (widget.prefillPricePerPerson != null) {
        _priceController.text = widget.prefillPricePerPerson!.toString();
      }
    }

    if (widget.overrideIsWishlist != null) {
      _isWishlist = widget.overrideIsWishlist!;
    }
    if (widget.overrideWishlistDone != null) {
      _wishlistDone = widget.overrideWishlistDone!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _priceController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialRecord != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.80),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 86,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
        ),
        title: Text(isEditing ? '编辑美食记录' : '新建美食记录', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: _backgroundDark,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
              onPressed: _publish,
              child: Text(isEditing ? '保存' : '发布'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _buildImageGrid(context),
          const SizedBox(height: 16),
          _buildRestaurantInfoCard(),
          const SizedBox(height: 16),
          _buildDetailsCard(context),
          const SizedBox(height: 16),
          _buildLocationCard(context),
          const SizedBox(height: 16),
          _buildUniversalLinkSection(context),
        ],
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _imageUrls.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showAddImageSheet(context),
            child: _DashedBorder(
              borderRadius: BorderRadius.circular(16),
              color: _primary.withValues(alpha: 0.30),
              strokeWidth: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: _primary.withValues(alpha: 0.10), shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: _primary, size: 24),
                    ),
                    const SizedBox(height: 8),
                    const Text('添加照片', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
            ),
          );
        }

        final imageUrl = _imageUrls[index - 1];
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(child: _buildLocalImage(imageUrl, fit: BoxFit.cover)),
              Positioned(
                top: 6,
                right: 6,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => setState(() => _imageUrls.removeAt(index - 1)),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.50),
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
    );
  }

  Widget _buildRestaurantInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            decoration: const InputDecoration(
              hintText: '输入餐厅名称...',
              hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF)),
              prefixIcon: Icon(Icons.storefront, color: _primary, size: 22),
              prefixIconConstraints: BoxConstraints(minWidth: 40, minHeight: 40),
              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 0),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF3F4F6))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _primary)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('推荐指数', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
              Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      onPressed: () => setState(() => _rating = i),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: Icon(
                        Icons.star,
                        size: 28,
                        color: i <= _rating ? _primary : const Color(0xFFE5E7EB),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('评价/描述', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.6)),
          const SizedBox(height: 8),
          TextField(
            controller: _contentController,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: '记录你的就餐体验...',
              hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _primary.withValues(alpha: 0.60)),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.payments,
            label: '人均消费',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('¥', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
                const SizedBox(width: 4),
                SizedBox(
                  width: 88,
                  child: TextField(
                    controller: _priceController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(color: Color(0xFFE5E7EB)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildDetailRow(
            icon: Icons.link,
            label: '相关链接',
            trailing: Expanded(
              child: TextField(
                controller: _linkController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.url,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                decoration: const InputDecoration(
                  hintText: '添加店铺或外卖链接...',
                  hintStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFE5E7EB)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('标签', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.6)),
              TextButton(
                onPressed: () => _showEditTagsSheet(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: _primary,
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
                child: const Text('编辑'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final t in _availableTags)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      final selected = _selectedTags.contains(t);
                      setState(() {
                        if (selected) {
                          _selectedTags.remove(t);
                        } else {
                          _selectedTags.add(t);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTags.contains(t) ? const Color(0x1A2BCDEE) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _selectedTags.contains(t) ? const Color(0x332BCDEE) : const Color(0xFFF3F4F6)),
                      ),
                      child: Text(
                        '# $t',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _selectedTags.contains(t) ? const Color(0xFF22BEBE) : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showEditTagsSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
                      color: Colors.transparent,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: Color(0xFF9CA3AF)),
                        SizedBox(width: 4),
                        Text('添加', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('标记为心愿餐厅', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    SizedBox(height: 4),
                    Text('开启后将同步保存至“心愿单”标签页', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              Switch(
                value: _isWishlist,
                activeThumbColor: _primary,
                activeTrackColor: _primary.withValues(alpha: 0.35),
                onChanged: (v) => setState(() => _isWishlist = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: _primary.withValues(alpha: 0.10), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: _primary),
          ),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
        final result = await Navigator.of(context).push<AmapLocationPickResult>(
          MaterialPageRoute(
            builder: (_) => AmapLocationPage.pick(
              initialPoiName: _poiName,
              initialAddress: _poiAddress,
              initialLatitude: _latitude,
              initialLongitude: _longitude,
            ),
          ),
        );
        if (!mounted) return;
        if (result == null) return;
        setState(() {
          _poiName = result.poiName;
          _poiAddress = result.address;
          _latitude = result.latitude;
          _longitude = result.longitude;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: const Color(0xFFEFF6FF),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCOjYFA8MIz3Oj8GOSc5C5RfL3KQNJAqyST0AcNGbGifa7s-82Q18x6DMtiRuIzM1sHBRjMcx8vnQaYiM4jWAukrciwb3mw4i4LefTvt9EtTLflZP4EVa9w7kssTN5ocVWOA97IhuVDi_PMzuolLhvdKjfRdKqGNEUHzc0aqPxYrE7VszbkM2mmO2ToJzh9YDY0vS3ijvR-t4aMxI8D1W78TKS1vn8Eq4UCJIg7xo_6vfbcwbyfvK3b-BwZxG8f_dddkgLUkLaUTdfm',
                  ),
                  fit: BoxFit.cover,
                  opacity: 0.50,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.place, color: Color(0xFF3B82F6), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _poiName.trim().isEmpty ? '请选择地点' : _poiName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _poiAddress.trim().isEmpty ? '点击选择地址' : _poiAddress,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }

  Widget _buildUniversalLinkSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: '万物互联'),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 6))],
            ),
            child: Column(
              children: [
                _UniversalLinkRow(
                  icon: Icons.people,
                  iconBg: const Color(0xFFEDE9FE),
                  iconColor: const Color(0xFF7C3AED),
                  title: '关联朋友',
                  trailing: _buildFriendTrailing(),
                  onTap: () => _showLinkFriendsSheet(context),
                ),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                _UniversalLinkRow(
                  icon: Icons.flight_takeoff,
                  iconBg: const Color(0xFFFFEDD5),
                  iconColor: const Color(0xFFEA580C),
                  title: '关联旅行',
                  trailing: _buildTravelTrailing(),
                  onTap: () => _showLinkTravelsSheet(context),
                ),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                _UniversalLinkRow(
                  icon: Icons.flag,
                  iconBg: const Color(0xFFE0F2FE),
                  iconColor: const Color(0xFF0284C7),
                  title: '关联目标',
                  trailing: _buildGoalTrailing(),
                  onTap: () => _showLinkGoalsSheet(context),
                ),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                _UniversalLinkRow(
                  icon: Icons.mood,
                  iconBg: const Color(0xFFFCE7F3),
                  iconColor: const Color(0xFFDB2777),
                  title: '关联心情',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF2F8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(_selectedMood, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFDB2777))),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, size: 18, color: Color(0xFFD1D5DB)),
                    ],
                  ),
                  onTap: () => _showSelectMoodSheet(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendTrailing() {
    if (_linkedFriends.isEmpty) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('选择朋友档案', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
          SizedBox(width: 6),
          Icon(Icons.chevron_right, size: 18, color: Color(0xFFD1D5DB)),
        ],
      );
    }

    final avatars = _linkedFriends.take(3).toList();
    final stackWidth = 26.0 + (avatars.length - 1) * 16.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: stackWidth,
          height: 26,
          child: Stack(
            children: [
              for (var i = 0; i < avatars.length; i++)
                Positioned(
                  left: i * 16.0,
                  child: _SmallAvatar(friend: avatars[i]),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.chevron_right, size: 18, color: Color(0xFFD1D5DB)),
      ],
    );
  }

  Widget _buildTravelTrailing() {
    if (_linkedTravelIds.isEmpty) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('选择旅行记录', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
          SizedBox(width: 6),
          Icon(Icons.chevron_right, size: 18, color: Color(0xFFD1D5DB)),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(999)),
          child: Text('已选 ${_linkedTravelIds.length} 条', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFEA580C))),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right, size: 18, color: Color(0xFFD1D5DB)),
      ],
    );
  }

  Widget _buildGoalTrailing() {
    if (_linkedGoalIds.isEmpty) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('选择人生目标', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
          SizedBox(width: 6),
          Icon(Icons.chevron_right, size: 18, color: Color(0xFFD1D5DB)),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(999)),
          child: Text('已选 ${_linkedGoalIds.length} 条', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right, size: 18, color: Color(0xFFD1D5DB)),
      ],
    );
  }

  Future<void> _showAddImageSheet(BuildContext context) async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;
    final stored = await _persistImages(files);
    if (stored.isEmpty) return;
    setState(() => _imageUrls.addAll(stored));
  }

  Future<List<String>> _persistImages(List<XFile> files) async {
    return persistImageFiles(files, folder: 'food', prefix: 'food');
  }

  Future<void> _showEditTagsSheet(BuildContext context) async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetShell(
          title: '编辑标签',
          child: StatefulBuilder(
            builder: (context, setInnerState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: '新增标签（不含#）',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: _backgroundDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        onPressed: () {
                          final v = controller.text.trim();
                          if (v.isEmpty) return;
                          if (_availableTags.contains(v)) return;
                          setState(() => _availableTags.add(v));
                          setInnerState(() {});
                          controller.clear();
                        },
                        child: const Text('添加'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final t in _availableTags)
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () {
                              setState(() {
                                _availableTags.remove(t);
                                _selectedTags.remove(t);
                              });
                              setInnerState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text('# $t  ×', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: _primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('完成'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    controller.dispose();
  }

  Future<void> _showSelectMoodSheet(BuildContext context) async {
    const moods = ['开心', '治愈', '平静', '兴奋', '难过', '疲惫'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetShell(
          title: '选择心情',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final m in moods)
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.of(context).pop(m),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: m == _selectedMood ? const Color(0xFFFDF2F8) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: m == _selectedMood ? const Color(0xFFDB2777) : const Color(0xFFF3F4F6)),
                    ),
                    child: Text(m, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: m == _selectedMood ? const Color(0xFFDB2777) : const Color(0xFF6B7280))),
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (selected == null) return;
    setState(() => _selectedMood = selected);
  }

  Future<void> _showLinkFriendsSheet(BuildContext context) async {
    final db = ref.read(appDatabaseProvider);
    final initial = _linkedFriends.map((e) => e.id).toSet();
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        var selected = initial;
        return _BottomSheetShell(
          title: '关联朋友',
          child: StatefulBuilder(
            builder: (context, setInnerState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 420),
                    child: StreamBuilder<List<FriendRecord>>(
                      stream: db.friendDao.watchAllActive(),
                      builder: (context, snapshot) {
                        final items = snapshot.data ?? const <FriendRecord>[];
                        if (items.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Text('暂无朋友档案', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final f = items[index];
                            final checked = selected.contains(f.id);
                            return ListTile(
                              leading: _SmallAvatar(friend: f, radius: 18),
                              title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                              trailing: Checkbox(
                                value: checked,
                                onChanged: (v) {
                                  final next = {...selected};
                                  if (v == true) {
                                    next.add(f.id);
                                  } else {
                                    next.remove(f.id);
                                  }
                                  selected = next;
                                  setInnerState(() {});
                                },
                              ),
                              onTap: () {
                                final next = {...selected};
                                if (checked) {
                                  next.remove(f.id);
                                } else {
                                  next.add(f.id);
                                }
                                selected = next;
                                setInnerState(() {});
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: _backgroundDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      onPressed: () => Navigator.of(context).pop(selected),
                      child: const Text('完成'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (result == null) return;
    final all = await db.friendDao.watchAllActive().first;
    setState(() {
      _linkedFriends
        ..clear()
        ..addAll(all.where((e) => result.contains(e.id)));
    });
  }

  Stream<List<TravelRecord>> _watchTravelRecords() {
    return ref.read(appDatabaseProvider).watchAllActiveTravelRecords();
  }

  Stream<List<TimelineEvent>> _watchGoalEvents() {
    final db = ref.read(appDatabaseProvider);
    return (db.select(db.timelineEvents)
          ..where((t) => t.eventType.equals('goal'))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<void> _showLinkTravelsSheet(BuildContext context) async {
    final initial = {..._linkedTravelIds};
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        var selected = initial;
        return _BottomSheetShell(
          title: '关联旅行',
          child: StatefulBuilder(
            builder: (context, setInnerState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 420),
                    child: StreamBuilder<List<TravelRecord>>(
                      stream: _watchTravelRecords(),
                      builder: (context, snapshot) {
                        final items = snapshot.data ?? const <TravelRecord>[];
                        if (items.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Text('暂无旅行记录', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final t = items[index];
                            final checked = selected.contains(t.id);
                            return ListTile(
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.flight_takeoff, color: Color(0xFF22C55E)),
                              ),
                              title: Text(t.title?.isNotEmpty == true ? t.title! : '旅行记录', style: const TextStyle(fontWeight: FontWeight.w800)),
                              trailing: Checkbox(
                                value: checked,
                                onChanged: (v) {
                                  final next = {...selected};
                                  if (v == true) {
                                    next.add(t.id);
                                  } else {
                                    next.remove(t.id);
                                  }
                                  selected = next;
                                  setInnerState(() {});
                                },
                              ),
                              onTap: () {
                                final next = {...selected};
                                if (checked) {
                                  next.remove(t.id);
                                } else {
                                  next.add(t.id);
                                }
                                selected = next;
                                setInnerState(() {});
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: _backgroundDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      onPressed: () => Navigator.of(context).pop(selected),
                      child: const Text('完成'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (result == null) return;
    setState(() {
      _linkedTravelIds
        ..clear()
        ..addAll(result);
    });
  }

  Future<void> _showLinkGoalsSheet(BuildContext context) async {
    final initial = {..._linkedGoalIds};
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        var selected = initial;
        return _BottomSheetShell(
          title: '关联人生目标',
          child: StatefulBuilder(
            builder: (context, setInnerState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 420),
                    child: StreamBuilder<List<TimelineEvent>>(
                      stream: _watchGoalEvents(),
                      builder: (context, snapshot) {
                        final items = snapshot.data ?? const <TimelineEvent>[];
                        if (items.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Text('暂无人生目标', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final g = items[index];
                            final checked = selected.contains(g.id);
                            return ListTile(
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.flag, color: Color(0xFF0284C7)),
                              ),
                              title: Text(g.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                              trailing: Checkbox(
                                value: checked,
                                onChanged: (v) {
                                  final next = {...selected};
                                  if (v == true) {
                                    next.add(g.id);
                                  } else {
                                    next.remove(g.id);
                                  }
                                  selected = next;
                                  setInnerState(() {});
                                },
                              ),
                              onTap: () {
                                final next = {...selected};
                                if (checked) {
                                  next.remove(g.id);
                                } else {
                                  next.add(g.id);
                                }
                                selected = next;
                                setInnerState(() {});
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: _backgroundDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      onPressed: () => Navigator.of(context).pop(selected),
                      child: const Text('完成'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (result == null) return;
    setState(() {
      _linkedGoalIds
        ..clear()
        ..addAll(result);
    });
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先填写餐厅名称')));
      return;
    }

    final db = ref.read(appDatabaseProvider);
    const uuid = Uuid();
    final now = DateTime.now();
    final existing = widget.initialRecord;
    final foodId = existing?.id ?? uuid.v4();
    final recordDate = existing?.recordDate ?? DateTime(now.year, now.month, now.day);
    final createdAt = existing?.createdAt ?? now;
    final isFavorite = existing?.isFavorite ?? false;

    final content = _contentController.text.trim();
    final link = _linkController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final selectedTags = _availableTags.where(_selectedTags.contains).toList();
    final wishlistDone = _isWishlist ? false : _wishlistDone;

    await db.foodDao.upsert(
      FoodRecordsCompanion.insert(
        id: foodId,
        title: title,
        content: Value(content.isEmpty ? null : content),
        images: Value(_imageUrls.isEmpty ? null : jsonEncode(_imageUrls)),
        tags: Value(selectedTags.isEmpty ? null : jsonEncode(selectedTags)),
        rating: Value(_rating <= 0 ? null : _rating.toDouble()),
        pricePerPerson: Value(price),
        link: Value(link.isEmpty ? null : link),
        poiName: Value(_poiName.trim().isEmpty ? null : _poiName.trim()),
        poiAddress: Value(_poiAddress.trim().isEmpty ? null : _poiAddress.trim()),
        city: Value(_poiAddress.trim().isEmpty ? null : _poiAddress.trim()),
        latitude: Value(_latitude),
        longitude: Value(_longitude),
        mood: Value(_selectedMood.trim().isEmpty ? null : _selectedMood.trim()),
        isWishlist: Value(_isWishlist),
        isFavorite: Value(isFavorite),
        wishlistDone: Value(wishlistDone),
        recordDate: recordDate,
        createdAt: createdAt,
        updatedAt: now,
      ),
    );

    if (existing != null) {
      final existingLinks = await db.linkDao.listLinksForEntity(entityType: 'food', entityId: foodId);
      for (final link in existingLinks) {
        await db.linkDao.deleteLink(
          sourceType: link.sourceType,
          sourceId: link.sourceId,
          targetType: link.targetType,
          targetId: link.targetId,
          now: now,
        );
      }
    }

    for (final f in _linkedFriends) {
      await db.linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'friend',
        targetId: f.id,
        now: now,
      );
    }
    for (final id in _linkedTravelIds) {
      await db.linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'travel',
        targetId: id,
        now: now,
      );
    }
    for (final id in _linkedGoalIds) {
      await db.linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'goal',
        targetId: id,
        now: now,
      );
    }

    if (!mounted) return;
    if (widget.popWithResultOnPublish) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pop();
    }
  }

  List<String> _decodeStringList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toList(growable: false);
      }
    } catch (_) {}
    return const [];
  }

  Future<void> _loadInitialLinks(String foodId) async {
    final db = ref.read(appDatabaseProvider);
    final links = await db.linkDao.listLinksForEntity(entityType: 'food', entityId: foodId);
    final friendIds = <String>{};
    final travelIds = <String>{};
    final goalIds = <String>{};
    for (final link in links) {
      final isSource = link.sourceType == 'food' && link.sourceId == foodId;
      final otherType = isSource ? link.targetType : link.sourceType;
      final otherId = isSource ? link.targetId : link.sourceId;
      if (otherType == 'friend') {
        friendIds.add(otherId);
      } else if (otherType == 'travel') {
        travelIds.add(otherId);
      } else if (otherType == 'goal') {
        goalIds.add(otherId);
      }
    }
    final friends = <FriendRecord>[];
    for (final id in friendIds) {
      final friend = await db.friendDao.findById(id);
      if (friend != null) friends.add(friend);
    }
    if (!mounted) return;
    setState(() {
      _linkedFriends
        ..clear()
        ..addAll(friends);
      _linkedTravelIds
        ..clear()
        ..addAll(travelIds);
      _linkedGoalIds
        ..clear()
        ..addAll(goalIds);
    });
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: _FoodCreatePageState._primary, borderRadius: BorderRadius.circular(999))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
      ],
    );
  }
}

class _UniversalLinkRow extends StatelessWidget {
  const _UniversalLinkRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSheetShell extends StatelessWidget {
  const _BottomSheetShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 16 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900))),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _DateFilterResult {
  const _DateFilterResult({
    required this.dateIndex,
    required this.customRange,
  });

  final int dateIndex;
  final DateTimeRange? customRange;
}

class _DateFilterSheet extends StatefulWidget {
  const _DateFilterSheet({
    required this.initialDateIndex,
    required this.initialCustomRange,
  });

  final int initialDateIndex;
  final DateTimeRange? initialCustomRange;

  @override
  State<_DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<_DateFilterSheet> {
  static const _dateOptions = ['不限', '今日', '近7天', '近30天', '自定义'];

  late int _dateIndex;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _dateIndex = widget.initialDateIndex;
    _customRange = widget.initialCustomRange;
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
                    const Expanded(child: Text('日期范围', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(_DateFilterResult(dateIndex: _dateIndex, customRange: _customRange)),
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

class _CompanionFilterResult {
  const _CompanionFilterResult({
    required this.friendIds,
    required this.solo,
  });

  final Set<String> friendIds;
  final bool solo;
}

class _CompanionFilterSheet extends StatefulWidget {
  const _CompanionFilterSheet({
    required this.initialFriendIds,
    required this.initialSolo,
    required this.friendsStream,
  });

  final Set<String> initialFriendIds;
  final bool initialSolo;
  final Stream<List<FriendRecord>> friendsStream;

  @override
  State<_CompanionFilterSheet> createState() => _CompanionFilterSheetState();
}

class _CompanionFilterSheetState extends State<_CompanionFilterSheet> {
  late Set<String> _selectedFriendIds;
  late bool _solo;

  @override
  void initState() {
    super.initState();
    _selectedFriendIds = {...widget.initialFriendIds};
    _solo = widget.initialSolo;
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
                    const Expanded(child: Text('同伴', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(_CompanionFilterResult(friendIds: _selectedFriendIds, solo: _solo)),
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
                      _FilterFriendTile(
                        name: '独享',
                        checked: _solo,
                        onTap: () => setState(() => _solo = !_solo),
                      ),
                      const SizedBox(height: 12),
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

class _RatingFilterSheet extends StatefulWidget {
  const _RatingFilterSheet({required this.initialRatings});

  final Set<int> initialRatings;

  @override
  State<_RatingFilterSheet> createState() => _RatingFilterSheetState();
}

class _RatingFilterSheetState extends State<_RatingFilterSheet> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialRatings};
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
                    const Expanded(child: Text('评分', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(_selected),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF2BCDEE), textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                      child: const Text('完成'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var i = 1; i <= 5; i++)
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {
                          setState(() {
                            if (_selected.contains(i)) {
                              _selected.remove(i);
                            } else {
                              _selected.add(i);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selected.contains(i) ? const Color(0xFF2BCDEE).withValues(alpha: 0.12) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _selected.contains(i) ? const Color(0xFF2BCDEE).withValues(alpha: 0.3) : const Color(0xFFF3F4F6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 16, color: Color(0xFFFB923C)),
                              const SizedBox(width: 6),
                              Text(
                                '$i 星',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _selected.contains(i) ? const Color(0xFF2BCDEE) : const Color(0xFF64748B),
                                ),
                              ),
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
      ),
    );
  }
}

class _CityFilterSheet extends StatefulWidget {
  const _CityFilterSheet({
    required this.initialCities,
    required this.recordsStream,
  });

  final Set<String> initialCities;
  final Stream<List<FoodRecord>> recordsStream;

  @override
  State<_CityFilterSheet> createState() => _CityFilterSheetState();
}

class _CityFilterSheetState extends State<_CityFilterSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialCities};
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
                    const Expanded(child: Text('城市', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(_selected),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF2BCDEE), textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                      child: const Text('完成'),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
                child: StreamBuilder<List<FoodRecord>>(
                  stream: widget.recordsStream,
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? const <FoodRecord>[];
                    final cities = <String>{};
                    for (final r in items) {
                      final city = _resolveFoodCity(r);
                      if (city.isNotEmpty) cities.add(city);
                    }
                    final list = cities.toList(growable: false)..sort();
                    if (list.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(child: Text('暂无已落库城市', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF)))),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final city = list[index];
                        final checked = _selected.contains(city);
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              if (checked) {
                                _selected.remove(city);
                              } else {
                                _selected.add(city);
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
                                Expanded(child: Text(city, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827)))),
                                Icon(checked ? Icons.check_circle : Icons.radio_button_unchecked, color: checked ? const Color(0xFF2BCDEE) : const Color(0xFFCBD5E1)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
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
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onTap();
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

String _resolveFoodCity(FoodRecord record) {
  final poiAddress = (record.poiAddress ?? '').trim();
  final cityRaw = (record.city ?? '').trim();
  if (poiAddress.isEmpty && cityRaw.isEmpty) return '';

  final fromPoi = _extractCityToken(poiAddress);
  if (fromPoi.isNotEmpty) return fromPoi;

  final fromCity = _extractCityToken(cityRaw);
  if (fromCity.isNotEmpty) return fromCity;

  return '未知';
}

String _extractCityToken(String input) {
  final s = input.trim();
  if (s.isEmpty) return '';
  final m1 = RegExp(r'([\u4e00-\u9fa5]{2,10}市)').firstMatch(s);
  if (m1 != null) return m1.group(1) ?? '';
  final m2 = RegExp(r'([\u4e00-\u9fa5]{2,10}州)').firstMatch(s);
  if (m2 != null) return m2.group(1) ?? '';
  final m3 = RegExp(r'([\u4e00-\u9fa5]{2,10}地区)').firstMatch(s);
  if (m3 != null) return m3.group(1) ?? '';
  final first = s.split(RegExp(r'[\s,，/]+')).first.trim();
  return first.length > 12 ? '' : first;
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

class _SmallAvatar extends StatelessWidget {
  const _SmallAvatar({required this.friend, this.radius = 13});

  final FriendRecord friend;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final path = (friend.avatarPath ?? '').trim();
    final canNetwork = path.startsWith('http://') || path.startsWith('https://');
    final initials = friend.name.isEmpty ? '?' : friend.name.characters.first;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE5E7EB),
        backgroundImage: canNetwork ? NetworkImage(path) : null,
        child: canNetwork ? null : Text(initials, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6B7280))),
      ),
    );
  }
}

class _DashedBorder extends StatelessWidget {
  const _DashedBorder({
    required this.child,
    required this.borderRadius,
    required this.color,
    required this.strokeWidth,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        borderRadius: borderRadius,
        color: color,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.borderRadius,
    required this.color,
    required this.strokeWidth,
  });

  final BorderRadius borderRadius;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    const dashWidth = 6.0;
    const dashSpace = 4.0;

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius || oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
