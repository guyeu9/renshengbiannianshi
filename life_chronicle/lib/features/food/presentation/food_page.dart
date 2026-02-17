import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  var _modeIndex = 0;

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
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _modeIndex == 0 ? const _FoodRecordBody() : const _FoodWishlistBody(),
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
  });

  final int modeIndex;
  final ValueChanged<int> onModeChanged;

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
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Color(0xFF9CA3AF), size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '搜索店名、标签、地理位置...',
                          style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _HeaderCircle(icon: Icons.tune, onTap: () {}),
            ],
          ),
          const SizedBox(height: 12),
          _SegmentedPill(modeIndex: modeIndex, onChanged: onModeChanged),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                _FilterChip(label: '日期范围', icon: Icons.calendar_month),
                SizedBox(width: 10),
                _FilterChip(label: '评分', icon: Icons.star),
                SizedBox(width: 10),
                _FilterChip(label: '位置', icon: Icons.location_on),
                SizedBox(width: 10),
                _FilterChip(label: '同伴', icon: Icons.group),
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
                  onTap: () => onChanged(0),
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
                  onTap: () => onChanged(1),
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
  const _FilterChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        ],
      ),
    );
  }
}

class _FoodRecordBody extends StatelessWidget {
  const _FoodRecordBody();

  static const _items = <FoodCardData>[
    FoodCardData(
      title: 'Oishii Sushi',
      subtitle: '海胆寿司拼盘',
      location: '东京 · 银座, 0.5km',
      rating: 4.9,
      price: '¥800/人',
      tags: ['纪念日', '深夜食堂'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDRCDE3dEirG3NFTxj_GHz5mv150NMHVxHOPTnevwqUm63H4YkrlLYgKfVD6Bt5d5nly8aSYgeyLu5wNHbgGonM0Z6Zeta98qgwwbzQ3SFfv_UE9hXyod-8hcLTWJkM_olUmStUWYga92_b0UphcFiY7mijCPD4cvbD2n4HWuA7Br4r9c2RBVCD5xqUcT0sp0VJFY9mBdnx_wI36YPjtay4-bMZqy5kWC67_5y96m32ntOnz4ENIB0bFdfJsy_D-br_9XN2PDG-9Z9i',
      imageHeight: 230,
    ),
    FoodCardData(
      title: '沸腾火锅',
      subtitle: '番茄鸳鸯锅',
      location: '上海 · 徐汇, 1.2km',
      rating: 4.6,
      price: '¥120/人',
      tags: ['朋友聚会', '热辣'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCmqyAqYhW5t3t1jwU-wNFCtLqg2fJIQP2X8EczN-EPQArXyVjbd2m-1i4u3uYX8fD8FkbYvF3eiq_r8jZQ-EMkRj5Kdn_jzZ2L2DpD_7hQZ7tlm48l3n4oSx3hPBVtQXbXG7U9m4qYX9x3H9gUp2uLAVMzu5rG-2rY4g7tqRZrK9Eus8qXbGf7s2dcx0y5inYbCDmEgdJorv7ZXf0e4A8j3Xj8oOwhH2b2jYQ',
      imageHeight: 180,
    ),
    FoodCardData(
      title: '甜点研究所',
      subtitle: '草莓千层',
      location: '上海 · 黄浦, 0.9km',
      rating: 4.7,
      price: '¥68/人',
      tags: ['下午茶', '甜品'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD5TgDkvmm3E53ryouFQmxE7gXlNOh5xJfIU6I6Vn0pZHZxRnyb7OtYxPl9zY8yqWQqQH4gWluDgP6P0tdq8L1qVQNNBVKTEt7e9bV9jK3D7TLH0lR6n6Cw6oC7lZr9Heg',
      imageHeight: 210,
    ),
    FoodCardData(
      title: '家常小馆',
      subtitle: '红烧肉',
      location: '上海 · 长宁, 2.1km',
      rating: 4.5,
      price: '¥55/人',
      tags: ['家常', '下饭'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA3fZtqfFjIYzP1Yw2X8v8lQBWm0yU6l7w1lH3cKqvSmZb0lQ8oZ3oWc7sM0h-3uVKx9y2Y3tWQ7vJjEoQe4mYdV1Y8f2W6Y3zjE',
      imageHeight: 160,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final left = <FoodCardData>[];
    final right = <FoodCardData>[];
    for (var i = 0; i < _items.length; i++) {
      (i.isEven ? left : right).add(_items[i]);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text('味觉地图', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              ),
              Text('查看全部', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2BCDEE))),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF3F4F6)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB3hTQwT6Gv-7jXrUoWgLCHuO6k4CwWkT0m4g8o5m9Y4Y8tVwZ5zNqXHcSxJrE7i4bLQ2Wn7W2n9dWw2',
                    fit: BoxFit.cover,
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.10)),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 6))],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.place, color: Color(0xFF2BCDEE), size: 18),
                            SizedBox(width: 8),
                            Text('最近打卡：静安 · 徐汇 · 黄浦', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('今日推荐', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (final item in left) ...[
                      _FoodCard(item: item),
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
                      _FoodCard(item: item),
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

class _FoodWishlistBody extends StatelessWidget {
  const _FoodWishlistBody();

  static const _items = <FoodWishlistItem>[
    FoodWishlistItem(
      title: 'SORA Brunch',
      subtitle: '牛油果吐司与拿铁',
      location: '上海 · 静安, 0.7km',
      rating: 4.7,
      price: '¥98/人',
      tags: ['周末', '拍照', '早午餐'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA2S7m0HKz3e7v1AURfWbYp0jSxJr0X_m9x5p7k0M2xHf9Jx0R8d1xw6aV9V8r2x1yP5A',
    ),
    FoodWishlistItem(
      title: 'Blue Note',
      subtitle: '爵士夜与特调',
      location: '上海 · 黄浦, 1.6km',
      rating: 4.8,
      price: '¥168/人',
      tags: ['氛围', '音乐', '夜晚'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB8cS5m2s0W7mR8b8d0y8bL3aA0XvQ2x9oR2fQm',
    ),
    FoodWishlistItem(
      title: 'Noma Pop-up',
      subtitle: '创意料理体验',
      location: '东京 · 涩谷, 0.9km',
      rating: 4.9,
      price: '¥1200/人',
      tags: ['特别', '预约', '纪念'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB7kR1m8n0m2Qf6Y0y2v7r2',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 140),
      itemBuilder: (context, index) => _WishlistCard(item: _items[index]),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemCount: _items.length,
    );
  }
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({required this.item});

  final FoodWishlistItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FoodWishlistDetailPage(item: item))),
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
                  child: Image.network(item.imageUrl, fit: BoxFit.cover),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.bookmark_border),
                            color: const Color(0xFF2BCDEE),
                            iconSize: 22,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(item.subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Color(0xFFFB923C)),
                          const SizedBox(width: 4),
                          Text(item.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFFB923C))),
                          const SizedBox(width: 10),
                          const Icon(Icons.place, size: 14, color: Color(0xFF2BCDEE)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(item.location, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final t in item.tags.take(2))
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(999)),
                              child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
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
                      child: Image.network(item.imageUrl, fit: BoxFit.cover),
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

class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.item});

  final FoodCardData item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FoodDetailPage(item: item))),
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
                child: SizedBox(
                  height: item.imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(item.imageUrl, fit: BoxFit.cover),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 14, color: Color(0xFFFB923C)),
                              const SizedBox(width: 4),
                              Text(
                                item.rating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    const SizedBox(height: 4),
                    Text(item.subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final t in item.tags)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(999)),
                            child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 14, color: Color(0xFF2BCDEE)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(item.location, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                        ),
                        Text(item.price, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFFB923C))),
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

