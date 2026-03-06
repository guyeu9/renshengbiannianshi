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
  
  // 日志记录器
  final List<Map<String, dynamic>> _logs = [];
  
  PdfExportService(this.db);
  
  void _log(String level, String message, {Map<String, dynamic>? data, StackTrace? stackTrace}) {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level,
      'message': message,
      'data': data,
      'stackTrace': stackTrace?.toString(),
    };
    _logs.add(logEntry);
    
    // 同时输出到控制台
    final logString = '[PDF导出][$level][${DateTime.now()}] $message';
    if (data != null) {
      debugPrint('$logString | 数据: $data');
    } else {
      debugPrint(logString);
    }
    if (stackTrace != null) {
      debugPrint('堆栈: $stackTrace');
    }
  }
  
  List<Map<String, dynamic>> getLogs() => List.unmodifiable(_logs);
  
  void clearLogs() => _logs.clear();
  
  Future<void> _loadFonts() async {
    if (_fontsLoaded) {
      _log('INFO', '字体已加载，跳过重复加载');
      return;
    }
    
    _log('INFO', '开始加载字体...');
    
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
      ];
      
      final boldFontPaths = [
        '/system/fonts/NotoSansCJK-Bold.ttc',
        '/system/fonts/NotoSansSC-Bold.otf',
        '/system/fonts/SourceHanSansSC-Bold.otf',
      ];
      
      _log('INFO', '尝试加载常规字体', data: {'paths': systemFontPaths});
      
      for (final fontPath in systemFontPaths) {
        try {
          _log('DEBUG', '检查字体文件', data: {'path': fontPath});
          final file = File(fontPath);
          final exists = await file.exists();
          _log('DEBUG', '字体文件存在性检查', data: {'path': fontPath, 'exists': exists});
          
          if (exists) {
            _log('INFO', '找到字体文件，开始读取', data: {'path': fontPath});
            final fontData = await file.readAsBytes();
            _log('DEBUG', '字体数据读取完成', data: {'path': fontPath, 'size': fontData.length});
            
            _chineseFont = pw.Font.ttf(ByteData.sublistView(Uint8List.fromList(fontData)));
            _log('INFO', '常规字体加载成功', data: {'path': fontPath});
            break;
          }
        } catch (e, stack) {
          _log('WARNING', '加载字体失败', data: {'path': fontPath, 'error': e.toString()}, stackTrace: stack);
          continue;
        }
      }
      
      _log('INFO', '尝试加载粗体字体', data: {'paths': boldFontPaths});
      
      for (final fontPath in boldFontPaths) {
        try {
          _log('DEBUG', '检查粗体字体文件', data: {'path': fontPath});
          final file = File(fontPath);
          final exists = await file.exists();
          _log('DEBUG', '粗体字体文件存在性检查', data: {'path': fontPath, 'exists': exists});
          
          if (exists) {
            _log('INFO', '找到粗体字体文件，开始读取', data: {'path': fontPath});
            final fontData = await file.readAsBytes();
            _log('DEBUG', '粗体字体数据读取完成', data: {'path': fontPath, 'size': fontData.length});
            
            _chineseFontBold = pw.Font.ttf(ByteData.sublistView(Uint8List.fromList(fontData)));
            _log('INFO', '粗体字体加载成功', data: {'path': fontPath});
            break;
          }
        } catch (e, stack) {
          _log('WARNING', '加载粗体字体失败', data: {'path': fontPath, 'error': e.toString()}, stackTrace: stack);
          continue;
        }
      }
      
      // 如果没有找到粗体字体，使用常规字体作为回退
      if (_chineseFontBold == null && _chineseFont != null) {
        _chineseFontBold = _chineseFont;
        _log('INFO', '使用常规字体作为粗体回退');
      }
      
      _log('INFO', '字体加载完成', data: {
        'regularFontLoaded': _chineseFont != null,
        'boldFontLoaded': _chineseFontBold != null,
      });
      
      _fontsLoaded = true;
    } catch (e, stack) {
      _log('ERROR', '字体加载过程发生异常', data: {'error': e.toString()}, stackTrace: stack);
      _fontsLoaded = true;
    }
  }
  
  pw.TextStyle _textStyle({
    double fontSize = 12,
    bool bold = false,
    PdfColor color = _textColor,
  }) {
    final font = bold ? (_chineseFontBold ?? _chineseFont) : _chineseFont;
    
    _log('DEBUG', '创建TextStyle', data: {
      'fontSize': fontSize,
      'bold': bold,
      'hasFont': font != null,
      'hasRegularFont': _chineseFont != null,
      'hasBoldFont': _chineseFontBold != null,
    });
    
    if (font != null) {
      return pw.TextStyle(
        fontSize: fontSize,
        color: color,
        font: font,
      );
    }
    
    _log('WARNING', '使用默认字体（无中文字体）', data: {'fontSize': fontSize, 'bold': bold});
    return pw.TextStyle(
      fontSize: fontSize,
      color: color,
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
    _log('INFO', '开始PDF导出', data: {
      'includeFood': includeFood,
      'includeMoment': includeMoment,
      'includeFriend': includeFriend,
      'includeTravel': includeTravel,
      'includeGoal': includeGoal,
      'includeTimeline': includeTimeline,
      'includeCover': includeCover,
      'includeToc': includeToc,
      'includeCharts': includeCharts,
      'includePhotos': includePhotos,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    });
    
    try {
      await _loadFonts();
    } catch (e, stack) {
      _log('ERROR', '字体加载失败，但继续导出', data: {'error': e.toString()}, stackTrace: stack);
    }
    
    final pdf = pw.Document();
    
    try {
      if (includeCover) {
        _log('INFO', '创建封面页...');
        pdf.addPage(await _createCoverPage(startDate: startDate, endDate: endDate));
        _log('INFO', '封面页创建完成');
      }
      
      if (includeToc) {
        _log('INFO', '创建目录页...');
        pdf.addPage(await _createTableOfContents(
          includeFood: includeFood,
          includeMoment: includeMoment,
          includeFriend: includeFriend,
          includeTravel: includeTravel,
          includeGoal: includeGoal,
          includeTimeline: includeTimeline,
        ));
        _log('INFO', '目录页创建完成');
      }
      
      _log('INFO', '创建概览章节...');
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
      _log('INFO', '概览章节创建完成');
      
      if (includeFood) {
        _log('INFO', '添加美食章节...');
        await _addFoodChapter(pdf, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
        _log('INFO', '美食章节添加完成');
      }
      if (includeMoment) {
        _log('INFO', '添加小确幸章节...');
        await _addMomentChapter(pdf, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
        _log('INFO', '小确幸章节添加完成');
      }
      if (includeFriend) {
        _log('INFO', '添加羁绊章节...');
        await _addFriendChapter(pdf, includePhotos: includePhotos);
        _log('INFO', '羁绊章节添加完成');
      }
      if (includeTravel) {
        _log('INFO', '添加旅行章节...');
        await _addTravelChapter(pdf, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
        _log('INFO', '旅行章节添加完成');
      }
      if (includeGoal) {
        _log('INFO', '添加目标章节...');
        await _addGoalChapter(pdf);
        _log('INFO', '目标章节添加完成');
      }
      if (includeTimeline) {
        _log('INFO', '添加时间线章节...');
        await _addTimelineChapter(pdf, startDate: startDate, endDate: endDate);
        _log('INFO', '时间线章节添加完成');
      }
      
      _log('INFO', '保存PDF文件...');
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final fileName = '人生编年史导出_$timestamp.pdf';
      final filePath = path.join(tempDir.path, fileName);
      
      _log('DEBUG', '准备写入文件', data: {'filePath': filePath});
      final file = File(filePath);
      final pdfBytes = await pdf.save();
      _log('DEBUG', 'PDF字节生成完成', data: {'size': pdfBytes.length});
      await file.writeAsBytes(pdfBytes);
      
      _log('INFO', 'PDF导出成功', data: {'filePath': filePath, 'logsCount': _logs.length});
      return filePath;
    } catch (e, stack) {
      _log('ERROR', 'PDF导出失败', data: {
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
        'logsCount': _logs.length,
      }, stackTrace: stack);
      throw Exception('PDF导出失败: $e\n\n详细日志:\n${_logs.map((l) => '[${l['level']}] ${l['message']}').join('\n')}');
    }
  }
  
  Future<pw.Page> _createCoverPage({DateTime? startDate, DateTime? endDate}) async {
    _log('DEBUG', '开始创建封面页');
    
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
    
    _log('DEBUG', '封面页数据准备完成', data: {'dateRangeText': dateRangeText});
    
    try {
      final page = pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          _log('DEBUG', '封面页 build 开始');
          return pw.Container(
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
          );
        },
      );
      
      _log('DEBUG', '封面页创建完成');
      return page;
    } catch (e, stack) {
      _log('ERROR', '封面页创建失败', data: {'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<pw.Page> _createTableOfContents({
    required bool includeFood,
    required bool includeMoment,
    required bool includeFriend,
    required bool includeTravel,
    required bool includeGoal,
    required bool includeTimeline,
  }) async {
    _log('DEBUG', '开始创建目录页');
    
    final chapters = <Map<String, dynamic>>[];
    if (includeFood) chapters.add({'title': '第一章：美食记录', 'page': 3});
    if (includeMoment) chapters.add({'title': '第二章：小确幸', 'page': includeFood ? 4 : 3});
    if (includeFriend) chapters.add({'title': '第三章：羁绊', 'page': (includeFood ? 1 : 0) + (includeMoment ? 1 : 0) + 3});
    if (includeTravel) chapters.add({'title': '第四章：旅行足迹', 'page': (includeFood ? 1 : 0) + (includeMoment ? 1 : 0) + (includeFriend ? 1 : 0) + 3});
    if (includeGoal) chapters.add({'title': '第五章：目标规划', 'page': (includeFood ? 1 : 0) + (includeMoment ? 1 : 0) + (includeFriend ? 1 : 0) + (includeTravel ? 1 : 0) + 3});
    if (includeTimeline) chapters.add({'title': '第六章：时间线', 'page': (includeFood ? 1 : 0) + (includeMoment ? 1 : 0) + (includeFriend ? 1 : 0) + (includeTravel ? 1 : 0) + (includeGoal ? 1 : 0) + 3});
    
    _log('DEBUG', '目录数据准备完成', data: {'chapterCount': chapters.length});
    
    try {
      final page = pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(48),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('目录', style: _textStyle(fontSize: 36, bold: true, color: _primaryColor)),
              pw.SizedBox(height: 32),
              ...chapters.map((chapter) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 12),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(chapter['title'] as String, style: _textStyle(fontSize: 16)),
                    ),
                    pw.Text('第 ${chapter['page']} 页', style: _textStyle(fontSize: 14, color: _mutedColor)),
                  ],
                ),
              )),
            ],
          ),
        ),
      );
      
      _log('DEBUG', '目录页创建完成');
      return page;
    } catch (e, stack) {
      _log('ERROR', '目录页创建失败', data: {'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
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
    _log('DEBUG', '开始创建概览章节');
    
    final stats = <pw.Widget>[];
    
    try {
      if (includeFood) {
        _log('DEBUG', '统计美食记录数量');
        var query = db.select(db.foodRecords);
        if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
          query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
        }
        final count = await query.get().then((r) => r.length);
        _log('DEBUG', '美食记录统计完成', data: {'count': count});
        stats.add(_buildStatCard('美食记录', count, _primaryColor));
      }
      
      if (includeMoment) {
        _log('DEBUG', '统计小确幸数量');
        var query = db.select(db.momentRecords);
        if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
          query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
        }
        final count = await query.get().then((r) => r.length);
        _log('DEBUG', '小确幸统计完成', data: {'count': count});
        stats.add(_buildStatCard('小确幸', count, _secondaryColor));
      }
      
      if (includeFriend) {
        _log('DEBUG', '统计羁绊数量');
        final count = await (db.select(db.friendRecords)).get().then((r) => r.length);
        _log('DEBUG', '羁绊统计完成', data: {'count': count});
        stats.add(_buildStatCard('羁绊', count, const PdfColor.fromInt(0xFFEC4899)));
      }
      
      if (includeTravel) {
        _log('DEBUG', '统计旅行数量');
        var query = db.select(db.travelRecords);
        if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
          query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
        }
        final count = await query.get().then((r) => r.length);
        _log('DEBUG', '旅行统计完成', data: {'count': count});
        stats.add(_buildStatCard('旅行', count, _accentColor));
      }
      
      if (includeGoal) {
        _log('DEBUG', '统计目标数量');
        final count = await (db.select(db.goalRecords)).get().then((r) => r.length);
        _log('DEBUG', '目标统计完成', data: {'count': count});
        stats.add(_buildStatCard('目标', count, const PdfColor.fromInt(0xFF8B5CF6)));
      }
      
      if (includeTimeline) {
        _log('DEBUG', '统计时间线事件数量');
        var query = db.select(db.timelineEvents);
        if (startDate != null) query = query..where((t) => t.startAt.isBiggerOrEqualValue(startDate));
        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
          query = query..where((t) => t.startAt.isSmallerOrEqualValue(endOfDay));
        }
        final count = await query.get().then((r) => r.length);
        _log('DEBUG', '时间线统计完成', data: {'count': count});
        stats.add(_buildStatCard('时间线', count, const PdfColor.fromInt(0xFF06B6D4)));
      }
      
      _log('DEBUG', '统计数据准备完成', data: {'statCount': stats.length});
      
      final page = pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('数据概览', style: _textStyle(fontSize: 32, bold: true, color: _primaryColor)),
              pw.SizedBox(height: 24),
              pw.Wrap(
                spacing: 16,
                runSpacing: 16,
                children: stats,
              ),
            ],
          ),
        ),
      );
      
      _log('DEBUG', '概览章节创建完成');
      return page;
    } catch (e, stack) {
      _log('ERROR', '概览章节创建失败', data: {'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  pw.Widget _buildStatCard(String title, int count, PdfColor color) {
    _log('DEBUG', '创建统计卡片', data: {'title': title, 'count': count});
    
    try {
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
    } catch (e, stack) {
      _log('ERROR', '统计卡片创建失败', data: {'title': title, 'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<pw.Page> _createChapterCoverPage(String chapter, String title, String subtitle, PdfColor color) async {
    _log('DEBUG', '创建章节封面页', data: {'chapter': chapter, 'title': title});
    
    try {
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
    } catch (e, stack) {
      _log('ERROR', '章节封面页创建失败', data: {'chapter': chapter, 'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<void> _addFoodChapter(pw.Document pdf, {required bool includePhotos, DateTime? startDate, DateTime? endDate}) async {
    _log('INFO', '开始添加美食章节');
    
    try {
      var query = db.select(db.foodRecords);
      
      if (startDate != null) {
        query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
      }
      
      final records = await query.get();
      _log('INFO', '美食记录查询完成', data: {'count': records.length});
      
      if (records.isEmpty) {
        _log('INFO', '无美食记录，跳过章节');
        return;
      }
      
      pdf.addPage(await _createChapterCoverPage('第一章', '美食记录', '共 ${records.length} 条记录', _primaryColor));
      _log('DEBUG', '美食章节封面页添加完成');
      
      for (final record in records) {
        _log('DEBUG', '处理美食记录', data: {'id': record.id, 'title': record.title});
        
        List<File> images = [];
        if (includePhotos && record.imagePaths != null && record.imagePaths!.isNotEmpty) {
          try {
            final imageList = jsonDecode(record.imagePaths!) as List<dynamic>;
            images = imageList
                .map((p) => File(p.toString()))
                .where((f) => f.existsSync())
                .toList();
            _log('DEBUG', '美食记录图片加载完成', data: {'id': record.id, 'imageCount': images.length});
          } catch (e) {
            _log('WARNING', '美食记录图片加载失败', data: {'id': record.id, 'error': e.toString()});
          }
        }
        
        pdf.addPage(await _createFoodDetailPage(record, images));
      }
      
      _log('INFO', '美食章节添加完成', data: {'recordCount': records.length});
    } catch (e, stack) {
      _log('ERROR', '美食章节添加失败', data: {'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<pw.Page> _createFoodDetailPage(FoodRecord record, List<File> images) async {
    _log('DEBUG', '创建美食详情页', data: {'id': record.id, 'title': record.title, 'imageCount': images.length});
    
    try {
      final imageWidgets = <pw.Widget>[];
      
      for (final imageFile in images.take(4)) {
        try {
          _log('DEBUG', '加载美食图片', data: {'path': imageFile.path});
          final bytes = await imageFile.readAsBytes();
          final image = pw.MemoryImage(bytes);
          imageWidgets.add(
            pw.ClipRRect(
              horizontalRadius: 12,
              verticalRadius: 12,
              child: pw.Image(image, fit: pw.BoxFit.cover),
            ),
          );
          _log('DEBUG', '美食图片加载成功', data: {'path': imageFile.path});
        } catch (e) {
          _log('WARNING', '无法加载美食图片', data: {'path': imageFile.path, 'error': e.toString()});
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
                    child: pw.Text(record.title, style: _textStyle(fontSize: 24, bold: true)),
                  ),
                  if (record.isFavorite)
                    pw.Text('★', style: _textStyle(fontSize: 24, color: const PdfColor.fromInt(0xFFF59E0B))),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text('${record.restaurantName ?? '未知餐厅'} | ${record.cuisineType ?? '未知菜系'}', 
                  style: _textStyle(fontSize: 14, color: _mutedColor)),
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
              
              pw.Text('评分: ${record.rating}/5', style: _textStyle(fontSize: 14, color: _secondaryColor)),
              pw.SizedBox(height: 8),
              
              if (record.content != null && record.content!.isNotEmpty) ...[
                pw.Text('评价:', style: _textStyle(fontSize: 14, bold: true)),
                pw.SizedBox(height: 4),
                pw.Text(record.content!, style: _textStyle(fontSize: 12)),
                pw.SizedBox(height: 8),
              ],
              
              pw.Text(record.recordDate.toString().split(' ')[0], style: _textStyle(fontSize: 10, color: _mutedColor)),
            ],
          ),
        ),
      );
    } catch (e, stack) {
      _log('ERROR', '美食详情页创建失败', data: {'id': record.id, 'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<void> _addMomentChapter(pw.Document pdf, {required bool includePhotos, DateTime? startDate, DateTime? endDate}) async {
    _log('INFO', '开始添加小确幸章节');
    
    try {
      var query = db.select(db.momentRecords);
      
      if (startDate != null) {
        query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
      }
      
      final records = await query.get();
      _log('INFO', '小确幸记录查询完成', data: {'count': records.length});
      
      if (records.isEmpty) {
        _log('INFO', '无小确幸记录，跳过章节');
        return;
      }
      
      pdf.addPage(await _createChapterCoverPage('第二章', '小确幸', '共 ${records.length} 条记录', _secondaryColor));
      _log('DEBUG', '小确幸章节封面页添加完成');
      
      for (final record in records) {
        _log('DEBUG', '处理小确幸记录', data: {'id': record.id});
        
        List<File> images = [];
        if (includePhotos && record.imagePaths != null && record.imagePaths!.isNotEmpty) {
          try {
            final imageList = jsonDecode(record.imagePaths!) as List<dynamic>;
            images = imageList
                .map((p) => File(p.toString()))
                .where((f) => f.existsSync())
                .toList();
            _log('DEBUG', '小确幸记录图片加载完成', data: {'id': record.id, 'imageCount': images.length});
          } catch (e) {
            _log('WARNING', '小确幸记录图片加载失败', data: {'id': record.id, 'error': e.toString()});
          }
        }
        
        pdf.addPage(await _createMomentDetailPage(record, images));
      }
      
      _log('INFO', '小确幸章节添加完成', data: {'recordCount': records.length});
    } catch (e, stack) {
      _log('ERROR', '小确幸章节添加失败', data: {'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<pw.Page> _createMomentDetailPage(MomentRecord record, List<File> images) async {
    _log('DEBUG', '创建小确幸详情页', data: {'id': record.id, 'imageCount': images.length});
    
    try {
      final imageWidgets = <pw.Widget>[];
      
      for (final imageFile in images.take(4)) {
        try {
          _log('DEBUG', '加载小确幸图片', data: {'path': imageFile.path});
          final bytes = await imageFile.readAsBytes();
          final image = pw.MemoryImage(bytes);
          imageWidgets.add(
            pw.ClipRRect(
              horizontalRadius: 12,
              verticalRadius: 12,
              child: pw.Image(image, fit: pw.BoxFit.cover),
            ),
          );
          _log('DEBUG', '小确幸图片加载成功', data: {'path': imageFile.path});
        } catch (e) {
          _log('WARNING', '无法加载小确幸图片', data: {'path': imageFile.path, 'error': e.toString()});
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
    } catch (e, stack) {
      _log('ERROR', '小确幸详情页创建失败', data: {'id': record.id, 'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<void> _addFriendChapter(pw.Document pdf, {required bool includePhotos}) async {
    _log('INFO', '开始添加羁绊章节');
    
    try {
      final records = await (db.select(db.friendRecords)).get();
      _log('INFO', '羁绊记录查询完成', data: {'count': records.length});
      
      if (records.isEmpty) {
        _log('INFO', '无羁绊记录，跳过章节');
        return;
      }
      
      pdf.addPage(await _createChapterCoverPage('第三章', '羁绊', '共 ${records.length} 位好友', const PdfColor.fromInt(0xFFEC4899)));
      _log('DEBUG', '羁绊章节封面页添加完成');
      
      for (final record in records) {
        _log('DEBUG', '处理羁绊记录', data: {'id': record.id, 'name': record.name});
        pdf.addPage(await _createFriendDetailPage(record, includePhotos: includePhotos));
      }
      
      _log('INFO', '羁绊章节添加完成', data: {'recordCount': records.length});
    } catch (e, stack) {
      _log('ERROR', '羁绊章节添加失败', data: {'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<pw.Page> _createFriendDetailPage(FriendRecord record, {required bool includePhotos}) async {
    _log('DEBUG', '创建羁绊详情页', data: {'id': record.id, 'name': record.name});
    
    try {
      pw.Widget? avatarWidget;
      
      if (includePhotos && record.avatarPath != null && record.avatarPath!.isNotEmpty) {
        try {
          _log('DEBUG', '加载羁绊头像', data: {'id': record.id, 'avatarPath': record.avatarPath});
          final avatarFile = File(record.avatarPath!);
          if (await avatarFile.exists()) {
            final bytes = await avatarFile.readAsBytes();
            final image = pw.MemoryImage(bytes);
            avatarWidget = pw.ClipRRect(
              horizontalRadius: 40,
              verticalRadius: 40,
              child: pw.Image(image, fit: pw.BoxFit.cover, width: 80, height: 80),
            );
            _log('DEBUG', '羁绊头像加载成功', data: {'id': record.id});
          } else {
            _log('WARNING', '羁绊头像文件不存在', data: {'id': record.id, 'path': record.avatarPath});
          }
        } catch (e) {
          _log('WARNING', '无法加载羁绊头像', data: {'id': record.id, 'error': e.toString()});
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
                  avatarWidget,
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(record.name, style: _textStyle(fontSize: 28, bold: true)),
                        pw.SizedBox(height: 4),
                        if (record.relationship != null && record.relationship!.isNotEmpty)
                          pw.Text(record.relationship!, style: _textStyle(fontSize: 14, color: _mutedColor)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              
              if (record.impressionTags != null && record.impressionTags!.isNotEmpty)
                pw.Text('印象标签: ${record.impressionTags}', style: _textStyle(fontSize: 12, color: _secondaryColor)),
              pw.SizedBox(height: 8),
              
              if (record.meetDate != null)
                pw.Text('相识于: ${record.meetDate!.toString().split(' ')[0]}', style: _textStyle(fontSize: 12, color: _mutedColor)),
              pw.SizedBox(height: 16),
              
              if (record.notes != null && record.notes!.isNotEmpty) ...[
                pw.Text('备注:', style: _textStyle(fontSize: 14, bold: true)),
                pw.SizedBox(height: 4),
                pw.Text(record.notes!, style: _textStyle(fontSize: 12)),
              ],
            ],
          ),
        ),
      );
    } catch (e, stack) {
      _log('ERROR', '羁绊详情页创建失败', data: {'id': record.id, 'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<void> _addTravelChapter(pw.Document pdf, {required bool includePhotos, DateTime? startDate, DateTime? endDate}) async {
    _log('INFO', '开始添加旅行章节');
    
    try {
      var query = db.select(db.travelRecords);
      
      if (startDate != null) {
        query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
      }
      
      final records = await query.get();
      _log('INFO', '旅行记录查询完成', data: {'count': records.length});
      
      if (records.isEmpty) {
        _log('INFO', '无旅行记录，跳过章节');
        return;
      }
      
      pdf.addPage(await _createChapterCoverPage('第四章', '旅行足迹', '共 ${records.length} 次旅行', _accentColor));
      _log('DEBUG', '旅行章节封面页添加完成');
      
      for (final record in records) {
        _log('DEBUG', '处理旅行记录', data: {'id': record.id, 'destination': record.destination});
        
        List<File> images = [];
        if (includePhotos && record.imagePaths != null && record.imagePaths!.isNotEmpty) {
          try {
            final imageList = jsonDecode(record.imagePaths!) as List<dynamic>;
            images = imageList
                .map((p) => File(p.toString()))
                .where((f) => f.existsSync())
                .toList();
            _log('DEBUG', '旅行记录图片加载完成', data: {'id': record.id, 'imageCount': images.length});
          } catch (e) {
            _log('WARNING', '旅行记录图片加载失败', data: {'id': record.id, 'error': e.toString()});
          }
        }
        
        pdf.addPage(await _createTravelDetailPage(record, images));
      }
      
      _log('INFO', '旅行章节添加完成', data: {'recordCount': records.length});
    } catch (e, stack) {
      _log('ERROR', '旅行章节添加失败', data: {'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<pw.Page> _createTravelDetailPage(TravelRecord record, List<File> images) async {
    _log('DEBUG', '创建旅行详情页', data: {'id': record.id, 'destination': record.destination, 'imageCount': images.length});
    
    try {
      final imageWidgets = <pw.Widget>[];
      
      for (final imageFile in images.take(4)) {
        try {
          _log('DEBUG', '加载旅行图片', data: {'path': imageFile.path});
          final bytes = await imageFile.readAsBytes();
          final image = pw.MemoryImage(bytes);
          imageWidgets.add(
            pw.ClipRRect(
              horizontalRadius: 12,
              verticalRadius: 12,
              child: pw.Image(image, fit: pw.BoxFit.cover),
            ),
          );
          _log('DEBUG', '旅行图片加载成功', data: {'path': imageFile.path});
        } catch (e) {
          _log('WARNING', '无法加载旅行图片', data: {'path': imageFile.path, 'error': e.toString()});
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
              
              if (record.description != null && record.description!.isNotEmpty) ...[
                pw.Text('旅行计划:', style: _textStyle(fontSize: 14, bold: true)),
                pw.SizedBox(height: 4),
                pw.Text(record.description!, style: _textStyle(fontSize: 12)),
                pw.SizedBox(height: 8),
              ],
              
              pw.Text('状态: ${record.status}', style: _textStyle(fontSize: 12, color: _secondaryColor)),
            ],
          ),
        ),
      );
    } catch (e, stack) {
      _log('ERROR', '旅行详情页创建失败', data: {'id': record.id, 'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<void> _addGoalChapter(pw.Document pdf) async {
    _log('INFO', '开始添加目标章节');
    
    try {
      final records = await (db.select(db.goalRecords)).get();
      _log('INFO', '目标记录查询完成', data: {'count': records.length});
      
      if (records.isEmpty) {
        _log('INFO', '无目标记录，跳过章节');
        return;
      }
      
      pdf.addPage(await _createChapterCoverPage('第五章', '目标规划', '共 ${records.length} 个目标', const PdfColor.fromInt(0xFF8B5CF6)));
      _log('DEBUG', '目标章节封面页添加完成');
      
      for (final record in records) {
        _log('DEBUG', '处理目标记录', data: {'id': record.id, 'title': record.title});
        pdf.addPage(await _createGoalDetailPage(record));
      }
      
      _log('INFO', '目标章节添加完成', data: {'recordCount': records.length});
    } catch (e, stack) {
      _log('ERROR', '目标章节添加失败', data: {'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<pw.Page> _createGoalDetailPage(GoalRecord record) async {
    _log('DEBUG', '创建目标详情页', data: {'id': record.id, 'title': record.title});
    
    try {
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
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: record.status == 'completed' 
                          ? const PdfColor.fromInt(0xFF10B981) 
                          : const PdfColor.fromInt(0xFFF59E0B),
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Text(
                      record.status == 'completed' ? '已完成' : '进行中',
                      style: _textStyle(fontSize: 12, color: PdfColors.white),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              
              pw.Text('进度: ${record.progress}%', style: _textStyle(fontSize: 16, color: _secondaryColor)),
              pw.SizedBox(height: 8),
              pw.Container(
                width: double.infinity,
                height: 8,
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFE5E7EB),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: (record.progress / 100) * 500,
                      height: 8,
                      decoration: pw.BoxDecoration(
                        color: const PdfColor.fromInt(0xFF8B5CF6),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              
              if (record.note != null && record.note!.isNotEmpty) ...[
                pw.Text('备注:', style: _textStyle(fontSize: 14, bold: true)),
                pw.SizedBox(height: 4),
                pw.Text(record.note!, style: _textStyle(fontSize: 12)),
                pw.SizedBox(height: 8),
              ],
              
              if (record.dueDate != null)
                pw.Text('截止日期: ${record.dueDate!.toString().split(' ')[0]}', style: _textStyle(fontSize: 10, color: _mutedColor)),
            ],
          ),
        ),
      );
    } catch (e, stack) {
      _log('ERROR', '目标详情页创建失败', data: {'id': record.id, 'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<void> _addTimelineChapter(pw.Document pdf, {DateTime? startDate, DateTime? endDate}) async {
    _log('INFO', '开始添加时间线章节');
    
    try {
      var query = db.select(db.timelineEvents);
      
      if (startDate != null) {
        query = query..where((t) => t.startAt.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.startAt.isSmallerOrEqualValue(endOfDay));
      }
      
      final records = await query.get();
      _log('INFO', '时间线记录查询完成', data: {'count': records.length});
      
      if (records.isEmpty) {
        _log('INFO', '无时间线记录，跳过章节');
        return;
      }
      
      pdf.addPage(await _createChapterCoverPage('第六章', '时间线', '共 ${records.length} 个事件', const PdfColor.fromInt(0xFF06B6D4)));
      _log('DEBUG', '时间线章节封面页添加完成');
      
      for (final record in records) {
        _log('DEBUG', '处理时间线记录', data: {'id': record.id, 'title': record.title});
        pdf.addPage(await _createTimelineDetailPage(record));
      }
      
      _log('INFO', '时间线章节添加完成', data: {'recordCount': records.length});
    } catch (e, stack) {
      _log('ERROR', '时间线章节添加失败', data: {'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<pw.Page> _createTimelineDetailPage(TimelineEvent record) async {
    _log('DEBUG', '创建时间线详情页', data: {'id': record.id, 'title': record.title});
    
    try {
      return pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 12,
                    height: 12,
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFF06B6D4),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Text(record.title, style: _textStyle(fontSize: 20, bold: true)),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              
              pw.Text('${record.startAt.toString().split('.')[0]}', style: _textStyle(fontSize: 12, color: _mutedColor)),
              if (record.endAt != null)
                pw.Text('至 ${record.endAt!.toString().split('.')[0]}', style: _textStyle(fontSize: 12, color: _mutedColor)),
              pw.SizedBox(height: 16),
              
              if (record.note != null && record.note!.isNotEmpty) ...[
                pw.Text('详情:', style: _textStyle(fontSize: 14, bold: true)),
                pw.SizedBox(height: 4),
                pw.Text(record.note!, style: _textStyle(fontSize: 12)),
              ],
            ],
          ),
        ),
      );
    } catch (e, stack) {
      _log('ERROR', '时间线详情页创建失败', data: {'id': record.id, 'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
  
  Future<void> sharePdf(String filePath) async {
    _log('INFO', '开始分享PDF', data: {'filePath': filePath});
    
    try {
      await Share.shareXFiles([XFile(filePath)], subject: '人生编年史PDF导出');
      _log('INFO', 'PDF分享完成');
    } catch (e, stack) {
      _log('ERROR', 'PDF分享失败', data: {'error': e.toString()}, stackTrace: stack);
      rethrow;
    }
  }
}
