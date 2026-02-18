import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String?> persistImagePath(
  String path, {
  required String folder,
  String? prefix,
}) async {
  final trimmed = path.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return trimmed;
  if (kIsWeb) return trimmed;
  final targetDir = await _ensureMediaDir(folder);
  if (p.isWithin(targetDir.path, trimmed)) {
    return trimmed;
  }
  final ext = p.extension(trimmed);
  final name = _buildFileName(prefix ?? folder, ext);
  final targetPath = p.join(targetDir.path, name);
  final saved = await File(trimmed).copy(targetPath);
  return saved.path;
}

Future<String?> persistImageFile(
  XFile file, {
  required String folder,
  String? prefix,
}) async {
  return persistImagePath(file.path, folder: folder, prefix: prefix);
}

Future<List<String>> persistImageFiles(
  List<XFile> files, {
  required String folder,
  String? prefix,
}) async {
  if (files.isEmpty) return const [];
  if (kIsWeb) {
    return files.map((f) => f.path).where((p) => p.trim().isNotEmpty).toList(growable: false);
  }
  final targetDir = await _ensureMediaDir(folder);
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final stored = <String>[];
  for (var i = 0; i < files.length; i += 1) {
    final path = files[i].path.trim();
    if (path.isEmpty) continue;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      stored.add(path);
      continue;
    }
    if (p.isWithin(targetDir.path, path)) {
      stored.add(path);
      continue;
    }
    final ext = p.extension(path);
    final targetPath = p.join(targetDir.path, _buildIndexedFileName(prefix ?? folder, stamp, i, ext));
    final copied = await File(path).copy(targetPath);
    stored.add(copied.path);
  }
  return stored;
}

Future<Directory> _ensureMediaDir(String folder) async {
  final dir = await getApplicationDocumentsDirectory();
  final targetDir = Directory(p.join(dir.path, 'media', folder));
  await targetDir.create(recursive: true);
  return targetDir;
}

String _buildFileName(String prefix, String ext) {
  final safeExt = ext.isEmpty ? '.jpg' : ext;
  return '${prefix}_${DateTime.now().millisecondsSinceEpoch}$safeExt';
}

String _buildIndexedFileName(String prefix, int stamp, int index, String ext) {
  final safeExt = ext.isEmpty ? '.jpg' : ext;
  return '${prefix}_${stamp}_$index$safeExt';
}
