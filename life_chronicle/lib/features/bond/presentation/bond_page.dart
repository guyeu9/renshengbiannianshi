import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';

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

class _FriendArchiveList extends StatelessWidget {
  const _FriendArchiveList();

  static const _friends = <_FriendArchiveItem>[
    _FriendArchiveItem(
      name: '林小鱼',
      days: '3650天',
      lastMeet: '上次见面：3天前',
      tags: ['老同学', '饭搭子'],
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDnx1BVMR2dn9-gpBBTIe286GD2f9d7IG3M2LVpHr5OQjFJ8YLsVB8yjzaoMV7Dr811Vw5m0T_opKoELbOUkPeZb_STLqC35_ENoXDazPq9TTwohuyly8N9jOpaxzpWzP4q2ZrMclyVw9pcUxfIm4EOAZLzcuyNY4TqjN7ri4M9GVuLVvlIndWVHWw12-0TPCbW_KzK61CDR_0fhUFP6jUiZcAi4PL0CKrr_Kyc_gQOqS7fTHK54Ah5-dfm-X8gewzUscxFZQELJCJC',
      imageHeight: 170,
    ),
    _FriendArchiveItem(
      name: '陈老师',
      days: '1020天',
      lastMeet: '上次见面：15天前',
      tags: ['导师', '智慧'],
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCHu7IjV4cm33RK-pkW6hoonuhAQb-DyLv1iVA2dKyQzhd53lWXWSVa6eJW6rK7TKJnUToCMFXgmbTJ5g-mq297SH27qPKorpNg89CDpkS8jMwru2zk1tk7xfAlvodwWdYB35Yqzc2O4_ySLIqrlWkt5iqPTI-nAg5nSGaTs0EtWfpyvlACMrdqnHi_1OA5skMQLi0f3jkQIudZvkcVmNTpSXhsliEpFVz-yLcLGAFL79i_Q_Wn0FxMY54HVtZa1wHbBGKAo5tDTOSU',
      imageHeight: 220,
    ),
    _FriendArchiveItem(
      name: 'Jason',
      days: '45天',
      lastMeet: '上次见面：昨天',
      tags: ['球友', '健身'],
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD7a6VGtTuMF5_1dOUkhDvMytXsN_vaVbM1zmWeRy2xsUiPpU4nj0m8bEj9AgIG4HXGDqpXAU22jtovDG11u5qOoRLN-XtLa8JVPps9PXgUtMjgGbLvdk6w9rLQdflNn3ebsmEzJLlnk4Ibu2aw0t0hC-qbpowK8L2ZdAAvoWdSpvpmweSC43SYii0vr3DYbtX2N3KpTt06nN5hQY1y4KKXCqQ107XJOP9MSSy1zNazGNu__RWQYxgkPt4E_cYATP9roWtyz9l-AXk9',
      imageHeight: 150,
    ),
    _FriendArchiveItem(
      name: '阿花',
      days: '8500天',
      lastMeet: '上次见面：1年前',
      tags: ['发小', '邻居', '搞笑'],
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCPTEFJCEvq3DE8_rarnMy0tRvPerq84lGyzqbcCGjBMMAVPCBpNdC2UiSOKAzOzP6jN7BtlyuM4UVSjzaKNBero_HjI3Oum6NUUwOnpsVLWtmiSnmjnQSxyQPNMZCuUPr-zgyBXTv-quBWZSz_uOTZVnqg8XMrNDVidthYpPO-C7UC8l_rQ65Vvnm2swtHoTVeFpcelpF2eLQPDCu_f68VXQUU_6pAxVQldsQaT-u_r3XpTzK8HrappLNRLKJuwVIrBG5ApFnPfS_Q',
      imageHeight: 200,
    ),
    _FriendArchiveItem(
      name: 'Sarah',
      days: '730天',
      lastMeet: '上次见面：2周前',
      tags: ['前同事', '设计'],
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBIwIvarteoBM8y0GPR6HHpqwu0yNUd9dNkLND1caedxNoKeLgEj9WAYQbea4GgSibuHyhjyA938K_EmDyI6OVhJ_vNJZ2i5o7kmlcMVv4Q8r2ejwwqn7z6Sq675IYyjQQnKpjRUeLmBPXa-8WGtsJgai_L7J5U_SihU8cSaSp0gHIMWqnyzTidGDslR7geVHGIN2h6AqmlAlpHQQZ711HQ_W6FpZe-5PUHC6innHDBPkAQGjeFrrj7PZJQ3fBb9Ug1vjNS6vcFaZg_',
      imageHeight: 170,
    ),
    _FriendArchiveItem(
      name: '旺财',
      days: '2100天',
      lastMeet: '上次见面：刚刚',
      tags: ['家人', '可爱'],
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCsCdjZ-FoTFjkLobd1gTqAEFaDqJLutaF8EGbGNBE_NvWKSUhwxsrG5lR1c58Hb0C6hTa4mIg0-dI2uWA2w_wEWaPuuf407WCTZ6I39C0TQfDBY6SaEdrmP4VUXnVK1ekQSEPOtoV4WLB-p8kYjQEr95LINZec5HBjPlwnIL3sVCj2dvUiyYntPetNyKMBV46sNwhdhNMST5-j7ePBPiM1LIccqJ6wSJt2PB6aTVS0V0h9aKLl4zpvViF50D0gcLxQHnYyuQIm2nyB',
      imageHeight: 170,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final left = <_FriendArchiveItem>[];
    final right = <_FriendArchiveItem>[];
    for (var i = 0; i < _friends.length; i++) {
      (i.isEven ? left : right).add(_friends[i]);
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
                  _FriendCard(item: item),
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
                  _FriendCard(item: item),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendArchiveItem {
  const _FriendArchiveItem({
    required this.name,
    required this.days,
    required this.tags,
    required this.lastMeet,
    required this.imageUrl,
    required this.imageHeight,
  });

  final String name;
  final String days;
  final List<String> tags;
  final String lastMeet;
  final String imageUrl;
  final double imageHeight;
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({required this.item});

  final _FriendArchiveItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 0,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _BondFriendDetailPage(friend: item))),
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
                  height: item.imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildLocalImage(item.imageUrl, fit: BoxFit.cover),
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
                            item.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0x1A2BCDEE), borderRadius: BorderRadius.circular(999)),
                          child: Text(
                            item.days,
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
                        for (final t in item.tags)
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
                            item.lastMeet,
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

  final _FriendArchiveItem friend;

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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
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
                  _FriendMemoryTimeline(friend: friend),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendProfileCard extends StatelessWidget {
  const _FriendProfileCard({required this.friend});

  final _FriendArchiveItem friend;

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
        children: [
          Container(
            width: 88,
            height: 88,
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0x332BCDEE),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: _buildLocalImage(friend.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
          Text(friend.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Text('已认识 ${friend.days}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFFB923C))),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: _InfoPair(label: '朋友生日', value: '10月26日 (还有12天)')),
              SizedBox(width: 12),
              Expanded(child: _InfoPair(label: '认识途径', value: '市一中 高中同学')),
            ],
          ),
          const SizedBox(height: 12),
          const _InfoPair(label: '备注', value: '高中死党，超级火锅爱好者'),
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
                    for (final t in friend.tags)
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
      ],
    );
  }
}

class _FriendMemoryTimeline extends StatefulWidget {
  const _FriendMemoryTimeline({required this.friend});

