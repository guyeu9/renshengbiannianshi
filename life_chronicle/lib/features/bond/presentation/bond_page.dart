import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/utils/media_storage.dart';

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

  void _handleAdd() {
    if (_tabIndex == 0) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FriendCreatePage()));
      return;
    }
    if (_tabIndex == 1) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EncounterCreatePage()));
    }
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
              onTabChanged: (next) => setState(() => _tabIndex = next),
              onAddTap: _handleAdd,
              onFilterTap: _openFilterSheet,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _tabIndex == 0 ? const _FriendArchiveList() : const _EncounterTimeline(),
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
    required this.onTabChanged,
    required this.onAddTap,
    required this.onFilterTap,
  });

  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onAddTap;
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
                  '羁绊',
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
                        child: Text(
                          tabIndex == 1 ? '搜索相遇回忆...' : '搜索朋友档案...',
                          style: const TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _CircleIconButton(icon: Icons.tune, onTap: onFilterTap),
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
  });

  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
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

class _SegmentedPill extends StatelessWidget {
  const _SegmentedPill({required this.tabIndex, required this.onChanged});

  final int tabIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final pillWidth = (w - 8) / 2;

        return Container(
          height: 52,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                left: tabIndex == 0 ? 0 : pillWidth,
                top: 0,
                bottom: 0,
                width: pillWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
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
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: tabIndex == 0 ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
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
                            fontSize: 15,
                            fontWeight: tabIndex == 1 ? FontWeight.w800 : FontWeight.w700,
                            color: tabIndex == 1 ? const Color(0xFF2BCDEE) : const Color(0xFF6B7280),
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
      },
    );
  }
}

class _FriendArchiveList extends ConsumerWidget {
  const _FriendArchiveList();

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
        final left = <FriendRecord>[];
        final right = <FriendRecord>[];
        for (var i = 0; i < friends.length; i++) {
          (i.isEven ? left : right).add(friends[i]);
        }
        return SingleChildScrollView(
          key: const ValueKey('friend_archives'),
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 140),
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
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _BondFriendDetailPage(friend: friend))),
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
                        _buildLocalImage(avatarPath, fit: BoxFit.cover)
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

class _EncounterTimeline extends StatelessWidget {
  const _EncounterTimeline();

