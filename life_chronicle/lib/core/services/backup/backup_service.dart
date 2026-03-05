import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../database/app_database.dart';
import 'change_log_recorder.dart';
import 'encryption_service.dart';
import 'webdav_client.dart';
import 'webdav_config_service.dart';

enum BackupStatus {
  idle,
  preparing,
  exporting,
  zipping,
  encrypting,
  uploading,
  downloading,
  completed,
  failed,
}

class BackupProgress {
  final BackupStatus status;
  final double progress;
  final String? message;
  final String? error;

  BackupProgress({
    required this.status,
    this.progress = 0.0,
    this.message,
    this.error,
  });
}

class BackupService {
  final AppDatabase db;
  final ChangeLogRecorder changeLogRecorder;
  final Uuid uuid;
  final _progressController = StreamController<BackupProgress>.broadcast();

  Stream<BackupProgress> get progressStream => _progressController.stream;

  BackupService(this.db, {Uuid? uuid})
      : changeLogRecorder = ChangeLogRecorder(db),
        uuid = uuid ?? const Uuid();

  void dispose() {
    _progressController.close();
  }

  Future<String> _createBackupLog({
    required String backupType,
    required String storageType,
    required String fileName,
    String? filePath,
    DateTime? startedAt,
  }) async {
    final id = uuid.v4();
    await db.backupLogDao.insert(BackupLogsCompanion(
      id: Value(id),
      backupType: Value(backupType),
      storageType: Value(storageType),
      fileName: Value(fileName),
      filePath: Value(filePath),
      status: const Value('in_progress'),
      startedAt: Value(startedAt ?? DateTime.now()),
      createdAt: Value(DateTime.now()),
    ));
    return id;
  }

  Future<void> _updateBackupLogSuccess({
    required String logId,
    int? fileSize,
    int? recordCount,
    int? mediaCount,
    DateTime? completedAt,
  }) async {
    await db.backupLogDao.updateStatus(
      logId,
      'completed',
      completedAt: completedAt ?? DateTime.now(),
    );
    
    await (db.update(db.backupLogs)..where((t) => t.id.equals(logId))).write(
      BackupLogsCompanion(
        fileSize: Value(fileSize),
        recordCount: Value(recordCount),
        mediaCount: Value(mediaCount),
      ),
    );
  }

  Future<void> _updateBackupLogFailed({
    required String logId,
    required String errorMessage,
  }) async {
    await db.backupLogDao.updateStatus(
      logId,
      'failed',
      errorMessage: errorMessage,
      completedAt: DateTime.now(),
    );
  }

  int _countRecords(Map<String, dynamic> data) {
    int count = 0;
    for (final key in data.keys) {
      if (key.endsWith('_records') || key == 'trips' || key == 'checklist_items' || key == 'entity_links' || key == 'link_logs' || key == 'user_profiles' || key == 'ai_providers' || key == 'annual_reviews') {
        final value = data[key];
        if (value is List) {
          count += value.length;
        }
      }
    }
    return count;
  }