  final _FriendArchiveItem friend;

  @override
  State<_FriendMemoryTimeline> createState() => _FriendMemoryTimelineState();
}

class _FriendMemoryTimelineState extends State<_FriendMemoryTimeline> {
  var _filterIndex = 0;

  static const _items = <_FriendMemoryItem>[
    _FriendMemoryItem(
      date: '2023年 10月 14日',
      typeLabel: '旅行',
      typeIcon: Icons.flight_takeoff,
      title: '京都红叶之旅',
      content: '即使下雨也很美的一天。我们在清水寺求了签，还吃到了超级好吃的抹茶冰淇淋！说好明年还要一起来。',
      place: '日本 · 京都',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA0aY7ho5JFR6xd4Dx-Viy_Ln5A4nyN9jjpKfK2OFlY6OrMzrIgYOq4teJOs1HlLjtUBmXlYBvVsvnq456VIIROH-_F7l6jQ2Tq_ncq7SW40NuJxrsIb_TY3IFMuood77iHB0ySyu2oHOhjjxQk0PWidNZ9mC5ZHI7-G6Ansi01UHXY1pnmU2r34RLwK6BTNial925C9cueZlbvw_9S_kQiEnwsveuq4rmYDX7It1U0ZYkwtJ8z2oNqYoJ8EJ1JzY72qElThvRP-ZpH',
      large: true,
    ),
    _FriendMemoryItem(
      date: '2023年 8月 2日',
      typeLabel: '美食',
      typeIcon: Icons.restaurant,
      title: '火锅局 🔥',
      content: '老地方见！晓雯终于不迟到了哈哈。',
      place: '上海 · 静安',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBYngYbbhn5XYOmWdqL2n_WAXBvW7DNtnZuqlNEVluNk-3sdfN8wxt2C11Zw1Mb2MSMzfnTmiGs3OYlrI6z_T9Uelht6wACNNhbRIuTRtDRp4jgCCCBq6TKdWHMgSs4vuJHRjYdByVEW5xv5ji24H-IVEDaYKLzmwAYSbKiLkKcJZnLV8jeLU2oz9bg1BGpscZ5_hme8a1vmXD0Um4pcFhNb7Qu106iJPWCEz_fEUpnB7YkDKCT8szi9Nz3RLZCVho3qigsX63sXU1k',
      large: false,
    ),
    _FriendMemoryItem(
      date: '2023年 6月 9日',
      typeLabel: '小确幸',
      typeIcon: Icons.auto_awesome,
      title: '雨天的咖啡馆',
      content: '窗外下雨，我们聊了很久很久。',
      place: '上海 · 徐汇',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB7bB4qRrW8u1lXcY7xv8u2pY1oP9uZ',
      large: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('共同回忆轴', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  SizedBox(height: 4),
                  Text('共 126 个美好瞬间', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
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
        _Timeline(items: _items),
      ],
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
    required this.imageUrl,
    required this.large,
  });

  final String date;
  final String typeLabel;
  final IconData typeIcon;
  final String title;
  final String content;
  final String place;
  final String imageUrl;
  final bool large;
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.items});

