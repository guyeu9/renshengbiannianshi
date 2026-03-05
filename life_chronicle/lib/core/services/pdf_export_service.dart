import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';

class PdfExportService {
  final AppDatabase db;
  
  static const _primaryColor = PdfColor.fromInt(0xFF4F46E5);
  static const _secondaryColor = PdfColor.fromInt(0xFF10B981);
  static const _accentColor = PdfColor.fromInt(0xFFF59E0B);
  static const _textColor = PdfColor.fromInt(0xFF1F2937);
  static const _mutedColor = PdfColor.fromInt(0xFF6B7280);
  static const _bgColor = PdfColor.fromInt(0xFFF9FAFB);
  
  PdfExportService(this.db);
  
  Future<String> exportToPdf({
    bool includeFood = true,
    bool includeMoment = true,
    bool includeFriend = true,
    bool includeTravel = true,
    bool includeGoal = true,
    bool includeTimeline = true,
    bool includeCover = true,
    bool includeToc = true,
    bool includeCharts = true,
    bool includePhotos = true,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();
    
    if (includeCover) {
      pdf.addPage(_createCoverPage(startDate: startDate, endDate: endDate));
    }
    
    if (includeToc) {
      pdf.addPage(_createTableOfContents(
        includeFood: includeFood,
        includeMoment: includeMoment,
        includeFriend: includeFriend,
        includeTravel: includeTravel,
        includeGoal: includeGoal,
        includeTimeline: includeTimeline,
      ));
    }
    
    pdf.addPage(await _createOverviewChapter(
      includeFood: includeFood,
      includeMoment: includeMoment,
      includeFriend: includeFriend,
      includeTravel: includeTravel,
      includeGoal: includeGoal,
      includeTimeline: includeTimeline,
      startDate: startDate,
      endDate: endDate,
    ));
    
    if (includeFood) {
      await _addFoodChapter(pdf, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
    }
    if (includeMoment) {
      await _addMomentChapter(pdf, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
    }
    if (includeFriend) {
      await _addFriendChapter(pdf);
    }
    if (includeTravel) {
      await _addTravelChapter(pdf, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
    }
    if (includeGoal) {
      await _addGoalChapter(pdf);
    }
    if (includeTimeline) {
      await _addTimelineChapter(pdf, startDate: startDate, endDate: endDate);
    }
    
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'life_chronicle_export_$timestamp.pdf';
    final filePath = path.join(tempDir.path, fileName);
    
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    
    return filePath;
  }
  
  pw.Page _createCoverPage({DateTime? startDate, DateTime? endDate}) {
    String dateRangeText = '';
    if (startDate != null || endDate != null) {
      final startStr = startDate != null 
          ? '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}' 
          : '不限';
      final endStr = endDate != null 
          ? '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}' 
          : '不限';
      dateRangeText = '\n时间范围: $startStr 至 $endStr';
    }
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        decoration: const pw.BoxDecoration(
          gradient: pw.LinearGradient(
            colors: [_primaryColor, _secondaryColor],
            begin: pw.Alignment.topLeft,
            end: pw.Alignment.bottomRight,
          ),
        ),
        child: pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Container(
                width: 80,
                height: 80,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(40),
                ),
                child: pw.Center(
                  child: pw.Text('📖', style: const pw.TextStyle(fontSize: 40)),
                ),
              ),
              const pw.SizedBox(height: 30),
              pw.Text(
                '人生编年史',
                style: pw.TextStyle(
                  fontSize: 36,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              const pw.SizedBox(height: 16),
              pw.Text(
                '数据导出报告',
                style: const pw.TextStyle(
                  fontSize: 20,
                  color: PdfColors.white,
                ),
              ),
              const pw.SizedBox(height: 50),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white.withOpacity(0.2),
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  '导出日期: ${DateTime.now().toString().split('.')[0]}$dateRangeText',
                  style: const pw.TextStyle(color: PdfColors.white),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  pw.Page _createTableOfContents({
    required bool includeFood,
    required bool includeMoment,
    required bool includeFriend,
    required bool includeTravel,
    required bool includeGoal,
    required bool includeTimeline,
  }) {
    final chapters = <pw.Widget>[];
    int chapterNum = 1;
    
    chapters.add(_buildTocItem('第一章', '数据概览', chapterNum++));
    
    if (includeFood) chapters.add(_buildTocItem('第二章', '美食记忆', chapterNum++));
    if (includeMoment) chapters.add(_buildTocItem('第三章', '小确幸时刻', chapterNum++));
    if (includeFriend) chapters.add(_buildTocItem('第四章', '羁绊故事', chapterNum++));
    if (includeTravel) chapters.add(_buildTocItem('第五章', '旅行足迹', chapterNum++));
    if (includeGoal) chapters.add(_buildTocItem('第六章', '目标征程', chapterNum++));
    if (includeTimeline) chapters.add(_buildTocItem('第七章', '时间线', chapterNum++));
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('目录', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: _primaryColor)),
            const pw.SizedBox(height: 30),
            ...chapters,
          ],
        ),
      ),
    );
  }
  
  pw.Widget _buildTocItem(String chapter, String title, int page) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 60,
            child: pw.Text(chapter, style: pw.TextStyle(color: _mutedColor)),
          ),
          pw.Expanded(
            child: pw.Text(title, style: const pw.TextStyle(fontSize: 14)),
          ),
          pw.Text('......', style: pw.TextStyle(color: _mutedColor)),
          const pw.SizedBox(width: 10),
          pw.Text('$page', style: pw.TextStyle(color: _mutedColor)),
        ],
      ),
    );
  }
  
  Future<pw.Page> _createOverviewChapter({
    required bool includeFood,
    required bool includeMoment,
    required bool includeFriend,
    required bool includeTravel,
    required bool includeGoal,
    required bool includeTimeline,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final stats = <pw.Widget>[];
    
    if (includeFood) {
      var query = db.select(db.foodRecords);
      if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      stats.add(_buildStatCard('🍜 美食记录', count, _primaryColor));
    }
    if (includeMoment) {
      var query = db.select(db.momentRecords);
      if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      stats.add(_buildStatCard('✨ 小确幸', count, _secondaryColor));
    }
    if (includeFriend) {
      final count = await (db.select(db.friendRecords)).get().then((r) => r.length);
      stats.add(_buildStatCard('💕 羁绊', count, const PdfColor.fromInt(0xFFEC4899)));
    }
    if (includeTravel) {
      var query = db.select(db.travelRecords);
      if (startDate != null) query = query..where((t) => t.startDate.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.startDate.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      stats.add(_buildStatCard('✈️ 旅行', count, _accentColor));
    }
    if (includeGoal) {
      final count = await (db.select(db.goalRecords)).get().then((r) => r.length);
      stats.add(_buildStatCard('🎯 目标', count, const PdfColor.fromInt(0xFF8B5CF6)));
    }
    if (includeTimeline) {
      var query = db.select(db.timelineEvents);
      if (startDate != null) query = query..where((t) => t.startAt.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.startAt.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      stats.add(_buildStatCard('⏳ 时间线', count, const PdfColor.fromInt(0xFF6366F1)));
    }
    
    String dateRangeText = '';
    if (startDate != null || endDate != null) {
      final startStr = startDate != null 
          ? '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}' 
          : '不限';
      final endStr = endDate != null 
          ? '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}' 
          : '不限';
      dateRangeText = ' ($startStr 至 $endStr)';
    }
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('第一章 数据概览$dateRangeText', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: _primaryColor)),
            const pw.SizedBox(height: 20),
            pw.Text('记录统计', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            const pw.SizedBox(height: 16),
            pw.Wrap(
              spacing: 16,
              runSpacing: 16,
              children: stats,
            ),
          ],
        ),
      ),
    );
  }
  
  pw.Widget _buildStatCard(String title, int count, PdfColor color) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 12, color: _mutedColor)),
          const pw.SizedBox(height: 8),
          pw.Text('$count', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }
  
  Future<void> _addFoodChapter(pw.Document pdf, {required bool includePhotos, DateTime? startDate, DateTime? endDate}) async {
    var query = db.select(db.foodRecords);
    
    if (startDate != null) {
      query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
    }
    
    final records = await query.get();
    
    if (records.isEmpty) return;
    
    final avgRating = records.map((r) => r.rating ?? 0).reduce((a, b) => a + b) / records.length;
    final totalExpense = records.map((r) => r.pricePerPerson ?? 0).reduce((a, b) => a + b);
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _primaryColor, width: 2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('第二章 美食记忆', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _primaryColor)),
              pw.Text('人生编年史', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '第 ${context.pageNumber} 页',
            style: pw.TextStyle(fontSize: 10, color: _mutedColor),
          ),
        ),
        build: (context) => [
          const pw.SizedBox(height: 20),
          pw.Row(
            children: [
              _buildMiniStat('总记录', '${records.length}'),
              const pw.SizedBox(width: 20),
              _buildMiniStat('平均评分', avgRating.toStringAsFixed(1)),
              const pw.SizedBox(width: 20),
              _buildMiniStat('总消费', '¥${totalExpense.toStringAsFixed(0)}'),
            ],
          ),
          const pw.SizedBox(height: 20),
          ...records.map((record) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(record.title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ),
                    if (record.rating != null)
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: record.rating! >= 4.5 ? _secondaryColor.withOpacity(0.2) : _bgColor,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text('⭐ ${record.rating}', style: const pw.TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                if (record.content != null) ...[
                  const pw.SizedBox(height: 8),
                  pw.Text(record.content!, style: pw.TextStyle(fontSize: 11, color: _textColor)),
                ],
                const pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    if (record.poiName != null) pw.Text('📍 ${record.poiName}', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
                    if (record.poiName != null && record.city != null) pw.Text(' · ', style: pw.TextStyle(color: _mutedColor)),
                    if (record.city != null) pw.Text(record.city!, style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
                    const pw.Spacer(),
                    pw.Text(record.recordDate.toString().split(' ')[0], style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  pw.Widget _buildMiniStat(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: pw.BoxDecoration(
        color: _bgColor,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _primaryColor)),
          const pw.SizedBox(height: 4),
          pw.Text(label, style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
        ],
      ),
    );
  }
  
  Future<void> _addMomentChapter(pw.Document pdf, {required bool includePhotos, DateTime? startDate, DateTime? endDate}) async {
    var query = db.select(db.momentRecords);
    
    if (startDate != null) {
      query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
    }
    
    final records = await query.get();
    
    if (records.isEmpty) return;
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _secondaryColor, width: 2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('第三章 小确幸时刻', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _secondaryColor)),
              pw.Text('人生编年史', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('第 ${context.pageNumber} 页', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
        ),
        build: (context) => [
          const pw.SizedBox(height: 20),
          pw.Row(
            children: [
              _buildMiniStat('总记录', '${records.length}'),
              const pw.SizedBox(width: 20),
              _buildMiniStat('收藏', '${records.where((r) => r.isFavorite).length}'),
            ],
          ),
          const pw.SizedBox(height: 20),
          ...records.map((record) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(record.content, style: pw.TextStyle(fontSize: 12)),
                const pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    if (record.mood != null) pw.Text('😊 ${record.mood}', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
                    const pw.Spacer(),
                    pw.Text(record.recordDate.toString().split(' ')[0], style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Future<void> _addFriendChapter(pw.Document pdf) async {
    final records = await (db.select(db.friendRecords)).get();
    
    if (records.isEmpty) return;
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFEC4899), width: 2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('第四章 羁绊故事', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFFEC4899))),
              pw.Text('人生编年史', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('第 ${context.pageNumber} 页', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
        ),
        build: (context) => [
          const pw.SizedBox(height: 20),
          pw.Row(
            children: [
              _buildMiniStat('总羁绊', '${records.length}'),
              const pw.SizedBox(width: 20),
              _buildMiniStat('收藏', '${records.where((r) => r.isFavorite).length}'),
            ],
          ),
          const pw.SizedBox(height: 20),
          ...records.map((record) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(record.name, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    if (record.relationship != null) ...[
                      const pw.SizedBox(width: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: pw.BoxDecoration(
                          color: _bgColor,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(record.relationship!, style: pw.TextStyle(fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                if (record.impressionTags?.isNotEmpty == true) ...[
                  const pw.SizedBox(height: 8),
                  pw.Text('印象: ${record.impressionTags!.join(', ')}', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
                ],
                if (record.meetDate != null) ...[
                  const pw.SizedBox(height: 4),
                  pw.Text('相识于: ${record.meetDate!.toString().split(' ')[0]}', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
                ],
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Future<void> _addTravelChapter(pw.Document pdf, {required bool includePhotos, DateTime? startDate, DateTime? endDate}) async {
    var query = db.select(db.travelRecords);
    
    if (startDate != null) {
      query = query..where((t) => t.startDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query..where((t) => t.startDate.isSmallerOrEqualValue(endOfDay));
    }
    
    final records = await query.get();
    
    if (records.isEmpty) return;
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _accentColor, width: 2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('第五章 旅行足迹', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _accentColor)),
              pw.Text('人生编年史', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('第 ${context.pageNumber} 页', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
        ),
        build: (context) => [
          const pw.SizedBox(height: 20),
          pw.Row(
            children: [
              _buildMiniStat('总旅行', '${records.length}'),
              const pw.SizedBox(width: 20),
              _buildMiniStat('目的地', '${records.map((r) => r.destination).toSet().length}'),
            ],
          ),
          const pw.SizedBox(height: 20),
          ...records.map((record) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(record.destination, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                if (record.description != null) ...[
                  const pw.SizedBox(height: 8),
                  pw.Text(record.description!, style: pw.TextStyle(fontSize: 11)),
                ],
                const pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Text(
                      '${record.startDate?.toString().split(' ')[0] ?? ''} - ${record.endDate?.toString().split(' ')[0] ?? ''}',
                      style: pw.TextStyle(fontSize: 10, color: _mutedColor),
                    ),
                    if (record.city != null) ...[
                      const pw.SizedBox(width: 16),
                      pw.Text('📍 ${record.city}', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
                    ],
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Future<void> _addGoalChapter(pw.Document pdf) async {
    final records = await (db.select(db.goalRecords)).get();
    
    if (records.isEmpty) return;
    
    final completedCount = records.where((r) => r.status == 'completed').length;
    final inProgressCount = records.where((r) => r.status == 'in_progress').length;
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF8B5CF6), width: 2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('第六章 目标征程', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF8B5CF6))),
              pw.Text('人生编年史', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('第 ${context.pageNumber} 页', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
        ),
        build: (context) => [
          const pw.SizedBox(height: 20),
          pw.Row(
            children: [
              _buildMiniStat('总目标', '${records.length}'),
              const pw.SizedBox(width: 20),
              _buildMiniStat('已完成', '$completedCount'),
              const pw.SizedBox(width: 20),
              _buildMiniStat('进行中', '$inProgressCount'),
            ],
          ),
          const pw.SizedBox(height: 20),
          ...records.map((record) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(record.title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: record.status == 'completed' ? _secondaryColor.withOpacity(0.2) : _accentColor.withOpacity(0.2),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        record.status == 'completed' ? '已完成' : (record.status == 'in_progress' ? '进行中' : record.status),
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                if (record.note != null) ...[
                  const pw.SizedBox(height: 8),
                  pw.Text(record.note!, style: pw.TextStyle(fontSize: 11)),
                ],
                const pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Text('进度: ${record.progress}%', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
                    if (record.deadline != null) ...[
                      const pw.SizedBox(width: 16),
                      pw.Text('截止: ${record.deadline!.toString().split(' ')[0]}', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
                    ],
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Future<void> _addTimelineChapter(pw.Document pdf, {DateTime? startDate, DateTime? endDate}) async {
    var query = db.select(db.timelineEvents);
    
    if (startDate != null) {
      query = query..where((t) => t.startAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query..where((t) => t.startAt.isSmallerOrEqualValue(endOfDay));
    }
    
    final records = await query.get();
    
    if (records.isEmpty) return;
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF6366F1), width: 2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('第七章 时间线', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF6366F1))),
              pw.Text('人生编年史', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('第 ${context.pageNumber} 页', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
        ),
        build: (context) => [
          const pw.SizedBox(height: 20),
          pw.Row(
            children: [
              _buildMiniStat('总事件', '${records.length}'),
              const pw.SizedBox(width: 20),
              _buildMiniStat('收藏', '${records.where((r) => r.isFavorite).length}'),
            ],
          ),
          const pw.SizedBox(height: 20),
          ...records.map((record) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(record.title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ),
                    if (record.type != null)
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: _bgColor,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(record.type!, style: const pw.TextStyle(fontSize: 10)),
                      ),
                  ],
                ),
                if (record.description != null) ...[
                  const pw.SizedBox(height: 8),
                  pw.Text(record.description!, style: pw.TextStyle(fontSize: 11)),
                ],
                const pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Text(
                      '${record.startAt?.toString().split('.')[0] ?? ''}',
                      style: pw.TextStyle(fontSize: 10, color: _mutedColor),
                    ),
                    if (record.poiName != null) ...[
                      const pw.SizedBox(width: 16),
                      pw.Text('📍 ${record.poiName}', style: pw.TextStyle(fontSize: 10, color: _mutedColor)),
                    ],
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Future<void> sharePdf(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: '人生编年史PDF导出',
    );
  }
}
