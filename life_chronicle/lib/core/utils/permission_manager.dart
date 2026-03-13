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
  Future<bool>