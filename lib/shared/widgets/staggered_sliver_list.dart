import 'package:flutter/material.dart';

/// A SliverList with staggered entrance animations
class StaggeredSliverList extends StatelessWidget {
  const StaggeredSliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.staggerDelay = const Duration(milliseconds: 60),
    this.animationDuration = const Duration(milliseconds: 400),
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index, Animation<double> animation) itemBuilder;
  final Duration staggerDelay;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _StaggeredItem(
            index: index,
            staggerDelay: staggerDelay,
            animationDuration: animationDuration,
            builder: (animation) => itemBuilder(context, index, animation),
          );
        },
        childCount: itemCount,
      ),
    );
  }
}

class _StaggeredItem extends StatefulWidget {
  const _StaggeredItem({
    required this.index,
    required this.staggerDelay,
    required this.animationDuration,
    required this.builder,
  });

  final int index;
  final Duration staggerDelay;
  final Duration animationDuration;
  final Widget Function(Animation<double> animation) builder;

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // Only animate first 10 items to avoid performance issues
    if (widget.index < 10) {
      Future.delayed(widget.staggerDelay * widget.index, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_controller);
  }
}
