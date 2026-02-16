import 'package:flutter/material.dart';

class GoalPage extends StatelessWidget {
  const GoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2BCDEE),
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GoalCreatePage())),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: const [
            _GoalHeader(),
            Expanded(child: _GoalHomeBody()),
          ],
        ),
      ),
    );
  }
}

class _GoalHeader extends StatelessWidget {
  const _GoalHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('目标', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
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
                          '搜索目标、标签..',
                          style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _CircleButton(icon: Icons.tune, onTap: () {}),
              const SizedBox(width: 12),
              _CircleButton(
                icon: Icons.add,
                iconColor: const Color(0xFF2BCDEE),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GoalCreatePage())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap, this.iconColor});

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
        child: SizedBox(width: 48, height: 48, child: Icon(icon, color: iconColor ?? const Color(0xFF6B7280), size: 22)),
      ),
    );
  }
}

class _GoalHomeBody extends StatelessWidget {
  const _GoalHomeBody();

  static const _items = <GoalItem>[
    GoalItem(title: '读完 24 本书', category: '成长', progress: 0.58, accent: Color(0xFF8B5CF6)),
    GoalItem(title: '跑步 300 公里', category: '健康', progress: 0.36, accent: Color(0xFF22C55E)),
    GoalItem(title: '去 3 个国家', category: '旅行', progress: 0.67, accent: Color(0xFF06B6D4)),
    GoalItem(title: '完成一门课程', category: '技能', progress: 0.22, accent: Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 140),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('人生目标看板', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                    SizedBox(height: 6),
                    Text('年度进度 · 专注当下', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFE2E8F0))),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.flag, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('进行中', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        const SizedBox(height: 12),
        for (final item in _items) ...[
          _GoalCard(item: item),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 6),
        const Text('已完成', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF22C55E)),
              SizedBox(width: 10),
              Expanded(child: Text('完成一次 10 公里跑', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
              Text('2025', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ],
    );
  }
}

class GoalItem {
  const GoalItem({required this.title, required this.category, required this.progress, required this.accent});

  final String title;
  final String category;
  final double progress;
  final Color accent;
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.item});

  final GoalItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GoalDetailPage(item: item))),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: item.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                    child: Text(item.category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: item.accent)),
                  ),
                  const Spacer(),
                  Text('${(item.progress * 100).round()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: item.accent)),
                ],
              ),
              const SizedBox(height: 10),
              Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: item.progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation(item.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoalDetailPage extends StatelessWidget {
  const GoalDetailPage({super.key, required this.item});

  final GoalItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        title: const Text('目标详情', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          _GoalCard(item: item),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
            child: const Text('目标详情页（待补齐原型的里程碑、关联、记录等元素）', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569), height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class GoalCreatePage extends StatelessWidget {
  const GoalCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.75),
        title: const Text('新建目标', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          TextButton(onPressed: () {}, child: const Text('保存', style: TextStyle(fontWeight: FontWeight.w900))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('标题', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                SizedBox(height: 10),
                TextField(decoration: InputDecoration(hintText: '例如：读完24本书', border: InputBorder.none)),
                SizedBox(height: 12),
                Text('分类', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                SizedBox(height: 10),
                TextField(decoration: InputDecoration(hintText: '成长/健康/旅行…', border: InputBorder.none)),
                SizedBox(height: 12),
                Text('截止时间', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                SizedBox(height: 10),
                TextField(decoration: InputDecoration(hintText: 'YYYY-MM-DD', border: InputBorder.none)),
                SizedBox(height: 12),
                Text('描述', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                SizedBox(height: 10),
                TextField(minLines: 4, maxLines: 10, decoration: InputDecoration(hintText: '写下你的目标规划…', border: InputBorder.none)),
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
