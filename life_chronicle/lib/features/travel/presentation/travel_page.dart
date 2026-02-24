import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drift/drift.dart' show Value, OrderingTerm, OrderingMode;
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/utils/media_storage.dart';
import '../../../core/widgets/ai_parse_button.dart';
import '../../../core/widgets/amap_location_page.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

enum _TravelViewMode { wishlist, onTheRoad }

class _TravelPageState extends State<TravelPage> {
  _TravelViewMode _mode = _TravelViewMode.onTheRoad;
  var _filterDateIndex = 0;
  DateTimeRange? _filterCustomRange;
  Set<String> _filterFriendIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _TravelTopBar()),
            SliverToBoxAdapter(child: _TravelSearchRow(onFilterTap: _openFilterSheet, controller: _searchController)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedHeaderDelegate(
                height: 56,
                child: _TravelModeSwitch(
                  mode: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
              sliver: SliverToBoxAdapter(
                child: _mode == _TravelViewMode.onTheRoad
                    ? _TravelOnTheRoadView(
                        searchQuery: _searchQuery,
                        filterDateIndex: _filterDateIndex,
                        filterCustomRange: _filterCustomRange,
                        filterFriendIds: _filterFriendIds,
                      )
                    : _TravelWishlistView(
                        searchQuery: _searchQuery,
                        filterDateIndex: _filterDateIndex,
                        filterCustomRange: _filterCustomRange,
                        filterFriendIds: _filterFriendIds,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TravelTopBar extends StatelessWidget {
  const _TravelTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          const SizedBox(width: 48),
          const Expanded(
            child: Text(
              '人生路漫漫',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
            ),
          ),
          SizedBox(
              width: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: AiParseButton(text: '解析', onPressed: () {}),
              ),
            ),
        ],
      ),
    );
  }
}

class _TravelSearchRow extends StatelessWidget {
  const _TravelSearchRow({required this.onFilterTap, required this.controller});

  final VoidCallback onFilterTap;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF94A3B8), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: '搜索城市、标签、地理位置...',
                        hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _SquareIconButton(icon: Icons.tune, onTap: onFilterTap),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(width: 44, height: 44, child: Icon(icon, color: const Color(0xFF64748B), size: 22)),
      ),
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF6F8F8),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class _TravelModeSwitch extends StatelessWidget {
  const _TravelModeSwitch({required this.mode, required this.onChanged});

  final _TravelViewMode mode;
  final ValueChanged<_TravelViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TravelModePill(
              label: '愿望清单',
              selected: mode == _TravelViewMode.wishlist,
              onTap: () => onChanged(_TravelViewMode.wishlist),
            ),
          ),
          Expanded(
            child: _TravelModePill(
              label: '在路上',
              selected: mode == _TravelViewMode.onTheRoad,
              onTap: () => onChanged(_TravelViewMode.onTheRoad),
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelModePill extends StatelessWidget {
  const _TravelModePill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF2BCDEE) : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

class _TravelOnTheRoadView extends ConsumerWidget {
  const _TravelOnTheRoadView({
    required this.searchQuery,
    required this.filterDateIndex,
    required this.filterCustomRange,
    required this.filterFriendIds,
  });

  final String searchQuery;
  final int filterDateIndex;
  final DateTimeRange? filterCustomRange;
  final Set<String> filterFriendIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder<List<TravelRecord>>(
      stream: db.watchAllActiveTravelRecords(),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <TravelRecord>[];
        var filtered = records.where((r) => !r.isWishlist).toList(growable: false);

        final searchLower = searchQuery.toLowerCase().trim();
        if (searchLower.isNotEmpty) {
          filtered = filtered.where((r) {
            final title = (r.title ?? '').toLowerCase();
            final destination = (r.destination ?? '').toLowerCase();
            final tags = (_decodeStringList(r.tags) ?? <String>[]).join(' ').toLowerCase();
            return title.contains(searchLower) ||
                destination.contains(searchLower) ||
                tags.contains(searchLower);
          }).toList(growable: false);
        }

        if (filtered.isEmpty) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _TravelFootprintCard(onTap: null),
              SizedBox(height: 18),
              _EmptyTravelState(label: '暂无旅行记录，去添加第一段旅程吧'),
            ],
          );
        }

        final tripIds = filtered.map((e) => e.tripId).toSet().toList();
        return StreamBuilder<List<Trip>>(
          stream: _watchTripsByIds(db, tripIds),
          builder: (context, tripSnapshot) {
            final trips = tripSnapshot.data ?? const <Trip>[];
            return StreamBuilder<List<EntityLink>>(
              stream: db.select(db.entityLinks).watch(),
              builder: (context, linkSnapshot) {
                final links = linkSnapshot.data ?? const <EntityLink>[];

                var finalRecords = filtered;
                if (filterFriendIds.isNotEmpty) {
                  final friendIdsByTravel = <String, Set<String>>{};
                  for (final link in links) {
                    String? travelId;
                    if (link.sourceType == 'travel' && link.targetType == 'friend') {
                      travelId = link.sourceId;
                      final set = friendIdsByTravel.putIfAbsent(travelId, () => <String>{});
                      set.add(link.targetId);
                    } else if (link.targetType == 'travel' && link.sourceType == 'friend') {
                      travelId = link.targetId;
                      final set = friendIdsByTravel.putIfAbsent(travelId, () => <String>{});
                      set.add(link.sourceId);
                    }
                  }
                  finalRecords = finalRecords.where((r) {
                    final linkedFriendIds = friendIdsByTravel[r.id] ?? <String>{};
                    return filterFriendIds.any((id) => linkedFriendIds.contains(id));
                  }).toList(growable: false);
                }

                if (finalRecords.isEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _TravelFootprintCard(onTap: null),
                      SizedBox(height: 18),
                      _EmptyTravelState(label: '没有匹配的旅行记录'),
                    ],
                  );
                }

                return StreamBuilder<List<FriendRecord>>(
                  stream: db.friendDao.watchAllActive(),
                  builder: (context, friendSnapshot) {
                    final friends = friendSnapshot.data ?? const <FriendRecord>[];
                    final entries = _buildTravelEntries(
                      records: finalRecords,
                      trips: trips,
                      friends: friends,
                      links: links,
                    );
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TravelFootprintCard(onTap: () {}),
                        const SizedBox(height: 18),
                        _TravelOnTheRoadTimeline(entries: entries),
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
  }
}

class _TravelOnTheRoadEntry {
  const _TravelOnTheRoadEntry({
    required this.year,
    required this.dateRange,
    required this.durationDays,
    required this.place,
    required this.imageUrl,
    required this.companions,
    required this.item,
  });

  final int year;
  final String dateRange;
  final int durationDays;
  final String place;
  final String imageUrl;
  final List<_CompanionInfo> companions;
  final TravelItem item;
}

class _TravelFootprintCard extends StatelessWidget {
  const _TravelFootprintCard({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            boxShadow: [BoxShadow(color: const Color(0xFF2BCDEE).withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 12))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                SizedBox(
                  height: 132,
                  width: double.infinity,
                  child: _buildLocalImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDcni2LwtmaarwLbusdF4hZ0n64Ccbqcro_mNlE1JoQ2W7xan2Np-aL-NR0r1mERCSWD-VrgAjgPTreKg7rOJG9pEmzgkxybMW6FiEQsie94nkXwMeYNfqLdMypoYLsM_gxZuODk_-9XmCjo5SikmTNZtEUM48dwCkfdgO8YzEGhUBCwW5EEGncwjnEUcgtdljEfYCFtXRijdDC1xfkzgrno5ctBJDtBD9oohKBGaO_DSbSe1M87lySWl4_APrOOnE5Bw4-EAcJO1jc',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '我的足迹',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xE6FFFFFF)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '12 个国家，45 座城市',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(color: Color(0xFF2BCDEE), shape: BoxShape.circle),
                        child: const Icon(Icons.map, color: Colors.white, size: 18),
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

class _TravelOnTheRoadTimeline extends StatelessWidget {
  const _TravelOnTheRoadTimeline({required this.entries});

  final List<_TravelOnTheRoadEntry> entries;

  @override
  Widget build(BuildContext context) {
    final byYear = <int, List<_TravelOnTheRoadEntry>>{};
    for (final e in entries) {
      byYear.putIfAbsent(e.year, () => []).add(e);
    }
    final years = byYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return _TimelineColumn(
      children: [
        for (final year in years) ...[
          _TimelineYearHeader(year: year),
          for (final entry in byYear[year]!) _TimelineTripEntry(entry: entry),
        ],
      ],
    );
  }
}

class _TimelineColumn extends StatelessWidget {
  const _TimelineColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _TimelineLinePainter(),
      child: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class _TimelineLinePainter extends CustomPainter {
  const _TimelineLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()..color = const Color(0xFFE5E7EB)..strokeWidth = 2..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(14, 0), Offset(14, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _TimelineLinePainter oldDelegate) => false;
}

class _TimelineYearHeader extends StatelessWidget {
  const _TimelineYearHeader({required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-24, 0),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF2BCDEE),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF6F8F8), width: 2),
              ),
            ),
          ),
          Text(
            '$year',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
          ),
        ],
      ),
    );
  }
}

class _TimelineTripEntry extends StatelessWidget {
  const _TimelineTripEntry({required this.entry});

  final _TravelOnTheRoadEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Stack(
        children: [
          Positioned(
            left: -15,
            top: 26,
            child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFD1D5DB), shape: BoxShape.circle)),
          ),
          const Positioned(
            left: -10,
            top: 30,
            child: SizedBox(width: 10, height: 2, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFE5E7EB)))),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.dateRange,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE)),
              ),
              const SizedBox(height: 10),
              _TravelOnRoadCard(entry: entry),
            ],
          ),
        ],
      ),
    );
  }
}

