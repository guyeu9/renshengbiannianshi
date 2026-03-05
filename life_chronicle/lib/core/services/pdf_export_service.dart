import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';

class PdfExportService {
  final AppDatabase db;
  
  PdfExportService(this.db);
  
  Future<String> exportToPdf({
    bool includeFood = true,
    bool includeMoment = true,
    bool includeFriend = true,
    bool includeTravel = true,
    bool includeGoal = true,
    bool includeTimeline = true,
  }) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('人生编年史', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('数据导出报告', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 40),
              pw.Text('导出日期: ${DateTime.now().toString().split('.')[0]}'),
            ],
          ),
        ),
      ),
    );
    
    if (includeFood) {
      await _addFoodRecordsPage(pdf);
    }
    if (includeMoment) {
      await _addMomentRecordsPage(pdf);
    }
    if (includeFriend) {
      await _addFriendRecordsPage(pdf);
    }
    if (includeTravel) {
      await _addTravelRecordsPage(pdf);
    }
    if (includeGoal) {
      await _addGoalRecordsPage(pdf);
    }
    if (includeTimeline) {
      await _addTimelineEventsPage(pdf);
    }
    
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'life_chronicle_export_$timestamp.pdf';
    final filePath = path.join(tempDir.path, fileName);
    
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    
    return filePath;
  }
  
  Future<void> _addFoodRecordsPage(pw.Document pdf) async {
    final records = await (db.select(db.foodRecords)).get();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Text('美食记录', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        build: (context) => [
          pw.SizedBox(height: 10),
          ...records.map((record) => pw.Container(
            margin: pw.EdgeInsets.only(bottom: 10),
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(record.title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                if (record.description != null) pw.Text(record.description!),
                pw.Row(
                  children: [
                    if (record.rating != null) pw.Text('评分: ${record.rating}  '),
                    pw.Text(record.createdAt.toString().split('.')[0]),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Future<void> _addMomentRecordsPage(pw.Document pdf) async {
    final records = await (db.select(db.momentRecords)).get();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Text('小确幸', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        build: (context) => [
          pw.SizedBox(height: 10),
          ...records.map((record) => pw.Container(
            margin: pw.EdgeInsets.only(bottom: 10),
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(record.content),
                pw.SizedBox(height: 5),
                pw.Text(record.createdAt.toString().split('.')[0], style: pw.TextStyle(color: PdfColors.grey600)),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Future<void> _addFriendRecordsPage(pw.Document pdf) async {
    final records = await (db.select(db.friendRecords)).get();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Text('羁绊', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        build: (context) => [
          pw.SizedBox(height: 10),
          ...records.map((record) => pw.Container(
            margin: pw.EdgeInsets.only(bottom: 10),
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(record.name, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                if (record.relationship != null) pw.Text('关系: ${record.relationship}'),
                if (record.description != null) pw.Text(record.description!),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Future<void> _addTravelRecordsPage(pw.Document pdf) async {
    final records = await (db.select(db.travelRecords)).get();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Text('旅行', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        build: (context) => [
          pw.SizedBox(height: 10),
          ...records.map((record) => pw.Container(
            margin: pw.EdgeInsets.only(bottom: 10),
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(record.destination, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                if (record.description != null) pw.Text(record.description!),
                pw.Text('日期: ${record.startDate?.toString().split(' ')[0] ?? ''} - ${record.endDate?.toString().split(' ')[0] ?? ''}'),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Future<void> _addGoalRecordsPage(pw.Document pdf) async {
    final records = await (db.select(db.goalRecords)).get();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Text('目标', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        build: (context) => [
          pw.SizedBox(height: 10),
          ...records.map((record) => pw.Container(
            margin: pw.EdgeInsets.only(bottom: 10),
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(record.title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                if (record.description != null) pw.Text(record.description!),
                pw.Text('状态: ${record.status}'),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Future<void> _addTimelineEventsPage(pw.Document pdf) async {
    final records = await (db.select(db.timelineEvents)).get();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Text('时间线', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        build: (context) => [
          pw.SizedBox(height: 10),
          ...records.map((record) => pw.Container(
            margin: pw.EdgeInsets.only(bottom: 10),
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(record.title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                if (record.description != null) pw.Text(record.description!),
                pw.Text(record.date.toString().split('.')[0]),
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
