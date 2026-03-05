import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';

class ExcelExportService {
  final AppDatabase db;
  
  ExcelExportService(this.db);
  
  Future<String> exportToExcel({
    bool includeFood = true,
    bool includeMoment = true,
    bool includeFriend = true,
    bool includeTravel = true,
    bool includeGoal = true,
    bool includeTimeline = true,
  }) async {
    final excel = Excel.createExcel();
    
    if (includeFood) {
      await _exportFoodRecords(excel);
    }
    if (includeMoment) {
      await _exportMomentRecords(excel);
    }
    if (includeFriend) {
      await _exportFriendRecords(excel);
    }
    if (includeTravel) {
      await _exportTravelRecords(excel);
    }
    if (includeGoal) {
      await _exportGoalRecords(excel);
    }
    if (includeTimeline) {
      await _exportTimelineEvents(excel);
    }
    
    excel.delete('Sheet1');
    
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'life_chronicle_export_$timestamp.xlsx';
    final filePath = path.join(tempDir.path, fileName);
    
    final bytes = excel.encode();
    if (bytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(bytes);
    }
    
    return filePath;
  }
  
  Future<void> _exportFoodRecords(Excel excel) async {
    final records = await (db.select(db.foodRecords)).get();
    final sheet = excel['美食记录'];
    
    sheet.appendRow(['ID', '标题', '描述', '评分', '标签', '创建时间']);
    
    for (final record in records) {
      sheet.appendRow([
        record.id,
        record.title,
        record.description ?? '',
        record.rating?.toString() ?? '',
        record.tags?.join(', ') ?? '',
        record.createdAt.toIso8601String(),
      ]);
    }
  }
  
  Future<void> _exportMomentRecords(Excel excel) async {
    final records = await (db.select(db.momentRecords)).get();
    final sheet = excel['小确幸'];
    
    sheet.appendRow(['ID', '内容', '心情', '标签', '创建时间']);
    
    for (final record in records) {
      sheet.appendRow([
        record.id,
        record.content,
        record.mood ?? '',
        record.tags?.join(', ') ?? '',
        record.createdAt.toIso8601String(),
      ]);
    }
  }
  
  Future<void> _exportFriendRecords(Excel excel) async {
    final records = await (db.select(db.friendRecords)).get();
    final sheet = excel['羁绊'];
    
    sheet.appendRow(['ID', '姓名', '关系', '描述', '标签', '创建时间']);
    
    for (final record in records) {
      sheet.appendRow([
        record.id,
        record.name,
        record.relationship ?? '',
        record.description ?? '',
        record.tags?.join(', ') ?? '',
        record.createdAt.toIso8601String(),
      ]);
    }
  }
  
  Future<void> _exportTravelRecords(Excel excel) async {
    final records = await (db.select(db.travelRecords)).get();
    final sheet = excel['旅行'];
    
    sheet.appendRow(['ID', '目的地', '描述', '开始日期', '结束日期', '标签', '创建时间']);
    
    for (final record in records) {
      sheet.appendRow([
        record.id,
        record.destination,
        record.description ?? '',
        record.startDate?.toIso8601String() ?? '',
        record.endDate?.toIso8601String() ?? '',
        record.tags?.join(', ') ?? '',
        record.createdAt.toIso8601String(),
      ]);
    }
  }
  
  Future<void> _exportGoalRecords(Excel excel) async {
    final records = await (db.select(db.goalRecords)).get();
    final sheet = excel['目标'];
    
    sheet.appendRow(['ID', '标题', '描述', '状态', '优先级', '截止日期', '创建时间']);
    
    for (final record in records) {
      sheet.appendRow([
        record.id,
        record.title,
        record.description ?? '',
        record.status,
        record.priority ?? '',
        record.deadline?.toIso8601String() ?? '',
        record.createdAt.toIso8601String(),
      ]);
    }
  }
  
  Future<void> _exportTimelineEvents(Excel excel) async {
    final records = await (db.select(db.timelineEvents)).get();
    final sheet = excel['时间线'];
    
    sheet.appendRow(['ID', '标题', '描述', '日期', '类型', '创建时间']);
    
    for (final record in records) {
      sheet.appendRow([
        record.id,
        record.title,
        record.description ?? '',
        record.date.toIso8601String(),
        record.type ?? '',
        record.createdAt.toIso8601String(),
      ]);
    }
  }
  
  Future<void> shareExcel(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: '人生编年史数据导出',
    );
  }
}
