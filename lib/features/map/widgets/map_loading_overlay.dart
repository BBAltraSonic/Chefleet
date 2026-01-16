import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_container.dart';

/// Loading overlay for map with skeleton markers
class MapLoadingOverlay extends StatelessWidget {
  const MapLoadingOverlay({
    super.key,
    this.message = 'Loading nearby vendors...',
    this.showSkeletonMarkers = true,
  });

  final String message;
  final bool showSkeletonMarkers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Skeleton markers (if enabled)
        if (showSkeletonMarkers) ...[
          Positioned(
            left: MediaQuery.of(context).size.width * 0.3,
            top: MediaQuery.of(context).size.height * 0.25,
            child: const PulsingMarkerSkeleton(),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.6,
            top: MediaQuery.of(context).size.height * 0.35,
            child: const PulsingMarkerSkeleton(delay: 200),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.45,
            top: MediaQuery.of(context).size.height * 0.5,
            child: const PulsingMarkerSkeleton(delay: 400),
          ),
        ],

        // Loading message at bottom
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.45,
          left: 0,
          right: 0,
          child: Center(
            child: GlassContainer(
              blur: 18,
              opacity: 0.9,
              borderRadius: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Pulsing skeleton marker with shimmer effect
class PulsingMarkerSkeleton extends StatefulWidget {
  const PulsingMarkerSkeleton({
    super.key,
    this.delay = 0,
  });

  final int delay;

  @override
  State<PulsingMarkerSkeleton> createState() => _PulsingMarkerSkeletonState();
}

class _PulsingMarkerSkeletonState extends State<PulsingMarkerSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Delay start if specified
    if (widget.delay > 0) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) {
          _controller.repeat(reverse: true);
        }
      });
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withOpacity(0.3),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.restaurant_rounded,
                color: theme.primaryColor.withOpacity(0.6),
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Progress indicator for long-running operations
class MapProgressIndicator extends StatelessWidget {
  const MapProgressIndicator({
    super.key,
    required this.progress,
    this.message,
  });

  final double progress; // 0.0 to 1.0
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 0,
      right: 0,
      child: Center(
        child: GlassContainer(
          blur: 18,
          opacity: 0.9,
          borderRadius: 16,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message != null) ...[
                  Text(
                    message!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: theme.primaryColor.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
