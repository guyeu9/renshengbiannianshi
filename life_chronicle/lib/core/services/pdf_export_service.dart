import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
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
  
  pw.Font? _chineseFont;
  pw.Font? _chineseFontBold;
  bool _fontsLoaded = false;
  
  PdfExportService(this.db);
  
  Future<void> _loadFonts() async {
    if (_fontsLoaded) return;
    
    try {
      final systemFontPaths = [
        '/system/fonts/NotoSansCJK-Regular.ttc',
        '/system/fonts/NotoSansSC-Regular.otf',
        '/system/fonts/NotoSansCJKsc-Regular.otf',
        '/system/fonts/DroidSansFallbackFull.ttf',
        '/system/fonts/DroidSansFallback.ttf',
        '/system/fonts/SourceHanSansSC-Regular.otf',
        '/system/fonts/Roboto-Regular.ttf',
        '/system/fonts/sans-serif.ttf',
        'C:\\Windows\\Fonts\\msyh.ttc',
        'C:\\Windows\\Fonts\\simhei.ttf',
        'C:\\Windows\\Fonts\\simsun.ttc',
        '/System/Library/Fonts/PingFang.ttc',
        '/System/Library/Fonts/STHeiti Light.ttc',
        '/System/Library/Fonts/Hiragino Sans GB.ttc',
      ];
      
      final boldFontPaths = [
        '/system/fonts/NotoSansCJK-Bold.ttc',
        '/system/fonts/NotoSansSC-Bold.otf',
        '/system/fonts/SourceHanSansSC-Bold.otf',
        'C:\\Windows\\Fonts\\msyhbd.ttc',
        'C:\\Windows\\Fonts\\simhei.ttf',
        '/System/Library/Fonts/PingFang.ttc',
      ];
      
      for (final fontPath in systemFontPaths) {
        try {
          final file = File(fontPath);
          if (await file.exists()) {
            final fontData = await file.readAsBytes();
            _chineseFont = pw.Font.ttf(ByteData.sublistView(Uint8List.fromList(fontData)));
            debugPrint('成功加载系统字体: $fontPath');
            break;
          }
        } catch (e) {
          debugPrint('加载字体 $fontPath 失败: $e');
          continue;
        }
      }
      
      for (final fontPath in boldFontPaths) {
        try {
          final file = File(fontPath);
          if (await file.exists()) {
            final fontData = await file.readAsBytes();
            _chineseFontBold = pw.Font.ttf(ByteData.sublistView(Uint8List.fromList(fontData)));
            debugPrint('成功加载粗体字体: $fontPath');
            break;
          }
        } catch (e) {
          debugPrint('加载粗体字体 $fontPath 失败: $e');
          continue;
        }
      }
      
      _chineseFontBold ??= _chineseFont;
      
      _fontsLoaded = true;
    } catch (e, stack) {
      debugPrint('无法加载系统字体: $e');
      debugPrint('堆栈: $stack');
      _fontsLoaded = true;
    }
  }
  
  pw.TextStyle _textStyle({
    double fontSize = 12,
    bool bold = false,
    PdfColor color = _textColor,
  }) {
    return pw.TextStyle(
      fontSize: fontSize,
      color: color,
      font: bold ? (_chineseFontBold ?? _chineseFont) : _chineseFont,
    );
  }
  
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
    debugPrint('开始PDF导出...');
    await _loadFonts();
    
    final pdf = pw.Document();
    
    try {
      if (includeCover) {
        debugPrint('创建封面页...');
        pdf.addPage(await _createCoverPage(startDate: startDate, endDate: endDate));
      }
      
      if (includeToc) {
        debugPrint('创建目录页...');
        pdf.addPage(await _createTableOfContents(
          includeFood: includeFood,
          includeMoment: includeMoment,
          includeFriend: includeFriend,
          includeTravel: includeTravel,
          includeGoal: includeGoal,
          includeTimeline: includeTimeline,
        ));
      }
      
      debugPrint('创建概览章节...');
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
        debugPrint('添加美食章节...');
        await _addFoodChapter(pdf, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
      }
      if (includeMoment) {
        debugPrint('添加小确幸章节...');
        await _addMomentChapter(pdf, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
      }
      if (includeFriend) {
        debugPrint('添加羁绊章节...');
        await _addFriendChapter(pdf, includePhotos: includePhotos);
      }
      if (includeTravel) {
        debugPrint('添加旅行章节...');
        await _addTravelChapter(pdf, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
      }
      if (includeGoal) {
        debugPrint('添加目标章节...');
        await _addGoalChapter(pdf);
      }
      if (includeTimeline) {
        debugPrint('添加时间线章节...');
        await _addTimelineChapter(pdf, startDate: startDate, endDate: endDate);
      }
      
      debugPrint('保存PDF文件...');
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final fileName = '人生编年史导出_$timestamp.pdf';
      final filePath = path.join(tempDir.path, fileName);
      
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      debugPrint('PDF导出成功: $filePath');
      return filePath;
    } catch (e, stack) {
      debugPrint('PDF导出错误: $e');
      debugPrint('堆栈: $stack');
      rethrow;
    }
  }
  
  Future<void> sharePdf(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: '人生编年史导出',
          text: '人生编年史数据导出报告',
        );
      }
    } catch (e, stack) {
      debugPrint('分享PDF错误: $e');
      debugPrint('堆栈: $stack');
      rethrow;
    }
  }
  
  Future<pw.Page> _createCoverPage({DateTime? startDate, DateTime? endDate}) async {
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
        decoration: pw.BoxDecoration(
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
                width: 120,
                height: 120,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(60),
                ),
                child: pw.Center(
                  child: pw.Text('LC', style: _textStyle(fontSize: 48, bold: true, color: _primaryColor)),
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                '人生编年史',
                style: _textStyle(fontSize: 42, bold: true, color: PdfColors.white),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                '数据导出报告',
                style: _textStyle(fontSize: 24, color: PdfColors.white),
              ),
              pw.SizedBox(height: 60),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0x33FFFFFF),
                  borderRadius: pw.BorderRadius.circular(24),
                ),
                child: pw.Text(
                  '导出日期: ${DateTime.now().toString().split('.')[0]}$dateRangeText',
                  style: _textStyle(color: PdfColors.white, fontSize: 14),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<pw.Page> _createTableOfContents({
    required bool includeFood,
    required bool includeMoment,
    required bool includeFriend,
    required bool includeTravel,
    required bool includeGoal,
    required bool includeTimeline,
  }) async {
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
            pw.Text('目录', style: _textStyle(fontSize: 32, bold: true, color: _primaryColor)),
            pw.SizedBox(height: 40),
            ...chapters,
          ],
        ),
      ),
    );
  }
  
  pw.Widget _buildTocItem(String chapter, String title, int page) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 12),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(chapter, style: _textStyle(color: _mutedColor, fontSize: 14)),
          ),
          pw.Expanded(
            child: pw.Text(title, style: _textStyle(fontSize: 16)),
          ),
          pw.Text('......', style: _textStyle(color: _mutedColor)),
          pw.SizedBox(width: 16),
          pw.Text('$page', style: _textStyle(color: _mutedColor, fontSize: 14)),
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
      stats.add(_buildStatCard('美食记录', count, _primaryColor));
    }
    if (includeMoment) {
      var query = db.select(db.momentRecords);
      if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      stats.add(_buildStatCard('小确幸', count, _secondaryColor));
    }
    if (includeFriend) {
      final count = await (db.select(db.friendRecords)).get().then((r) => r.length);
      stats.add(_buildStatCard('羁绊', count, const PdfColor.fromInt(0xFFEC4899)));
    }
    if (includeTravel) {
      var query = db.select(db.travelRecords);
      if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      stats.add(_buildStatCard('旅行', count, _accentColor));
    }
    if (includeGoal) {
      final count = await (db.select(db.goalRecords)).get().then((r) => r.length);
      stats.add(_buildStatCard('目标', count, const PdfColor.fromInt(0xFF8B5CF6)));
    }
    if (includeTimeline) {
      var query = db.select(db.timelineEvents);
      if (startDate != null) query = query..where((t) => t.startAt.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.startAt.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      stats.add(_buildStatCard('时间线', count, const PdfColor.fromInt(0xFF6366F1)));
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
            pw.Text('第一章 数据概览$dateRangeText', style: _textStyle(fontSize: 28, bold: true, color: _primaryColor)),
            pw.SizedBox(height: 24),
            pw.Text('记录统计', style: _textStyle(fontSize: 18, bold: true)),
            pw.SizedBox(height: 20),
            pw.Wrap(
              spacing: 20,
              runSpacing: 20,
              children: stats,
            ),
          ],
        ),
      ),
    );
  }
  
  pw.Widget _buildStatCard(String title, int count, PdfColor color) {
    return pw.Container(
      width: 140,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt((color.toInt() & 0x00FFFFFF) | 0x1A000000),
        borderRadius: pw.BorderRadius.circular(16),
        boxShadow: [
          pw.BoxShadow(
            color: PdfColor.fromInt(0x10000000),
            blurRadius: 8,
            offset: const PdfPoint(0, 4),
          ),
        ],
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: _textStyle(fontSize: 14, color: _mutedColor)),
          pw.SizedBox(height: 12),
          pw.Text('$count', style: _textStyle(fontSize: 32, bold: true, color: color)),
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
    
    final ratings = records.map((r) => r.rating ?? 0).toList();
    final avgRating = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;
    
    final expenses = records.map((r) => r.pricePerPerson ?? 0).toList();
    final totalExpense = expenses.isEmpty ? 0.0 : expenses.reduce((a, b) => a + b);
    
    pdf.addPage(await _createChapterCoverPage(
      '第二章',
      '美食记忆',
      '共 ${records.length} 条记录 · 平均评分 ${avgRating.toStringAsFixed(1)} · 总消费 ¥${totalExpense.toStringAsFixed(0)}',
      _primaryColor,
    ));
    
    for (final record in records) {
      try {
        final images = includePhotos ? await _getRecordImages('food', record.images) : <File>[];
        pdf.addPage(await _createFoodDetailPage(record, images));
      } catch (e) {
        debugPrint('添加美食记录详情页失败: $e');
      }
    }
  }
  
  Future<List<File>> _getRecordImages(String module, String? imagesJson) async {
    try {
      if (imagesJson == null || imagesJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> imagePaths;
      try {
        imagePaths = jsonDecode(imagesJson) as List<dynamic>;
      } catch (e) {
        debugPrint('解析图片JSON失败: $e, 原始数据: $imagesJson');
        return [];
      }
      
      if (imagePaths.isEmpty) {
        return [];
      }
      
      final files = <File>[];
      for (final imagePath in imagePaths) {
        if (imagePath is! String || imagePath.isEmpty) continue;
        
        final trimmed = imagePath.trim();
        if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
          continue;
        }
        
        try {
          final file = File(trimmed);
          if (await file.exists()) {
            files.add(file);
          } else {
            debugPrint('图片文件不存在: $trimmed');
          }
        } catch (e) {
          debugPrint('检查图片文件失败: $trimmed, 错误: $e');
        }
      }
      
      return files;
    } catch (e) {
      debugPrint('获取图片失败: $e');
      return [];
    }
  }
  
  Future<pw.Page> _createChapterCoverPage(String chapter, String title, String subtitle, PdfColor color) async {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        decoration: pw.BoxDecoration(
          gradient: pw.LinearGradient(
            colors: [color, PdfColor.fromInt((color.toInt() & 0x00FFFFFF) | 0xFF000000)],
            begin: pw.Alignment.topLeft,
            end: pw.Alignment.bottomRight,
          ),
        ),
        child: pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(chapter, style: _textStyle(fontSize: 24, color: PdfColor.fromInt(0xB3FFFFFF))),
              pw.SizedBox(height: 16),
              pw.Text(title, style: _textStyle(fontSize: 48, bold: true, color: PdfColors.white)),
              pw.SizedBox(height: 24),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0x33FFFFFF),
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(subtitle, style: _textStyle(fontSize: 14, color: PdfColors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<pw.Page> _createFoodDetailPage(FoodRecord record, List<File> images) async {
    final imageWidgets = <pw.Widget>[];
    
    for (final imageFile in images.take(4)) {
      try {
        final bytes = await imageFile.readAsBytes();
        final image = pw.MemoryImage(bytes);
        imageWidgets.add(
          pw.ClipRRect(
            borderRadius: pw.BorderRadius.circular(12),
            child: pw.Image(image, fit: pw.BoxFit.cover),
          ),
        );
      } catch (e) {
        debugPrint('无法加载图片: $e');
      }
    }
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(32),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(record.title, style: _textStyle(fontSize: 24, bold: true)),
                ),
                if (record.rating != null)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: record.rating! >= 4.5 ? PdfColor.fromInt(0x3310B981) : _bgColor,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text('★ ${record.rating}', style: _textStyle(fontSize: 14, color: _accentColor)),
                  ),
              ],
            ),
            pw.SizedBox(height: 16),
            
            if (imageWidgets.isNotEmpty) ...[
              pw.Container(
                height: 200,
                child: pw.GridView(
                  crossAxisCount: imageWidgets.length > 2 ? 2 : imageWidgets.length,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: imageWidgets,
                ),
              ),
              pw.SizedBox(height: 16),
            ],
            
            if (record.content != null && record.content!.isNotEmpty) ...[
              pw.Text(record.content!, style: _textStyle(fontSize: 12, color: _textColor)),
              pw.SizedBox(height: 16),
            ],
            
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: _bgColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                children: [
                  if (record.poiName != null)
                    pw.Text('📍 ${record.poiName}', style: _textStyle(fontSize: 10, color: _mutedColor)),
                  if (record.poiName != null && record.city != null)
                    pw.Text(' · ', style: _textStyle(color: _mutedColor)),
                  if (record.city != null)
                    pw.Text(record.city!, style: _textStyle(fontSize: 10, color: _mutedColor)),
                  pw.Spacer(),
                  pw.Text(record.recordDate.toString().split(' ')[0], style: _textStyle(fontSize: 10, color: _mutedColor)),
                ],
              ),
            ),
          ],
        ),
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
    
    pdf.addPage(await _createChapterCoverPage(
      '第三章',
      '小确幸时刻',
      '共 ${records.length} 条记录 · ${records.where((r) => r.isFavorite).length} 个收藏',
      _secondaryColor,
    ));
    
    for (final record in records) {
      try {
        final images = includePhotos ? await _getRecordImages('moment', record.images) : <File>[];
        pdf.addPage(await _createMomentDetailPage(record, images));
      } catch (e) {
        debugPrint('添加小确幸记录详情页失败: $e');
      }
    }
  }
  
  Future<pw.Page> _createMomentDetailPage(MomentRecord record, List<File> images) async {
    final imageWidgets = <pw.Widget>[];
    
    for (final imageFile in images.take(4)) {
      try {
        final bytes = await imageFile.readAsBytes();
        final image = pw.MemoryImage(bytes);
        imageWidgets.add(
          pw.ClipRRect(
            borderRadius: pw.BorderRadius.circular(12),
            child: pw.Image(image, fit: pw.BoxFit.cover),
          ),
        );
      } catch (e) {
        debugPrint('无法加载图片: $e');
      }
    }
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(32),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(record.mood, style: _textStyle(fontSize: 20, bold: true, color: _secondaryColor)),
                ),
                if (record.isFavorite)
                  pw.Text('❤', style: _textStyle(fontSize: 20, color: const PdfColor.fromInt(0xFFEC4899))),
              ],
            ),
            pw.SizedBox(height: 16),
            
            if (imageWidgets.isNotEmpty) ...[
              pw.Container(
                height: 200,
                child: pw.GridView(
                  crossAxisCount: imageWidgets.length > 2 ? 2 : imageWidgets.length,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: imageWidgets,
                ),
              ),
              pw.SizedBox(height: 16),
            ],
            
            pw.Text(record.content ?? '', style: _textStyle(fontSize: 14, color: _textColor)),
            pw.SizedBox(height: 16),
            
            pw.Text(record.recordDate.toString().split(' ')[0], style: _textStyle(fontSize: 10, color: _mutedColor)),
          ],
        ),
      ),
    );
  }
  
  Future<void> _addFriendChapter(pw.Document pdf, {required bool includePhotos}) async {
    final records = await (db.select(db.friendRecords)).get();
    
    if (records.isEmpty) return;
    
    pdf.addPage(await _createChapterCoverPage(
      '第四章',
      '羁绊故事',
      '共 ${records.length} 位好友 · ${records.where((r) => r.isFavorite).length} 位特别关心',
      const PdfColor.fromInt(0xFFEC4899),
    ));
    
    for (final record in records) {
      try {
        pdf.addPage(await _createFriendDetailPage(record, includePhotos: includePhotos));
      } catch (e) {
        debugPrint('添加羁绊记录详情页失败: $e');
      }
    }
  }
  
  Future<pw.Page> _createFriendDetailPage(FriendRecord record, {required bool includePhotos}) async {
    pw.Widget? avatarWidget;
    
    if (includePhotos && record.avatarPath != null && record.avatarPath!.isNotEmpty) {
      try {
        final avatarFile = File(record.avatarPath!);
        if (await avatarFile.exists()) {
          final bytes = await avatarFile.readAsBytes();
          final image = pw.MemoryImage(bytes);
          avatarWidget = pw.ClipRRect(
            borderRadius: pw.BorderRadius.circular(40),
            child: pw.Image(image, fit: pw.BoxFit.cover, width: 80, height: 80),
          );
        }
      } catch (e) {
        debugPrint('无法加载头像: $e');
      }
    }
    
    avatarWidget ??= pw.Container(
      width: 80,
      height: 80,
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFEC4899),
        borderRadius: pw.BorderRadius.circular(40),
      ),
      child: pw.Center(
        child: pw.Text(
          record.name.isNotEmpty ? record.name[0] : '?',
          style: _textStyle(fontSize: 32, bold: true, color: PdfColors.white),
        ),
      ),
    );
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(32),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                if (avatarWidget != null) avatarWidget,
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(record.name, style: _textStyle(fontSize: 28, bold: true)),
                      if (record.groupName != null)
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: _bgColor,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(record.groupName!, style: _textStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            
            if (record.impressionTags != null && record.impressionTags!.isNotEmpty)
              pw.Text('印象: ${record.impressionTags}', style: _textStyle(fontSize: 12, color: _mutedColor)),
            if (record.meetDate != null)
              pw.Text('相识于: ${record.meetDate!.toString().split(' ')[0]}', style: _textStyle(fontSize: 12, color: _mutedColor)),
          ],
        ),
      ),
    );
  }
  
  Future<void> _addTravelChapter(pw.Document pdf, {required bool includePhotos, DateTime? startDate, DateTime? endDate}) async {
    var query = db.select(db.travelRecords);
    
    if (startDate != null) {
      query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
    }
    
    final records = await query.get();
    
    if (records.isEmpty) return;
    
    final destinations = records
        .where((r) => r.destination != null)
        .map((r) => r.destination!)
        .toSet()
        .length;
    
    pdf.addPage(await _createChapterCoverPage(
      '第五章',
      '旅行足迹',
      '共 ${records.length} 次旅行 · $destinations 个目的地',
      _accentColor,
    ));
    
    for (final record in records) {
      try {
        final images = includePhotos ? await _getRecordImages('travel', record.images) : <File>[];
        pdf.addPage(await _createTravelDetailPage(record, images));
      } catch (e) {
        debugPrint('添加旅行记录详情页失败: $e');
      }
    }
  }
  
  Future<pw.Page> _createTravelDetailPage(TravelRecord record, List<File> images) async {
    final imageWidgets = <pw.Widget>[];
    
    for (final imageFile in images.take(4)) {
      try {
        final bytes = await imageFile.readAsBytes();
        final image = pw.MemoryImage(bytes);
        imageWidgets.add(
          pw.ClipRRect(
            borderRadius: pw.BorderRadius.circular(12),
            child: pw.Image(image, fit: pw.BoxFit.cover),
          ),
        );
      } catch (e) {
        debugPrint('无法加载图片: $e');
      }
    }
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(32),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(record.destination ?? '未知目的地', style: _textStyle(fontSize: 28, bold: true, color: _accentColor)),
            pw.SizedBox(height: 8),
            if (record.planDate != null)
              pw.Text('计划日期: ${record.planDate!.toString().split(' ')[0]}', style: _textStyle(fontSize: 12, color: _mutedColor)),
            pw.SizedBox(height: 16),
            
            if (imageWidgets.isNotEmpty) ...[
              pw.Container(
                height: 200,
                child: pw.GridView(
                  crossAxisCount: imageWidgets.length > 2 ? 2 : imageWidgets.length,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: imageWidgets,
                ),
              ),
              pw.SizedBox(height: 16),
            ],
            
            if (record.content != null && record.content!.isNotEmpty) ...[
              pw.Text(record.content!, style: _textStyle(fontSize: 12, color: _textColor)),
              pw.SizedBox(height: 16),
            ],
            
            if (record.city != null)
              pw.Text('📍 ${record.city}', style: _textStyle(fontSize: 10, color: _mutedColor)),
          ],
        ),
      ),
    );
  }
  
  Future<void> _addGoalChapter(pw.Document pdf) async {
    final records = await (db.select(db.goalRecords)).get();
    
    if (records.isEmpty) return;
    
    final completedCount = records.where((r) => r.isCompleted).length;
    final inProgressCount = records.where((r) => !r.isCompleted).length;
    
    pdf.addPage(await _createChapterCoverPage(
      '第六章',
      '目标征程',
      '共 ${records.length} 个目标 · $completedCount 个已完成 · $inProgressCount 个进行中',
      const PdfColor.fromInt(0xFF8B5CF6),
    ));
    
    for (final record in records) {
      try {
        pdf.addPage(await _createGoalDetailPage(record));
      } catch (e) {
        debugPrint('添加目标详情页失败: $e');
      }
    }
  }
  
  Future<pw.Page> _createGoalDetailPage(GoalRecord record) async {
    final progress = record.progress.clamp(0, 100).toInt();
    final remaining = (100 - progress).clamp(0, 100);
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(32),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(record.title, style: _textStyle(fontSize: 24, bold: true)),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: record.isCompleted ? PdfColor.fromInt(0x3310B981) : PdfColor.fromInt(0x33F59E0B),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    record.isCompleted ? '已完成' : '进行中',
                    style: _textStyle(fontSize: 12, color: record.isCompleted ? _secondaryColor : _accentColor),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            
            pw.Container(
              height: 8,
              decoration: pw.BoxDecoration(
                color: _bgColor,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                children: [
                  if (progress > 0)
                    pw.Expanded(
                      flex: progress,
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          color: record.isCompleted ? _secondaryColor : _accentColor,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  if (remaining > 0)
                    pw.Expanded(
                      flex: remaining,
                      child: pw.SizedBox(),
                    ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('进度: $progress%', style: _textStyle(fontSize: 12, color: _mutedColor)),
            pw.SizedBox(height: 16),
            
            if (record.note != null && record.note!.isNotEmpty) ...[
              pw.Text(record.note!, style: _textStyle(fontSize: 12, color: _textColor)),
              pw.SizedBox(height: 16),
            ],
            
            if (record.dueDate != null)
              pw.Text('截止日期: ${record.dueDate!.toString().split(' ')[0]}', style: _textStyle(fontSize: 10, color: _mutedColor)),
          ],
        ),
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
    
    pdf.addPage(await _createChapterCoverPage(
      '第七章',
      '时间线',
      '共 ${records.length} 个事件 · ${records.where((r) => r.isFavorite).length} 个收藏',
      const PdfColor.fromInt(0xFF6366F1),
    ));
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.SizedBox(height: 20),
          ...records.map((record) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 20),
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(record.title, style: _textStyle(fontSize: 16, bold: true)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: _bgColor,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(record.eventType, style: _textStyle(fontSize: 10)),
                    ),
                  ],
                ),
                if (record.note != null && record.note!.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(record.note!, style: _textStyle(fontSize: 11, color: _textColor)),
                ],
                pw.SizedBox(height: 8),
                pw.Text(
                  record.startAt?.toString().split('.')[0] ?? '',
                  style: _textStyle(fontSize: 10, color: _mutedColor),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
