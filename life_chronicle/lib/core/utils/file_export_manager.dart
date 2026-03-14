import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
  /// - 选择保存位置
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
      builder: (sheetContext) => _ExportOptionsSheet(
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
  Future<String?> saveFileToSelectedLocation(
    BuildContext context, {
    required String sourcePath,
    required String fileName,
    String? dialogTitle,
  }) async {
    try {
      debugPrint('===== FileExportManager.saveFileToSelectedLocation =====');
      debugPrint('sourcePath: $sourcePath');
      debugPrint('fileName: $fileName');
      debugPrint('dialogTitle: $dialogTitle');

      // 检查源文件是否存在
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        debugPrint('错误: 源文件不存在: $sourcePath');
        if (context.mounted) {
          _showErrorSnackBar(context, '源文件不存在，无法保存');
        }
        return null;
      }

      debugPrint('调用 FilePicker.platform.saveFile...');
      
      final result = await FilePicker.platform.saveFile(
        dialogTitle: dialogTitle ?? '保存文件',
        fileName: fileName,
      );

      debugPrint('FilePicker.platform.saveFile 返回结果: $result');

      if (result != null) {
        debugPrint('用户选择了保存位置: $result');
        
        // 复制文件到用户选择的位置
        await sourceFile.copy(result);
        
        debugPrint('文件复制成功');
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('文件已保存'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return result;
      } else {
        debugPrint('用户取消了保存操作');
        return null;
      }
    } on PlatformException catch (e) {
      debugPrint('保存文件 PlatformException: ${e.code} - ${e.message}');
      debugPrint('详细信息: ${e.details}');
      
      if (context.mounted) {
        String errorMessage = '保存失败';
        if (e.message != null && e.message!.isNotEmpty) {
          errorMessage = '保存失败: ${e.message}';
        }
        _showErrorSnackBar(context, errorMessage);
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('保存文件失败: $e');
      debugPrint('堆栈跟踪: $stackTrace');
      
      if (context.mounted) {
        _showErrorSnackBar(context, '保存失败: $e');
      }
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
      debugPrint('===== FileExportManager.shareFile =====');
      debugPrint('filePath: $filePath');
      
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
  /// 使用 SAF 让用户选择保存位置
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
    debugPrint('===== FileExportManager.exportToDownloads =====');
    debugPrint('sourcePath: $sourcePath');
    debugPrint('fileName: $fileName');

    // 使用 SAF 让用户选择保存位置（不需要额外权限）
    final savedPath = await saveFileToSelectedLocation(
      context,
      sourcePath: sourcePath,
      fileName: fileName,
      dialogTitle: '保存到下载目录',
    );

    if (savedPath != null) {
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

  /// 显示错误提示
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
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
              await FileExportManager.instance.saveFileToSelectedLocation(
                context,
                sourcePath: sourcePath,
                fileName: fileName,
              );
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
