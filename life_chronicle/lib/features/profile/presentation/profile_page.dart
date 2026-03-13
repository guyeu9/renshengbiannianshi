import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:epubx/epubx.dart' as epub;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:drift/drift.dart' hide Column;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/router/route_navigation.dart';
import '../../../core/router/app_router.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/providers/ai_provider.dart';
import '../../../core/services/ai_service.dart' as ai_service;
import '../../../core/utils/media_storage.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../core/config/module_management_config.dart';
import '../../../app/app_theme.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/services/file_logger.dart';
import '../../../core/models/version_info.dart';
import '../../../core/services/app_update_service.dart';
import '../../travel/presentation/travel_page.dart' show TravelItem;

class ChronicleRecord {
  const ChronicleRecord({
    required this.id,
    required this.title,
    required this.rangeStart,
    required this.rangeEnd,
    required this.createdAt,
    required this.modules,
    required this.stats,
    required this.aiSummary,
    required this.userSummary,
    required this.pdfPath,
    required this.epubPath,
    required this.isFeatured,
  });

  final String id;
  final String title;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final DateTime createdAt;
  final List<String> modules;
  final Map<String, int> stats;
  final String aiSummary;
  final String userSummary;
  final String pdfPath;
  final String epubPath;
  final bool isFeatured;

  String rangeLabel() {
    return '${_formatChronicleDate(rangeStart)} - ${_formatChronicleDate(rangeEnd)}';
  }

  List<String> tags() {
    final tags = <String>[...modules];
    if (isFeatured) tags.add('精选');
    return tags;
  }

  ChronicleRecord copyWith({
    String? id,
    String? title,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    DateTime? createdAt,
    List<String>? modules,
    Map<String, int>? stats,
    String? aiSummary,
    String? userSummary,
    String? pdfPath,
    String? epubPath,
    bool? isFeatured,
  }) {
    return ChronicleRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      createdAt: createdAt ?? this.createdAt,
      modules: modules ?? this.modules,
      stats: stats ?? this.stats,
      aiSummary: aiSummary ?? this.aiSummary,
      userSummary: userSummary ?? this.userSummary,
      pdfPath: pdfPath ?? this.pdfPath,
      epubPath: epubPath ?? this.epubPath,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'rangeStart': rangeStart.toIso8601String(),
      'rangeEnd': rangeEnd.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'modules': modules,
      'stats': stats,
      'aiSummary': aiSummary,
      'userSummary': userSummary,
      'pdfPath': pdfPath,
      'epubPath': epubPath,
      'isFeatured': isFeatured,
    };
  }

  factory ChronicleRecord.fromJson(Map<String, dynamic> json) {
    final rawModules = json['modules'];
    final modules = <String>[];
    if (rawModules is List) {
      modules.addAll(rawModules.map((e) => e.toString()));
    }
    final rawStats = json['stats'];
    final stats = <String, int>{};
    if (rawStats is Map) {
      for (final entry in rawStats.entries) {
        final value = entry.value;
        stats[entry.key.toString()] = value is num ? value.toInt() : int.tryParse(value.toString()) ?? 0;
      }
    }
    return ChronicleRecord(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      rangeStart: DateTime.tryParse(json['rangeStart']?.toString() ?? '') ?? DateTime.now(),
      rangeEnd: DateTime.tryParse(json['rangeEnd']?.toString() ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      modules: modules,
      stats: stats,
      aiSummary: (json['aiSummary'] ?? '').toString(),
      userSummary: (json['userSummary'] ?? '').toString(),
      pdfPath: (json['pdfPath'] ?? '').toString(),
      epubPath: (json['epubPath'] ?? '').toString(),
      isFeatured: json['isFeatured'] == true,
    );
  }
}

class ChronicleModuleSummary {
  const ChronicleModuleSummary({
    required this.key,
    required this.title,
    required this.count,
    required this.highlights,
  });

  final String key;
  final String title;
  final int count;
  final List<String> highlights;
}

class ChronicleRecordDetail {
  const ChronicleRecordDetail({
    required this.id,
    required this.moduleType,
    required this.title,
    required this.content,
    required this.recordDate,
    this.imagePaths = const [],
    this.rating,
    this.location,
    this.mood,
    this.destination,
    this.friendName,
    this.eventSummary,
  });

  final String id;
  final String moduleType;
  final String title;
  final String content;
  final DateTime recordDate;
  final List<String> imagePaths;
  final double? rating;
  final String? location;
  final String? mood;
  final String? destination;
  final String? friendName;
  final String? eventSummary;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleType': moduleType,
      'title': title,
      'content': content,
      'recordDate': recordDate.toIso8601String(),
      'imagePaths': imagePaths,
      'rating': rating,
      'location': location,
      'mood': mood,
      'destination': destination,
      'friendName': friendName,
      'eventSummary': eventSummary,
    };
  }

  factory ChronicleRecordDetail.fromJson(Map<String, dynamic> json) {
    final rawImagePaths = json['imagePaths'];
    final imagePaths = <String>[];
    if (rawImagePaths is List) {
      imagePaths.addAll(rawImagePaths.map((e) => e.toString()));
    }
    return ChronicleRecordDetail(
      id: (json['id'] ?? '').toString(),
      moduleType: (json['moduleType'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      recordDate: DateTime.tryParse(json['recordDate']?.toString() ?? '') ?? DateTime.now(),
      imagePaths: imagePaths,
      rating: json['rating'] is num ? json['rating'].toDouble() : null,
      location: json['location']?.toString(),
      mood: json['mood']?.toString(),
      destination: json['destination']?.toString(),
      friendName: json['friendName']?.toString(),
      eventSummary: json['eventSummary']?.toString(),
    );
  }
}

class ChronicleGeneratedContent {
  const ChronicleGeneratedContent({
    required this.rangeStart,
    required this.rangeEnd,
    required this.moduleSummaries,
    required this.aiSummary,
    this.recordDetails = const [],
  });

  final DateTime rangeStart;
  final DateTime rangeEnd;
  final List<ChronicleModuleSummary> moduleSummaries;
  final String aiSummary;
  final List<ChronicleRecordDetail> recordDetails;
}

Future<File?> chronicleStoreFile() async {
  if (kIsWeb) return null;
  final dir = await getApplicationDocumentsDirectory();
  final chronicleDir = Directory(p.join(dir.path, 'chronicle'));
  await chronicleDir.create(recursive: true);
  return File(p.join(chronicleDir.path, 'chronicles.json'));
}

Future<Directory?> chronicleExportDir() async {
  if (kIsWeb) return null;
  final dir = await getApplicationDocumentsDirectory();
  final exportDir = Directory(p.join(dir.path, 'chronicle', 'exports'));
  await exportDir.create(recursive: true);
  return exportDir;
}

Future<List<ChronicleRecord>> loadChronicleRecords() async {
  if (kIsWeb) return const <ChronicleRecord>[];
  final file = await chronicleStoreFile();
  if (file == null) return const <ChronicleRecord>[];
  if (!await file.exists()) {
    await file.writeAsString('[]');
    return const <ChronicleRecord>[];
  }
  try {
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((e) => ChronicleRecord.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    }
  } catch (e) {
    debugPrint('加载编年史记录失败: $e');
  }
  await file.writeAsString('[]');
  return const <ChronicleRecord>[];
}

Future<void> saveChronicleRecords(List<ChronicleRecord> records) async {
  if (kIsWeb) return;
  final file = await chronicleStoreFile();
  if (file == null) return;
  final payload = jsonEncode(records.map((e) => e.toJson()).toList(growable: false));
  await file.writeAsString(payload);
}

String _formatChronicleDate(DateTime date) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${date.year}.${two(date.month)}.${two(date.day)}';
}

String _safeFileName(String input) {
  final replaced = input.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  return replaced.isEmpty ? 'chronicle' : replaced;
}

class ProfilePage extends ConsumerWidget {
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

