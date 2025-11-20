import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Hero animation optimization utilities for smooth transitions
class HeroOptimizer {
  static HeroOptimizer? _instance;
  HeroOptimizer._();

  factory HeroOptimizer() => _instance ??= HeroOptimizer._();

  /// Animation performance settings
  bool _isOptimizationEnabled = true;
  int _maxConcurrentAnimations = 3;
  Duration _defaultAnimationDuration = const Duration(milliseconds: 300);
  Duration _optimizedAnimationDuration = const Duration(milliseconds: 200);

  /// Animation queue management
  final Queue<_PendingHeroAnimation> _animationQueue = Queue<_PendingHeroAnimation>();
  final Set<String> _activeAnimations = <String>{};
  final Map<String, _AnimationMetrics> _animationMetrics = {};

  /// Performance optimization
  final Map<String, ui.Image?> _imageCache = {};
  final Map<String, Size> _sizeCache = {};
  int _maxImageCacheSize = 50;
  int _maxSizeCacheSize = 200;

  /// Device capability detection
  bool _isLowEndDevice = false;
  bool _reduceAnimations = false;
  double _devicePerformanceScore = 1.0;

  /// Animation callbacks
  final List<Function(String)> _animationStartCallbacks = [];
  final List<Function(String, Duration)> _animationCompleteCallbacks = [];

  /// Statistics
  int _totalAnimations = 0;
  int _cachedAnimations = 0;
  int _queuedAnimations = 0;
  int _droppedAnimations = 0;
  final List<Duration> _animationDurations = [];

  /// Initialize the hero optimizer
  Future<void> initialize() async {
    await _detectDeviceCapabilities();
    _setupPerformanceMonitoring();

    developer.log(
      'HeroOptimizer initialized - Performance Score: $_devicePerformanceScore',
      name: 'HeroOptimizer',
    );
  }

  /// Detect device capabilities
  Future<void> _detectDeviceCapabilities() async {
    try {
      // Get device pixel ratio and screen size
      final pixelRatio = ui.window.devicePixelRatio;
      final screenSize = ui.window.physicalSize;
      final totalPixels = screenSize.width * screenSize.height;

      // Calculate performance score based on device characteristics
      double performanceScore = 1.0;

      // Adjust for pixel ratio (higher ratio = more demanding)
      if (pixelRatio > 3.0) {
        performanceScore *= 0.8;
      } else if (pixelRatio < 2.0) {
        performanceScore *= 1.1;
      }

      // Adjust for screen resolution
      if (totalPixels > 2000000) { // 2K+ resolution
        performanceScore *= 0.7;
      } else if (totalPixels < 1000000) { // Lower resolution
        performanceScore *= 1.2;
      }

      // Check for reduced motion / accessibility settings
      final accessibility = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures;
      _reduceAnimations = accessibility.disableAnimations;

      // Determine if this is a low-end device
      _isLowEndDevice = performanceScore < 0.8 || _reduceAnimations;

      // Apply final adjustments
      if (_isLowEndDevice) {
        performanceScore *= 0.6;
        _maxConcurrentAnimations = 2;
        _defaultAnimationDuration = const Duration(milliseconds: 200);
        _maxImageCacheSize = 20;
        _maxSizeCacheSize = 100;
      }

      _devicePerformanceScore = performanceScore;

    } catch (e) {
      developer.log(
        'Failed to detect device capabilities: $e',
        name: 'HeroOptimizer',
        error: e,
      );

      // Default to conservative settings
      _isLowEndDevice = true;
      _devicePerformanceScore = 0.7;
      _maxConcurrentAnimations = 2;
    }
  }

  /// Setup performance monitoring
  void _setupPerformanceMonitoring() {
    // Monitor frame rate and adjust animations accordingly
    WidgetsBinding.instance.addPostFrameCallback(_onPostFrame);
  }

  /// Called after each frame
  void _onFrame(Duration timestamp) {
    // This could be used to monitor performance and adjust animations
    WidgetsBinding.instance.addPostFrameCallback(_onPostFrame);
  }

  void _onPostFrame(Duration timestamp) {
    // Implementation for performance monitoring
    // Could track frame rates and adjust animation quality dynamically
  }

