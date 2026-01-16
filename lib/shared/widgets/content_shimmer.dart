import 'package:flutter/material.dart';

/// A shimmer loading animation widget for displaying loading states.
///
/// This widget provides a smooth shimmer effect that can be used
/// as a placeholder while content is loading. It's commonly used
/// in lists, cards, and other content areas to indicate loading state.
///
/// Example usage:
/// ```dart
/// ContentShimmer(
///   height: 100,
///   width: double.infinity,
/// )
/// ```
class ContentShimmer extends StatefulWidget {
  const ContentShimmer({
    super.key,
    this.height = 100,
    this.width = double.infinity,
  });
  
  final double height;
  final double width;

  @override
  State<ContentShimmer> createState() => _ContentShimmerState();
}

class _ContentShimmerState extends State<ContentShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: const Alignment(1, 0),
              colors: [
                Colors.grey[300]!,
                Colors.grey[200]!,
                Colors.grey[300]!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}
