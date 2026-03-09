import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageStoreResult {
  const ImageStoreResult({
    required this.originalPath,
    required this.thumbnailPath,
  });
  
  final String originalPath;
  final String thumbnailPath;
}

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

String getThumbnailPath(String originalPath) {
  final ext = p.extension(originalPath);
  final baseName = p.basenameWithoutExtension(originalPath);
  final dir = p.dirname(originalPath);
  return p.join(dir, '${baseName}_thumb$ext');
}

Future<ImageStoreResult?> persistImageWithThumbnail(
  String sourcePath, {
  required String folder,
  String? prefix,
  int thumbnailMaxWidth = 400,
}) async {
  final trimmed = sourcePath.trim();
  if (trimmed.isEmpty) return null;
  
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return ImageStoreResult(originalPath: trimmed, thumbnailPath: trimmed);
  }
  
  if (kIsWeb) {
    return ImageStoreResult(originalPath: trimmed, thumbnailPath: trimmed);
  }
  
  final targetDir = await _ensureMediaDir(folder);
  
  if (p.isWithin(targetDir.path, trimmed)) {
    final thumbPath = getThumbnailPath(trimmed);
    if (File(thumbPath).existsSync()) {
      return ImageStoreResult(originalPath: trimmed, thumbnailPath: thumbPath);
    }
    await _generateThumbnail(trimmed, thumbPath, thumbnailMaxWidth);
    return ImageStoreResult(originalPath: trimmed, thumbnailPath: thumbPath);
  }
  
  final ext = p.extension(trimmed);
  final name = _buildFileName(prefix ?? folder, ext);
  final targetPath = p.join(targetDir.path, name);
  await File(trimmed).copy(targetPath);
  
  final thumbPath = getThumbnailPath(targetPath);
  await _generateThumbnail(targetPath, thumbPath, thumbnailMaxWidth);
  
  return ImageStoreResult(originalPath: targetPath, thumbnailPath: thumbPath);
}

Future<List<ImageStoreResult>> persistImagesWithThumbnails(
  List<XFile> files, {
  required String folder,
  String? prefix,
  int thumbnailMaxWidth = 400,
}) async {
  if (files.isEmpty) return const [];
  
  if (kIsWeb) {
    return files
        .map((f) => f.path)
        .where((path) => path.trim().isNotEmpty)
        .map((path) => ImageStoreResult(originalPath: path, thumbnailPath: path))
        .toList(growable: false);
  }
  
  final targetDir = await _ensureMediaDir(folder);
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final results = <ImageStoreResult>[];
  
  for (var i = 0; i < files.length; i += 1) {
    final path = files[i].path.trim();
    if (path.isEmpty) continue;
    
    if (path.startsWith('http://') || path.startsWith('https://')) {
      results.add(ImageStoreResult(originalPath: path, thumbnailPath: path));
      continue;
    }
    
    if (p.isWithin(targetDir.path, path)) {
      final thumbPath = getThumbnailPath(path);
      if (!File(thumbPath).existsSync()) {
        await _generateThumbnail(path, thumbPath, thumbnailMaxWidth);
      }
      results.add(ImageStoreResult(originalPath: path, thumbnailPath: thumbPath));
      continue;
    }
    
    final ext = p.extension(path);
    final targetPath = p.join(targetDir.path, _buildIndexedFileName(prefix ?? folder, stamp, i, ext));
    await File(path).copy(targetPath);
    
    final thumbPath = getThumbnailPath(targetPath);
    await _generateThumbnail(targetPath, thumbPath, thumbnailMaxWidth);
    
    results.add(ImageStoreResult(originalPath: targetPath, thumbnailPath: thumbPath));
  }
  
  return results;
}

Future<void> _generateThumbnail(
  String sourcePath,
  String targetPath, 
  int maxWidth,
) async {
  try {
    final file = File(sourcePath);
    final bytes = await file.readAsBytes();
    
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: maxWidth,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      await file.copy(targetPath);
      return;
    }
    
    await File(targetPath).writeAsBytes(byteData.buffer.asUint8List());
    
    image.dispose();
    codec.dispose();
  } catch (e) {
    try {
      await File(sourcePath).copy(targetPath);
    } catch (_) {}
  }
}

Future<void> generateMissingThumbnails(String folder) async {
  if (kIsWeb) return;
  
  final targetDir = await _ensureMediaDir(folder);
  final entities = targetDir.listSync(recursive: false);
  
  for (final entity in entities) {
    if (entity is! File) continue;
    final path = entity.path;
    if (path.contains('_thumb')) continue;
    
    final ext = p.extension(path).toLowerCase();
    if (!['.jpg', '.jpeg', '.png', '.webp', '.gif'].contains(ext)) continue;
    
    final thumbPath = getThumbnailPath(path);
    if (!File(thumbPath).existsSync()) {
      await _generateThumbnail(path, thumbPath, 400);
    }
  }
}
