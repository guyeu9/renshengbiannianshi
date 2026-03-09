import 'dart:io';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';
import 'file_logger.dart';

class ExcelExportService {
  final AppDatabase db;
  static const String _tag = 'ExcelExport';
  
  ExcelExportService(this.db);
  
  Future<String> exportToExcel({
    bool includeFood = true,
    bool includeMoment = true,
    bool includeFriend = true,
    bool includeTravel = true,
    bool includeGoal = true,
    bool includeTimeline = true,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final stopwatch = Stopwatch()..start();
    await amapInfo(_tag, '开始导出Excel, startDate=$startDate, endDate=$endDate');
    
    final excel = Excel.createExcel();
    
    await _createOverviewSheet(excel,
      includeFood: includeFood,
      includeMoment: includeMoment,
      includeFriend: includeFriend,
      includeTravel: includeTravel,
      includeGoal: includeGoal,
      includeTimeline: includeTimeline,
      startDate: startDate,
      endDate: endDate,
    );
    
    if (includeFood) {
      await _exportFoodRecords(excel, startDate: startDate, endDate: endDate);
    }
    if (includeMoment) {
      await _exportMomentRecords(excel, startDate: startDate, endDate: endDate);
    }
    if (includeFriend) {
      await _exportFriendRecords(excel);
    }
    if (includeTravel) {
      await _exportTravelRecords(excel, startDate: startDate, endDate: endDate);
    }
    if (includeGoal) {
      await _exportGoalRecords(excel);
    }
    if (includeTimeline) {
      await _exportTimelineEvents(excel, startDate: startDate, endDate: endDate);
    }
    
    excel.delete('Sheet1');
    
    final tempDir = await getTemporaryDirectory();
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final fileName = '人生编年史导出_$timestamp.xlsx';
    final filePath = path.join(tempDir.path, fileName);
    
    final bytes = excel.encode();
    if (bytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      final fileSize = bytes.length;
      stopwatch.stop();
      await amapPerf(_tag, 'exportToExcel', stopwatch.elapsedMilliseconds, sizeBytes: fileSize);
      await amapInfo(_tag, '导出完成: $filePath');
    }
    
    return filePath;
  }
  
  Future<void> _createOverviewSheet(Excel excel, {
    required bool includeFood,
    required bool includeMoment,
    required bool includeFriend,
    required bool includeTravel,
    required bool includeGoal,
    required bool includeTimeline,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final sheet = excel['数据概览'];
    
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('F1'));
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('人生编年史 - 数据导出报告');
    titleCell.cellStyle = CellStyle(bold: true, fontSize: 16);
    
    sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('导出时间:');
    sheet.cell(CellIndex.indexByString('B3')).value = TextCellValue(DateTime.now().toString().split('.')[0]);
    
    sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue('导出版本:');
    sheet.cell(CellIndex.indexByString('B4')).value = TextCellValue('v1.0');
    
    if (startDate != null || endDate != null) {
      sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue('时间范围:');
      final startStr = startDate != null ? '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}' : '不限';
      final endStr = endDate != null ? '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}' : '不限';
      sheet.cell(CellIndex.indexByString('B5')).value = TextCellValue('$startStr 至 $endStr');
    }
    
    int rowNum = 7;
    sheet.cell(CellIndex.indexByString('A$rowNum')).value = TextCellValue('模块');
    sheet.cell(CellIndex.indexByString('B$rowNum')).value = TextCellValue('记录数');
    sheet.cell(CellIndex.indexByString('C$rowNum')).value = TextCellValue('状态');
    
    for (var col in ['A', 'B', 'C']) {
      final cell = sheet.cell(CellIndex.indexByString('$col$rowNum'));
      cell.cellStyle = CellStyle(bold: true);
    }
    
    rowNum++;
    
    if (includeFood) {
      var query = db.select(db.foodRecords);
      if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      sheet.cell(CellIndex.indexByString('A$rowNum')).value = TextCellValue('美食记录');
      sheet.cell(CellIndex.indexByString('B$rowNum')).value = IntCellValue(count);
      sheet.cell(CellIndex.indexByString('C$rowNum')).value = TextCellValue('已导出');
      rowNum++;
    }
    
    if (includeMoment) {
      var query = db.select(db.momentRecords);
      if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      sheet.cell(CellIndex.indexByString('A$rowNum')).value = TextCellValue('小确幸');
      sheet.cell(CellIndex.indexByString('B$rowNum')).value = IntCellValue(count);
      sheet.cell(CellIndex.indexByString('C$rowNum')).value = TextCellValue('已导出');
      rowNum++;
    }
    
    if (includeFriend) {
      final count = await (db.select(db.friendRecords)).get().then((r) => r.length);
      sheet.cell(CellIndex.indexByString('A$rowNum')).value = TextCellValue('羁绊');
      sheet.cell(CellIndex.indexByString('B$rowNum')).value = IntCellValue(count);
      sheet.cell(CellIndex.indexByString('C$rowNum')).value = TextCellValue('已导出');
      rowNum++;
    }
    
    if (includeTravel) {
      var query = db.select(db.travelRecords);
      if (startDate != null) query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      sheet.cell(CellIndex.indexByString('A$rowNum')).value = TextCellValue('旅行');
      sheet.cell(CellIndex.indexByString('B$rowNum')).value = IntCellValue(count);
      sheet.cell(CellIndex.indexByString('C$rowNum')).value = TextCellValue('已导出');
      rowNum++;
    }
    
    if (includeGoal) {
      final count = await (db.select(db.goalRecords)).get().then((r) => r.length);
      sheet.cell(CellIndex.indexByString('A$rowNum')).value = TextCellValue('目标');
      sheet.cell(CellIndex.indexByString('B$rowNum')).value = IntCellValue(count);
      sheet.cell(CellIndex.indexByString('C$rowNum')).value = TextCellValue('已导出');
      rowNum++;
    }
    
    if (includeTimeline) {
      var query = db.select(db.timelineEvents);
      if (startDate != null) query = query..where((t) => t.startAt.isBiggerOrEqualValue(startDate));
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query..where((t) => t.startAt.isSmallerOrEqualValue(endOfDay));
      }
      final count = await query.get().then((r) => r.length);
      sheet.cell(CellIndex.indexByString('A$rowNum')).value = TextCellValue('时间线');
      sheet.cell(CellIndex.indexByString('B$rowNum')).value = IntCellValue(count);
      sheet.cell(CellIndex.indexByString('C$rowNum')).value = TextCellValue('已导出');
    }
  }
  
