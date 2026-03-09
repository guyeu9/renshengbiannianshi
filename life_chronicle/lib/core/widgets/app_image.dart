import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    this.thumbnailSource,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.onTap,
    this.heroTag,
    this.useThumbnail = false,
  });

  final String source;
  final String? thumbnailSource;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final VoidCallback? onTap;
  final String? heroTag;
  final bool useThumbnail;

  static String? getAutoThumbnailPath(String originalPath) {
    if (originalPath.isEmpty) return null;
    if (originalPath.startsWith('http://') || originalPath.startsWith('https://')) return null;
    if (originalPath.contains('_thumb')) return null;
    
    final ext = p.extension(originalPath);
    final baseName = p.basenameWithoutExtension(originalPath);
    final dir = p.dirname(originalPath);
    final thumbPath = p.join(dir, '${baseName}_thumb$ext');
    
    if (File(thumbPath).existsSync()) {
      return thumbPath;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    String actualSource = source.trim();
    
    if (useThumbnail && thumbnailSource != null) {
      actualSource = thumbnailSource!.trim();
    } else if (useThumbnail) {
      final autoThumb = getAutoThumbnailPath(source);
      if (autoThumb != null) {
        actualSource = autoThumb;
      }
    }
    
    if (actualSource.isEmpty) {
      return errorWidget ?? _buildDefaultError();
    }

    final isNetwork = actualSource.startsWith('http://') || actualSource.startsWith('https://');
    final isAsset = actualSource.startsWith('assets/') || actualSource.startsWith('AssetManifest');

    Widget image;

    if (isNetwork) {
      image = CachedNetworkImage(
        imageUrl: actualSource,
        fit: fit,
        width: width,
        height: height,
        memCacheWidth: width != null ? (width! * 2).toInt() : null,
        memCacheHeight: height != null ? (height! * 2).toInt() : null,
        placeholder: (_, __) => placeholder ?? _buildDefaultPlaceholder(),
        errorWidget: (_, __, ___) => errorWidget ?? _buildDefaultError(),
      );
    } else if (isAsset) {
      image = Image.asset(
        actualSource,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => errorWidget ?? _buildDefaultError(),
      );
    } else if (kIsWeb) {
      image = Image.network(
        actualSource,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => errorWidget ?? _buildDefaultError(),
      );
    } else {
      image = _LocalFileImage(
        path: actualSource,
        fit: fit,
        width: width,
        height: height,
        errorWidget: errorWidget,
      );
    }

    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: image);
    }

    return image;
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

class _LocalFileImage extends StatelessWidget {
  const _LocalFileImage({
    required this.path,
    required this.fit,
    this.width,
    this.height,
    this.errorWidget,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;

  static final _imageCache = <String, ImageProvider>{};

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    
    if (!file.existsSync()) {
      return errorWidget ?? _buildDefaultError();
    }

    late ImageProvider provider;
    if (_imageCache.containsKey(path)) {
      provider = _imageCache[path]!;
    } else {
      provider = FileImage(file);
      _imageCache[path] = provider;
    }

    return Image(
      image: provider,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => errorWidget ?? _buildDefaultError(),
      gaplessPlayback: true,
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

class ImagePreview {
  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    String? heroTag,
  }) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (_) => _ImagePreviewDialog(
        imageUrl: imageUrl,
        heroTag: heroTag,
      ),
    );
  }

  static Future<void> showGallery(
    BuildContext context, {
    required List<String> images,
    int initialIndex = 0,
    List<String>? heroTags,
  }) async {
    if (images.isEmpty) return;
    if (images.length == 1) {
      await show(context, imageUrl: images.first, heroTag: heroTags?.first);
      return;
    }

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (_) => _ImageGalleryDialog(
        images: images,
        initialIndex: initialIndex,
        heroTags: heroTags,
      ),
    );
  }
}

class _ImagePreviewDialog extends StatelessWidget {
  const _ImagePreviewDialog({
    required this.imageUrl,
    this.heroTag,
  });

