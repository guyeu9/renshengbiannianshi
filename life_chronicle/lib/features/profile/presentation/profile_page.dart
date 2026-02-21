import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:drift/drift.dart' hide Column;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/utils/media_storage.dart';

const Map<String, IconData> moduleIconRegistry = {
  'restaurant': Icons.restaurant,
  'flight_takeoff': Icons.flight_takeoff,
  'auto_awesome': Icons.auto_awesome,
  'diversity_3': Icons.diversity_3,
  'flag': Icons.flag,
  'star': Icons.star,
  'card_giftcard': Icons.card_giftcard,
  'sunny': Icons.sunny,
  'local_florist': Icons.local_florist,
  'coffee': Icons.coffee,
  'beach_access': Icons.beach_access,
  'pets': Icons.pets,
  'music_note': Icons.music_note,
  'nightlife': Icons.nightlife,
  'sports_soccer': Icons.sports_soccer,
  'movie': Icons.movie,
  'cake': Icons.cake,
  'celebration': Icons.celebration,
  'favorite': Icons.favorite,
  'self_improvement': Icons.self_improvement,
  'camera_alt': Icons.camera_alt,
  'directions_walk': Icons.directions_walk,
};

IconData iconFromName(String name) {
  return moduleIconRegistry[name] ?? Icons.star;
}

class ModuleTag {
  const ModuleTag({
    required this.id,
    required this.name,
    this.iconName,
    this.showOnCalendar = true,
  });

  final String id;
  final String name;
  final String? iconName;
  final bool showOnCalendar;

  ModuleTag copyWith({
    String? id,
    String? name,
    String? iconName,
    bool? showOnCalendar,
  }) {
    return ModuleTag(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      showOnCalendar: showOnCalendar ?? this.showOnCalendar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'showOnCalendar': showOnCalendar,
    };
  }

  factory ModuleTag.fromJson(Map<String, dynamic> json) {
    return ModuleTag(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      iconName: (json['iconName'] ?? '').toString().isEmpty ? null : json['iconName'].toString(),
      showOnCalendar: json['showOnCalendar'] == null ? true : json['showOnCalendar'] == true,
    );
  }
}

class ModuleConfig {
  const ModuleConfig({
    required this.key,
    required this.title,
    required this.iconName,
    required this.tagTitle,
    required this.showOnCalendar,
    required this.tags,
  });

  final String key;
  final String title;
  final String iconName;
  final String tagTitle;
  final bool showOnCalendar;
  final List<ModuleTag> tags;

  ModuleConfig copyWith({
    String? title,
    String? iconName,
    String? tagTitle,
    bool? showOnCalendar,
    List<ModuleTag>? tags,
  }) {
    return ModuleConfig(
      key: key,
      title: title ?? this.title,
      iconName: iconName ?? this.iconName,
      tagTitle: tagTitle ?? this.tagTitle,
      showOnCalendar: showOnCalendar ?? this.showOnCalendar,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'iconName': iconName,
      'tagTitle': tagTitle,
      'showOnCalendar': showOnCalendar,
      'tags': tags.map((t) => t.toJson()).toList(growable: false),
    };
  }