  Future<void> _exportFoodRecords(Excel excel, {DateTime? startDate, DateTime? endDate}) async {
    var query = db.select(db.foodRecords);
    
    if (startDate != null) {
      query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
    }
    
    final records = await query.get();
    await amapDebug(_tag, '导出美食记录: ${records.length}条');
    final sheet = excel['美食记录'];
    
    final headers = [
      'ID', '标题', '内容', '评分', '人均消费', '标签', 
      '心情', '地点', '城市', '国家', '心愿单', '收藏',
      '记录日期', '创建时间'
    ];
    
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByString('${_colLetter(i)}1'));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true);
    }
    
    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      final row = i + 2;
      
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(record.id);
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(record.title);
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(record.content ?? '');
      sheet.cell(CellIndex.indexByString('D$row')).value = DoubleCellValue(record.rating ?? 0);
      sheet.cell(CellIndex.indexByString('E$row')).value = DoubleCellValue(record.pricePerPerson ?? 0);
      sheet.cell(CellIndex.indexByString('F$row')).value = TextCellValue(record.tags ?? '');
      sheet.cell(CellIndex.indexByString('G$row')).value = TextCellValue(record.mood ?? '');
      sheet.cell(CellIndex.indexByString('H$row')).value = TextCellValue(record.poiName ?? '');
      sheet.cell(CellIndex.indexByString('I$row')).value = TextCellValue(record.city ?? '');
      sheet.cell(CellIndex.indexByString('J$row')).value = TextCellValue(record.country ?? '');
      sheet.cell(CellIndex.indexByString('K$row')).value = TextCellValue(record.isWishlist ? '是' : '否');
      sheet.cell(CellIndex.indexByString('L$row')).value = TextCellValue(record.isFavorite ? '是' : '否');
      sheet.cell(CellIndex.indexByString('M$row')).value = TextCellValue(record.recordDate.toString().split('.')[0]);
      sheet.cell(CellIndex.indexByString('N$row')).value = TextCellValue(record.createdAt.toString().split('.')[0]);
    }
    
    if (records.isNotEmpty) {
      final lastRow = records.length + 2;
      sheet.cell(CellIndex.indexByString('A$lastRow')).value = TextCellValue('汇总');
      final avgRating = records.map((r) => r.rating ?? 0).reduce((a, b) => a + b) / records.length;
      sheet.cell(CellIndex.indexByString('D$lastRow')).value = TextCellValue('平均: ${avgRating.toStringAsFixed(1)}');
      final totalExpense = records.map((r) => r.pricePerPerson ?? 0).reduce((a, b) => a + b);
      sheet.cell(CellIndex.indexByString('E$lastRow')).value = TextCellValue('总计: ¥${totalExpense.toStringAsFixed(0)}');
    }
  }
  
  Future<void> _exportMomentRecords(Excel excel, {DateTime? startDate, DateTime? endDate}) async {
    var query = db.select(db.momentRecords);
    
    if (startDate != null) {
      query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
    }
    
    final records = await query.get();
    await amapDebug(_tag, '导出小确幸: ${records.length}条');
    final sheet = excel['小确幸'];
    
    final headers = ['ID', '内容', '心情', '心情颜色', '标签', '地点', '城市', '收藏', '记录日期', '创建时间'];
    
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByString('${_colLetter(i)}1'));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true);
    }
    
    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      final row = i + 2;
      
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(record.id);
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(record.content ?? '');
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(record.mood);
      sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(record.moodColor ?? '');
      sheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue(record.tags ?? '');
      sheet.cell(CellIndex.indexByString('F$row')).value = TextCellValue(record.poiName ?? '');
      sheet.cell(CellIndex.indexByString('G$row')).value = TextCellValue(record.city ?? '');
      sheet.cell(CellIndex.indexByString('H$row')).value = TextCellValue(record.isFavorite ? '是' : '否');
      sheet.cell(CellIndex.indexByString('I$row')).value = TextCellValue(record.recordDate.toString().split('.')[0]);
      sheet.cell(CellIndex.indexByString('J$row')).value = TextCellValue(record.createdAt.toString().split('.')[0]);
    }
  }
  
  Future<void> _exportFriendRecords(Excel excel) async {
    final records = await (db.select(db.friendRecords)).get();
    await amapDebug(_tag, '导出羁绊: ${records.length}条');
    final sheet = excel['羁绊'];
    
    final headers = ['ID', '姓名', '生日', '联系方式', '相识方式', '相识日期', '印象标签', '分组', '最后见面', '联系频率', '收藏'];
    
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByString('${_colLetter(i)}1'));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true);
    }
    
    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      final row = i + 2;
      
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(record.id);
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(record.name);
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(record.birthday?.toString().split(' ')[0] ?? '');
      sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(record.contact ?? '');
      sheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue(record.meetWay ?? '');
      sheet.cell(CellIndex.indexByString('F$row')).value = TextCellValue(record.meetDate?.toString().split(' ')[0] ?? '');
      sheet.cell(CellIndex.indexByString('G$row')).value = TextCellValue(record.impressionTags ?? '');
      sheet.cell(CellIndex.indexByString('H$row')).value = TextCellValue(record.groupName ?? '');
      sheet.cell(CellIndex.indexByString('I$row')).value = TextCellValue(record.lastMeetDate?.toString().split(' ')[0] ?? '');
      sheet.cell(CellIndex.indexByString('J$row')).value = TextCellValue(record.contactFrequency ?? '');
      sheet.cell(CellIndex.indexByString('K$row')).value = TextCellValue(record.isFavorite ? '是' : '否');
    }
  }
  
  Future<void> _exportTravelRecords(Excel excel, {DateTime? startDate, DateTime? endDate}) async {
    var query = db.select(db.travelRecords);
    
    if (startDate != null) {
      query = query..where((t) => t.recordDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query..where((t) => t.recordDate.isSmallerOrEqualValue(endOfDay));
    }
    
    final records = await query.get();
    await amapDebug(_tag, '导出旅行: ${records.length}条');
    final sheet = excel['旅行'];
    
    final headers = ['ID', '目的地', '内容', '计划日期', '地点', '城市', '国家', '心情', '标签', '收藏', '创建时间'];
    
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByString('${_colLetter(i)}1'));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true);
    }
    
    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      final row = i + 2;
      
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(record.id);
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(record.destination ?? '');
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(record.content ?? '');
      sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(record.planDate?.toString().split(' ')[0] ?? '');
      sheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue(record.poiName ?? '');
      sheet.cell(CellIndex.indexByString('F$row')).value = TextCellValue(record.city ?? '');
      sheet.cell(CellIndex.indexByString('G$row')).value = TextCellValue(record.country ?? '');
      sheet.cell(CellIndex.indexByString('H$row')).value = TextCellValue(record.mood ?? '');
      sheet.cell(CellIndex.indexByString('I$row')).value = TextCellValue(record.tags ?? '');
      sheet.cell(CellIndex.indexByString('J$row')).value = TextCellValue(record.isFavorite ? '是' : '否');
      sheet.cell(CellIndex.indexByString('K$row')).value = TextCellValue(record.createdAt.toString().split('.')[0]);
    }
  }
  
  Future<void> _exportGoalRecords(Excel excel) async {
    final records = await (db.select(db.goalRecords)).get();
    await amapDebug(_tag, '导出目标: ${records.length}条');
    final sheet = excel['目标'];
    
    final headers = ['ID', '标题', '备注', '总结', '分类', '标签', '层级', '进度', '已完成', '目标年月', '截止日期', '延期', '收藏', '创建时间'];
    
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByString('${_colLetter(i)}1'));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true);
    }
    
    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      final row = i + 2;
      
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(record.id);
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(record.title);
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(record.note ?? '');
      sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(record.summary ?? '');
      sheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue(record.category ?? '');
      sheet.cell(CellIndex.indexByString('F$row')).value = TextCellValue(record.tags ?? '');
      sheet.cell(CellIndex.indexByString('G$row')).value = TextCellValue(record.level);
      sheet.cell(CellIndex.indexByString('H$row')).value = DoubleCellValue(record.progress);
      sheet.cell(CellIndex.indexByString('I$row')).value = TextCellValue(record.isCompleted ? '是' : '否');
      sheet.cell(CellIndex.indexByString('J$row')).value = TextCellValue('${record.targetYear ?? ''}-${record.targetMonth ?? ''}');
      sheet.cell(CellIndex.indexByString('K$row')).value = TextCellValue(record.dueDate?.toString().split(' ')[0] ?? '');
      sheet.cell(CellIndex.indexByString('L$row')).value = TextCellValue(record.isPostponed ? '是' : '否');
      sheet.cell(CellIndex.indexByString('M$row')).value = TextCellValue(record.isFavorite ? '是' : '否');
      sheet.cell(CellIndex.indexByString('N$row')).value = TextCellValue(record.createdAt.toString().split('.')[0]);
    }
  }
  
  Future<void> _exportTimelineEvents(Excel excel, {DateTime? startDate, DateTime? endDate}) async {
    var query = db.select(db.timelineEvents);
    
    if (startDate != null) {
      query = query..where((t) => t.startAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query..where((t) => t.startAt.isSmallerOrEqualValue(endOfDay));
    }
    
    final records = await query.get();
    await amapDebug(_tag, '导出时间线: ${records.length}条');
    final sheet = excel['时间线'];
    
    final headers = ['ID', '标题', '事件类型', '开始时间', '结束时间', '备注', '标签', '地点', '收藏', '创建时间'];
    
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByString('${_colLetter(i)}1'));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true);
    }
    
    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      final row = i + 2;
      
      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(record.id);
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(record.title);
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(record.eventType);
      sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(record.startAt?.toString().split('.')[0] ?? '');
      sheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue(record.endAt?.toString().split('.')[0] ?? '');
      sheet.cell(CellIndex.indexByString('F$row')).value = TextCellValue(record.note ?? '');
      sheet.cell(CellIndex.indexByString('G$row')).value = TextCellValue(record.tags ?? '');
      sheet.cell(CellIndex.indexByString('H$row')).value = TextCellValue(record.poiName ?? '');
      sheet.cell(CellIndex.indexByString('I$row')).value = TextCellValue(record.isFavorite ? '是' : '否');
      sheet.cell(CellIndex.indexByString('J$row')).value = TextCellValue(record.createdAt.toString().split('.')[0]);
    }
  }
  
  String _colLetter(int index) {
    if (index < 26) {
      return String.fromCharCode(65 + index);
    } else {
      return '${String.fromCharCode(65 + (index ~/ 26) - 1)}${String.fromCharCode(65 + (index % 26))}';
    }
  }
  
  Future<void> shareExcel(String filePath) async {
    await amapInfo(_tag, '分享Excel: $filePath');
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: '人生编年史数据导出',
    );
  }
}