  final String imageUrl;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: AppImage(
                source: imageUrl,
                fit: BoxFit.contain,
                heroTag: heroTag,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageGalleryDialog extends StatefulWidget {
  const _ImageGalleryDialog({
    required this.images,
    required this.initialIndex,
    this.heroTags,
  });

  final List<String> images;
  final int initialIndex;
  final List<String>? heroTags;

  @override
  State<_ImageGalleryDialog> createState() => _ImageGalleryDialogState();
}

class _ImageGalleryDialogState extends State<_ImageGalleryDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final heroTag = widget.heroTags != null && index < widget.heroTags!.length
                  ? widget.heroTags![index]
                  : null;
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: AppImage(
                    source: widget.images[index],
                    fit: BoxFit.contain,
                    heroTag: heroTag,
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableImage extends StatefulWidget {
  const ExpandableImage({
    super.key,
    required this.source,
    this.collapsedAspectRatio = 16 / 9,
    this.borderRadius = 16,
    this.heroTag,
  });

  final String source;
  final double collapsedAspectRatio;
  final double borderRadius;
  final String? heroTag;

  @override
  State<ExpandableImage> createState() => _ExpandableImageState();
}

class _ExpandableImageState extends State<ExpandableImage> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: _expanded
                ? AppImage(
                    source: widget.source,
                    fit: BoxFit.contain,
                    heroTag: widget.heroTag,
                  )
                : AspectRatio(
                    aspectRatio: widget.collapsedAspectRatio,
                    child: AppImage(
                      source: widget.source,
                      fit: BoxFit.cover,
                      heroTag: widget.heroTag,
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class ExpandableImageWithPreview extends StatelessWidget {
  const ExpandableImageWithPreview({
    super.key,
    required this.source,
    this.collapsedAspectRatio = 16 / 9,
    this.borderRadius = 16,
    this.heroTag,
    this.images,
    this.initialIndex = 0,
  });

  final String source;
  final double collapsedAspectRatio;
  final double borderRadius;
  final String? heroTag;
  final List<String>? images;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (images != null && images!.isNotEmpty) {
          ImagePreview.showGallery(
            context,
            images: images!,
            initialIndex: initialIndex,
          );
        } else {
          ImagePreview.show(
            context,
            imageUrl: source,
            heroTag: heroTag,
          );
        }
      },
      onLongPress: () {
        _showExpandOptions(context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: AspectRatio(
          aspectRatio: collapsedAspectRatio,
          child: AppImage(
            source: source,
            fit: BoxFit.cover,
            heroTag: heroTag,
          ),
        ),
      ),
    );
  }

  void _showExpandOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.zoom_in),
                title: const Text('查看完整图片'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (images != null && images!.isNotEmpty) {
                    ImagePreview.showGallery(
                      context,
                      images: images!,
                      initialIndex: initialIndex,
                    );
                  } else {
                    ImagePreview.show(
                      context,
                      imageUrl: source,
                      heroTag: heroTag,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.fullscreen),
                title: const Text('全屏预览'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (images != null && images!.isNotEmpty) {
                    ImagePreview.showGallery(
                      context,
                      images: images!,
                      initialIndex: initialIndex,
                    );
                  } else {
                    ImagePreview.show(
                      context,
                      imageUrl: source,
                      heroTag: heroTag,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

enum ImageLoadingStrategy {
  normal,
  progressive,
  lowQualityFirst,
}

class SmartImageLoader {
  static Widget load({
    required String source,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? placeholder,
    Widget? errorWidget,
    String? heroTag,
    bool useThumbnail = false,
    ImageLoadingStrategy strategy = ImageLoadingStrategy.normal,
  }) {
    switch (strategy) {
      case ImageLoadingStrategy.progressive:
        return _ProgressiveImageLoader(
          source: source,
          fit: fit,
          width: width,
          height: height,
          placeholder: placeholder,
          errorWidget: errorWidget,
          heroTag: heroTag,
          useThumbnail: useThumbnail,
        );
      case ImageLoadingStrategy.lowQualityFirst:
        return _LowQualityFirstLoader(
          source: source,
          fit: fit,
          width: width,
          height: height,
          placeholder: placeholder,
          errorWidget: errorWidget,
          heroTag: heroTag,
        );
      case ImageLoadingStrategy.normal:
        return AppImage(
          source: source,
          fit: fit,
          width: width,
          height: height,
          placeholder: placeholder,
          errorWidget: errorWidget,
          heroTag: heroTag,
          useThumbnail: useThumbnail,
        );
    }
  }
}

class _ProgressiveImageLoader extends StatefulWidget {
  const _ProgressiveImageLoader({
    required this.source,
    required this.fit,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.heroTag,
    this.useThumbnail = false,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? heroTag;
  final bool useThumbnail;

  @override
  State<_ProgressiveImageLoader> createState() => _ProgressiveImageLoaderState();
}

class _ProgressiveImageLoaderState extends State<_ProgressiveImageLoader> {
  bool _thumbnailLoaded = false;

  @override
  Widget build(BuildContext context) {
    final thumbnailPath = AppImage.getAutoThumbnailPath(widget.source);
    
    if (thumbnailPath != null && !_thumbnailLoaded) {
      return Stack(
        fit: StackFit.passthrough,
        children: [
          AppImage(
            source: thumbnailPath,
            fit: widget.fit,
            width: widget.width,
            height: widget.height,
            placeholder: widget.placeholder,
            errorWidget: widget.errorWidget,
          ),
          AppImage(
            source: widget.source,
            fit: widget.fit,
            width: widget.width,
            height: widget.height,
            errorWidget: const SizedBox.shrink(),
            onTap: () {
              if (mounted) {
                setState(() => _thumbnailLoaded = true);
              }
            },
          ),
        ],
      );
    }
    
    return AppImage(
      source: widget.source,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      placeholder: widget.placeholder,
      errorWidget: widget.errorWidget,
      heroTag: widget.heroTag,
    );
  }
}

class _LowQualityFirstLoader extends StatefulWidget {
  const _LowQualityFirstLoader({
    required this.source,
    required this.fit,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.heroTag,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? heroTag;

  @override
  State<_LowQualityFirstLoader> createState() => _LowQualityFirstLoaderState();
}

class _LowQualityFirstLoaderState extends State<_LowQualityFirstLoader> {
  bool _highQualityLoaded = false;

  @override
  Widget build(BuildContext context) {
    final isNetwork = widget.source.startsWith('http://') || widget.source.startsWith('https://');
    
    if (isNetwork) {
      final uri = Uri.tryParse(widget.source);
      if (uri != null) {
        final lowQualityUrl = uri.replace(
          queryParameters: {
            ...uri.queryParameters,
            'quality': 'low',
            'q': '50',
          },
        ).toString();
        
        return Stack(
          fit: StackFit.passthrough,
          children: [
            AnimatedOpacity(
              opacity: _highQualityLoaded ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: AppImage(
                source: lowQualityUrl,
                fit: widget.fit,
                width: widget.width,
                height: widget.height,
                placeholder: widget.placeholder,
                errorWidget: widget.errorWidget,
              ),
            ),
            AnimatedOpacity(
              opacity: _highQualityLoaded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AppImage(
                source: widget.source,
                fit: widget.fit,
                width: widget.width,
                height: widget.height,
                errorWidget: const SizedBox.shrink(),
                onTap: () {
                  if (mounted && !_highQualityLoaded) {
                    setState(() => _highQualityLoaded = true);
                  }
                },
              ),
            ),
          ],
        );
      }
    }
    
    return AppImage(
      source: widget.source,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      placeholder: widget.placeholder,
      errorWidget: widget.errorWidget,
      heroTag: widget.heroTag,
    );
  }
}