  static const _items = <_EncounterItem>[
    _EncounterItem(
      date: '2023年10月15日',
      title: '与 小明 在 Oishii Sushi 共进晚餐',
      content: '分享了最近的职场趣闻，寿司的味道依然如故。聊到了关于明年的旅行计划。',
      icon: Icons.calendar_today,
      iconFilled: true,
      avatars: [
        _EncounterAvatar(
          image:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAGk_HxDxrbpCRA6nSpTvEx_Io_FA5-C-wqijGhFkRJZFjWpnNLZ-k-AQhJwTA8l2oHDOwDJJGVRBDrNX54Ud6jT0MXlkXTfMYEVYfvY9GS_joYMeb0OOUimcx0PQfqw8ibMAAGF1F-3looMH4sH5jO8v6-GAII_IFmIqZ1Zw9NSsu7YxXpTCTVudfG0FG1Pc8uu9R9BL407BNh7DUcIWczb_gQ7MDiJ3oHnBwVnQHuH8ZpZMnIOjAQmw_d-cboUPe_DoRuhUg9ZyI6',
          badge: 'Me',
        ),
      ],
      extraChip: 'M',
    ),
    _EncounterItem(
      date: '2023年9月20日',
      title: '与 佳佳、阿强 开启 京都之旅',
      content: '清水寺的晚霞非常壮丽。三个人的旅行虽然偶尔有小摩擦，但更多的是欢笑。',
      icon: Icons.flight_takeoff,
      iconFilled: true,
      avatars: [
        _EncounterAvatar(
          image:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAfqbTtlSzcGbxP6sDWFkXEXnXY7S9cEL6Bt3EJFPLD4Rw4StNb79kcTLEPX-DpJkD-EixDzyQ6VaF22CHOCaE0oYW39n2OsTFHJzLc152j70DhBjAAR5fvSJSTauBaUMy49hKBlkyVA9qW0YTbdc9La2XSgErXsEHMkPotxhkDCM3ji8Ztz0Pniue06QW1WXBgJvIZt2LvcGUYOW4SBrEjzS-xqNRpXpHhqISfj24SoyJj7wCWaf9vQce7Lm5-lO3SsHbeXAYpSmqo',
        ),
        _EncounterAvatar(
          image:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDtAP63KUCiq0PzWilgClTpCmQSFmEXpK9FGb2IB7ogpjVWu_vs342c4QeGysBwdHS1jP7MGfXnuwRozaxnI_8Lp0i_JBo7-3uqhagGpgt8MVAOyhMUAcz4GQl-Y7kqzYE0pzBFVw3esKYOm4MnQJsTRx4cv14lraUivp1APir-9n02Ajzdl3nPBejG-cCs69Tle82GmPCROQzKPfEerHtNsruSKQycVv2lM7wbb8YO66mUp0XgOgqr8aoGHomDB5UjYoVUdB4WxGos',
        ),
      ],
      extraChip: '+2 位伙伴',
    ),
    _EncounterItem(
      date: '2023年8月05日',
      title: '在 公园 与 小红 散步',
      content: '初秋的微风，我们聊了很多关于未来的想法。生活就是由这些平凡的时刻组成的。',
      icon: Icons.park,
      iconFilled: true,
      avatars: [
        _EncounterAvatar(
          image:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBjJ_wNHKW7CgtCLI2HD7UJjfBb-w2Tp1oreBYKtJEJmzS5ZocJ7P1u3GIskb2LWreXDDihpXzWjEhSt8rrwn9356112wZu2fz8HepNGNfOaxTFiTK5SwltbAsJAVWsOi-Z6p4X03UtTN4lIn8u61_jer0T8mer3Iti8vGeLepODSFiOFyaTHMLD95vuDshdpk13EscElon4D_4POOR2ir6Zij-MR2SykIenIJ6PdLNzSosTQGzQDymOcI7dYq936Ve4oFdBcZ8sL9A',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const ValueKey('encounters'),
      children: [
        Positioned(
          left: 36,
          top: 0,
          bottom: 0,
          child: Container(width: 2, color: const Color(0xFFE5E7EB)),
        ),
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
          children: [
            for (final item in _items) ...[
              _EncounterRow(item: item),
              const SizedBox(height: 18),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 26),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
                  ),
                  child: const Text('已加载全部美好回忆', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EncounterItem {
  const _EncounterItem({
    required this.date,
    required this.title,
    required this.content,
    required this.icon,
    required this.iconFilled,
    required this.avatars,
    this.extraChip,
  });

  final String date;
  final String title;
  final String content;
  final IconData icon;
  final bool iconFilled;
  final List<_EncounterAvatar> avatars;
  final String? extraChip;
}

class _EncounterAvatar {
  const _EncounterAvatar({required this.image, this.badge});

  final String image;
  final String? badge;
}

class _EncounterRow extends StatelessWidget {
  const _EncounterRow({required this.item});

  final _EncounterItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 6),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.date.contains('10月') ? const Color(0xFF2BCDEE) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: item.date.contains('10月') ? const Color(0xFFF6F6F6) : const Color(0xFFEAF9FD),
              width: 3,
            ),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Icon(
            item.icon,
            color: item.date.contains('10月') ? Colors.white : const Color(0xFF2BCDEE),
            size: 18,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _EncounterDetailPage(item: item))),
              borderRadius: BorderRadius.circular(28),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0x00000000)),
                  boxShadow: [BoxShadow(color: const Color(0xFF2BCDEE).withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
                        ),
                        const Icon(Icons.chevron_right, size: 18, color: Color(0x809CA3AF)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1.2)),
                    const SizedBox(height: 8),
                    Text(item.content, style: const TextStyle(fontSize: 13, color: Color(0xFF78909C), height: 1.4)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          height: 32,
                          child: Stack(
                            children: [
                              for (var i = 0; i < item.avatars.length; i++)
                                Positioned(
                                  left: i * 18,
                                  child: _Avatar(image: item.avatars[i].image, badge: item.avatars[i].badge),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (item.extraChip != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(999)),
                            child: Text(item.extraChip!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                          ),
                      ],
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
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.image, this.badge});

  final String image;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
          ),
          if (badge != null)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2BCDEE),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(badge!, style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
    );
  }
}

