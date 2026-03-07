import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';

class MarkdownExportService {
  final AppDatabase db;
  
  MarkdownExportService(this.db);
  
  Future<String> exportToMarkdown({
    bool includeFood = true,
    bool includeMoment = true,
    bool includeFriend = true,
    bool includeTravel = true,
    bool includeGoal = true,
    bool includeTimeline = true,
    bool includePhotos = true,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final buffer = StringBuffer();
    
    await _writeCoverPage(buffer, startDate, endDate);
    buffer.writeln('---\n');
    
    await _writeOverviewSection(buffer,
      includeFood: includeFood,
      includeMoment: includeMoment,
      includeFriend: includeFriend,
      includeTravel: includeTravel,
      includeGoal: includeGoal,
      includeTimeline: includeTimeline,
      startDate: startDate,
      endDate: endDate,
    );
    buffer.writeln('---\n');
    
    if (includeFood) {
      await _writeFoodSection(buffer, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
      buffer.writeln('---\n');
    }
    
    if (includeMoment) {
      await _writeMomentSection(buffer, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
      buffer.writeln('---\n');
    }
    
    if (includeFriend) {
      await _writeFriendSection(buffer, includePhotos: includePhotos);
      buffer.writeln('---\n');
    }
    
    if (includeTravel) {
      await _writeTravelSection(buffer, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
      buffer.writeln('---\n');
    }
    
    if (includeGoal) {
      await _writeGoalSection(buffer);
      buffer.writeln('---\n');
    }
    
    if (includeTimeline) {
      await _writeTimelineSection(buffer, startDate: startDate, endDate: endDate);
    }
    
    final tempDir = await getTemporaryDirectory();
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final fileName = '人生编年史导出_$timestamp.md';
    final filePath = path.join(tempDir.path, fileName);
    
    final file = File(filePath);
    await file.writeAsString(buffer.toString(), encoding: utf8);
    
    return filePath;
  }
  
  Future<void> shareMarkdown(String filePath) async {
    await Share.shareXFiles([XFile(filePath)], text: '人生编年史 - Markdown导出');
  }
  
  Future<void> _writeCoverPage(StringBuffer buffer, DateTime? startDate, DateTime? endDate) async {
    buffer.writeln('# 人生编年史\n');
    buffer.writeln('> 数据导出报告\n');
    buffer.writeln('**导出时间**: ${DateTime.now().toString().split('.')[0]}\n');
    
    if (startDate != null || endDate != null) {
      final startStr = startDate != null 
          ? '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}' 
          : '不限';
      final endStr = endDate != null 
          ? '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}' 
          : '不限';
      buffer.writeln('**时间范围**: $startStr 至 $endStr\n');
    }
    
    buffer.writeln('\n---\n');
  }
  
  Future<void> _writeOverviewSection(StringBuffer buffer, {
    required bool includeFood,
    required bool includeMoment,
    required bool includeFriend,
    required bool includeTravel,
    required bool includeGoal,
    required bool includeTimeline,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    buffer.writeln('## 数据概览\n');
    
    if (includeFood) {
      var query = db.select(db.foodRecords);
      if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      buffer.writeln('- **美食记录**: $count 条');
    }
    
    if (includeMoment) {
      var query = db.select(db.momentRecords);
      if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      buffer.writeln('- **小确幸**: $count 条');
    }
    
    if (includeFriend) {
      final count = await (db.select(db.friendRecords)).get().then((r) => r.length);
      buffer.writeln('- **羁绊**: $count 位');
    }
    
    if (includeTravel) {
      var query = db.select(db.travelRecords);
      if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      buffer.writeln('- **旅行**: $count 条');
    }
    
    if (includeGoal) {
      final count = await (db.select(db.goalRecords)).get().then((r) => r.length);
      buffer.writeln('- **目标**: $count 条');
    }
    
    if (includeTimeline) {
      var query = db.select(db.timelineEvents);
      if (startDate != null) query = query..where((t) => t.startAt.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.startAt.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      buffer.writeln('- **时间线**: $count 个事件');
    }
    
    buffer.writeln('');
  }
  
  Future<void> _writeFoodSection(StringBuffer buffer, {
    required bool includePhotos,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = db.select(db.foodRecords);
    
    if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
    }
    
    final records = await query.get();
    
    if (records.isEmpty) return;
    
    buffer.writeln('## 第一章：美食记录\n');
    buffer.writeln('> 共 ${records.length} 条记录\n');
    
    for (final record in records) {
      buffer.writeln('### ${record.title}\n');
      
      if (record.isFavorite) {
        buffer.writeln('⭐ 已收藏\n');
      }
      
      buffer.writeln('- **菜系**: ${record.tags ?? '未知'}');
      buffer.writeln('- **评分**: ${record.rating}/5');
      buffer.writeln('- **日期**: ${record.recordDate.toString().split(' ')[0]}\n');
      
      if (record.content != null && record.content!.isNotEmpty) {
        buffer.writeln('#### 评价\n');
        buffer.writeln('${record.content}\n');
      }
      
      if (includePhotos && record.images != null && record.images!.isNotEmpty) {
        try {
          final imageList = jsonDecode(record.images!) as List<dynamic>;
          final imageCount = imageList.length;
          if (imageCount > 0) {
            buffer.writeln('#### 图片\n');
            buffer.writeln('> 包含 $imageCount 张图片\n');
          }
        } catch (e) {
          debugPrint('解析美食记录图片失败: $e');
        }
      }
      
      buffer.writeln('---\n');
    }
  }
  
  Future<void> _writeMomentSection(StringBuffer buffer, {
    required bool includePhotos,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = db.select(db.momentRecords);
    
    if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
    }
    
    final records = await query.get();
    
    if (records.isEmpty) return;
    
    buffer.writeln('## 第二章：小确幸\n');
    buffer.writeln('> 共 ${records.length} 条记录\n');
    
    for (final record in records) {
      buffer.writeln('### ${record.mood}\n');
      
      if (record.isFavorite) {
        buffer.writeln('❤️ 已收藏\n');
      }
      
      buffer.writeln('- **日期**: ${record.recordDate.toString().split(' ')[0]}\n');
      
      if (record.content != null && record.content!.isNotEmpty) {
        buffer.writeln('${record.content}\n');
      }
      
      if (includePhotos && record.images != null && record.images!.isNotEmpty) {
        try {
          final imageList = jsonDecode(record.images!) as List<dynamic>;
          final imageCount = imageList.length;
          if (imageCount > 0) {
            buffer.writeln('#### 图片\n');
            buffer.writeln('> 包含 $imageCount 张图片\n');
          }
        } catch (e) {
          debugPrint('解析小确幸图片失败: $e');
        }
      }
      
      buffer.writeln('---\n');
    }
  }
  
  Future<void> _writeFriendSection(StringBuffer buffer, {required bool includePhotos}) async {
    final records = await (db.select(db.friendRecords)).get();
    
    if (records.isEmpty) return;
    
    buffer.writeln('## 第三章：羁绊\n');
    buffer.writeln('> 共 ${records.length} 位好友\n');
    
    for (final record in records) {
      buffer.writeln('### ${record.name}\n');
      
      if (record.isFavorite) {
        buffer.writeln('⭐ 已收藏\n');
      }
      
      if (record.groupName != null && record.groupName!.isNotEmpty) {
        buffer.writeln('- **分组**: ${record.groupName}');
      }
      
      if (record.impressionTags != null && record.impressionTags!.isNotEmpty) {
        buffer.writeln('- **印象标签**: ${record.impressionTags}');
      }
      
      buffer.writeln('---\n');
    }
  }
  
  Future<void> _writeTravelSection(StringBuffer buffer, {
    required bool includePhotos,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = db.select(db.travelRecords);
    
    if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
    }
    
    final records = await query.get();
    
    if (records.isEmpty) return;
    
    buffer.writeln('## 第四章：旅行足迹\n');
    buffer.writeln('> 共 ${records.length} 条记录\n');
    
    for (final record in records) {
      buffer.writeln('### ${record.destination ?? '未知目的地'}\n');
      
      final status = record.isWishlist ? '愿望清单' : (record.wishlistDone ? '已完成' : '进行中');
      buffer.writeln('- **状态**: $status');
      
      if (record.planDate != null) {
        buffer.writeln('- **计划日期**: ${record.planDate!.toString().split(' ')[0]}');
      }
      
      buffer.writeln('- **记录日期**: ${record.recordDate.toString().split(' ')[0]}\n');
      
      if (record.content != null && record.content!.isNotEmpty) {
        buffer.writeln('#### 旅行计划\n');
        buffer.writeln('${record.content}\n');
      }
      
      if (includePhotos && record.images != null && record.images!.isNotEmpty) {
        try {
          final imageList = jsonDecode(record.images!) as List<dynamic>;
          final imageCount = imageList.length;
          if (imageCount > 0) {
            buffer.writeln('#### 图片\n');
            buffer.writeln('> 包含 $imageCount 张图片\n');
          }
        } catch (e) {
          debugPrint('解析旅行图片失败: $e');
        }
      }
      
      buffer.writeln('---\n');
    }
  }
  
  Future<void> _writeGoalSection(StringBuffer buffer) async {
    final records = await (db.select(db.goalRecords)).get();
    
    if (records.isEmpty) return;
    
    buffer.writeln('## 第五章：目标规划\n');
    buffer.writeln('> 共 ${records.length} 条记录\n');
    
    for (final record in records) {
      buffer.writeln('### ${record.title}\n');
      
      if (record.isFavorite) {
        buffer.writeln('⭐ 已收藏\n');
      }
      
      final status = record.isCompleted ? '✅ 已完成' : '⏳ 进行中';
      buffer.writeln('- **状态**: $status');
      
      if (record.dueDate != null) {
        buffer.writeln('- **截止日期**: ${record.dueDate!.toString().split(' ')[0]}');
      }
      if (record.targetYear != null) {
        buffer.writeln('- **目标年份**: ${record.targetYear}');
      }
      if (record.targetQuarter != null) {
        buffer.writeln('- **目标季度**: Q${record.targetQuarter}');
      }
      if (record.targetMonth != null) {
        buffer.writeln('- **目标月份**: ${record.targetMonth}');
      }
      
      buffer.writeln('- **创建日期**: ${record.recordDate.toString().split(' ')[0]}\n');
      
      if (record.note != null && record.note!.isNotEmpty) {
        buffer.writeln('#### 说明\n');
        buffer.writeln('${record.note}\n');
      }
      
      if (record.summary != null && record.summary!.isNotEmpty) {
        buffer.writeln('#### 总结\n');
        buffer.writeln('${record.summary}\n');
      }
      
      buffer.writeln('---\n');
    }
  }
  
  Future<void> _writeTimelineSection(StringBuffer buffer, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = db.select(db.timelineEvents)
      ..orderBy([(t) => OrderingTerm(expression: t.startAt, mode: OrderingMode.asc)]);
    
    if (startDate != null) query = query..where((t) => t.startAt.isBiggerOrEqualValue(startDate));
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query..where((t) => t.startAt.isSmallerOrEqualValue(endOfDay));
    }
    
    final records = await query.get();
    
    if (records.isEmpty) return;
    
    buffer.writeln('## 第六章：时间线\n');
    buffer.writeln('> 共 ${records.length} 个事件\n');
    
    for (final record in records) {
      buffer.writeln('### ${record.title}\n');
      
      buffer.writeln('- **类型**: ${record.eventType}');
      buffer.writeln('- **开始时间**: ${record.startAt.toString().split(' ')[0]}');
      
      if (record.endAt != null) {
        buffer.writeln('- **结束时间**: ${record.endAt!.toString().split(' ')[0]}');
      }
      
      if (record.note != null && record.note!.isNotEmpty) {
        buffer.writeln('\n#### 说明\n');
        buffer.writeln('${record.note}\n');
      }
      
      buffer.writeln('---\n');
    }
  }
}
