import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class ImageSaveUtil {
  static Future<bool> saveImageToGallery(String imagePath) async {
    try {
      final result = await SaverGallery.saveFile(
        filePath: imagePath,
        fileName: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        skipIfExists: false,
      );
      return result.isSuccess;
    } catch (e) {
      debugPrint('保存图片失败: $e');
      return false;
    }
  }

  static Future<bool> saveNetworkImageToGallery(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final result = await SaverGallery.saveImage(
        Uint8List.fromList(response.bodyBytes),
        fileName: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        skipIfExists: false,
      );
      return result.isSuccess;
    } catch (e) {
      debugPrint('保存网络图片失败: $e');
      return false;
    }
  }

  static Future<void> shareImage(String imagePath, {String? text}) async {
    try {
      final file = XFile(imagePath);
      await Share.shareXFiles([file], text: text);
    } catch (e) {
      debugPrint('分享图片失败: $e');
    }
  }

  static Future<void> shareNetworkImage(String imageUrl, {String? text}) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/share_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(response.bodyBytes);
      final xFile = XFile(tempFile.path);
      await Share.shareXFiles([xFile], text: text);
    } catch (e) {
      debugPrint('分享网络图片失败: $e');
    }
  }

  static void showImageOptions(
    BuildContext context,
    String imagePath, {
    bool isNetwork = false,
    VoidCallback? onView,
    VoidCallback? onDelete,
  }) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onView != null)
              ListTile(
              leading: const Icon(Icons.zoom_in),
              title: const Text('查看大图'),
              onTap: () {
                Navigator.pop(ctx);
                onView();
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('保存到相册'),
              onTap: () async {
                Navigator.pop(ctx);
                bool success;
                if (isNetwork) {
                  success = await saveNetworkImageToGallery(imagePath);
                } else {
                  success = await saveImageToGallery(imagePath);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? '保存成功' : '保存失败'),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('分享图片'),
              onTap: () async {
                Navigator.pop(ctx);
                if (isNetwork) {
                  await shareNetworkImage(imagePath);
                } else {
                  await shareImage(imagePath);
                }
              },
            ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除图片', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
              ),
          ],
        ),
      ),
    );
  }
}
