import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/version_info.dart';

class AppUpdateService {
  static const String _versionJsonUrl = 
      'https://your-gitee-username.gitee.io/chronicle-of-life-updates/version.json';

  Future<VersionInfo?> checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse(_versionJsonUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return VersionInfo.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isUpdateAvailable(VersionInfo versionInfo) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentBuild = int.parse(packageInfo.buildNumber);
    return versionInfo.buildNumber > currentBuild;
  }

  Future<void> launchDownloadUrl(VersionInfo versionInfo) async {
    final platform = _getPlatform();
    final url = versionInfo.downloadUrl[platform];
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  String _getPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'android';
  }

  Future<PackageInfo> getCurrentPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }
}
