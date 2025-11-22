import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Optimized cached image widget with accessibility support
/// Uses cached_network_image for better performance and offline support
class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      memCacheHeight: height != null ? (height! * 2).toInt() : null,
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    if (semanticLabel != null) {
      imageWidget = Semantics(
        image: true,
        label: semanticLabel,
        child: ExcludeSemantics(child: imageWidget),
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(
        Icons.broken_image,
        size: (width != null && height != null) 
            ? (width! < height! ? width! * 0.4 : height! * 0.4)
            : 40,
        color: Colors.grey[600],
      ),
    );
  }
}

/// Circular cached image widget for avatars and logos
class CircularCachedImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? semanticLabel;

  const CircularCachedImage({
    super.key,
    required this.imageUrl,
    this.size = 50,
    this.placeholder,
    this.errorWidget,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return CachedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(size / 2),
      placeholder: placeholder ?? _buildPlaceholder(),
      errorWidget: errorWidget ?? _buildErrorWidget(),
      semanticLabel: semanticLabel,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: Colors.grey[600],
      ),
    );
  }
}

/// Thumbnail image widget for list items
/// Optimized for small sizes with aggressive caching
class ThumbnailImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? semanticLabel;

  const ThumbnailImage({
    super.key,
    required this.imageUrl,
    this.size = 80,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      // Aggressive caching for thumbnails
      memCacheWidth: (size * 2).toInt(),
      memCacheHeight: (size * 2).toInt(),
      maxWidthDiskCache: 200,
      maxHeightDiskCache: 200,
    );

    if (semanticLabel != null) {
      imageWidget = Semantics(
        image: true,
        label: semanticLabel,
        child: ExcludeSemantics(child: imageWidget),
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: size * 0.3,
          height: size * 0.3,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[300],
      child: Icon(
        Icons.image_not_supported,
        size: size * 0.4,
        color: Colors.grey[600],
      ),
    );
  }
}
