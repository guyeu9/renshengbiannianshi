import 'package:flutter/material.dart';

class MomentPage extends StatelessWidget {
  const MomentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _MomentHeader(),
            const Expanded(child: _MomentHomeBody()),
          ],
        ),
      ),
    );
  }
}

class _MomentHeader extends StatelessWidget {
  const _MomentHeader();

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
              _HeaderCircle(icon: Icons.tune, onTap: () {}),
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

class _MomentHomeBody extends StatelessWidget {
  const _MomentHomeBody();

  static const _items = <MomentCardData>[
    MomentCardData(
      moodName: '开心',
      moodColor: Color(0xFFFFF7ED),
      moodAccent: Color(0xFFF59E0B),
      title: '晨光里的草地',
      content: '今天的日出很温柔，风也刚刚好。',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC0XjMatVfzgqn6Mpbz0GjbXVFJh_BuXBjgoaaRdhaP07RNZUJ_3fEI65LH8A22EE3IjRHl4B_9XujGACKX6R6fc2qzukwUlytbLRXU_pwgkekBe8Xjn8mquxugtO9DmdXVVsc4zUeHRatJK0a_9kLbCP-q5xRHwtB0eYC9RDzu_faLxD55eacqGgC3KGi2dcJt3Yy6eZLS73eaWldZ4fSCosPvYzrPLV8OKvuQ5R53XzZ1ySIn5l-sgn5VV1CousmvXt7phBXtqbyg',
      imageHeight: 190,
    ),
    MomentCardData(
      moodName: '治愈',
      moodColor: Color(0xFFEFF6FF),
      moodAccent: Color(0xFF60A5FA),
      title: '咖啡香',
      content: '和自己相处的下午。',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA6r6i1N1DqXwB7cVdS0wWw5b5Y8m0k4s5x3e2n1k6',
      imageHeight: 230,
    ),
    MomentCardData(
      moodName: '感动',
      moodColor: Color(0xFFF5F3FF),
      moodAccent: Color(0xFFA855F7),
      title: '被理解的一刻',
      content: '一句话就足够。',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA2G8hEwJ2Zp1xKxT3m2p4Q3zG3D',
      imageHeight: 170,
    ),
    MomentCardData(
      moodName: '平静',
      moodColor: Color(0xFFECFDF5),
      moodAccent: Color(0xFF22C55E),
      title: '散步',
      content: '生活慢慢来。',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA3rV4K0w0lW6a4p8Z0w0',
      imageHeight: 210,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final left = <MomentCardData>[];
    final right = <MomentCardData>[];
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
                child: Text('今日心情', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              ),
              Text('年度心情', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2BCDEE))),
            ],
          ),
          const SizedBox(height: 12),
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
  }
}

class MomentCardData {
  const MomentCardData({
    required this.moodName,
    required this.moodColor,
    required this.moodAccent,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.imageHeight,
  });

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
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MomentDetailPage(item: item))),
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
                child: SizedBox(height: item.imageHeight, child: Image.network(item.imageUrl, fit: BoxFit.cover)),
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

class MomentDetailPage extends StatelessWidget {
  const MomentDetailPage({super.key, required this.item});

  final MomentCardData item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        title: const Text('小确幸详情', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(aspectRatio: 4 / 3, child: Image.network(item.imageUrl, fit: BoxFit.cover)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: item.moodColor, borderRadius: BorderRadius.circular(999)),
                child: Text(item.moodName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: item.moodAccent)),
              ),
              const Spacer(),
              const Icon(Icons.favorite, color: Color(0xFFF43F5E)),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
            child: Text(item.content, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569), height: 1.5)),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
            child: const Text('万物互联（待接入）', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
          ),
        ],
      ),
    );
  }
}

class MomentCreatePage extends StatelessWidget {
  const MomentCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.75),
        title: const Text('新建小确幸', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          TextButton(onPressed: () {}, child: const Text('保存', style: TextStyle(fontWeight: FontWeight.w900))),
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('心情', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MoodSelectChip(active: true, label: '开心', color: Color(0xFFF59E0B)),
                    _MoodSelectChip(active: false, label: '平静', color: Color(0xFF22C55E)),
                    _MoodSelectChip(active: false, label: '感动', color: Color(0xFFA855F7)),
                    _MoodSelectChip(active: false, label: '治愈', color: Color(0xFF60A5FA)),
                    _MoodSelectChip(active: false, label: '+ 添加', color: Color(0xFF9CA3AF)),
                  ],
                ),
                SizedBox(height: 14),
                Text('记录', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                SizedBox(height: 10),
                TextField(
                  minLines: 4,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: '写下此刻的小确幸…',
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
            child: const Text('万物互联（待接入）', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
          ),
        ],
      ),
    );
  }
}

class _MoodSelectChip extends StatelessWidget {
  const _MoodSelectChip({required this.active, required this.label, required this.color});

  final bool active;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.12) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? color.withValues(alpha: 0.25) : const Color(0xFFF3F4F6)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: active ? color : const Color(0xFF6B7280)),
      ),
    );
  }
}
