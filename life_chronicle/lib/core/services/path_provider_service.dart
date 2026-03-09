import 'dart:io';
import 'package:path_provider/path_provider.dart' as pp;

abstract class PathProviderService {
  Future<Directory> getApplicationDocumentsDirectory();
  Future<Directory> getTemporaryDirectory();
}

class RealPathProviderService implements PathProviderService {
  const RealPathProviderService();

  @override
  Future<Directory> getApplicationDocumentsDirectory() async {
    return await pp.getApplicationDocumentsDirectory();
  }

  @override
  Future<Directory> getTemporaryDirectory() async {
    return await pp.getTemporaryDirectory();
  }
}

class MockPathProviderService implements PathProviderService {
  final Directory appDocDir;
  final Directory tempDir;

  MockPathProviderService({
    required this.appDocDir,
    required this.tempDir,
  });

  @override
  Future<Directory> getApplicationDocumentsDirectory() async => appDocDir;

  @override
  Future<Directory> getTemporaryDirectory() async => tempDir;
}