  /// Create optimized hero animation widget
  Widget createOptimizedHero({
    required String tag,
    required Widget child,
    Duration? duration,
    Curve? curve,
    bool enableCachedTransition = true,
    HeroFlightShuttleBuilder? flightShuttleBuilder,
    HeroPlaceholderBuilder? placeholderBuilder,
  }) {
    if (!_isOptimizationEnabled) {
      return Hero(
        tag: tag,
        child: child,
        flightShuttleBuilder: flightShuttleBuilder,
        placeholderBuilder: placeholderBuilder,
      );
    }

    final animationDuration = _getOptimizedDuration(duration);
    final optimizedCurve = _getOptimizedCurve(curve);

    return OptimizedHero(
      tag: tag,
      child: child,
      duration: animationDuration,
      curve: optimizedCurve,
      enableCachedTransition: enableCachedTransition,
      flightShuttleBuilder: _createOptimizedFlightShuttleBuilder(
        flightShuttleBuilder,
        enableCachedTransition,
      ),
      placeholderBuilder: placeholderBuilder,
      onAnimationStart: () => _onAnimationStart(tag),
      onAnimationEnd: () => _onAnimationEnd(tag, animationDuration),
    );
  }

  /// Get optimized animation duration
  Duration _getOptimizedDuration(Duration? requestedDuration) {
    if (!_isOptimizationEnabled || requestedDuration != null) {
      return requestedDuration ?? _defaultAnimationDuration;
    }

    if (_isLowEndDevice || _reduceAnimations) {
      return _optimizedAnimationDuration;
    }

    if (_activeAnimations.length >= _maxConcurrentAnimations) {
      return const Duration(milliseconds: 150); // Shorter duration for queued animations
    }

    return _defaultAnimationDuration;
  }

  /// Get optimized animation curve
  Curve _getOptimizedCurve(Curve? requestedCurve) {
    if (!_isOptimizationEnabled || requestedCurve != null) {
      return requestedCurve ?? Curves.easeInOut;
    }

    if (_isLowEndDevice) {
      // Use simpler curves for better performance
      return Curves.easeOut;
    }

    if (_activeAnimations.length >= _maxConcurrentAnimations) {
      return Curves.easeOut; // Faster curve for queued animations
    }

    return Curves.easeInOut;
  }

  /// Create optimized flight shuttle builder
  HeroFlightShuttleBuilder? _createOptimizedFlightShuttleBuilder(
    HeroFlightShuttleBuilder? originalBuilder,
    bool enableCaching,
  ) {
    if (originalBuilder != null) {
      return originalBuilder;
    }

    if (!enableCaching) {
      return null;
    }

    return (BuildContext flightContext, Animation<double> animation, HeroFlightDirection flightDirection, BuildContext fromHeroContext, BuildContext toHeroContext) {
      final tag = (toHeroContext.widget as Hero).tag.toString();

      // Check if we have a cached image for this hero
      if (_imageCache.containsKey(tag)) {
        final cachedImage = _imageCache[tag];
        final cachedSize = _sizeCache[tag];

        if (cachedImage != null && cachedSize != null) {
          return _buildCachedHero(cachedImage, cachedSize, animation);
        }
      }

      // Use default hero flight behavior
      return toHeroContext.widget;
    };
  }