  factory ModuleConfig.fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];
    final tags = <ModuleTag>[];
    if (tagsRaw is List) {
      for (final item in tagsRaw) {
        if (item is Map<String, dynamic>) {
          tags.add(ModuleTag.fromJson(item));
        } else if (item is Map) {
          tags.add(ModuleTag.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return ModuleConfig(
      key: (json['key'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      iconName: (json['iconName'] ?? '').toString(),
      tagTitle: (json['tagTitle'] ?? '').toString(),
      showOnCalendar: json['showOnCalendar'] == null ? true : json['showOnCalendar'] == true,
      tags: tags,
    );
  }
}

class ModuleManagementConfig {
  const ModuleManagementConfig({required this.modules});

  final Map<String, ModuleConfig> modules;

  ModuleConfig moduleOf(String key) {
    return modules[key] ?? ModuleManagementConfig.defaults().modules[key]!;
  }

  Map<String, dynamic> toJson() {
    return {
      'modules': {
        for (final entry in modules.entries) entry.key: entry.value.toJson(),
      },
    };
  }

  factory ModuleManagementConfig.fromJson(Map<String, dynamic> json) {
    final modulesRaw = json['modules'];
    final modules = <String, ModuleConfig>{};
    if (modulesRaw is Map) {
      for (final entry in modulesRaw.entries) {
        if (entry.value is Map<String, dynamic>) {
          modules[entry.key.toString()] = ModuleConfig.fromJson(entry.value as Map<String, dynamic>);
        } else if (entry.value is Map) {
          modules[entry.key.toString()] = ModuleConfig.fromJson(Map<String, dynamic>.from(entry.value as Map));
        }
      }
    }
    final defaults = ModuleManagementConfig.defaults();
    for (final entry in defaults.modules.entries) {
      modules.putIfAbsent(entry.key, () => entry.value);
    }
    return ModuleManagementConfig(modules: modules);
  }

  static ModuleManagementConfig defaults() {
    return ModuleManagementConfig(
      modules: {
        'food': ModuleConfig(
          key: 'food',
          title: '美食',
          iconName: 'restaurant',
          tagTitle: '菜系标签管理',
          showOnCalendar: true,
          tags: const [
            ModuleTag(id: 'food-1', name: '火锅'),
            ModuleTag(id: 'food-2', name: '日料'),
            ModuleTag(id: 'food-3', name: '川菜'),
            ModuleTag(id: 'food-4', name: '西餐'),
          ],
        ),
        'travel': ModuleConfig(
          key: 'travel',
          title: '旅行',
          iconName: 'flight_takeoff',
          tagTitle: '目的地标签管理',
          showOnCalendar: true,
          tags: const [
            ModuleTag(id: 'travel-1', name: '国内游'),
            ModuleTag(id: 'travel-2', name: '露营'),
            ModuleTag(id: 'travel-3', name: '海岛'),
            ModuleTag(id: 'travel-4', name: '城市漫游'),
          ],
        ),
        'moment': ModuleConfig(
          key: 'moment',
          title: '小确幸',
          iconName: 'auto_awesome',
          tagTitle: '个性化标签管理 (支持自定义图标)',
          showOnCalendar: true,
          tags: const [
            ModuleTag(id: 'moment-1', name: '礼物', iconName: 'card_giftcard', showOnCalendar: true),
            ModuleTag(id: 'moment-2', name: '夕阳', iconName: 'sunny', showOnCalendar: false),
            ModuleTag(id: 'moment-3', name: '散步', iconName: 'directions_walk', showOnCalendar: true),
            ModuleTag(id: 'moment-4', name: '花束', iconName: 'local_florist', showOnCalendar: true),
          ],
        ),
        'bond': ModuleConfig(
          key: 'bond',
          title: '羁绊',
          iconName: 'diversity_3',
          tagTitle: '印象标签管理',
          showOnCalendar: true,
          tags: const [
            ModuleTag(id: 'bond-1', name: '死党'),
            ModuleTag(id: 'bond-2', name: '家人'),
            ModuleTag(id: 'bond-3', name: '同事'),
          ],
        ),
        'goal': ModuleConfig(
          key: 'goal',
          title: '目标',
          iconName: 'flag',
          tagTitle: '目标分类管理',
          showOnCalendar: true,
          tags: const [
            ModuleTag(id: 'goal-1', name: '年度目标'),
            ModuleTag(id: 'goal-2', name: '习惯养成'),
            ModuleTag(id: 'goal-3', name: '职业发展'),
          ],
        ),
      },
    );
  }
}

Future<File?> moduleManagementConfigFile() async {
  if (kIsWeb) return null;
  final dir = await getApplicationDocumentsDirectory();
  final profileDir = Directory(p.join(dir.path, 'profile'));
  await profileDir.create(recursive: true);
  return File(p.join(profileDir.path, 'module_management.json'));
}

Future<ModuleManagementConfig> loadModuleManagementConfig() async {
  if (kIsWeb) return ModuleManagementConfig.defaults();
  final file = await moduleManagementConfigFile();
  if (file == null) return ModuleManagementConfig.defaults();
  if (!await file.exists()) {
    final defaults = ModuleManagementConfig.defaults();
    await file.writeAsString(jsonEncode(defaults.toJson()));
    return defaults;
  }
  try {
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      return ModuleManagementConfig.fromJson(Map<String, dynamic>.from(decoded));
    }
  } catch (_) {}
  final fallback = ModuleManagementConfig.defaults();
  await file.writeAsString(jsonEncode(fallback.toJson()));
  return fallback;
}

Future<void> saveModuleManagementConfig(ModuleManagementConfig config) async {
  if (kIsWeb) return;
  final file = await moduleManagementConfigFile();
  if (file == null) return;
  await file.writeAsString(jsonEncode(config.toJson()));
}

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
                              icon: Icons.person,
                              iconColor: Colors.black,
                              title: '个人资料',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const PersonalProfilePage()),
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
    return persistImagePath(path, folder: 'profile', prefix: 'avatar');
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
          Consumer(
            builder: (context, ref, _) {
              final nameAsync = ref.watch(userDisplayNameProvider);
              return nameAsync.when(
                data: (name) => Text(
                  name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
                  overflow: TextOverflow.ellipsis,
                ),
                loading: () => const Text(
                  '林晓梦',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
                ),
                error: (_, __) => const Text(
                  '林晓梦',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
                ),
              );
            },
          ),
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
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          onTap();
        },
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
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          onTap();
        },
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
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        item.onTap();
      },
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
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onTap();
      },
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
  static const _categories = ['全部', '美食', '旅行', '小确幸', '羁绊', '相遇'];
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
                      final encounterCount = allItems.where((item) => item.category == '相遇').length;
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
                                        const SizedBox(width: 10),
                                        _FavoriteSummaryChip(
                                          label: '相遇',
                                          count: encounterCount.toString(),
                                          color: const Color(0xFFE0F2FE),
                                          textColor: const Color(0xFF0284C7),
                                          onTap: () => setState(() {
                                            _selectedCategoryIndex = 5;
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
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          onTap?.call();
        },
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
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onTap();
      },
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
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onTap?.call();
      },
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
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onSelect?.call();
                },
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
    return const _UniversalLinkHomePage();
  }
}

class _UniversalLinkHomePage extends ConsumerStatefulWidget {
  const _UniversalLinkHomePage();

  @override
  ConsumerState<_UniversalLinkHomePage> createState() => _UniversalLinkHomePageState();
}

class _UniversalLinkHomePageState extends ConsumerState<_UniversalLinkHomePage> {
  final _searchController = TextEditingController();
  String _selectedType = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final linkCountExp = db.entityLinks.id.count();
    final logCountExp = db.linkLogs.id.count();

    final linkCountQuery = db.selectOnly(db.entityLinks)..addColumns([linkCountExp]);
    final logCountQuery = db.selectOnly(db.linkLogs)..addColumns([logCountExp]);

    final recentLinksQuery = (db.select(db.entityLinks)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
      ..limit(20));

    final recentLogsQuery = (db.select(db.linkLogs)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
      ..limit(50));

