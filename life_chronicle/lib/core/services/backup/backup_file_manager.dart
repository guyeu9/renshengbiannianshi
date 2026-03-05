import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class BackupFileInfo {
  final String filePath;
  final String fileName;
  final int fileSize;
  final DateTime createdAt;
  final String? recordCount;
  final String? mediaCount;

  BackupFileInfo({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.createdAt,
    this.recordCount,
    this.mediaCount,
  });

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class BackupFileManager {
  Future<Directory> getBackupDir() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(path.join(appDocDir.path, 'backups'));
    return backupDir;
  }

  Future<List<BackupFileInfo>> listBackupFiles() async {
    final backupDir = await getBackupDir();
    if (!await backupDir.exists()) {
      return [];
    }

    final files = <BackupFileInfo>[];
    await for (final entity in backupDir.list()) {
      if (entity is File && entity.path.endsWith('.zip')) {
        final stat = await entity.stat();
        files.add(BackupFileInfo(
          filePath: entity.path,
          fileName: path.basename(entity.path),
          fileSize: stat.size,
          createdAt: stat.modified,
        ));
      }
    }

    files.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return files;
  }

  Future<void> deleteBackupFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> applyRetentionPolicy(int keepCount) async {
    final files = await listBackupFiles();
    if (files.length <= keepCount) return;

    final filesToDelete = files.skip(keepCount);
    for (final file in filesToDelete) {
      await deleteBackupFile(file.filePath);
    }
  }

  Future<int> getTotalBackupSize() async {
    final files = await listBackupFiles();
    return files.fold<int>(0, (sum, file) => sum + file.fileSize);
  }
}
