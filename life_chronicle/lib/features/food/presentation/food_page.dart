import 'package:flutter/material.dart';

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2BCDEE),
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FoodCreatePage())),
        child: const Icon(Icons.add, size: 28),
      ),
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

class FoodCreatePage extends StatelessWidget {
  const FoodCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.75),
        title: const Text('新建美食记录', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('保存', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add_photo_alternate, color: Color(0xFF2BCDEE), size: 44),
                  SizedBox(height: 10),
                  Text('添加照片', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
                  SizedBox(height: 4),
                  Text('支持多张上传', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _FormCard(
            title: '餐厅信息',
            children: const [
              _FormRow(label: '店名', value: 'Oishii Sushi'),
              _FormRow(label: '地址', value: '上海市静安区南京西路'),
              _FormRow(label: '人均', value: '¥480'),
              _FormRow(label: '评分', value: '4.8'),
            ],
          ),
          const SizedBox(height: 14),
          _FormCard(
            title: '标签',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _TagChip(active: true, label: '日料'),
                  _TagChip(active: true, label: '海胆'),
                  _TagChip(active: false, label: '+ 添加'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _FormCard(
            title: '万物互联',
            children: const [
              _LinkRow(icon: Icons.people, title: '关联人物', subtitle: '张三、小明'),
              SizedBox(height: 10),
              _LinkRow(icon: Icons.auto_awesome, title: '关联小确幸', subtitle: '海胆很新鲜'),
              SizedBox(height: 10),
              _LinkRow(icon: Icons.airplanemode_active, title: '关联旅行', subtitle: '京都之旅'),
            ],
          ),
          const SizedBox(height: 14),
          _FormCard(
            title: '记录',
            children: const [
              Text(
                '写下你此刻的味觉记忆…',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF)),
              ),
              SizedBox(height: 12),
              TextField(
                minLines: 4,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: '比如：海胆很新鲜，醋饭温度刚刚好…',
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  const _FormRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)))),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.active, required this.label});

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0x1A2BCDEE) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? const Color(0x332BCDEE) : const Color(0xFFF3F4F6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: active ? const Color(0xFF2BCDEE) : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2BCDEE), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }
}
