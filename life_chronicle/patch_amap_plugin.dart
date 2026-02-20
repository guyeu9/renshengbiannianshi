import 'dart:io';
import 'dart:isolate';

Future<void> main() async {
  await _patchPackage('amap_flutter_map', 'plugins/amap_flutter_map');
  await _patchPackage('amap_flutter_base', 'plugins/amap_flutter_base');
  stdout.writeln('完成，请将 pubspec.yaml 指向本地路径 plugins/amap_flutter_map 与 plugins/amap_flutter_base');
}

Future<void> _patchPackage(String packageName, String targetPath) async {
  final packageUri = Uri.parse('package:$packageName/');
  final packagePathUri = await Isolate.resolvePackageUri(packageUri);
  if (packagePathUri == null) {
    stdout.writeln('无法解析 package:$packageName/');
    stdout.writeln('请确保已执行 flutter pub get');
    exit(1);
  }

  final sourceDir = Directory.fromUri(packagePathUri).parent;
  final targetDir = Directory(targetPath);
  if (targetDir.existsSync()) {
    await targetDir.delete(recursive: true);
  }

  await _copyDirectory(sourceDir, targetDir);
  await _patchFiles(targetDir);
}

Future<void> _copyDirectory(Directory source, Directory destination) async {
  await destination.create(recursive: true);
  await for (final entity in source.list(recursive: false)) {
    final name = entity.path.split(Platform.pathSeparator).last;
    if (entity is Directory) {
      await _copyDirectory(entity, Directory('${destination.path}${Platform.pathSeparator}$name'));
    } else if (entity is File) {
      await entity.copy('${destination.path}${Platform.pathSeparator}$name');
    }
  }
}

Future<void> _patchFiles(Directory dir) async {
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = await entity.readAsString();
      var next = content;
      if (next.contains('hashValues') || next.contains('hashList')) {
        next = next.replaceAll('hashValues(', 'Object.hash(').replaceAll('hashList(', 'Object.hashAll(');
      }
      next = next.replaceAll("import 'dart:ui' show hashValues;", "import 'dart:ui';");
      next = next.replaceAll("import 'dart:ui' show hashValues, Offset;", "import 'dart:ui' show Offset;");
      next = next.replaceAll("import 'dart:ui' show Offset, hashValues;", "import 'dart:ui' show Offset;");
      next = next.replaceAll("import 'dart:ui' show Color, hashValues;", "import 'dart:ui' show Color;");
      next = next.replaceAll("import 'dart:ui' show hashValues, Color;", "import 'dart:ui' show Color;");
      if (next != content) {
        await entity.writeAsString(next);
      }
    }
  }
}