  Future<void> _shareProfile(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(appDatabaseProvider);
      final profile = await (db.select(db.userProfiles)).getSingleOrNull();
      final name = profile?.displayName ?? '林晓梦';

      final text = '''
【人生编年史 - 个人中心】

用户名：$name
已记录人生：${await _calculateRecordDays(ref)}天

记录统计：
- 美食记录：待统计
- 旅行记录：待统计
- 小确幸记录：待统计
- 羁绊记录：待统计
- 目标记录：待统计

我频繁的记录着，我热烈的分享着
你要知道诗人的一生也可能非常普通

来自【人生编年史】App
''';

      await Share.share(text, subject: '人生编年史 - 个人中心');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败：$e')),
        );
      }
    }
  }

  void _showNotificationSettings(BuildContext context) {
    RouteNavigation.goToReminderSettings(context);
  }

  Future<int> _calculateRecordDays(WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final profile = await (db.select(db.userProfiles)..where((t) => t.id.equals('me'))).getSingleOrNull();

    if (profile?.createdAt != null) {
      return DateTime.now().difference(profile!.createdAt).inDays;
    }

    final allDates = <DateTime>[];

    final foods = await db.foodDao.watchAllActive().first;
    for (final f in foods) {
      allDates.add(f.recordDate);
    }

    final moments = await db.momentDao.watchAllActive().first;
    for (final m in moments) {
      allDates.add(m.recordDate);
    }

    final travels = await (db.select(db.travelRecords)..where((t) => t.isDeleted.equals(false))).get();
    for (final t in travels) {
      allDates.add(t.recordDate);
    }

    final events = await (db.select(db.timelineEvents)..where((t) => t.isDeleted.equals(false))).get();
    for (final e in events) {
      allDates.add(e.recordDate);
    }

    final friends = await db.friendDao.watchAllActive().first;
    for (final f in friends) {
      allDates.add(f.updatedAt);
    }

    if (allDates.isEmpty) return 0;

    allDates.sort();
    return DateTime.now().difference(allDates.first).inDays;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.only(bottom: 40 + MediaQuery.paddingOf(context).bottom),
                children: [
                  const _Header(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ChronicleCard(
                          onGenerate: () => RouteNavigation.goToChronicleGenerateConfig(context),
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
                                onTap: () => RouteNavigation.goToFavoritesCenter(context),
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
                                onTap: () => RouteNavigation.goToChronicleManage(context),
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
                                onTap: () => RouteNavigation.goToAnnualReportList(context),
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
                                onTap: () => RouteNavigation.goToDataManagement(context),
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
                                onTap: () => RouteNavigation.goToModuleManagement(context),
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
                              onTap: () => RouteNavigation.goToUniversalLink(context),
                            ),
                            _ListItem(
                              icon: Icons.psychology,
                              iconColor: const Color(0xFF6366F1),
                              title: 'AI 模型管理',
                              onTap: () => RouteNavigation.goToAiModelManagement(context),
                            ),
                            _ListItem(
                              icon: Icons.person,
                              iconColor: Colors.black,
                              title: '个人资料',
                              onTap: () => RouteNavigation.goToPersonalProfile(context),
                            ),
                            _ListItem(
                              icon: Icons.notifications_active,
                              iconColor: Colors.black,
                              title: '提醒设置',
                              onTap: () => RouteNavigation.goToReminderSettings(context),
                            ),
                            _ListItem(
                              icon: Icons.lock,
                              iconColor: Colors.black,
                              title: '隐私与安全',
                              onTap: () => RouteNavigation.goToPrivacySecurity(context),
                            ),
                            _ListItem(
                              icon: Icons.help,
                              iconColor: Colors.black,
                              title: '帮助与反馈',
                              onTap: () => RouteNavigation.goToHelpFeedback(context),
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
                            backgroundColor: WidgetStateProperty.all(Colors.transparent),
                          ),
                          onPressed: () {},
                          child: const Text('退出登录', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 悬浮按钮 - 返回
              Positioned(
                top: 16,
                left: 16,
                child: _FrostedCircleButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => context.go(AppRoutes.home),
                ),
              ),
              // 悬浮按钮 - 分享和通知
              Positioned(
                top: 16,
                right: 16,
                child: Row(
                  children: [
                    _FrostedCircleButton(
                      icon: Icons.share,
                      onTap: () => _shareProfile(context, ref),
                    ),
                    const SizedBox(width: 12),
                    _FrostedCircleButton(
                      icon: Icons.notifications,
                      onTap: () => _showNotificationSettings(context),
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

class _Header extends ConsumerStatefulWidget {
  const _Header();

  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
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
    } catch (e) {
      debugPrint('加载头像路径失败: $e');
    }
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

  static String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
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
          Consumer(
            builder: (context, ref, _) {
              final daysAsync = ref.watch(userRecordDaysProvider);
              final days = daysAsync.when(
                data: (d) => d,
                loading: () => 0,
                error: (_, __) => 0,
              );
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_edu, size: 16, color: Color(0xFF15803D)),
                    const SizedBox(width: 8),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 12, color: Color(0xFF166534), fontWeight: FontWeight.w800),
                        children: [
                          const TextSpan(text: '已记录人生 '),
                          TextSpan(text: _formatNumber(days), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          const TextSpan(text: ' 天'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
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

class ChronicleGenerateConfigPage extends ConsumerStatefulWidget {
  const ChronicleGenerateConfigPage({super.key});

  @override
  ConsumerState<ChronicleGenerateConfigPage> createState() => _ChronicleGenerateConfigPageState();
}

class _ChronicleGenerateConfigPageState extends ConsumerState<ChronicleGenerateConfigPage> {
  static const _rangeOptions = ['2024 年度', '近三年', '自定义'];
  static const _modules = [
    {
      'key': 'food',
      'title': '寻味美食',
      'desc': '记录味蕾的感动瞬间',
      'icon': Icons.restaurant,
      'color': Color(0xFFFFA726),
    },
    {
      'key': 'travel',
      'title': '漫游足迹',
      'desc': '探索世界的每一个角落',
      'icon': Icons.flight_takeoff,
      'color': Color(0xFF42A5F5),
    },
    {
      'key': 'bond',
      'title': '情感羁绊',
      'desc': '与重要之人的温暖交集',
      'icon': Icons.favorite,
      'color': Color(0xFFEC407A),
    },
    {
      'key': 'goal',
      'title': '人生目标',
      'desc': '每一个努力达成的小成就',
      'icon': Icons.track_changes,
      'color': Color(0xFFAB47BC),
    },
    {
      'key': 'moment',
      'title': '日常小确幸',
      'desc': '平凡生活中的闪光时刻',
      'icon': Icons.auto_awesome,
      'color': Color(0xFFFFCA28),
    },
  ];

  final _titleController = TextEditingController();
  final _aiSummaryController = TextEditingController();
  final _chatInputController = TextEditingController();

  int _rangeIndex = 0;
  DateTimeRange? _customRange;
  bool _loadingSummary = true;
  bool _generating = false;
  bool _sendingChat = false;
  final List<Map<String, String>> _chatMessages = [];
  List<ChronicleModuleSummary> _summaries = const [];
  Map<String, bool> _moduleSelection = {};

  @override
  void initState() {
    super.initState();
    _moduleSelection = {
      'food': true,
      'travel': true,
      'moment': true,
      'bond': false,
      'goal': false,
    };
    _refreshSummary();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _aiSummaryController.dispose();
    _chatInputController.dispose();
    super.dispose();
  }

  DateTimeRange _currentRange() {
    final now = DateTime.now();
    if (_rangeIndex == 2 && _customRange != null) {
      return _customRange!;
    }
    if (_rangeIndex == 0) {
      return DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 12, 31),
      );
    }
    final end = DateTime(now.year, now.month, now.day);
    final start = end.subtract(const Duration(days: 365 * 3 - 1));
    return DateTimeRange(start: start, end: end);
  }

  String _formatDate(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${date.year}.${two(date.month)}.${two(date.day)}';
  }

  Set<String> _selectedModules() {
    return _moduleSelection.entries.where((e) => e.value).map((e) => e.key).toSet();
  }

  Future<void> _pickCustomRange() async {
    final initial = _customRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('zh', 'CN'),
    );
    if (picked == null) return;
    setState(() {
      _customRange = picked;
      _rangeIndex = 2;
    });
    _refreshSummary();
  }

  Future<void> _sendChatMessage() async {
    final input = _chatInputController.text.trim();
    if (input.isEmpty) return;

    final chatService = ref.read(activeChatServiceProvider);
    if (chatService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在"AI模型管理"中配置对话服务')),
      );
      return;
    }

    setState(() {
      _sendingChat = true;
      _chatMessages.add({'role': 'user', 'content': input});
      _chatInputController.clear();
    });

    try {
      final range = _currentRange();
      final selectedModules = _selectedModules();
      final moduleInfo = _summaries
          .where((s) => selectedModules.contains(s.key))
          .map((s) => '${s.title}(${s.count}条记录)')
          .join('、');

      final systemPrompt = '''你是人生编年史助手，帮助用户整理和总结人生记忆。
当前编年史配置：
- 时间范围：${_formatDate(range.start)} - ${_formatDate(range.end)}
- 选中模块：$moduleInfo

请根据用户的输入，帮助他们：
1. 挖掘记忆中的亮点和主题
2. 提炼人生感悟和成长轨迹
3. 为编年史生成有意义的总结

回复要简洁有温度，不超过200字。''';

      final messages = _chatMessages.map((m) => ai_service.ChatMessage(role: m['role']!, content: m['content']!)).toList();

      final response = await chatService.chat(
        systemPrompt: systemPrompt,
        messages: messages,
      );

      if (!mounted) return;
      setState(() {
        _chatMessages.add({'role': 'assistant', 'content': response});
        _aiSummaryController.text = response;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI对话失败：$e')),
      );
    } finally {
      if (mounted) {
        setState(() => _sendingChat = false);
      }
    }
  }

  Future<void> _refreshSummary() async {
    setState(() => _loadingSummary = true);
    final range = _currentRange();
    final db = ref.read(appDatabaseProvider);
    final content = await _collectChronicleData(db, range, _selectedModules());
    if (!mounted) return;
    setState(() {
      _summaries = content.moduleSummaries;
      _loadingSummary = false;
      _aiSummaryController.text = content.aiSummary;
    });
  }

  List<String> _parseImagePaths(String? imagesJson) {
    if (imagesJson == null || imagesJson.trim().isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(imagesJson);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint('解析图片路径JSON失败: $e');
    }
    return const [];
  }

  Future<ChronicleGeneratedContent> _collectChronicleData(
    AppDatabase db,
    DateTimeRange range,
    Set<String> modules,
  ) async {
    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final endExclusive = DateTime(range.end.year, range.end.month, range.end.day).add(const Duration(days: 1));
    final summaries = <ChronicleModuleSummary>[];
    final recordDetails = <ChronicleRecordDetail>[];

    Future<List<FoodRecord>> foods() {
      return (db.select(db.foodRecords)
            ..where((t) => t.isDeleted.equals(false))
            ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
            ..where((t) => t.recordDate.isSmallerThanValue(endExclusive)))
          .get();
    }

    Future<List<TravelRecord>> travels() {
      return (db.select(db.travelRecords)
            ..where((t) => t.isDeleted.equals(false))
            ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
            ..where((t) => t.recordDate.isSmallerThanValue(endExclusive)))
          .get();
    }

    Future<List<MomentRecord>> moments() {
      return (db.select(db.momentRecords)
            ..where((t) => t.isDeleted.equals(false))
            ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
            ..where((t) => t.recordDate.isSmallerThanValue(endExclusive)))
          .get();
    }

    Future<List<FriendRecord>> friends() {
      return (db.select(db.friendRecords)
            ..where((t) => t.isDeleted.equals(false))
            ..where((t) => t.updatedAt.isBiggerOrEqualValue(start))
            ..where((t) => t.updatedAt.isSmallerThanValue(endExclusive)))
          .get();
    }

    Future<List<TimelineEvent>> events(String type) {
      return (db.select(db.timelineEvents)
            ..where((t) => t.isDeleted.equals(false))
            ..where((t) => t.eventType.equals(type))
            ..where((t) => t.recordDate.isBiggerOrEqualValue(start))
            ..where((t) => t.recordDate.isSmallerThanValue(endExclusive)))
          .get();
    }

    if (modules.contains('food')) {
      final records = await foods();
      summaries.add(
        ChronicleModuleSummary(
          key: 'food',
          title: '美食',
          count: records.length,
          highlights: records.map((e) => e.title).where((e) => e.trim().isNotEmpty).take(3).toList(),
        ),
      );
      for (final record in records) {
        final locationParts = <String>[];
        if (record.poiName != null && record.poiName!.trim().isNotEmpty) {
          locationParts.add(record.poiName!);
        }
        if (record.poiAddress != null && record.poiAddress!.trim().isNotEmpty) {
          locationParts.add(record.poiAddress!);
        }
        if (record.city != null && record.city!.trim().isNotEmpty) {
          locationParts.add(record.city!);
        }
        recordDetails.add(
          ChronicleRecordDetail(
            id: record.id,
            moduleType: 'food',
            title: record.title,
            content: record.content ?? '',
            recordDate: record.recordDate,
            imagePaths: _parseImagePaths(record.images),
            rating: record.rating,
            location: locationParts.isNotEmpty ? locationParts.join(' · ') : null,
          ),
        );
      }
    }
    if (modules.contains('travel')) {
      final records = await travels();
      summaries.add(
        ChronicleModuleSummary(
          key: 'travel',
          title: '旅行',
          count: records.length,
          highlights: records
              .map((e) => (e.title ?? '').trim().isNotEmpty ? (e.title ?? '').trim() : (e.destination ?? '').trim())
              .where((e) => e.trim().isNotEmpty)
              .take(3)
              .toList(),
        ),
      );
      for (final record in records) {
        final title = (record.title ?? '').trim().isNotEmpty ? (record.title ?? '') : (record.destination ?? '');
        recordDetails.add(
          ChronicleRecordDetail(
            id: record.id,
            moduleType: 'travel',
            title: title,
            content: record.content ?? '',
            recordDate: record.recordDate,
            imagePaths: _parseImagePaths(record.images),
            destination: record.destination,
            mood: record.mood,
          ),
        );
      }
    }
    if (modules.contains('moment')) {
      final records = await moments();
      summaries.add(
        ChronicleModuleSummary(
          key: 'moment',
          title: '小确幸',
          count: records.length,
          highlights: records.map((e) => (e.content ?? '').trim()).where((e) => e.isNotEmpty).take(3).toList(),
        ),
      );
      for (final record in records) {
        recordDetails.add(
          ChronicleRecordDetail(
            id: record.id,
            moduleType: 'moment',
            title: '小确幸',
            content: record.content ?? '',
            recordDate: record.recordDate,
            imagePaths: _parseImagePaths(record.images),
            mood: record.mood,
          ),
        );
      }
    }
    if (modules.contains('bond')) {
      final records = await friends();
      summaries.add(
        ChronicleModuleSummary(
          key: 'bond',
          title: '羁绊',
          count: records.length,
          highlights: records.map((e) => e.name).where((e) => e.trim().isNotEmpty).take(3).toList(),
        ),
      );
      for (final record in records) {
        recordDetails.add(
          ChronicleRecordDetail(
            id: record.id,
            moduleType: 'bond',
            title: record.name,
            content: record.impressionTags ?? '',
            recordDate: record.updatedAt,
            friendName: record.name,
          ),
        );
      }
    }
    if (modules.contains('goal')) {
      final records = await events('goal');
      summaries.add(
        ChronicleModuleSummary(
          key: 'goal',
          title: '目标',
          count: records.length,
          highlights: records.map((e) => e.title.trim()).where((e) => e.isNotEmpty).take(3).toList(),
        ),
      );
      for (final record in records) {
        recordDetails.add(
          ChronicleRecordDetail(
            id: record.id,
            moduleType: 'goal',
            title: record.title,
            content: record.note ?? '',
            recordDate: record.recordDate,
          ),
        );
      }
    }
    if (modules.contains('encounter')) {
      final records = await events('encounter');
      for (final record in records) {
        recordDetails.add(
          ChronicleRecordDetail(
            id: record.id,
            moduleType: 'encounter',
            title: record.title,
            content: record.note ?? '',
            recordDate: record.recordDate,
            eventSummary: record.note,
          ),
        );
      }
    }
    final aiSummary = _buildAiSummary(range, summaries);
    return ChronicleGeneratedContent(
      rangeStart: range.start,
      rangeEnd: range.end,
      moduleSummaries: summaries,
      aiSummary: aiSummary,
      recordDetails: recordDetails,
    );
  }

  String _buildAiSummary(DateTimeRange range, List<ChronicleModuleSummary> summaries) {
    final total = summaries.fold<int>(0, (prev, e) => prev + e.count);
    final summaryLines = <String>[
      '时间范围：${_formatDate(range.start)} - ${_formatDate(range.end)}',
      '共整理 $total 条记录，覆盖 ${summaries.length} 个模块。',
    ];
    for (final item in summaries) {
      final highlights = item.highlights.isEmpty ? '暂无代表内容' : '代表内容：${item.highlights.join('、')}';
      summaryLines.add('${item.title}：${item.count} 条，$highlights');
    }
    return summaryLines.join('\n');
  }

  Future<_ChronicleExportResult> _exportChronicle(
    String title,
    DateTimeRange range,
    String aiSummary,
    List<ChronicleModuleSummary> summaries,
    List<ChronicleRecordDetail> recordDetails,
  ) async {
    final exportDir = await chronicleExportDir();
    if (exportDir == null) {
      return const _ChronicleExportResult(pdfPath: '', epubPath: '');
    }
    final safeTitle = _safeFileName(title);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final pdfPath = p.join(exportDir.path, '$safeTitle-$stamp.pdf');
    final epubPath = p.join(exportDir.path, '$safeTitle-$stamp.epub');

    final pdfBytes = await _buildPdfBytes(title, range, aiSummary, summaries, recordDetails);
    await File(pdfPath).writeAsBytes(pdfBytes, flush: true);

    final epubBytes = await _buildEpubBytes(title, range, aiSummary, summaries);
    await File(epubPath).writeAsBytes(epubBytes, flush: true);

    return _ChronicleExportResult(pdfPath: pdfPath, epubPath: epubPath);
  }

  pw.Page _buildPdfCoverPage(
    String title,
    DateTimeRange range,
  ) {
    const primaryColor = PdfColor.fromInt(0xFF2BCDEE);
    const lightPrimaryColor = PdfColor.fromInt(0xFFE6F9FC);
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Container(
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              begin: pw.Alignment.topCenter,
              end: pw.Alignment.bottomCenter,
              colors: [lightPrimaryColor, PdfColors.white],
            ),
          ),
          child: pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Container(
                  width: 120,
                  height: 120,
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Icon(
                      const pw.IconData(0xe5ee),
                      size: 72,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  '${_formatDate(range.start)} - ${_formatDate(range.end)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 60),
                pw.Text(
                  '人生编年史',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  pw.Widget _buildBarChart(List<ChronicleModuleSummary> summaries) {
    final colors = [
      PdfColor(0xFF, 0xA7, 0x26),
      PdfColor(0x42, 0xA5, 0xF5),
      PdfColor(0xEC, 0x40, 0x7A),
      PdfColor(0xAB, 0x47, 0xBC),
      PdfColor(0xFF, 0xCA, 0x28),
    ];
    
    final maxCount = summaries.isEmpty ? 1 : summaries.fold<int>(0, (max, s) => s.count > max ? s.count : max);
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('模块记录统计 - 柱状图', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Container(
          width: 400,
          height: 200,
          child: pw.CustomPaint(
            painter: (canvas, size) {
              final startX = 50.0;
              final startY = size.y - 30.0;
              final barWidth = 60.0;
              final spacing = 20.0;
              
              for (var i = 0; i < summaries.length; i++) {
                final x = startX + i * (barWidth + spacing);
                final height = (summaries[i].count / maxCount) * (size.y - 60.0);
                final y = startY - height;
                
                canvas.drawRect(x, y, barWidth, height);
                canvas.setFillColor(colors[i % colors.length]);
                canvas.fillPath();
              }
            },
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: summaries.asMap().entries.map((entry) {
            final i = entry.key;
            final summary = entry.value;
            return pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Container(
                    width: 20,
                    height: 20,
                    decoration: pw.BoxDecoration(color: colors[i % colors.length]),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(summary.title, style: pw.TextStyle(fontSize: 10)),
                  pw.Text('${summary.count}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildPieChart(List<ChronicleModuleSummary> summaries) {
    final colors = [
      PdfColor(0xFF, 0xA7, 0x26),
      PdfColor(0x42, 0xA5, 0xF5),
      PdfColor(0xEC, 0x40, 0x7A),
      PdfColor(0xAB, 0x47, 0xBC),
      PdfColor(0xFF, 0xCA, 0x28),
    ];
    
    final total = summaries.fold<int>(0, (sum, s) => sum + s.count);
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('模块记录统计 - 饼图', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 200,
              height: 200,
              child: pw.CustomPaint(
                painter: (canvas, size) {
                  final centerX = size.x / 2;
                  final centerY = size.y / 2;
                  final radius = 80.0;
                  var startAngle = 0.0;
                  
                  for (var i = 0; i < summaries.length; i++) {
                    final sweepAngle = (summaries[i].count / total) * 2 * 3.14159;
                    
                    canvas.moveTo(centerX, centerY);
                    for (var angle = startAngle; angle <= startAngle + sweepAngle; angle += 0.01) {
                      final x = centerX + radius * math.cos(angle);
                      final y = centerY + radius * math.sin(angle);
                      canvas.lineTo(x, y);
                    }
                    canvas.closePath();
                    canvas.setFillColor(colors[i % colors.length]);
                    canvas.fillPath();
                    
                    startAngle += sweepAngle;
                  }
                },
              ),
            ),
            pw.SizedBox(width: 20),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: summaries.asMap().entries.map((entry) {
                final i = entry.key;
                final summary = entry.value;
                final percentage = total == 0 ? 0 : (summary.count / total * 100).toStringAsFixed(1);
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 16,
                        height: 16,
                        decoration: pw.BoxDecoration(color: colors[i % colors.length]),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text('${summary.title}: ${summary.count} ($percentage%)', style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildImageGrid(List<ChronicleRecordDetail> recordDetails) {
    final imageWidgets = <pw.Widget>[];
    final maxImages = 12;
    var imageCount = 0;

    for (final record in recordDetails) {
      if (imageCount >= maxImages) break;
      for (final imagePath in record.imagePaths) {
        if (imageCount >= maxImages) break;
        try {
          final file = File(imagePath);
          if (file.existsSync()) {
            final bytes = file.readAsBytesSync();
            imageWidgets.add(
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      height: 80,
                      width: double.infinity,
                      child: pw.Image(
                        pw.MemoryImage(bytes),
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            _formatDate(record.recordDate),
                            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            record.title.isNotEmpty ? record.title : '记录',
                            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
            imageCount++;
          }
        } catch (e) {
          debugPrint('处理图片失败: $e');
          imageWidgets.add(
            pw.Container(
              height: 120,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Icon(
                    const pw.IconData(0xe04f),
                    size: 32,
                    color: PdfColors.grey400,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '加载失败',
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                  ),
                ],
              ),
            ),
          );
          imageCount++;
        }
      }
    }

    if (imageWidgets.isEmpty) {
      return pw.Container();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '精彩瞬间',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.GridView(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
          children: imageWidgets,
        ),
      ],
    );
  }

  pw.Widget _buildModuleChapter(
    ChronicleModuleSummary summary,
    List<ChronicleRecordDetail> moduleRecords,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 48,
              height: 48,
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF2BCDEE),
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(
                child: pw.Icon(
                  const pw.IconData(0xe5ee),
                  size: 28,
                  color: PdfColors.white,
                ),
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  summary.title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF2BCDEE),
                  ),
                ),
                pw.Text(
                  '共 ${summary.count} 条记录',
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        if (summary.highlights.isNotEmpty) ...[
          pw.Text(
            '精选内容',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: summary.highlights.map((highlight) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Bullet(text: highlight),
              );
            }).toList(),
          ),
          pw.SizedBox(height: 20),
        ],
        if (moduleRecords.isNotEmpty) ...[
          pw.Text(
            '记录列表',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: moduleRecords.take(10).map((record) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            record.title.isNotEmpty ? record.title : '记录',
                            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            _formatDate(record.recordDate),
                            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                      if (record.content.isNotEmpty) ...[
                        pw.SizedBox(height: 6),
                        pw.Text(
                          record.content,
                          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                          maxLines: 3,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          pw.SizedBox(height: 20),
        ],
        _buildImageGrid(moduleRecords),
      ],
    );
  }

  pw.Page _buildPdfClosingPage(
    String title,
    List<ChronicleModuleSummary> summaries,
  ) {
    const primaryColor = PdfColor.fromInt(0xFF2BCDEE);
    const lightPrimaryColor = PdfColor.fromInt(0xFFE6F9FC);
    
    final totalRecords = summaries.fold<int>(0, (sum, s) => sum + s.count);
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Container(
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              begin: pw.Alignment.topCenter,
              end: pw.Alignment.bottomCenter,
              colors: [lightPrimaryColor, PdfColors.white],
            ),
          ),
          child: pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Container(
                  width: 120,
                  height: 120,
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Icon(
                      const pw.IconData(0xe5ee),
                      size: 72,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  '共收录 $totalRecords 条珍贵记忆',
                  style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 40),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(16),
                    boxShadow: [
                      pw.BoxShadow(
                        color: PdfColors.grey300,
                        blurRadius: 10,
                        offset: const PdfPoint(0, 4),
                      ),
                    ],
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        '感谢您使用人生编年史',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        '愿这些珍贵的回忆，成为您人生中最美好的珍藏。',
                        style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 60),
                pw.Text(
                  '人生编年史',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  pw.Page _buildPdfConclusionPage(
    String title,
    DateTimeRange range,
  ) {
    const primaryColor = PdfColor.fromInt(0xFF2BCDEE);
    const lightPrimaryColor = PdfColor.fromInt(0xFFE6F9FC);
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Container(
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              begin: pw.Alignment.topCenter,
              end: pw.Alignment.bottomCenter,
              colors: [PdfColors.white, lightPrimaryColor],
            ),
          ),
          child: pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Container(
                  width: 100,
                  height: 100,
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Icon(
                      const pw.IconData(0xe5ca),
                      size: 60,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  '感谢阅读',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  '每一次记录，都是对生活的热爱',
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.grey700,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 60),
                pw.Text(
                  '人生编年史',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<int>> _buildPdfBytes(
    String title,
    DateTimeRange range,
    String aiSummary,
    List<ChronicleModuleSummary> summaries,
    List<ChronicleRecordDetail> recordDetails,
  ) async {
    final doc = pw.Document();
    
    doc.addPage(_buildPdfCoverPage(title, range));
    
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Text('总览', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text('时间范围：${_formatDate(range.start)} - ${_formatDate(range.end)}'),
            pw.SizedBox(height: 14),
            pw.Text('AI 总结', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text(aiSummary.isEmpty ? '暂无内容' : aiSummary),
            pw.SizedBox(height: 14),
            pw.Text('数据可视化', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            if (summaries.isNotEmpty) ...[
              _buildBarChart(summaries),
              pw.SizedBox(height: 20),
              _buildPieChart(summaries),
            ],
          ];
          return widgets;
        },
      ),
    );
    
    for (final summary in summaries) {
      final moduleRecords = recordDetails
          .where((record) => record.moduleType == summary.key)
          .toList();
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return [_buildModuleChapter(summary, moduleRecords)];
          },
        ),
      );
    }
    
    doc.addPage(_buildPdfClosingPage(title, summaries));
    doc.addPage(_buildPdfConclusionPage(title, range));
    
    return doc.save();
  }

  Future<List<int>> _buildEpubBytes(
    String title,
    DateTimeRange range,
    String aiSummary,
    List<ChronicleModuleSummary> summaries,
  ) async {
    final chapters = <epub.EpubChapter>[];
    
    final coverBuffer = StringBuffer();
    coverBuffer.writeln('<div style="text-align: center; padding-top: 100px;">');
    coverBuffer.writeln('<h1 style="font-size: 36px; color: #2BCDEE;">${_escapeHtml(title)}</h1>');
    coverBuffer.writeln('<p style="font-size: 18px; color: #666; margin-top: 20px;">时间范围：${_escapeHtml(_formatDate(range.start))} - ${_escapeHtml(_formatDate(range.end))}</p>');
    coverBuffer.writeln('<p style="font-size: 24px; color: #2BCDEE; margin-top: 100px;">人生编年史</p>');
    coverBuffer.writeln('</div>');
    
    chapters.add(
      epub.EpubChapter()
        ..Title = '封面'
        ..HtmlContent = coverBuffer.toString()
    );
    
    final overviewBuffer = StringBuffer();
    overviewBuffer.writeln('<h1>总览</h1>');
    overviewBuffer.writeln('<p>时间范围：${_escapeHtml(_formatDate(range.start))} - ${_escapeHtml(_formatDate(range.end))}</p>');
    overviewBuffer.writeln('<h2>AI 总结</h2>');
    overviewBuffer.writeln('<p>${_escapeHtml(aiSummary.isEmpty ? '暂无内容' : aiSummary).replaceAll('\n', '<br/>')}</p>');
    
    chapters.add(
      epub.EpubChapter()
        ..Title = '总览'
        ..HtmlContent = overviewBuffer.toString()
    );
    
    for (final summary in summaries) {
      final chapterBuffer = StringBuffer();
      chapterBuffer.writeln('<h1>${_escapeHtml(summary.title)}</h1>');
      chapterBuffer.writeln('<p>共 ${summary.count} 条记录</p>');
      chapterBuffer.writeln('<h2>代表内容</h2>');
      if (summary.highlights.isEmpty) {
        chapterBuffer.writeln('<p>暂无代表内容</p>');
      } else {
        chapterBuffer.writeln('<ul>');
        for (final item in summary.highlights) {
          chapterBuffer.writeln('<li>${_escapeHtml(item)}</li>');
        }
        chapterBuffer.writeln('</ul>');
      }
      
      chapters.add(
        epub.EpubChapter()
          ..Title = summary.title
          ..HtmlContent = chapterBuffer.toString()
      );
    }
    
    final conclusionBuffer = StringBuffer();
    conclusionBuffer.writeln('<div style="text-align: center; padding-top: 100px;">');
    conclusionBuffer.writeln('<h1 style="font-size: 36px; color: #2BCDEE;">感谢阅读</h1>');
    conclusionBuffer.writeln('<p style="font-size: 18px; color: #666; margin-top: 20px;">每一次记录，都是对生活的热爱</p>');
    conclusionBuffer.writeln('<p style="font-size: 24px; color: #2BCDEE; margin-top: 100px;">人生编年史</p>');
    conclusionBuffer.writeln('</div>');
    
    chapters.add(
      epub.EpubChapter()
        ..Title = '结语'
        ..HtmlContent = conclusionBuffer.toString()
    );
    
    final book = epub.EpubBook()
      ..Title = title
      ..Author = '人生编年史'
      ..Chapters = chapters;
      
    return epub.EpubWriter.writeBook(book) ?? <int>[];
  }

  String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  Future<void> _generateChronicle() async {
    if (_generating) return;
    final selected = _selectedModules();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('至少选择一个模块')));
      return;
    }
    
    await amapInfo('编年史', '开始生成编年史, 选中模块: ${selected.join(", ")}');
    setState(() => _generating = true);
    try {
      final range = _currentRange();
      await amapDebug('编年史', '时间范围: ${_formatDate(range.start)} 至 ${_formatDate(range.end)}');
      
      final db = ref.read(appDatabaseProvider);
      await amapDebug('编年史', '开始收集编年史数据...');
      final content = await _collectChronicleData(db, range, selected);
      await amapDebug('编年史', '数据收集完成, 模块摘要数: ${content.moduleSummaries.length}, 记录详情数: ${content.recordDetails.length}');
      
      final title = _titleController.text.trim().isEmpty
          ? '${_formatDate(range.start)}-${_formatDate(range.end)} 编年史'
          : _titleController.text.trim();
      final aiSummary = _aiSummaryController.text.trim().isEmpty ? content.aiSummary : _aiSummaryController.text.trim();
      
      await amapDebug('编年史', '开始导出编年史文件, 标题: $title');
      final exportResult = await _exportChronicle(title, range, aiSummary, content.moduleSummaries, content.recordDetails);
      await amapInfo('编年史', '导出完成, PDF路径: ${exportResult.pdfPath}, EPUB路径: ${exportResult.epubPath}');
      
      final stats = {for (final item in content.moduleSummaries) item.title: item.count};
      final record = ChronicleRecord(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        rangeStart: range.start,
        rangeEnd: range.end,
        createdAt: DateTime.now(),
        modules: [for (final key in selected) key],
        stats: stats,
        aiSummary: aiSummary,
        userSummary: '',
        pdfPath: exportResult.pdfPath,
        epubPath: exportResult.epubPath,
        isFeatured: false,
      );
      final records = await loadChronicleRecords();
      final updated = [record, ...records];
      await saveChronicleRecords(updated);
      await amapInfo('编年史', '编年史生成成功并保存, ID: ${record.id}');
      
      if (!mounted) return;
      setState(() => _generating = false);
      RouteNavigation.goToChronicleManage(context);
    } catch (e, stack) {
      await amapError('编年史', '生成失败: $e\n$stack');
      if (mounted) {
        setState(() => _generating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败：$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = AppTheme.primary;
    const backgroundLight = AppTheme.backgroundLight;
    const surface = AppTheme.surface;
    const textMain = AppTheme.textMain;
    const textMuted = AppTheme.textMuted;
    
    final range = _currentRange();
    
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: textMain),
                      splashRadius: 22,
                    ),
                    const SizedBox(width: 8),
                    Text('定格时光', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textMain)),
                  ],
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.only(top: 70, left: 16, right: 16, bottom: 100),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('选择您想珍藏的记忆片段，生成专属编年史。', style: TextStyle(fontSize: 14, color: textMuted)),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text('1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primary)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('时间胶囊', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textMain)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var i = 0; i < _rangeOptions.length; i++) ...[
                              _RangeChip(
                                label: _rangeOptions[i],
                                selected: _rangeIndex == i,
                                onTap: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  if (i == 2) {
                                    _pickCustomRange();
                                  } else {
                                    setState(() => _rangeIndex = i);
                                    _refreshSummary();
                                  }
                                },
                              ),
                              if (i < _rangeOptions.length - 1) const SizedBox(width: 12),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text('开始日期', style: TextStyle(fontSize: 12, color: textMuted)),
                                  const SizedBox(height: 4),
                                  Text(_formatDate(range.start), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textMain)),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: const Color(0xFFE2E8F0),
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text('结束日期', style: TextStyle(fontSize: 12, color: textMuted)),
                                  const SizedBox(height: 4),
                                  Text(_formatDate(range.end), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textMain)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text('2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primary)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('记忆碎片', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textMain)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          for (var i = 0; i < _modules.length; i++) ...[
                            _ModuleItem(
                              module: _modules[i],
                              selected: _moduleSelection[_modules[i]['key']] ?? false,
                              count: _summaries.where((s) => s.key == _modules[i]['key']).firstOrNull?.count,
                              onTap: () {
                                setState(() {
                                  final key = _modules[i]['key'] as String;
                                  _moduleSelection[key] = !(_moduleSelection[key] ?? false);
                                });
                                _refreshSummary();
                              },
                            ),
                            if (i < _modules.length - 1) const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text('3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primary)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('AI 互动', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textMain)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 240),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.auto_awesome, color: primary, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      '你好！我已经准备好为你生成 ${_rangeOptions[_rangeIndex]} 的编年史。关于这些记忆，你有什么特别想强调的主题吗？',
                                      style: TextStyle(fontSize: 14, color: textMain),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _chatInputController,
                                decoration: InputDecoration(
                                  hintText: '与 AI 助手讨论...',
                                  hintStyle: TextStyle(color: textMuted),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                style: TextStyle(fontSize: 14, color: textMain),
                                onSubmitted: _sendingChat ? null : (_) => _sendChatMessage(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_sendingChat)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                              )
                            else
                              IconButton(
                                icon: Icon(Icons.send, color: primary),
                                onPressed: _sendChatMessage,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, color: primary, size: 20),
                          const SizedBox(width: 8),
                          Text('AI 总结', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textMain)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_loadingSummary)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                            ),
                          ),
                        )
                      else
                        Stack(
                          children: [
                            TextField(
                              controller: _aiSummaryController,
                              maxLines: 6,
                              decoration: InputDecoration(
                                hintText: 'AI 生成的总结将显示在这里...',
                                hintStyle: TextStyle(color: textMuted),
                                filled: true,
                                fillColor: const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              style: TextStyle(fontSize: 14, color: textMain, height: 1.5),
                            ),
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Icon(Icons.edit, color: textMuted, size: 18),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('编年史标题', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textMain)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: '给你的编年史起个名字...',
                          hintStyle: TextStyle(color: textMuted),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: TextStyle(fontSize: 14, color: textMain),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: surface.withValues(alpha: 0.8),
                  border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0))),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 12,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          color: const Color(0xFF64748B),
                          onPressed: () => Navigator.of(context).maybePop(),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      Text('生成配置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textMain)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: surface.withValues(alpha: 0.9),
                  border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
                ),
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: 16 + MediaQuery.paddingOf(context).bottom,
                ),
                child: ElevatedButton(
                  onPressed: _generating ? null : _generateChronicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: _generating
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_stories, size: 22),
                            const SizedBox(width: 8),
                            const Text('生成人生编年史', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const primary = AppTheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? Colors.transparent : const Color(0xFFE2E8F0)),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 0),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _ModuleItem extends StatelessWidget {
  const _ModuleItem({required this.module, required this.selected, this.count, required this.onTap});

  final Map<String, dynamic> module;
  final bool selected;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const primary = AppTheme.primary;
    const textMain = AppTheme.textMain;
    const textMuted = AppTheme.textMuted;
    
    final iconColor = module['color'] as Color;
    final iconBgColor = iconColor.withValues(alpha: 0.1);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? primary.withValues(alpha: 0.3) : const Color(0xFFE2E8F0)),
          color: selected ? primary.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(module['icon'] as IconData, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(module['title'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textMain)),
                      if (count != null && count! > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: primary)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(module['desc'] as String, style: TextStyle(fontSize: 12, color: textMuted)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 24,
              height: 24,
              child: Stack(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: selected ? primary : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  if (selected)
                    Center(
                      child: Icon(Icons.check, color: Colors.white, size: 16),
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

class _ChronicleExportResult {
  const _ChronicleExportResult({required this.pdfPath, required this.epubPath});

  final String pdfPath;
  final String epubPath;
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
  static const _categories = ['全部', '美食', '旅行', '小确幸', '目标', '羁绊', '相遇'];
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

  Future<void> _unfavoriteSelected(AppDatabase db, List<_FavoriteItem> allItems) async {
    if (_selectedIds.isEmpty) return;
    final now = DateTime.now();
    final selectedItems = allItems.where((item) => _selectedIds.contains(item.id)).toList();
    
    for (final item in selectedItems) {
      final id = item.id;
      if (id.startsWith('food-')) {
        await db.foodDao.updateFavorite(id.substring(5), isFavorite: false, now: now);
      } else if (id.startsWith('travel-')) {
        await (db.update(db.travelRecords)..where((t) => t.id.equals(id.substring(7)))).write(
          TravelRecordsCompanion(isFavorite: const Value(false), updatedAt: Value(now)),
        );
      } else if (id.startsWith('moment-')) {
        await db.momentDao.updateFavorite(id.substring(7), isFavorite: false, now: now);
      } else if (id.startsWith('bond-')) {
        await db.friendDao.updateFavorite(id.substring(5), isFavorite: false, now: now);
      } else if (id.startsWith('goal-')) {
        await db.updateGoalFavorite(id.substring(5), isFavorite: false, now: now);
      } else if (id.startsWith('encounter-')) {
        await db.updateEncounterFavorite(id.substring(10), isFavorite: false, now: now);
      }
    }
    
    setState(() {
      _selectedIds.clear();
      _selectionMode = false;
    });
  }

  Future<void> _exportToPdf(List<_FavoriteItem> allItems) async {
    if (_selectedIds.isEmpty) return;
    
    final selectedItems = allItems.where((item) => _selectedIds.contains(item.id)).toList();
    
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  '我的收藏',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              ...selectedItems.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        item.category,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      item.title,
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${item.tag} · ${_formatDate(item.date)}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    ),
                    pw.Divider(),
                  ],
                ),
              )),
            ];
          },
        ),
      );
      
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/收藏导出_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF已保存到: ${file.path}')),
        );
      }
      
      setState(() {
        _selectedIds.clear();
        _selectionMode = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<String> _parseStringList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toList(growable: false);
      }
    } catch (e) {
      debugPrint('解析字符串列表失败: $e');
    }
    return const [];
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }

  void _navigateToDetail(BuildContext context, String id) async {
    if (id.startsWith('food-')) {
      RouteNavigation.goToFoodDetail(context, id.substring(5));
    } else if (id.startsWith('travel-')) {
      final db = ref.read(appDatabaseProvider);
      final travelId = id.substring(7);
      final travel = await (db.select(db.travelRecords)..where((t) => t.id.equals(travelId))).getSingleOrNull();
      if (travel == null || !context.mounted) return;
      RouteNavigation.goToTravelDetail(context, travel.id, item: TravelItem(
        travelId: travel.id,
        tripId: '',
        recordDate: travel.recordDate,
        date: '${travel.recordDate.year}年${travel.recordDate.month}月${travel.recordDate.day}日',
        title: travel.title ?? '',
        subtitle: travel.destination ?? '',
        imageUrl: _parseStringList(travel.images).firstOrNull ?? '',
      ));
    } else if (id.startsWith('moment-')) {
      RouteNavigation.goToMomentDetail(context, id.substring(7));
    } else if (id.startsWith('bond-')) {
      RouteNavigation.goToFriendProfile(context, id.substring(5));
    } else if (id.startsWith('goal-')) {
      final db = ref.read(appDatabaseProvider);
      final goalId = id.substring(5);
      final goal = await (db.select(db.goalRecords)..where((t) => t.id.equals(goalId))).getSingleOrNull();
      if (goal == null || !context.mounted) return;
      RouteNavigation.goToGoalDetail(context, goal.id, record: goal);
    } else if (id.startsWith('encounter-')) {
      RouteNavigation.goToEncounterDetail(context, id.substring(10));
    }
  }

  String _momentTitle(String? content) {
    final text = (content ?? '').trim();
    if (text.isEmpty) return '小确幸记录';
    if (text.length <= 12) return text;
    return '${text.substring(0, 12)}…';
  }

  String _goalTagFromNote(String? note) {
    final raw = (note ?? '').trim();
    if (raw.isEmpty) return '目标';
    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('分类：')) {
        final value = trimmed.substring(3).trim();
        if (value.isNotEmpty) return value;
      }
    }
    return '目标';
  }

  String _encounterTagFromRecord(TimelineEvent record) {
    final poiName = (record.poiName ?? '').trim();
    if (poiName.isNotEmpty) return poiName;
    final poiAddress = (record.poiAddress ?? '').trim();
    if (poiAddress.isNotEmpty) return poiAddress;
    final note = (record.note ?? '').trim();
    if (note.isNotEmpty) {
      for (final line in note.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.startsWith('地点：')) {
          final value = trimmed.substring(3).trim();
          if (value.isNotEmpty) return value;
        }
      }
    }
    return '相遇';
  }

  List<_FavoriteItem> _buildItems({
    required List<FoodRecord> foods,
    required List<MomentRecord> moments,
    required List<TravelRecord> travels,
    required List<FriendRecord> friends,
    required List<TimelineEvent> goals,
    required List<TimelineEvent> encounters,
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
      final scene = (record.tags ?? '').trim();
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
    for (final record in goals) {
      if (!record.isFavorite) continue;
      final title = record.title.trim();
      items.add(
        _FavoriteItem(
          id: 'goal-${record.id}',
          title: title.isNotEmpty ? title : '人生目标',
          category: '目标',
          date: record.recordDate,
          tag: _goalTagFromNote(record.note),
          tagColor: const Color(0xFFF3E8FF),
          tagTextColor: const Color(0xFF9333EA),
          imageUrl: _fallbackImageUrl,
        ),
      );
    }
    for (final record in encounters) {
      if (!record.isFavorite) continue;
      final title = record.title.trim();
      items.add(
        _FavoriteItem(
          id: 'encounter-${record.id}',
          title: title.isNotEmpty ? title : '相遇记录',
          category: '相遇',
          date: record.recordDate,
          tag: _encounterTagFromRecord(record),
          tagColor: const Color(0xFFE0F2FE),
          tagTextColor: const Color(0xFF0284C7),
          imageUrl: _fallbackImageUrl,
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
                      final goalsStream = (db.select(db.timelineEvents)
                            ..where((t) => t.eventType.equals('goal'))
                            ..where((t) => t.isDeleted.equals(false))
                            ..orderBy([(t) => OrderingTerm(expression: t.recordDate, mode: OrderingMode.desc)]))
                          .watch();
                      final encountersStream = db.watchEncounterEvents();
                      return StreamBuilder<List<TimelineEvent>>(
                        stream: goalsStream,
                        builder: (context, goalSnapshot) {
                          final goals = goalSnapshot.data ?? const <TimelineEvent>[];
                          return StreamBuilder<List<TimelineEvent>>(
                            stream: encountersStream,
                            builder: (context, encounterSnapshot) {
                              final encounters = encounterSnapshot.data ?? const <TimelineEvent>[];
                              final allItems = _buildItems(
                                foods: foods,
                                moments: moments,
                                travels: travels,
                                friends: friends,
                                goals: goals,
                                encounters: encounters,
                              );
                              final items = _filterItems(allItems);
                              final foodCount = allItems.where((item) => item.category == '美食').length;
                              final travelCount = allItems.where((item) => item.category == '旅行').length;
                              final momentCount = allItems.where((item) => item.category == '小确幸').length;
                              final goalCount = allItems.where((item) => item.category == '目标').length;
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
                                                onPressed: selectedCount == 0 ? null : () => _exportToPdf(allItems),
                                                style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B), textStyle: const TextStyle(fontWeight: FontWeight.w800)),
                                                icon: const Icon(Icons.picture_as_pdf, size: 18),
                                                label: Text('导出PDF${selectedCount == 0 ? '' : ' ($selectedCount)'}'),
                                              ),
                                              const SizedBox(width: 8),
                                              TextButton.icon(
                                                onPressed: selectedCount == 0 ? null : () => _unfavoriteSelected(db, allItems),
                                                style: TextButton.styleFrom(foregroundColor: const Color(0xFFF43F5E), textStyle: const TextStyle(fontWeight: FontWeight.w800)),
                                                icon: const Icon(Icons.bookmark_remove, size: 18),
                                                label: const Text('取消收藏'),
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
                                            LayoutBuilder(
                                              builder: (context, constraints) {
                                                const spacing = 10.0;
                                                final itemWidth = (constraints.maxWidth - spacing) / 2;
                                                return Wrap(
                                                  spacing: spacing,
                                                  runSpacing: spacing,
                                                  children: [
                                                    _FavoriteSummaryChip(
                                                      width: itemWidth,
                                                      label: '美食',
                                                      count: foodCount.toString(),
                                                      color: const Color(0xFFFFEDD5),
                                                      textColor: const Color(0xFFFB923C),
                                                      onTap: () => setState(() {
                                                        _selectedCategoryIndex = 1;
                                                        _selectedIds.clear();
                                                      }),
                                                    ),
                                                    _FavoriteSummaryChip(
                                                      width: itemWidth,
                                                      label: '旅行',
                                                      count: travelCount.toString(),
                                                      color: const Color(0xFFDBEAFE),
                                                      textColor: const Color(0xFF3B82F6),
                                                      onTap: () => setState(() {
                                                        _selectedCategoryIndex = 2;
                                                        _selectedIds.clear();
                                                      }),
                                                    ),
                                                    _FavoriteSummaryChip(
                                                      width: itemWidth,
                                                      label: '小确幸',
                                                      count: momentCount.toString(),
                                                      color: const Color(0xFFFCE7F3),
                                                      textColor: const Color(0xFFEC4899),
                                                      onTap: () => setState(() {
                                                        _selectedCategoryIndex = 3;
                                                        _selectedIds.clear();
                                                      }),
                                                    ),
                                                    _FavoriteSummaryChip(
                                                      width: itemWidth,
                                                      label: '目标',
                                                      count: goalCount.toString(),
                                                      color: const Color(0xFFF3E8FF),
                                                      textColor: const Color(0xFF9333EA),
                                                      onTap: () => setState(() {
                                                        _selectedCategoryIndex = 4;
                                                        _selectedIds.clear();
                                                      }),
                                                    ),
                                                    _FavoriteSummaryChip(
                                                      width: itemWidth,
                                                      label: '相遇',
                                                      count: encounterCount.toString(),
                                                      color: const Color(0xFFE0F2FE),
                                                      textColor: const Color(0xFF0284C7),
                                                      onTap: () => setState(() {
                                                        _selectedCategoryIndex = 6;
                                                        _selectedIds.clear();
                                                      }),
                                                    ),
                                                  ],
                                                );
                                              },
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
                                              } else {
                                                _navigateToDetail(context, item.id);
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
              },
            );
          },
        );
  }
}

class ChronicleManagePage extends ConsumerStatefulWidget {
  const ChronicleManagePage({super.key});

  @override
  ConsumerState<ChronicleManagePage> createState() => _ChronicleManagePageState();
}

class _ChronicleManagePageState extends ConsumerState<ChronicleManagePage> {
  Future<void> _toggleFeatured(ChronicleRecord record) async {
    final records = await loadChronicleRecords();
    final updated = [
      for (final item in records)
        if (item.id == record.id)
          item.copyWith(isFeatured: !item.isFeatured)
        else
          item,
    ];
    await saveChronicleRecords(updated);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _shareFile(String path, String fallbackName) async {
    final file = File(path);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('文件不存在或尚未生成')));
      }
      return;
    }
    await Share.shareXFiles([XFile(file.path)], text: fallbackName);
  }

  Future<void> _exportRecord(ChronicleRecord record) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(999))),
              const SizedBox(height: 16),
              Text('导出 ${record.title}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _shareFile(record.pdfPath, '${record.title}.pdf');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('导出 PDF'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _shareFile(record.epubPath, '${record.title}.epub');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('导出 EPUB'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF2F4F6);
    const primary = Color(0xFF2563EB);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        title: const Text('编年史管理', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: () {
              RouteNavigation.goToChronicleGenerateConfig(context);
            },
            style: TextButton.styleFrom(foregroundColor: primary, textStyle: const TextStyle(fontWeight: FontWeight.w900)),
            child: const Text('生成新版本'),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<ChronicleRecord>>(
          future: loadChronicleRecords(),
          builder: (context, snapshot) {
            final records = snapshot.data ?? const [];
            return ListView(
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
                if (records.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('暂无编年史版本，请先生成。', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)))),
                  )
                else
                  for (final record in records) ...[
                    _ChronicleVersionCard(
                      record: record,
                      onPreview: () {
                        RouteNavigation.goToChroniclePreview(context, record);
                      },
                      onExport: () => _exportRecord(record),
                      onFeatureToggle: () => _toggleFeatured(record),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class ChroniclePreviewPage extends StatelessWidget {
  const ChroniclePreviewPage({super.key, required this.record});

  final ChronicleRecord record;

  @override
  Widget build(BuildContext context) {
    final range = '${_formatChronicleDate(record.rangeStart)} - ${_formatChronicleDate(record.rangeEnd)}';
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        title: const Text('编年史预览', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
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
                  Text(record.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 6),
                  Text(range, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final tag in record.modules)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(999)),
                          child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF3B82F6))),
                        ),
                      if (record.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(999)),
                          child: const Text('精选', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFF97316))),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
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
                  const Text('AI 初步分析', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 8),
                  Text(record.aiSummary.isEmpty ? '暂无内容' : record.aiSummary,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155), height: 1.5)),
                ],
              ),
            ),
            if (record.userSummary.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
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
                    const Text('我的补充', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    const SizedBox(height: 8),
                    Text(record.userSummary, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155), height: 1.5)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
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
                  const Text('模块统计', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  const SizedBox(height: 8),
                  for (final entry in record.stats.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('${entry.key} · ${entry.value} 条',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
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

class _FavoriteSummaryChip extends StatelessWidget {
  const _FavoriteSummaryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.textColor,
    this.width,
    this.onTap,
  });

  final String label;
  final String count;
  final Color color;
  final Color textColor;
  final double? width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
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
                child: AppImage(source: imageUrl, fit: BoxFit.cover),
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
    required this.record,
    required this.onPreview,
    required this.onExport,
    required this.onFeatureToggle,
  });

  final ChronicleRecord record;
  final VoidCallback onPreview;
  final VoidCallback onExport;
  final VoidCallback onFeatureToggle;

  @override
  Widget build(BuildContext context) {
    final range = '${_formatChronicleDate(record.rangeStart)} - ${_formatChronicleDate(record.rangeEnd)}';
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
                child: Text(record.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              ),
              TextButton(
                onPressed: onFeatureToggle,
                style: TextButton.styleFrom(
                  foregroundColor: record.isFeatured ? const Color(0xFFF97316) : const Color(0xFF64748B),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                ),
                child: Text(record.isFeatured ? '取消精选' : '设为精选'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(range, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final tag in record.modules)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(999)),
                  child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF3B82F6))),
                ),
              if (record.isFeatured)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(999)),
                  child: const Text('精选', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFF97316))),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  onPressed: onPreview,
                  child: const Text('预览'),
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
                  onPressed: onExport,
                  child: const Text('导出'),
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
                        onPressed: () => RouteNavigation.goToUniversalLinkAllLogs(context),
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
                        onPressed: () => RouteNavigation.goToUniversalLinkAllLogs(context),
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
                                    stream: db.travelDao.watchTripsOnly(),
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
                                    stream: db.travelDao.watchTripsOnly(),
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
    } catch (e) {
      debugPrint('解析字符串列表失败: $e');
    }
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
      final raw = (record.tags ?? '').trim();
      if (raw.isEmpty) continue;
      List<String> tags;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          tags = decoded.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList(growable: false);
        } else {
          tags = [raw];
        }
      } catch (e) {
        debugPrint('解析小确幸标签失败: $e');
        tags = [raw];
      }
      for (final tag in tags) {
        counts.update(tag, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  Map<String, int> _countTravelTags(List<TravelRecord> travels) {
    final counts = <String, int>{};
    for (final record in travels) {
      final tags = _parseStringList(record.tags);
      for (final tag in tags) {
        final key = tag.trim();
        if (key.isEmpty) continue;
        counts.update(key, (v) => v + 1, ifAbsent: () => 1);
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
      final tags = _parseStringList(record.tags);
      for (final tag in tags) {
        final key = tag.trim();
        if (key.isEmpty) continue;
        counts.update(key, (v) => v + 1, ifAbsent: () => 1);
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
    final iconNames = IconUtils.getTagIconNamesForModule(module.key);
    String selectedIcon = tag?.iconName ?? (iconNames.isNotEmpty ? iconNames.first : 'flag');
    String? selectedColor = tag?.color;
    bool showOnCalendar = tag?.showOnCalendar ?? true;

    const colorOptions = <String>[
      '#EF4444',
      '#F97316',
      '#F59E0B',
      '#EAB308',
      '#84CC16',
      '#22C55E',
      '#10B981',
      '#14B8A6',
      '#06B6D4',
      '#0EA5E9',
      '#3B82F6',
      '#6366F1',
      '#8B5CF6',
      '#A855F7',
      '#D946EF',
      '#EC4899',
      '#F43F5E',
      '#78716C',
    ];

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
                          const SizedBox(height: 16),
                          const Text('标签颜色', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => setSheetState(() => selectedColor = null),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selectedColor == null ? const Color(0xFF2BCDEE) : const Color(0xFFE5E7EB),
                                      width: selectedColor == null ? 2 : 1,
                                    ),
                                  ),
                                  child: selectedColor == null ? const Icon(Icons.close, size: 16, color: Color(0xFF9CA3AF)) : null,
                                ),
                              ),
                              for (final colorHex in colorOptions)
                                InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => setSheetState(() => selectedColor = colorHex),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: _colorFromHex(colorHex),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: selectedColor == colorHex ? const Color(0xFF2BCDEE) : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (module.key == 'moment' || module.key == 'goal') ...[
                            const SizedBox(height: 16),
                            const Text('选择图标', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final iconName in iconNames)
                                  InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => setSheetState(() => selectedIcon = iconName),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: iconName == selectedIcon ? const Color(0xFFE0F2F1) : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: iconName == selectedIcon ? const Color(0xFF2BCDEE) : const Color(0xFFE5E7EB),
                                        ),
                                      ),
                                      child: Icon(IconUtils.fromName(iconName), color: iconName == selectedIcon ? const Color(0xFF0F766E) : const Color(0xFF6B7280), size: 20),
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
                                      iconName: (module.key == 'moment' || module.key == 'goal') ? selectedIcon : null,
                                      color: selectedColor,
                                      showOnCalendar: module.key == 'moment' ? showOnCalendar : true,
                                    ),
                                  );
                                } else {
                                  final index = updatedTags.indexWhere((t) => t.id == tag.id);
                                  if (index != -1) {
                                    updatedTags[index] = tag.copyWith(
                                      name: name,
                                      iconName: (module.key == 'moment' || module.key == 'goal') ? selectedIcon : tag.iconName,
                                      color: selectedColor,
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

  Color _colorFromHex(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) {
        buffer.write('ff');
      }
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      debugPrint('解析颜色值失败: $e');
      return const Color(0xFF6B7280);
    }
  }

  Future<void> _confirmDeleteTag({
    required ModuleConfig module,
    required ModuleTag tag,
    required int usageCount,
  }) async {
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('确定要删除"${tag.name}"吗？'),
              if (usageCount > 0) ...[
                const SizedBox(height: 8),
                Text('该标签已被 $usageCount 条记录使用', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop('cancel'), child: const Text('取消')),
            if (usageCount > 0)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop('replace'),
                child: const Text('替换'),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('delete'),
              child: Text('删除', style: TextStyle(color: usageCount > 0 ? Colors.red : null)),
            ),
          ],
        );
      },
    );
    if (action == null || action == 'cancel') return;
    if (action == 'replace') {
      await _showReplaceTagDialog(module: module, oldTag: tag, usageCount: usageCount);
      return;
    }
    final current = _config?.moduleOf(module.key) ?? module;
    final updatedTags = current.tags.where((t) => t.id != tag.id).toList(growable: false);
    await _saveConfig(_updateModule(current.copyWith(tags: updatedTags)));
  }

  Future<void> _showReplaceTagDialog({
    required ModuleConfig module,
    required ModuleTag oldTag,
    required int usageCount,
  }) async {
    final current = _config?.moduleOf(module.key) ?? module;
    final otherTags = current.tags.where((t) => t.id != oldTag.id).toList();
    if (otherTags.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('没有可替换的标签，请先创建新标签')));
      return;
    }
    String? selectedTagId = otherTags.first.id;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('替换标签'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('将 "${oldTag.name}" 替换为：'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedTagId,
                    items: otherTags
                        .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                        .toList(growable: false),
                    onChanged: (v) => setState(() => selectedTagId = v),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  Text('将影响 $usageCount 条记录', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('取消')),
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('确认替换')),
              ],
            );
          },
        );
      },
    );
    if (confirmed != true || selectedTagId == null) return;
    final newTag = otherTags.firstWhere((t) => t.id == selectedTagId);
    await _replaceTagInDatabase(module: module, oldTagName: oldTag.name, newTagName: newTag.name);
    final updatedTags = current.tags.where((t) => t.id != oldTag.id).toList(growable: false);
    await _saveConfig(_updateModule(current.copyWith(tags: updatedTags)));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已将 "${oldTag.name}" 替换为 "${newTag.name}"')));
  }

  Future<void> _replaceTagInDatabase({
    required ModuleConfig module,
    required String oldTagName,
    required String newTagName,
  }) async {
    final db = ref.read(appDatabaseProvider);
    switch (module.key) {
      case 'food':
        final foods = await db.select(db.foodRecords).get();
        for (final food in foods) {
          final tags = _parseStringList(food.tags);
          if (tags.contains(oldTagName)) {
            final newTags = tags.map((t) => t == oldTagName ? newTagName : t).toList();
            await (db.update(db.foodRecords)..where((t) => t.id.equals(food.id)))
                .write(FoodRecordsCompanion(tags: Value(jsonEncode(newTags))));
          }
        }
        break;
      case 'moment':
        final moments = await db.select(db.momentRecords).get();
        for (final moment in moments) {
          final tags = _parseStringList(moment.tags);
          if (tags.contains(oldTagName)) {
            final newTags = tags.map((t) => t == oldTagName ? newTagName : t).toList();
            await (db.update(db.momentRecords)..where((t) => t.id.equals(moment.id)))
                .write(MomentRecordsCompanion(tags: Value(jsonEncode(newTags))));
          }
        }
        break;
      case 'travel':
        final travels = await db.select(db.travelRecords).get();
        for (final travel in travels) {
          final tags = _parseStringList(travel.tags);
          if (tags.contains(oldTagName)) {
            final newTags = tags.map((t) => t == oldTagName ? newTagName : t).toList();
            await (db.update(db.travelRecords)..where((t) => t.id.equals(travel.id)))
                .write(TravelRecordsCompanion(tags: Value(jsonEncode(newTags))));
          }
        }
        break;
      case 'bond':
        final friends = await db.select(db.friendRecords).get();
        for (final friend in friends) {
          final tags = _parseStringList(friend.impressionTags);
          if (tags.contains(oldTagName)) {
            final newTags = tags.map((t) => t == oldTagName ? newTagName : t).toList();
            await (db.update(db.friendRecords)..where((t) => t.id.equals(friend.id)))
                .write(FriendRecordsCompanion(impressionTags: Value(jsonEncode(newTags))));
          }
        }
        break;
      case 'goal':
        final events = await (db.select(db.timelineEvents)..where((t) => t.eventType.equals('goal'))).get();
        for (final event in events) {
          final tags = _parseStringList(event.tags);
          if (tags.contains(oldTagName)) {
            final newTags = tags.map((t) => t == oldTagName ? newTagName : t).toList();
            await (db.update(db.timelineEvents)..where((t) => t.id.equals(event.id)))
                .write(TimelineEventsCompanion(tags: Value(jsonEncode(newTags))));
          }
        }
        break;
    }
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
              child: Icon(IconUtils.fromName(tag.iconName ?? module.iconName), size: 16, color: _accentFg),
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
            onPressed: () => _confirmDeleteTag(module: module, tag: tag, usageCount: count),
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
                child: Icon(IconUtils.fromName(module.iconName), color: _accentFg),
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
                  icon: Icon(IconUtils.fromName(module.iconName), size: 16, color: _accentFg),
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

class AnnualReportListPage extends ConsumerStatefulWidget {
  const AnnualReportListPage({super.key});

  @override
  ConsumerState<AnnualReportListPage> createState() => _AnnualReportListPageState();
}

class _AnnualReportListPageState extends ConsumerState<AnnualReportListPage> {
  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF2F4F6);
    const primary = Color(0xFF2563EB);
    
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        title: const Text('年度报告', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: () {
              RouteNavigation.goToYearReport(context);
            },
            style: TextButton.styleFrom(foregroundColor: primary, textStyle: const TextStyle(fontWeight: FontWeight.w900)),
            child: const Text('生成报告'),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final reportsAsync = ref.watch(annualReportListProvider);
            
            return reportsAsync.when(
              data: (reports) {
                if (reports.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView(
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
                          Text('年度报告', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                          SizedBox(height: 8),
                          Text('系统会保留每次生成的年度报告，支持查看、导出与重命名。', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B), height: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final report in reports)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AnnualReportCard(
                          report: report,
                          onTap: () => _viewReport(report),
                          onDelete: () => _deleteReport(report),
                          onRename: () => _renameReport(report),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('加载失败: $err', style: const TextStyle(color: Color(0xFFEF4444))),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
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
              Text('年度报告', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
              SizedBox(height: 8),
              Text('年度报告会根据你的记录数据，生成包含生活概览、AI洞察、各模块篇章的完整报告。', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B), height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              Icon(Icons.auto_awesome, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('暂无年度报告', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey.shade500)),
              const SizedBox(height: 8),
              Text('点击右上角"生成报告"开始创建', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
            ],
          ),
        ),
      ],
    );
  }

  void _viewReport(AnnualReportRecord report) {
    RouteNavigation.goToAnnualReportDetail(context, report);
  }

  Future<void> _deleteReport(AnnualReportRecord report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除报告'),
        content: Text('确定要删除"${report.displayTitle}"吗？此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final db = ref.read(appDatabaseProvider);
      await db.annualReviewDao.deleteById(report.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('报告已删除')),
        );
      }
    }
  }

  Future<void> _renameReport(AnnualReportRecord report) async {
    final controller = TextEditingController(text: report.title);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名报告'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '请输入报告标题',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && controller.text.trim().isNotEmpty) {
      final db = ref.read(appDatabaseProvider);
      await db.annualReviewDao.updateTitle(report.id, controller.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('报告已重命名')),
        );
      }
    }
  }
}

