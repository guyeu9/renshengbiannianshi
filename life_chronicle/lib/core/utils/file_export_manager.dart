import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'permission_manager.dart';

/// 文件导出管理器
/// 
/// 统一管理文件的导出、分享、保存到下载目录等功能
/// 支持 Android 各版本的存储权限适配
class FileExportManager {
  FileExportManager._();

  static final FileExportManager _instance = FileExportManager._();
  static FileExportManager get instance => _instance;

  /// 导出文件并显示选项菜单
  /// 
  /// 导出完成后显示底部菜单，提供以下选项：
  /// - 保存到下载文件夹
  /// - 分享到其他应用
  /// - 在文件管理器中打开
  /// 
  /// [context] BuildContext
  /// [sourcePath] 源文件路径
  /// [fileName] 建议的文件名
  /// [subject] 分享时的主题
  Future<void> exportFileWithOptions(
    BuildContext context, {
    required String sourcePath,
    required String fileName,
    String? subject,
  }) async {
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExportOptionsSheet(
        sourcePath: sourcePath,
        fileName: fileName,
        subject: subject,
      ),
    );
  }

  /// 保存文件到用户选择的目录
  /// 
  /// 使用 file_picker 让用户选择保存位置
  /// 
  /// 返回保存后的文件路径，失败返回 null
  Future<String?> saveFileToSelectedLocation({
    required String sourcePath,
    required String fileName,
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: dialogTitle ?? '保存文件',
        fileName: fileName,
        type: FileType.any,
      );

      if (result != null) {
        await File(sourcePath).copy(result);
        return result;
      }
      return null;
    } catch (e) {
      debugPrint('保存文件失败: $e');
      return null;
    }
  }

  /// 分享文件
  /// 
  /// 使用系统分享功能分享文件
  Future<void> shareFile({
    required String filePath,
    String? subject,
    String? text,
  }) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject,
        text: text,
      );
    } catch (e) {
      debugPrint('分享文件失败: $e');
    }
  }

  /// 导出并自动保存到下载目录
  /// 
  /// 先申请权限，然后保存到下载目录
  /// 
  /// [context] BuildContext
  /// [sourcePath] 源文件路径
  /// [fileName] 文件名
  /// [onSuccess] 成功回调
  /// [onError] 失败回调
  Future<void> exportToDownloads(
    BuildContext context, {
    required String sourcePath,
    required String fileName,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    // 申请权限
    final hasPermission = await PermissionManager.instance
        .requestExportPermissionWithDialog(context);

    if (!hasPermission) {
      onError?.call();
      return;
    }

    // 让用户选择保存位置
    final savedPath = await saveFileToSelectedLocation(
      sourcePath: sourcePath,
      fileName: fileName,
      dialogTitle: '保存到下载目录',
    );

    if (savedPath != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('文件已保存到: $savedPath')),
        );
      }
      onSuccess?.call();
    } else {
      onError?.call();
    }
  }

  /// 获取临时目录路径
  /// 
  /// 用于创建临时导出文件
  Future<String> getTempDirectory() async {
    final tempDir = await getTemporaryDirectory();
    return tempDir.path;
  }

  /// 获取应用文档目录
  /// 
  /// 用于保存应用内部文件
  Future<String> getAppDocumentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return appDir.path;
  }

  /// 清理临时文件
  /// 
  /// 删除指定目录下的临时文件
  Future<void> cleanTempFiles(String directory, {String? pattern}) async {
    try {
      final dir = Directory(directory);
      if (!await dir.exists()) return;

      final entities = await dir.list().toList();
      for (final entity in entities) {
        if (entity is File) {
          if (pattern == null || entity.path.contains(pattern)) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('清理临时文件失败: $e');
    }
  }
}

/// 导出选项底部菜单
class _ExportOptionsSheet extends StatelessWidget {
  final String sourcePath;
  final String fileName;
  final String? subject;

  const _ExportOptionsSheet({
    required this.sourcePath,
    required this.fileName,
    this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            '导出文件',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          _OptionTile(
            icon: Icons.save_alt,
            title: '保存到下载文件夹',
            subtitle: '选择保存位置',
            onTap: () async {
              Navigator.pop(context);
              await FileExportManager.instance.exportToDownloads(
                context,
                sourcePath: sourcePath,
                fileName: fileName,
              );
            },
          ),
          _OptionTile(
            icon: Icons.share,
            title: '分享到其他应用',
            subtitle: '通过系统分享发送',
            onTap: () {
              Navigator.pop(context);
              FileExportManager.instance.shareFile(
                filePath: sourcePath,
                subject: subject ?? fileName,
              );
            },
          ),
          _OptionTile(
            icon: Icons.folder_open,
            title: '选择保存位置',
            subtitle: '自定义保存路径',
            onTap: () async {
              Navigator.pop(context);
              final savedPath = await FileExportManager.instance
                  .saveFileToSelectedLocation(
                sourcePath: sourcePath,
                fileName: fileName,
              );
              if (savedPath != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('文件已保存')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF2BCDEE)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF111827),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF9CA3AF),
        ),
      ),
      onTap: onTap,
    );
  }
}