class FoodDetailPage extends StatelessWidget {
  const FoodDetailPage({super.key, required this.item});

  final FoodCardData item;

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
                      child: Image.network(item.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(item.subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 16, color: Color(0xFF2BCDEE)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.location,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0x1AFB923C), borderRadius: BorderRadius.circular(999)),
                        child: Text(
                          '评分 ${item.rating.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFFB923C)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('万物互联', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 10),
                  _LinkBlock(
                    icon: Icons.people,
                    title: '关联人物',
                    chips: const ['张三', '小明'],
                  ),
                  const SizedBox(height: 10),
                  _LinkBlock(
                    icon: Icons.auto_awesome,
                    title: '关联小确幸',
                    chips: const ['海胆很新鲜', '聊天很开心'],
                  ),
                  const SizedBox(height: 18),
                  const Text('记录', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: const Text(
                      '那天的海胆很新鲜，醋饭的温度刚刚好。我们聊到了明年的旅行计划。',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569), height: 1.5),
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
  const FoodCreatePage({super.key});

  @override
  ConsumerState<FoodCreatePage> createState() => _FoodCreatePageState();
}

class _FoodCreatePageState extends ConsumerState<FoodCreatePage> {
  static const _primary = Color(0xFF2BCDEE);
  static const _backgroundDark = Color(0xFF102222);

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _priceController = TextEditingController();
  final _linkController = TextEditingController();

  var _rating = 4;
  var _isWishlist = false;
  var _selectedMood = '开心';

