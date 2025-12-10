import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Custom layout that animates map height and opacity based on feed scroll
class AnimatedMapFeedLayout extends StatefulWidget {
  const AnimatedMapFeedLayout({
    super.key,
    required this.mapBuilder,
    required this.feedBuilder,
    this.searchBarBuilder,
    this.minMapHeightPercent = 0.20,
    this.maxMapHeightPercent = 0.60,
    this.minMapOpacity = 0.15,
    this.animationDuration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutCubic,
  });

  final Widget Function(double opacity, double heightPercent) mapBuilder;
  final Widget Function(ScrollController scrollController, double sheetHeight) feedBuilder;
  final Widget Function()? searchBarBuilder;
  final double minMapHeightPercent;
  final double maxMapHeightPercent;
  final double minMapOpacity;
  final Duration animationDuration;
  final Curve curve;

  @override
  State<AnimatedMapFeedLayout> createState() => _AnimatedMapFeedLayoutState();
}

class _AnimatedMapFeedLayoutState extends State<AnimatedMapFeedLayout>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  
  double _mapHeightPercent = 0.60;
  double _mapOpacity = 1.0;
  double _lastScrollOffset = 0;
  bool _isScrollingToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _mapHeightPercent = widget.maxMapHeightPercent;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final offset = _scrollController.offset;
    final maxScroll = 200.0; // Scroll distance to reach minimum
    
    // Detect scroll direction
    _isScrollingToTop = offset < _lastScrollOffset;
    _lastScrollOffset = offset;

    // Calculate interpolation value (0 = top of feed, 1 = scrolled down)
    final scrollProgress = (offset / maxScroll).clamp(0.0, 1.0);

    setState(() {
      // Interpolate height: 60% -> 20%
      _mapHeightPercent = lerpDouble(
        widget.maxMapHeightPercent,
        widget.minMapHeightPercent,
        scrollProgress,
      )!;

      // Interpolate opacity: 1.0 -> 0.15
      _mapOpacity = lerpDouble(
        1.0,
        widget.minMapOpacity,
        scrollProgress,
      )!;
    });
  }

  /// Pull to reveal map - when at top and pulling down
  void _onPullToReveal() {
    if (_scrollController.offset <= 0) {
      setState(() {
        _mapHeightPercent = widget.maxMapHeightPercent;
        _mapOpacity = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * _mapHeightPercent;
    final feedHeight = screenHeight - mapHeight;

    return Stack(
      children: [
        // Map Layer with animated opacity
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: mapHeight,
          child: AnimatedOpacity(
            opacity: _mapOpacity,
            duration: widget.animationDuration,
            curve: widget.curve,
            child: widget.mapBuilder(_mapOpacity, _mapHeightPercent),
          ),
        ),

        // Feed Layer with glassmorphism header
        Positioned(
          top: mapHeight - 24, // Overlap for rounded corners
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildFeedContainer(feedHeight + 24),
        ),

        // Search Bar (always on top)
        if (widget.searchBarBuilder != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: widget.searchBarBuilder!(),
          ),
      ],
    );
  }

  Widget _buildFeedContainer(double height) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Glass blur header with drag handle
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.scaffoldBackgroundColor.withOpacity(0.8),
                      theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: Center(
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.delta.dy > 0) {
                        _onPullToReveal();
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Scrollable feed content
          Expanded(
            child: widget.feedBuilder(_scrollController, height),
          ),
        ],
      ),
    );
  }
}
