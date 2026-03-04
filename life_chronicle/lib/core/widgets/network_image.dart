import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return errorWidget ?? _buildDefaultError();
    }

    final isNetwork = trimmed.startsWith('http://') || trimmed.startsWith('https://');
    if (!isNetwork) {
      return Image.asset(
        trimmed,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => errorWidget ?? _buildDefaultError(),
      );
    }

    return CachedNetworkImage(
      imageUrl: trimmed,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildDefaultError(),
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      memCacheHeight: height != null ? (height! * 2).toInt() : null,
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF3F4F6),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF3F4F6),
      child: const Icon(Icons.broken_image, color: Color(0xFF9CA3AF), size: 24),
    );
  }
}

class AppNetworkImageProvider extends CachedNetworkImageProvider {
  AppNetworkImageProvider(super.url, {super.scale = 1.0});
}
