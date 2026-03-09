import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';
import 'file_logger.dart';
import 'path_provider_service.dart';

class PdfExportService {
  final AppDatabase db;
  final PathProviderService pathProvider;
  
  static const _primaryColor = PdfColor.fromInt(0xFF4F46E5);
  static const _secondaryColor = PdfColor.fromInt(0xFF10B981);
  static const _accentColor = PdfColor.fromInt(0xFFF59E0B);
  static const _textColor = PdfColor.fromInt(0xFF1F2937);
  static const _mutedColor = PdfColor.fromInt(0xFF6B7280);
  
  pw.Font? _chineseFont;
  pw.Font? _chineseFontBold;
  bool _fontsLoaded = false;
  
  PdfExportService(this.db, [this.pathProvider = const RealPathProviderService()]);
  
  Future<void> _loadFonts() async {
    if (_fontsLoaded) {
      await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 字体已加载，跳过重复加载', LogLevel.info);
      return;
    }
    
    await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 开始加载字体...', LogLevel.info);
    
    try {
      // 第一步：尝试从应用内 assets 加载字体（最可靠）
      await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 步骤1 - 尝试从应用内assets加载字体', LogLevel.info);
      
      final assetFontPaths = [
        'assets/fonts/NotoSansSC-Regular.otf',
        'assets/fonts/NotoSansSC-Bold.otf',
        'assets/fonts/DroidSansFallback.ttf',
      ];
      
      for (final assetPath in assetFontPaths) {
        try {
          await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 尝试加载asset字体: $assetPath', LogLevel.debug);
          final fontData = await rootBundle.load(assetPath);
          await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: asset字体加载成功: $assetPath, size=${fontData.lengthInBytes}', LogLevel.info);
          
          if (assetPath.contains('Bold')) {
            _chineseFontBold = pw.Font.ttf(fontData);
            await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 粗体字体从assets加载成功', LogLevel.info);
          } else {
            _chineseFont = pw.Font.ttf(fontData);
            await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 常规字体从assets加载成功', LogLevel.info);
          }
        } catch (e) {
          await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: asset字体不存在或加载失败: $assetPath, error=${e.toString()}', LogLevel.debug);
        }
      }
      
      // 如果从 assets 加载成功，直接返回
      if (_chineseFont != null) {
        if (_chineseFontBold == null) {
          _chineseFontBold = _chineseFont;
          await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 粗体字体使用常规字体作为回退', LogLevel.info);
        }
        await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 从assets加载字体完成 - regularFontLoaded=true, boldFontLoaded=true', LogLevel.info);
        _fontsLoaded = true;
        return;
      }
      
      // 第二步：尝试从系统字体路径加载（优先 TTF/OTF，最后尝试 TTC）
      await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 步骤2 - assets加载失败，尝试从系统字体加载', LogLevel.info);
      
      // 优先尝试 TTF/OTF 格式
      final ttfFontPaths = [
        '/system/fonts/NotoSansSC-Regular.otf',
        '/system/fonts/NotoSansCJKsc-Regular.otf',
        '/system/fonts/SourceHanSansSC-Regular.otf',
        '/system/fonts/DroidSansFallbackFull.ttf',
        '/system/fonts/DroidSansFallback.ttf',
        '/system/fonts/Roboto-Regular.ttf',
        '/data/fonts/NotoSansSC-Regular.otf',
        '/data/fonts/DroidSansFallback.ttf',
      ];
      
      final ttfBoldFontPaths = [
        '/system/fonts/NotoSansSC-Bold.otf',
        '/system/fonts/SourceHanSansSC-Bold.otf',
        '/system/fonts/Roboto-Bold.ttf',
        '/system/fonts/Roboto-Medium.ttf',
        '/data/fonts/NotoSansSC-Bold.otf',
      ];
      
      // TTC 格式字体路径（最后尝试）
      final ttcFontPaths = [
        '/system/fonts/NotoSansCJK-Regular.ttc',
        '/system/fonts/NotoSerifCJK-Regular.ttc',
      ];
      
      // 加载 TTF/OTF 格式字体
      await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 尝试加载TTF/OTF格式字体，共${ttfFontPaths.length}个候选', LogLevel.info);
      
      for (int i = 0; i < ttfFontPaths.length; i++) {
        final fontPath = ttfFontPaths[i];
        try {
          final file = File(fontPath);
          final exists = await file.exists();
          
          if (exists) {
            await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 找到TTF/OTF字体: $fontPath', LogLevel.info);
            final fontData = await file.readAsBytes();
            _chineseFont = pw.Font.ttf(ByteData.sublistView(Uint8List.fromList(fontData)));
            await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: TTF/OTF字体加载成功: $fontPath', LogLevel.info);
            break;
          }
        } catch (e) {
          await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 加载TTF/OTF字体失败: $fontPath, error=${e.toString()}', LogLevel.warn);
          continue;
        }
      }
      
      // 加载粗体 TTF/OTF 格式字体
      await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 尝试加载粗体TTF/OTF格式字体，共${ttfBoldFontPaths.length}个候选', LogLevel.info);
      
      for (int i = 0; i < ttfBoldFontPaths.length; i++) {
        final fontPath = ttfBoldFontPaths[i];
        try {
          final file = File(fontPath);
          final exists = await file.exists();
          
          if (exists) {
            await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 找到粗体TTF/OTF字体: $fontPath', LogLevel.info);
            final fontData = await file.readAsBytes();
            _chineseFontBold = pw.Font.ttf(ByteData.sublistView(Uint8List.fromList(fontData)));
            await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 粗体TTF/OTF字体加载成功: $fontPath', LogLevel.info);
            break;
          }
        } catch (e) {
          await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 加载粗体TTF/OTF字体失败: $fontPath, error=${e.toString()}', LogLevel.warn);
          continue;
        }
      }
      
      // 如果 TTF/OTF 都没找到，尝试 TTC 格式（需要特殊处理）
      if (_chineseFont == null) {
        await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: TTF/OTF未找到，尝试TTC格式字体', LogLevel.info);
        
        for (final ttcPath in ttcFontPaths) {
          try {
            final file = File(ttcPath);
            final exists = await file.exists();
            
            if (exists) {
              await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 找到TTC字体: $ttcPath', LogLevel.info);
              final fontData = await file.readAsBytes();
              
              // TTC 文件需要提取单个字体
              // TTC 格式：前12字节是头部，包含字体数量
              // 简单处理：直接尝试加载，pdf库可能会解析失败
              try {
                _chineseFont = pw.Font.ttf(ByteData.sublistView(Uint8List.fromList(fontData)));
                await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: TTC字体加载成功: $ttcPath', LogLevel.info);
                break;
              } catch (ttcError) {
                await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: TTC字体解析失败(库不支持TTC格式): $ttcPath, error=${ttcError.toString()}', LogLevel.warn);
                continue;
              }
            }
          } catch (e) {
            await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 加载TTC字体失败: $ttcPath, error=${e.toString()}', LogLevel.warn);
            continue;
          }
        }
      }
      
      if (_chineseFontBold == null && _chineseFont != null) {
        await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 粗体字体未找到，使用常规字体作为回退', LogLevel.info);
        _chineseFontBold = _chineseFont;
      }
      
      // 记录最终结果
      if (_chineseFont == null) {
        await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 警告 - 未找到任何中文字体，PDF中的中文可能显示为空白', LogLevel.warn);
      }
      
      await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 字体加载完成 - regularFontLoaded=${_chineseFont != null}, boldFontLoaded=${_chineseFontBold != null}', LogLevel.info);
      
      _fontsLoaded = true;
    } catch (e, stack) {
      await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 字体加载过程发生异常: ${e.toString()}', LogLevel.error);
      await FileLogger.instance.logWithLevel('PDF导出', '_loadFonts: 异常堆栈: ${stack.toString()}', LogLevel.error);
      _chineseFont = null;
      _chineseFontBold = null;
      _fontsLoaded = true;
    }
  }
  