class _AnnualReportCard extends StatelessWidget {
  const _AnnualReportCard({
    required this.report,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  final AnnualReportRecord report;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    final dateStr = '${report.createdAt.year}-${report.createdAt.month.toString().padLeft(2, '0')}-${report.createdAt.day.toString().padLeft(2, '0')}';
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8AB4F8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFF8AB4F8), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.displayTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      const SizedBox(height: 4),
                      Text(dateStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'rename') onRename();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'rename', child: Text('重命名')),
                    const PopupMenuItem(value: 'delete', child: Text('删除')),
                  ],
                ),
              ],
            ),
            if (report.keywords.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: report.keywords.take(5).map((k) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(999)),
                  child: Text(k, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF3B82F6))),
                )).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatChip('美食', report.stats.foodCount, const Color(0xFFFFA726)),
                const SizedBox(width: 8),
                _buildStatChip('小确幸', report.stats.momentCount, const Color(0xFFFFCA28)),
                const SizedBox(width: 8),
                _buildStatChip('旅行', report.stats.travelCount, const Color(0xFF42A5F5)),
                const SizedBox(width: 8),
                _buildStatChip('目标', report.stats.goalCount, const Color(0xFFAB47BC)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text('$label: $count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class YearReportPage extends ConsumerStatefulWidget {
  const YearReportPage({
    super.key,
    this.initialReport,
    this.initialStats,
    this.reportId,
    this.createdAt,
  });

  final AnnualReportContent? initialReport;
  final YearStatistics? initialStats;
  final String? reportId;
  final DateTime? createdAt;

  @override
  ConsumerState<YearReportPage> createState() => _YearReportPageState();
}

class _YearReportPageState extends ConsumerState<YearReportPage> {
  int? _selectedYear;
  bool _loading = false;
  bool _generating = false;
  double _progress = 0;
  String _progressText = '';
  final TextEditingController _titleController = TextEditingController();

  YearStatistics? _statistics;
  Map<String, String> _moduleReports = {};
  AnnualReportContent? _finalReport;
  List<int> _availableYears = [];
  bool _loadingYears = true;

  bool get _isViewMode => widget.initialReport != null;

  @override
  void initState() {
    super.initState();
    if (_isViewMode) {
      _finalReport = widget.initialReport;
      _statistics = widget.initialStats;
      _selectedYear = widget.initialStats?.year;
      _titleController.text = widget.initialStats != null ? '${widget.initialStats!.year}年度报告' : '';
      _loadingYears = false;
    } else {
      _loadAvailableYears();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableYears() async {
    setState(() => _loadingYears = true);
    
    try {
      final db = ref.read(appDatabaseProvider);
      final years = <int>{};
      
      final currentYear = DateTime.now().year;
      years.add(currentYear);
      
      final foodYears = await db.customSelect(
        "SELECT DISTINCT strftime('%Y', record_date) as year FROM food_records WHERE is_deleted = 0",
        readsFrom: {db.foodRecords},
      ).get();
      for (final row in foodYears) {
        final yearStr = row.read<String>('year');
        if (yearStr.isNotEmpty) {
          years.add(int.tryParse(yearStr) ?? 0);
        }
      }
      
      final momentYears = await db.customSelect(
        "SELECT DISTINCT strftime('%Y', record_date) as year FROM moment_records WHERE is_deleted = 0",
        readsFrom: {db.momentRecords},
      ).get();
      for (final row in momentYears) {
        final yearStr = row.read<String>('year');
        if (yearStr.isNotEmpty) {
          years.add(int.tryParse(yearStr) ?? 0);
        }
      }
      
      final travelYears = await db.customSelect(
        "SELECT DISTINCT strftime('%Y', record_date) as year FROM travel_records WHERE is_deleted = 0",
        readsFrom: {db.travelRecords},
      ).get();
      for (final row in travelYears) {
        final yearStr = row.read<String>('year');
        if (yearStr.isNotEmpty) {
          years.add(int.tryParse(yearStr) ?? 0);
        }
      }
      
      final goalYears = await db.customSelect(
        "SELECT DISTINCT strftime('%Y', record_date) as year FROM goal_records WHERE is_deleted = 0",
        readsFrom: {db.goalRecords},
      ).get();
      for (final row in goalYears) {
        final yearStr = row.read<String>('year');
        if (yearStr.isNotEmpty) {
          years.add(int.tryParse(yearStr) ?? 0);
        }
      }
      
      final encounterYears = await db.customSelect(
        "SELECT DISTINCT strftime('%Y', record_date) as year FROM timeline_events WHERE is_deleted = 0 AND event_type = 'encounter'",
        readsFrom: {db.timelineEvents},
      ).get();
      for (final row in encounterYears) {
        final yearStr = row.read<String>('year');
        if (yearStr.isNotEmpty) {
          years.add(int.tryParse(yearStr) ?? 0);
        }
      }
      
      years.removeWhere((y) => y < 2000 || y > currentYear + 1);
      
      final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
      
      if (!mounted) return;
      setState(() {
        _availableYears = sortedYears;
        _loadingYears = false;
        if (sortedYears.isNotEmpty) {
          _selectedYear = sortedYears.first;
        }
      });
      
      if (_selectedYear != null) {
        _loadStatistics();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingYears = false;
        _availableYears = [DateTime.now().year];
        _selectedYear = DateTime.now().year;
      });
      _loadStatistics();
    }
  }

  Future<void> _loadStatistics() async {
    if (_selectedYear == null) return;
    
    final year = _selectedYear!;
    
    setState(() {
      _loading = true;
      _statistics = null;
      _moduleReports = {};
      _finalReport = null;
    });

    try {
      final db = ref.read(appDatabaseProvider);
      final stats = await _computeStatistics(db, year);
      if (!mounted) return;
      setState(() {
        _statistics = stats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载统计数据失败：$e')),
      );
    }
  }

  Future<YearStatistics> _computeStatistics(AppDatabase db, int year) async {
    final yearStart = DateTime(year, 1, 1);
    final yearEnd = DateTime(year, 12, 31, 23, 59, 59);

    final foods = await (db.select(db.foodRecords)
          ..where((t) => t.recordDate.isBiggerOrEqualValue(yearStart))
          ..where((t) => t.recordDate.isSmallerOrEqualValue(yearEnd))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isWishlist.equals(false)))
        .get();

    final moments = await (db.select(db.momentRecords)
          ..where((t) => t.recordDate.isBiggerOrEqualValue(yearStart))
          ..where((t) => t.recordDate.isSmallerOrEqualValue(yearEnd))
          ..where((t) => t.isDeleted.equals(false)))
        .get();

    final travels = await (db.select(db.travelRecords)
          ..where((t) => t.recordDate.isBiggerOrEqualValue(yearStart))
          ..where((t) => t.recordDate.isSmallerOrEqualValue(yearEnd))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.isWishlist.equals(false)))
        .get();

    final goals = await (db.select(db.goalRecords)
          ..where((t) => t.recordDate.isBiggerOrEqualValue(yearStart))
          ..where((t) => t.recordDate.isSmallerOrEqualValue(yearEnd))
          ..where((t) => t.isDeleted.equals(false)))
        .get();

    final encounters = await (db.select(db.timelineEvents)
          ..where((t) => t.recordDate.isBiggerOrEqualValue(yearStart))
          ..where((t) => t.recordDate.isSmallerOrEqualValue(yearEnd))
          ..where((t) => t.isDeleted.equals(false))
          ..where((t) => t.eventType.equals('encounter')))
        .get();

    final friends = await db.friendDao.watchAllActive().first;

    final cityFoodCount = <String, int>{};
    final cityFoodRating = <String, List<double>>{};
    for (final f in foods) {
      final city = f.poiName ?? f.city ?? '未知';
      cityFoodCount[city] = (cityFoodCount[city] ?? 0) + 1;
      if (f.rating != null) {
        cityFoodRating.putIfAbsent(city, () => []).add(f.rating!);
      }
    }

    final topFoodCities = cityFoodCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final destinationCount = <String, int>{};
    for (final t in travels) {
      final dest = t.destination ?? t.poiName ?? '未知';
      destinationCount[dest] = (destinationCount[dest] ?? 0) + 1;
    }
    final topDestinations = destinationCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final moodCount = <String, int>{};
    for (final m in moments) {
      if (m.mood.isNotEmpty) {
        moodCount[m.mood] = (moodCount[m.mood] ?? 0) + 1;
      }
    }
    final topMoods = moodCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final completedGoals = goals.where((g) => g.isCompleted).length;
    final totalGoals = goals.length;

    final topRatedFoods = foods.where((f) => f.rating != null).toList()
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));

    return YearStatistics(
      year: year,
      totalRecords: foods.length + moments.length + travels.length + goals.length + encounters.length,
      foodCount: foods.length,
      momentCount: moments.length,
      travelCount: travels.length,
      goalCount: goals.length,
      encounterCount: encounters.length,
      friendCount: friends.length,
      topFoodCities: topFoodCities.take(5).map((e) => MapEntry(e.key, e.value)).toList(),
      avgFoodRating: cityFoodRating.isEmpty
          ? 0
          : cityFoodRating.values.expand((l) => l).reduce((a, b) => a + b) /
              cityFoodRating.values.expand((l) => l).length,
      topDestinations: topDestinations.take(5).map((e) => MapEntry(e.key, e.value)).toList(),
      topMoods: topMoods.take(5).map((e) => MapEntry(e.key, e.value)).toList(),
      goalCompletionRate: totalGoals > 0 ? completedGoals / totalGoals : 0,
      completedGoals: completedGoals,
      totalGoals: totalGoals,
      topRatedFoods: topRatedFoods.take(3).toList(),
      topTravels: travels.take(3).toList(),
      topMoments: moments.take(3).toList(),
    );
  }

  Future<void> _generateReport() async {
    final chatService = ref.read(activeChatServiceProvider);
    if (chatService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在"AI模型管理"中配置对话服务')),
      );
      return;
    }

    if (_statistics == null || _selectedYear == null) return;

    final year = _selectedYear!;
    final stats = _statistics!;

    setState(() {
      _generating = true;
      _progress = 0;
      _progressText = '正在加载原始数据...';
    });

    try {
      final db = ref.read(appDatabaseProvider);
      final yearStart = DateTime(year, 1, 1);
      final yearEnd = DateTime(year, 12, 31, 23, 59, 59);

      final foods = await (db.select(db.foodRecords)
            ..where((t) => t.recordDate.isBiggerOrEqualValue(yearStart))
            ..where((t) => t.recordDate.isSmallerOrEqualValue(yearEnd))
            ..where((t) => t.isDeleted.equals(false))
            ..where((t) => t.isWishlist.equals(false)))
          .get();

      final moments = await (db.select(db.momentRecords)
            ..where((t) => t.recordDate.isBiggerOrEqualValue(yearStart))
            ..where((t) => t.recordDate.isSmallerOrEqualValue(yearEnd))
            ..where((t) => t.isDeleted.equals(false)))
          .get();

      final travels = await (db.select(db.travelRecords)
            ..where((t) => t.recordDate.isBiggerOrEqualValue(yearStart))
            ..where((t) => t.recordDate.isSmallerOrEqualValue(yearEnd))
            ..where((t) => t.isDeleted.equals(false))
            ..where((t) => t.isWishlist.equals(false)))
          .get();

      final goals = await (db.select(db.goalRecords)
            ..where((t) => t.recordDate.isBiggerOrEqualValue(yearStart))
            ..where((t) => t.recordDate.isSmallerOrEqualValue(yearEnd))
            ..where((t) => t.isDeleted.equals(false)))
          .get();

      final encounters = await (db.select(db.timelineEvents)
            ..where((t) => t.recordDate.isBiggerOrEqualValue(yearStart))
            ..where((t) => t.recordDate.isSmallerOrEqualValue(yearEnd))
            ..where((t) => t.isDeleted.equals(false))
            ..where((t) => t.eventType.equals('encounter')))
          .get();

      final friends = await db.friendDao.watchAllActive().first;

      if (!mounted) return;

      final systemPrompt = _buildUltimateSystemPrompt();

      setState(() {
        _progress = 0.1;
        _progressText = '正在生成美食篇章...';
      });

      final foodPrompt = _buildFoodPrompt(stats, foods);
      final foodReport = await chatService.chat(
        systemPrompt: systemPrompt,
        messages: [ai_service.ChatMessage(role: 'user', content: foodPrompt)],
      );
      _moduleReports['food'] = foodReport;

      if (!mounted) return;
      setState(() {
        _progress = 0.25;
        _progressText = '正在生成情绪篇章...';
      });

      final moodPrompt = _buildMoodPrompt(stats, moments);
      final moodReport = await chatService.chat(
        systemPrompt: systemPrompt,
        messages: [ai_service.ChatMessage(role: 'user', content: moodPrompt)],
      );
      _moduleReports['mood'] = moodReport;

      if (!mounted) return;
      setState(() {
        _progress = 0.4;
        _progressText = '正在生成旅行篇章...';
      });

      final travelPrompt = _buildTravelPrompt(stats, travels);
      final travelReport = await chatService.chat(
        systemPrompt: systemPrompt,
        messages: [ai_service.ChatMessage(role: 'user', content: travelPrompt)],
      );
      _moduleReports['travel'] = travelReport;

      if (!mounted) return;
      setState(() {
        _progress = 0.55;
        _progressText = '正在生成目标篇章...';
      });

      final goalPrompt = _buildGoalPrompt(stats, goals);
      final goalReport = await chatService.chat(
        systemPrompt: systemPrompt,
        messages: [ai_service.ChatMessage(role: 'user', content: goalPrompt)],
      );
      _moduleReports['goal'] = goalReport;

      if (!mounted) return;
      setState(() {
        _progress = 0.7;
        _progressText = '正在生成羁绊篇章...';
      });

      final bondPrompt = _buildBondPrompt(stats, encounters, friends);
      final bondReport = await chatService.chat(
        systemPrompt: systemPrompt,
        messages: [ai_service.ChatMessage(role: 'user', content: bondPrompt)],
      );
      _moduleReports['bond'] = bondReport;

      if (!mounted) return;
      setState(() {
        _progress = 0.85;
        _progressText = '正在生成生活概览...';
      });

      final overviewPrompt = _buildOverviewPrompt(stats, _moduleReports);
      final overviewReport = await chatService.chat(
        systemPrompt: systemPrompt,
        messages: [ai_service.ChatMessage(role: 'user', content: overviewPrompt)],
      );

      if (!mounted) return;
      setState(() {
        _progress = 0.92;
        _progressText = '正在生成AI洞察...';
      });

      final insightsPrompt = _buildInsightsPrompt(stats, _moduleReports);
      final insightsReport = await chatService.chat(
        systemPrompt: systemPrompt,
        messages: [ai_service.ChatMessage(role: 'user', content: insightsPrompt)],
      );

      if (!mounted) return;
      setState(() {
        _progress = 0.97;
        _progressText = '正在生成年度结语...';
      });

      final summaryPrompt = _buildSummaryPrompt(stats, _moduleReports);
      final summaryReport = await chatService.chat(
        systemPrompt: systemPrompt,
        messages: [ai_service.ChatMessage(role: 'user', content: summaryPrompt)],
      );

      if (!mounted) return;
      setState(() {
        _progress = 1;
        _progressText = '生成完成';
        _finalReport = AnnualReportContent(
          opening: '$year年，你用记录书写了独一无二的人生篇章。',
          lifeOverview: overviewReport,
          lifestyle: _extractLifestyle(overviewReport),
          behaviorPatterns: _extractBehaviorPatterns(overviewReport),
          preferencePortrait: _extractPreferencePortrait(overviewReport),
          trendChanges: _extractTrendChanges(overviewReport),
          aiInsights: insightsReport,
          foodChapter: _moduleReports['food'] ?? '',
          emotionChapter: _moduleReports['mood'] ?? '',
          travelChapter: _moduleReports['travel'] ?? '',
          goalChapter: _moduleReports['goal'] ?? '',
          friendshipChapter: _moduleReports['bond'] ?? '',
          closing: summaryReport,
          keywords: _extractKeywords(insightsReport),
        );
        _generating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _generating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('生成报告失败：$e')),
      );
    }
  }

  String _buildUltimateSystemPrompt() {
    return '''
你是人生编年史APP中的AI史官（Life Historian AI）。

你的职责是阅读、理解并分析用户长期记录的生活数据，帮助用户发现生活规律、行为模式和个人偏好。

你不是普通聊天助手，而是一位长期观察用户生活的记录者与分析者。你会像一位冷静、理性但富有人情味的史官一样，通过用户留下的记录，还原他们的生活轨迹，并给出洞察。

你的分析必须基于数据，而不是主观猜测。

# 一、你的核心角色

你是一位生活数据分析史官。

你的主要任务包括：
1. 阅读用户的历史记录
2. 发现其中的行为模式
3. 分析用户的偏好与习惯
4. 总结用户的生活规律
5. 给出客观而有启发性的洞察

# 二、你的分析原则

## 1 数据优先原则
所有结论必须来自用户数据。不要编造事实、推测不存在的数据、夸大结论。
如果数据不足，你应该说明："当前数据不足以得出明确结论。"

## 2 模式发现原则
你的核心能力是发现生活模式（Pattern）。例如：频繁出现的行为、明显偏好的选择、时间周期变化、场景规律、行为趋势。

## 3 趋势分析原则
当数据包含时间维度时，请尝试分析：行为是否发生变化、是否存在增长或下降趋势、用户习惯是否稳定。

## 4 避免过度结论
不要因为少量数据得出强结论。

# 三、你的分析结构

每次分析必须按照以下结构输出：
1. 生活洞察（Insights）
2. 数据观察（Data Observations）
3. 可能的生活模式（Patterns）
4. 建议或启发（Suggestions）

# 四、数据解释规则

当你看到用户数据时，请重点关注：
1. 频率：哪些行为出现最多
2. 偏好：用户是否反复选择某些类型
3. 场景：用户通常在什么情境下进行这些活动
4. 时间：活动是否集中在某些时间

# 五、分析语气要求

你的语气应该：冷静、清晰、观察者视角、逻辑严谨。
避免：过度情绪化、夸张表达、心理治疗式语言。
推荐表达方式："从记录来看…"、"数据似乎表明…"、"一个明显的趋势是…"

# 六、当数据不足时

如果用户数据很少，你必须明确说明："当前记录数量较少，分析结论可能不稳定。"并仅给出轻度观察。

# 七、最终输出格式

输出结构：Insights、Data Observations、Patterns、Suggestions
不要输出JSON。输出自然语言结构即可。

# 八、你的目标

你的最终目标不是简单回答问题，而是帮助用户：
- 看见自己的生活模式
- 理解自己的行为习惯
- 发现生活中的规律
''';
  }

  String _buildOverviewPrompt(YearStatistics stats, Map<String, String> modules) {
    return '''
请为${stats.year}年生成一份生活概览（300字以内）。

统计数据：
- 全年总记录数：${stats.totalRecords}条
- 美食：${stats.foodCount}条
- 小确幸：${stats.momentCount}条
- 旅行：${stats.travelCount}条
- 目标：${stats.goalCount}条
- 相遇：${stats.encounterCount}次

请分析并输出：
1. 生活方式类型（社交型/探索型/规律型）
2. 主要行为模式
3. 偏好画像
4. 趋势变化

请用温暖有温度的语言总结这一年的生活全貌。
''';
  }

  String _buildInsightsPrompt(YearStatistics stats, Map<String, String> modules) {
    return '''
请为${stats.year}年生成3-5条关键AI洞察（每条50字以内）。

各模块总结：
- 美食篇章：${modules['food'] ?? '暂无'}
- 情绪篇章：${modules['mood'] ?? '暂无'}
- 旅行篇章：${modules['travel'] ?? '暂无'}
- 目标篇章：${modules['goal'] ?? '暂无'}
- 羁绊篇章：${modules['bond'] ?? '暂无'}

请输出3-5条关键洞察，每条洞察应该：
1. 基于数据分析
2. 有启发性
3. 简洁有力
''';
  }

  String _extractLifestyle(String overview) {
    if (overview.contains('社交型')) return '社交型';
    if (overview.contains('探索型')) return '探索型';
    if (overview.contains('规律型')) return '规律型';
    if (overview.contains('独处型')) return '独处型';
    if (overview.contains('稳定型')) return '稳定型';
    return '混合型';
  }

  String _extractBehaviorPatterns(String overview) {
    final patterns = <String>[];
    if (overview.contains('周末') || overview.contains('周末活动')) patterns.add('周末活动丰富');
    if (overview.contains('高频') || overview.contains('频繁')) patterns.add('高频记录');
    if (overview.contains('固定') || overview.contains('规律')) patterns.add('生活规律');
    if (overview.contains('新') || overview.contains('探索')) patterns.add('喜欢探索新事物');
    if (overview.contains('社交') || overview.contains('朋友')) patterns.add('社交活跃');
    return patterns.isNotEmpty ? patterns.join('、') : overview;
  }

  String _extractPreferencePortrait(String overview) {
    final prefs = <String>[];
    if (overview.contains('美食') || overview.contains('餐厅')) prefs.add('美食爱好者');
    if (overview.contains('旅行') || overview.contains('出行')) prefs.add('旅行达人');
    if (overview.contains('阅读') || overview.contains('学习')) prefs.add('学习型');
    if (overview.contains('运动') || overview.contains('健身')) prefs.add('运动型');
    if (overview.contains('音乐') || overview.contains('艺术')) prefs.add('艺术型');
    return prefs.isNotEmpty ? prefs.join('、') : overview;
  }

  String _extractTrendChanges(String overview) {
    if (overview.contains('增长') || overview.contains('增加')) return '呈增长趋势';
    if (overview.contains('下降') || overview.contains('减少')) return '有所下降';
    if (overview.contains('稳定') || overview.contains('持平')) return '保持稳定';
    return overview;
  }

  List<String> _extractKeywords(String insights) {
    final keywords = <String>[];
    final commonKeywords = ['成长', '探索', '温暖', '社交', '美食', '旅行', '目标', '羁绊', '幸福', '变化'];
    for (final keyword in commonKeywords) {
      if (insights.contains(keyword) && keywords.length < 5) {
        keywords.add(keyword);
      }
    }
    if (keywords.isEmpty) {
      keywords.addAll(['成长', '探索', '温暖']);
    }
    return keywords;
  }

  String _buildFoodPrompt(YearStatistics stats, List<FoodRecord> records) {
    final recordsText = records.isEmpty
      ? '暂无美食记录数据。'
      : records.map((r) => '''
【${r.id}】 ${r.recordDate.toString().split(' ').first}
标题：${r.title}
${r.content?.isNotEmpty == true ? '内容：${r.content}\n' : ''}
${r.rating != null ? '评分：${r.rating}星\n' : ''}
${r.pricePerPerson != null ? '人均：¥${r.pricePerPerson}\n' : ''}
${r.poiName?.isNotEmpty == true ? '地点：${r.poiName}\n' : ''}
${(r.tags?.isNotEmpty == true) ? '标签：${r.tags}\n' : ''}
''').join('\n');

    return '''
请为${stats.year}年的美食记录写一段总结（200字以内）。

统计数据：
- 全年美食记录：${stats.foodCount}条
- 平均评分：${stats.avgFoodRating.toStringAsFixed(1)}分
- 最常去的城市/餐厅：${stats.topFoodCities.map((e) => '${e.key}(${e.value}次)').join('、')}
- 最高评分美食：${stats.topRatedFoods.map((f) => '${f.title}(${f.rating}分)').join('、')}

原始记录数据（共${records.length}条）：
$recordsText

请用温暖有温度的语言总结这一年的味觉旅程。
''';
  }

  String _buildMoodPrompt(YearStatistics stats, List<MomentRecord> records) {
    final recordsText = records.isEmpty
      ? '暂无情绪记录数据。'
      : records.map((r) => '''
【${r.id}】 ${r.recordDate.toString().split(' ').first}
心情：${r.mood}
${r.content?.isNotEmpty == true ? '内容：${r.content}\n' : ''}
${r.tags?.isNotEmpty == true ? '标签：${r.tags}\n' : ''}
''').join('\n');

    return '''
请为${stats.year}年的情绪记录写一段总结（200字以内）。

统计数据：
- 全年小确幸记录：${stats.momentCount}条
- 最常见情绪：${stats.topMoods.map((e) => '${e.key}(${e.value}次)').join('、')}

原始记录数据（共${records.length}条）：
$recordsText

请用温暖有温度的语言总结这一年的情绪变化。
''';
  }

  String _buildTravelPrompt(YearStatistics stats, List<TravelRecord> records) {
    final recordsText = records.isEmpty
      ? '暂无旅行记录数据。'
      : records.map((r) => '''
【${r.id}】 ${r.recordDate.toString().split(' ').first}
${r.title?.isNotEmpty == true ? '标题：${r.title}\n' : ''}
${r.content?.isNotEmpty == true ? '内容：${r.content}\n' : ''}
${r.destination?.isNotEmpty == true ? '目的地：${r.destination}\n' : ''}
${r.poiName?.isNotEmpty == true ? '地点：${r.poiName}\n' : ''}
''').join('\n');

    return '''
请为${stats.year}年的旅行记录写一段总结（200字以内）。

统计数据：
- 全年旅行记录：${stats.travelCount}条
- 最常去的目的地：${stats.topDestinations.map((e) => '${e.key}(${e.value}次)').join('、')}

原始记录数据（共${records.length}条）：
$recordsText

请用温暖有温度的语言总结这一年的探索足迹。
''';
  }

  String _buildGoalPrompt(YearStatistics stats, List<GoalRecord> records) {
    final recordsText = records.isEmpty
      ? '暂无目标记录数据。'
      : records.map((r) => '''
【${r.id}】 ${r.recordDate.toString().split(' ').first}
标题：${r.title}
${r.note?.isNotEmpty == true ? '备注：${r.note}\n' : ''}
${r.summary?.isNotEmpty == true ? '总结：${r.summary}\n' : ''}
分类：${r.category ?? '未分类'}
进度：${(r.progress * 100).toStringAsFixed(0)}%
状态：${r.isCompleted ? '已完成' : '进行中'}
''').join('\n');

    return '''
请为${stats.year}年的目标完成情况写一段总结（200字以内）。

统计数据：
- 全年目标数：${stats.totalGoals}个
- 已完成：${stats.completedGoals}个
- 完成率：${(stats.goalCompletionRate * 100).toStringAsFixed(0)}%

原始记录数据（共${records.length}条）：
$recordsText

请用温暖有温度的语言总结这一年的成长与成就。
''';
  }

  String _buildBondPrompt(YearStatistics stats, List<TimelineEvent> encounters, List<FriendRecord> friends) {
    final encountersText = encounters.isEmpty
        ? '暂无相遇记录数据。'
        : encounters.map((e) => '''
【${e.id}】 ${e.recordDate.toString().split(' ').first}
事件：${e.title}
''').join('\n');

    return '''
请为${stats.year}年的羁绊记录写一段总结（200字以内）。

统计数据：
- 全年相遇记录：${stats.encounterCount}次
- 记录的好友数：${stats.friendCount}位

原始相遇记录数据（共${encounters.length}条）：
$encountersText

请用温暖有温度的语言总结这一年的人际关系。
''';
  }

  String _buildSummaryPrompt(YearStatistics stats, Map<String, String> modules) {
    return '''
请为${stats.year}年的年度报告写一段结语（300字以内）。

全年总记录数：${stats.totalRecords}条
- 美食：${stats.foodCount}条
- 小确幸：${stats.momentCount}条
- 旅行：${stats.travelCount}条
- 目标：${stats.goalCount}条
- 相遇：${stats.encounterCount}次

美食篇章摘要：${modules['food'] ?? ''}
情绪篇章摘要：${modules['mood'] ?? ''}
旅行篇章摘要：${modules['travel'] ?? ''}
目标篇章摘要：${modules['goal'] ?? ''}
羁绊篇章摘要：${modules['bond'] ?? ''}

请写一段温暖的年度结语，像写给未来自己的一封信。
''';
  }

  Future<void> _exportPdf() async {
    if (_finalReport == null || _statistics == null) return;

    try {
      final pdf = pw.Document();
      final stats = _statistics!;
      final report = _finalReport!;

      pdf.addPage(
        pw.Page(
          build: (ctx) => pw.Container(
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [PdfColors.blue900, PdfColors.blue600],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
            ),
            child: pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    '${stats.year} 年度报告',
                    style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    '人生编年史',
                    style: pw.TextStyle(fontSize: 18, color: PdfColors.grey),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    '共记录 ${stats.totalRecords} 条人生记忆',
                    style: const pw.TextStyle(fontSize: 14, color: PdfColors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      pdf.addPage(
        pw.Page(
          build: (ctx) => pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('年度总览', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatBox('美食', stats.foodCount.toString(), PdfColors.orange),
                    _buildStatBox('小确幸', stats.momentCount.toString(), PdfColors.amber),
                    _buildStatBox('旅行', stats.travelCount.toString(), PdfColors.blue),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatBox('目标', stats.goalCount.toString(), PdfColors.purple),
                    _buildStatBox('相遇', stats.encounterCount.toString(), PdfColors.pink),
                    _buildStatBox('好友', stats.friendCount.toString(), PdfColors.red),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (report.lifeOverview.isNotEmpty) {
        pdf.addPage(_buildChapterPage('生活概览', report.lifeOverview, PdfColors.teal));
      }

      if (report.aiInsights.isNotEmpty) {
        pdf.addPage(_buildChapterPage('AI洞察', report.aiInsights, PdfColors.purple));
      }

      if (report.foodChapter.isNotEmpty) {
        pdf.addPage(_buildChapterPage('美食篇章', report.foodChapter, PdfColors.orange));
      }
      if (report.emotionChapter.isNotEmpty) {
        pdf.addPage(_buildChapterPage('情绪篇章', report.emotionChapter, PdfColors.amber));
      }
      if (report.travelChapter.isNotEmpty) {
        pdf.addPage(_buildChapterPage('旅行篇章', report.travelChapter, PdfColors.blue));
      }
      if (report.goalChapter.isNotEmpty) {
        pdf.addPage(_buildChapterPage('目标篇章', report.goalChapter, PdfColors.purple));
      }
      if (report.friendshipChapter.isNotEmpty) {
        pdf.addPage(_buildChapterPage('羁绊篇章', report.friendshipChapter, PdfColors.pink));
      }

      pdf.addPage(
        pw.Page(
          build: (ctx) => pw.Container(
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [PdfColors.indigo900, PdfColors.indigo600],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    '年度结语',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Text(
                    report.closing,
                    style: const pw.TextStyle(fontSize: 14, color: PdfColors.white, lineSpacing: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    '感谢这一年的记录与陪伴',
                    style: pw.TextStyle(fontSize: 18, color: PdfColors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final exportDir = Directory(p.join(dir.path, 'exports'));
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      final file = File(p.join(exportDir.path, 'annual_report_${stats.year}.pdf'));
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;

      await Share.shareXFiles([XFile(file.path)], text: '${stats.year}年度报告');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出PDF失败：$e')),
      );
    }
  }

  pw.Widget _buildStatBox(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(color.toInt() | 0x33000000),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(value, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: color)),
          pw.SizedBox(height: 4),
          pw.Text(label, style: pw.TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  pw.Page _buildChapterPage(String title, String content, PdfColor color) {
    return pw.Page(
      build: (ctx) => pw.Padding(
        padding: const pw.EdgeInsets.all(24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(color.toInt() | 0x33000000),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: color)),
            ),
            pw.SizedBox(height: 24),
            pw.Expanded(
              child: pw.Text(
                content,
                style: const pw.TextStyle(fontSize: 14, lineSpacing: 6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.primary;
    final surface = AppTheme.surface;
    final textMain = AppTheme.textMain;
    final textMuted = AppTheme.textMuted;

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        title: Text(_isViewMode ? '报告详情' : '年度报告', style: TextStyle(color: textMain, fontWeight: FontWeight.w700)),
        backgroundColor: surface,
        elevation: 0,
        iconTheme: IconThemeData(color: textMain),
        actions: _isViewMode
            ? [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'rename') {
                      _showRenameDialog();
                    } else if (value == 'delete') {
                      _showDeleteConfirm();
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'rename', child: Text('重命名')),
                    const PopupMenuItem(value: 'delete', child: Text('删除')),
                  ],
                ),
              ]
            : null,
      ),
      body: _loadingYears
          ? const Center(child: CircularProgressIndicator())
          : _isViewMode
              ? _buildViewModeBody(primary, surface, textMain, textMuted)
              : _buildGenerateModeBody(primary, surface, textMain, textMuted),
    );
  }

  Widget _buildViewModeBody(Color primary, Color surface, Color textMain, Color textMuted) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_statistics != null) ...[
            _buildStatsCard(_statistics!),
            const SizedBox(height: 24),
            if (_finalReport != null) ...[
              _buildReportPreview(_finalReport!),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _exportPdf,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('导出PDF'),
                      style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildGenerateModeBody(Color primary, Color surface, Color textMain, Color textMuted) {
    return _selectedYear == null
        ? const Center(child: Text('暂无数据'))
        : _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          isExpanded: true,
                          items: _availableYears.map((y) => DropdownMenuItem(value: y, child: Text('$y 年'))).toList(),
                          onChanged: (v) {
                            if (v != null && v != _selectedYear) {
                              setState(() {
                                _selectedYear = v;
                                _statistics = null;
                                _finalReport = null;
                                _moduleReports = {};
                              });
                              _loadStatistics();
                            }
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (_statistics != null) ...[
                    _buildStatsCard(_statistics!),
                    const SizedBox(height: 24),
                    if (_generating) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              LinearProgressIndicator(value: _progress, color: primary),
                              const SizedBox(height: 12),
                              Text(_progressText, style: TextStyle(color: textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ] else if (_finalReport != null) ...[
                      _buildReportPreview(_finalReport!),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: '报告标题（默认为"{年份}年度报告"）',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _generateReport,
                              icon: const Icon(Icons.refresh),
                              label: const Text('重新生成'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: textMain),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saveReport,
                              icon: const Icon(Icons.save),
                              label: const Text('保存报告'),
                              style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ] else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _generateReport,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('生成年度报告'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
  }

  Future<void> _saveReport() async {
    if (_finalReport == null || _statistics == null || _selectedYear == null) return;
    
    final title = _titleController.text.trim().isEmpty 
        ? '$_selectedYear年度报告' 
        : _titleController.text.trim();
    
    final db = ref.read(appDatabaseProvider);
    final uuid = const Uuid().v4();
    
    await db.annualReviewDao.upsert(
      AnnualReviewsCompanion(
        id: Value(uuid),
        year: Value(_selectedYear!),
        title: Value(title),
        content: Value(jsonEncode(_finalReport!.toJson())),
        stats: Value(jsonEncode(_statistics!.toJson())),
        keywords: Value(jsonEncode(_finalReport!.keywords)),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('报告已保存')),
      );
      context.pop();
    }
  }

  Future<void> _showRenameDialog() async {
    if (widget.reportId == null) return;
    
    final controller = TextEditingController(text: widget.initialStats != null ? '${widget.initialStats!.year}年度报告' : '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名报告'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '请输入报告标题',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && controller.text.trim().isNotEmpty) {
      final db = ref.read(appDatabaseProvider);
      await db.annualReviewDao.updateTitle(widget.reportId!, controller.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('报告已重命名')),
        );
        context.pop();
      }
    }
  }

  Future<void> _showDeleteConfirm() async {
    if (widget.reportId == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除报告'),
        content: const Text('确定要删除这份报告吗？此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final db = ref.read(appDatabaseProvider);
      await db.annualReviewDao.deleteById(widget.reportId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('报告已删除')),
        );
        context.pop();
      }
    }
  }

  Widget _buildStatsCard(YearStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('年度总览', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textMain)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem('美食', stats.foodCount, const Color(0xFFFFA726)),
                _buildStatItem('小确幸', stats.momentCount, const Color(0xFFFFCA28)),
                _buildStatItem('旅行', stats.travelCount, const Color(0xFF42A5F5)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatItem('目标', stats.goalCount, const Color(0xFFAB47BC)),
                _buildStatItem('相遇', stats.encounterCount, const Color(0xFFEC407A)),
                _buildStatItem('好友', stats.friendCount, const Color(0xFFEF5350)),
              ],
            ),
            const SizedBox(height: 16),
            Text('共记录 ${stats.totalRecords} 条人生记忆', style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportPreview(AnnualReportContent report) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppTheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text('生活概览', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textMain)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  report.lifeOverview.isNotEmpty ? report.lifeOverview : '暂无数据',
                  style: TextStyle(color: AppTheme.textMain, height: 1.6),
                ),
                const SizedBox(height: 12),
                if (report.lifestyle.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF2BCDEE).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('生活方式: ${report.lifestyle}', style: const TextStyle(fontSize: 13, color: Color(0xFF2BCDEE), fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                ],
                if (report.behaviorPatterns.isNotEmpty && report.behaviorPatterns != report.lifeOverview) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFFA726).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('行为模式: ${report.behaviorPatterns}', style: const TextStyle(fontSize: 13, color: Color(0xFFFFA726), fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                ],
                if (report.preferencePortrait.isNotEmpty && report.preferencePortrait != report.lifeOverview) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF42A5F5).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('偏好画像: ${report.preferencePortrait}', style: const TextStyle(fontSize: 13, color: Color(0xFF42A5F5), fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                ],
                if (report.trendChanges.isNotEmpty && report.trendChanges != report.lifeOverview) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFAB47BC).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('趋势变化: ${report.trendChanges}', style: const TextStyle(fontSize: 13, color: Color(0xFFAB47BC), fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: report.keywords.map<Widget>((k) => Chip(
                    label: Text(k),
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 12),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.insights, color: const Color(0xFFAB47BC), size: 24),
                    const SizedBox(width: 8),
                    Text('AI洞察', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textMain)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  report.aiInsights.isNotEmpty ? report.aiInsights : '暂无数据',
                  style: TextStyle(color: AppTheme.textMain, height: 1.6),
                ),
              ],
            ),
          ),
        ),
        _buildExpandableChapter('美食篇章', report.foodChapter, const Color(0xFFFFA726)),
        _buildExpandableChapter('情绪篇章', report.emotionChapter, const Color(0xFFFFCA28)),
        _buildExpandableChapter('旅行篇章', report.travelChapter, const Color(0xFF42A5F5)),
        _buildExpandableChapter('目标篇章', report.goalChapter, const Color(0xFFAB47BC)),
        _buildExpandableChapter('羁绊篇章', report.friendshipChapter, const Color(0xFFEC407A)),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, color: const Color(0xFFEF5350), size: 24),
                    const SizedBox(width: 8),
                    Text('年度结语', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textMain)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  report.closing.isNotEmpty ? report.closing : '暂无数据',
                  style: TextStyle(color: AppTheme.textMuted, height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableChapter(String title, String content, Color color) {
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(content, style: TextStyle(color: AppTheme.textMain, height: 1.6)),
          ),
        ],
      ),
    );
  }
}

class YearStatistics {
  const YearStatistics({
    required this.year,
    required this.totalRecords,
    required this.foodCount,
    required this.momentCount,
    required this.travelCount,
    required this.goalCount,
    required this.encounterCount,
    required this.friendCount,
    required this.topFoodCities,
    required this.avgFoodRating,
    required this.topDestinations,
    required this.topMoods,
    required this.goalCompletionRate,
    required this.completedGoals,
    required this.totalGoals,
    required this.topRatedFoods,
    required this.topTravels,
    required this.topMoments,
  });

  final int year;
  final int totalRecords;
  final int foodCount;
  final int momentCount;
  final int travelCount;
  final int goalCount;
  final int encounterCount;
  final int friendCount;
  final List<MapEntry<String, int>> topFoodCities;
  final double avgFoodRating;
  final List<MapEntry<String, int>> topDestinations;
  final List<MapEntry<String, int>> topMoods;
  final double goalCompletionRate;
  final int completedGoals;
  final int totalGoals;
  final List<FoodRecord> topRatedFoods;
  final List<TravelRecord> topTravels;
  final List<MomentRecord> topMoments;

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'totalRecords': totalRecords,
      'foodCount': foodCount,
      'momentCount': momentCount,
      'travelCount': travelCount,
      'goalCount': goalCount,
      'encounterCount': encounterCount,
      'friendCount': friendCount,
      'topFoodCities': topFoodCities.map((e) => {'key': e.key, 'value': e.value}).toList(),
      'avgFoodRating': avgFoodRating,
      'topDestinations': topDestinations.map((e) => {'key': e.key, 'value': e.value}).toList(),
      'topMoods': topMoods.map((e) => {'key': e.key, 'value': e.value}).toList(),
      'goalCompletionRate': goalCompletionRate,
      'completedGoals': completedGoals,
      'totalGoals': totalGoals,
    };
  }

  factory YearStatistics.fromJson(Map<String, dynamic> json) {
    return YearStatistics(
      year: json['year'] as int? ?? DateTime.now().year,
      totalRecords: json['totalRecords'] as int? ?? 0,
      foodCount: json['foodCount'] as int? ?? 0,
      momentCount: json['momentCount'] as int? ?? 0,
      travelCount: json['travelCount'] as int? ?? 0,
      goalCount: json['goalCount'] as int? ?? 0,
      encounterCount: json['encounterCount'] as int? ?? 0,
      friendCount: json['friendCount'] as int? ?? 0,
      topFoodCities: (json['topFoodCities'] as List?)
              ?.map((e) => MapEntry(e['key'] as String, e['value'] as int))
              .toList() ??
          [],
      avgFoodRating: (json['avgFoodRating'] as num?)?.toDouble() ?? 0.0,
      topDestinations: (json['topDestinations'] as List?)
              ?.map((e) => MapEntry(e['key'] as String, e['value'] as int))
              .toList() ??
          [],
      topMoods: (json['topMoods'] as List?)
              ?.map((e) => MapEntry(e['key'] as String, e['value'] as int))
              .toList() ??
          [],
      goalCompletionRate: (json['goalCompletionRate'] as num?)?.toDouble() ?? 0.0,
      completedGoals: json['completedGoals'] as int? ?? 0,
      totalGoals: json['totalGoals'] as int? ?? 0,
      topRatedFoods: [],
      topTravels: [],
      topMoments: [],
    );
  }
}

class AnnualReportContent {
  const AnnualReportContent({
    required this.opening,
    this.lifeOverview = '',
    this.lifestyle = '',
    this.behaviorPatterns = '',
    this.preferencePortrait = '',
    this.trendChanges = '',
    this.aiInsights = '',
    required this.foodChapter,
    required this.emotionChapter,
    required this.travelChapter,
    required this.goalChapter,
    required this.friendshipChapter,
    required this.closing,
    required this.keywords,
  });

  final String opening;
  final String lifeOverview;
  final String lifestyle;
  final String behaviorPatterns;
  final String preferencePortrait;
  final String trendChanges;
  final String aiInsights;
  final String foodChapter;
  final String emotionChapter;
  final String travelChapter;
  final String goalChapter;
  final String friendshipChapter;
  final String closing;
  final List<String> keywords;

  Map<String, dynamic> toJson() {
    return {
      'opening': opening,
      'lifeOverview': lifeOverview,
      'lifestyle': lifestyle,
      'behaviorPatterns': behaviorPatterns,
      'preferencePortrait': preferencePortrait,
      'trendChanges': trendChanges,
      'aiInsights': aiInsights,
      'foodChapter': foodChapter,
      'emotionChapter': emotionChapter,
      'travelChapter': travelChapter,
      'goalChapter': goalChapter,
      'friendshipChapter': friendshipChapter,
      'closing': closing,
      'keywords': keywords,
    };
  }

  factory AnnualReportContent.fromJson(Map<String, dynamic> json) {
    return AnnualReportContent(
      opening: json['opening'] as String? ?? '',
      lifeOverview: json['lifeOverview'] as String? ?? '',
      lifestyle: json['lifestyle'] as String? ?? '',
      behaviorPatterns: json['behaviorPatterns'] as String? ?? '',
      preferencePortrait: json['preferencePortrait'] as String? ?? '',
      trendChanges: json['trendChanges'] as String? ?? '',
      aiInsights: json['aiInsights'] as String? ?? '',
      foodChapter: json['foodChapter'] as String? ?? '',
      emotionChapter: json['emotionChapter'] as String? ?? '',
      travelChapter: json['travelChapter'] as String? ?? '',
      goalChapter: json['goalChapter'] as String? ?? '',
      friendshipChapter: json['friendshipChapter'] as String? ?? '',
      closing: json['closing'] as String? ?? '',
      keywords: (json['keywords'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class AnnualReportRecord {
  const AnnualReportRecord({
    required this.id,
    required this.year,
    required this.title,
    required this.content,
    required this.stats,
    required this.keywords,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final int year;
  final String title;
  final AnnualReportContent content;
  final YearStatistics stats;
  final List<String> keywords;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayTitle => title.isEmpty ? '$year年度报告' : title;

  static AnnualReportRecord fromDatabase(AnnualReview review) {
    AnnualReportContent? content;
    YearStatistics? stats;
    List<String> keywordsList = [];

    if (review.content != null && review.content!.isNotEmpty) {
      try {
        content = AnnualReportContent.fromJson(jsonDecode(review.content!));
      } catch (e) {
        debugPrint('解析年度报告内容失败: $e');
        content = AnnualReportContent(
          opening: review.content!,
          foodChapter: '',
          emotionChapter: '',
          travelChapter: '',
          goalChapter: '',
          friendshipChapter: '',
          closing: '',
          keywords: [],
        );
      }
    }

    if (review.stats != null && review.stats!.isNotEmpty) {
      try {
        stats = YearStatistics.fromJson(jsonDecode(review.stats!));
      } catch (e) {
        debugPrint('解析年度统计失败: $e');
        stats = YearStatistics(
          year: review.year,
          totalRecords: 0,
          foodCount: 0,
          momentCount: 0,
          travelCount: 0,
          goalCount: 0,
          encounterCount: 0,
          friendCount: 0,
          topFoodCities: [],
          avgFoodRating: 0,
          topDestinations: [],
          topMoods: [],
          goalCompletionRate: 0,
          completedGoals: 0,
          totalGoals: 0,
          topRatedFoods: [],
          topTravels: [],
          topMoments: [],
        );
      }
    }

    if (review.keywords != null && review.keywords!.isNotEmpty) {
      try {
        keywordsList = List<String>.from(jsonDecode(review.keywords!));
      } catch (e) {
        debugPrint('解析年度报告关键词失败: $e');
        keywordsList = content?.keywords ?? [];
      }
    } else {
      keywordsList = content?.keywords ?? [];
    }

    return AnnualReportRecord(
      id: review.id,
      year: review.year,
      title: review.title,
      content: content!,
      stats: stats!,
      keywords: keywordsList,
      createdAt: review.createdAt,
      updatedAt: review.updatedAt,
    );
  }

  Map<String, dynamic> toDatabaseCompanion({DateTime? existingCreatedAt}) {
    return {
      'id': id,
      'year': year,
      'title': title,
      'content': jsonEncode(content.toJson()),
      'stats': jsonEncode(stats.toJson()),
      'keywords': jsonEncode(keywords),
      'createdAt': existingCreatedAt ?? createdAt,
      'updatedAt': DateTime.now(),
    };
  }
}

final annualReportListProvider = StreamProvider<List<AnnualReportRecord>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.annualReviewDao.watchAll().map((reviews) {
    return reviews.map((r) => AnnualReportRecord.fromDatabase(r)).toList();
  });
});

class ReminderSettingsPage extends ConsumerStatefulWidget {
  const ReminderSettingsPage({super.key});

  @override
  ConsumerState<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends ConsumerState<ReminderSettingsPage> {
  List<FriendRecord> _friends = [];
  Map<String, bool> _reminderEnabled = {};
  Map<String, int> _reminderDays = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final db = ref.read(appDatabaseProvider);
    final friends = await db.friendDao.watchAllActive().first;
    
    final prefs = await SharedPreferences.getInstance();
    
    final Map<String, bool> enabled = {};
    final Map<String, int> days = {};
    
    for (final f in friends) {
      final key = 'reminder_${f.id}';
      enabled[f.id] = prefs.getBool(key) ?? false;
      days[f.id] = prefs.getInt('${key}_days') ?? 7;
    }
    
    if (!mounted) return;
    setState(() {
      _friends = friends;
      _reminderEnabled = enabled;
      _reminderDays = days;
      _loading = false;
    });
  }

  Future<void> _toggleReminder(String friendId, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_$friendId', enabled);
    setState(() {
      _reminderEnabled[friendId] = enabled;
    });
  }

  Future<void> _setReminderDays(String friendId, int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_${friendId}_days', days);
    setState(() {
      _reminderDays[friendId] = days;
    });
  }

  Future<void> _scheduleReminder(FriendRecord friend, int days) async {
    // TODO: 集成 flutter_local_notifications 实现本地通知
    // 这里只是保存设置，实际通知需要在后台服务中处理
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已设置${friend.name}的联络提醒，每$days天提醒一次')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.primary;
    final surface = AppTheme.surface;
    final textMain = AppTheme.textMain;
    final textMuted = AppTheme.textMuted;

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        title: Text('提醒设置', style: TextStyle(color: textMain, fontWeight: FontWeight.w700)),
        backgroundColor: surface,
        elevation: 0,
        iconTheme: IconThemeData(color: textMain),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _friends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: textMuted),
                      const SizedBox(height: 16),
                      Text('暂无好友记录', style: TextStyle(color: textMuted)),
                      const SizedBox(height: 8),
                      Text('添加好友后可设置联络提醒', style: TextStyle(color: textMuted, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _friends.length,
                  itemBuilder: (ctx, i) {
                    final friend = _friends[i];
                    final enabled = _reminderEnabled[friend.id] ?? false;
                    final days = _reminderDays[friend.id] ?? 7;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: primary.withValues(alpha: 0.1),
                                  child: Text(
                                    friend.name.isNotEmpty ? friend.name[0] : '?',
                                    style: TextStyle(color: primary, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(friend.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textMain)),
                                      if (friend.contactFrequency != null && friend.contactFrequency!.isNotEmpty)
                                        Text('期望频率：${friend.contactFrequency}', style: TextStyle(fontSize: 12, color: textMuted)),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: enabled,
                                  onChanged: (v) => _toggleReminder(friend.id, v),
                                  activeColor: primary,
                                ),
                              ],
                            ),
                            if (enabled) ...[
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text('提醒周期', style: TextStyle(color: textMuted)),
                                  const SizedBox(width: 12),
                                  DropdownButton<int>(
                                    value: days,
                                    items: const [
                                      DropdownMenuItem(value: 3, child: Text('每3天')),
                                      DropdownMenuItem(value: 7, child: Text('每7天')),
                                      DropdownMenuItem(value: 14, child: Text('每14天')),
                                      DropdownMenuItem(value: 30, child: Text('每30天')),
                                      DropdownMenuItem(value: 60, child: Text('每60天')),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) {
                                        _setReminderDays(friend.id, v);
                                        _scheduleReminder(friend, v);
                                      }
                                    },
                                    underline: const SizedBox(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '距离上次联络已过 X 天，该联系一下啦！',
                                style: TextStyle(fontSize: 12, color: textMuted, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        elevation: 0,
        centerTitle: true,
        title: const Text('帮助与反馈', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1F2937))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF374151)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HelpListGroup(
              items: [
                _HelpListItem(
                  icon: Icons.help_outline,
                  iconColor: Colors.black,
                  title: '使用帮助',
                  onTap: () => _showHelpDialog(context),
                ),
                _HelpListItem(
                  icon: Icons.bug_report_outlined,
                  iconColor: Colors.black,
                  title: '系统日志',
                  onTap: () => RouteNavigation.goToSystemLog(context),
                ),
                _HelpListItem(
                  icon: Icons.info_outline,
                  iconColor: Colors.black,
                  title: '关于我们',
                  onTap: () => _showAboutDialog(context),
                ),
                _HelpListItem(
                  icon: Icons.description_outlined,
                  iconColor: Colors.black,
                  title: '用户协议',
                  onTap: () => _showUserAgreement(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text(
                    '人生编年史',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '版本 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
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

  void _showHelpDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HelpContentSheet(
        title: '使用帮助',
        content: _buildHelpContent(),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HelpContentSheet(
        title: '关于我们',
        content: _buildAboutContent(context),
      ),
    );
  }

  Future<void> _checkForUpdate(BuildContext context) async {
    final updateService = AppUpdateService();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final versionInfo = await updateService.checkForUpdate();
      
      if (context.mounted) {
        Navigator.of(context).pop();
        
        if (versionInfo != null) {
          final hasUpdate = await updateService.isUpdateAvailable(versionInfo);
          
          if (hasUpdate && context.mounted) {
            _showUpdateAvailableDialog(context, versionInfo);
          } else if (context.mounted) {
            _showNoUpdateDialog(context);
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('检查更新失败，请稍后重试')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('检查更新失败：$e')),
        );
      }
    }
  }

  void _showUpdateAvailableDialog(BuildContext context, VersionInfo versionInfo) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('发现新版本'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('最新版本：${versionInfo.latestVersion}'),
            const SizedBox(height: 12),
            const Text('更新内容：', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (final item in versionInfo.changelog)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $item'),
              ),
            if (versionInfo.forceUpdate)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '此版本为强制更新',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          if (!versionInfo.forceUpdate)
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('稍后再说'),
            ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final updateService = AppUpdateService();
              await updateService.launchDownloadUrl(versionInfo);
            },
            child: const Text('立即更新'),
          ),
        ],
      ),
    );
  }

  void _showNoUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('已是最新版本'),
        content: const Text('您当前使用的已是最新版本，无需更新。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }

  void _showUserAgreement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HelpContentSheet(
        title: '用户协议',
        content: _buildAgreementContent(),
      ),
    );
  }

  Widget _buildHelpContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHelpItem('1. 如何添加记录？', '点击底部导航栏的"+"按钮，选择要添加的记录类型（美食、旅行、小确幸等），填写相关信息后保存即可。'),
        _buildHelpItem('2. 如何使用AI史官？', '在各模块页面顶部点击"AI史官"按钮，AI会根据您的记录数据为您提供智能分析和建议。'),
        _buildHelpItem('3. 如何备份数据？', '进入个人中心 -> 数据管理，点击"立即备份"按钮即可将数据备份到本地或云端。'),
        _buildHelpItem('4. 如何设置提醒？', '进入个人中心 -> 提醒设置，可以设置每日记录提醒、目标截止提醒等。'),
        _buildHelpItem('5. 如何分享记录？', '在记录详情页点击分享按钮，可以将记录导出为图片或文本格式分享给好友。'),
      ],
    );
  }

  Widget _buildHelpItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutContent(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF2BCDEE).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.auto_stories,
            size: 40,
            color: Color(0xFF2BCDEE),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '人生编年史',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '记录生活点滴，珍藏美好回忆',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final version = snapshot.data?.version ?? '0.1.0';
            return _buildInfoRow('版本', version);
          },
        ),
        _buildInfoRow('开发者', '苏留哲'),
        _buildInfoRow('联系邮箱', '暂无'),
        _buildInfoRow('官方网站', '暂无'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _checkForUpdate(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2BCDEE),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.update, size: 20),
              SizedBox(width: 8),
              Text('检查更新', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementContent() {
    return const Text(
      '欢迎使用人生编年史！\n\n'
      '1. 服务条款\n'
      '本应用为用户提供生活记录、数据管理等服务。用户使用本应用即表示同意本协议的所有条款。\n\n'
      '2. 用户责任\n'
      '用户应当遵守法律法规，不得利用本应用从事违法违规活动。\n\n'
      '3. 知识产权\n'
      '本应用的界面设计、代码、图标等均为开发团队所有，未经授权不得复制或修改。\n\n'
      '4. 免责声明\n'
      '用户自行承担使用本应用的风险，开发团队不对因使用本应用造成的任何损失承担责任。\n\n'
      '5. 协议修改\n'
      '开发团队有权随时修改本协议，修改后的协议将在应用内公布。',
      style: TextStyle(
        fontSize: 14,
        color: Color(0xFF6B7280),
        height: 1.6,
      ),
    );
  }

}

class _HelpListItem {
  const _HelpListItem({
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

class _HelpListGroup extends StatelessWidget {
  const _HelpListGroup({required this.items});

  final List<_HelpListItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _HelpListRow(item: items[i]),
            if (i != items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Color(0xFFF3F4F6)),
              ),
          ],
        ],
      ),
    );
  }
}

class _HelpListRow extends StatelessWidget {
  const _HelpListRow({required this.item});

  final _HelpListItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        item.onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(item.icon, color: item.iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }
}

class _HelpContentSheet extends StatelessWidget {
  const _HelpContentSheet({
    required this.title,
    required this.content,
  });

  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF9CA3AF)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: content,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
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
