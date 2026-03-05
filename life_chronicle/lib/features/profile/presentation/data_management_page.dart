import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/providers/uuid_provider.dart';
import '../../../core/services/backup/backup.dart';
import 'backup_log_page.dart';

class DataManagementPage extends ConsumerStatefulWidget {
  const DataManagementPage({super.key});

  @override
  ConsumerState<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends ConsumerState<DataManagementPage> {
  final WebDavConfigService _configService = WebDavConfigService();
  final BackgroundBackupService _backgroundBackupService = BackgroundBackupService();
  WebDavConfig? _config;
  bool _isLoading = true;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isExporting = false;
  BackupProgress? _currentProgress;
  StreamSubscription<BackupProgress>? _progressSubscription;
  List<Map<String, dynamic>> _availableBackups = [];

  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _encryptionPasswordController = TextEditingController();

  bool _obscurePassword = true;
  String _backupFrequency = 'daily';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _encryptionPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final config = await _configService.loadConfig();
    if (mounted) {
      setState(() {
        _config = config;
        if (config != null) {
          _urlController.text = config.url;
          _usernameController.text = config.username;
          _passwordController.text = config.password;
          _backupFrequency = config.autoBackupFrequency ?? 'daily';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _testConnection() async {
    if (_urlController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('请填写完整的 WebDAV 配置', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final client = WebDavClient(
        baseUrl: _urlController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );
      final success = await client.testConnection();
      client.close();

      if (success) {
        _showSnackBar('连接成功！');
      } else {
        _showSnackBar('连接失败，请检查配置', isError: true);
      }
    } catch (e) {
      _showSnackBar('连接出错: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveConfig() async {
    if (_urlController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('请填写完整的 WebDAV 配置', isError: true);
      return;
    }

    final newConfig = WebDavConfig(
      url: _urlController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      enabled: _config?.enabled ?? true,
      autoBackup: _config?.autoBackup ?? false,
      encryptBackup: _config?.encryptBackup ?? true,
      autoBackupFrequency: _backupFrequency,
      backupOnWifiOnly: _config?.backupOnWifiOnly ?? true,
    );

    await _configService.saveConfig(newConfig);
    if (mounted) {
      setState(() => _config = newConfig);
      _showSnackBar('配置已保存');
    }
  }

  Future<void> _performFullBackup() async {
    if (_config == null) {
      _showSnackBar('请先配置 WebDAV', isError: true);
      return;
    }

    if (_encryptionPasswordController.text.isEmpty && _config!.encryptBackup) {
      _showSnackBar('请输入加密密码', isError: true);
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final backupService = BackupService(db);

    setState(() => _isBackingUp = true);
    
    try {
      _progressSubscription = backupService.progressStream.listen((progress) {
        if (mounted) {
          setState(() => _currentProgress = progress);
        }
      });

      await backupService.performFullBackup(
        config: _config!,
        encryptionPassword: _encryptionPasswordController.text,
      );

      _showSnackBar('备份成功！');
    } catch (e) {
      _showSnackBar('备份失败: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
          _currentProgress = null;
        });
        _progressSubscription?.cancel();
      }
    }
  }

  Future<void> _performLocalBackup() async {
    final db = ref.read(appDatabaseProvider);
    final uuid = ref.read(uuidProvider);
    final backupService = BackupService(db);
    final startedAt = DateTime.now();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'life_chronicle_local_$timestamp.zip';
    String? logId;

    setState(() => _isBackingUp = true);
    
    try {
      logId = uuid.v4();
      await db.backupLogDao.insert(BackupLogsCompanion(
        id: Value(logId),
        backupType: const Value('full'),
        storageType: const Value('local'),
        fileName: Value(fileName),
        status: const Value('in_progress'),
        startedAt: Value(startedAt),
        createdAt: Value(DateTime.now()),
      ));
      
      final tempDir = await backupService.getTempDir();
      final zipPath = path.join(tempDir.path, fileName);
      
      final data = await backupService.exportAllData();
      final mediaFiles = await backupService.collectAllMediaFiles();
      
      await EncryptionService.createZipArchive(mediaFiles, data, zipPath);
      
      final appDocDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory(path.join(appDocDir.path, 'backups'));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      final finalZipPath = path.join(backupDir.path, fileName);
      await File(zipPath).copy(finalZipPath);
      
      final fileSize = await File(finalZipPath).length();
      final recordCount = _countRecords(data);
      final mediaCount = mediaFiles.length;
      
      await db.backupLogDao.updateStatus(
        logId,
        'completed',
        completedAt: DateTime.now(),
      );
      
      await (db.update(db.backupLogs)..where((t) => t.id.equals(logId!))).write(
        BackupLogsCompanion(
          filePath: Value(finalZipPath),
          fileSize: Value(fileSize),
          recordCount: Value(recordCount),
          mediaCount: Value(mediaCount),
        ),
      );
      
      setState(() => _isBackingUp = false);
      
      if (!mounted) return;
      final shouldShare = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('备份成功'),
          content: Text(
            '备份文件已保存\n\n'
            '路径: $finalZipPath\n'
            '大小: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB\n'
            '记录数: $recordCount\n'
            '媒体文件: $mediaCount\n\n'
            '是否分享到其他应用？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('关闭'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('分享'),
            ),
          ],
        ),
      );
      
      if (shouldShare == true && mounted) {
        await Share.shareXFiles(
          [XFile(finalZipPath)],
          subject: '人生编年史备份 $fileName',
        );
      }
    } catch (e) {
      if (logId != null) {
        await db.backupLogDao.updateStatus(
          logId,
          'failed',
          errorMessage: e.toString(),
          completedAt: DateTime.now(),
        );
      }
      _showSnackBar('本地备份失败: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
          _currentProgress = null;
        });
      }
    }
  }
  
  int _countRecords(Map<String, dynamic> data) {
    int count = 0;
    for (final key in data.keys) {
      if (key.endsWith('_records') || key == 'trips' || key == 'checklist_items' || key == 'entity_links' || key == 'link_logs' || key == 'user_profiles' || key == 'ai_providers') {
        final value = data[key];
        if (value is List) {
          count += value.length;
        }
      }
    }
    return count;
  }

  Future<void> _restoreFromLocal() async {
    final db = ref.read(appDatabaseProvider);
    final backupService = BackupService(db);

    setState(() => _isRestoring = true);
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'json'],
        allowCompression: false,
      );
      
      if (result == null || result.files.isEmpty) {
        setState(() => _isRestoring = false);
        return;
      }
      
      final filePath = result.files.first.path;
      if (filePath == null) {
        _showSnackBar('无法获取文件路径', isError: true);
        return;
      }
      
      final file = File(filePath);
      if (!await file.exists()) {
        _showSnackBar('文件不存在', isError: true);
        return;
      }
      
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认恢复'),
          content: Text('将从文件恢复数据：\n${result.files.first.name}\n\n此操作将合并到当前数据，是否继续？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确定'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) {
        setState(() => _isRestoring = false);
        return;
      }
      
      final tempDir = await backupService.getTempDir();
      
      if (filePath.endsWith('.zip')) {
        final extractDir = path.join(tempDir.path, 'extract_${DateTime.now().millisecondsSinceEpoch}');
        final (data, mediaFiles) = await EncryptionService.extractZipArchive(file, extractDir);
        
        await backupService.importData(data, merge: true);
        await _restoreMediaFiles(mediaFiles);
      } else if (filePath.endsWith('.json')) {
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        await backupService.importData(data, merge: true);
      } else {
        _showSnackBar('不支持的文件格式', isError: true);
        return;
      }
      
      _showSnackBar('恢复成功！');
    } catch (e) {
      _showSnackBar('恢复失败: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
          _currentProgress = null;
        });
      }
    }
  }

  Future<void> _restoreMediaFiles(List<File> mediaFiles) async {
    final targetMediaDir = Directory(path.join((await getApplicationDocumentsDirectory()).path, 'media'));
    if (!await targetMediaDir.exists()) {
      await targetMediaDir.create(recursive: true);
    }
    
    for (final file in mediaFiles) {
      final fileName = path.basename(file.path);
      final targetPath = path.join(targetMediaDir.path, fileName);
      await file.copy(targetPath);
    }
  }

  Future<void> _exportToJson() async {
    final db = ref.read(appDatabaseProvider);
    final backupService = BackupService(db);

    setState(() => _isExporting = true);
    
    try {
      final data = await backupService.exportAllData();
      final jsonString = jsonEncode(data);
      
      final tempDir = await backupService.getTempDir();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'life_chronicle_export_$timestamp.json';
      final filePath = path.join(tempDir.path, fileName);
      final file = File(filePath);
      await file.writeAsString(jsonString);
      
      final appDocDir = await getApplicationDocumentsDirectory();
      final exportDir = Directory(path.join(appDocDir.path, 'exports'));
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      final savedPath = path.join(exportDir.path, fileName);
      await file.copy(savedPath);
      
      setState(() => _isExporting = false);
      
      if (!mounted) return;
      final shouldShare = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('导出成功'),
          content: Text('文件已保存到应用内部\n\n是否分享到其他应用？\n\n文件大小: ${(jsonString.length / 1024).toStringAsFixed(1)} KB'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('关闭'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('分享'),
            ),
          ],
        ),
      );
      
      if (shouldShare == true && mounted) {
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: '人生编年史数据导出 $fileName',
        );
      }
    } catch (e) {
      _showSnackBar('JSON 导出失败: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _loadAvailableBackups() async {
    if (_config == null) return;
    
    final db = ref.read(appDatabaseProvider);
    final backupService = BackupService(db);
    
    try {
      final backups = await backupService.listAvailableBackups(_config!);
      if (mounted) {
        setState(() => _availableBackups = backups);
      }
    } catch (e) {
      _showSnackBar('加载备份列表失败: $e', isError: true);
    }
  }

  Future<void> _restoreBackup(String fileName) async {
    if (_config == null) {
      _showSnackBar('请先配置 WebDAV', isError: true);
      return;
    }

    if (_encryptionPasswordController.text.isEmpty && _config!.encryptBackup) {
      _showSnackBar('请输入加密密码', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认恢复'),
        content: const Text('恢复数据将合并到当前数据中，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final db = ref.read(appDatabaseProvider);
    final backupService = BackupService(db);

    setState(() => _isRestoring = true);
    
    try {
      _progressSubscription = backupService.progressStream.listen((progress) {
        if (mounted) {
          setState(() => _currentProgress = progress);
        }
      });

      await backupService.restoreFromBackup(
        config: _config!,
        encryptionPassword: _encryptionPasswordController.text,
        backupFileName: fileName,
      );

      _showSnackBar('恢复成功！');
    } catch (e) {
      _showSnackBar('恢复失败: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
          _currentProgress = null;
        });
        _progressSubscription?.cancel();
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF101F22) : const Color(0xFFF6F8F8);
    final surfaceColor = isDark ? const Color(0xFF162A2E) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF1F2937);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final dividerColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '数据管理',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textMain,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildLastBackupSection(isDark, textMain, textMuted),
                    const SizedBox(height: 24),
                    _buildDataExportSection(isDark, surfaceColor, textMain, textMuted, dividerColor),
                    const SizedBox(height: 24),
                    _buildLocalBackupSection(isDark, surfaceColor, textMain, textMuted, dividerColor),
                    const SizedBox(height: 24),
                    _buildWebDavConfigSection(isDark, surfaceColor, textMain, textMuted, dividerColor),
                    const SizedBox(height: 24),
                    _buildAutomationSection(isDark, surfaceColor, textMain, textMuted, dividerColor),
                    const SizedBox(height: 24),
                    _buildRecoverySection(isDark, surfaceColor, textMain, textMuted),
                    const SizedBox(height: 24),
                    _buildFooterNote(isDark, textMuted),
                    const SizedBox(height: 100),
                  ],
                ),
                _buildBottomActionBar(isDark, surfaceColor, textMain),
              ],
            ),
    );
  }

  Widget _buildLastBackupSection(bool isDark, Color textMain, Color textMuted) {
    return Consumer(
      builder: (context, ref, _) {
        final db = ref.watch(appDatabaseProvider);
        return StreamBuilder<SyncStateData?>(
          stream: db.syncStateDao.watchDefault(),
          builder: (context, snapshot) {
            final lastSyncTime = snapshot.data?.lastSyncTime;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '上次备份时间',
                      style: TextStyle(
                        fontSize: 14,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastSyncTime != null
                          ? '${lastSyncTime.year}-${lastSyncTime.month.toString().padLeft(2, '0')}-${lastSyncTime.day.toString().padLeft(2, '0')} ${lastSyncTime.hour.toString().padLeft(2, '0')}:${lastSyncTime.minute.toString().padLeft(2, '0')}'
                          : '从未备份',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: textMain,
                      ),
                    ),
                  ],
                ),
                if (lastSyncTime != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: isDark ? const Color(0xFF065F46) : const Color(0xFFD1FAE5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '已同步',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDataExportSection(bool isDark, Color surfaceColor, Color textMain, Color textMuted, Color dividerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '数据导出',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)),
          ),
          child: Column(
            children: [
              _buildExportItem(
                isDark,
                textMain,
                textMuted,
                Icons.data_object,
                Colors.orange,
                'JSON 全量导出',
                '适合开发者或数据迁移',
                _isExporting ? null : _exportToJson,
              ),
              Divider(height: 1, color: dividerColor),
              _buildExportItem(
                isDark,
                textMain,
                textMuted,
                Icons.picture_as_pdf,
                Colors.red,
                'Excel / PDF 导出',
                '选择模块，适合阅读与打印',
                null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportItem(
    bool isDark,
    Color textMain,
    Color textMuted,
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
    VoidCallback? onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? iconColor.withValues(alpha: 0.1)
                      : iconColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocalBackupSection(bool isDark, Color surfaceColor, Color textMain, Color textMuted, Color dividerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '全量备份',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '全部数据json和图片等全部导出为一个压缩包，支持点击底部的本地恢复读取这个压缩包整体增量恢复',
                style: TextStyle(
                  fontSize: 14,
                  color: textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              if (_currentProgress != null) _buildProgressIndicator(isDark, textMain, textMuted),
              if (_currentProgress != null) const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: (_isBackingUp) ? null : _performLocalBackup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.backup),
                label: Text(_isBackingUp ? '备份中...' : '立即本地备份'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebDavConfigSection(bool isDark, Color surfaceColor, Color textMain, Color textMuted, Color dividerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'WebDAV 备份配置',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(
                isDark,
                textMain,
                textMuted,
                '服务器地址',
                Icons.link,
                _urlController,
                'https://dav.example.com',
                false,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                isDark,
                textMain,
                textMuted,
                '账户名称',
                Icons.person,
                _usernameController,
                'username@example.com',
                false,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                isDark,
                textMain,
                textMuted,
                '账户密码',
                Icons.lock,
                _passwordController,
                'password123',
              ),
              const SizedBox(height: 16),
              Divider(color: dividerColor),
              const SizedBox(height: 16),
              _buildSwitchRow(
                isDark,
                textMain,
                textMuted,
                '启用加密备份',
                '推荐开启，保护隐私安全',
                _config?.encryptBackup ?? true,
                (value) async {
                  if (_config != null) {
                    final newConfig = _config!.copyWith(encryptBackup: value);
                    await _configService.saveConfig(newConfig);
                    setState(() => _config = newConfig);
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _testConnection,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppTheme.primary),
                        foregroundColor: AppTheme.primary,
                      ),
                      child: const Text('测试连接'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveConfig,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('保存配置'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    bool isDark,
    Color textMain,
    Color textMuted,
    String label,
    IconData icon,
    TextEditingController controller,
    String hint,
    bool obscure,
  ) {
    final fillColor = isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: TextStyle(color: textMain, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: Icon(icon, color: textMuted, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    bool isDark,
    Color textMain,
    Color textMuted,
    String label,
    IconData icon,
    TextEditingController controller,
    String hint,
  ) {
    final fillColor = isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: _obscurePassword,
            style: TextStyle(color: textMain, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: Icon(icon, color: textMuted, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(
    bool isDark,
    Color textMain,
    Color textMuted,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
        _buildCustomSwitch(value, onChanged),
      ],
    );
  }

  Widget _buildCustomSwitch(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 52,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value ? AppTheme.primary : const Color(0xFFE5E7EB),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 22 : 2,
              top: 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutomationSection(bool isDark, Color surfaceColor, Color textMain, Color textMuted, Color dividerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '自动化',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildSwitchRow(
                  isDark,
                  textMain,
                  textMuted,
                  '自动备份',
                  '在 Wi-Fi 环境下自动同步',
                  _config?.autoBackup ?? false,
                  (value) async {
                    if (_config != null) {
                      final newConfig = _config!.copyWith(autoBackup: value);
                      await _configService.saveConfig(newConfig);
                      if (value) {
                        await _backgroundBackupService.registerPeriodicBackup(
                          frequency: newConfig.autoBackupFrequency ?? 'daily',
                          wifiOnly: newConfig.backupOnWifiOnly,
                        );
                      } else {
                        await _backgroundBackupService.cancelBackup();
                      }
                      setState(() => _config = newConfig);
                    }
                  },
                ),
              ),
              if (_config?.autoBackup ?? false) ...[
                Divider(height: 1, color: dividerColor),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '备份频率',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildFrequencyButton('每日', 'daily', isDark, surfaceColor, textMain, textMuted),
                            const SizedBox(width: 4),
                            _buildFrequencyButton('每周', 'weekly', isDark, surfaceColor, textMain, textMuted),
                            const SizedBox(width: 4),
                            _buildFrequencyButton('每月', 'monthly', isDark, surfaceColor, textMain, textMuted),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyButton(
    String label, String value, bool isDark, Color surfaceColor, Color textMain, Color textMuted,
  ) {
    final isSelected = _backupFrequency == value;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (_config != null) {
            setState(() {
              _backupFrequency = value;
            });
            final newConfig = _config!.copyWith(autoBackupFrequency: value);
            await _configService.saveConfig(newConfig);
            if (newConfig.autoBackup) {
              await _backgroundBackupService.registerPeriodicBackup(
                frequency: value,
                wifiOnly: newConfig.backupOnWifiOnly,
              );
            }
            setState(() => _config = newConfig);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? surfaceColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppTheme.primary : textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecoverySection(bool isDark, Color surfaceColor, Color textMain, Color textMuted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '数据恢复',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildRecoveryCard(
              isDark,
              surfaceColor,
              textMain,
              textMuted,
              Icons.cloud_download,
              AppTheme.primary,
              '从云端恢复',
              _isRestoring ? null : () async {
                await _loadAvailableBackups();
                if (_availableBackups.isNotEmpty && mounted) {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('选择备份文件', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          ),
                          const Divider(height: 1),
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _availableBackups.length,
                              itemBuilder: (context, index) {
                                final backup = _availableBackups[index];
                                final fileName = backup['fileName'] as String? ?? '未知文件';
                                final dateStr = backup['date'] as String? ?? '';
                                return ListTile(
                                  leading: const Icon(Icons.backup),
                                  title: Text(fileName),
                                  subtitle: Text(dateStr),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    _restoreBackup(fileName);
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
              },
            ),
            _buildRecoveryCard(
              isDark,
              surfaceColor,
              textMain,
              textMuted,
              Icons.folder_open,
              textMuted,
              '从本地文件恢复',
              _isRestoring ? null : _restoreFromLocal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecoveryCard(
    bool isDark,
    Color surfaceColor,
    Color textMain,
    Color textMuted,
    IconData icon,
    Color iconColor,
    String label,
    VoidCallback? onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.1),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textMain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterNote(bool isDark, Color textMuted) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, size: 16, color: textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '您的数据仅存储在本地或您配置的云端，',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: textMuted,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '人生博物馆无法查看任何内容。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(bool isDark, Color surfaceColor, Color textMain) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF101F22).withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BackupLogPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                    foregroundColor: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide.none,
                  ),
                  icon: const Icon(Icons.history, size: 20),
                  label: const Text('查看日志', style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: (_isBackingUp || _config == null) ? null : _performFullBackup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.sync, size: 20),
                  label: Text(
                    _isBackingUp ? '备份中...' : '立即备份',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark, Color textMain, Color textMuted) {
    final status = _currentProgress!.status;
    final statusText = {
          BackupStatus.idle: '准备中',
          BackupStatus.preparing: '准备中',
          BackupStatus.exporting: '导出数据',
          BackupStatus.zipping: '打包文件',
          BackupStatus.encrypting: '加密中',
          BackupStatus.uploading: '上传中',
          BackupStatus.downloading: '下载中',
          BackupStatus.completed: '完成',
          BackupStatus.failed: '失败',
        }[status] ??
        '处理中';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: _currentProgress!.progress,
          backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          _currentProgress!.message ?? statusText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textMuted,
          ),
        ),
        if (_currentProgress!.error != null) ...[
          const SizedBox(height: 8),
          Text(
            _currentProgress!.error!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