  pw.TextStyle _textStyle({
    double fontSize = 12,
    bool bold = false,
    PdfColor color = _textColor,
  }) {
    try {
      final font = bold ? (_chineseFontBold ?? _chineseFont) : _chineseFont;
      
      if (font != null) {
        return pw.TextStyle(
          fontSize: fontSize,
          color: color,
          font: font,
        );
      }
      
      return pw.TextStyle(
        fontSize: fontSize,
        color: color,
      );
    } catch (e) {
      FileLogger.instance.logWithLevel('PDF导出', '_textStyle发生异常: bold=$bold, fontSize=$fontSize, error=${e.toString()}', LogLevel.error);
      return pw.TextStyle(
        fontSize: fontSize,
        color: color,
      );
    }
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
    await FileLogger.instance.logWithLevel('PDF导出', '========== PDF导出开始 ==========', LogLevel.info);
    await FileLogger.instance.logWithLevel('PDF导出', '参数: includeFood=$includeFood, includeMoment=$includeMoment, includeFriend=$includeFriend, includeTravel=$includeTravel, includeGoal=$includeGoal, includeTimeline=$includeTimeline', LogLevel.info);
    
    try {
      await FileLogger.instance.logWithLevel('PDF导出', '步骤1: 开始加载字体', LogLevel.info);
      await _loadFonts();
      await FileLogger.instance.logWithLevel('PDF导出', '步骤1完成: 字体加载结束', LogLevel.info);
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '步骤1异常: 字体加载失败，但继续导出: ${e.toString()}', LogLevel.error);
    }
    
    final pdf = pw.Document();
    await FileLogger.instance.logWithLevel('PDF导出', '步骤2: PDF文档对象已创建', LogLevel.info);
    