  Future<bool> isWifiConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.wifi;
  }

  Future<bool> isNetworkAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> checkNetworkConstraint({required bool wifiOnly}) async {
    if (!await isNetworkAvailable()) {
      throw Exception('网络不可用，请检查网络连接');
    }
    if (wifiOnly && !await isWifiConnected()) {
      throw Exception('当前非 Wi-Fi 网络，已跳过备份');
    }
  }

  void _emitProgress(BackupStatus status, {double progress = 0.0, String? message, String? error}) {
    _progressController.add(
      BackupProgress(
        status: status,
        progress: progress,
        message: message,
        error: error,
      ),
    );
  }

  Future<Directory> getTempDir() async {
    final tempDir = await getTemporaryDirectory();
    final backupDir = Directory(path.join(tempDir.path, 'life_chronicle_backup'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  Future<Directory> getExportDir() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(path.join(appDocDir.path, 'exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  Future<Directory> getMediaDir() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(path.join(appDocDir.path, 'media'));
    return mediaDir;
  }

  Future<String> _getDatabasePath() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return path.join(appDocDir.path, 'life_chronicle.db');
  }

  Future<Map<String, dynamic>> exportAllData() async {
    final exportData = <String, dynamic>{};

    exportData['food_records'] = await _exportFoodRecords();
    exportData['moment_records'] = await _exportMomentRecords();
    exportData['friend_records'] = await _exportFriendRecords();
    exportData['travel_records'] = await _exportTravelRecords();
    exportData['trips'] = await _exportTrips();
    exportData['goal_records'] = await _exportGoalRecords();
    exportData['goal_postponements'] = await _exportGoalPostponements();
    exportData['goal_reviews'] = await _exportGoalReviews();
    exportData['timeline_events'] = await _exportTimelineEvents();
    exportData['entity_links'] = await _exportEntityLinks();
    exportData['link_logs'] = await _exportLinkLogs();
    exportData['user_profiles'] = await _exportUserProfiles();
    exportData['ai_providers'] = await _exportAiProviders();
    exportData['checklist_items'] = await _exportChecklistItems();
    exportData['annual_reviews'] = await _exportAnnualReviews();
    exportData['exported_at'] = DateTime.now().toIso8601String();
    exportData['schema_version'] = db.schemaVersion;

    return exportData;
  }

  Future<List<Map<String, dynamic>>> _exportFoodRecords() async {
    final records = await (db.select(db.foodRecords)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportMomentRecords() async {
    final records = await (db.select(db.momentRecords)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportFriendRecords() async {
    final records = await (db.select(db.friendRecords)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportTravelRecords() async {
    final records = await (db.select(db.travelRecords)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportTrips() async {
    final records = await (db.select(db.trips)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportGoalRecords() async {
    final records = await (db.select(db.goalRecords)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportTimelineEvents() async {
    final records = await (db.select(db.timelineEvents)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportEntityLinks() async {
    final records = await (db.select(db.entityLinks)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportLinkLogs() async {
    final records = await (db.select(db.linkLogs)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportUserProfiles() async {
    final records = await (db.select(db.userProfiles)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportAiProviders() async {
    final records = await (db.select(db.aiProviders)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportChecklistItems() async {
    final records = await (db.select(db.checklistItems)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportGoalPostponements() async {
    final records = await (db.select(db.goalPostponements)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportGoalReviews() async {
    final records = await (db.select(db.goalReviews)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportAnnualReviews() async {
    final records = await (db.select(db.annualReviews)).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<File>> collectAllMediaFiles() async {
    final mediaDir = await getMediaDir();
    if (!await mediaDir.exists()) {
      return [];
    }

    final allowedExtensions = {'.jpg', '.jpeg', '.png', '.gif', '.mp4', '.mov', '.mp3', '.wav', '.webp', '.heic'};
    final excludedPatterns = ['temp_', 'tmp_', '.tmp', 'cache_', '.cache'];
    
    final files = <File>[];
    await for (final entity in mediaDir.list(recursive: true)) {
      if (entity is File) {
        final fileName = path.basename(entity.path).toLowerCase();
        final extension = path.extension(fileName).toLowerCase();
        
        if (!allowedExtensions.contains(extension)) {
          continue;
        }
        
        if (excludedPatterns.any((pattern) => fileName.contains(pattern))) {
          continue;
        }
        
        files.add(entity);
      }
    }
    return files;
  }

  Future<void> importData(Map<String, dynamic> data, {bool merge = true}) async {
    if (data.containsKey('food_records')) {
      await _importFoodRecords(List<Map<String, dynamic>>.from(data['food_records']), merge: merge);
    }
    if (data.containsKey('moment_records')) {
      await _importMomentRecords(List<Map<String, dynamic>>.from(data['moment_records']), merge: merge);
    }
    if (data.containsKey('friend_records')) {
      await _importFriendRecords(List<Map<String, dynamic>>.from(data['friend_records']), merge: merge);
    }
    if (data.containsKey('travel_records')) {
      await _importTravelRecords(List<Map<String, dynamic>>.from(data['travel_records']), merge: merge);
    }
    if (data.containsKey('trips')) {
      await _importTrips(List<Map<String, dynamic>>.from(data['trips']), merge: merge);
    }
    if (data.containsKey('goal_records')) {
      await _importGoalRecords(List<Map<String, dynamic>>.from(data['goal_records']), merge: merge);
    }
    if (data.containsKey('goal_postponements')) {
      await _importGoalPostponements(List<Map<String, dynamic>>.from(data['goal_postponements']), merge: merge);
    }
    if (data.containsKey('goal_reviews')) {
      await _importGoalReviews(List<Map<String, dynamic>>.from(data['goal_reviews']), merge: merge);
    }
    if (data.containsKey('timeline_events')) {
      await _importTimelineEvents(List<Map<String, dynamic>>.from(data['timeline_events']), merge: merge);
    }
    if (data.containsKey('entity_links')) {
      await _importEntityLinks(List<Map<String, dynamic>>.from(data['entity_links']), merge: merge);
    }
    if (data.containsKey('link_logs')) {
      await _importLinkLogs(List<Map<String, dynamic>>.from(data['link_logs']), merge: merge);
    }
    if (data.containsKey('user_profiles')) {
      await _importUserProfiles(List<Map<String, dynamic>>.from(data['user_profiles']), merge: merge);
    }
    if (data.containsKey('ai_providers')) {
      await _importAiProviders(List<Map<String, dynamic>>.from(data['ai_providers']), merge: merge);
    }
    if (data.containsKey('checklist_items')) {
      await _importChecklistItems(List<Map<String, dynamic>>.from(data['checklist_items']), merge: merge);
    }
    if (data.containsKey('annual_reviews')) {
      await _importAnnualReviews(List<Map<String, dynamic>>.from(data['annual_reviews']), merge: merge);
    }
  }

  Future<void> _importFoodRecords(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = FoodRecord.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.foodDao.upsert(companion);
      } else {
        await db.into(db.foodRecords).insert(companion);
      }
    }
  }

  Future<void> _importMomentRecords(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = MomentRecord.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.into(db.momentRecords).insertOnConflictUpdate(companion);
      } else {
        await db.into(db.momentRecords).insert(companion);
      }
    }
  }

  Future<void> _importFriendRecords(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = FriendRecord.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.into(db.friendRecords).insertOnConflictUpdate(companion);
      } else {
        await db.into(db.friendRecords).insert(companion);
      }
    }
  }

  Future<void> _importTravelRecords(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = TravelRecord.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.into(db.travelRecords).insertOnConflictUpdate(companion);
      } else {
        await db.into(db.travelRecords).insert(companion);
      }
    }
  }

  Future<void> _importTrips(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = Trip.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.into(db.trips).insertOnConflictUpdate(companion);
      } else {
        await db.into(db.trips).insert(companion);
      }
    }
  }

  Future<void> _importGoalRecords(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = GoalRecord.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.into(db.goalRecords).insertOnConflictUpdate(companion);
      } else {
        await db.into(db.goalRecords).insert(companion);
      }
    }
  }

  Future<void> _importTimelineEvents(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = TimelineEvent.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.into(db.timelineEvents).insertOnConflictUpdate(companion);
      } else {
        await db.into(db.timelineEvents).insert(companion);
      }
    }
  }

  Future<void> _importEntityLinks(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = EntityLink.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.into(db.entityLinks).insertOnConflictUpdate(companion);
      } else {
        await db.into(db.entityLinks).insert(companion);
      }
    }
  }

  Future<void> _importLinkLogs(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = LinkLog.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.into(db.linkLogs).insertOnConflictUpdate(companion);
      } else {
        await db.into(db.linkLogs).insert(companion);
      }
    }
  }

  Future<void> _importUserProfiles(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = UserProfile.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.into(db.userProfiles).insertOnConflictUpdate(companion);
      } else {
        await db.into(db.userProfiles).insert(companion);
      }
    }
  }

  Future<void> _importAiProviders(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = AiProvider.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.into(db.aiProviders).insertOnConflictUpdate(companion);
      } else {
        await db.into(db.aiProviders).insert(companion);
      }
    }
  }

  Future<void> _importChecklistItems(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = ChecklistItem.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.into(db.checklistItems).insertOnConflictUpdate(companion);
      } else {
        await db.into(db.checklistItems).insert(companion);
      }
    }
  }

  Future<void> _importGoalPostponements(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = GoalPostponement.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.into(db.goalPostponements).insertOnConflictUpdate(companion);
      } else {
        await db.into(db.goalPostponements).insert(companion);
      }
    }
  }

  Future<void> _importGoalReviews(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = GoalReview.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.into(db.goalReviews).insertOnConflictUpdate(companion);
      } else {
        await db.into(db.goalReviews).insert(companion);
      }
    }
  }

  Future<void> _importAnnualReviews(List<Map<String, dynamic>> records, {bool merge = true}) async {
    for (final record in records) {
      final entity = AnnualReview.fromJson(record);
      final companion = entity.toCompanion(false);
      if (merge) {
        await db.into(db.annualReviews).insertOnConflictUpdate(companion);
      } else {
        await db.into(db.annualReviews).insert(companion);
      }
    }
  }

  Future<void> performFullBackup({
    required WebDavConfig config,
    required String encryptionPassword,
  }) async {
    final startedAt = DateTime.now();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'life_chronicle_full_$timestamp.zip';
    String? logId;
    
    _emitProgress(BackupStatus.preparing, message: '准备备份...');
    
    try {
      logId = await _createBackupLog(
        backupType: 'full',
        storageType: 'cloud',
        fileName: fileName,
        startedAt: startedAt,
      );
      
      if (config.backupOnWifiOnly) {
        await checkNetworkConstraint(wifiOnly: true);
      } else {
        await checkNetworkConstraint(wifiOnly: false);
      }
      
      final tempDir = await getTempDir();
      final zipPath = path.join(tempDir.path, fileName);
      
      _emitProgress(BackupStatus.exporting, progress: 0.1, message: '导出数据...');
      final data = await exportAllData();
      final mediaFiles = await collectAllMediaFiles();
      
      _emitProgress(BackupStatus.zipping, progress: 0.3, message: '打包文件...');
      final zipFile = await EncryptionService.createZipArchive(
        mediaFiles,
        data,
        zipPath,
      );
      
      File encryptedFile = zipFile;
      if (config.encryptBackup) {
        _emitProgress(BackupStatus.encrypting, progress: 0.5, message: '加密备份...');
        encryptedFile = await EncryptionService.encryptFile(
          zipFile,
          encryptionPassword,
        );
      }
      
      _emitProgress(BackupStatus.uploading, progress: 0.7, message: '上传到 WebDAV...');
      final client = WebDavClient(
        baseUrl: config.url,
        username: config.username,
        password: config.password,
      );
      
      final backupPath = config.backupPath ?? '/life_chronicle_backups/';
      await client.createDirectory(backupPath);
      
      final remoteFileName = path.basename(encryptedFile.path);
      final remotePath = path.join(backupPath, remoteFileName);
      await client.uploadFile(encryptedFile, remotePath);
      
      await _updateSyncState(timestamp);
      await _saveBackupManifest(
        client,
        backupPath,
        'full',
        remoteFileName,
        timestamp,
      );
      
      final fileSize = await encryptedFile.length();
      final recordCount = _countRecords(data);
      final mediaCount = mediaFiles.length;
      
      await _updateBackupLogSuccess(
        logId: logId,
        fileSize: fileSize,
        recordCount: recordCount,
        mediaCount: mediaCount,
      );
      
      _emitProgress(BackupStatus.completed, progress: 1.0, message: '备份完成！');
    } catch (e) {
      if (logId != null) {
        await _updateBackupLogFailed(
          logId: logId,
          errorMessage: e.toString(),
        );
      }
      _emitProgress(BackupStatus.failed, error: e.toString());
      rethrow;
    }
  }

  Future<void> performIncrementalBackup({
    required WebDavConfig config,
    required String encryptionPassword,
  }) async {
    final startedAt = DateTime.now();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'life_chronicle_inc_$timestamp.zip';
    String? logId;
    
    _emitProgress(BackupStatus.preparing, message: '准备增量备份...');
    
    try {
      logId = await _createBackupLog(
        backupType: 'incremental',
        storageType: 'cloud',
        fileName: fileName,
        startedAt: startedAt,
      );
      
      if (config.backupOnWifiOnly) {
        await checkNetworkConstraint(wifiOnly: true);
      } else {
        await checkNetworkConstraint(wifiOnly: false);
      }
      
      final lastSyncState = await db.syncStateDao.getDefault();
      final lastSyncChangeId = lastSyncState?.lastSyncChangeId ?? 0;
      
      final unsyncedChanges = await db.changeLogDao.findUnsynced();
      if (unsyncedChanges.isEmpty) {
        await _updateBackupLogSuccess(
          logId: logId,
          recordCount: 0,
          mediaCount: 0,
        );
        _emitProgress(BackupStatus.completed, message: '没有需要备份的变更');
        return;
      }
      
      final nonIncrementalEntityTypes = ['entity_links', 'link_logs', 'user_profiles', 'ai_providers'];
      final hasNonIncrementalChanges = unsyncedChanges.any(
        (c) => nonIncrementalEntityTypes.contains(c.entityType),
      );
      
      if (hasNonIncrementalChanges) {
        _emitProgress(BackupStatus.preparing, message: '检测到配置变更，执行全量备份...');
        await performFullBackup(config: config, encryptionPassword: encryptionPassword);
        return;
      }
      
      final tempDir = await getTempDir();
      final zipPath = path.join(tempDir.path, fileName);
      
      _emitProgress(BackupStatus.exporting, progress: 0.1, message: '导出变更数据...');
      final incrementalData = await _exportIncrementalData(unsyncedChanges);
      final changedMediaFiles = await _collectChangedMediaFiles(unsyncedChanges);
      
      _emitProgress(BackupStatus.zipping, progress: 0.3, message: '打包文件...');
      final zipFile = await EncryptionService.createZipArchive(
        changedMediaFiles,
        incrementalData,
        zipPath,
      );
      
      File encryptedFile = zipFile;
      if (config.encryptBackup) {
        _emitProgress(BackupStatus.encrypting, progress: 0.5, message: '加密备份...');
        encryptedFile = await EncryptionService.encryptFile(
          zipFile,
          encryptionPassword,
        );
      }
      
      _emitProgress(BackupStatus.uploading, progress: 0.7, message: '上传到 WebDAV...');
      final client = WebDavClient(
        baseUrl: config.url,
        username: config.username,
        password: config.password,
      );
      
      final backupPath = config.backupPath ?? '/life_chronicle_backups/';
      await client.createDirectory(backupPath);
      
      final remoteFileName = path.basename(encryptedFile.path);
      final remotePath = path.join(backupPath, remoteFileName);
      await client.uploadFile(encryptedFile, remotePath);
      
      final maxChangeId = unsyncedChanges.map((c) => c.id).reduce((a, b) => a > b ? a : b);
      await _updateSyncState(timestamp, maxChangeId);
      await db.changeLogDao.markAllAsSyncedByIds(unsyncedChanges.map((c) => c.id).toList());
      
      await _saveBackupManifest(
        client,
        backupPath,
        'incremental',
        remoteFileName,
        timestamp,
        lastSyncChangeId,
      );
      
      final fileSize = await encryptedFile.length();
      final recordCount = _countRecords(incrementalData);
      final mediaCount = changedMediaFiles.length;
      
      await _updateBackupLogSuccess(
        logId: logId,
        fileSize: fileSize,
        recordCount: recordCount,
        mediaCount: mediaCount,
      );
      
      _emitProgress(BackupStatus.completed, progress: 1.0, message: '增量备份完成！');
    } catch (e) {
      if (logId != null) {
        await _updateBackupLogFailed(
          logId: logId,
          errorMessage: e.toString(),
        );
      }
      _emitProgress(BackupStatus.failed, error: e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _exportIncrementalData(List<ChangeLog> changes) async {
    final data = <String, dynamic>{};
    final entityIdsByType = <String, Set<String>>{};
    
    for (final change in changes) {
      if (!entityIdsByType.containsKey(change.entityType)) {
        entityIdsByType[change.entityType] = <String>{};
      }
      entityIdsByType[change.entityType]!.add(change.entityId);
    }
    
    data['changes'] = changes.map((c) => c.toJson()).toList();
    data['food_records'] = await _exportFoodRecordsByIds(entityIdsByType['food_records']?.toList() ?? []);
    data['moment_records'] = await _exportMomentRecordsByIds(entityIdsByType['moment_records']?.toList() ?? []);
    data['friend_records'] = await _exportFriendRecordsByIds(entityIdsByType['friend_records']?.toList() ?? []);
    data['travel_records'] = await _exportTravelRecordsByIds(entityIdsByType['travel_records']?.toList() ?? []);
    data['trips'] = await _exportTripsByIds(entityIdsByType['trips']?.toList() ?? []);
    data['goal_records'] = await _exportGoalRecordsByIds(entityIdsByType['goal_records']?.toList() ?? []);
    data['timeline_events'] = await _exportTimelineEventsByIds(entityIdsByType['timeline_events']?.toList() ?? []);
    data['checklist_items'] = await _exportChecklistItemsByIds(entityIdsByType['checklist_items']?.toList() ?? []);
    data['annual_reviews'] = await _exportAnnualReviewsByIds(entityIdsByType['annual_reviews']?.toList() ?? []);
    data['exported_at'] = DateTime.now().toIso8601String();
    
    return data;
  }

  Future<List<File>> _collectChangedMediaFiles(List<ChangeLog> changes) async {
    final mediaDir = await getMediaDir();
    if (!await mediaDir.exists()) return [];
    
    final files = <File>[];
    final changedFileNames = <String>{};
    
    for (final change in changes) {
      if (change.changedFields != null) {
        try {
          final fields = jsonDecode(change.changedFields!);
          if (fields is Map<String, dynamic>) {
            for (final value in fields.values) {
              if (value is String && (value.endsWith('.jpg') || value.endsWith('.png') || value.endsWith('.jpeg'))) {
                changedFileNames.add(path.basename(value));
              }
            }
          }
        } catch (_) {}
      }
    }
    
    await for (final entity in mediaDir.list(recursive: true)) {
      if (entity is File && changedFileNames.contains(path.basename(entity.path))) {
        files.add(entity);
      }
    }
    
    return files;
  }

  Future<List<Map<String, dynamic>>> _exportFoodRecordsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final records = await (db.select(db.foodRecords)..where((t) => t.id.isIn(ids))).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportMomentRecordsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final records = await (db.select(db.momentRecords)..where((t) => t.id.isIn(ids))).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportFriendRecordsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final records = await (db.select(db.friendRecords)..where((t) => t.id.isIn(ids))).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportTravelRecordsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final records = await (db.select(db.travelRecords)..where((t) => t.id.isIn(ids))).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportTripsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final records = await (db.select(db.trips)..where((t) => t.id.isIn(ids))).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportGoalRecordsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final records = await (db.select(db.goalRecords)..where((t) => t.id.isIn(ids))).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportTimelineEventsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final records = await (db.select(db.timelineEvents)..where((t) => t.id.isIn(ids))).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportChecklistItemsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final records = await (db.select(db.checklistItems)..where((t) => t.id.isIn(ids))).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportAnnualReviewsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final records = await (db.select(db.annualReviews)..where((t) => t.id.isIn(ids))).get();
    return records.map((r) => r.toJson()).toList();
  }

  Future<void> _updateSyncState(int timestamp, [int? lastChangeId]) async {
    final deviceId = uuid.v4();
    await db.syncStateDao.upsert(SyncStateCompanion(
      id: const Value('main'),
      lastSyncTime: Value(DateTime.fromMillisecondsSinceEpoch(timestamp)),
      lastSyncChangeId: lastChangeId != null ? Value(lastChangeId) : const Value(null),
      deviceId: Value(deviceId),
    ));
  }

  Future<void> _saveBackupManifest(
    WebDavClient client,
    String backupPath,
    String type,
    String fileName,
    int timestamp, [
    int? baseChangeId,
  ]) async {
    final tempDir = await getTempDir();
    final manifestPath = path.join(tempDir.path, 'backup_manifest.json');
    
    Map<String, dynamic>? existingManifest;
    try {
      final remoteManifestPath = path.join(backupPath, 'backup_manifest.json');
      if (await client.exists(remoteManifestPath)) {
        final localManifestPath = path.join(tempDir.path, 'existing_manifest.json');
        await client.downloadFile(remoteManifestPath, localManifestPath);
        final manifestString = await File(localManifestPath).readAsString();
        existingManifest = jsonDecode(manifestString) as Map<String, dynamic>;
      }
    } catch (_) {}
    
    final newBackup = {
      'type': type,
      'fileName': fileName,
      'timestamp': timestamp,
      'baseChangeId': baseChangeId,
    };
    
    final backups = (existingManifest?['backups'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    backups.add(newBackup);
    
    final manifest = {
      'version': '1.0',
      'lastUpdated': DateTime.now().toIso8601String(),
      'backups': backups,
    };
    
    final manifestFile = File(manifestPath);
    await manifestFile.writeAsString(jsonEncode(manifest));
    
    final remoteManifestPath = path.join(backupPath, 'backup_manifest.json');
    await client.uploadFile(manifestFile, remoteManifestPath);
  }

  Future<void> restoreFromBackup({
    required WebDavConfig config,
    required String encryptionPassword,
    required String backupFileName,
  }) async {
    _emitProgress(BackupStatus.preparing, message: '准备恢复...');
    
    try {
      final tempDir = await getTempDir();
      final extractDir = path.join(tempDir.path, 'extract');
      
      _emitProgress(BackupStatus.downloading, progress: 0.1, message: '下载备份...');
      final client = WebDavClient(
        baseUrl: config.url,
        username: config.username,
        password: config.password,
      );
      
      final backupPath = config.backupPath ?? '/life_chronicle_backups/';
      final remotePath = path.join(backupPath, backupFileName);
      final localFilePath = path.join(tempDir.path, backupFileName);
      
      await client.downloadFile(remotePath, localFilePath);
      
      File decryptedFile = File(localFilePath);
      if (config.encryptBackup) {
        _emitProgress(BackupStatus.encrypting, progress: 0.3, message: '解密备份...');
        decryptedFile = await EncryptionService.decryptFile(
          File(localFilePath),
          encryptionPassword,
        );
      }
      
      _emitProgress(BackupStatus.zipping, progress: 0.5, message: '解压文件...');
      final (data, mediaFiles) = await EncryptionService.extractZipArchive(
        decryptedFile,
        extractDir,
      );
      
      _emitProgress(BackupStatus.exporting, progress: 0.7, message: '创建快照...');
      snapshotPath = await _createLocalSnapshot();
      
      try {
        _emitProgress(BackupStatus.exporting, progress: 0.8, message: '恢复数据...');
        await importData(data, merge: true);
        await _restoreMediaFiles(mediaFiles);
        
        _emitProgress(BackupStatus.completed, progress: 1.0, message: '恢复完成！');
      } catch (e) {
        _emitProgress(BackupStatus.preparing, message: '恢复失败，正在回滚...');
        await _restoreFromSnapshot();
        rethrow;
      }
    } catch (e) {
      _emitProgress(BackupStatus.failed, error: e.toString());
      rethrow;
    }
  }

  Future<String> _createLocalSnapshot() async {
    final tempDir = await getTempDir();
    final snapshotDir = Directory(path.join(tempDir.path, 'snapshot_${DateTime.now().millisecondsSinceEpoch}'));
    await snapshotDir.create(recursive: true);
    
    final dbPath = await _getDatabasePath();
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.copy(path.join(snapshotDir.path, 'database.db'));
    }
    
    final mediaDir = await getMediaDir();
    final mediaFiles = <String>[];
    if (await mediaDir.exists()) {
      await for (final entity in mediaDir.list(recursive: true)) {
        if (entity is File) {
          mediaFiles.add(entity.path);
        }
      }
    }
    
    final metadata = {
      'createdAt': DateTime.now().toIso8601String(),
      'mediaFiles': mediaFiles,
    };
    final metadataFile = File(path.join(snapshotDir.path, 'metadata.json'));
    await metadataFile.writeAsString(jsonEncode(metadata));
    
    return snapshotDir.path;
  }

  Future<void> _restoreFromSnapshot() async {
    try {
      final tempDir = await getTempDir();
      final snapshotDirs = await tempDir.list().where((entity) => 
        entity is Directory && path.basename(entity.path).startsWith('snapshot_')
      ).toList();
      
      if (snapshotDirs.isEmpty) {
        _emitProgress(BackupStatus.failed, error: '未找到快照文件');
        return;
      }
      
      snapshotDirs.sort((a, b) => b.path.compareTo(a.path));
      final latestSnapshot = snapshotDirs.first as Directory;
      
      final dbPath = await _getDatabasePath();
      final snapshotDb = File(path.join(latestSnapshot.path, 'database.db'));
      if (await snapshotDb.exists()) {
        await snapshotDb.copy(dbPath);
      }
      
      final metadataFile = File(path.join(latestSnapshot.path, 'metadata.json'));
      if (await metadataFile.exists()) {
        await metadataFile.readAsString();
      }
      
      _emitProgress(BackupStatus.completed, message: '已从快照恢复');
    } catch (e) {
      _emitProgress(BackupStatus.failed, error: '快照恢复失败: $e');
    }
  }

  Future<void> clearAllData() async {
    await (db.delete(db.foodRecords)).go();
    await (db.delete(db.momentRecords)).go();
    await (db.delete(db.friendRecords)).go();
    await (db.delete(db.travelRecords)).go();
    await (db.delete(db.goalRecords)).go();
    await (db.delete(db.timelineEvents)).go();
    await (db.delete(db.trips)).go();
    await (db.delete(db.checklistItems)).go();
    await (db.delete(db.entityLinks)).go();
    await (db.delete(db.linkLogs)).go();
    await (db.delete(db.goalPostponements)).go();
    await (db.delete(db.goalReviews)).go();
    await (db.delete(db.annualReviews)).go();
    await (db.delete(db.changeLogs)).go();
    await (db.delete(db.backupLogs)).go();
    
    final mediaDir = await getMediaDir();
    if (await mediaDir.exists()) {
      await mediaDir.delete(recursive: true);
      await mediaDir.create(recursive: true);
    }
    
    await (db.delete(db.syncState)).go();
  }

  Future<void> _restoreMediaFiles(List<File> mediaFiles) async {
    final targetMediaDir = await getMediaDir();
    if (!await targetMediaDir.exists()) {
      await targetMediaDir.create(recursive: true);
    }
    
    for (final file in mediaFiles) {
      final fileName = path.basename(file.path);
      final targetPath = path.join(targetMediaDir.path, fileName);
      await file.copy(targetPath);
    }
  }

  Future<List<Map<String, dynamic>>> listAvailableBackups(WebDavConfig config) async {
    final client = WebDavClient(
      baseUrl: config.url,
      username: config.username,
      password: config.password,
    );
    
    final backupPath = config.backupPath ?? '/life_chronicle_backups/';
    final manifestRemotePath = path.join(backupPath, 'backup_manifest.json');
    
    try {
      if (!await client.exists(manifestRemotePath)) {
        return [];
      }
      
      final tempDir = await getTempDir();
      final localManifestPath = path.join(tempDir.path, 'manifest.json');
      await client.downloadFile(manifestRemotePath, localManifestPath);
      
      final manifestString = await File(localManifestPath).readAsString();
      final manifest = jsonDecode(manifestString) as Map<String, dynamic>;
      
      return (manifest['backups'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      return [];
    }
  }
}
