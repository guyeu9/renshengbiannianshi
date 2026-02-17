import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('万物互联', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                SizedBox(height: 10),
                Text('该详情页当前为样例数据，关联展示将在列表切换为数据库数据后接入。', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MomentCreatePage extends ConsumerStatefulWidget {
  const MomentCreatePage({super.key});

  @override
  ConsumerState<MomentCreatePage> createState() => _MomentCreatePageState();
}

class _MomentCreatePageState extends ConsumerState<MomentCreatePage> {
  static const _uuid = Uuid();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  DateTime _recordAt = DateTime.now();
  String _locationText = '';

  final List<String> _tags = ['读书', '搬家', '桌面布置', '电影'];
  int _selectedTagIndex = 0;

  final List<String> _imageUrls = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCxSxrPSNP5GyscJf8VbLyfGEMofwTDzF1suIZ8-kZwEH0DRvaUoSDgFeBeKagtjiOWcOnVaUDtkjJVIuTRKaWf7nsJrY-78Kfy786jvH5MO5t6UqIAuYbDpFIJ7PeRTkiBtloDw6uBasMwFXyt4gnaMkqhoS3zAyRxD4LVpNpRG5THPkjsUMnk-CDVjFKNsl43gKj137Cya9-i21Lr7QjjlMXEZUnTrWi39Nzf8UqaEPfWNwgzIcsj0XXuLx3AUITdlnOzAjgaWoL0',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCzi11fyH_6hYKpZThR-mYHS3Da_3eXh85e-gCF_lvAH4SvfVjEwYh8d9aR0miNPNYH3o8jde33xIqi8T8JZTryTI74D153SQ-NnVlzsByGKcsDJ4paCt34YtBbuSHysuHtnBf9FYccASj2-QsK3BnTxo-0vrBn7UYxwC64OUtZYsmidVwv8TTmBlpZAZlPAhsHziMezg7JvI5MI5RqQf-1xir3hjKC5Id6td075svWNDf8Ykyb9R0CInz15shx_oRD7Cvrrg8YDkS0',
  ];

  final Set<String> _linkedFriendIds = {};
  final Set<String> _linkedFoodIds = {};

  static const _moods = <_MoodOption>[
    _MoodOption(label: '开心', emoji: '😊', color: Color(0xFF2BCDEE)),
    _MoodOption(label: '平静', emoji: '😌', color: Color(0xFF22C55E)),
    _MoodOption(label: '治愈', emoji: '🌿', color: Color(0xFF60A5FA)),
    _MoodOption(label: '思考', emoji: '🤔', color: Color(0xFFA855F7)),
    _MoodOption(label: '放空', emoji: '☁️', color: Color(0xFF64748B)),
  ];
  int _selectedMoodIndex = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
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
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_recordAt));
    if (time == null) return;
    setState(() {
      _recordAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _editLocation() async {
    final controller = TextEditingController(text: _locationText);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: _BottomSheetShell(
            title: '地理位置',
            actionText: '确定',
            onAction: () => Navigator.of(context).pop(controller.text.trim()),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '添加位置信息',
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
    setState(() => _locationText = result);
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

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先填写标题')));
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final momentId = _uuid.v4();

    final content = _contentController.text.trim();
    final mergedContent = content.isEmpty ? title : '$title\n\n$content';

    final mood = _moods[_selectedMoodIndex];
    final tag = _tags.isEmpty ? null : _tags[_selectedTagIndex.clamp(0, _tags.length - 1)];
    final location = _locationText.trim();

    await db.momentDao.upsert(
      MomentRecordsCompanion.insert(
        id: momentId,
        content: Value(mergedContent.isEmpty ? null : mergedContent),
        images: Value(_imageUrls.isEmpty ? null : jsonEncode(_imageUrls)),
        mood: mood.label,
        moodColor: Value('#${mood.color.toARGB32().toRadixString(16).padLeft(8, '0')}'),
        sceneTag: Value(tag?.trim().isEmpty == true ? null : tag),
        city: Value(location.isEmpty ? null : location),
        latitude: const Value(null),
        longitude: const Value(null),
        recordDate: _recordAt,
        createdAt: now,
        updatedAt: now,
      ),
    );

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

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _addPlaceholderImage() {
    setState(() {
      _imageUrls.add(
        'https://lh3.googleusercontent.com/aida-public/AB6AXuA6r6i1N1DqXwB7cVdS0wWw5b5Y8m0k4s5x3e2n1k6',
      );
    });
  }

  void _removeImageAt(int index) {
    setState(() => _imageUrls.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final mood = _moods[_selectedMoodIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _CreateTopBar(
              title: '记录小确幸',
              onCancel: () => Navigator.of(context).maybePop(),
              actionText: '发布',
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
                    value: _locationText.trim().isEmpty ? '添加位置信息' : _locationText.trim(),
                    trailingIcon: Icons.chevron_right,
                    onTap: _editLocation,
                  ),
                  const SizedBox(height: 18),
                  Text('万物互联', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF6B7280).withValues(alpha: 0.9))),
                  const SizedBox(height: 10),
                  _UniversalLinkCard(
                    title: '关联人生目标',
                    subtitle: '让小确幸充满意义',
                    icon: Icons.flag,
                    gradientStart: const Color(0xFF2BCDEE),
                    gradientEnd: const Color(0xFF22D3EE),
                    trailingText: '待接入',
                    onTap: null,
                  ),
                  const SizedBox(height: 10),
                  _UniversalLinkCard(
                    title: '关联旅行',
                    subtitle: '记录旅途中的点滴',
                    icon: Icons.flight_takeoff,
                    gradientStart: const Color(0xFF34D399),
                    gradientEnd: const Color(0xFF14B8A6),
                    trailingText: '待接入',
                    onTap: null,
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
          Image.network(url, fit: BoxFit.cover),
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
    this.trailingText,
    this.trailingIcon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;
  final String? trailingText;
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
            if (trailingText != null)
              Text(trailingText!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF)))
            else
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
