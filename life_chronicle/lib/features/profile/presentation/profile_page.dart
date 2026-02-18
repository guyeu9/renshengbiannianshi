import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:drift/drift.dart' show OrderingMode, OrderingTerm;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _background = Color(0xFFF2F4F6);
  static const _primary = Color(0xFF8AB4F8);
  static const _accent = Color(0xFFE2F0FD);
  static const _softRed = Color(0xFFFFEBEE);
  static const _softBlue = Color(0xFFE3F2FD);
  static const _softPurple = Color(0xFFF3E5F5);
  static const _iconRed = Color(0xFFEF5350);
  static const _iconBlue = Color(0xFF42A5F5);
  static const _iconPurple = Color(0xFFAB47BC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FrostedCircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Row(
                    children: [
                      _FrostedCircleButton(icon: Icons.share, onTap: () {}),
                      const SizedBox(width: 12),
                      _FrostedCircleButton(icon: Icons.notifications, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 40 + MediaQuery.paddingOf(context).bottom),
                children: [
                  const _Header(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ChronicleCard(
                          onGenerate: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ChronicleGenerateConfigPage()),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _SectionTitle(title: '功能管理'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _LargeTile(
                                icon: Icons.collections_bookmark,
                                iconBg: _softPurple,
                                iconColor: _iconPurple,
                                title: '收藏中心',
                                subtitle: '美食 · 旅行 · 小确幸',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const FavoritesCenterPage()),
                                ),
                                trailingIcon: Icons.ios_share,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SmallTile(
                                icon: Icons.history_toggle_off,
                                iconBg: _accent,
                                iconColor: const Color(0xFF5D8CC0),
                                title: '编年史管理',
                                subtitle: '查看历史版本',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ChronicleManagePage()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SmallTile(
                                icon: Icons.analytics,
                                iconBg: _softRed,
                                iconColor: _iconRed,
                                title: '年度报告',
                                subtitle: '回顾过往精彩',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const YearReportPage()),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SmallTile(
                                icon: Icons.cloud_upload,
                                iconBg: _softBlue,
                                iconColor: _iconBlue,
                                title: '数据备份',
                                subtitle: '云端安全存储',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const DataManagementPage()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SmallTile(
                                icon: Icons.dashboard_customize,
                                iconBg: _accent,
                                iconColor: const Color(0xFF5D8CC0),
                                title: '模块管理',
                                subtitle: '个性化主页',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ModuleManagementPage()),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _ListGroup(
                          items: [
                            _ListItem(
                              icon: Icons.hub,
                              iconColor: const Color(0xFF4CAF50),
                              title: '万物互联',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const UniversalLinkPage()),
                              ),
                            ),
                            _ListItem(
                              icon: Icons.notifications_active,
                              iconColor: Colors.black,
                              title: '提醒设置',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ReminderSettingsPage()),
                              ),
                            ),
                            _ListItem(
                              icon: Icons.lock,
                              iconColor: Colors.black,
                              title: '隐私与安全',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const PrivacySecurityPage()),
                              ),
                            ),
                            _ListItem(
                              icon: Icons.help,
                              iconColor: Colors.black,
                              title: '帮助与反馈',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const HelpFeedbackPage()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            foregroundColor: const Color(0xFF9CA3AF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ).copyWith(
                            backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
                          ),
                          onPressed: () {},
                          child: const Text('退出登录', style: TextStyle(fontWeight: FontWeight.w600)),
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

class _Header extends StatefulWidget {
  const _Header();

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  static const _defaultAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBbKe_aCd46pUms7LLAFzD6OXtQ8lCfAXJOsCrBecRIq0Rsb6hG4jY_titPPL6OX4UEolhRaXIm5q1CN8mgX1sDnDEpjIu6VsAPEPXD_TgVO70SfpWy3Ip2I0CsCyMuTYopG68o1H3zfeCTGnhMwcli29GRkYeNRSh_bne4ffgw7Lym8TRcy9xvfIRJ7re4r_AZ6HYWFXuNljbmovvrN8K3yGjv8iiZ5MCKo2rG0vQcYlScRiJTep-ftfRgTq7kF_pycqvsKRxWyfNh';

  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  ImageProvider _avatarProvider() {
    final path = _avatarPath?.trim() ?? '';
    if (path.isEmpty) {
      return const NetworkImage(_defaultAvatarUrl);
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final storedPath = await _persistAvatar(file.path);
    if (storedPath == null) return;
    await _saveAvatarPath(storedPath);
    if (!mounted) return;
    setState(() => _avatarPath = storedPath);
  }

  Future<void> _loadAvatar() async {
    final stored = await _readAvatarPath();
    if (!mounted) return;
    setState(() => _avatarPath = stored);
  }

  Future<String?> _readAvatarPath() async {
    if (kIsWeb) return null;
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'profile', 'avatar.json'));
    if (!await file.exists()) return null;
    try {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map && decoded['path'] is String) {
        final path = (decoded['path'] as String).trim();
        if (path.isNotEmpty && await File(path).exists()) {
          return path;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveAvatarPath(String path) async {
    if (kIsWeb) return;
    final dir = await getApplicationDocumentsDirectory();
    final profileDir = Directory(p.join(dir.path, 'profile'));
    await profileDir.create(recursive: true);
    final file = File(p.join(profileDir.path, 'avatar.json'));
    await file.writeAsString(jsonEncode({'path': path}));
  }

  Future<String?> _persistAvatar(String path) async {
    if (path.trim().isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (kIsWeb) return path;
    final dir = await getApplicationDocumentsDirectory();
    final profileDir = Directory(p.join(dir.path, 'profile'));
    await profileDir.create(recursive: true);
    if (p.isWithin(profileDir.path, path)) {
      return path;
    }
    final ext = p.extension(path);
    final targetPath = p.join(
      profileDir.path,
      'avatar_${DateTime.now().millisecondsSinceEpoch}${ext.isEmpty ? '.jpg' : ext}',
    );
    final saved = await File(path).copy(targetPath);
    return saved.path;
  }

  void _openAvatarPreview() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Container(
            color: Colors.black,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Expanded(
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child: Center(
                        child: Image(
                          image: _avatarProvider(),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('关闭', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ProfilePage._primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              textStyle: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            onPressed: () async {
                              await _pickAvatar();
                              if (!dialogContext.mounted) return;
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text('更换头像'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8EAED), Color(0xFFF8F9FA)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: _openAvatarPreview,
                      child: ClipOval(
                        child: Image(
                          image: _avatarProvider(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: _pickAvatar,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.edit, size: 14, color: Color(0xFF2563EB)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Alex Chen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFDCFCE7)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history_edu, size: 16, color: Color(0xFF15803D)),
                SizedBox(width: 8),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 12, color: Color(0xFF166534), fontWeight: FontWeight.w800),
                    children: [
                      TextSpan(text: '已记录人生 '),
                      TextSpan(text: '1,240', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      TextSpan(text: ' 天'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '我频繁的记录着，我热烈的分享着',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1152D4)),
          ),
          const SizedBox(height: 6),
          const Text(
            '你要知道诗人的一生也可能非常普通',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1152D4)),
          ),
        ],
      ),
    );
  }
}

class _ChronicleCard extends StatelessWidget {
  const _ChronicleCard({required this.onGenerate});

  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)]),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, 8))],
        border: Border.all(color: const Color(0x331E40AF)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, _) {
                          final db = ref.watch(appDatabaseProvider);
                          return StreamBuilder<List<FoodRecord>>(
                            stream: db.foodDao.watchAllActive(),
                            builder: (context, foodSnapshot) {
                              final foodCount = foodSnapshot.data?.length ?? 0;
                              return StreamBuilder<List<TravelRecord>>(
                                stream: (db.select(db.travelRecords)
                                      ..where((t) => t.isDeleted.equals(false)))
                                    .watch(),
                                builder: (context, travelSnapshot) {
                                  final travelCount = travelSnapshot.data?.length ?? 0;
                                  return StreamBuilder<List<MomentRecord>>(
                                    stream: db.momentDao.watchAllActive(),
                                    builder: (context, momentSnapshot) {
                                      final momentCount = momentSnapshot.data?.length ?? 0;
                                      return StreamBuilder<List<TimelineEvent>>(
                                        stream: (db.select(db.timelineEvents)
                                              ..where((t) => t.isDeleted.equals(false))
                                              ..where((t) => t.eventType.isIn(['encounter', 'goal'])))
                                            .watch(),
                                        builder: (context, timelineSnapshot) {
                                          final events = timelineSnapshot.data ?? const <TimelineEvent>[];
                                          var encounterCount = 0;
                                          var goalCount = 0;
                                          for (final e in events) {
                                            if (e.eventType == 'encounter') {
                                              encounterCount += 1;
                                            } else if (e.eventType == 'goal') {
                                              goalCount += 1;
                                            }
                                          }
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Row(
                                                children: [
                                                  Icon(Icons.auto_stories, color: Color(0xFFFCD34D), size: 20),
                                                  SizedBox(width: 8),
                                                  Text('人生传记', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '$foodCount条美食、$travelCount次旅行、$momentCount个小确幸、$encounterCount次相遇、$goalCount个目标',
                                                style: const TextStyle(fontSize: 12, color: Color(0xFFDBEAFE), fontWeight: FontWeight.w600),
                                              ),
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
                        },
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      child: const Icon(Icons.workspace_premium, color: Color(0xFFFCD34D), size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    SizedBox(
                      height: 32,
                      child: Stack(
                        children: const [
                          _StackAvatar(
                            left: 0,
                            image:
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBH6ehj1x0eGgr0VT06HQYlUaq4fxkuUqmW_4FW1gikA4nxmI22lrL1sVhFIaaXEu4_sdXwyQzkzCt-Dnrf67biay7YI5oTrsxWpfXYiDoEZ8XgUQuJKSYkju8t7BU-1oC6Pe41HZgsfEJ-8oBiL-EoEHYjkIMGCg8b9eEaanMop_7hkQD5mnnsAE5St7AICaTl30tf6PViJCwsyVOz4DzZpvGdGZKHVVXJacED7BYrhu8umPQo5a8feO9c8Je6Tu0hBrX-Qa6IqdPz',
                          ),
                          _StackAvatar(
                            left: 20,
                            image:
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAxXDOLwhNbt-UVPJcW_LvKDBPIFu2hX7FsNBdXVv1wiYEXyaNi06egGSt711Y68tkgK5bmiHGEArNPbXPlUqI3hvoopLb4Q1Wp1u1HsKCs87W5BCKa4qIfvOl4VitjkOYUCI9PkDmdEWe2WxS5GcFcwiE9yOGssBuuM3V81VxKHBzmc0ClvZ1UQ0ljfW0DdCs5zGmFoBnUpVeqJFFTy_uZ0uzkCnheIB8Z_TdXj23jlr2fS_cAzwrHvlTJ9KFxYr5zTudW71WrxMRa',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 30),
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E40AF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
                      ),
                      child: const Text('+3', style: TextStyle(fontSize: 10, color: Color(0xFFDBEAFE), fontWeight: FontWeight.w800)),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onGenerate,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_fix_high, size: 16),
                          SizedBox(width: 6),
                          Text('生成编年史'),
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
    );
  }
}

class _StackAvatar extends StatelessWidget {
  const _StackAvatar({required this.left, required this.image});

  final double left;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: ProfilePage._primary, borderRadius: BorderRadius.circular(99))),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
      ],
    );
  }
}

class _LargeTile extends StatelessWidget {
  const _LargeTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(999)),
                child: Icon(trailingIcon, size: 18, color: const Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallTile extends StatelessWidget {
  const _SmallTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(999)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListGroup extends StatelessWidget {
  const _ListGroup({required this.items});

  final List<_ListItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6))),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _ListRow(item: items[i]),
            if (i != items.length - 1) const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider(height: 1, color: Color(0xFFF9FAFB))),
          ],
        ],
      ),
    );
  }
}