  final List<_FriendMemoryItem> items;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 24,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFFFB923C), const Color(0xFFFB923C).withValues(alpha: 0.18)],
              ),
            ),
          ),
        ),
        Column(
          children: [
            for (final item in items) ...[
              _TimelineEntry(item: item),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.item});

  final _FriendMemoryItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 10),
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: item.large ? const Color(0xFF2BCDEE) : const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFF8FAFC), width: 2),
            boxShadow: item.large ? [BoxShadow(color: const Color(0xFF2BCDEE).withValues(alpha: 0.20), blurRadius: 14, offset: const Offset(0, 6))] : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.date, style: TextStyle(fontSize: 12, fontWeight: item.large ? FontWeight.w900 : FontWeight.w700, color: item.large ? const Color(0xFF2BCDEE) : const Color(0xFF9CA3AF))),
              const SizedBox(height: 8),
              item.large ? _LargeMemoryCard(item: item) : _SmallMemoryCard(item: item),
            ],
          ),
        ),
      ],
    );
  }
}

class _LargeMemoryCard extends StatelessWidget {
  const _LargeMemoryCard({required this.item});

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
                      _buildLocalImage(item.imageUrl, fit: BoxFit.cover),
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

class _SmallMemoryCard extends StatelessWidget {
  const _SmallMemoryCard({required this.item});

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
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: _buildLocalImage(item.imageUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    const SizedBox(height: 6),
                    Text(item.content, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B), height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.more_horiz, color: Color(0xFFD1D5DB)),
            ],
          ),
        ),
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
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _addPlaceholderImage() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;
    setState(() => _imageUrls.addAll(files.map((f) => f.path)));
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
                    leading: _AvatarCircle(name: f.name),
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
    final note = noteParts.isEmpty ? null : noteParts.join('\n');

    await db.into(db.timelineEvents).insertOnConflictUpdate(
          TimelineEventsCompanion.insert(
            id: encounterId,
            title: title,
            eventType: 'encounter',
            startAt: Value(recordDate),
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
                          _AvatarCircle(name: f.name),
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
