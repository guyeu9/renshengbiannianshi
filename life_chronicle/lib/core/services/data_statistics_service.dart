import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../database/app_database.dart';

class DataStatistics {
  final int foodRecordCount;
  final int momentRecordCount;
  final int friendRecordCount;
  final int travelRecordCount;
  final int goalRecordCount;
  final int timelineEventCount;
  final int totalRecordCount;
  final int mediaFileCount;
  final int mediaFileSize;
  final int databaseSize;
  final DateTime? lastBackupTime;
  
  DataStatistics({
    required this.foodRecordCount,
    required this.momentRecordCount,
    required this.friendRecordCount,
    required this.travelRecordCount,
    required this.goalRecordCount,
    required this.timelineEventCount,
    required this.totalRecordCount,
    required this.mediaFileCount,
    required this.mediaFileSize,
    required this.databaseSize,
    this.lastBackupTime,
  });
  
  String get formattedMediaSize {
    if (mediaFileSize < 1024) return '$mediaFileSize B';
    if (mediaFileSize < 1024 * 1024) return '${(mediaFileSize / 1024).toStringAsFixed(1)} KB';
    if (mediaFileSize < 1024 * 1024 * 1024) {
      return '${(mediaFileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(mediaFileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  String get formattedDatabaseSize {
    if (databaseSize < 1024) return '$databaseSize B';
    if (databaseSize < 1024 * 1024) return '${(databaseSize / 1024).toStringAsFixed(1)} KB';
    if (databaseSize < 1024 * 1024 * 1024) {
      return '${(databaseSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(databaseSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class DataStatisticsService {
  final AppDatabase db;
  
  DataStatisticsService(this.db);
  
  Future<DataStatistics> getStatistics() async {
    final foodCount = await (db.select(db.foodRecords)).get().then((r) => r.length);
    final momentCount = await (db.select(db.momentRecords)).get().then((r) => r.length);
    final friendCount = await (db.select(db.friendRecords)).get().then((r) => r.length);
    final travelCount = await (db.select(db.travelRecords)).get().then((r) => r.length);
    final goalCount = await (db.select(db.goalRecords)).get().then((r) => r.length);
    final timelineCount = await (db.select(db.timelineEvents)).get().then((r) => r.length);
    
    final mediaStats = await _getMediaStats();
    final dbSize = await _getDatabaseSize();
    final lastBackup = await db.backupLogDao.findLatestSuccessful();
    
    return DataStatistics(
      foodRecordCount: foodCount,
      momentRecordCount: momentCount,
      friendRecordCount: friendCount,
      travelRecordCount: travelCount,
      goalRecordCount: goalCount,
      timelineEventCount: timelineCount,
      totalRecordCount: foodCount + momentCount + friendCount + travelCount + goalCount + timelineCount,
      mediaFileCount: mediaStats.$1,
      mediaFileSize: mediaStats.$2,
      databaseSize: dbSize,
      lastBackupTime: lastBackup?.completedAt,
    );
  }
  
  Future<(int, int)> _getMediaStats() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(path.join(appDocDir.path, 'media'));
    
    if (!await mediaDir.exists()) {
      return (0, 0);
    }
    
    int count = 0;
    int totalSize = 0;
    
    await for (final entity in mediaDir.list(recursive: true)) {
      if (entity is File) {
        count++;
        totalSize += await entity.length();
      }
    }
    
    return (count, totalSize);
  }
  
  Future<int> _getDatabaseSize() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbFile = File(path.join(appDocDir.path, 'life_chronicle.db'));
    
    if (!await dbFile.exists()) {
      return 0;
    }
    
    return await dbFile.length();
  }
}
