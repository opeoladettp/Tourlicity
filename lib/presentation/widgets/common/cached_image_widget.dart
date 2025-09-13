import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey.shade400,
        size: 32,
      ),
    );
  }
}

class CachedAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackText;

  const CachedAvatarWidget({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade300,
        child: Text(
          fallbackText?.isNotEmpty == true 
              ? fallbackText!.substring(0, 1).toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        child: SizedBox(
          width: radius * 0.8,
          height: radius * 0.8,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade300,
        child: Text(
          fallbackText?.isNotEmpty == true 
              ? fallbackText!.substring(0, 1).toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
      ),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      memCacheWidth: (radius * 2).toInt(),
      memCacheHeight: (radius * 2).toInt(),
    );
  }
}