class _BondFriendDetailPage extends StatelessWidget {
  const _BondFriendDetailPage({required this.friend});

  final FriendRecord friend;

  @override
  Widget build(BuildContext context) {
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
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  _FriendProfileCard(friend: friend),
                  const SizedBox(height: 14),
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () {},
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
      ),
    );
  }
}

class _FriendProfileCard extends StatelessWidget {
  const _FriendProfileCard({required this.friend});

  final FriendRecord friend;

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
                    : _buildLocalImage(friend.avatarPath!, fit: BoxFit.cover),
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
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2BCDEE)),
                    foregroundColor: const Color(0xFF2BCDEE),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Colors.transparent,
                  ),
                  icon: const Icon(Icons.bookmark_border, size: 18),
                  label: const Text('收藏', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
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

  List<_FriendMemoryItem> _parseEvents(List<TimelineEvent> events) {
    return events.map((e) {
      String place = '';
      String content = '';
      List<String> images = [];

      if (e.note != null) {
        final lines = e.note!.split('\n');
        for (final line in lines) {
          if (line.startsWith('地点：')) {
            place = line.substring(3).trim();
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

      return _FriendMemoryItem(
        date: '${e.recordDate.year}年 ${e.recordDate.month}月 ${e.recordDate.day}日',
        typeLabel: '遭遇', // 暂时统一
        typeIcon: Icons.diversity_3,
        title: e.title,
        content: content,
        place: place,
        images: images,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);

    return StreamBuilder<List<TimelineEvent>>(
      stream: db.watchEncountersForFriend(widget.friend.id),
      builder: (context, snapshot) {
        final events = snapshot.data ?? [];
        final items = _parseEvents(events);

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
                                Text('共 ${items.length} 个美好瞬间', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF9CA3AF))),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.filter_list, size: 18),
                            label: const Text('筛选'),
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

              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Center(child: Text('还没有共同回忆哦，快去记录一次遭遇吧！', style: TextStyle(color: Color(0xFF9CA3AF)))),
                );
              }

              final itemIndex = index - 1;
              final item = items[itemIndex];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: _TimelineEntry(item: item, isLast: itemIndex == items.length - 1),
              );
            },
            childCount: items.isEmpty ? 2 : items.length + 1,
          ),
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
    required this.date,
    required this.typeLabel,
    required this.typeIcon,
    required this.title,
    required this.content,
    required this.place,
    required this.images,
  });

  final String date;
  final String typeLabel;
  final IconData typeIcon;
  final String title;
  final String content;
  final String place;
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
                      _buildLocalImage(item.images.first, fit: BoxFit.cover),
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
                        const Icon(Icons.place, size: 16, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(item.place, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
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
                          _buildLocalImage(displayImages[index], fit: BoxFit.cover),
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
                    const Icon(Icons.place, size: 16, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(item.place, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
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
                  if (item.place.isNotEmpty) ...[
                    const Icon(Icons.place, size: 14, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text(item.place, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                  ],
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
  const FriendCreatePage({super.key});

  @override
  ConsumerState<FriendCreatePage> createState() => _FriendCreatePageState();
}

class _FriendCreatePageState extends ConsumerState<FriendCreatePage> {
  static const _uuid = Uuid();
  static const _frequencyOptions = ['无需提醒', '每一个月提醒一次', '每三个月提醒一次', '每年提醒一次'];
  static const _presetTags = [
    '家人',
    '同学',
    '同事',
    '闺蜜',
    '饭搭子',
    '旅行搭子',
    '球友',
    '靠谱',
    '有趣',
    '温柔',
    '爱运动',
    '爱拍照',
  ];

  final _nameController = TextEditingController();
  final _meetWayController = TextEditingController();
  final _remarkController = TextEditingController();

  String? _avatarPath;
  DateTime? _birthday;
  DateTime? _meetDate;
  String? _contactFrequency = '无需提醒';
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
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

  Future<void> _openTagPickerSheet() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        var selected = <String>{..._selectedTags};
        return StatefulBuilder(
          builder: (context, setInner) {
            return _BottomSheetShell(
              title: '印象标签',
              actionText: '完成',
              onAction: () => Navigator.of(context).pop(selected.toList()),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final tag in _presetTags)
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              if (selected.contains(tag)) {
                                selected.remove(tag);
                              } else {
                                selected.add(tag);
                              }
                              setInner(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected.contains(tag) ? const Color(0x1A0EA5E9) : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: selected.contains(tag) ? const Color(0xFF0EA5E9) : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            await Navigator.of(context).maybePop();
                            if (!mounted) return;
                            await _addCustomTag();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.transparent,
                            ),
                            child: const Text(
                              '添加标签',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (result == null) return;
    setState(() {
      _selectedTags
        ..clear()
        ..addAll(result.map((e) => e.replaceAll('#', '').trim()).where((e) => e.isNotEmpty));
    });
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
    final friendId = _uuid.v4();
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
        createdAt: now,
        updatedAt: now,
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final avatarPath = (_avatarPath ?? '').trim();
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
                                : _buildLocalImage(avatarPath, fit: BoxFit.cover),
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
                    Row(
                      children: [
                        const Expanded(
                          child: Text('印象标签', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF999999))),
                        ),
                        TextButton(
                          onPressed: _openTagPickerSheet,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF0EA5E9),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                          ),
                          child: const Text('选择'),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final t in _selectedTags)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0x1A0EA5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0EA5E9))),
                                const SizedBox(width: 6),
                                InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: () => setState(() => _selectedTags.remove(t)),
                                  child: const Icon(Icons.close, size: 16, color: Color(0xFF0EA5E9)),
                                ),
                              ],
                            ),
                          ),
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
                      const Expanded(
                        child: Center(
                          child: Text('新建档案', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
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
  }
}

class EncounterCreatePage extends ConsumerStatefulWidget {
  const EncounterCreatePage({super.key});

  @override
  ConsumerState<EncounterCreatePage> createState() => _EncounterCreatePageState();
}

class _EncounterCreatePageState extends ConsumerState<EncounterCreatePage> {
  static const _uuid = Uuid();

  final _titleController = TextEditingController();
  final _moodController = TextEditingController();
  final _placeController = TextEditingController();

  DateTime _date = DateTime.now();
  final List<String> _imageUrls = [];

  final Set<String> _linkedFriendIds = {};
  final Set<String> _linkedFoodIds = {};
  bool _linkTravel = false;
  bool _linkGoal = false;

  @override
  void dispose() {
    _titleController.dispose();
    _moodController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('zh', 'CN'),
    );
    if (pickedDate == null) return;
    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('zh', 'CN'),
          child: child,
        );
      },
    );
    if (pickedTime == null) return;
    setState(() => _date = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute));
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
    return persistImageFiles(files, folder: 'encounter', prefix: 'encounter');
  }

  void _removeImageAt(int index) {
    setState(() => _imageUrls.removeAt(index));
  }

  Future<void> _selectFriends() async {
    final db = ref.read(appDatabaseProvider);
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StreamBuilder<List<FriendRecord>>(
          stream: db.friendDao.watchAllActive(),
          builder: (context, snapshot) {
            final items = (snapshot.data ?? const <FriendRecord>[])
                .map(
                  (f) => _SelectItem(
                    id: f.id,
                    title: f.name,
                    leading: _AvatarCircle(name: f.name, imagePath: f.avatarPath),
                  ),
                )
                .toList(growable: false);
            return _MultiSelectBottomSheet(title: '选择相遇对象', items: items, initialSelected: _linkedFriendIds);
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

  Future<void> _selectFoods() async {
    final db = ref.read(appDatabaseProvider);
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StreamBuilder<List<FoodRecord>>(
          stream: db.foodDao.watchAllActive(),
          builder: (context, snapshot) {
            final items = (snapshot.data ?? const <FoodRecord>[])
                .map(
                  (f) => _SelectItem(
                    id: f.id,
                    title: f.title,
                    leading: const _IconSquare(color: Color(0xFFFFEDD5), icon: Icons.restaurant, iconColor: Color(0xFFFB923C)),
                  ),
                )
                .toList(growable: false);
            return _MultiSelectBottomSheet(title: '关联美食', items: items, initialSelected: _linkedFoodIds);
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

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先填写标题')));
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final encounterId = _uuid.v4();
    final recordDate = DateTime(_date.year, _date.month, _date.day);

    final place = _placeController.text.trim();
    final mood = _moodController.text.trim();
    final noteParts = <String>[];
    if (place.isNotEmpty) noteParts.add('地点：$place');
    if (mood.isNotEmpty) noteParts.add('心情分享：$mood');
    if (_imageUrls.isNotEmpty) noteParts.add('图片：${jsonEncode(_imageUrls)}');
    final note = noteParts.isEmpty ? null : noteParts.join('\n');

    await db.into(db.timelineEvents).insertOnConflictUpdate(
          TimelineEventsCompanion.insert(
            id: encounterId,
            title: title,
            eventType: 'encounter',
            startAt: Value(_date),
            endAt: const Value(null),
            note: Value(note),
            recordDate: recordDate,
            createdAt: now,
            updatedAt: now,
          ),
        );

    for (final id in _linkedFriendIds) {
      await db.linkDao.createLink(
        sourceType: 'encounter',
        sourceId: encounterId,
        targetType: 'friend',
        targetId: id,
        now: now,
      );
    }
    for (final id in _linkedFoodIds) {
      await db.linkDao.createLink(
        sourceType: 'encounter',
        sourceId: encounterId,
        targetType: 'food',
        targetId: id,
        now: now,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _CreateTopBar(
              title: '记录相遇',
              onCancel: () => Navigator.of(context).maybePop(),
              actionText: '保存',
              onAction: _save,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                children: [
                  _SectionCard(
                    title: '标题',
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: '一句话概括这次相遇',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: '相遇对象',
                    child: Column(
                      children: [
                        SizedBox(
                          height: 56,
                          child: Row(
                            children: [
                              Expanded(
                                child: _SelectedAvatarsRow(
                                  selectedIds: _linkedFriendIds,
                                  onTap: _selectFriends,
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: _selectFriends,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF2BCDEE),
                                  side: BorderSide(color: const Color(0xFF2BCDEE).withValues(alpha: 0.25)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('添加', style: TextStyle(fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _FieldCard(
                          label: '日期',
                          icon: Icons.calendar_today,
                          iconColor: const Color(0xFF0095FF),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _pickDate,
                            child: Row(
                              children: [
                                Text(_formatDate(_date), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                const Spacer(),
                                const Icon(Icons.edit, size: 18, color: Color(0xFF94A3B8)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FieldCard(
                          label: '地点',
                          icon: Icons.location_on,
                          iconColor: const Color(0xFF0095FF),
                          child: TextField(
                            controller: _placeController,
                            decoration: const InputDecoration(hintText: '在哪里相遇?', border: InputBorder.none),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: '心情分享',
                    child: TextField(
                      controller: _moodController,
                      minLines: 4,
                      maxLines: 7,
                      decoration: const InputDecoration(
                        hintText: '记录下这美好的一刻...',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827), height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: '上传照片',
                    child: Column(
                      children: [
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
                            return _PhotoTile(url: _imageUrls[index], onRemove: () => _removeImageAt(index));
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: '万物互联',
                    trailing: const Icon(Icons.link, size: 18, color: Color(0xFF0095FF)),
                    child: Column(
                      children: [
                        _LinkToggleRow(
                          title: '关联美食',
                          subtitle: _linkedFoodIds.isEmpty ? '刚才一起吃了什么?' : '已选 ${_linkedFoodIds.length} 条',
                          iconBackground: const Color(0xFFFFEDD5),
                          icon: Icons.restaurant,
                          iconColor: const Color(0xFFFB923C),
                          checked: _linkedFoodIds.isNotEmpty,
                          onTap: _selectFoods,
                        ),
                        const SizedBox(height: 10),
                        _LinkToggleRow(
                          title: '关联旅行',
                          subtitle: '是在旅途中相遇吗?',
                          iconBackground: const Color(0xFFE0F2FE),
                          icon: Icons.flight,
                          iconColor: const Color(0xFF0095FF),
                          checked: _linkTravel,
                          onTap: () => setState(() => _linkTravel = !_linkTravel),
                        ),
                        const SizedBox(height: 10),
                        _LinkToggleRow(
                          title: '关联目标',
                          subtitle: '是否达成了共同目标?',
                          iconBackground: const Color(0xFFF3E8FF),
                          icon: Icons.flag,
                          iconColor: const Color(0xFFA855F7),
                          checked: _linkGoal,
                          onTap: () => setState(() => _linkGoal = !_linkGoal),
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

class _ChipPill extends StatelessWidget {
  const _ChipPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
    );
  }
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
        color: Colors.white.withValues(alpha: 0.92),
        border: const Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B), textStyle: const TextStyle(fontWeight: FontWeight.w800)),
            child: const Text('取消'),
          ),
          Expanded(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, this.trailing, required this.child});

  final String title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Expanded(child: child),
            ],
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
      borderRadius: BorderRadius.circular(16),
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
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2BCDEE).withValues(alpha: 0.2), width: 2),
        ),
        child: const Center(child: Icon(Icons.add_a_photo, color: Color(0xFF2BCDEE))),
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

class _LinkToggleRow extends StatelessWidget {
  const _LinkToggleRow({
    required this.title,
    required this.subtitle,
    required this.iconBackground,
    required this.icon,
    required this.iconColor,
    required this.checked,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color iconBackground;
  final IconData icon;
  final Color iconColor;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: checked ? const Color(0xFF0095FF).withValues(alpha: 0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: checked ? const Color(0xFF0095FF).withValues(alpha: 0.18) : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                ],
              ),
            ),
            if (checked)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(color: Color(0xFF0095FF), shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              )
            else
              const Icon(Icons.radio_button_unchecked, color: Color(0xFFCBD5E1)),
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
                                imagePath: friend.avatarPath,
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
  const _FilterFriendTile({required this.name, required this.imagePath, required this.checked, required this.onTap});

  final String name;
  final String? imagePath;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter = trimmed.isEmpty ? '?' : trimmed.characters.first;
    final path = imagePath?.trim() ?? '';
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
              child: path.isEmpty ? Text(letter, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF64748B))) : ClipOval(child: _buildLocalImage(path, fit: BoxFit.cover)),
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
  const _MultiSelectBottomSheet({required this.title, required this.items, required this.initialSelected});

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
                    Expanded(child: Text(widget.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(_selected),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF2BCDEE), textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
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
            ],
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
          : ClipOval(child: _buildLocalImage(path, fit: BoxFit.cover)),
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

class _SelectedAvatarsRow extends ConsumerWidget {
  const _SelectedAvatarsRow({required this.selectedIds, required this.onTap});

  final Set<String> selectedIds;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder<List<FriendRecord>>(
      stream: db.friendDao.watchAllActive(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <FriendRecord>[];
        final selected = all.where((f) => selectedIds.contains(f.id)).toList(growable: false);
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                if (selected.isEmpty)
                  const Expanded(
                    child: Text('请选择相遇对象', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                  )
                else
                  Expanded(
                    child: Row(
                      children: [
                        for (final f in selected.take(4)) ...[
                          _AvatarCircle(name: f.name, imagePath: f.avatarPath),
                          const SizedBox(width: 8),
                        ],
                        if (selected.length > 4)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                            child: Text('+${selected.length - 4}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EncounterDetailPage extends StatelessWidget {
  const _EncounterDetailPage({required this.item});

  final _EncounterItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
            title: const Text('相遇详情', style: TextStyle(fontWeight: FontWeight.w900)),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(color: const Color(0x1A2BCDEE), borderRadius: BorderRadius.circular(12)),
                              child: Icon(item.icon, color: const Color(0xFF2BCDEE)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(item.date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1.2)),
                        const SizedBox(height: 10),
                        Text(item.content, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B), height: 1.5)),
                        const SizedBox(height: 14),
                        const Text('参与者', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (final a in item.avatars) ...[
                              _Avatar(image: a.image, badge: a.badge),
                              const SizedBox(width: 8),
                            ],
                            if (item.extraChip != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(999)),
                                child: Text(item.extraChip!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text('万物互联', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _ChipPill(text: '关联美食'),
                            _ChipPill(text: '关联旅行'),
                            _ChipPill(text: '关联小确幸'),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                  child: const Text('关联', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