    final goalsStream = (db.select(db.timelineEvents)
          ..where((t) => t.eventType.equals('goal'))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();

    final encountersStream = db.watchEncounterEvents();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                border: const Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('万物互联', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                            SizedBox(height: 2),
                            Text('管理人生碎片的深度羁绊', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UniversalLinkAllLogsPage())),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF2BCDEE), textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                        child: const Text('全部日志'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))]),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: '搜索记忆关键词（如：成都、火锅...）',
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF2BCDEE)),
                        suffixIcon: _searchController.text.trim().isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close, size: 18, color: Color(0xFF9CA3AF)),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StreamBuilder<TypedResult>(
                          stream: linkCountQuery.watchSingle(),
                          builder: (context, snapshot) {
                            final count = snapshot.data?.read(linkCountExp) ?? 0;
                            return _UniversalStatCard(title: '当前已建立关联', value: '$count', unit: '处');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StreamBuilder<TypedResult>(
                          stream: logCountQuery.watchSingle(),
                          builder: (context, snapshot) {
                            final count = snapshot.data?.read(logCountExp) ?? 0;
                            return _UniversalStatCard(title: '全部日志', value: '$count', unit: '条');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _UniversalFilterChip(
                          label: '全部关联',
                          selected: _selectedType == 'all',
                          onTap: () => setState(() => _selectedType = 'all'),
                        ),
                        _UniversalFilterChip(
                          label: '羁绊',
                          selected: _selectedType == 'friend',
                          onTap: () => setState(() => _selectedType = 'friend'),
                        ),
                        _UniversalFilterChip(
                          label: '美食',
                          selected: _selectedType == 'food',
                          onTap: () => setState(() => _selectedType = 'food'),
                        ),
                        _UniversalFilterChip(
                          label: '旅行',
                          selected: _selectedType == 'travel',
                          onTap: () => setState(() => _selectedType = 'travel'),
                        ),
                        _UniversalFilterChip(
                          label: '小确幸',
                          selected: _selectedType == 'moment',
                          onTap: () => setState(() => _selectedType = 'moment'),
                        ),
                        _UniversalFilterChip(
                          label: '目标',
                          selected: _selectedType == 'goal',
                          onTap: () => setState(() => _selectedType = 'goal'),
                        ),
                        _UniversalFilterChip(
                          label: '相遇',
                          selected: _selectedType == 'encounter',
                          onTap: () => setState(() => _selectedType = 'encounter'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text('最近关联', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UniversalLinkAllLogsPage())),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF2BCDEE), textStyle: const TextStyle(fontWeight: FontWeight.w900)),
                        child: const Text('查看全部'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<List<EntityLink>>(
                    stream: recentLinksQuery.watch(),
                    builder: (context, snapshot) {
                      final links = snapshot.data ?? const <EntityLink>[];
                      return StreamBuilder<List<FriendRecord>>(
                        stream: db.friendDao.watchAllActive(),
                        builder: (context, friendSnapshot) {
                          final friends = friendSnapshot.data ?? const <FriendRecord>[];
                          return StreamBuilder<List<FoodRecord>>(
                            stream: db.foodDao.watchAllActive(),
                            builder: (context, foodSnapshot) {
                              final foods = foodSnapshot.data ?? const <FoodRecord>[];
                              return StreamBuilder<List<MomentRecord>>(
                                stream: db.momentDao.watchAllActive(),
                                builder: (context, momentSnapshot) {
                                  final moments = momentSnapshot.data ?? const <MomentRecord>[];
                                  return StreamBuilder<List<TravelRecord>>(
                                    stream: db.watchAllActiveTravelRecords(),
                                    builder: (context, travelSnapshot) {
                                      final travels = travelSnapshot.data ?? const <TravelRecord>[];
                                      return StreamBuilder<List<TimelineEvent>>(
                                        stream: goalsStream,
                                        builder: (context, goalSnapshot) {
                                          final goals = goalSnapshot.data ?? const <TimelineEvent>[];
                                          return StreamBuilder<List<TimelineEvent>>(
                                            stream: encountersStream,
                                            builder: (context, encounterSnapshot) {
                                              final encounters = encounterSnapshot.data ?? const <TimelineEvent>[];
                                              final maps = _UniversalEntityMaps(
                                                foods: {for (final f in foods) f.id: (f.title).trim().isEmpty ? '美食记录' : f.title.trim()},
                                                moments: {for (final m in moments) m.id: _momentTitleFromContent(m.content)},
                                                friends: {for (final f in friends) f.id: (f.name).trim().isEmpty ? '朋友' : f.name.trim()},
                                                travels: {
                                                  for (final t in travels)
                                                    t.id: ((t.title ?? '').trim().isNotEmpty ? t.title!.trim() : ((t.destination ?? '').trim().isNotEmpty ? t.destination!.trim() : '旅行记录'))
                                                },
                                                goals: {for (final g in goals) g.id: g.title},
                                                encounters: {for (final e in encounters) e.id: e.title},
                                              );
                                              final query = _searchController.text.trim();
                                              final filtered = links.where((link) {
                                                if (_selectedType != 'all' && link.sourceType != _selectedType && link.targetType != _selectedType) return false;
                                                if (query.isEmpty) return true;
                                                final left = '${_typeLabel(link.sourceType)} ${maps.titleOf(link.sourceType, link.sourceId)}';
                                                final right = '${_typeLabel(link.targetType)} ${maps.titleOf(link.targetType, link.targetId)}';
                                                return left.contains(query) || right.contains(query);
                                              }).toList(growable: false);

                                              if (filtered.isEmpty) {
                                                return Container(
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
                                                  child: Text(
                                                    query.isEmpty ? '暂无关联：请在任意新建页选择关联项并保存。' : '未找到匹配的关联项',
                                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                                                  ),
                                                );
                                              }

                                              return Column(
                                                children: [
                                                  for (final link in filtered) ...[
                                                    _UniversalLinkCard(
                                                      leftTitle: maps.titleOf(link.sourceType, link.sourceId),
                                                      leftType: _typeLabel(link.sourceType),
                                                      rightTitle: maps.titleOf(link.targetType, link.targetId),
                                                      rightType: _typeLabel(link.targetType),
                                                      linkLabel: _linkTypeLabel(link.linkType),
                                                      createdAt: link.createdAt,
                                                    ),
                                                    const SizedBox(height: 10),
                                                  ],
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
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const Text('最近日志', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 8),
                  StreamBuilder<List<LinkLog>>(
                    stream: recentLogsQuery.watch(),
                    builder: (context, snapshot) {
                      final logs = snapshot.data ?? const <LinkLog>[];
                      if (snapshot.connectionState == ConnectionState.waiting && logs.isEmpty) {
                        return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                      }
                      if (logs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
                          child: const Text('暂无日志：请在任意新建页保存一条关联记录。', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                        );
                      }

                      return StreamBuilder<List<FriendRecord>>(
                        stream: db.friendDao.watchAllActive(),
                        builder: (context, friendSnapshot) {
                          final friends = friendSnapshot.data ?? const <FriendRecord>[];
                          return StreamBuilder<List<FoodRecord>>(
                            stream: db.foodDao.watchAllActive(),
                            builder: (context, foodSnapshot) {
                              final foods = foodSnapshot.data ?? const <FoodRecord>[];
                              return StreamBuilder<List<MomentRecord>>(
                                stream: db.momentDao.watchAllActive(),
                                builder: (context, momentSnapshot) {
                                  final moments = momentSnapshot.data ?? const <MomentRecord>[];
                                  return StreamBuilder<List<TravelRecord>>(
                                    stream: db.watchAllActiveTravelRecords(),
                                    builder: (context, travelSnapshot) {
                                      final travels = travelSnapshot.data ?? const <TravelRecord>[];
                                      return StreamBuilder<List<TimelineEvent>>(
                                        stream: goalsStream,
                                        builder: (context, goalSnapshot) {
                                          final goals = goalSnapshot.data ?? const <TimelineEvent>[];
                                          return StreamBuilder<List<TimelineEvent>>(
                                            stream: encountersStream,
                                            builder: (context, encounterSnapshot) {
                                              final encounters = encounterSnapshot.data ?? const <TimelineEvent>[];
                                              final maps = _UniversalEntityMaps(
                                                foods: {for (final f in foods) f.id: (f.title).trim().isEmpty ? '美食记录' : f.title.trim()},
                                                moments: {for (final m in moments) m.id: _momentTitleFromContent(m.content)},
                                                friends: {for (final f in friends) f.id: (f.name).trim().isEmpty ? '朋友' : f.name.trim()},
                                                travels: {
                                                  for (final t in travels)
                                                    t.id: ((t.title ?? '').trim().isNotEmpty ? t.title!.trim() : ((t.destination ?? '').trim().isNotEmpty ? t.destination!.trim() : '旅行记录'))
                                                },
                                                goals: {for (final g in goals) g.id: g.title},
                                                encounters: {for (final e in encounters) e.id: e.title},
                                              );

                                              final query = _searchController.text.trim();
                                              final filtered = logs.where((log) {
                                                if (_selectedType != 'all' && log.sourceType != _selectedType && log.targetType != _selectedType) return false;
                                                if (query.isEmpty) return true;
                                                final left = '${_typeLabel(log.sourceType)} ${maps.titleOf(log.sourceType, log.sourceId)}';
                                                final right = '${_typeLabel(log.targetType)} ${maps.titleOf(log.targetType, log.targetId)}';
                                                return left.contains(query) || right.contains(query);
                                              }).toList(growable: false);

                                              return Container(
                                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3F4F6))),
                                                child: ListView.separated(
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemCount: filtered.length,
                                                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                                                  itemBuilder: (context, index) {
                                                    final log = filtered[index];
                                                    final leftTitle = maps.titleOf(log.sourceType, log.sourceId);
                                                    final rightTitle = maps.titleOf(log.targetType, log.targetId);
                                                    return ListTile(
                                                      dense: true,
                                                      leading: Container(
                                                        width: 34,
                                                        height: 34,
                                                        decoration: BoxDecoration(
                                                          color: _logActionColor(log.action),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: Icon(_logActionIcon(log.action), size: 18, color: _logActionIconColor(log.action)),
                                                      ),
                                                      title: Text(
                                                        '${_logActionLabel(log.action)}：$leftTitle ↔ $rightTitle',
                                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      subtitle: Text(
                                                        '${_typeLabel(log.sourceType)} · $leftTitle\n${_typeLabel(log.targetType)} · $rightTitle',
                                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B), height: 1.35),
                                                      ),
                                                      trailing: Text(
                                                        _timeText(log.createdAt),
                                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                                                      ),
                                                    );
                                                  },
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
                            },
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
    );
  }
}

class UniversalLinkAllLogsPage extends ConsumerStatefulWidget {
  const UniversalLinkAllLogsPage({super.key});

  @override
  ConsumerState<UniversalLinkAllLogsPage> createState() => _UniversalLinkAllLogsPageState();
}

class _UniversalLinkAllLogsPageState extends ConsumerState<UniversalLinkAllLogsPage> {
  String _action = 'all';
  String _entityType = 'all';
  int _limit = 200;

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final logsQuery = (db.select(db.linkLogs)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
      ..limit(_limit));

    final goalsStream = (db.select(db.timelineEvents)
          ..where((t) => t.eventType.equals('goal'))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
        .watch();
    final encountersStream = db.watchEncounterEvents();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        title: const Text('全部日志', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: const [SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      _UniversalTab(
                        label: '全部',
                        selected: _action == 'all',
                        onTap: () => setState(() => _action = 'all'),
                      ),
                      _UniversalTab(
                        label: '新增',
                        selected: _action == 'create',
                        onTap: () => setState(() => _action = 'create'),
                      ),
                      _UniversalTab(
                        label: '修改',
                        selected: _action == 'update',
                        onTap: () => setState(() => _action = 'update'),
                      ),
                      _UniversalTab(
                        label: '删除',
                        selected: _action == 'delete',
                        onTap: () => setState(() => _action = 'delete'),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 48,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      scrollDirection: Axis.horizontal,
                      children: [
                        _UniversalChip(
                          label: '全部',
                          selected: _entityType == 'all',
                          onTap: () => setState(() => _entityType = 'all'),
                        ),
                        _UniversalChip(
                          label: '美食',
                          selected: _entityType == 'food',
                          onTap: () => setState(() => _entityType = 'food'),
                        ),
                        _UniversalChip(
                          label: '旅行',
                          selected: _entityType == 'travel',
                          onTap: () => setState(() => _entityType = 'travel'),
                        ),
                        _UniversalChip(
                          label: '小确幸',
                          selected: _entityType == 'moment',
                          onTap: () => setState(() => _entityType = 'moment'),
                        ),
                        _UniversalChip(
                          label: '目标',
                          selected: _entityType == 'goal',
                          onTap: () => setState(() => _entityType = 'goal'),
                        ),
                        _UniversalChip(
                          label: '羁绊',
                          selected: _entityType == 'friend',
                          onTap: () => setState(() => _entityType = 'friend'),
                        ),
                        _UniversalChip(
                          label: '相遇',
                          selected: _entityType == 'encounter',
                          onTap: () => setState(() => _entityType = 'encounter'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<LinkLog>>(
                stream: logsQuery.watch(),
                builder: (context, snapshot) {
                  final raw = snapshot.data ?? const <LinkLog>[];
                  if (snapshot.connectionState == ConnectionState.waiting && raw.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (raw.isEmpty) {
                    return const Center(child: Text('暂无日志', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6B7280))));
                  }

                  return StreamBuilder<List<FriendRecord>>(
                    stream: db.friendDao.watchAllActive(),
                    builder: (context, friendSnapshot) {
                      final friends = friendSnapshot.data ?? const <FriendRecord>[];
                      return StreamBuilder<List<FoodRecord>>(
                        stream: db.foodDao.watchAllActive(),
                        builder: (context, foodSnapshot) {
                          final foods = foodSnapshot.data ?? const <FoodRecord>[];
                          return StreamBuilder<List<MomentRecord>>(
                            stream: db.momentDao.watchAllActive(),
                            builder: (context, momentSnapshot) {
                              final moments = momentSnapshot.data ?? const <MomentRecord>[];
                              return StreamBuilder<List<TravelRecord>>(
                                stream: db.watchAllActiveTravelRecords(),
                                builder: (context, travelSnapshot) {
                                  final travels = travelSnapshot.data ?? const <TravelRecord>[];
                                  return StreamBuilder<List<TimelineEvent>>(
                                    stream: goalsStream,
                                    builder: (context, goalSnapshot) {
                                      final goals = goalSnapshot.data ?? const <TimelineEvent>[];
                                      return StreamBuilder<List<TimelineEvent>>(
                                        stream: encountersStream,
                                        builder: (context, encounterSnapshot) {
                                          final encounters = encounterSnapshot.data ?? const <TimelineEvent>[];
                                          final maps = _UniversalEntityMaps(
                                            foods: {for (final f in foods) f.id: (f.title).trim().isEmpty ? '美食记录' : f.title.trim()},
                                            moments: {for (final m in moments) m.id: _momentTitleFromContent(m.content)},
                                            friends: {for (final f in friends) f.id: (f.name).trim().isEmpty ? '朋友' : f.name.trim()},
                                            travels: {
                                              for (final t in travels)
                                                t.id: ((t.title ?? '').trim().isNotEmpty ? t.title!.trim() : ((t.destination ?? '').trim().isNotEmpty ? t.destination!.trim() : '旅行记录'))
                                            },
                                            goals: {for (final g in goals) g.id: g.title},
                                            encounters: {for (final e in encounters) e.id: e.title},
                                          );

                                          final items = raw.where((log) {
                                            if (_action != 'all' && log.action != _action) return false;
                                            if (_entityType == 'all') return true;
                                            return log.sourceType == _entityType || log.targetType == _entityType;
                                          }).toList(growable: false);

                                          if (items.isEmpty) {
                                            return const Center(
                                              child: Text('没有符合筛选条件的日志', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                                            );
                                          }

                                          final groups = _groupLogsByDay(items);

                                          return ListView.builder(
                                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                                            itemCount: groups.length + 1,
                                            itemBuilder: (context, index) {
                                              if (index == groups.length) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: OutlinedButton(
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor: const Color(0xFF64748B),
                                                      side: const BorderSide(color: Color(0xFFE5E7EB), style: BorderStyle.solid),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                                                    ),
                                                    onPressed: () => setState(() => _limit += 200),
                                                    child: const Text('查看更早的记录'),
                                                  ),
                                                );
                                              }

                                              final group = groups[index];
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(top: index == 0 ? 0 : 14, bottom: 8, left: 2),
                                                    child: Text(group.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
                                                  ),
                                                  for (final log in group.items) ...[
                                                    _UniversalLogRow(
                                                      color: _typeColor(log.sourceType),
                                                      title: '${_logActionLabel(log.action)}关联',
                                                      subtitle: '${_typeLabel(log.sourceType)} · ${maps.titleOf(log.sourceType, log.sourceId)}  ↔  ${_typeLabel(log.targetType)} · ${maps.titleOf(log.targetType, log.targetId)}',
                                                      time: _timeText(log.createdAt, includeDayPrefix: group.title == '昨天'),
                                                    ),
                                                    const SizedBox(height: 10),
                                                  ],
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
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
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

String _linkTypeLabel(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return '关联';
  if (value == 'manual') return '共同回忆';
  if (value == 'auto') return '系统关联';
  return value;
}

String _momentTitleFromContent(String? content) {
  final raw = (content ?? '').trim();
  if (raw.isEmpty) return '小确幸';
  final lines = raw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(growable: false);
  if (lines.isEmpty) return '小确幸';
  return lines.first.length > 24 ? '${lines.first.substring(0, 24)}…' : lines.first;
}

IconData _logActionIcon(String action) {
  switch (action) {
    case 'delete':
      return Icons.link_off;
    case 'update':
      return Icons.edit;
    default:
      return Icons.link;
  }
}

Color _logActionIconColor(String action) {
  switch (action) {
    case 'delete':
      return const Color(0xFFEF4444);
    case 'update':
      return const Color(0xFFF59E0B);
    default:
      return const Color(0xFF3B82F6);
  }
}

Color _logActionColor(String action) {
  switch (action) {
    case 'delete':
      return const Color(0xFFFFEBEE);
    case 'update':
      return const Color(0xFFFFF7ED);
    default:
      return const Color(0xFFEFF6FF);
  }
}

String _logActionLabel(String action) {
  switch (action) {
    case 'delete':
      return '删除';
    case 'update':
      return '修改';
    default:
      return '新增';
  }
}

String _timeText(DateTime dateTime, {bool includeDayPrefix = false}) {
  final local = dateTime.toLocal();
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  if (!includeDayPrefix) return '$hh:$mm';
  return '昨天 $hh:$mm';
}

Color _typeColor(String type) {
  switch (type) {
    case 'food':
      return const Color(0xFFF97316);
    case 'travel':
      return const Color(0xFF60A5FA);
    case 'moment':
      return const Color(0xFFF472B6);
    case 'goal':
      return const Color(0xFF34D399);
    case 'friend':
      return const Color(0xFFA78BFA);
    case 'encounter':
      return const Color(0xFF818CF8);
    default:
      return const Color(0xFF94A3B8);
  }
}

class _UniversalEntityMaps {
  const _UniversalEntityMaps({
    required this.foods,
    required this.moments,
    required this.friends,
    required this.travels,
    required this.goals,
    required this.encounters,
  });

  final Map<String, String> foods;
  final Map<String, String> moments;
  final Map<String, String> friends;
  final Map<String, String> travels;
  final Map<String, String> goals;
  final Map<String, String> encounters;

  String titleOf(String type, String id) {
    switch (type) {
      case 'food':
        return foods[id] ?? '已删除/未找到';
      case 'moment':
        return moments[id] ?? '已删除/未找到';
      case 'friend':
        return friends[id] ?? '已删除/未找到';
      case 'travel':
        return travels[id] ?? '已删除/未找到';
      case 'goal':
        return goals[id] ?? '已删除/未找到';
      case 'encounter':
        return encounters[id] ?? '已删除/未找到';
      default:
        return '已删除/未找到';
    }
  }
}

class _UniversalStatCard extends StatelessWidget {
  const _UniversalStatCard({required this.title, required this.value, required this.unit});

  final String title;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF2BCDEE))),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(unit, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UniversalFilterChip extends StatelessWidget {
  const _UniversalFilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2BCDEE) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? const Color(0xFF2BCDEE) : const Color(0xFFE5E7EB)),
            boxShadow: selected ? const [BoxShadow(color: Color(0x332BCDEE), blurRadius: 12, offset: Offset(0, 4))] : null,
          ),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: selected ? Colors.white : const Color(0xFF64748B))),
        ),
      ),
    );
  }
}

class _UniversalLinkCard extends StatelessWidget {
  const _UniversalLinkCard({
    required this.leftTitle,
    required this.leftType,
    required this.rightTitle,
    required this.rightType,
    required this.linkLabel,
    required this.createdAt,
  });

  final String leftTitle;
  final String leftType;
  final String rightTitle;
  final String rightType;
  final String linkLabel;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final local = createdAt.toLocal();
    final date = '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _UniversalEntityCell(title: leftTitle, type: leftType)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: const Color(0x1A2BCDEE), borderRadius: BorderRadius.circular(999)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.link, size: 16, color: Color(0xFF2BCDEE)),
                    ),
                    const SizedBox(height: 6),
                    Text(linkLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF2BCDEE))),
                  ],
                ),
              ),
              Expanded(child: _UniversalEntityCell(title: rightTitle, type: rightType)),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('关联于 $date', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
              const Spacer(),
              Text('普通关联', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF64748B).withValues(alpha: 0.9))),
            ],
          ),
        ],
      ),
    );
  }
}

class _UniversalEntityCell extends StatelessWidget {
  const _UniversalEntityCell({required this.title, required this.type});

  final String title;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(type, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
      ],
    );
  }
}

class _UniversalTab extends StatelessWidget {
  const _UniversalTab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: selected ? const Color(0xFF2BCDEE) : Colors.transparent, width: 2)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w900 : FontWeight.w700, color: selected ? const Color(0xFF2BCDEE) : const Color(0xFF94A3B8)),
          ),
        ),
      ),
    );
  }
}

class _UniversalChip extends StatelessWidget {
  const _UniversalChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0x1A2BCDEE) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? const Color(0x332BCDEE) : const Color(0xFFE5E7EB)),
          ),
          child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: selected ? const Color(0xFF2BCDEE) : const Color(0xFF64748B))),
        ),
      ),
    );
  }
}

class _UniversalLogRow extends StatelessWidget {
  const _UniversalLogRow({required this.color, required this.title, required this.subtitle, required this.time});

  final Color color;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(width: 6, height: 46, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

class _LogGroup {
  const _LogGroup({required this.title, required this.items});
  final String title;
  final List<LinkLog> items;
}

List<_LogGroup> _groupLogsByDay(List<LinkLog> logs) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final todayItems = <LinkLog>[];
  final yesterdayItems = <LinkLog>[];
  final olderGroups = <String, List<LinkLog>>{};

  for (final log in logs) {
    final local = log.createdAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) {
      todayItems.add(log);
      continue;
    }
    if (day == yesterday) {
      yesterdayItems.add(log);
      continue;
    }
    final key = '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    (olderGroups[key] ??= <LinkLog>[]).add(log);
  }

  final result = <_LogGroup>[];
  if (todayItems.isNotEmpty) result.add(_LogGroup(title: '今天', items: todayItems));
  if (yesterdayItems.isNotEmpty) result.add(_LogGroup(title: '昨天', items: yesterdayItems));

  final olderKeys = olderGroups.keys.toList(growable: false)..sort((a, b) => b.compareTo(a));
  for (final k in olderKeys) {
    result.add(_LogGroup(title: k, items: olderGroups[k] ?? const <LinkLog>[]));
  }
  return result;
}

class DataManagementPage extends StatelessWidget {
  const DataManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(title: '个人中心-数据管理');
  }
}

class PersonalProfilePage extends ConsumerStatefulWidget {
  const PersonalProfilePage({super.key});

  @override
  ConsumerState<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends ConsumerState<PersonalProfilePage> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _birthday;
  String _relationshipStatus = '单身汪';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String? _formatNumber(Object? value) {
    if (value == null) return null;
    if (value is num) {
      final asInt = value.toInt();
      if (asInt.toDouble() == value.toDouble()) return asInt.toString();
      return value.toString();
    }
    return value.toString();
  }

  double? _parseNumber(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }

  Future<void> _load() async {
    final db = ref.read(appDatabaseProvider);
    final row = await (db.select(db.userProfiles)..where((t) => t.id.equals('me'))).getSingleOrNull();

    final displayName = (row?.displayName ?? '').trim();
    final nameAsync = displayName.isEmpty ? await ref.read(userDisplayNameProvider.future) : displayName;
    final birthday = row?.birthday == null ? null : DateTime(row!.birthday!.year, row.birthday!.month, row.birthday!.day);

    final heightText = _formatNumber(row?.heightCm);
    final weightText = _formatNumber(row?.weightKg);
    final statusText = (row?.relationshipStatus ?? '').trim();

    if (!mounted) return;
    setState(() {
      _nameController.text = nameAsync;
      _birthday = birthday;
      if (heightText != null) _heightController.text = heightText;
      if (weightText != null) _weightController.text = weightText;
      if (['单身汪', '有对象', '已婚'].contains(statusText)) {
        _relationshipStatus = statusText;
      }
    });
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final initial = _birthday ?? DateTime(now.year - 20, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      locale: const Locale('zh', 'CN'),
    );
    if (pickedDate == null) return;
    if (!mounted) return;
    setState(() => _birthday = DateTime(pickedDate.year, pickedDate.month, pickedDate.day));
  }

  String _birthdayText() {
    final value = _birthday;
    if (value == null) return '未填写';
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _save() async {
    final displayName = _nameController.text.trim();
    if (displayName.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写用户名')));
      return;
    }
    final height = _parseNumber(_heightController.text);
    final weight = _parseNumber(_weightController.text);

    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final existed = await (db.select(db.userProfiles)..where((t) => t.id.equals('me'))).getSingleOrNull();
    await db.into(db.userProfiles).insertOnConflictUpdate(
          UserProfilesCompanion(
            id: const Value('me'),
            displayName: Value(displayName),
            birthday: Value(_birthday),
            heightCm: Value(height),
            weightKg: Value(weight),
            relationshipStatus: Value(_relationshipStatus),
            createdAt: Value(existed?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );

    final notifier = ref.read(profileRevisionProvider.notifier);
    notifier.state = notifier.state + 1;

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        title: const Text('个人资料', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存', style: TextStyle(fontWeight: FontWeight.w800)),
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
                children: [
                  const Text('用户名', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: '请输入用户名',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('出生日期', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickBirthday,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _birthdayText(),
                              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                            ),
                          ),
                          const Icon(Icons.calendar_month, size: 18, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('身高(cm)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _heightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: '例如 170',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('体重(kg)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _weightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: '例如 60',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('感情状态', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _relationshipStatus,
                    items: const [
                      DropdownMenuItem(value: '单身汪', child: Text('单身汪')),
                      DropdownMenuItem(value: '有对象', child: Text('有对象')),
                      DropdownMenuItem(value: '已婚', child: Text('已婚')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _relationshipStatus = value);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfilePage._primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
              onPressed: _save,
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}

class ModuleManagementPage extends ConsumerStatefulWidget {
  const ModuleManagementPage({super.key});

  @override
  ConsumerState<ModuleManagementPage> createState() => _ModuleManagementPageState();
}

class _ModuleManagementPageState extends ConsumerState<ModuleManagementPage> {
  ModuleManagementConfig? _config;
  bool _loading = true;

  static const _bg = Color(0xFFF2F4F6);
  static const _accentBg = Color(0xFFE0F2F1);
  static const _accentFg = Color(0xFF00695C);
  static const _cardBorder = Color(0xFFF3F4F6);
  static const _mutedText = Color(0xFF94A3B8);

  final List<_ModuleIconOption> _momentIconOptions = const [
    _ModuleIconOption(name: 'card_giftcard', icon: Icons.card_giftcard),
    _ModuleIconOption(name: 'sunny', icon: Icons.sunny),
    _ModuleIconOption(name: 'directions_walk', icon: Icons.directions_walk),
    _ModuleIconOption(name: 'local_florist', icon: Icons.local_florist),
    _ModuleIconOption(name: 'coffee', icon: Icons.coffee),
    _ModuleIconOption(name: 'beach_access', icon: Icons.beach_access),
    _ModuleIconOption(name: 'pets', icon: Icons.pets),
    _ModuleIconOption(name: 'music_note', icon: Icons.music_note),
    _ModuleIconOption(name: 'nightlife', icon: Icons.nightlife),
    _ModuleIconOption(name: 'movie', icon: Icons.movie),
    _ModuleIconOption(name: 'celebration', icon: Icons.celebration),
    _ModuleIconOption(name: 'camera_alt', icon: Icons.camera_alt),
  ];

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await loadModuleManagementConfig();
    if (!mounted) return;
    setState(() {
      _config = config;
      _loading = false;
    });
  }

  Future<void> _saveConfig(ModuleManagementConfig config) async {
    setState(() => _config = config);
    await saveModuleManagementConfig(config);
    if (!mounted) return;
    ref.read(moduleManagementRevisionProvider.notifier).state += 1;
  }

  ModuleManagementConfig _updateModule(ModuleConfig module) {
    final modules = Map<String, ModuleConfig>.from(_config?.modules ?? {});
    modules[module.key] = module;
    return ModuleManagementConfig(modules: modules);
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

  Map<String, int> _countFoodTags(List<FoodRecord> foods) {
    final counts = <String, int>{};
    for (final record in foods) {
      final tags = _parseStringList(record.tags);
      for (final tag in tags) {
        final key = tag.trim();
        if (key.isEmpty) continue;
        counts.update(key, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  Map<String, int> _countMomentTags(List<MomentRecord> moments) {
    final counts = <String, int>{};
    for (final record in moments) {
      final tag = (record.sceneTag ?? '').trim();
      if (tag.isEmpty) continue;
      counts.update(tag, (v) => v + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  Map<String, int> _countTravelTags(List<TravelRecord> travels) {
    final counts = <String, int>{};
    for (final record in travels) {
      final candidates = [
        record.destination,
        record.mood,
      ];
      for (final raw in candidates) {
        final tag = (raw ?? '').trim();
        if (tag.isEmpty) continue;
        counts.update(tag, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  Map<String, int> _countBondTags(List<FriendRecord> friends) {
    final counts = <String, int>{};
    for (final record in friends) {
      final tags = _parseStringList(record.impressionTags);
      for (final tag in tags) {
        final key = tag.trim();
        if (key.isEmpty) continue;
        counts.update(key, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  Map<String, int> _countGoalTags(List<TimelineEvent> goals) {
    final counts = <String, int>{};
    for (final record in goals) {
      final note = (record.note ?? '').trim();
      if (note.isEmpty) continue;
      for (final line in note.split('\n')) {
        if (line.startsWith('分类：')) {
          final tag = line.replaceFirst('分类：', '').trim();
          if (tag.isNotEmpty) {
            counts.update(tag, (v) => v + 1, ifAbsent: () => 1);
          }
        }
      }
    }
    return counts;
  }

  String _newTagId(String moduleKey) {
    return '$moduleKey-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _openTagEditor({
    required ModuleConfig module,
    ModuleTag? tag,
  }) async {
    final controller = TextEditingController(text: tag?.name ?? '');
    String selectedIcon = tag?.iconName ?? _momentIconOptions.first.name;
    bool showOnCalendar = tag?.showOnCalendar ?? true;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: Material(
                  color: Colors.white,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tag == null ? '新增标签' : '编辑标签',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: '输入标签名称',
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                              isDense: true,
                            ),
                          ),
                          if (module.key == 'moment') ...[
                            const SizedBox(height: 16),
                            const Text('选择图标', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final option in _momentIconOptions)
                                  InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => setSheetState(() => selectedIcon = option.name),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: option.name == selectedIcon ? const Color(0xFFE0F2F1) : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: option.name == selectedIcon ? const Color(0xFF2BCDEE) : const Color(0xFFE5E7EB),
                                        ),
                                      ),
                                      child: Icon(option.icon, color: option.name == selectedIcon ? const Color(0xFF0F766E) : const Color(0xFF6B7280), size: 20),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Text('首页日程展示', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
                                const Spacer(),
                                Switch(
                                  value: showOnCalendar,
                                  activeColor: const Color(0xFF2BCDEE),
                                  activeTrackColor: const Color(0xFFBAE6FD),
                                  onChanged: (v) => setSheetState(() => showOnCalendar = v),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ProfilePage._primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                textStyle: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                              onPressed: () {
                                final name = controller.text.trim();
                                if (name.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入标签名称')));
                                  return;
                                }
                                final current = _config?.moduleOf(module.key) ?? module;
                                final updatedTags = [...current.tags];
                                if (tag == null) {
                                  updatedTags.add(
                                    ModuleTag(
                                      id: _newTagId(module.key),
                                      name: name,
                                      iconName: module.key == 'moment' ? selectedIcon : null,
                                      showOnCalendar: module.key == 'moment' ? showOnCalendar : true,
                                    ),
                                  );
                                } else {
                                  final index = updatedTags.indexWhere((t) => t.id == tag.id);
                                  if (index != -1) {
                                    updatedTags[index] = tag.copyWith(
                                      name: name,
                                      iconName: module.key == 'moment' ? selectedIcon : tag.iconName,
                                      showOnCalendar: module.key == 'moment' ? showOnCalendar : tag.showOnCalendar,
                                    );
                                  }
                                }
                                _saveConfig(_updateModule(current.copyWith(tags: updatedTags)));
                                Navigator.of(context).pop();
                              },
                              child: const Text('保存'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteTag({
    required ModuleConfig module,
    required ModuleTag tag,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除“${tag.name}”吗？'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('取消')),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('删除')),
          ],
        );
      },
    );
    if (confirmed != true) return;
    final current = _config?.moduleOf(module.key) ?? module;
    final updatedTags = current.tags.where((t) => t.id != tag.id).toList(growable: false);
    await _saveConfig(_updateModule(current.copyWith(tags: updatedTags)));
  }

  Widget _buildTagRow({
    required ModuleConfig module,
    required ModuleTag tag,
    required int count,
  }) {
    final isMoment = module.key == 'moment';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          if (isMoment)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
              child: Icon(iconFromName(tag.iconName ?? module.iconName), size: 16, color: _accentFg),
            ),
          if (isMoment) const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: tag.name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                children: [
                  TextSpan(text: ' ($count)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
          ),
          if (isMoment)
            Row(
              children: [
                const Text('首页展示', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                const SizedBox(width: 4),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: tag.showOnCalendar,
                    activeColor: const Color(0xFF2BCDEE),
                    activeTrackColor: const Color(0xFFBAE6FD),
                    onChanged: (v) {
                      final current = _config?.moduleOf(module.key) ?? module;
                      final updatedTags = current.tags
                          .map((t) => t.id == tag.id ? t.copyWith(showOnCalendar: v) : t)
                          .toList(growable: false);
                      _saveConfig(_updateModule(current.copyWith(tags: updatedTags)));
                    },
                  ),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18, color: Color(0xFF94A3B8)),
            onPressed: () => _openTagEditor(module: module, tag: tag),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 18, color: Color(0xFFEF4444)),
            onPressed: () => _confirmDeleteTag(module: module, tag: tag),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required ModuleConfig module,
    required Map<String, int> tagCounts,
  }) {
    final tags = module.tags;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: _accentBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(iconFromName(module.iconName), color: _accentFg),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(module.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('首页日程展示', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                  Switch(
                    value: module.showOnCalendar,
                    activeColor: const Color(0xFF2BCDEE),
                    activeTrackColor: const Color(0xFFBAE6FD),
                    onChanged: (v) => _saveConfig(_updateModule(module.copyWith(showOnCalendar: v))),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Opacity(
                opacity: 0.5,
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(iconFromName(module.iconName), size: 16, color: _accentFg),
                  label: const Text('图标', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(module.tagTitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
          const SizedBox(height: 10),
          Column(
            children: [
              for (final tag in tags) ...[
                _buildTagRow(
                  module: module,
                  tag: tag,
                  count: tagCounts[tag.name] ?? 0,
                ),
                const SizedBox(height: 8),
              ],
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _openTagEditor(module: module),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB), style: BorderStyle.solid),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 16, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Text('新增${module.title == '羁绊' ? '印象' : module.title == '目标' ? '分类' : module.title == '旅行' ? '目的地' : module.title == '美食' ? '菜系' : '标签'}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          title: const Text('模块管理', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final config = _config ?? ModuleManagementConfig.defaults();
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        title: const Text('模块管理', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: StreamBuilder<List<FoodRecord>>(
        stream: db.foodDao.watchAllActive(),
        builder: (context, foodSnapshot) {
          final foodCounts = _countFoodTags(foodSnapshot.data ?? const <FoodRecord>[]);
          return StreamBuilder<List<MomentRecord>>(
            stream: db.momentDao.watchAllActive(),
            builder: (context, momentSnapshot) {
              final momentCounts = _countMomentTags(momentSnapshot.data ?? const <MomentRecord>[]);
              return StreamBuilder<List<TravelRecord>>(
                stream: db.watchAllActiveTravelRecords(),
                builder: (context, travelSnapshot) {
                  final travelCounts = _countTravelTags(travelSnapshot.data ?? const <TravelRecord>[]);
                  return StreamBuilder<List<FriendRecord>>(
                    stream: db.friendDao.watchAllActive(),
                    builder: (context, friendSnapshot) {
                      final bondCounts = _countBondTags(friendSnapshot.data ?? const <FriendRecord>[]);
                      return StreamBuilder<List<TimelineEvent>>(
                        stream: (db.select(db.timelineEvents)
                              ..where((t) => t.isDeleted.equals(false))
                              ..where((t) => t.eventType.equals('goal')))
                            .watch(),
                        builder: (context, goalSnapshot) {
                          final goalCounts = _countGoalTags(goalSnapshot.data ?? const <TimelineEvent>[]);
                          return ListView(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 40),
                            children: [
                              const Text(
                                '自定义您的首页日历图标，管理各模块深度标签及数据统计。',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                              ),
                              const SizedBox(height: 16),
                              _buildModuleCard(module: config.moduleOf('food'), tagCounts: foodCounts),
                              const SizedBox(height: 14),
                              _buildModuleCard(module: config.moduleOf('travel'), tagCounts: travelCounts),
                              const SizedBox(height: 14),
                              _buildModuleCard(module: config.moduleOf('moment'), tagCounts: momentCounts),
                              const SizedBox(height: 14),
                              _buildModuleCard(module: config.moduleOf('bond'), tagCounts: bondCounts),
                              const SizedBox(height: 14),
                              _buildModuleCard(module: config.moduleOf('goal'), tagCounts: goalCounts),
                              const SizedBox(height: 20),
                              Center(
                                child: TextButton.icon(
                                  onPressed: () => _saveConfig(ModuleManagementConfig.defaults()),
                                  icon: const Icon(Icons.settings_backup_restore, color: _mutedText),
                                  label: const Text('恢复默认设置', style: TextStyle(fontWeight: FontWeight.w700, color: _mutedText)),
                                ),
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
    );
  }
}

class _ModuleIconOption {
  const _ModuleIconOption({required this.name, required this.icon});

  final String name;
  final IconData icon;
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
  if (isNetwork || kIsWeb) {
    return Image.network(trimmed, fit: fit, gaplessPlayback: true);
  }
  return Image.file(File(trimmed), fit: fit, gaplessPlayback: true);
}
