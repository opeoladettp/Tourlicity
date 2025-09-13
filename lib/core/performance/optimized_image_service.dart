import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Service for optimized image loading and caching
class OptimizedImageService {
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheTimeout = Duration(days: 7);

  /// Creates an optimized cached network image widget
  static Widget buildOptimizedNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    bool enableMemoryCache = true,
    bool enableDiskCache = true,
    Duration? cacheTimeout,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      maxWidthDiskCache: width?.toInt(),
      maxHeightDiskCache: height?.toInt(),
      placeholder: (context, url) =>
          placeholder ?? _buildPlaceholder(width, height),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildErrorWidget(width, height),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
      useOldImageOnUrlChange: true,
      // Uses default cache manager from cached_network_image
    );
  }

  /// Creates a thumbnail version of an image
  static Widget buildThumbnail({
    required String imageUrl,
    required double size,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return buildOptimizedNetworkImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  /// Preloads images for better performance
  static Future<void> preloadImages(
    BuildContext context,
    List<String> imageUrls, {
    Size? targetSize,
  }) async {
    final futures = imageUrls.map((url) {
      return precacheImage(
        CachedNetworkImageProvider(url),
        context,
        size: targetSize,
      );
    });

    await Future.wait(futures);
  }

  /// Compresses an image file
  static Future<Uint8List> compressImage(
    File imageFile, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: maxWidth,
      targetHeight: maxHeight,
    );

    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return data!.buffer.asUint8List();
  }

  /// Builds a shimmer placeholder
  static Widget _buildPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  /// Builds an error widget
  static Widget _buildErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.error_outline,
        color: Colors.grey,
      ),
    );
  }

  /// Clears image cache
  static Future<void> clearCache() async {
    // Clear the default image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Gets cache size
  static Future<int> getCacheSize() async {
    return ImageCacheUtils.getCurrentCacheSize();
  }
}

/// Image cache utilities
class ImageCacheUtils {
  /// Gets current cache size (approximation)
  static int getCurrentCacheSize() {
    return PaintingBinding.instance.imageCache.currentSize;
  }
  
  /// Gets maximum cache size
  static int getMaxCacheSize() {
    return PaintingBinding.instance.imageCache.maximumSize;
  }
  
  /// Sets maximum cache size
  static void setMaxCacheSize(int size) {
    PaintingBinding.instance.imageCache.maximumSize = size;
  }
  
  /// Sets maximum cache size in bytes
  static void setMaxCacheSizeBytes(int bytes) {
    PaintingBinding.instance.imageCache.maximumSizeBytes = bytes;
  }
}

/// Widget for lazy loading images in lists
class LazyImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const LazyImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // For simplicity, load image immediately
    // In production, consider using visibility_detector package
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isVisible
        ? OptimizedImageService.buildOptimizedNetworkImage(
            imageUrl: widget.imageUrl,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            placeholder: widget.placeholder,
            errorWidget: widget.errorWidget,
          )
        : widget.placeholder ??
            OptimizedImageService._buildPlaceholder(
                widget.width, widget.height);
  }
}

/// Image size calculator for responsive images
class ImageSizeCalculator {
  /// Calculates optimal image size based on device
  static Size calculateOptimalSize(
    BuildContext context, {
    double? aspectRatio,
    double maxWidth = double.infinity,
    double maxHeight = double.infinity,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    double width = (screenSize.width * devicePixelRatio).clamp(0, maxWidth);
    double height = aspectRatio != null
        ? width / aspectRatio
        : (screenSize.height * devicePixelRatio).clamp(0, maxHeight);

    return Size(width, height);
  }

  /// Gets thumbnail size based on screen density
  static double getThumbnailSize(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (80 * devicePixelRatio).clamp(80, 200);
  }
}
