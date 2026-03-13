import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// 权限管理工具类
/// 统一处理 Android 各版本的存储和媒体权限
class PermissionManager {
  PermissionManager._();

  static final PermissionManager _instance = PermissionManager._();
  static PermissionManager get instance => _instance;

  /// 获取 Android SDK 版本
  Future<int> _getAndroidSdkVersion() async {
    if (!Platform.isAndroid) return 0;
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }

  /// 检查并申请图片读取权限
  /// 
  /// 根据 Android 版本自动选择合适的权限：
  /// - Android 13+ (API 33+): READ_MEDIA_IMAGES
  /// - Android 10-12 (API 29-32): READ_EXTERNAL_STORAGE
  /// 
  /// 返回 true 表示权限已授予
  Future<bool> requestPhotoPermission() async {
    if (!Platform.isAndroid) return true;

    final sdkVersion = await _getAndroidSdkVersion();
    PermissionStatus status;

    if (sdkVersion >= 33) {
      // Android 13+ 使用新的媒体权限
      status = await Permission.photos.request();
    } else {
      // Android 10-12 使用存储权限
      status = await Permission.storage.request();
    }

    return status.isGranted || status.isLimited;
  }

  /// 检查图片读取权限状态（不申请）
  Future<bool> checkPhotoPermission() async {
    if (!Platform.isAndroid) return true;

    final sdkVersion = await _getAndroidSdkVersion();
    PermissionStatus status;

    if (sdkVersion >= 33) {
      status = await Permission.photos.status;
    } else {
      status = await Permission.storage.status;
    }

    return status.isGranted || status.isLimited;
  }

  /// 检查并申请管理外部存储权限
  /// 
  /// 注意：这个权限需要特殊申请，用户需要手动在设置中开启
  /// 主要用于导出文件到下载目录等操作
  Future<bool> requestManageExternalStorage() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  /// 检查管理外部存储权限状态
  Future<bool> checkManageExternalStorage() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.manageExternalStorage.status;
    return status.isGranted;
  }

  /// 申请存储写入权限（用于 Android 10 以下）
  Future<bool> requestStorageWritePermission() async {
    if (!Platform.isAndroid) return true;

    final sdkVersion = await _getAndroidSdkVersion();
    if (sdkVersion >= 29) {
      // Android 10+ 不需要 WRITE_EXTERNAL_STORAGE 权限
      return true;
    }

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// 显示权限说明弹窗
  /// 
  /// 在申请敏感权限前显示说明，提高用户授权率
  Future<bool> showPermissionExplanation(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    String? cancelText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// 显示权限被拒绝的引导弹窗
  /// 
  /// 当用户拒绝权限后，提供跳转到应用设置的选项
  Future<void> showPermissionDeniedDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String settingText,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(settingText),
          ),
        ],
      ),
    );
  }

  /// 申请图片选择所需的全套权限
  /// 
  /// 包含权限说明弹窗和权限申请流程
  Future<bool> requestPhotoPermissionWithDialog(BuildContext context) async {
    // 先检查是否已有权限
    if (await checkPhotoPermission()) {
      return true;
    }

    // 显示权限说明
    final shouldProceed = await showPermissionExplanation(
      context,
      title: '需要相册权限',
      content: '为了选择图片，需要访问您的相册。您的图片仅用于本地存储，不会上传到任何服务器。',
      confirmText: '去授权',
      cancelText: '取消',
    );

    if (!shouldProceed) {
      return false;
    }

    // 申请权限
    final granted = await requestPhotoPermission();

    if (!granted && context.mounted) {
      // 权限被拒绝，显示引导
      await showPermissionDeniedDialog(
        context,
        title: '权限被拒绝',
        content: '无法访问相册。如需使用此功能，请在设置中开启相册权限。',
        settingText: '去设置',
      );
    }

    return granted;
  }

  /// 申请文件导出所需的全套权限
  /// 
  /// 包含权限说明弹窗和权限申请流程
  Future<bool> requestExportPermissionWithDialog(BuildContext context) async {
    // 检查是否已有权限
    if (await checkManageExternalStorage()) {
      return true;
    }

    // 显示权限说明
    final shouldProceed = await showPermissionExplanation(
      context,
      title: '需要存储权限',
      content: '为了将文件导出到下载目录，需要访问设备存储。导出的文件仅保存在您选择的位置。',
      confirmText: '去授权',
      cancelText: '取消',
    );

    if (!shouldProceed) {
      return false;
    }

    // 申请权限
    final granted = await requestManageExternalStorage();

    if (!granted && context.mounted) {
      // 权限被拒绝，显示引导
      await showPermissionDeniedDialog(
        context,
        title: '权限被拒绝',
        content: '无法导出到下载目录。如需使用此功能，请在设置中开启"所有文件访问权限"。',
        settingText: '去设置',
      );
    }

    return granted;
  }
}