class _ListItem {
  const _ListItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
}

class _ListRow extends StatelessWidget {
  const _ListRow({required this.item});

  final _ListItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(item.icon, color: item.iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }
}

class _FrostedCircleButton extends StatelessWidget {
  const _FrostedCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.60),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF374151)),
      ),
    );
  }
}

class ChronicleGenerateConfigPage extends StatelessWidget {
  const ChronicleGenerateConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '编年史生成配置');
  }
}

class _FavoriteItem {
  const _FavoriteItem({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String category;
  final DateTime date;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final String imageUrl;
}

class FavoritesCenterPage extends ConsumerStatefulWidget {
  const FavoritesCenterPage({super.key});

  @override
  ConsumerState<FavoritesCenterPage> createState() => _FavoritesCenterPageState();
}

class _FavoritesCenterPageState extends ConsumerState<FavoritesCenterPage> {
  static const _categories = ['全部', '美食', '旅行', '小确幸', '羁绊'];
  static const _fallbackImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAKyf0mNiZ0TAc0cDBuDh729VN8zm8R-lF-JlOBczemlVSfDxlTXyG9D-4CqGvj4VGLsjyH_nyxHz36t5YCWIUdFilyoKvFftQ0lxzt6pmOkOgpBI_gvBZAInqTnxhG3lNNaOqRyxJCT-lzLS3lmLEkNBMXJ6LnIbYkBwU51lRvY0DqIG10oPqPfaoC12BgWZPmW74AWxyipq5A_nuiETA3saO846Avvh5KoAF7C0KINcR5Dmp2orHJWlVQTu97pn9w2S1O1IDzigGp';

  int _selectedCategoryIndex = 0;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  List<_FavoriteItem> _filterItems(List<_FavoriteItem> allItems) {
    final category = _categories[_selectedCategoryIndex];
    if (category == '全部') {
      return allItems;
    }
    return allItems.where((item) => item.category == category).toList(growable: false);
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSelectAll(List<_FavoriteItem> items) {
    setState(() {
      if (_selectedIds.length == items.length && items.isNotEmpty) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(items.map((item) => item.id));
      }
    });
  }

  List<String> _parseStringList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toList(growable: false);
      }
    } catch (_) {}
    return const [];
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }

  String _momentTitle(String? content) {
    final text = (content ?? '').trim();
    if (text.isEmpty) return '小确幸记录';
    if (text.length <= 12) return text;
    return '${text.substring(0, 12)}…';
  }

  List<_FavoriteItem> _buildItems({
    required List<FoodRecord> foods,
    required List<MomentRecord> moments,
    required List<TravelRecord> travels,
    required List<FriendRecord> friends,
  }) {
    final items = <_FavoriteItem>[];
    for (final record in foods) {
      if (!record.isFavorite) continue;
      final images = _parseStringList(record.images);
      final tags = _parseStringList(record.tags);
      items.add(
        _FavoriteItem(
          id: 'food-${record.id}',
          title: record.title,
          category: '美食',
          date: record.recordDate,
          tag: tags.isNotEmpty ? tags.first : '美食',
          tagColor: const Color(0xFFFFEDD5),
          tagTextColor: const Color(0xFFFB923C),
          imageUrl: images.isNotEmpty ? images.first : _fallbackImageUrl,
        ),
      );
    }
    for (final record in travels) {
      if (!record.isFavorite) continue;
      final images = _parseStringList(record.images);
      final title = (record.title ?? '').trim();
      final destination = (record.destination ?? '').trim();
      final mood = (record.mood ?? '').trim();
      items.add(
        _FavoriteItem(
          id: 'travel-${record.id}',
          title: title.isNotEmpty ? title : (destination.isNotEmpty ? destination : '旅行记录'),
          category: '旅行',
          date: record.recordDate,
          tag: mood.isNotEmpty ? mood : (destination.isNotEmpty ? destination : '旅行'),
          tagColor: const Color(0xFFDBEAFE),
          tagTextColor: const Color(0xFF3B82F6),
          imageUrl: images.isNotEmpty ? images.first : _fallbackImageUrl,
        ),
      );
    }
    for (final record in moments) {
      if (!record.isFavorite) continue;
      final images = _parseStringList(record.images);
      final mood = record.mood.trim();
      final scene = (record.sceneTag ?? '').trim();
      items.add(
        _FavoriteItem(
          id: 'moment-${record.id}',
          title: _momentTitle(record.content),
          category: '小确幸',
          date: record.recordDate,
          tag: mood.isNotEmpty ? mood : (scene.isNotEmpty ? scene : '小确幸'),
          tagColor: const Color(0xFFFCE7F3),
          tagTextColor: const Color(0xFFEC4899),
          imageUrl: images.isNotEmpty ? images.first : _fallbackImageUrl,
        ),
      );
    }
    for (final record in friends) {
      if (!record.isFavorite) continue;
      final group = (record.groupName ?? '').trim();
      items.add(
        _FavoriteItem(
          id: 'bond-${record.id}',
          title: record.name,
          category: '羁绊',
          date: record.updatedAt,
          tag: group.isNotEmpty ? group : '朋友',
          tagColor: const Color(0xFFEDE9FE),
          tagTextColor: const Color(0xFF7C3AED),
          imageUrl: (record.avatarPath ?? '').trim().isNotEmpty ? record.avatarPath!.trim() : _fallbackImageUrl,
        ),
      );
    }
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF2F4F6);
    const primary = Color(0xFF8AB4F8);
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder<List<FoodRecord>>(
        stream: db.foodDao.watchAllActive(),
        builder: (context, foodSnapshot) {
          final foods = foodSnapshot.data ?? const <FoodRecord>[];
          return StreamBuilder<List<TravelRecord>>(
            stream: db.watchAllActiveTravelRecords(),
            builder: (context, travelSnapshot) {
              final travels = travelSnapshot.data ?? const <TravelRecord>[];
              return StreamBuilder<List<MomentRecord>>(
                stream: db.momentDao.watchAllActive(),
                builder: (context, momentSnapshot) {
                  final moments = momentSnapshot.data ?? const <MomentRecord>[];
                  return StreamBuilder<List<FriendRecord>>(
                    stream: db.friendDao.watchAllActive(),
                    builder: (context, friendSnapshot) {
                      final friends = friendSnapshot.data ?? const <FriendRecord>[];
                      final allItems = _buildItems(
                        foods: foods,
                        moments: moments,
                        travels: travels,
                        friends: friends,
                      );
                      final items = _filterItems(allItems);
                      final foodCount = allItems.where((item) => item.category == '美食').length;
                      final travelCount = allItems.where((item) => item.category == '旅行').length;
                      final momentCount = allItems.where((item) => item.category == '小确幸').length;
                      final visibleIds = items.map((item) => item.id).toSet();
                      final selectedCount = _selectedIds.where(visibleIds.contains).length;
                      final allSelected = selectedCount == items.length && items.isNotEmpty;
                      return Scaffold(
                        backgroundColor: background,
                        appBar: AppBar(
                          backgroundColor: Colors.white.withValues(alpha: 0.7),
                          title: const Text('收藏中心', style: TextStyle(fontWeight: FontWeight.w800)),
                          actions: [
                            TextButton(
                              onPressed: _toggleSelectionMode,
                              style: TextButton.styleFrom(foregroundColor: primary, textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                              child: Text(_selectionMode ? '取消' : '选择'),
                            ),
                          ],
                        ),
                        bottomNavigationBar: _selectionMode
                            ? SafeArea(
                                top: false,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () => _toggleSelectAll(items),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 18,
                                                height: 18,
                                                decoration: BoxDecoration(
                                                  color: allSelected ? primary : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: const Color(0xFFCBD5F5)),
                                                ),
                                                child: allSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                allSelected ? '取消全选' : '全选',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: selectedCount == 0 ? null : () {},
                                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B), textStyle: const TextStyle(fontWeight: FontWeight.w800)),
                                        icon: const Icon(Icons.ios_share, size: 18),
                                        label: Text('批量导出${selectedCount == 0 ? '' : ' ($selectedCount)'}'),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: selectedCount == 0 ? null : () {},
                                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFF43F5E), textStyle: const TextStyle(fontWeight: FontWeight.w800)),
                                        icon: const Icon(Icons.delete, size: 18),
                                        label: const Text('删除'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : null,
                        body: SafeArea(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFFF3F4F6)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('收藏概览', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        _FavoriteSummaryChip(
                                          label: '美食',
                                          count: foodCount.toString(),
                                          color: const Color(0xFFFFEDD5),
                                          textColor: const Color(0xFFFB923C),
                                          onTap: () => setState(() {
                                            _selectedCategoryIndex = 1;
                                            _selectedIds.clear();
                                          }),
                                        ),
                                        const SizedBox(width: 10),
                                        _FavoriteSummaryChip(
                                          label: '旅行',
                                          count: travelCount.toString(),
                                          color: const Color(0xFFDBEAFE),
                                          textColor: const Color(0xFF3B82F6),
                                          onTap: () => setState(() {
                                            _selectedCategoryIndex = 2;
                                            _selectedIds.clear();
                                          }),
                                        ),
                                        const SizedBox(width: 10),
                                        _FavoriteSummaryChip(
                                          label: '小确幸',
                                          count: momentCount.toString(),
                                          color: const Color(0xFFFCE7F3),
                                          textColor: const Color(0xFFEC4899),
                                          onTap: () => setState(() {
                                            _selectedCategoryIndex = 3;
                                            _selectedIds.clear();
                                          }),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 36,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          final label = _categories[index];
                                          final selected = index == _selectedCategoryIndex;
                                          return _CategoryChip(
                                            label: label,
                                            selected: selected,
                                            onTap: () => setState(() {
                                              _selectedCategoryIndex = index;
                                              _selectedIds.clear();
                                            }),
                                          );
                                        },
                                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                                        itemCount: _categories.length,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Text('最近收藏', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _selectedCategoryIndex = 0;
                                      _selectedIds.clear();
                                    }),
                                    style: TextButton.styleFrom(foregroundColor: primary, textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                                    child: const Text('查看全部'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (items.isEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  alignment: Alignment.center,
                                  child: const Text('暂无收藏记录', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                                )
                              else
                                for (final item in items) ...[
                                  _FavoriteItemCard(
                                    title: item.title,
                                    subtitle: '${item.category} · ${_formatDate(item.date)}',
                                    tag: item.tag,
                                    tagColor: item.tagColor,
                                    tagTextColor: item.tagTextColor,
                                    imageUrl: item.imageUrl,
                                    selectable: _selectionMode,
                                    selected: _selectedIds.contains(item.id),
                                    onSelect: () {
                                      if (!_selectionMode) return;
                                      setState(() {
                                        if (_selectedIds.contains(item.id)) {
                                          _selectedIds.remove(item.id);
                                        } else {
                                          _selectedIds.add(item.id);
                                        }
                                      });
                                    },
                                    onTap: () {
                                      if (_selectionMode) {
                                        setState(() {
                                          if (_selectedIds.contains(item.id)) {
                                            _selectedIds.remove(item.id);
                                          } else {
                                            _selectedIds.add(item.id);
                                          }
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                ],
                            ],
                          ),
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
  }
}

class ChronicleManagePage extends StatelessWidget {
  const ChronicleManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF2F4F6);
    const primary = Color(0xFF8AB4F8);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        title: const Text('编年史管理', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(foregroundColor: primary, textStyle: const TextStyle(fontWeight: FontWeight.w900)),
            child: const Text('生成新版本'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('版本说明', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  SizedBox(height: 8),
                  Text('系统会保留每次生成的编年史版本，支持预览、导出与标记为精选。', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B), height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ChronicleVersionCard(
              title: '2024 年度编年史',
              range: '2024.01.01 - 2024.12.31',
              tags: const ['年度', '精选'],
              primaryAction: '预览',
              secondaryAction: '导出',
            ),
            const SizedBox(height: 12),
            _ChronicleVersionCard(
              title: '2024 上半年精选',
              range: '2024.01.01 - 2024.06.30',
              tags: const ['专题'],
              primaryAction: '预览',
              secondaryAction: '导出',
            ),
            const SizedBox(height: 12),
            _ChronicleVersionCard(
              title: '旅行主题合集',
              range: '2023.05.01 - 2024.03.31',
              tags: const ['旅行', '专题'],
              primaryAction: '预览',
              secondaryAction: '导出',
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteSummaryChip extends StatelessWidget {
  const _FavoriteSummaryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.textColor,
    this.onTap,
  });

  final String label;
  final String count;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textColor)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? const Color(0xFF8AB4F8) : const Color(0xFFF1F5F9);
    final textColor = selected ? Colors.white : const Color(0xFF64748B);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textColor)),
      ),
    );
  }
}

class _FavoriteItemCard extends StatelessWidget {
  const _FavoriteItemCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    required this.imageUrl,
    this.selectable = false,
    this.selected = false,
    this.onSelect,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final String imageUrl;
  final bool selectable;
  final bool selected;
  final VoidCallback? onSelect;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 72,
                height: 72,
                child: _buildLocalImage(imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(999)),
                    child: Text(tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: tagTextColor)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (selectable)
              InkWell(
                onTap: onSelect,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF8AB4F8) : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: selected ? const Color(0xFF8AB4F8) : const Color(0xFFCBD5E1)),
                  ),
                  child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
              )
            else
              const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}

class _ChronicleVersionCard extends StatelessWidget {
  const _ChronicleVersionCard({
    required this.title,
    required this.range,
    required this.tags,
    required this.primaryAction,
    required this.secondaryAction,
  });

  final String title;
  final String range;
  final List<String> tags;
  final String primaryAction;
  final String secondaryAction;

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
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              ),
              const Icon(Icons.auto_stories, size: 18, color: Color(0xFF8AB4F8)),
            ],
          ),
          const SizedBox(height: 6),
          Text(range, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final tag in tags)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(999)),
                  child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF3B82F6))),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8AB4F8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  onPressed: () {},
                  child: Text(primaryAction),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  onPressed: () {},
                  child: Text(secondaryAction),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UniversalLinkPage extends ConsumerWidget {
  const UniversalLinkPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    final logsQuery = (db.select(db.linkLogs)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
      ..limit(50));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        title: const Text('个人中心-万物互联', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UniversalLinkAllLogsPage())),
            child: const Text('全部日志'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('说明', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  SizedBox(height: 8),
                  Text('万物互联的底层是 entity_links + link_logs；这里展示最近的关联操作日志，便于校验各模块是否已正确写入关联。', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B), height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('最近日志', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UniversalLinkAllLogsPage())),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF2BCDEE), textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<LinkLog>>(
              stream: logsQuery.watch(),
              builder: (context, snapshot) {
                final items = snapshot.data ?? const <LinkLog>[];

                if (snapshot.connectionState == ConnectionState.waiting && items.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                }

                if (items.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
                    child: const Text('暂无日志：请在任意新建页发布一条记录并进行关联。', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                  );
                }

                return Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    itemBuilder: (context, index) {
                      final log = items[index];
                      return ListTile(
                        dense: true,
                        leading: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: log.action == 'delete' ? const Color(0xFFFFEBEE) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Icon(log.action == 'delete' ? Icons.link_off : Icons.link, size: 18, color: log.action == 'delete' ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)),
                        ),
                        title: Text(
                          '${_typeLabel(log.sourceType)} → ${_typeLabel(log.targetType)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                        ),
                        subtitle: Text(
                          '${log.action} · ${log.createdAt.toLocal().toString().substring(0, 19)}\n${log.sourceType}:${log.sourceId}  →  ${log.targetType}:${log.targetId}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B), height: 1.35),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UniversalLinkAllLogsPage extends ConsumerWidget {
  const UniversalLinkAllLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final logsQuery = (db.select(db.linkLogs)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
      ..limit(300));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        title: const Text('个人中心-万物互联-全部日志', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: StreamBuilder<List<LinkLog>>(
          stream: logsQuery.watch(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <LinkLog>[];
            if (snapshot.connectionState == ConnectionState.waiting && items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (items.isEmpty) {
              return const Center(
                child: Text('暂无日志', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final log = items[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: log.action == 'delete' ? const Color(0xFFFFEBEE) : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(log.action, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: log.action == 'delete' ? const Color(0xFFEF4444) : const Color(0xFF2563EB))),
                          ),
                          const SizedBox(width: 10),
                          Text(_typeLabel(log.sourceType), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1))),
                          Text(_typeLabel(log.targetType), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                          const Spacer(),
                          Text(log.createdAt.toLocal().toString().substring(0, 19), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('${log.sourceType}:${log.sourceId}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                      const SizedBox(height: 6),
                      Text('${log.targetType}:${log.targetId}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

String _typeLabel(String t) {
  switch (t) {
    case 'food':
      return '美食';
    case 'moment':
      return '小确幸';
    case 'friend':
      return '朋友';
    case 'encounter':
      return '相遇';
    case 'travel':
      return '旅行';
    case 'goal':
      return '目标';
    default:
      return t;
  }
}

class DataManagementPage extends StatelessWidget {
  const DataManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '个人中心-数据管理');
  }
}

class ModuleManagementPage extends StatelessWidget {
  const ModuleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '个人中心-模块管理');
  }
}

class YearReportPage extends StatelessWidget {
  const YearReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '年度报告');
  }
}

class ReminderSettingsPage extends StatelessWidget {
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '提醒设置');
  }
}

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '隐私与安全');
  }
}

class HelpFeedbackPage extends StatelessWidget {
  const HelpFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '帮助与反馈');
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: null,
      ),
      body: const SafeArea(
        child: Center(
          child: Text('界面已搭建（待填充原型细节）', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
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