  /// Build cached hero widget
  Widget _buildCachedHero(ui.Image image, Size size, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: CustomPaint(
            size: size,
            painter: _CachedImagePainter(image),
          ),
        );
      },
    );
  }

  /// Handle animation start
  void _onAnimationStart(String tag) {
    _totalAnimations++;

    // Check if we should queue this animation
    if (_activeAnimations.length >= _maxConcurrentAnimations) {
      _queuedAnimations++;
      _animationQueue.add(_PendingHeroAnimation(
        tag: tag,
        timestamp: DateTime.now(),
      ));
      return;
    }

    _activeAnimations.add(tag);

    // Record animation start
    _recordAnimationStart(tag);

    // Notify callbacks
    for (final callback in _animationStartCallbacks) {
      try {
        callback(tag);
      } catch (e) {
        developer.log(
          'Error in animation start callback: $e',
          name: 'HeroOptimizer',
          error: e,
        );
      }
    }
  }

  /// Handle animation end
  void _onAnimationEnd(String tag, Duration duration) {
    _activeAnimations.remove(tag);

    // Record animation completion
    _recordAnimationEnd(tag, duration);

    // Process queued animations
    _processQueuedAnimations();

    // Notify callbacks
    for (final callback in _animationCompleteCallbacks) {
      try {
        callback(tag, duration);
      } catch (e) {
        developer.log(
          'Error in animation complete callback: $e',
          name: 'HeroOptimizer',
          error: e,
        );
      }
    }
  }

  /// Process queued animations
  void _processQueuedAnimations() {
    while (_animationQueue.isNotEmpty && _activeAnimations.length < _maxConcurrentAnimations) {
      final pendingAnimation = _animationQueue.removeFirst();

      // Skip very old queued animations (they're likely irrelevant now)
      final waitTime = DateTime.now().difference(pendingAnimation.timestamp);
      if (waitTime.inMilliseconds > 500) {
        _droppedAnimations++;
        continue;
      }

      // Start the queued animation
      _onAnimationStart(pendingAnimation.tag);
    }
  }

  /// Record animation start metrics
  void _recordAnimationStart(String tag) {
    final metrics = _animationMetrics.putIfAbsent(
      tag,
      () => _AnimationMetrics(tag: tag),
    );
    metrics.recordStart();
  }

  /// Record animation end metrics
  void _recordAnimationEnd(String tag, Duration duration) {
    final metrics = _animationMetrics[tag];
    if (metrics != null) {
      metrics.recordEnd(duration);
    }

    _animationDurations.add(duration);

    // Keep only last 100 animation durations
    if (_animationDurations.length > 100) {
      _animationDurations.removeAt(0);
    }
  }

  /// Cache hero widget for faster transitions
  void cacheHeroWidget(String tag, Widget widget) {
    if (!_isOptimizationEnabled) return;

    // In a real implementation, this would render the widget to an image
    // and cache it for future animations. For now, we'll simulate caching.

    if (_imageCache.length >= _maxImageCacheSize) {
      _evictOldestImageCache();
    }

    // Simulate caching by just storing a placeholder
    _imageCache[tag] = null; // Would be actual image
    _sizeCache[tag] = const Size(100, 100); // Would be actual size

    _cachedAnimations++;
  }

  /// Evict oldest image cache entry
  void _evictOldestImageCache() {
    if (_imageCache.isEmpty) return;

    // Simple FIFO eviction - in a real implementation, this would be more sophisticated
    final firstKey = _imageCache.keys.first;
    _imageCache.remove(firstKey);
    _sizeCache.remove(firstKey);
  }

  /// Preload hero widgets for upcoming transitions
  Future<void> preloadHeroes(List<String> tags) async {
    if (!_isOptimizationEnabled || _isLowEndDevice) return;

    for (final tag in tags) {
      if (!_imageCache.containsKey(tag)) {
        // In a real implementation, this would pre-render the hero
        // and cache the resulting image
        try {
          // Simulate preloading delay
          await Future.delayed(Duration(milliseconds: 10));

          // Cache the preloaded hero
          cacheHeroWidget(tag, Container()); // Placeholder widget
        } catch (e) {
          developer.log(
            'Failed to preload hero: $tag',
            name: 'HeroOptimizer',
            error: e,
          );
        }
      }
    }
  }

  /// Check if hero animation should be enabled
  bool shouldEnableHeroAnimation() {
    return _isOptimizationEnabled && !_reduceAnimations;
  }

  /// Get recommended animation duration based on current load
  Duration getRecommendedDuration() {
    if (!_isOptimizationEnabled) return _defaultAnimationDuration;

    final activeCount = _activeAnimations.length;
    final queueCount = _animationQueue.length;

    if (activeCount >= _maxConcurrentAnimations) {
      return const Duration(milliseconds: 100); // Very fast for high load
    } else if (queueCount > 0) {
      return const Duration(milliseconds: 150); // Fast for queued animations
    } else if (_isLowEndDevice) {
      return _optimizedAnimationDuration;
    }

    return _defaultAnimationDuration;
  }

  /// Add animation start callback
  void addAnimationStartCallback(Function(String) callback) {
    _animationStartCallbacks.add(callback);
  }

  /// Remove animation start callback
  void removeAnimationStartCallback(Function(String) callback) {
    _animationStartCallbacks.remove(callback);
  }

  /// Add animation complete callback
  void addAnimationCompleteCallback(Function(String, Duration) callback) {
    _animationCompleteCallbacks.add(callback);
  }

  /// Remove animation complete callback
  void removeAnimationCompleteCallback(Function(String, Duration) callback) {
    _animationCompleteCallbacks.remove(callback);
  }

  /// Enable or disable optimization
  void setOptimizationEnabled(bool enabled) {
    _isOptimizationEnabled = enabled;

    if (!enabled) {
      _clearCaches();
    }

    developer.log(
      'Hero optimization ${enabled ? 'enabled' : 'disabled'}',
      name: 'HeroOptimizer',
    );
  }

  /// Clear all caches
  void _clearCaches() {
    _imageCache.clear();
    _sizeCache.clear();
    _animationMetrics.clear();
  }

  /// Get hero animation statistics
  Map<String, dynamic> getAnimationStatistics() {
    final avgDuration = _animationDurations.isEmpty
        ? 0.0
        : _animationDurations.fold(0, (sum, d) => sum + d.inMilliseconds) / _animationDurations.length;

    final cacheHitRate = _totalAnimations > 0
        ? (_cachedAnimations / _totalAnimations) * 100
        : 0.0;

    final dropRate = (_queuedAnimations + _cachedAnimations) > 0
        ? (_droppedAnimations / (_queuedAnimations + _cachedAnimations)) * 100
        : 0.0;

    return {
      'isOptimizationEnabled': _isOptimizationEnabled,
      'devicePerformanceScore': _devicePerformanceScore,
      'isLowEndDevice': _isLowEndDevice,
      'reduceAnimations': _reduceAnimations,
      'totalAnimations': _totalAnimations,
      'cachedAnimations': _cachedAnimations,
      'queuedAnimations': _queuedAnimations,
      'droppedAnimations': _droppedAnimations,
      'activeAnimations': _activeAnimations.length,
      'maxConcurrentAnimations': _maxConcurrentAnimations,
      'averageAnimationDuration': avgDuration.round(),
      'cacheHitRate': cacheHitRate.toStringAsFixed(1),
      'animationDropRate': dropRate.toStringAsFixed(1),
      'imageCacheSize': _imageCache.length,
      'maxImageCacheSize': _maxImageCacheSize,
      'defaultDuration': _defaultAnimationDuration.inMilliseconds,
      'optimizedDuration': _optimizedAnimationDuration.inMilliseconds,
    };
  }

  /// Clear caches
  void clearCaches() {
    _clearCaches();
    developer.log('Hero caches cleared', name: 'HeroOptimizer');
  }

  /// Reset statistics
  void resetStatistics() {
    _totalAnimations = 0;
    _cachedAnimations = 0;
    _queuedAnimations = 0;
    _droppedAnimations = 0;
    _animationDurations.clear();

    developer.log('Hero optimizer statistics reset', name: 'HeroOptimizer');
  }

  /// Dispose resources
  void dispose() {
    _clearCaches();
    _animationQueue.clear();
    _activeAnimations.clear();
    _animationStartCallbacks.clear();
    _animationCompleteCallbacks.clear();

    developer.log('HeroOptimizer disposed', name: 'HeroOptimizer');
  }
}