    try {
      if (includeCover) {
        await FileLogger.instance.logWithLevel('PDF导出', '步骤3: 开始创建封面页', LogLevel.info);
        pdf.addPage(await _createCoverPage(startDate: startDate, endDate: endDate));
        await FileLogger.instance.logWithLevel('PDF导出', '步骤3完成: 封面页创建完成', LogLevel.info);
      }
      
      if (includeToc) {
        await FileLogger.instance.logWithLevel('PDF导出', '步骤4: 开始创建目录页', LogLevel.info);
        pdf.addPage(await _createTableOfContents(
          includeFood: includeFood,
          includeMoment: includeMoment,
          includeFriend: includeFriend,
          includeTravel: includeTravel,
          includeGoal: includeGoal,
          includeTimeline: includeTimeline,
        ));
        await FileLogger.instance.logWithLevel('PDF导出', '步骤4完成: 目录页创建完成', LogLevel.info);
      }
      
      await FileLogger.instance.logWithLevel('PDF导出', '步骤5: 开始创建概览章节', LogLevel.info);
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
      await FileLogger.instance.logWithLevel('PDF导出', '步骤5完成: 概览章节创建完成', LogLevel.info);
      
      if (includeFood) {
        await FileLogger.instance.logWithLevel('PDF导出', '步骤6: 开始添加美食章节', LogLevel.info);
        await _addFoodChapter(pdf, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
        await FileLogger.instance.logWithLevel('PDF导出', '步骤6完成: 美食章节添加完成', LogLevel.info);
      }
      if (includeMoment) {
        await FileLogger.instance.logWithLevel('PDF导出', '步骤7: 开始添加小确幸章节', LogLevel.info);
        await _addMomentChapter(pdf, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
        await FileLogger.instance.logWithLevel('PDF导出', '步骤7完成: 小确幸章节添加完成', LogLevel.info);
      }
      if (includeFriend) {
        await FileLogger.instance.logWithLevel('PDF导出', '步骤8: 开始添加羁绊章节', LogLevel.info);
        await _addFriendChapter(pdf, includePhotos: includePhotos);
        await FileLogger.instance.logWithLevel('PDF导出', '步骤8完成: 羁绊章节添加完成', LogLevel.info);
      }
      if (includeTravel) {
        await FileLogger.instance.logWithLevel('PDF导出', '步骤9: 开始添加旅行章节', LogLevel.info);
        await _addTravelChapter(pdf, includePhotos: includePhotos, startDate: startDate, endDate: endDate);
        await FileLogger.instance.logWithLevel('PDF导出', '步骤9完成: 旅行章节添加完成', LogLevel.info);
      }
      if (includeGoal) {
        await FileLogger.instance.logWithLevel('PDF导出', '步骤10: 开始添加目标章节', LogLevel.info);
        await _addGoalChapter(pdf);
        await FileLogger.instance.logWithLevel('PDF导出', '步骤10完成: 目标章节添加完成', LogLevel.info);
      }
      if (includeTimeline) {
        await FileLogger.instance.logWithLevel('PDF导出', '步骤11: 开始添加时间线章节', LogLevel.info);
        await _addTimelineChapter(pdf, startDate: startDate, endDate: endDate);
        await FileLogger.instance.logWithLevel('PDF导出', '步骤11完成: 时间线章节添加完成', LogLevel.info);
      }
      
      await FileLogger.instance.logWithLevel('PDF导出', '步骤12: 准备保存PDF文件', LogLevel.info);
      final tempDir = await pathProvider.getTemporaryDirectory();
      await FileLogger.instance.logWithLevel('PDF导出', '临时目录: ${tempDir.path}', LogLevel.debug);
      
      final now = DateTime.now();
      final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final fileName = '人生编年史导出_$timestamp.pdf';
      final filePath = path.join(tempDir.path, fileName);
      
      await FileLogger.instance.logWithLevel('PDF导出', '准备写入文件: $filePath', LogLevel.debug);
      final file = File(filePath);
      
      await FileLogger.instance.logWithLevel('PDF导出', '开始生成PDF字节...', LogLevel.info);
      final pdfBytes = await pdf.save();
      await FileLogger.instance.logWithLevel('PDF导出', 'PDF字节生成完成: size=${pdfBytes.length}', LogLevel.debug);
      
      await FileLogger.instance.logWithLevel('PDF导出', '开始写入磁盘...', LogLevel.info);
      await file.writeAsBytes(pdfBytes);
      
      await FileLogger.instance.logWithLevel('PDF导出', '========== PDF导出成功: $filePath ==========', LogLevel.info);
      return filePath;
    } catch (e, stack) {
      await FileLogger.instance.logWithLevel('PDF导出', '========== PDF导出失败 ==========', LogLevel.error);
      await FileLogger.instance.logWithLevel('PDF导出', '错误信息: ${e.toString()}', LogLevel.error);
      await FileLogger.instance.logWithLevel('PDF导出', '堆栈跟踪: ${stack.toString()}', LogLevel.error);
      rethrow;
    }
  }
  
  Future<pw.Page> _createCoverPage({DateTime? startDate, DateTime? endDate}) async {
    await FileLogger.instance.logWithLevel('PDF导出', '_createCoverPage: 开始创建封面页', LogLevel.info);
    
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
    await FileLogger.instance.logWithLevel('PDF导出', '_createCoverPage: dateRangeText=$dateRangeText', LogLevel.debug);
    
    try {
      await FileLogger.instance.logWithLevel('PDF导出', '_createCoverPage: 准备返回Page对象', LogLevel.debug);
      return pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Container(
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [_primaryColor, PdfColor.fromInt(0xFF7C3AED)],
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
                    boxShadow: [
                      pw.BoxShadow(
                        color: const PdfColor.fromInt(0x33000000),
                        blurRadius: 20,
                        offset: const PdfPoint(0, 10),
                      ),
                    ],
                  ),
                  child: pw.Center(
                    child: pw.Text('LC', style: _textStyle(fontSize: 48, color: _primaryColor, bold: true)),
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  '人生编年史',
                  style: _textStyle(fontSize: 42, color: PdfColors.white, bold: true),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  '数据导出报告',
                  style: _textStyle(fontSize: 24, color: const PdfColor.fromInt(0xE6FFFFFF)),
                ),
                pw.SizedBox(height: 60),
                pw.Text(
                  '导出日期: ${DateTime.now().toString().split('.')[0]}$dateRangeText',
                  style: _textStyle(fontSize: 14, color: const PdfColor.fromInt(0xCCFFFFFF)),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '封面页创建失败，尝试简化版本: ${e.toString()}', LogLevel.error);
      return pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Container(
          color: _primaryColor,
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
                    child: pw.Text('LC', style: pw.TextStyle(fontSize: 48, color: _primaryColor)),
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  '人生编年史',
                  style: pw.TextStyle(fontSize: 42, color: PdfColors.white),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  '数据导出报告',
                  style: pw.TextStyle(fontSize: 24, color: PdfColors.white),
                ),
              ],
            ),
          ),
        ),
      );
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
    await FileLogger.instance.logWithLevel('PDF导出', '开始创建目录页', LogLevel.info);
    
    final chapters = <Map<String, dynamic>>[];
    if (includeFood) chapters.add({'title': '第一章：美食记录', 'page': 3});
    if (includeMoment) chapters.add({'title': '第二章：小确幸', 'page': includeFood ? 4 : 3});
    if (includeFriend) chapters.add({'title': '第三章：羁绊', 'page': (includeFood ? 1 : 0) + (includeMoment ? 1 : 0) + 3});
    if (includeTravel) chapters.add({'title': '第四章：旅行足迹', 'page': (includeFood ? 1 : 0) + (includeMoment ? 1 : 0) + (includeFriend ? 1 : 0) + 3});
    if (includeGoal) chapters.add({'title': '第五章：目标规划', 'page': (includeFood ? 1 : 0) + (includeMoment ? 1 : 0) + (includeFriend ? 1 : 0) + (includeTravel ? 1 : 0) + 3});
    if (includeTimeline) chapters.add({'title': '第六章：时间线', 'page': (includeFood ? 1 : 0) + (includeMoment ? 1 : 0) + (includeFriend ? 1 : 0) + (includeTravel ? 1 : 0) + (includeGoal ? 1 : 0) + 3});
    
    try {
      return pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(48),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('目录', style: _textStyle(fontSize: 36, color: _primaryColor, bold: true)),
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
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '目录页创建失败: ${e.toString()}', LogLevel.error);
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
    await FileLogger.instance.logWithLevel('PDF导出', '开始创建概览章节', LogLevel.info);
    
    try {
      final stats = <Map<String, dynamic>>[];
      
      if (includeFood) {
        var query = db.select(db.foodRecords);
        if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
          query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
        }
        final count = await query.get().then((r) => r.length);
        stats.add({'title': '美食记录', 'count': count, 'color': _primaryColor});
      }
      
      if (includeMoment) {
        var query = db.select(db.momentRecords);
        if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
          query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
        }
        final count = await query.get().then((r) => r.length);
        stats.add({'title': '小确幸', 'count': count, 'color': _secondaryColor});
      }
      
      if (includeFriend) {
        final count = await (db.select(db.friendRecords)).get().then((r) => r.length);
        stats.add({'title': '羁绊', 'count': count, 'color': const PdfColor.fromInt(0xFFEC4899)});
      }
      
      if (includeTravel) {
        var query = db.select(db.travelRecords);
        if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
          query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
        }
        final count = await query.get().then((r) => r.length);
        stats.add({'title': '旅行', 'count': count, 'color': _accentColor});
      }
      
      if (includeGoal) {
        final count = await (db.select(db.goalRecords)).get().then((r) => r.length);
        stats.add({'title': '目标', 'count': count, 'color': const PdfColor.fromInt(0xFF8B5CF6)});
      }
      
      if (includeTimeline) {
        var query = db.select(db.timelineEvents);
        if (startDate != null) query = query..where((t) => t.startAt.isBiggerOrEqualValue(startDate));
        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
          query = query..where((t) => t.startAt.isSmallerOrEqualValue(endOfDay));
        }
        final count = await query.get().then((r) => r.length);
        stats.add({'title': '时间线', 'count': count, 'color': const PdfColor.fromInt(0xFF06B6D4)});
      }
      
      await FileLogger.instance.logWithLevel('PDF导出', '概览章节数据准备完成', LogLevel.info);
      
      return pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('数据概览', style: _textStyle(fontSize: 32, color: _primaryColor, bold: true)),
              pw.SizedBox(height: 24),
              pw.Wrap(
                spacing: 16,
                runSpacing: 16,
                children: stats.map((stat) => _buildStatCard(
                  stat['title'] as String, 
                  stat['count'] as int, 
                  stat['color'] as PdfColor,
                )).toList(),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '概览章节创建失败，尝试简化版本: ${e.toString()}', LogLevel.error);
      
      final stats = <String>[];
      
      if (includeFood) {
        var query = db.select(db.foodRecords);
        if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
          query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
        }
        final count = await query.get().then((r) => r.length);
        stats.add('美食记录: $count');
      }
      
      if (includeMoment) {
        var query = db.select(db.momentRecords);
        if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
          query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
        }
        final count = await query.get().then((r) => r.length);
        stats.add('小确幸: $count');
      }
      
      if (includeFriend) {
        final count = await (db.select(db.friendRecords)).get().then((r) => r.length);
        stats.add('羁绊: $count');
      }
      
      if (includeTravel) {
        var query = db.select(db.travelRecords);
        if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
          query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
        }
        final count = await query.get().then((r) => r.length);
        stats.add('旅行: $count');
      }
      
      if (includeGoal) {
        final count = await (db.select(db.goalRecords)).get().then((r) => r.length);
        stats.add('目标: $count');
      }
      
      if (includeTimeline) {
        var query = db.select(db.timelineEvents);
        if (startDate != null) query = query..where((t) => t.startAt.isBiggerOrEqualValue(startDate));
        if (endDate != null) {
          final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
          query = query..where((t) => t.startAt.isSmallerOrEqualValue(endOfDay));
        }
        final count = await query.get().then((r) => r.length);
        stats.add('时间线: $count');
      }
      
      return pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('数据概览', style: pw.TextStyle(fontSize: 32, color: _primaryColor)),
              pw.SizedBox(height: 24),
              ...stats.map((stat) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Text(stat, style: pw.TextStyle(fontSize: 18)),
              )),
            ],
          ),
        ),
      );
    }
  }
  
  pw.Widget _buildStatCard(String title, int count, PdfColor color) {
    try {
      final bgColor = PdfColor.fromInt((color.toInt() & 0x00FFFFFF) | 0x1A000000);
      final shadowColor = PdfColor.fromInt(0x10000000);
      
      return pw.Container(
        width: 140,
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: pw.BorderRadius.circular(16),
          boxShadow: [
            pw.BoxShadow(
              color: shadowColor,
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
            pw.Text('$count', style: _textStyle(fontSize: 32, color: color, bold: true)),
          ],
        ),
      );
    } catch (e) {
      return pw.Container(
        width: 140,
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0x1A000000),
          borderRadius: pw.BorderRadius.circular(16),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 14, color: _mutedColor)),
            pw.SizedBox(height: 12),
            pw.Text('$count', style: pw.TextStyle(fontSize: 32, color: color)),
          ],
        ),
      );
    }
  }
  
  Future<pw.Page> _createChapterCoverPage(String chapter, String title, String subtitle, PdfColor color) async {
    await FileLogger.instance.logWithLevel('PDF导出', '创建章节封面页: chapter=$chapter, title=$title', LogLevel.info);
    
    try {
      return pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Container(
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [color, PdfColor.fromInt((color.toInt() & 0x00FFFFFF) | 0x4B000000)],
              begin: pw.Alignment.topLeft,
              end: pw.Alignment.bottomRight,
            ),
          ),
          child: pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(chapter, style: _textStyle(fontSize: 24, color: PdfColors.white)),
                pw.SizedBox(height: 16),
                pw.Text(title, style: _textStyle(fontSize: 48, color: PdfColors.white, bold: true)),
                pw.SizedBox(height: 24),
                pw.Text(subtitle, style: _textStyle(fontSize: 14, color: const PdfColor.fromInt(0xE6FFFFFF))),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '章节封面页创建失败，使用纯色版本: chapter=$chapter, error=${e.toString()}', LogLevel.error);
      return pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Container(
          color: color,
          child: pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(chapter, style: pw.TextStyle(fontSize: 24, color: PdfColors.white)),
                pw.SizedBox(height: 16),
                pw.Text(title, style: pw.TextStyle(fontSize: 48, color: PdfColors.white)),
                pw.SizedBox(height: 24),
                pw.Text(subtitle, style: pw.TextStyle(fontSize: 14, color: PdfColors.white)),
              ],
            ),
          ),
        ),
      );
    }
  }
  
  Future<void> _addFoodChapter(pw.Document pdf, {required bool includePhotos, DateTime? startDate, DateTime? endDate}) async {
    await FileLogger.instance.logWithLevel('PDF导出', '开始添加美食章节', LogLevel.info);
    
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
      await FileLogger.instance.logWithLevel('PDF导出', '美食记录查询完成: count=${records.length}', LogLevel.info);
      
      if (records.isEmpty) {
        await FileLogger.instance.logWithLevel('PDF导出', '无美食记录，跳过章节', LogLevel.info);
        return;
      }
      
      pdf.addPage(await _createChapterCoverPage('第一章', '美食记录', '共 ${records.length} 条记录', _primaryColor));
      await FileLogger.instance.logWithLevel('PDF导出', '美食章节封面页添加完成', LogLevel.debug);
      
      for (final record in records) {
        await FileLogger.instance.logWithLevel('PDF导出', '处理美食记录: id=${record.id}, title=${record.title}', LogLevel.debug);
        
        List<File> images = [];
        if (includePhotos && record.images != null && record.images!.isNotEmpty) {
          try {
            final imageList = jsonDecode(record.images!) as List<dynamic>;
            images = imageList
                .map((p) => File(p.toString()))
                .where((f) => f.existsSync())
                .toList();
            await FileLogger.instance.logWithLevel('PDF导出', '美食记录图片加载完成: id=${record.id}, imageCount=${images.length}', LogLevel.debug);
          } catch (e) {
            await FileLogger.instance.logWithLevel('PDF导出', '美食记录图片加载失败: id=${record.id}, error=${e.toString()}', LogLevel.warn);
          }
        }
        
        pdf.addPage(await _createFoodDetailPage(record, images));
      }
      
      await FileLogger.instance.logWithLevel('PDF导出', '美食章节添加完成: recordCount=${records.length}', LogLevel.info);
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '美食章节添加失败: ${e.toString()}', LogLevel.error);
      rethrow;
    }
  }
  
  Future<pw.Page> _createFoodDetailPage(FoodRecord record, List<File> images) async {
    await FileLogger.instance.logWithLevel('PDF导出', '创建美食详情页: id=${record.id}, title=${record.title}, imageCount=${images.length}', LogLevel.debug);
    
    try {
      final imageWidgets = <pw.Widget>[];
      
      for (final imageFile in images) {
        try {
          await FileLogger.instance.logWithLevel('PDF导出', '加载美食图片: path=${imageFile.path}', LogLevel.debug);
          final bytes = await imageFile.readAsBytes();
          final image = pw.MemoryImage(bytes);
          imageWidgets.add(
            pw.ClipRRect(
              horizontalRadius: 12,
              verticalRadius: 12,
              child: pw.Image(image, fit: pw.BoxFit.cover),
            ),
          );
          await FileLogger.instance.logWithLevel('PDF导出', '美食图片加载成功: path=${imageFile.path}', LogLevel.debug);
        } catch (e) {
          await FileLogger.instance.logWithLevel('PDF导出', '无法加载美食图片: path=${imageFile.path}, error=${e.toString()}', LogLevel.warn);
        }
      }
      
      final children = <pw.Widget>[
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
        pw.Text('${record.title} | ${record.tags ?? '未知菜系'}', 
            style: _textStyle(fontSize: 14, color: _mutedColor)),
        pw.SizedBox(height: 16),
      ];
      
      if (imageWidgets.isNotEmpty) {
        final crossAxisCount = imageWidgets.length > 4 ? 3 : (imageWidgets.length > 2 ? 2 : imageWidgets.length);
        final gridHeight = imageWidgets.length <= 4 ? 200.0 : (imageWidgets.length <= 9 ? 300.0 : 400.0);
        
        children.addAll([
          pw.Container(
            height: gridHeight,
            child: pw.GridView(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: imageWidgets,
            ),
          ),
          pw.SizedBox(height: 16),
        ]);
      }
      
      children.addAll([
        pw.Text('评分: ${record.rating}/5', style: _textStyle(fontSize: 14, color: _secondaryColor)),
        pw.SizedBox(height: 8),
        
        if (record.content != null && record.content!.isNotEmpty) ...[
          pw.Text('评价:', style: _textStyle(fontSize: 14, bold: true)),
          pw.SizedBox(height: 4),
          pw.Text(record.content!, style: _textStyle(fontSize: 12)),
          pw.SizedBox(height: 8),
        ],
        
        pw.Text(record.recordDate.toString().split(' ')[0], style: _textStyle(fontSize: 10, color: _mutedColor)),
      ]);
      
      return pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '美食详情页创建失败: id=${record.id}, error=${e.toString()}', LogLevel.error);
      rethrow;
    }
  }
  
  Future<void> _addMomentChapter(pw.Document pdf, {required bool includePhotos, DateTime? startDate, DateTime? endDate}) async {
    await FileLogger.instance.logWithLevel('PDF导出', '开始添加小确幸章节', LogLevel.info);
    
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
      await FileLogger.instance.logWithLevel('PDF导出', '小确幸记录查询完成: count=${records.length}', LogLevel.info);
      
      if (records.isEmpty) {
        await FileLogger.instance.logWithLevel('PDF导出', '无小确幸记录，跳过章节', LogLevel.info);
        return;
      }
      
      pdf.addPage(await _createChapterCoverPage('第二章', '小确幸', '共 ${records.length} 条记录', _secondaryColor));
      await FileLogger.instance.logWithLevel('PDF导出', '小确幸章节封面页添加完成', LogLevel.debug);
      
      for (final record in records) {
        await FileLogger.instance.logWithLevel('PDF导出', '处理小确幸记录: id=${record.id}', LogLevel.debug);
        
        List<File> images = [];
        if (includePhotos && record.images != null && record.images!.isNotEmpty) {
          try {
            final imageList = jsonDecode(record.images!) as List<dynamic>;
            images = imageList
                .map((p) => File(p.toString()))
                .where((f) => f.existsSync())
                .toList();
            await FileLogger.instance.logWithLevel('PDF导出', '小确幸记录图片加载完成: id=${record.id}, imageCount=${images.length}', LogLevel.debug);
          } catch (e) {
            await FileLogger.instance.logWithLevel('PDF导出', '小确幸记录图片加载失败: id=${record.id}, error=${e.toString()}', LogLevel.warn);
          }
        }
        
        pdf.addPage(await _createMomentDetailPage(record, images));
      }
      
      await FileLogger.instance.logWithLevel('PDF导出', '小确幸章节添加完成: recordCount=${records.length}', LogLevel.info);
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '小确幸章节添加失败: ${e.toString()}', LogLevel.error);
      rethrow;
    }
  }
  
  Future<pw.Page> _createMomentDetailPage(MomentRecord record, List<File> images) async {
    await FileLogger.instance.logWithLevel('PDF导出', '创建小确幸详情页: id=${record.id}, imageCount=${images.length}', LogLevel.debug);
    
    try {
      final imageWidgets = <pw.Widget>[];
      
      for (final imageFile in images) {
        try {
          await FileLogger.instance.logWithLevel('PDF导出', '加载小确幸图片: path=${imageFile.path}', LogLevel.debug);
          final bytes = await imageFile.readAsBytes();
          final image = pw.MemoryImage(bytes);
          imageWidgets.add(
            pw.ClipRRect(
              horizontalRadius: 12,
              verticalRadius: 12,
              child: pw.Image(image, fit: pw.BoxFit.cover),
            ),
          );
          await FileLogger.instance.logWithLevel('PDF导出', '小确幸图片加载成功: path=${imageFile.path}', LogLevel.debug);
        } catch (e) {
          await FileLogger.instance.logWithLevel('PDF导出', '无法加载小确幸图片: path=${imageFile.path}, error=${e.toString()}', LogLevel.warn);
        }
      }
      
      final children = <pw.Widget>[
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(record.mood, style: _textStyle(fontSize: 20, color: _secondaryColor, bold: true)),
            ),
            if (record.isFavorite)
              pw.Text('❤', style: _textStyle(fontSize: 20, color: const PdfColor.fromInt(0xFFEC4899))),
          ],
        ),
        pw.SizedBox(height: 16),
      ];
      
      if (imageWidgets.isNotEmpty) {
        final crossAxisCount = imageWidgets.length > 4 ? 3 : (imageWidgets.length > 2 ? 2 : imageWidgets.length);
        final gridHeight = imageWidgets.length <= 4 ? 200.0 : (imageWidgets.length <= 9 ? 300.0 : 400.0);
        
        children.addAll([
          pw.Container(
            height: gridHeight,
            child: pw.GridView(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: imageWidgets,
            ),
          ),
          pw.SizedBox(height: 16),
        ]);
      }
      
      children.addAll([
        pw.Text(record.content ?? '', style: _textStyle(fontSize: 14, color: _textColor)),
        pw.SizedBox(height: 16),
        
        pw.Text(record.recordDate.toString().split(' ')[0], style: _textStyle(fontSize: 10, color: _mutedColor)),
      ]);
      
      return pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '小确幸详情页创建失败: id=${record.id}, error=${e.toString()}', LogLevel.error);
      rethrow;
    }
  }
  
  Future<void> _addFriendChapter(pw.Document pdf, {required bool includePhotos}) async {
    await FileLogger.instance.logWithLevel('PDF导出', '开始添加羁绊章节', LogLevel.info);
    
    try {
      final records = await (db.select(db.friendRecords)).get();
      await FileLogger.instance.logWithLevel('PDF导出', '羁绊记录查询完成: count=${records.length}', LogLevel.info);
      
      if (records.isEmpty) {
        await FileLogger.instance.logWithLevel('PDF导出', '无羁绊记录，跳过章节', LogLevel.info);
        return;
      }
      
      pdf.addPage(await _createChapterCoverPage('第三章', '羁绊', '共 ${records.length} 位好友', const PdfColor.fromInt(0xFFEC4899)));
      await FileLogger.instance.logWithLevel('PDF导出', '羁绊章节封面页添加完成', LogLevel.debug);
      
      for (final record in records) {
        await FileLogger.instance.logWithLevel('PDF导出', '处理羁绊记录: id=${record.id}, name=${record.name}', LogLevel.debug);
        pdf.addPage(await _createFriendDetailPage(record, includePhotos: includePhotos));
      }
      
      await FileLogger.instance.logWithLevel('PDF导出', '羁绊章节添加完成: recordCount=${records.length}', LogLevel.info);
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '羁绊章节添加失败: ${e.toString()}', LogLevel.error);
      rethrow;
    }
  }
  
  Future<pw.Page> _createFriendDetailPage(FriendRecord record, {required bool includePhotos}) async {
    await FileLogger.instance.logWithLevel('PDF导出', '创建羁绊详情页: id=${record.id}, name=${record.name}', LogLevel.debug);
    
    try {
      pw.Widget? avatarWidget;
      
      if (includePhotos && record.avatarPath != null && record.avatarPath!.isNotEmpty) {
        try {
          await FileLogger.instance.logWithLevel('PDF导出', '加载羁绊头像: id=${record.id}, avatarPath=${record.avatarPath}', LogLevel.debug);
          final avatarFile = File(record.avatarPath!);
          if (await avatarFile.exists()) {
            final bytes = await avatarFile.readAsBytes();
            final image = pw.MemoryImage(bytes);
            avatarWidget = pw.ClipRRect(
              horizontalRadius: 40,
              verticalRadius: 40,
              child: pw.Image(image, fit: pw.BoxFit.cover, width: 80, height: 80),
            );
            await FileLogger.instance.logWithLevel('PDF导出', '羁绊头像加载成功: id=${record.id}', LogLevel.debug);
          } else {
            await FileLogger.instance.logWithLevel('PDF导出', '羁绊头像文件不存在: id=${record.id}, path=${record.avatarPath}', LogLevel.warn);
          }
        } catch (e) {
          await FileLogger.instance.logWithLevel('PDF导出', '无法加载羁绊头像: id=${record.id}, error=${e.toString()}', LogLevel.warn);
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
            style: _textStyle(fontSize: 32, color: PdfColors.white, bold: true),
          ),
        ),
      );
      
      final avatar = avatarWidget;
      
      return pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  avatar,
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(record.name, style: _textStyle(fontSize: 28, bold: true)),
                        pw.SizedBox(height: 4),
                        if (record.groupName != null && record.groupName!.isNotEmpty)
                          pw.Text(record.groupName!, style: _textStyle(fontSize: 14, color: _mutedColor)),
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
              
              if (record.impressionTags != null && record.impressionTags!.isNotEmpty) ...[
                pw.Text('备注:', style: _textStyle(fontSize: 14, bold: true)),
                pw.SizedBox(height: 4),
                pw.Text(record.impressionTags!, style: _textStyle(fontSize: 12)),
              ],
            ],
          ),
        ),
      );
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '羁绊详情页创建失败: id=${record.id}, error=${e.toString()}', LogLevel.error);
      rethrow;
    }
  }
  
  Future<void> _addTravelChapter(pw.Document pdf, {required bool includePhotos, DateTime? startDate, DateTime? endDate}) async {
    await FileLogger.instance.logWithLevel('PDF导出', '开始添加旅行章节', LogLevel.info);
    
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
      await FileLogger.instance.logWithLevel('PDF导出', '旅行记录查询完成: count=${records.length}', LogLevel.info);
      
      if (records.isEmpty) {
        await FileLogger.instance.logWithLevel('PDF导出', '无旅行记录，跳过章节', LogLevel.info);
        return;
      }
      
      pdf.addPage(await _createChapterCoverPage('第四章', '旅行足迹', '共 ${records.length} 次旅行', _accentColor));
      await FileLogger.instance.logWithLevel('PDF导出', '旅行章节封面页添加完成', LogLevel.debug);
      
      for (final record in records) {
        await FileLogger.instance.logWithLevel('PDF导出', '处理旅行记录: id=${record.id}, destination=${record.destination}', LogLevel.debug);
        
        List<File> images = [];
        if (includePhotos && record.images != null && record.images!.isNotEmpty) {
          try {
            final imageList = jsonDecode(record.images!) as List<dynamic>;
            images = imageList
                .map((p) => File(p.toString()))
                .where((f) => f.existsSync())
                .toList();
            await FileLogger.instance.logWithLevel('PDF导出', '旅行记录图片加载完成: id=${record.id}, imageCount=${images.length}', LogLevel.debug);
          } catch (e) {
            await FileLogger.instance.logWithLevel('PDF导出', '旅行记录图片加载失败: id=${record.id}, error=${e.toString()}', LogLevel.warn);
          }
        }
        
        pdf.addPage(await _createTravelDetailPage(record, images));
      }
      
      await FileLogger.instance.logWithLevel('PDF导出', '旅行章节添加完成: recordCount=${records.length}', LogLevel.info);
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '旅行章节添加失败: ${e.toString()}', LogLevel.error);
      rethrow;
    }
  }
  
  Future<pw.Page> _createTravelDetailPage(TravelRecord record, List<File> images) async {
    await FileLogger.instance.logWithLevel('PDF导出', '创建旅行详情页: id=${record.id}, destination=${record.destination}, imageCount=${images.length}', LogLevel.debug);
    
    try {
      final imageWidgets = <pw.Widget>[];
      
      for (final imageFile in images) {
        try {
          await FileLogger.instance.logWithLevel('PDF导出', '加载旅行图片: path=${imageFile.path}', LogLevel.debug);
          final bytes = await imageFile.readAsBytes();
          final image = pw.MemoryImage(bytes);
          imageWidgets.add(
            pw.ClipRRect(
              horizontalRadius: 12,
              verticalRadius: 12,
              child: pw.Image(image, fit: pw.BoxFit.cover),
            ),
          );
          await FileLogger.instance.logWithLevel('PDF导出', '旅行图片加载成功: path=${imageFile.path}', LogLevel.debug);
        } catch (e) {
          await FileLogger.instance.logWithLevel('PDF导出', '无法加载旅行图片: path=${imageFile.path}, error=${e.toString()}', LogLevel.warn);
        }
      }
      
      final children = <pw.Widget>[
        pw.Text(record.destination ?? '未知目的地', style: _textStyle(fontSize: 28, color: _accentColor, bold: true)),
        pw.SizedBox(height: 8),
        if (record.planDate != null)
          pw.Text('计划日期: ${record.planDate!.toString().split(' ')[0]}', style: _textStyle(fontSize: 12, color: _mutedColor)),
        pw.SizedBox(height: 16),
      ];
      
      if (imageWidgets.isNotEmpty) {
        final crossAxisCount = imageWidgets.length > 4 ? 3 : (imageWidgets.length > 2 ? 2 : imageWidgets.length);
        final gridHeight = imageWidgets.length <= 4 ? 200.0 : (imageWidgets.length <= 9 ? 300.0 : 400.0);
        
        children.addAll([
          pw.Container(
            height: gridHeight,
            child: pw.GridView(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: imageWidgets,
            ),
          ),
          pw.SizedBox(height: 16),
        ]);
      }
      
      children.addAll([
        if (record.content != null && record.content!.isNotEmpty) ...[
          pw.Text('旅行计划:', style: _textStyle(fontSize: 14, bold: true)),
          pw.SizedBox(height: 4),
          pw.Text(record.content!, style: _textStyle(fontSize: 12)),
          pw.SizedBox(height: 8),
        ],
        
        pw.Text('状态: ${record.isWishlist ? "愿望清单" : (record.wishlistDone ? "已完成" : "进行中")}', style: _textStyle(fontSize: 12, color: _secondaryColor)),
      ]);
      
      return pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '旅行详情页创建失败: id=${record.id}, error=${e.toString()}', LogLevel.error);
      rethrow;
    }
  }
  
  Future<void> _addGoalChapter(pw.Document pdf) async {
    await FileLogger.instance.logWithLevel('PDF导出', '开始添加目标章节', LogLevel.info);
    
    try {
      final records = await (db.select(db.goalRecords)).get();
      await FileLogger.instance.logWithLevel('PDF导出', '目标记录查询完成: count=${records.length}', LogLevel.info);
      
      if (records.isEmpty) {
        await FileLogger.instance.logWithLevel('PDF导出', '无目标记录，跳过章节', LogLevel.info);
        return;
      }
      
      pdf.addPage(await _createChapterCoverPage('第五章', '目标规划', '共 ${records.length} 个目标', const PdfColor.fromInt(0xFF8B5CF6)));
      await FileLogger.instance.logWithLevel('PDF导出', '目标章节封面页添加完成', LogLevel.debug);
      
      for (final record in records) {
        await FileLogger.instance.logWithLevel('PDF导出', '处理目标记录: id=${record.id}, title=${record.title}', LogLevel.debug);
        pdf.addPage(await _createGoalDetailPage(record));
      }
      
      await FileLogger.instance.logWithLevel('PDF导出', '目标章节添加完成: recordCount=${records.length}', LogLevel.info);
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '目标章节添加失败: ${e.toString()}', LogLevel.error);
      rethrow;
    }
  }
  
  Future<pw.Page> _createGoalDetailPage(GoalRecord record) async {
    await FileLogger.instance.logWithLevel('PDF导出', '创建目标详情页: id=${record.id}, title=${record.title}', LogLevel.debug);
    
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
                      color: record.isCompleted 
                          ? const PdfColor.fromInt(0xFF10B981) 
                          : const PdfColor.fromInt(0xFFF59E0B),
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Text(
                      record.isCompleted ? '已完成' : '进行中',
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
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '目标详情页创建失败: id=${record.id}, error=${e.toString()}', LogLevel.error);
      rethrow;
    }
  }
  
  Future<void> _addTimelineChapter(pw.Document pdf, {DateTime? startDate, DateTime? endDate}) async {
    await FileLogger.instance.logWithLevel('PDF导出', '开始添加时间线章节', LogLevel.info);
    
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
      await FileLogger.instance.logWithLevel('PDF导出', '时间线记录查询完成: count=${records.length}', LogLevel.info);
      
      if (records.isEmpty) {
        await FileLogger.instance.logWithLevel('PDF导出', '无时间线记录，跳过章节', LogLevel.info);
        return;
      }
      
      pdf.addPage(await _createChapterCoverPage('第六章', '时间线', '共 ${records.length} 个事件', const PdfColor.fromInt(0xFF06B6D4)));
      await FileLogger.instance.logWithLevel('PDF导出', '时间线章节封面页添加完成', LogLevel.debug);
      
      for (final record in records) {
        await FileLogger.instance.logWithLevel('PDF导出', '处理时间线记录: id=${record.id}, title=${record.title}', LogLevel.debug);
        pdf.addPage(await _createTimelineDetailPage(record));
      }
      
      await FileLogger.instance.logWithLevel('PDF导出', '时间线章节添加完成: recordCount=${records.length}', LogLevel.info);
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '瞬间章节添加失败: ${e.toString()}', LogLevel.error);
      rethrow;
    }
  }
  
  Future<pw.Page> _createTimelineDetailPage(TimelineEvent record) async {
    await FileLogger.instance.logWithLevel('PDF导出', '创建时间线详情页: id=${record.id}, title=${record.title}', LogLevel.debug);
    
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
              
              pw.Text(record.startAt.toString().split('.')[0], style: _textStyle(fontSize: 12, color: _mutedColor)),
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
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '时间线详情页创建失败: id=${record.id}, error=${e.toString()}', LogLevel.error);
      rethrow;
    }
  }
  
  Future<void> sharePdf(String filePath) async {
    await FileLogger.instance.logWithLevel('PDF导出', '开始分享PDF: $filePath', LogLevel.info);
    
    try {
      await Share.shareXFiles([XFile(filePath)], subject: '人生编年史PDF导出');
      await FileLogger.instance.logWithLevel('PDF导出', 'PDF分享完成', LogLevel.info);
    } catch (e) {
      await FileLogger.instance.logWithLevel('PDF导出', '生成PDF封面图片失败，使用默认封面: ${e.toString()}', LogLevel.error);
      rethrow;
    }
  }
}