class _TravelOnRoadCard extends StatelessWidget {
  const _TravelOnRoadCard({required this.entry});

  final _TravelOnTheRoadEntry entry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TravelDetailPage(item: entry.item))),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: SizedBox(
                  height: 160,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildLocalImage(entry.imageUrl, fit: BoxFit.cover),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flight_takeoff, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text('${entry.durationDays} 天', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
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
                    Text(entry.place, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (entry.companions.isNotEmpty)
                          SizedBox(
                            width: entry.companions.length > 2
                                ? 52
                                : (entry.companions.length == 2 ? 38 : 24),
                            height: 24,
                            child: Stack(
                              children: [
                                for (var i = 0; i < entry.companions.length && i < 2; i++)
                                  Positioned(
                                    left: i * 14.0,
                                    child: _CompanionAvatar(info: entry.companions[i]),
                                  ),
                                if (entry.companions.length > 2)
                                  Positioned(
                                    left: 28,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2E8F0),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: Text(
                                        '+${entry.companions.length - 2}',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (entry.companions.isNotEmpty) const SizedBox(width: 14),
                        if (entry.companions.isNotEmpty) Container(width: 1, height: 14, color: const Color(0xFFE2E8F0)),
                        if (entry.companions.isNotEmpty) const SizedBox(width: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2BCDEE).withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.restaurant, size: 14, color: Color(0xFF2BCDEE)),
                              SizedBox(width: 6),
                              Text('美食', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF4B5563))),
                            ],
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

class _TravelWishlistView extends ConsumerWidget {
  const _TravelWishlistView({
    required this.searchQuery,
    required this.filterDateIndex,
    required this.filterCustomRange,
    required this.filterFriendIds,
  });

  final String searchQuery;
  final int filterDateIndex;
  final DateTimeRange? filterCustomRange;
  final Set<String> filterFriendIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder<List<TravelRecord>>(
      stream: db.watchAllActiveTravelRecords(),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <TravelRecord>[];
        var filtered = records.where((r) => r.isWishlist).toList(growable: false);

        final searchLower = searchQuery.toLowerCase().trim();
        if (searchLower.isNotEmpty) {
          filtered = filtered.where((r) {
            final title = (r.title ?? '').toLowerCase();
            final destination = (r.destination ?? '').toLowerCase();
            final tags = (_decodeStringList(r.tags) ?? <String>[]).join(' ').toLowerCase();
            return title.contains(searchLower) ||
                destination.contains(searchLower) ||
                tags.contains(searchLower);
          }).toList(growable: false);
        }

        if (filtered.isEmpty) {
          return const _EmptyTravelState(label: '暂无心愿清单，去添加目的地吧');
        }
        final tripIds = filtered.map((e) => e.tripId).toSet().toList();
        return StreamBuilder<List<Trip>>(
          stream: _watchTripsByIds(db, tripIds),
          builder: (context, tripSnapshot) {
            final trips = tripSnapshot.data ?? const <Trip>[];
            final tripById = {for (final t in trips) t.id: t};
            
            var finalRecords = filtered;
            if (filterFriendIds.isNotEmpty) {
              return StreamBuilder<List<EntityLink>>(
                stream: db.select(db.entityLinks).watch(),
                builder: (context, linkSnapshot) {
                  final links = linkSnapshot.data ?? const <EntityLink>[];
                  final friendIdsByTravel = <String, Set<String>>{};
                  for (final link in links) {
                    String? travelId;
                    if (link.sourceType == 'travel' && link.targetType == 'friend') {
                      travelId = link.sourceId;
                      final set = friendIdsByTravel.putIfAbsent(travelId, () => <String>{});
                      set.add(link.targetId);
                    } else if (link.targetType == 'travel' && link.sourceType == 'friend') {
                      travelId = link.targetId;
                      final set = friendIdsByTravel.putIfAbsent(travelId, () => <String>{});
                      set.add(link.sourceId);
                    }
                  }
                  finalRecords = filtered.where((r) {
                    final linkedFriendIds = friendIdsByTravel[r.id] ?? <String>{};
                    return filterFriendIds.any((id) => linkedFriendIds.contains(id));
                  }).toList(growable: false);
                  
                  if (finalRecords.isEmpty) {
                    return const _EmptyTravelState(label: '没有匹配的心愿清单');
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final record in finalRecords) ...[
                        _TravelWishlistCard(item: _buildWishlistItem(record, tripById[record.tripId])),
                        const SizedBox(height: 14),
                      ],
                    ],
                  );
                },
              );
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final record in finalRecords) ...[
                  _TravelWishlistCard(item: _buildWishlistItem(record, tripById[record.tripId])),
                  const SizedBox(height: 14),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _TravelWishlistCard extends StatelessWidget {
  const _TravelWishlistCard({required this.item});

  final TravelItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TravelDetailPage(item: item))),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                child: SizedBox(width: 110, height: 110, child: _buildLocalImage(item.imageUrl, fit: BoxFit.cover)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
                      const SizedBox(height: 6),
                      Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      const SizedBox(height: 6),
                      Text(item.subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TravelItem {
  const TravelItem({
    required this.travelId,
    required this.tripId,
    required this.recordDate,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  final String travelId;
  final String tripId;
  final DateTime recordDate;
  final String date;
  final String title;
  final String subtitle;
  final String imageUrl;
}

class TravelDetailPage extends ConsumerWidget {
  const TravelDetailPage({super.key, required this.item});

  final TravelItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder<TravelRecord?>(
      stream: _watchTravelById(db, item.travelId),
      builder: (context, recordSnapshot) {
        final record = recordSnapshot.data;
        return StreamBuilder<Trip?>(
          stream: _watchTripById(db, item.tripId),
          builder: (context, tripSnapshot) {
            final trip = tripSnapshot.data;
            final title = record == null ? item.title : _travelTitle(record, trip);
            final place = record == null ? item.subtitle : _travelPlace(record, trip);
            final headerStart = trip?.startDate ?? record?.planDate ?? record?.recordDate ?? item.recordDate;
            final headerEnd = trip?.endDate ?? record?.planDate ?? headerStart;
            final duration = _durationDays(headerStart, headerEnd);
            final durationLabel = _formatDurationLabel(duration);
            final dateLabel = _formatDateDotRange(headerStart, headerEnd);
            final cover = record == null ? item.imageUrl : _pickCoverImage(record);
            final tripId = trip?.id ?? record?.tripId ?? item.tripId;
            final tripTitle = trip?.name ?? item.title;
            final recordId = record?.id ?? item.travelId;
            final tagSet = <String>{};
            if (record != null) {
              tagSet.addAll(_decodeStringList(record.tags));
              final destination = record.destination?.trim();
              if (destination != null && destination.isNotEmpty) {
                tagSet.add(destination);
              }
            }
            final tagList = tagSet.toList()..sort();
            return StreamBuilder<List<TravelRecord>>(
              stream: _watchTravelRecordsByTripId(db, tripId),
              builder: (context, travelSnapshot) {
                final allRecords = travelSnapshot.data ?? const <TravelRecord>[];
                final journals = allRecords.where((r) => r.id != recordId && !r.isWishlist).toList(growable: false);
                return StreamBuilder<List<EntityLink>>(
                  stream: db.select(db.entityLinks).watch(),
                  builder: (context, linkSnapshot) {
                    final links = linkSnapshot.data ?? const <EntityLink>[];
                    return StreamBuilder<List<FriendRecord>>(
                      stream: db.friendDao.watchAllActive(),
                      builder: (context, friendSnapshot) {
                        final friends = friendSnapshot.data ?? const <FriendRecord>[];
                        return StreamBuilder<List<FoodRecord>>(
                          stream: db.foodDao.watchAllActive(),
                          builder: (context, foodSnapshot) {
                            final foods = foodSnapshot.data ?? const <FoodRecord>[];
                            return Scaffold(
                              backgroundColor: const Color(0xFFF6F8F8),
                              floatingActionButton: FloatingActionButton(
                                backgroundColor: const Color(0xFF2BCDEE),
                                foregroundColor: Colors.white,
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => TravelJournalCreatePage(initialTripId: tripId, initialTripTitle: tripTitle),
                                  ),
                                ),
                                child: const Icon(Icons.add, size: 28),
                              ),
                              body: CustomScrollView(
                                slivers: [
                                  SliverAppBar(
                                    automaticallyImplyLeading: false,
                                    backgroundColor: Colors.transparent,
                                    surfaceTintColor: Colors.transparent,
                                    elevation: 0,
                                    pinned: false,
                                    expandedHeight: 288,
                                    flexibleSpace: FlexibleSpaceBar(
                                      background: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                                            child: _buildLocalImage(cover, fit: BoxFit.cover),
                                          ),
                                          DecoratedBox(
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [Colors.transparent, Color(0x33000000), Color(0x99000000)],
                                                stops: [0.35, 0.70, 1.00],
                                              ),
                                            ),
                                          ),
                                          SafeArea(
                                            bottom: false,
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                                              child: Row(
                                                children: [
                                                  _FrostedCircleIconButton(
                                                    icon: Icons.arrow_back,
                                                    onTap: () => Navigator.of(context).maybePop(),
                                                  ),
                                                  const Spacer(),
                                                  _FrostedCircleIconButton(icon: Icons.bookmark_border, onTap: () {}),
                                                  const SizedBox(width: 10),
                                                  _FrostedCircleIconButton(
                                                    icon: Icons.edit,
                                                    onTap: () => Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => TravelCreatePage(
                                                          initialRecord: record,
                                                          initialTrip: trip,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  _FrostedCircleIconButton(
                                                    icon: Icons.add,
                                                    onTap: () => Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => TravelJournalCreatePage(initialTripId: tripId, initialTripTitle: tripTitle),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  _PrimaryPillButton(
                                                    icon: Icons.ios_share,
                                                    label: '一键导出',
                                                    onTap: () {},
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 20,
                                            right: 20,
                                            bottom: 20,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withValues(alpha: 0.20),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                                                      ),
                                                      child: Text(
                                                        durationLabel,
                                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    const Icon(Icons.location_on, color: Colors.white70, size: 16),
                                                    const SizedBox(width: 4),
                                                    Text(place, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  title,
                                                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, height: 1.05),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(dateLabel, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13, fontWeight: FontWeight.w600)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          if (record?.isWishlist == true)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                                              ),
                                              child: Row(
                                                children: [
                                                  Checkbox.adaptive(
                                                    value: record?.wishlistDone ?? false,
                                                    activeColor: const Color(0xFF2BCDEE),
                                                    onChanged: record == null
                                                        ? null
                                                        : (value) async {
                                                            await (db.update(db.travelRecords)..where((t) => t.id.equals(record.id))).write(
                                                              TravelRecordsCompanion(
                                                                wishlistDone: Value(value ?? false),
                                                                updatedAt: Value(DateTime.now()),
                                                              ),
                                                            );
                                                          },
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      '心愿清单待办',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w900,
                                                        color: record?.wishlistDone == true ? const Color(0xFF94A3B8) : const Color(0xFF111827),
                                                        decoration: record?.wishlistDone == true ? TextDecoration.lineThrough : TextDecoration.none,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (record?.isWishlist == true) const SizedBox(height: 14),
                                          if (tagList.isNotEmpty)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                                              ),
                                              child: Wrap(
                                                spacing: 10,
                                                runSpacing: 10,
                                                children: [
                                                  for (final tag in tagList) _TagChip(label: '#$tag'),
                                                ],
                                              ),
                                            ),
                                          if (tagList.isNotEmpty) const SizedBox(height: 14),
                                          _TravelTimeline(
                                            trip: trip,
                                            journals: journals,
                                            friends: friends,
                                            foods: foods,
                                            links: links,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
      },
    );
  }
}

class TravelCreatePage extends ConsumerStatefulWidget {
  const TravelCreatePage({super.key, this.initialRecord, this.initialTrip});

  final TravelRecord? initialRecord;
  final Trip? initialTrip;

  @override
  ConsumerState<TravelCreatePage> createState() => _TravelCreatePageState();
}

class _ChecklistItem {
  final String? id;
  final String title;
  final String? note;
  bool isDone;
  final int orderIndex;

  _ChecklistItem({
    this.id,
    required this.title,
    this.note,
    this.isDone = false,
    this.orderIndex = 0,
  });

  _ChecklistItem copyWith({
    String? id,
    String? title,
    String? note,
    bool? isDone,
    int? orderIndex,
  }) {
    return _ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      isDone: isDone ?? this.isDone,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}

class _TravelCreatePageState extends ConsumerState&lt;TravelCreatePage&gt; {
  bool _addToWishlist = true;
  final List&lt;_ChecklistItem&gt; _checklistItems = [];

  final Set&lt;String&gt; _linkedFriendIds = {};
  String? _coverImagePath;
  DateTime? _planStart;
  DateTime? _planEnd;

  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _flightLinkController = TextEditingController();
  final _hotelLinkController = TextEditingController();
  final TextEditingController _dateRangeController = TextEditingController();
  final List<String> _availableTags = [];
  final Set<String> _selectedTags = {};

  String _poiName = '';
  String _poiAddress = '';
  double? _latitude;
  double? _longitude;

  String get _locationDisplay {
    final name = _poiName.trim();
    final address = _poiAddress.trim();
    if (name.isEmpty && address.isEmpty) return '';
    if (name.isEmpty) return address;
    if (address.isEmpty) return name;
    return '$name · $address';
  }

  @override
  void initState() {
    super.initState();
    _hydrateForm();
  }

  Future<void> _hydrateForm() async {
    final record = widget.initialRecord;
    final trip = widget.initialTrip;
    if (record == null && trip == null) {
      return;
    }

    if (record != null) {
      _addToWishlist = record.isWishlist;
      _poiName = record.poiName ?? '';
      _poiAddress = record.poiAddress ?? '';
      _latitude = record.latitude;
      _longitude = record.longitude;
      final images = _decodeStringList(record.images);
      _coverImagePath = images.isNotEmpty ? images.first : null;
    }

    final title = (record?.title ?? '').trim();
    _titleController.text = title.isNotEmpty ? title : (trip?.name ?? '');
    _destinationController.text = (record?.destination ?? '').trim().isNotEmpty
        ? record!.destination!.trim()
        : _decodeStringList(trip?.destinations).isNotEmpty
            ? _decodeStringList(trip?.destinations).first
            : '';
    final contentParts = _splitContent(record?.content);
    _noteController.text = contentParts.note;
    _flightLinkController.text = contentParts.flight;
    _hotelLinkController.text = contentParts.hotel;
    _budgetController.text = trip?.totalExpense?.toString() ?? '';

    final tags = _decodeStringList(record?.tags);
    _availableTags
      ..clear()
      ..addAll(tags);
    _selectedTags
      ..clear()
      ..addAll(tags);

    _planStart = trip?.startDate ?? record?.planDate;
    _planEnd = trip?.endDate ?? record?.planDate;
    _setDateRangeText(_planStart, _planEnd);

    if (record != null) {
      await _loadLinkedFriends(record.id);
    }

    final tripId = existingTrip?.id ?? existingRecord?.tripId;
    if (tripId != null) {
      await _loadChecklistItems(tripId);
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadLinkedFriends(String travelId) async {
    final db = ref.read(appDatabaseProvider);
    final links = await db.linkDao.listLinksForEntity(entityType: 'travel', entityId: travelId);
    final ids = <String>{};
    for (final link in links) {
      final isSource = link.sourceType == 'travel' && link.sourceId == travelId;
      final otherType = isSource ? link.targetType : link.sourceType;
      final otherId = isSource ? link.targetId : link.sourceId;
      if (otherType == 'friend') {
        ids.add(otherId);
      }
    }
    if (!mounted) return;
    setState(() {
      _linkedFriendIds
        ..clear()
        ..addAll(ids);
    });
  }

  Future&lt;void&gt; _loadChecklistItems(String tripId) async {
    final db = ref.read(appDatabaseProvider);
    final items = await db.checklistDao.listByTripId(tripId);
    if (!mounted) return;
    setState(() {
      _checklistItems.clear();
      _checklistItems.addAll(items.map((e) =&gt; _ChecklistItem(
            id: e.id,
            title: e.title,
            note: e.note,
            isDone: e.isDone,
            orderIndex: e.orderIndex,
          )));
    });
  }

  Future&lt;void&gt; _addChecklistItem() async {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final result = await showModalBottomSheet&lt;_ChecklistItem&gt;(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: _BottomSheetShell(
            title: '添加心愿项',
            actionText: '添加',
            onAction: () {
              final title = titleController.text.trim();
              if (title.isEmpty) return;
              Navigator.of(context).pop(_ChecklistItem(
                title: title,
                note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                orderIndex: _checklistItems.length,
              ));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '例如：清水寺日落',
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      labelText: '标题',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      hintText: '备注（可选）',
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      labelText: '备注',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    titleController.dispose();
    noteController.dispose();
    if (result == null || !mounted) return;
    setState(() =&gt; _checklistItems.add(result));
  }

  Future&lt;void&gt; _editChecklistItem(int index) async {
    final item = _checklistItems[index];
    final titleController = TextEditingController(text: item.title);
    final noteController = TextEditingController(text: item.note ?? '');
    final result = await showModalBottomSheet&lt;_ChecklistItem&gt;(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: _BottomSheetShell(
            title: '编辑心愿项',
            actionText: '保存',
            onAction: () {
              final title = titleController.text.trim();
              if (title.isEmpty) return;
              Navigator.of(context).pop(item.copyWith(
                title: title,
                note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '例如：清水寺日落',
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      labelText: '标题',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      hintText: '备注（可选）',
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      labelText: '备注',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    titleController.dispose();
    noteController.dispose();
    if (result == null || !mounted) return;
    setState(() =&gt; _checklistItems[index] = result);
  }

  void _deleteChecklistItem(int index) {
    setState(() =&gt; _checklistItems.removeAt(index));
  }

  _ContentParts _splitContent(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const _ContentParts(note: '', flight: '', hotel: '');
    }
    final lines = raw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final notes = <String>[];
    var flight = '';
    var hotel = '';
    for (final line in lines) {
      if (line.startsWith('机票/交通：')) {
        flight = line.replaceFirst('机票/交通：', '').trim();
        continue;
      }
      if (line.startsWith('住宿：')) {
        hotel = line.replaceFirst('住宿：', '').trim();
        continue;
      }
      notes.add(line);
    }
    return _ContentParts(note: notes.join('\n'), flight: flight, hotel: hotel);
  }

  void _setDateRangeText(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      _dateRangeController.text = '';
      return;
    }
    final startDate = start ?? end!;
    final endDate = end ?? startDate;
    _dateRangeController.text =
        '${startDate.year}年${startDate.month}月${startDate.day}日 - ${endDate.year}年${endDate.month}月${endDate.day}日';
  }

  Future<void> _pickDestinationLocation() async {
    final result = await Navigator.of(context).push<AmapLocationPickResult>(
      MaterialPageRoute(
        builder: (_) => AmapLocationPage.pick(
          initialPoiName: _poiName.trim().isNotEmpty ? _poiName.trim() : _destinationController.text.trim(),
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
      final text = result.poiName.trim().isNotEmpty ? result.poiName.trim() : result.address.trim();
      if (text.isNotEmpty) {
        _destinationController.text = text;
      }
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialStart = _planStart ?? now;
    final initialEnd = _planEnd ?? initialStart;
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('zh', 'CN'),
    );
    if (picked == null) return;
    setState(() {
      _planStart = picked.start;
      _planEnd = picked.end;
      _setDateRangeText(_planStart, _planEnd);
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
                  hintText: '例如：徒步 / 拍照',
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
      if (!_availableTags.contains(tag)) {
        _availableTags.add(tag);
      }
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
              title: '同行者 (羁绊)',
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

  (DateTime?, DateTime?) _parseDateRange(String text) {
    final numbers = RegExp(r'\d+').allMatches(text).map((m) => int.parse(m.group(0)!)).toList();
    if (numbers.length < 3) {
      return (null, null);
    }
    final startYear = numbers[0];
    final startMonth = numbers[1];
    final startDay = numbers[2];
    DateTime? start;
    DateTime? end;
    try {
      start = DateTime(startYear, startMonth, startDay);
    } catch (_) {
      start = null;
    }
    if (numbers.length >= 5) {
      final endYear = numbers.length >= 6 ? numbers[3] : startYear;
      final endMonth = numbers.length >= 6 ? numbers[4] : numbers[3];
      final endDay = numbers.length >= 6 ? numbers[5] : numbers[4];
      try {
        end = DateTime(endYear, endMonth, endDay);
      } catch (_) {
        end = null;
      }
    }
    return (start, end);
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final stored = await _persistSingleImage(file, 'travel');
    if (stored == null) return;
    if (!mounted) return;
    setState(() => _coverImagePath = stored);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先填写行程标题')));
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final existingRecord = widget.initialRecord;
    final existingTrip = widget.initialTrip;
    const uuid = Uuid();
    final now = DateTime.now();
    final recordDate = existingRecord?.recordDate ?? DateTime(now.year, now.month, now.day);
    final tripId = existingTrip?.id ?? existingRecord?.tripId ?? uuid.v4();
    final travelId = existingRecord?.id ?? uuid.v4();

    final destination = _destinationController.text.trim();
    final poiName = _poiName.trim();
    final poiAddress = _poiAddress.trim();
    final budget = double.tryParse(_budgetController.text.trim());
    final note = _noteController.text.trim();
    final flightLink = _flightLinkController.text.trim();
    final hotelLink = _hotelLinkController.text.trim();
    final parts = <String>[];
    if (note.isNotEmpty) parts.add(note);
    if (flightLink.isNotEmpty) parts.add('机票/交通：$flightLink');
    if (hotelLink.isNotEmpty) parts.add('住宿：$hotelLink');
    final content = parts.isEmpty ? null : parts.join('\n');
    var startDate = _planStart;
    var endDate = _planEnd;
    if (startDate == null && _dateRangeController.text.trim().isNotEmpty) {
      final parsed = _parseDateRange(_dateRangeController.text.trim());
      startDate = parsed.$1;
      endDate = parsed.$2;
    }
    final destinations = destination.isEmpty ? null : jsonEncode([destination]);

    await db.into(db.trips).insertOnConflictUpdate(
          TripsCompanion.insert(
            id: tripId,
            name: title,
            startDate: Value(startDate),
            endDate: Value(endDate),
            destinations: Value(destinations),
            totalExpense: Value(budget),
            createdAt: existingTrip?.createdAt ?? now,
            updatedAt: now,
          ),
        );

    final cover = _coverImagePath?.trim().isNotEmpty == true ? jsonEncode([_coverImagePath]) : null;
    final tagSet = <String>{};
    for (final tag in _selectedTags) {
      final value = tag.trim();
      if (value.isNotEmpty) tagSet.add(value);
    }
    if (destination.isNotEmpty) tagSet.add(destination);
    final tagsJson = tagSet.isEmpty ? null : jsonEncode(tagSet.toList());
    await db.into(db.travelRecords).insertOnConflictUpdate(
          TravelRecordsCompanion.insert(
            id: travelId,
            tripId: tripId,
            title: Value(title),
            content: Value(content),
            images: Value(cover),
            destination: Value(destination.isEmpty ? null : destination),
            tags: Value(tagsJson),
            poiName: Value(poiName.isEmpty ? null : poiName),
            poiAddress: Value(poiAddress.isEmpty ? null : poiAddress),
            city: Value(poiAddress.isEmpty ? null : poiAddress),
            latitude: Value(_latitude),
            longitude: Value(_longitude),
            isWishlist: Value(_addToWishlist),
            wishlistDone: Value(existingRecord?.wishlistDone ?? false),
            planDate: Value(startDate),
            recordDate: recordDate,
            createdAt: existingRecord?.createdAt ?? now,
            updatedAt: now,
          ),
        );

    final eventStart = startDate ?? recordDate;
    final eventRecordDate = DateTime(eventStart.year, eventStart.month, eventStart.day);
    await db.into(db.timelineEvents).insertOnConflictUpdate(
          TimelineEventsCompanion.insert(
            id: travelId,
            title: title,
            eventType: 'travel',
            startAt: Value(eventStart),
            endAt: Value(endDate),
            note: Value(content),
            tags: Value(tagsJson),
            poiName: Value(poiName.isEmpty ? null : poiName),
            poiAddress: Value(poiAddress.isEmpty ? null : poiAddress),
            latitude: Value(_latitude),
            longitude: Value(_longitude),
            recordDate: eventRecordDate,
            createdAt: existingRecord?.createdAt ?? now,
            updatedAt: now,
          ),
        );

    final existingLinks = existingRecord == null
        ? const <EntityLink>[]
        : await db.linkDao.listLinksForEntity(entityType: 'travel', entityId: travelId);
    for (final link in existingLinks) {
      await db.linkDao.deleteLink(
        sourceType: link.sourceType,
        sourceId: link.sourceId,
        targetType: link.targetType,
        targetId: link.targetId,
        linkType: link.linkType,
        now: now,
      );
    }
    for (final id in _linkedFriendIds) {
      await db.linkDao.createLink(
        sourceType: 'travel',
        sourceId: travelId,
        targetType: 'friend',
        targetId: id,
        now: now,
      );
    }

    await db.checklistDao.deleteByTripId(tripId);
    for (var i = 0; i &lt; _checklistItems.length; i++) {
      final item = _checklistItems[i];
      final itemId = item.id ?? const Uuid().v4();
      await db.checklistDao.upsert(ChecklistItemsCompanion.insert(
        id: itemId,
        tripId: tripId,
        travelId: Value(travelId),
        title: item.title,
        note: Value(item.note),
        isDone: Value(item.isDone),
        orderIndex: i,
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _flightLinkController.dispose();
    _hotelLinkController.dispose();
    _dateRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = {..._availableTags, ..._selectedTags}.toList()..sort();
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8F8).withValues(alpha: 0.92),
                border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('取消'),
                      ),
                      const Spacer(),
                      const Text('新建旅行行程', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: _PrimaryPillButton(icon: null, label: '创建', onTap: _save),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF2BCDEE).withValues(alpha: 0.06), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _pickCoverImage,
                child: _DashedRRect(
                  radius: 20,
                  dashColor: const Color(0xFF2BCDEE).withValues(alpha: 0.35),
                  dashWidth: 7,
                  dashGap: 6,
                  strokeWidth: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 200,
                      child: _coverImagePath == null || _coverImagePath!.trim().isEmpty
                          ? Container(
                              color: Colors.white,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, color: Color(0xFF9CA3AF), size: 44),
                                  SizedBox(height: 10),
                                  Text('上传目的地封面或攻略截图',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
                                ],
                              ),
                            )
                          : _buildLocalImage(_coverImagePath!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('行程标题', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
                    const SizedBox(height: 8),
                    _RoundedFilledField(
                      controller: _titleController,
                      hintText: '给这次行程起个标题...',
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 14),
                    const Text('备注与设想', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
                    const SizedBox(height: 8),
                    _RoundedFilledField(
                      controller: _noteController,
                      hintText: '记录关于这次行程的备注或初步设想...',
                      minLines: 3,
                      maxLines: 6,
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155), height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _SectionTitle(label: '基本信息'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.place,
                      label: '目的地',
                      trailing: const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _pickDestinationLocation,
                        child: AbsorbPointer(
                          child: _PlainTextField(
                            controller: _destinationController,
                            readOnly: true,
                            hintText: _locationDisplay.isEmpty ? '选择目的地' : _locationDisplay,
                          ),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: '计划时间',
                      trailing: const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _pickDateRange,
                        child: AbsorbPointer(
                          child: _PlainTextField(controller: _dateRangeController, readOnly: true, hintText: '选择日期范围'),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                    _InfoRow(
                      icon: Icons.paid,
                      label: '预算金额',
                      child: Row(
                        children: [
                          const Text('¥', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                          const SizedBox(width: 6),
                          Expanded(child: _PlainTextField(controller: _budgetController, hintText: '0.00', keyboardType: TextInputType.number)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(child: _SectionTitle(label: '同行者 (羁绊)')),
                  TextButton(
                    onPressed: _selectLinkedFriends,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2BCDEE),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    child: const Text('管理'),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: StreamBuilder<List<FriendRecord>>(
                    stream: ref.read(appDatabaseProvider).friendDao.watchAllActive(),
                    builder: (context, snapshot) {
                      final friends = snapshot.data ?? const <FriendRecord>[];
                      final selectedFriends = friends.where((f) => _linkedFriendIds.contains(f.id)).toList(growable: false);
                      return Row(
                        children: [
                          const _CompanionInviteChip(),
                          for (final friend in selectedFriends) ...[
                            const SizedBox(width: 14),
                            _CompanionNameChip(
                              name: friend.name,
                              avatarPath: friend.avatarPath,
                              isFavorite: friend.isFavorite,
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const _SectionTitle(label: '规划详情'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('加入愿望清单', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF334155))),
                          SizedBox(height: 4),
                          Text('开启后，此行程将同步至愿望清单', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _addToWishlist,
                      activeTrackColor: const Color(0xFF2BCDEE),
                      activeColor: Colors.white,
                      onChanged: (v) => setState(() => _addToWishlist = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Text('预订链接', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF9CA3AF))),
                    ),
                    const SizedBox(height: 10),
                    _IconInputRow(icon: Icons.flight, rotateIcon: true, hintText: '粘贴机票/交通预订链接', controller: _flightLinkController),
                    const SizedBox(height: 10),
                    _IconInputRow(icon: Icons.hotel, hintText: '粘贴酒店/住宿预订链接', controller: _hotelLinkController),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Text('旅行标签', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF9CA3AF))),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final tag in tags)
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                if (_selectedTags.contains(tag)) {
                                  _selectedTags.remove(tag);
                                } else {
                                  _selectedTags.add(tag);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedTags.contains(tag)
                                    ? const Color(0xFF2BCDEE).withValues(alpha: 0.10)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: _selectedTags.contains(tag)
                                    ? Border.all(color: const Color(0xFF2BCDEE).withValues(alpha: 0.20))
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '#$tag',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: _selectedTags.contains(tag) ? const Color(0xFF22A4BE) : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _selectedTags.contains(tag) ? Icons.close : Icons.add,
                                    size: 14,
                                    color: const Color(0xFF64748B),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _addCustomTag,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('#', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
                                SizedBox(width: 6),
                                Text('输入标签...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                              ],
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 2),
                            child: Text('心愿清单 (景点 / 美食)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF9CA3AF))),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: const Color(0xFF2BCDEE).withValues(alpha: 0.10), borderRadius: BorderRadius.circular(999)),
                          child: Text('${_checklistItems.length} 项', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._checklistItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox.adaptive(
                            value: item.isDone,
                            activeColor: const Color(0xFF2BCDEE),
                            onChanged: (v) {
                              setState(() {
                                _checklistItems[index] = item.copyWith(isDone: v ?? false);
                              });
                            },
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: GestureDetector(
                                onTap: () => _editChecklistItem(index),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: item.isDone ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                                        decoration: item.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                                      ),
                                    ),
                                    if (item.note != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        item.note!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: item.isDone ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_horiz, color: Color(0xFF94A3B8), size: 20),
                            onPressed: () async {
                              final result = await showModalBottomSheet<String>(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) => _BottomSheetShell(
                                  title: '心愿项操作',
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.edit, color: Color(0xFF2BCDEE)),
                                          title: const Text('编辑', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                                          onTap: () => Navigator.of(context).pop('edit'),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                                          title: const Text('删除', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFEF4444))),
                                          onTap: () => Navigator.of(context).pop('delete'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              if (result == 'edit') {
                                _editChecklistItem(index);
                              } else if (result == 'delete') {
                                _deleteChecklistItem(index);
                              }
                            },
                          ),
                        ],
                      );
                    }).toList(),
                    const SizedBox(height: 10),
                    Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add, color: Color(0xFF94A3B8), size: 18),
                          onPressed: _addChecklistItem,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: _addChecklistItem,
                            child: AbsorbPointer(
                              child: const _PlainTextField(hintText: '添加想去的地方...'),
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
        ],
      ),
    );
  }
}

class TravelJournalCreatePage extends ConsumerStatefulWidget {
  const TravelJournalCreatePage({super.key, this.initialTripId, this.initialTripTitle});

  final String? initialTripId;
  final String? initialTripTitle;

  @override
  ConsumerState<TravelJournalCreatePage> createState() => _TravelJournalCreatePageState();
}

class _TravelJournalCreatePageState extends ConsumerState<TravelJournalCreatePage> {
  int _selectedMoodIndex = 1;

  final Set<String> _linkedFriendIds = {};
  final Set<String> _linkedFoodIds = {};
  String? _linkedTripId;
  String? _linkedTripTitle;
  final List<String> _availableTags = [];
  final Set<String> _selectedTags = {};

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrls = <String>[];

  String _poiName = '';
  String _poiAddress = '';
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _linkedTripId = widget.initialTripId;
    _linkedTripTitle = widget.initialTripTitle;
  }

  String get _locationTitle {
    final name = _poiName.trim();
    final address = _poiAddress.trim();
    if (name.isNotEmpty) return name;
    if (address.isNotEmpty) return address;
    return '添加地点';
  }

  String? get _locationSubtitle {
    final address = _poiAddress.trim();
    return address.isEmpty ? null : address;
  }

  Future<void> _pickLocation() async {
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
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;
    final stored = await _persistPickedImages(files, 'travel');
    if (stored.isEmpty) return;
    setState(() => _imageUrls.addAll(stored));
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
              title: '同行朋友',
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

  Future<void> _selectLinkedTrip() async {
    final db = ref.read(appDatabaseProvider);
    final selected = await showModalBottomSheet<_TripPickResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StreamBuilder<List<Trip>>(
          stream: db.select(db.trips).watch(),
          builder: (context, snapshot) {
            final trips = snapshot.data ?? const <Trip>[];
            return _BottomSheetShell(
              title: '关联行程',
              actionText: '清除',
              onAction: () => Navigator.of(context).pop(const _TripPickResult.empty()),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
                child: trips.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          child: Text('暂无行程', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                        itemCount: trips.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final trip = trips[index];
                          final selectedId = _linkedTripId ?? '';
                          final checked = selectedId == trip.id;
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.of(context).pop(_TripPickResult(trip.id, trip.name)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: checked ? const Color(0xFF2BCDEE).withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: checked ? const Color(0xFF2BCDEE).withValues(alpha: 0.22) : const Color(0xFFF1F5F9)),
                              ),
                              child: Row(
                                children: [
                                  const _IconSquare(color: Color(0xFFE0F2FE), icon: Icons.flight_takeoff, iconColor: Color(0xFF0EA5E9)),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(trip.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827)))),
                                  Icon(checked ? Icons.check_circle : Icons.radio_button_unchecked, color: checked ? const Color(0xFF2BCDEE) : const Color(0xFFCBD5E1)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            );
          },
        );
      },
    );
    if (selected == null) return;
    if (!mounted) return;
    if (selected.isEmpty) {
      setState(() {
        _linkedTripId = null;
        _linkedTripTitle = null;
      });
      return;
    }
    setState(() {
      _linkedTripId = selected.id;
      _linkedTripTitle = selected.name;
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
                  hintText: '例如：徒步 / 拍照',
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
      if (!_availableTags.contains(tag)) {
        _availableTags.add(tag);
      }
      _selectedTags.add(tag);
    });
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先填写游记标题')));
      return;
    }

    final db = ref.read(appDatabaseProvider);
    const uuid = Uuid();
    final now = DateTime.now();
    final recordDate = DateTime(now.year, now.month, now.day);
    final tripId = _linkedTripId ?? uuid.v4();
    final travelId = uuid.v4();

    final poiName = _poiName.trim();
    final poiAddress = _poiAddress.trim();
    final destination = poiName.isNotEmpty ? poiName : (poiAddress.isNotEmpty ? poiAddress : '');
    final images = _imageUrls.isEmpty ? null : jsonEncode(_imageUrls);
    final content = _contentController.text.trim();
    final mood = _moods[_selectedMoodIndex].label;

    if (_linkedTripId == null) {
      await db.into(db.trips).insertOnConflictUpdate(
            TripsCompanion.insert(
              id: tripId,
              name: title,
              startDate: Value(recordDate),
              endDate: Value(recordDate),
              destinations: Value(destination.isEmpty ? null : jsonEncode([destination])),
              totalExpense: const Value(null),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }

    final tagSet = <String>{};
    if (destination.isNotEmpty) {
      tagSet.add(destination);
    }
    tagSet.addAll(_selectedTags);
    final tagsJson = tagSet.isEmpty ? null : jsonEncode(tagSet.toList()..sort());
    await db.into(db.travelRecords).insertOnConflictUpdate(
          TravelRecordsCompanion.insert(
            id: travelId,
            tripId: tripId,
            title: Value(title),
            content: Value(content.isEmpty ? null : content),
            images: Value(images),
            destination: Value(destination.isEmpty ? null : destination),
            tags: Value(tagsJson),
            poiName: Value(poiName.isEmpty ? null : poiName),
            poiAddress: Value(poiAddress.isEmpty ? null : poiAddress),
            city: Value(poiAddress.isEmpty ? null : poiAddress),
            latitude: Value(_latitude),
            longitude: Value(_longitude),
            mood: Value(mood),
            isWishlist: const Value(false),
            wishlistDone: const Value(false),
            recordDate: recordDate,
            createdAt: now,
            updatedAt: now,
          ),
        );

    for (final id in _linkedFriendIds) {
      await db.linkDao.createLink(
        sourceType: 'travel',
        sourceId: travelId,
        targetType: 'friend',
        targetId: id,
        now: now,
      );
    }
    for (final id in _linkedFoodIds) {
      await db.linkDao.createLink(
        sourceType: 'travel',
        sourceId: travelId,
        targetType: 'food',
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
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = {..._availableTags, ..._selectedTags}.toList()..sort();
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8F8).withValues(alpha: 0.90),
                border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('取消'),
                      ),
                      const Spacer(),
                      const Text('新建游记', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: _PrimaryPillButton(icon: null, label: '发布', onTap: _publish),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _RoundedFilledField(
                  controller: _titleController,
                  hintText: '给这段游记起个标题...',
                  fillColor: const Color(0xFFF1F5F9),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 12),
                _RoundedFilledField(
                  controller: _contentController,
                  hintText: '此刻有什么想记录的？描述你的见闻与感悟...',
                  fillColor: Colors.transparent,
                  minLines: 5,
                  maxLines: 10,
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF334155), height: 1.6),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    ..._imageUrls.map((url) => _PhotoGridItem(imageUrl: url)),
                    _PhotoAddGridItem(onTap: _pickImages),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('已选 ${_imageUrls.length} 张', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                    const Spacer(),
                    Text('还可以添加 ${9 - _imageUrls.length} 张', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _SectionTitle(label: '万物互联'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _AssociationRow(
                  iconBg: const Color(0xFF2BCDEE).withValues(alpha: 0.10),
                  iconColor: const Color(0xFF2BCDEE),
                  icon: Icons.place,
                  title: _locationTitle,
                  subtitle: _locationSubtitle,
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
                  onTap: _pickLocation,
                ),
                Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          _MoodIcon(),
                          SizedBox(width: 10),
                          Text('此时心情', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 64,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _moods.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final mood = _moods[index];
                            final isSelected = index == _selectedMoodIndex;
                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => setState(() => _selectedMoodIndex = index),
                              child: SizedBox(
                                width: 58,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Text(mood.emoji, style: TextStyle(fontSize: isSelected ? 26 : 24)),
                                        if (isSelected)
                                          const Positioned(bottom: -2, child: SizedBox(width: 6, height: 6, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFF2BCDEE), shape: BoxShape.circle)))),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      mood.label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                        color: isSelected ? const Color(0xFF2BCDEE) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                _AssociationRow(
                  iconBg: const Color(0xFFA855F7).withValues(alpha: 0.12),
                  iconColor: const Color(0xFFA855F7),
                  icon: Icons.groups,
                  title: '同行朋友',
                  subtitle: null,
                  onTap: _selectLinkedFriends,
                  trailing: StreamBuilder<List<FriendRecord>>(
                    stream: ref.read(appDatabaseProvider).friendDao.watchAllActive(),
                    builder: (context, snapshot) {
                      final friends = snapshot.data ?? const <FriendRecord>[];
                      final selectedFriends = friends.where((f) => _linkedFriendIds.contains(f.id)).toList(growable: false);
                      final visibleFriends = selectedFriends.take(2).toList(growable: false);
                      final overflow = selectedFriends.length - visibleFriends.length;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selectedFriends.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                              child: const Text('未选择', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                            )
                          else ...[
                            for (final friend in visibleFriends) ...[
                              _TinyLetterAvatar(name: friend.name),
                              const SizedBox(width: 6),
                            ],
                            if (overflow > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(999)),
                                child: Text('+$overflow', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF3B82F6))),
                              ),
                          ],
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
                        ],
                      );
                    },
                  ),
                ),
                Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                _AssociationRow(
                  iconBg: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                  iconColor: const Color(0xFFF43F5E),
                  icon: Icons.restaurant,
                  title: '关联美食',
                  subtitle: '选择本次旅行的美食记录',
                  onTap: _selectLinkedFoods,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          _linkedFoodIds.isEmpty ? '未关联' : '已关联 ${_linkedFoodIds.length} 项',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          _TagIcon(),
                          SizedBox(width: 10),
                          Text('自定义标签', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final tag in tags)
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  if (_selectedTags.contains(tag)) {
                                    _selectedTags.remove(tag);
                                  } else {
                                    _selectedTags.add(tag);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _selectedTags.contains(tag)
                                      ? const Color(0xFF2BCDEE).withValues(alpha: 0.10)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: _selectedTags.contains(tag)
                                      ? Border.all(color: const Color(0xFF2BCDEE).withValues(alpha: 0.20))
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '#$tag',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: _selectedTags.contains(tag) ? const Color(0xFF22A4BE) : const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _selectedTags.contains(tag) ? Icons.close : Icons.add,
                                      size: 14,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _addCustomTag,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('#', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
                                  SizedBox(width: 6),
                                  Text('输入标签...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
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
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: _selectLinkedTrip,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8, height: 8, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFF2BCDEE), shape: BoxShape.circle))),
                  const SizedBox(width: 10),
                  const Text('正在关联行程：', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                  Text(
                    (_linkedTripTitle ?? '').trim().isEmpty ? '未关联行程' : _linkedTripTitle!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF334155)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _moods = <_Mood>[
    _Mood('😌', '平静'),
    _Mood('🤩', '惊叹'),
    _Mood('😆', '开心'),
    _Mood('🤔', '思考'),
    _Mood('🥱', '疲惫'),
  ];
}

class _Mood {
  const _Mood(this.emoji, this.label);
  final String emoji;
  final String label;
}

class _FrostedCircleIconButton extends StatelessWidget {
  const _FrostedCircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.white.withValues(alpha: 0.12),
          child: InkWell(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              onTap();
            },
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryPillButton extends StatelessWidget {
  const _PrimaryPillButton({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2BCDEE).withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
              ],
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TravelTimeline extends StatelessWidget {
  const _TravelTimeline({
    required this.trip,
    required this.journals,
    required this.friends,
    required this.foods,
    required this.links,
  });

  final Trip? trip;
  final List<TravelRecord> journals;
  final List<FriendRecord> friends;
  final List<FoodRecord> foods;
  final List<EntityLink> links;

  @override
  Widget build(BuildContext context) {
    if (journals.isEmpty) {
      return const _EmptyTravelState(label: '暂无游记，去添加新的旅行记录吧');
    }
    final friendById = {for (final friend in friends) friend.id: friend};
    final foodById = {for (final food in foods) food.id: food};
    final friendIdsByTravel = <String, Set<String>>{};
    final foodIdsByTravel = <String, Set<String>>{};
    for (final link in links) {
      String? travelId;
      String? targetType;
      String? targetId;
      if (link.sourceType == 'travel') {
        travelId = link.sourceId;
        targetType = link.targetType;
        targetId = link.targetId;
      } else if (link.targetType == 'travel') {
        travelId = link.targetId;
        targetType = link.sourceType;
        targetId = link.sourceId;
      }
      if (travelId == null || targetType == null || targetId == null) {
        continue;
      }
      if (targetType == 'friend') {
        final set = friendIdsByTravel.putIfAbsent(travelId, () => <String>{});
        set.add(targetId);
      } else if (targetType == 'food') {
        final set = foodIdsByTravel.putIfAbsent(travelId, () => <String>{});
        set.add(targetId);
      }
    }
    final sorted = [...journals]..sort((a, b) => a.recordDate.compareTo(b.recordDate));
    final dayMap = <DateTime, List<TravelRecord>>{};
    for (final record in sorted) {
      final dayKey = DateTime(record.recordDate.year, record.recordDate.month, record.recordDate.day);
      dayMap.putIfAbsent(dayKey, () => <TravelRecord>[]).add(record);
    }
    final days = dayMap.keys.toList()..sort((a, b) => a.compareTo(b));
    final today = DateTime.now();
    final hasActiveDay = days.any((d) => _isSameDay(d, today));
    return Stack(
      children: [
        Positioned(
          left: 18,
          top: 16,
          bottom: 18,
          child: Container(width: 2, color: const Color(0xFFE5E7EB)),
        ),
        Column(
          children: [
            for (int i = 0; i < days.length; i++) ...[
              _TimelineDayBlock(
                dayTitle: '第${i + 1}天',
                daySubTitle: _formatDaySubTitle(days[i]),
                isActive: hasActiveDay ? _isSameDay(days[i], today) : i == 0,
                items: _buildDayItems(
                  records: dayMap[days[i]] ?? const <TravelRecord>[],
                  friendById: friendById,
                  foodById: foodById,
                  friendIdsByTravel: friendIdsByTravel,
                  foodIdsByTravel: foodIdsByTravel,
                ),
              ),
              if (i != days.length - 1) const SizedBox(height: 22),
            ],
            if (trip != null) ...[
              const SizedBox(height: 18),
              const _TimelineEndMarker(),
            ],
          ],
        ),
      ],
    );
  }

  List<_TimelineItem> _buildDayItems({
    required List<TravelRecord> records,
    required Map<String, FriendRecord> friendById,
    required Map<String, FoodRecord> foodById,
    required Map<String, Set<String>> friendIdsByTravel,
    required Map<String, Set<String>> foodIdsByTravel,
  }) {
    final items = <_TimelineItem>[];
    final dayFriendIds = <String>{};
    for (final record in records) {
      dayFriendIds.addAll(friendIdsByTravel[record.id] ?? const <String>{});
    }
    final dayFriends = [
      for (final id in dayFriendIds)
        if (friendById.containsKey(id)) friendById[id]!,
    ];
    if (dayFriends.isNotEmpty) {
      items.add(_TimelineItem.companions(dayFriends));
    }
    for (final record in records) {
      items.add(_TimelineItem.journal(record: record, trip: trip));
      final foodIds = foodIdsByTravel[record.id] ?? const <String>{};
      for (final id in foodIds) {
        final food = foodById[id];
        if (food != null) {
          items.add(_TimelineItem.food(record: food));
        }
      }
    }
    return items;
  }
}

class _TimelineDayBlock extends StatelessWidget {
  const _TimelineDayBlock({required this.dayTitle, required this.daySubTitle, required this.isActive, required this.items});

  final String dayTitle;
  final String daySubTitle;
  final bool isActive;
  final List<_TimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 36,
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF2BCDEE) : const Color(0xFFCBD5E1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isActive ? const Color(0xFF2BCDEE) : const Color(0xFFCBD5E1)).withValues(alpha: 0.25),
                        blurRadius: 0,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dayTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(daySubTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i].build(context),
                if (i != items.length - 1) const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineItem {
  const _TimelineItem._(this._builder);
  final Widget Function(BuildContext context) _builder;

  Widget build(BuildContext context) => _builder(context);

  static _TimelineItem companions(List<FriendRecord> friends) {
    return _TimelineItem._((context) => _TimelineCompanionCard(friends: friends));
  }

  static _TimelineItem journal({required TravelRecord record, required Trip? trip}) {
    return _TimelineItem._((context) => _TimelineJournalCard(record: record, trip: trip));
  }

  static _TimelineItem food({required FoodRecord record}) {
    return _TimelineItem._((context) => _TimelineFoodCard(record: record));
  }
}

class _TimelineCompanionCard extends StatelessWidget {
  const _TimelineCompanionCard({required this.friends});

  final List<FriendRecord> friends;

  @override
  Widget build(BuildContext context) {
    final displayFriends = friends.take(3).toList();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (int i = 0; i < displayFriends.length; i++)
                  Positioned(
                    left: i * 18,
                    child: _buildFriendAvatar(displayFriends[i]),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '与 ',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                children: _buildFriendSpans(displayFriends),
              ),
            ),
          ),
          const Icon(Icons.group, color: Color(0xFFCBD5E1), size: 18),
        ],
      ),
    );
  }

  Widget _buildFriendAvatar(FriendRecord friend) {
    final avatarPath = (friend.avatarPath ?? '').trim();
    if (avatarPath.isNotEmpty) {
      return _TinyAvatar(url: avatarPath, size: 32);
    }
    return _TinyLetterAvatar(name: friend.name);
  }

  List<TextSpan> _buildFriendSpans(List<FriendRecord> friends) {
    final spans = <TextSpan>[];
    for (int i = 0; i < friends.length; i++) {
      spans.add(
        TextSpan(text: '@${friends[i].name}', style: const TextStyle(color: Color(0xFF2BCDEE), fontWeight: FontWeight.w900)),
      );
      if (i != friends.length - 1) {
        spans.add(const TextSpan(text: ', ', style: TextStyle(color: Color(0xFF64748B))));
      }
    }
    spans.add(const TextSpan(text: ' 同行', style: TextStyle(color: Color(0xFF64748B))));
    return spans;
  }
}

class _TimelineJournalCard extends StatelessWidget {
  const _TimelineJournalCard({required this.record, required this.trip});

  final TravelRecord record;
  final Trip? trip;

  @override
  Widget build(BuildContext context) {
    final title = _travelTitle(record, trip);
    final subtitle = _travelPlace(record, trip);
    final content = (record.content ?? '').trim();
    final images = _decodeStringList(record.images);
    final tagSet = <String>{};
    tagSet.addAll(_decodeStringList(record.tags));
    final destination = record.destination?.trim();
    if (destination != null && destination.isNotEmpty) {
      tagSet.add(destination);
    }
    final tags = tagSet.toList()..sort();
    final timeLabel = '${record.recordDate.hour.toString().padLeft(2, '0')}:${record.recordDate.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: const Color(0xFFF97316).withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.edit_note, size: 18, color: Color(0xFFF97316)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(timeLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ],
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final image in images.take(4))
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(width: 72, height: 72, child: _buildLocalImage(image, fit: BoxFit.cover)),
                  ),
              ],
            ),
          ],
          if (content.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B), height: 1.5),
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final tag in tags) _TagChip(label: '#$tag')],
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineFoodCard extends StatelessWidget {
  const _TimelineFoodCard({required this.record});

  final FoodRecord record;

  @override
  Widget build(BuildContext context) {
    final image = _pickFoodCoverImage(record);
    final label = _pickFoodLabel(record);
    final subtitle = _pickFoodSubtitle(record);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: image.isEmpty
                  ? Container(
                      color: const Color(0xFFE2E8F0),
                      alignment: Alignment.center,
                      child: const Icon(Icons.restaurant, color: Color(0xFF94A3B8)),
                    )
                  : _buildLocalImage(image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.restaurant, color: Color(0xFF2BCDEE), size: 14),
                    const SizedBox(width: 6),
                    Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE), letterSpacing: 0.4)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(record.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(subtitle, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEndMarker extends StatelessWidget {
  const _TimelineEndMarker();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48),
      child: Row(
        children: const [
          SizedBox(width: 30, height: 1, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFCBD5E1)))),
          SizedBox(width: 10),
          Text('旅程未完待续...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2BCDEE).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0xFF2BCDEE), borderRadius: BorderRadius.circular(999))),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.6)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.child, this.trailing});

  final IconData icon;
  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: const Color(0xFF2BCDEE).withValues(alpha: 0.10), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF2BCDEE), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _PlainTextField extends StatelessWidget {
  const _PlainTextField({this.controller, this.readOnly = false, required this.hintText, this.keyboardType});

  final TextEditingController? controller;
  final bool readOnly;
  final String hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFCBD5E1)),
      ),
    );
  }
}

class _RoundedFilledField extends StatelessWidget {
  const _RoundedFilledField({
    required this.hintText,
    required this.textStyle,
    this.minLines = 1,
    this.maxLines = 1,
    this.fillColor,
    this.controller,
  });

  final String hintText;
  final TextStyle textStyle;
  final int minLines;
  final int maxLines;
  final Color? fillColor;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: textStyle,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor ?? const Color(0xFFF6F8F8),
        hintText: hintText,
        hintStyle: textStyle.copyWith(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}

class _IconInputRow extends StatelessWidget {
  const _IconInputRow({required this.icon, required this.hintText, this.rotateIcon = false, this.controller});

  final IconData icon;
  final String hintText;
  final bool rotateIcon;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF6F8F8), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Transform.rotate(
            angle: rotateIcon ? -0.8 : 0,
            child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanionInviteChip extends StatelessWidget {
  const _CompanionInviteChip();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DashedRRect(
          radius: 999,
          dashColor: const Color(0xFF2BCDEE).withValues(alpha: 0.45),
          dashWidth: 6,
          dashGap: 6,
          strokeWidth: 2,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFF2BCDEE).withValues(alpha: 0.06), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Color(0xFF2BCDEE)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text('邀请', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
      ],
    );
  }
}

class _CompanionNameChip extends StatelessWidget {
  const _CompanionNameChip({required this.name, this.avatarPath, this.isFavorite = false});

  final String name;
  final String? avatarPath;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            _AvatarCircle(name: name, avatarPath: avatarPath),
            if (isFavorite)
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2BCDEE),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 10),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 64,
          child: Text(name, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF475569))),
        ),
      ],
    );
  }
}

class _DashedRRect extends StatelessWidget {
  const _DashedRRect({
    required this.child,
    required this.radius,
    required this.dashColor,
    required this.dashWidth,
    required this.dashGap,
    required this.strokeWidth,
  });

  final Widget child;
  final double radius;
  final Color dashColor;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        radius: radius,
        dashColor: dashColor,
        dashWidth: dashWidth,
        dashGap: dashGap,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.radius,
    required this.dashColor,
    required this.dashWidth,
    required this.dashGap,
    required this.strokeWidth,
  });

  final double radius;
  final Color dashColor;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dashColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.dashColor != dashColor ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _PhotoGridItem extends StatelessWidget {
  const _PhotoGridItem({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildLocalImage(imageUrl, fit: BoxFit.cover),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.50), shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoAddGridItem extends StatelessWidget {
  const _PhotoAddGridItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: _DashedRRect(
        radius: 12,
        dashColor: const Color(0xFFCBD5E1),
        dashWidth: 7,
        dashGap: 6,
        strokeWidth: 2,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: const Color(0xFFF1F5F9),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo, size: 30, color: Color(0xFF2BCDEE)),
                SizedBox(height: 6),
                Text('添加照片', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ),
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
  if (isNetwork || kIsWeb) {
    return Image.network(trimmed, fit: fit, gaplessPlayback: true);
  }
  return Image.file(File(trimmed), fit: fit, gaplessPlayback: true);
}

Future<List<String>> _persistPickedImages(List<XFile> files, String folder) async {
  return persistImageFiles(files, folder: folder, prefix: folder);
}

Future<String?> _persistSingleImage(XFile file, String folder) async {
  return persistImageFile(file, folder: folder, prefix: folder);
}

class _CompanionInfo {
  const _CompanionInfo({required this.name, this.avatarPath});

  final String name;
  final String? avatarPath;
}

class _CompanionAvatar extends StatelessWidget {
  const _CompanionAvatar({required this.info});

  final _CompanionInfo info;

  @override
  Widget build(BuildContext context) {
    final avatar = (info.avatarPath ?? '').trim();
    final hasAvatar = avatar.isNotEmpty;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        color: const Color(0xFFE2E8F0),
      ),
      child: hasAvatar
          ? ClipOval(child: _buildLocalImage(avatar, fit: BoxFit.cover))
          : Center(
              child: Text(
                info.name.trim().isEmpty ? '?' : info.name.trim().characters.first,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
              ),
            ),
    );
  }
}

class _EmptyTravelState extends StatelessWidget {
  const _EmptyTravelState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
    );
  }
}

class _TripPickResult {
  const _TripPickResult(this.id, this.name);
  const _TripPickResult.empty()
      : id = '',
        name = '';

  final String id;
  final String name;

  bool get isEmpty => id.isEmpty;
}

Stream<TravelRecord?> _watchTravelById(AppDatabase db, String id) {
  return (db.select(db.travelRecords)
        ..where((t) => t.id.equals(id))
        ..where((t) => t.isDeleted.equals(false))
        ..limit(1))
      .watchSingleOrNull();
}

Stream<Trip?> _watchTripById(AppDatabase db, String id) {
  return (db.select(db.trips)..where((t) => t.id.equals(id))).watchSingleOrNull();
}

Stream<List<TravelRecord>> _watchTravelRecordsByTripId(AppDatabase db, String tripId) {
  return (db.select(db.travelRecords)
        ..where((t) => t.isDeleted.equals(false))
        ..where((t) => t.tripId.equals(tripId))
        ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
      .watch();
}

Stream<List<Trip>> _watchTripsByIds(AppDatabase db, List<String> ids) {
  if (ids.isEmpty) return Stream.value(const <Trip>[]);
  return (db.select(db.trips)..where((t) => t.id.isIn(ids))).watch();
}

List<_TravelOnTheRoadEntry> _buildTravelEntries({
  required List<TravelRecord> records,
  required List<Trip> trips,
  required List<FriendRecord> friends,
  required List<EntityLink> links,
}) {
  final tripById = {for (final t in trips) t.id: t};
  final friendById = {for (final f in friends) f.id: f};
  final friendIdsByTravel = <String, Set<String>>{};
  for (final link in links) {
    String? travelId;
    String? friendId;
    if (link.sourceType == 'travel' && link.targetType == 'friend') {
      travelId = link.sourceId;
      friendId = link.targetId;
    } else if (link.targetType == 'travel' && link.sourceType == 'friend') {
      travelId = link.targetId;
      friendId = link.sourceId;
    }
    if (travelId == null || friendId == null) continue;
    final set = friendIdsByTravel.putIfAbsent(travelId, () => <String>{});
    set.add(friendId);
  }

  return records.map((record) {
    final trip = tripById[record.tripId];
    final startDate = trip?.startDate ?? record.planDate ?? record.recordDate;
    final endDate = trip?.endDate ?? record.planDate ?? record.recordDate;
    final dateRange = _formatDateRange(startDate, endDate, record.recordDate);
    final durationDays = _durationDays(startDate, endDate);
    final place = _travelPlace(record, trip);
    final imageUrl = _pickCoverImage(record);
    final companionIds = friendIdsByTravel[record.id] ?? const <String>{};
    final companions = [
      for (final id in companionIds)
        if (friendById.containsKey(id))
          _CompanionInfo(
            name: friendById[id]!.name,
            avatarPath: friendById[id]!.avatarPath,
          ),
    ];
    return _TravelOnTheRoadEntry(
      year: startDate.year,
      dateRange: dateRange,
      durationDays: durationDays,
      place: place,
      imageUrl: imageUrl,
      companions: companions,
      item: _buildTravelItem(record, trip),
    );
  }).toList(growable: false);
}

TravelItem _buildTravelItem(TravelRecord record, Trip? trip) {
  final date = _formatDateCN(trip?.startDate ?? record.recordDate);
  final title = _travelTitle(record, trip);
  final subtitle = _travelSubtitle(record, trip);
  final imageUrl = _pickCoverImage(record);
  return TravelItem(
    date: date,
    title: title,
    subtitle: subtitle,
    imageUrl: imageUrl,
    travelId: record.id,
    tripId: record.tripId,
    recordDate: record.recordDate,
  );
}

TravelItem _buildWishlistItem(TravelRecord record, Trip? trip) {
  final date = _formatPlanLabel(record.planDate ?? trip?.startDate);
  final title = _travelTitle(record, trip);
  final subtitle = _travelPlace(record, trip);
  final imageUrl = _pickCoverImage(record);
  return TravelItem(
    date: date,
    title: title,
    subtitle: subtitle,
    imageUrl: imageUrl,
    travelId: record.id,
    tripId: record.tripId,
    recordDate: record.recordDate,
  );
}

String _travelTitle(TravelRecord record, Trip? trip) {
  final title = record.title?.trim() ?? '';
  if (title.isNotEmpty) return title;
  final tripName = trip?.name.trim() ?? '';
  if (tripName.isNotEmpty) return tripName;
  final destination = record.destination?.trim() ?? '';
  return destination.isNotEmpty ? destination : '旅行记录';
}

String _travelSubtitle(TravelRecord record, Trip? trip) {
  final content = (record.content ?? '').trim();
  if (content.isNotEmpty) {
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isNotEmpty) return lines.first.trim();
  }
  final place = _travelPlace(record, trip);
  return place.isNotEmpty ? place : '记录旅途的点滴';
}

String _travelPlace(TravelRecord record, Trip? trip) {
  final destination = (record.destination ?? '').trim();
  if (destination.isNotEmpty) return destination;
  final poiName = (record.poiName ?? '').trim();
  final poiAddress = (record.poiAddress ?? '').trim();
  if (poiName.isNotEmpty && poiAddress.isNotEmpty && !poiName.contains(poiAddress)) {
    return '$poiName · $poiAddress';
  }
  if (poiName.isNotEmpty) return poiName;
  if (poiAddress.isNotEmpty) return poiAddress;
  final tripDestinations = _decodeStringList(trip?.destinations);
  return tripDestinations.isNotEmpty ? tripDestinations.first : '未知目的地';
}

String _pickCoverImage(TravelRecord record) {
  final images = _decodeStringList(record.images);
  return images.isNotEmpty ? images.first : '';
}

String _pickFoodCoverImage(FoodRecord record) {
  final images = _decodeStringList(record.images);
  return images.isNotEmpty ? images.first : '';
}

String _pickFoodLabel(FoodRecord record) {
  final tags = _decodeStringList(record.tags);
  if (tags.isNotEmpty) return tags.first;
  final poiName = (record.poiName ?? '').trim();
  if (poiName.isNotEmpty) return poiName;
  return '美食';
}

String _pickFoodSubtitle(FoodRecord record) {
  final content = (record.content ?? '').trim();
  if (content.isNotEmpty) return content;
  final poiAddress = (record.poiAddress ?? '').trim();
  if (poiAddress.isNotEmpty) return poiAddress;
  return '记录一餐的味道';
}

String _formatDateCN(DateTime date) {
  return '${date.year}年${date.month}月${date.day}日';
}

String _formatPlanLabel(DateTime? date) {
  if (date == null) return '计划：待定';
  return '计划：${date.year}年${date.month}月';
}

String _formatDateRange(DateTime? start, DateTime? end, DateTime fallback) {
  final startDate = start ?? end ?? fallback;
  final endDate = end ?? startDate;
  if (_isSameDay(startDate, endDate)) {
    return '${startDate.month}月${startDate.day}日';
  }
  return '${startDate.month}月${startDate.day}日 - ${endDate.month}月${endDate.day}日';
}

String _formatDaySubTitle(DateTime date) {
  return '${date.month}月${date.day}日 · ${_weekdayLabel(date.weekday)}';
}

String _weekdayLabel(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return '星期一';
    case DateTime.tuesday:
      return '星期二';
    case DateTime.wednesday:
      return '星期三';
    case DateTime.thursday:
      return '星期四';
    case DateTime.friday:
      return '星期五';
    case DateTime.saturday:
      return '星期六';
    case DateTime.sunday:
      return '星期日';
    default:
      return '星期';
  }
}

int _durationDays(DateTime? start, DateTime? end) {
  if (start == null && end == null) return 1;
  final startDate = start ?? end!;
  final endDate = end ?? startDate;
  final diff = endDate.difference(startDate).inDays;
  return diff.abs() + 1;
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

List<String> _decodeStringList(String? raw) {
  if (raw == null) return const <String>[];
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return const <String>[];
  try {
    final list = jsonDecode(trimmed) as List;
    return list.map((e) => e.toString()).toList();
  } catch (_) {
    return const <String>[];
  }
}

class _ContentParts {
  const _ContentParts({required this.note, required this.flight, required this.hotel});
  final String note;
  final String flight;
  final String hotel;
}

String _formatDurationLabel(int days) {
  if (days <= 1) return '1天';
  return '$days天';
}

String _formatDateDotRange(DateTime? start, DateTime? end) {
  if (start == null && end == null) return '';
  final startDate = start ?? end!;
  final endDate = end ?? startDate;
  if (_isSameDay(startDate, endDate)) {
    return '${startDate.month}.${startDate.day}';
  }
  return '${startDate.month}.${startDate.day} - ${endDate.month}.${endDate.day}';
}

class _AssociationRow extends StatelessWidget {
  const _AssociationRow({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                  ],
                ],
              ),
            ),
            trailing,
          ],
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
  const _AvatarCircle({required this.name, this.avatarPath});

  final String name;
  final String? avatarPath;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter = trimmed.isEmpty ? '?' : trimmed.substring(0, 1);
    final hasAvatar = avatarPath != null && avatarPath!.trim().isNotEmpty;
    
    Widget content;
    if (hasAvatar) {
      content = ClipOval(
        child: Image.file(
          File(avatarPath!),
          fit: BoxFit.cover,
          width: 48,
          height: 48,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(letter, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF334155))),
            );
          },
        ),
      );
    } else {
      content = Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(letter, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF334155))),
      );
    }
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: content,
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

class _MoodIcon extends StatelessWidget {
  const _MoodIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: const Color(0xFFF97316).withValues(alpha: 0.14), shape: BoxShape.circle),
      child: const Icon(Icons.sentiment_satisfied, size: 18, color: Color(0xFFF97316)),
    );
  }
}

class _TagIcon extends StatelessWidget {
  const _TagIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: const Color(0xFF3B82F6).withValues(alpha: 0.14), shape: BoxShape.circle),
      child: const Icon(Icons.label, size: 18, color: Color(0xFF3B82F6)),
    );
  }
}

class _TinyAvatar extends StatelessWidget {
  const _TinyAvatar({required this.url, this.size = 28});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2)),
        child: ClipOval(child: _buildLocalImage(url, fit: BoxFit.cover)),
      ),
    );
  }
}

class _TinyLetterAvatar extends StatelessWidget {
  const _TinyLetterAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter = trimmed.isEmpty ? '?' : trimmed.substring(0, 1);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      alignment: Alignment.center,
      child: Text(letter, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF3B82F6))),
    );
  }
}