/// Optimized Hero widget with performance enhancements
class OptimizedHero extends StatefulWidget {
  final String tag;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool enableCachedTransition;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final HeroPlaceholderBuilder? placeholderBuilder;
  final VoidCallback? onAnimationStart;
  final VoidCallback? onAnimationEnd;

  const OptimizedHero({
    Key? key,
    required this.tag,
    required this.child,
    required this.duration,
    required this.curve,
    this.enableCachedTransition = true,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
    this.onAnimationStart,
    this.onAnimationEnd,
  }) : super(key: key);

  @override
  State<OptimizedHero> createState() => _OptimizedHeroState();
}

class _OptimizedHeroState extends State<OptimizedHero>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _controller.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        widget.onAnimationStart?.call();
        break;
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        widget.onAnimationEnd?.call();
        break;
      case AnimationStatus.reverse:
        break;
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.tag,
      child: widget.child,
      flightShuttleBuilder: widget.flightShuttleBuilder,
      placeholderBuilder: widget.placeholderBuilder,
    );
  }
}

/// Pending hero animation in queue
class _PendingHeroAnimation {
  final String tag;
  final DateTime timestamp;

  _PendingHeroAnimation({
    required this.tag,
    required this.timestamp,
  });
}

/// Animation metrics for performance tracking
class _AnimationMetrics {
  final String tag;
  int startTime = 0;
  int totalDuration = 0;
  int executionCount = 0;
  int minDuration = 0;
  int maxDuration = 0;

  _AnimationMetrics({
    required this.tag,
  });

  void recordStart() {
    startTime = DateTime.now().millisecondsSinceEpoch;
  }

  void recordEnd(Duration duration) {
    final durationMs = duration.inMilliseconds;
    totalDuration += durationMs;
    executionCount++;

    if (minDuration == 0 || durationMs < minDuration) {
      minDuration = durationMs;
    }

    if (durationMs > maxDuration) {
      maxDuration = durationMs;
    }
  }

  double get averageDuration {
    return executionCount > 0 ? totalDuration / executionCount : 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'tag': tag,
      'executionCount': executionCount,
      'averageDuration': averageDuration.round(),
      'minDuration': minDuration,
      'maxDuration': maxDuration,
      'totalDuration': totalDuration,
    };
  }
}

/// Custom painter for cached images
class _CachedImagePainter extends CustomPainter {
  final ui.Image? image;

  _CachedImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      final srcRect = Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble());
      final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(image!, srcRect, dstRect, Paint());
    }
  }

  @override
  bool shouldRepaint(_CachedImagePainter oldDelegate) {
    return image != oldDelegate.image;
  }
}