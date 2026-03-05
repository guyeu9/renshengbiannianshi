import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../database/app_database.dart';

class ModuleStatistics {
  final int recordCount;
  final int mediaFileCount;
  final int mediaFileSize;
  
  ModuleStatistics({
    required this.recordCount,
    required this.mediaFileCount,
    required this.mediaFileSize,
  });
  
  String get formattedMediaSize {
    if (mediaFileSize < 1024) return '$mediaFileSize B';
    if (mediaFileSize < 1024 * 1024) return '${(mediaFileSize / 1024).toStringAsFixed(1)} KB';
    if (mediaFileSize < 1024 * 1024 * 1024) {
      return '${(mediaFileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(mediaFileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class DataStatistics {
  final ModuleStatistics foodStats;
  final ModuleStatistics momentStats;
  final ModuleStatistics friendStats;
  final ModuleStatistics travelStats;
  final ModuleStatistics goalStats;
  final ModuleStatistics timelineStats;
  final int totalRecordCount;
  final int totalMediaFileCount;
  final int totalMediaFileSize;
  final int databaseSize;
  final DateTime? lastBackupTime;
  
  DataStatistics({
    required this.foodStats,
    required this.momentStats,
    required this.friendStats,
    required this.travelStats,
    required this.goalStats,
    required this.timelineStats,
    required this.totalRecordCount,
    required this.totalMediaFileCount,
    required this.totalMediaFileSize,
    required this.databaseSize,
    this.lastBackupTime,
  });
  
  // 向后兼容的 getter
  int get foodRecordCount => foodStats.recordCount;
  int get momentRecordCount => momentStats.recordCount;
  int get friendRecordCount => friendStats.recordCount;
  int get travelRecordCount => travelStats.recordCount;
  int get goalRecordCount => goalStats.recordCount;
  int get timelineEventCount => timelineStats.recordCount;
  int get mediaFileCount => totalMediaFileCount;
  int get mediaFileSize => totalMediaFileSize;
  
  String get formattedTotalMediaSize {
    if (totalMediaFileSize < 1024) return '$totalMediaFileSize B';
    if (totalMediaFileSize < 1024 * 1024) return '${(totalMediaFileSize / 1024).toStringAsFixed(1)} KB';
    if (totalMediaFileSize < 1024 * 1024 * 1024) {
      return '${(totalMediaFileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(totalMediaFileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
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
    // 获取各模块记录数
    final foodCount = await (db.select(db.foodRecords)).get().then((r) => r.length);
    final momentCount = await (db.select(db.momentRecords)).get().then((r) => r.length);
    final friendCount = await (db.select(db.friendRecords)).get().then((r) => r.length);
    final travelCount = await (db.select(db.travelRecords)).get().then((r) => r.length);
    final goalCount = await (db.select(db.goalRecords)).get().then((r) => r.length);
    final timelineCount = await (db.select(db.timelineEvents)).get().then((r) => r.length);
    
    // 获取各模块媒体文件统计
    final foodMediaStats = await _getModuleMediaStats('food');
    final momentMediaStats = await _getModuleMediaStats('moment');
    final friendMediaStats = await _getModuleMediaStats('friend');
    final travelMediaStats = await _getModuleMediaStats('travel');
    final goalMediaStats = await _getModuleMediaStats('goal');
    final timelineMediaStats = await _getModuleMediaStats('timeline');
    
    // 计算总数
    final totalMediaCount = foodMediaStats.$1 + momentMediaStats.$1 + friendMediaStats.$1 + 
                           travelMediaStats.$1 + goalMediaStats.$1 + timelineMediaStats.$1;
    final totalMediaSize = foodMediaStats.$2 + momentMediaStats.$2 + friendMediaStats.$2 + 
                          travelMediaStats.$2 + goalMediaStats.$2 + timelineMediaStats.$2;
    
    final dbSize = await _getDatabaseSize();
    final lastBackup = await db.backupLogDao.findLatestSuccessful();
    
    return DataStatistics(
      foodStats: ModuleStatistics(
        recordCount: foodCount,
        mediaFileCount: foodMediaStats.$1,
        mediaFileSize: foodMediaStats.$2,
      ),
      momentStats: ModuleStatistics(
        recordCount: momentCount,
        mediaFileCount: momentMediaStats.$1,
        mediaFileSize: momentMediaStats.$2,
      ),
      friendStats: ModuleStatistics(
        recordCount: friendCount,
        mediaFileCount: friendMediaStats.$1,
        mediaFileSize: friendMediaStats.$2,
      ),
      travelStats: ModuleStatistics(
        recordCount: travelCount,
        mediaFileCount: travelMediaStats.$1,
        mediaFileSize: travelMediaStats.$2,
      ),
      goalStats: ModuleStatistics(
        recordCount: goalCount,
        mediaFileCount: goalMediaStats.$1,
        mediaFileSize: goalMediaStats.$2,
      ),
      timelineStats: ModuleStatistics(
        recordCount: timelineCount,
        mediaFileCount: timelineMediaStats.$1,
        mediaFileSize: timelineMediaStats.$2,
      ),
      totalRecordCount: foodCount + momentCount + friendCount + travelCount + goalCount + timelineCount,
      totalMediaFileCount: totalMediaCount,
      totalMediaFileSize: totalMediaSize,
      databaseSize: dbSize,
      lastBackupTime: lastBackup?.completedAt,
    );
  }
  
  Future<(int, int)> _getModuleMediaStats(String moduleName) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final moduleDir = Directory(path.join(appDocDir.path, 'media', moduleName));
    
    if (!await moduleDir.exists()) {
      return (0, 0);
    }
    
    int count = 0;
    int totalSize = 0;
    
    await for (final entity in moduleDir.list(recursive: true)) {
      if (entity is File) {
        count++;
        totalSize += await entity.length();
      }
    }
    
    return (count, totalSize);
  }
  
  Future<int> _getDatabaseSize() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    // 使用正确的数据库文件名
    final dbFile = File(path.join(appDocDir.path, 'life_chronicle.sqlite'));
    
    if (!await dbFile.exists()) {
      // 尝试旧的数据库文件名
      final oldDbFile = File(path.join(appDocDir.path, 'life_chronicle.db'));
      if (await oldDbFile.exists()) {
        return await oldDbFile.length();
      }
      return 0;
    }
    
    return await dbFile.length();
  }
}
