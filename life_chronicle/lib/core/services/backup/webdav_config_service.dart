import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WebDavConfig {
  final String url;
  final String username;
  final String password;
  final String? backupPath;
  final bool enabled;
  final bool autoBackup;
  final String? autoBackupFrequency;
  final bool backupOnWifiOnly;
  final bool encryptBackup;
  final String? encryptionPasswordHint;
  final bool rememberPassword;
  final String? passwordHint;

  WebDavConfig({
    required this.url,
    required this.username,
    required this.password,
    this.backupPath = '/life_chronicle_backups/',
    this.enabled = false,
    this.autoBackup = false,
    this.autoBackupFrequency = 'daily',
    this.backupOnWifiOnly = true,
    this.encryptBackup = true,
    this.encryptionPasswordHint,
    this.rememberPassword = false,
    this.passwordHint,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'username': username,
      'password': password,
      'backupPath': backupPath,
      'enabled': enabled,
      'autoBackup': autoBackup,
      'autoBackupFrequency': autoBackupFrequency,
      'backupOnWifiOnly': backupOnWifiOnly,
      'encryptBackup': encryptBackup,
      'encryptionPasswordHint': encryptionPasswordHint,
      'rememberPassword': rememberPassword,
      'passwordHint': passwordHint,
    };
  }

  factory WebDavConfig.fromJson(Map<String, dynamic> json) {
    return WebDavConfig(
      url: json['url'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      backupPath: json['backupPath'] as String?,
      enabled: json['enabled'] as bool? ?? false,
      autoBackup: json['autoBackup'] as bool? ?? false,
      autoBackupFrequency: json['autoBackupFrequency'] as String?,
      backupOnWifiOnly: json['backupOnWifiOnly'] as bool? ?? true,
      encryptBackup: json['encryptBackup'] as bool? ?? true,
      encryptionPasswordHint: json['encryptionPasswordHint'] as String?,
      rememberPassword: json['rememberPassword'] as bool? ?? false,
      passwordHint: json['passwordHint'] as String?,
    );
  }

  WebDavConfig copyWith({
    String? url,
    String? username,
    String? password,
    String? backupPath,
    bool? enabled,
    bool? autoBackup,
    String? autoBackupFrequency,
    bool? backupOnWifiOnly,
    bool? encryptBackup,
    String? encryptionPasswordHint,
    bool? rememberPassword,
    String? passwordHint,
  }) {
    return WebDavConfig(
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      backupPath: backupPath ?? this.backupPath,
      enabled: enabled ?? this.enabled,
      autoBackup: autoBackup ?? this.autoBackup,
      autoBackupFrequency: autoBackupFrequency ?? this.autoBackupFrequency,
      backupOnWifiOnly: backupOnWifiOnly ?? this.backupOnWifiOnly,
      encryptBackup: encryptBackup ?? this.encryptBackup,
      encryptionPasswordHint: encryptionPasswordHint ?? this.encryptionPasswordHint,
      rememberPassword: rememberPassword ?? this.rememberPassword,
      passwordHint: passwordHint ?? this.passwordHint,
    );
  }

  bool isValid() {
    return url.isNotEmpty && username.isNotEmpty && password.isNotEmpty;
  }

  static const Map<String, String> jianguoyunPreset = {
    'url': 'https://dav.jianguoyun.com/dav/',
    'name': '坚果云',
  };

  static const Map<String, String> teracloudPreset = {
    'url': 'https://dav.teracloud.jp/dav/',
    'name': 'TeraCloud',
  };

  static const Map<String, String> pCloudPreset = {
    'url': 'https://webdav.pcloud.com/',
    'name': 'pCloud',
  };

  static const List<Map<String, String>> presets = [
    jianguoyunPreset,
    teracloudPreset,
    pCloudPreset,
  ];
}

class WebDavConfigService {
  static const String _storageKey = 'webdav_config';
  static const String _encryptionPasswordKey = 'backup_encryption_password';
  static const String _rememberPasswordKey = 'backup_remember_password';
  
  final FlutterSecureStorage _storage;

  WebDavConfigService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<WebDavConfig?> loadConfig() async {
    try {
      final jsonString = await _storage.read(key: _storageKey);
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return WebDavConfig.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveConfig(WebDavConfig config) async {
    final jsonString = jsonEncode(config.toJson());
    await _storage.write(key: _storageKey, value: jsonString);
  }

  Future<void> deleteConfig() async {
    await _storage.delete(key: _storageKey);
    await _storage.delete(key: _encryptionPasswordKey);
  }

  Future<void> saveEncryptionPassword(String password) async {
    await _storage.write(key: _encryptionPasswordKey, value: password);
  }

  Future<String?> loadEncryptionPassword() async {
    return await _storage.read(key: _encryptionPasswordKey);
  }

  Future<void> deleteEncryptionPassword() async {
    await _storage.delete(key: _encryptionPasswordKey);
  }

  Future<bool> hasConfig() async {
    final config = await loadConfig();
    return config != null;
  }

  Future<void> updateEnabled(bool enabled) async {
    final config = await loadConfig();
    if (config != null) {
      await saveConfig(config.copyWith(enabled: enabled));
    }
  }

  Future<void> updateAutoBackup(bool autoBackup) async {
    final config = await loadConfig();
    if (config != null) {
      await saveConfig(config.copyWith(autoBackup: autoBackup));
    }
  }

  Future<void> saveRememberPassword(bool remember) async {
    await _storage.write(key: _rememberPasswordKey, value: remember.toString());
  }

  Future<bool> loadRememberPassword() async {
    final value = await _storage.read(key: _rememberPasswordKey);
    return value == 'true';
  }

  Future<void> savePasswordHint(String hint) async {
    await _storage.write(key: '${_encryptionPasswordKey}_hint', value: hint);
  }

  Future<String?> loadPasswordHint() async {
    return await _storage.read(key: '${_encryptionPasswordKey}_hint');
  }
}
