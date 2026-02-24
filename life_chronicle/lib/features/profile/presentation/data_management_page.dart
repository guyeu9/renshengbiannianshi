import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/services/backup/backup.dart';

class DataManagementPage extends ConsumerStatefulWidget {
  const DataManagementPage({super.key});

  @override
  ConsumerState<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends ConsumerState<DataManagementPage> {
  final WebDavConfigService _configService = WebDavConfigService();
  WebDavConfig? _config;
  bool _isLoading = true;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  BackupProgress? _currentProgress;
  StreamSubscription<BackupProgress>? _progressSubscription;
  List<Map<String, dynamic>> _availableBackups = [];

  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _encryptionPasswordController = TextEditingController();

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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '数据管理',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildLastBackupSection(),
                const SizedBox(height: 16),
                _buildWebDavConfigSection(),
                const SizedBox(height: 16),
                _buildBackupOptionsSection(),
                const SizedBox(height: 16),
                _buildRestoreSection(),
                const SizedBox(height: 16),
                _buildLocalExportSection(),
              ],
            ),
    );
  }

  Widget _buildLastBackupSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      padding: const EdgeInsets.all(16),
      child: Consumer(
        builder: (context, ref, _) {
          final db = ref.watch(appDatabaseProvider);
          return StreamBuilder<SyncStateData?>(
            stream: db.syncStateDao.watchDefault(),
            builder: (context, snapshot) {
              final lastSyncTime = snapshot.data?.lastSyncTime;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '上次备份',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lastSyncTime != null
                        ? '${lastSyncTime.year}-${lastSyncTime.month.toString().padLeft(2, '0')}-${lastSyncTime.day.toString().padLeft(2, '0')} ${lastSyncTime.hour.toString().padLeft(2, '0')}:${lastSyncTime.minute.toString().padLeft(2, '0')}'
                        : '从未备份',
                    style: TextStyle(
                      fontSize: 14,
                      color: lastSyncTime != null ? const Color(0xFF4CAF50) : const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWebDavConfigSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WebDAV 配置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _buildPresetButtons(),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: '服务器地址',
              hintText: 'https://dav.jianguoyun.com/dav/',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: '用户名',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '密码/应用密码',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _testConnection,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('测试连接'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveConfig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8AB4F8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('保存配置'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: WebDavConfig.presets.map((preset) {
        return ActionChip(
          label: Text(preset['name']!),
          onPressed: () {
            _urlController.text = preset['url']!;
          },
        );
      }).toList(),
    );
  }

  Widget _buildBackupOptionsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '备份选项',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('启用加密'),
            subtitle: const Text('备份文件将使用 AES-256 加密'),
            value: _config?.encryptBackup ?? true,
            onChanged: (value) async {
              if (_config != null) {
                final newConfig = _config!.copyWith(encryptBackup: value);
                await _configService.saveConfig(newConfig);
                setState(() => _config = newConfig);
              }
            },
          ),
          if (_config?.encryptBackup ?? true) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _encryptionPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '加密密码',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('自动备份'),
            subtitle: const Text('定期自动备份到云端'),
            value: _config?.autoBackup ?? false,
            onChanged: (value) async {
              if (_config != null) {
                final newConfig = _config!.copyWith(autoBackup: value);
                await _configService.saveConfig(newConfig);
                setState(() => _config = newConfig);
              }
            },
          ),
          if (_config?.autoBackup ?? false) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _config?.autoBackupFrequency ?? 'daily',
              decoration: InputDecoration(
                labelText: '备份频率',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
              ),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('每天')),
                DropdownMenuItem(value: 'weekly', child: Text('每周')),
                DropdownMenuItem(value: 'monthly', child: Text('每月')),
              ],
              onChanged: (value) async {
                if (_config != null && value != null) {
                  final newConfig = _config!.copyWith(autoBackupFrequency: value);
                  await _configService.saveConfig(newConfig);
                  setState(() => _config = newConfig);
                }
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('仅 Wi-Fi 下备份'),
              subtitle: const Text('避免消耗移动数据流量'),
              value: _config?.backupOnWifiOnly ?? true,
              onChanged: (value) async {
                if (_config != null) {
                  final newConfig = _config!.copyWith(backupOnWifiOnly: value);
                  await _configService.saveConfig(newConfig);
                  setState(() => _config = newConfig);
                }
              },
            ),
          ],
          const SizedBox(height: 16),
          if (_currentProgress != null) _buildProgressIndicator(),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: (_isBackingUp || _config == null) ? null : _performFullBackup,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 0),
            ),
            icon: const Icon(Icons.cloud_upload),
            label: Text(_isBackingUp ? '备份中...' : '立即备份'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
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
          backgroundColor: const Color(0xFFE5E7EB),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8AB4F8)),
        ),
        const SizedBox(height: 8),
        Text(
          _currentProgress!.message ?? statusText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
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

  Widget _buildRestoreSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '数据恢复',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: (_isRestoring || _config == null) ? null : _loadAvailableBackups,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8AB4F8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('刷新备份列表'),
          ),
          const SizedBox(height: 16),
          if (_availableBackups.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  '暂无可用备份',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ..._availableBackups.map((backup) {
              final timestamp = backup['timestamp'] as int?;
              final fileName = backup['fileName'] as String?;
              final type = backup['type'] as String?;
              final date = timestamp != null
                  ? DateTime.fromMillisecondsSinceEpoch(timestamp)
                  : null;
              
              return ListTile(
                title: Text(
                  type == 'full' ? '全量备份' : '增量备份',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  date != null
                      ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
                      : fileName ?? '',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.restore),
                  onPressed: () {
                    if (fileName != null) {
                      _restoreBackup(fileName);
                    }
                  },
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLocalExportSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '本地导出',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '导出到本地文件（开发中）',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.description),
                  label: const Text('JSON 全量'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Excel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
