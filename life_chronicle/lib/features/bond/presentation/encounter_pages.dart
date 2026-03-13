import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/providers/uuid_provider.dart';
import '../../../core/utils/image_save_util.dart';
import '../../../core/utils/media_storage.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/router/route_navigation.dart';
import '../providers/encounter_detail_provider.dart';
import 'bond_filter_components.dart';

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
          : ClipOval(child: AppImage(source: path, fit: BoxFit.cover)),
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
  const _PhotoTile({
    required this.url,
    required this.onRemove,
    this.images,
    this.initialIndex = 0,
  });

  final String url;
  final VoidCallback onRemove;
  final List<String>? images;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (images != null && images!.isNotEmpty) {
          ImagePreview.showGallery(context, images: images!, initialIndex: initialIndex);
        } else {
          ImagePreview.show(context, imageUrl: url);
        }
      },
      onLongPress: () {
        ImageSaveUtil.showImageOptions(
          context,
          url,
          isNetwork: false,
          onView: () {
            if (images != null && images!.isNotEmpty) {
              ImagePreview.showGallery(context, images: images!, initialIndex: initialIndex);
            } else {
              ImagePreview.show(context, imageUrl: url);
            }
          },
          onDelete: onRemove,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(source: url, fit: BoxFit.cover),
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
  const EncounterCreatePage({super.key, this.initialEvent});

  final TimelineEvent? initialEvent;

  @override
  ConsumerState<EncounterCreatePage> createState() => _EncounterCreatePageState();
}

class _EncounterCreatePageState extends ConsumerState<EncounterCreatePage> {
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
  final Set<String> _linkedTravelIds = {};
  final Set<String> _linkedGoalIds = {};

  bool get _isEditMode => widget.initialEvent != null;

  @override
  void initState() {
    super.initState();
    _initFromEvent();
  }

  Future<void> _initFromEvent() async {
    final event = widget.initialEvent;
    if (event == null) return;

    _titleController.text = event.title;
    _date = event.startAt ?? event.recordDate;
    _poiName = event.poiName ?? '';
    _poiAddress = event.poiAddress ?? '';
    _latitude = event.latitude;
    _longitude = event.longitude;

    final note = event.note ?? '';
    final lines = note.split('\n');
    for (final line in lines) {
      if (line.startsWith('心情分享：')) {
        _moodController.text = line.substring('心情分享：'.length);
      } else if (line.startsWith('图片：')) {
        try {
          final jsonStr = line.substring('图片：'.length);
          final decoded = jsonDecode(jsonStr);
          if (decoded is List) {
            _imageUrls.addAll(decoded.whereType<String>());
          }
        } catch (e) {
          debugPrint('解析图片JSON失败: $e');
        }
      }
    }

    // 加载关联数据
    final db = ref.read(appDatabaseProvider);
    final links = await db.linkDao.listLinksForEntity(entityType: 'encounter', entityId: event.id);
    setState(() {
      for (final link in links) {
        final isSource = link.sourceType == 'encounter' && link.sourceId == event.id;
        final otherType = isSource ? link.targetType : link.sourceType;
        final otherId = isSource ? link.targetId : link.sourceId;
        switch (otherType) {
          case 'friend':
            _linkedFriendIds.add(otherId);
          case 'food':
            _linkedFoodIds.add(otherId);
          case 'travel':
            _linkedTravelIds.add(otherId);
          case 'goal':
            _linkedGoalIds.add(otherId);
        }
      }
    });
  }

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

  Future<void> _selectTravels() async {
    final db = ref.read(appDatabaseProvider);
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StreamBuilder<List<TravelRecord>>(
          stream: db.watchAllActiveTravelRecords(),
          builder: (context, snapshot) {
            final items = (snapshot.data ?? const <TravelRecord>[])
                .map(
                  (t) {
                    final title = (t.title ?? '').trim();
                    final dest = (t.destination ?? '').trim();
                    return SelectItem(
                      id: t.id,
                      title: title.isNotEmpty ? title : dest,
                      leading: const _IconSquare(color: Color(0xFFE0F2FE), icon: Icons.airplanemode_active, iconColor: Color(0xFF0095FF)),
                    );
                  },
                )
                .toList(growable: false);
            return MultiSelectBottomSheet(title: '关联旅行', items: items, initialSelected: _linkedTravelIds);
          },
        );
      },
    );
    if (selected == null) return;
    setState(() {
      _linkedTravelIds
        ..clear()
        ..addAll(selected);
    });
  }

  Future<void> _selectGoals() async {
    final db = ref.read(appDatabaseProvider);
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StreamBuilder<List<TimelineEvent>>(
          stream: (db.select(db.timelineEvents)
                ..where((t) => t.isDeleted.equals(false))
                ..where((t) => t.eventType.equals('goal')))
              .watch(),
          builder: (context, snapshot) {
            final items = (snapshot.data ?? const <TimelineEvent>[])
                .map(
                  (g) => SelectItem(
                    id: g.id,
                    title: g.title,
                    leading: const _IconSquare(color: Color(0xFFF3E8FF), icon: Icons.outlined_flag, iconColor: Color(0xFFA855F7)),
                  ),
                )
                .toList(growable: false);
            return MultiSelectBottomSheet(title: '关联目标', items: items, initialSelected: _linkedGoalIds);
          },
        );
      },
    );
    if (selected == null) return;
    setState(() {
      _linkedGoalIds
        ..clear()
        ..addAll(selected);
    });
  }

  Future<void> _selectLocation() async {
    final result = await RouteNavigation.openMapPicker(
      context,
      initialPoiName: _poiName,
      initialAddress: _poiAddress,
      initialLatitude: _latitude,
      initialLongitude: _longitude,
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
    final encounterId = _isEditMode ? widget.initialEvent!.id : ref.read(uuidProvider).v4();
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

    if (_isEditMode) {
      await (db.update(db.timelineEvents)..where((t) => t.id.equals(encounterId))).write(
        TimelineEventsCompanion(
          title: Value(title),
          startAt: Value(_date),
          note: Value(note),
          poiName: Value(_poiName.trim().isEmpty ? null : _poiName.trim()),
          poiAddress: Value(_poiAddress.trim().isEmpty ? null : _poiAddress.trim()),
          latitude: Value(_latitude),
          longitude: Value(_longitude),
          recordDate: Value(recordDate),
          updatedAt: Value(now),
        ),
      );

      final existingLinks = await db.linkDao.listLinksForEntity(entityType: 'encounter', entityId: encounterId);
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
    } else {
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
    }

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
    for (final id in _linkedTravelIds) {
      await db.linkDao.createLink(
        sourceType: 'encounter',
        sourceId: encounterId,
        targetType: 'travel',
        targetId: id,
        now: now,
      );
    }
    for (final id in _linkedGoalIds) {
      await db.linkDao.createLink(
        sourceType: 'encounter',
        sourceId: encounterId,
        targetType: 'goal',
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
              title: _isEditMode ? '编辑相遇' : '记录相遇',
              onCancel: () => Navigator.of(context).maybePop(),
              actionText: _isEditMode ? '保存' : '发布',
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
                            return _PhotoTile(
                              url: _imageUrls[index],
                              onRemove: () => _removeImageAt(index),
                              images: _imageUrls,
                              initialIndex: index,
                            );
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
                          subtitle: _linkedTravelIds.isEmpty ? '是在旅途中相遇吗?' : '已选 ${_linkedTravelIds.length} 条',
                          iconBackground: const Color(0xFFE0F2FE),
                          icon: Icons.airplanemode_active,
                          iconColor: const Color(0xFF0095FF),
                          checked: _linkedTravelIds.isNotEmpty,
                          onTap: _selectTravels,
                        ),
                        const SizedBox(height: 10),
                        _LinkToggleRow(
                          title: '关联目标',
                          subtitle: _linkedGoalIds.isEmpty ? '是否达成了共同目标?' : '已选 ${_linkedGoalIds.length} 条',
                          iconBackground: const Color(0xFFF3E8FF),
                          icon: Icons.flag,
                          iconColor: const Color(0xFFA855F7),
                          checked: _linkedGoalIds.isNotEmpty,
                          onTap: _selectGoals,
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
class EncounterDetailPage extends ConsumerStatefulWidget {
  const EncounterDetailPage({super.key, required this.encounterId});

  final String encounterId;

  @override
  ConsumerState<EncounterDetailPage> createState() => _EncounterDetailPageState();
}

class _EncounterDetailPageState extends ConsumerState<EncounterDetailPage> {
  final _shareKey = GlobalKey();

  Future<void> _shareLongImage(BuildContext context) async {
    final boundary = _shareKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
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
      final file = File('${dir.path}/encounter_detail_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      debugPrint('分享导出失败: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('导出失败，请稍后重试')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(encounterDetailProvider(widget.encounterId));
    final db = ref.read(appDatabaseProvider);

    return detailAsync.when(
      data: (state) {
        if (state == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6F6F6),
            appBar: AppBar(
              backgroundColor: Colors.white.withValues(alpha: 0.85),
              leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
              title: const Text('相遇详情', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            body: const Center(
              child: Text('记录不存在或已删除', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
            ),
          );
        }

        final event = state.event;
        final title = event.title.trim().isEmpty ? '相遇详情' : event.title;
        final recordAt = event.startAt ?? event.recordDate;
        final dateText = '${recordAt.year}年${recordAt.month}月${recordAt.day}日';

        void openMapPreview() {
          final poiName = (event.poiName ?? '').trim();
          final poiAddress = (event.poiAddress ?? '').trim();
          if (poiName.isEmpty && poiAddress.isEmpty) return;
          RouteNavigation.openMapPreview(
            context,
            title: title,
            poiName: poiName,
            address: poiAddress,
            city: '',
            latitude: event.latitude,
            longitude: event.longitude,
          );
        }

        final noteData = _parseEncounterNote(event.note);

        return Scaffold(
          backgroundColor: const Color(0xFFF6F6F6),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white.withValues(alpha: 0.85),
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
                title: const Text('相遇详情', style: TextStyle(fontWeight: FontWeight.w900)),
                actions: [
                  IconButton(
                    onPressed: () {
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
                                  title: const Text('删除此条相遇', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                                  subtitle: const Text('删除后将不可恢复', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                                  onTap: () async {
                                    Navigator.of(sheetContext).pop();
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (dialogContext) {
                                        return AlertDialog(
                                          title: const Text('确认删除'),
                                          content: const Text('确定要删除这条相遇记录吗？'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('取消')),
                                            TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('删除')),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirmed != true) return;
                                    final now = DateTime.now();
                                    final linkDao = db.linkDao;
                                    final links = await linkDao.listLinksForEntity(entityType: 'encounter', entityId: event.id);
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
                                    await (db.update(db.timelineEvents)..where((t) => t.id.equals(event.id))).write(
                                      TimelineEventsCompanion(
                                        isDeleted: const Value(true),
                                        updatedAt: Value(now),
                                      ),
                                    );
                                    if (context.mounted) Navigator.of(context).pop();
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
                  key: _shareKey,
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
                                    child: const Icon(Icons.diversity_3, color: Color(0xFF2BCDEE)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(dateText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
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
                                        child: Text(event.poiName!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                                      ),
                                      const Icon(Icons.chevron_right, size: 16, color: Color(0xFF9CA3AF)),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              const Text('参与者', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                              const SizedBox(height: 10),
                              if (state.friendNames.isEmpty)
                                const Text('暂无参与者', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)))
                              else
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    for (final f in state.friends.where((f) => state.friendIds.contains(f.id)))
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _AvatarCircle(name: f.name, imagePath: f.avatarPath),
                                          const SizedBox(width: 8),
                                          Text(f.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                                        ],
                                      ),
                                  ],
                                ),
                              if (noteData.mood != null && noteData.mood!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAFBFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFF3F4F6)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(color: const Color(0xFFFCE7F3), borderRadius: BorderRadius.circular(999)),
                                            child: const Icon(Icons.favorite, size: 14, color: Color(0xFFEC4899)),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('心情分享', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(noteData.mood!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF374151), height: 1.5)),
                                    ],
                                  ),
                                ),
                              ],
                              if (noteData.images.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFF3F4F6)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(999)),
                                            child: const Icon(Icons.photo_library_outlined, size: 14, color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('打卡相册', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                          const Spacer(),
                                          Text('${noteData.images.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _ImageGrid(images: noteData.images),
                                    ],
                                  ),
                                ),
                              ],
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
                                    child: const Text('关联', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF2BCDEE))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _LinkBlock(icon: Icons.restaurant, title: '关联美食', chips: state.foodTitles),
                              const SizedBox(height: 10),
                              _LinkBlock(icon: Icons.airplanemode_active, title: '关联旅行', chips: state.travelTitles),
                              const SizedBox(height: 10),
                              _LinkBlock(icon: Icons.flag, title: '关联目标', chips: state.goalTitles),
                            ],
                          ),
                        ),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _BottomAction(
                          icon: Icons.edit,
                          label: '编辑',
                          onTap: () {
                            RouteNavigation.goToEncounterCreate(context, initialEvent: event);
                          },
                        ),
                        _BottomDivider(),
                        _BottomAction(
                          icon: event.isFavorite ? Icons.favorite : Icons.favorite_border,
                          label: '收藏',
                          active: event.isFavorite,
                          onTap: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await db.updateEncounterFavorite(event.id, isFavorite: !event.isFavorite, now: DateTime.now());
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(event.isFavorite ? '已取消收藏' : '已添加到收藏'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                        _BottomDivider(),
                        _BottomAction(
                          icon: Icons.share,
                          label: '分享',
                          onTap: () => _shareLongImage(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: const Center(child: Text('加载失败')),
      ),
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
    final color = active ? const Color(0xFFF43F5E) : const Color(0xFF6B7280);
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
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: onTap == null ? const Color(0xFFCBD5E1) : color,
              ),
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

class _BottomSheetShell extends StatelessWidget {
  const _BottomSheetShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _EncounterNoteData {
  _EncounterNoteData();
  String? location;
  String? mood;
  final List<String> images = [];
}

_EncounterNoteData _parseEncounterNote(String? note) {
  final result = _EncounterNoteData();
  if (note == null || note.trim().isEmpty) return result;
  final lines = note.split('\n');
  for (final line in lines) {
    if (line.startsWith('地点：')) {
      result.location = line.substring('地点：'.length).trim();
    } else if (line.startsWith('心情分享：')) {
      result.mood = line.substring('心情分享：'.length).trim();
    } else if (line.startsWith('图片：')) {
      try {
        final jsonStr = line.substring('图片：'.length);
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          result.images.addAll(decoded.whereType<String>());
        }
      } catch (e) {
        debugPrint('解析图片JSON失败: $e');
      }
    }
  }
  return result;
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return SmartImage(
        source: images[0],
        borderRadius: 12,
        images: images,
        initialIndex: 0,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => ImagePreview.showGallery(context, images: images, initialIndex: index),
          onLongPress: () => ImageSaveUtil.showImageOptions(
            context,
            images[index],
            isNetwork: false,
            onView: () => ImagePreview.showGallery(context, images: images, initialIndex: index),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppImage(source: images[index], fit: BoxFit.cover),
          ),
        );
      },
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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(999)),
                child: Icon(icon, size: 14, color: const Color(0xFF64748B)),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
            ],
          ),
          if (chips.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('暂无${title.replaceAll('关联', '')}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final chip in chips)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(chip, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