  var _poiName = '三里屯太古里 (Sanlitun Taikoo Li)';
  var _poiAddress = '北京市朝阳区三里屯路19号';

  final _imageUrls = <String>[
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAot94lcCxv_cm5mGQBGYXWaKOLR1xcuPovBRmN4mYBOHgM37Y_vCdOG2RP7PRo1KNivOJqyobA5gWwHf5Ta0oaE_sxMYGe-ARTD6T3iNnEX_HZikKHuKZXVTnB4hUGka-aRMS9dKrXx4SEVHTJIMJE7eE28Kg0bZZTFe8aLwrKemUYmSet8WdVZZ0v6LZl0xr_A3iPV_CWpKaQzbRxBGwaG7WU1ry830-9feZfYSjzm3PXl_NYjVT9X92nA8d01mV9Hi19yL7FHud3',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDWXGzomX40HmgdCXHO1GaNPlPkdZFFx77X_VKg0Ge0KrSvDn3lTSxSyu2UgfdLME_4Bab5DSCKfnIv30daS79iRmdkpDn8b2avVZcNxMMDBGnSpUST_yXV8o8jkyV99XOmWCcB6z7RnFkE15jJ8L1XsiviEUWrkACEQG39_e883m6IAXMZvGQn-q93OK5oRtgNPk76YqXUpb7vnytWfTtx7khNwmShTsw2Ghsn-OBPHZJi85ZcckG5iHVVKqz9B2CEz6iPN-ZGFo8L',
  ];
  final _tags = <String>['必吃榜', '周末探店', '辣'];

  final _linkedFriends = <FriendRecord>[];

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
        title: const Text('新建美食记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
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
              child: const Text('发布'),
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
              Positioned.fill(child: Image.network(imageUrl, fit: BoxFit.cover)),
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
                for (final t in _tags)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(12)),
                      child: Text('# $t', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _backgroundDark)),
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
      onTap: () => _showEditLocationSheet(context),
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
                    _poiName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _poiAddress,
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
        const _SectionHeader(title: '万物关联'),
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
                  trailing: const Text('选择旅行记录', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('旅行模块待接入')));
                  },
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
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

  Future<void> _showAddImageSheet(BuildContext context) async {
    final controller = TextEditingController();
    final url = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetShell(
          title: '添加照片',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: '图片URL',
                  border: OutlineInputBorder(),
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
                  onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                  child: const Text('添加'),
                ),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();

    final next = (url ?? '').trim();
    if (next.isEmpty) return;
    setState(() => _imageUrls.add(next));
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
                          if (_tags.contains(v)) return;
                          setState(() => _tags.add(v));
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
                        for (final t in _tags)
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () {
                              setState(() => _tags.remove(t));
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

  Future<void> _showEditLocationSheet(BuildContext context) async {
    final nameController = TextEditingController(text: _poiName);
    final addressController = TextEditingController(text: _poiAddress);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetShell(
          title: '选择地点',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '地点名称', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: '地址', border: OutlineInputBorder()),
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        );
      },
    );
    setState(() {
      _poiName = nameController.text.trim().isEmpty ? _poiName : nameController.text.trim();
      _poiAddress = addressController.text.trim().isEmpty ? _poiAddress : addressController.text.trim();
    });
    nameController.dispose();
    addressController.dispose();
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
    final foodId = uuid.v4();
    final recordDate = DateTime(now.year, now.month, now.day);

    final content = _contentController.text.trim();
    final link = _linkController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    await db.foodDao.upsert(
      FoodRecordsCompanion.insert(
        id: foodId,
        title: title,
        content: Value(content.isEmpty ? null : content),
        images: Value(_imageUrls.isEmpty ? null : jsonEncode(_imageUrls)),
        tags: Value(_tags.isEmpty ? null : jsonEncode(_tags)),
        rating: Value(_rating <= 0 ? null : _rating.toDouble()),
        pricePerPerson: Value(price),
        link: Value(link.isEmpty ? null : link),
        poiName: Value(_poiName.trim().isEmpty ? null : _poiName.trim()),
        city: const Value(null),
        latitude: const Value(null),
        longitude: const Value(null),
        mood: Value(_selectedMood.trim().isEmpty ? null : _selectedMood.trim()),
        isWishlist: Value(_isWishlist),
        recordDate: recordDate,
        createdAt: now,
        updatedAt: now,
      ),
    );

    for (final f in _linkedFriends) {
      await db.linkDao.createLink(
        sourceType: 'food',
        sourceId: foodId,
        targetType: 'friend',
        targetId: f.id,
        now: now,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
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
              Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900))),
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
