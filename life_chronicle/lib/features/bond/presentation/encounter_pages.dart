import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/utils/media_storage.dart';
import '../../../core/widgets/amap_location_page.dart';
import 'bond_filter_components.dart';

// 顶层辅助函数
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

String initialLetter(String name) {
  final trimmed = name.trim();
  return trimmed.isEmpty ? '?' : trimmed.characters.first;
}

// 辅助组件类
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
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
            Icon(checked ? Icons.check_circle : Icons.radio_button_unchecked, color: checked ? const Color(0xFF2BCDEE) : const Color(0xFFCBD5E1)),
          ],
        ),
      ),
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
                  const Text('选择相遇对象', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)))
                else
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final f in selected.take(6))
                          _AvatarCircle(name: f.name, imagePath: f.avatarPath),
                        if (selected.length > 6)
                          Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text('+${selected.length - 6}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        );
      },
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
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
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
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(child: Icon(Icons.add_photo_alternate, color: Color(0xFF94A3B8), size: 28)),
      ),
    );
  }
}

// 相遇创建页面
class EncounterCreatePage extends ConsumerStatefulWidget {
  const EncounterCreatePage({super.key});

  @override
  ConsumerState<EncounterCreatePage> createState() => _EncounterCreatePageState();
}

class _EncounterCreatePageState extends ConsumerState<EncounterCreatePage> {
  static const _uuid = Uuid();

  final _titleController = TextEditingController();
  final _moodController = TextEditingController();
  String _poiName = '';
  String _poiAddress = '';
  double? _latitude;
  double? _longitude;

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
                  (f) => SelectItem(
                    id: f.id,
                    title: f.name,
                    leading: _AvatarCircle(name: f.name, imagePath: f.avatarPath),
                  ),
                )
                .toList(growable: false);
            return MultiSelectBottomSheet(title: '选择相遇对象', items: items, initialSelected: _linkedFriendIds);
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
                  (f) => SelectItem(
                    id: f.id,
                    title: f.title,
                    leading: const _IconSquare(color: Color(0xFFFFEDD5), icon: Icons.restaurant, iconColor: Color(0xFFFB923C)),
                  ),
                )
                .toList(growable: false);
            return MultiSelectBottomSheet(title: '关联美食', items: items, initialSelected: _linkedFoodIds);
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

  Future<void> _selectLocation() async {
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
    if (result == null) return;
    if (!mounted) return;
    setState(() {
      _poiName = result.poiName;
      _poiAddress = result.address;
      _latitude = result.latitude;
      _longitude = result.longitude;
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

    final place = _poiName.trim().isNotEmpty
        ? _poiName.trim()
        : (_poiAddress.trim().isNotEmpty ? _poiAddress.trim() : '');
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
            poiName: Value(_poiName.trim().isEmpty ? null : _poiName.trim()),
            poiAddress: Value(_poiAddress.trim().isEmpty ? null : _poiAddress.trim()),
            latitude: Value(_latitude),
            longitude: Value(_longitude),
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
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _selectLocation,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _poiName.trim().isNotEmpty
                                        ? _poiName.trim()
                                        : (_poiAddress.trim().isNotEmpty ? _poiAddress.trim() : '在哪里相遇?'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: _poiName.trim().isNotEmpty || _poiAddress.trim().isNotEmpty ? const Color(0xFF111827) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                                if (_poiName.trim().isNotEmpty || _poiAddress.trim().isNotEmpty)
                                  IconButton(
                                    onPressed: () => setState(() {
                                      _poiName = '';
                                      _poiAddress = '';
                                      _latitude = null;
                                      _longitude = null;
                                    }),
                                    icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
                                  )
                                else
                                  const Icon(Icons.edit, size: 18, color: Color(0xFF94A3B8)),
                              ],
                            ),
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
                          icon: Icons.airplanemode_active,
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

// 相遇详情页面
class EncounterDetailPage extends ConsumerWidget {
  const EncounterDetailPage({super.key, required this.encounterId});

  final String encounterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    Stream<TimelineEvent?> watchEvent() {
      return (db.select(db.timelineEvents)
            ..where((t) => t.isDeleted.equals(false))
            ..where((t) => t.id.equals(encounterId))
            ..limit(1))
          .watchSingleOrNull();
    }

    return StreamBuilder<TimelineEvent?>(
      stream: watchEvent(),
      builder: (context, snapshot) {
        final event = snapshot.data;

        final title = (event?.title ?? '').trim().isEmpty ? '相遇详情' : event!.title;
        final recordAt = event?.startAt ?? event?.recordDate;
        final dateText = recordAt == null ? '' : '${recordAt.year}年${recordAt.month}月${recordAt.day}日';

        void openMapPreview() {
          if (event == null) return;
          final poiName = (event.poiName ?? '').trim();
          final poiAddress = (event.poiAddress ?? '').trim();
          if (poiName.isEmpty && poiAddress.isEmpty) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AmapLocationPage.preview(
                title: title,
                poiName: poiName,
                address: poiAddress,
                city: '',
                latitude: event.latitude,
                longitude: event.longitude,
              ),
            ),
          );
        }

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
                        child: event == null
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text('记录不存在或已删除', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(color: const Color(0x1A2BCDEE), borderRadius: BorderRadius.circular(12)),
                                        child: const Icon(Icons.diversity_3, color: Color(0xFF2BCDEE)),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          dateText.isEmpty ? '${event.recordDate.year}年${event.recordDate.month}月${event.recordDate.day}日' : dateText,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1.2)),
                                  if (event.poiName != null && event.poiName!.trim().isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: openMapPreview,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 16, color: Color(0xFF9CA3AF)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              event.poiName!,
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280)),
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF9CA3AF)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 14),
                                  const Text('参与者', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                  const SizedBox(height: 10),
                                  StreamBuilder<List<EntityLink>>(
                                    stream: db.linkDao.watchLinksForEntity(entityType: 'encounter', entityId: encounterId),
                                    builder: (context, linkSnapshot) {
                                      final friendIds = <String>{};
                                      for (final link in linkSnapshot.data ?? const <EntityLink>[]) {
                                        final isSource = link.sourceType == 'encounter' && link.sourceId == encounterId;
                                        final otherType = isSource ? link.targetType : link.sourceType;
                                        if (otherType == 'friend') {
                                          friendIds.add(isSource ? link.targetId : link.sourceId);
                                        }
                                      }
                                      if (friendIds.isEmpty) {
                                        return const Text('暂无参与者', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)));
                                      }
                                      return StreamBuilder<List<FriendRecord>>(
                                        stream: db.friendDao.watchAllActive(),
                                        builder: (context, friendSnapshot) {
                                          final friends = friendSnapshot.data ?? const <FriendRecord>[];
                                          final selected = friends.where((f) => friendIds.contains(f.id)).toList(growable: false);
                                          if (selected.isEmpty) {
                                            return const Text('暂无参与者', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)));
                                          }
                                          return Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            children: [
                                              for (final f in selected)
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    _AvatarCircle(name: f.name, imagePath: f.avatarPath),
                                                    const SizedBox(width: 8),
                                                    Text(f.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                                                  ],
                                                ),
                                            ],
                                          );
                                        },
                                      );
                                    },
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
        );
      },
    );
  }
}
