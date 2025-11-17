import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/active_orders_bloc.dart';
import '../widgets/active_order_modal.dart';

class ActiveOrderFAB extends StatefulWidget {
  const ActiveOrderFAB({super.key});

  @override
  State<ActiveOrderFAB> createState() => _ActiveOrderFABState();
}

class _ActiveOrderFABState extends State<ActiveOrderFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for attention-grabbing
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Slide animation for show/hide
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 2), // Start from bottom
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Start listening to ActiveOrdersBloc state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActiveOrdersBloc>().stream.listen((state) {
        _updateFabState(state.fabState);
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _updateFabState(FabState fabState) {
    switch (fabState) {
      case FabState.hidden:
        _slideController.reverse();
        _pulseController.stop();
        break;
      case FabState.visible:
        _slideController.forward();
        _pulseController.stop();
        break;
      case FabState.pulsing:
        _slideController.forward();
        _pulseController.repeat(reverse: true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveOrdersBloc, ActiveOrdersState>(
      builder: (context, state) {
        if (state.fabState == FabState.hidden) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 24,
          right: 24,
          child: SlideTransition(
            position: _slideAnimation,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: _buildFab(state),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFab(ActiveOrdersState state) {
    final activeOrderCount = state.activeOrderCount;
    final hasOrdersNeedingAttention = state.hasOrdersNeedingAttention;

    return FloatingActionButton.extended(
      onPressed: _openActiveOrderModal,
      icon: Stack(
        children: [
          const Icon(Icons.shopping_bag_outlined),
          if (hasOrdersNeedingAttention)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      label: Text(
        activeOrderCount == 1 ? '1 Order' : '$activeOrderCount Orders',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      backgroundColor: hasOrdersNeedingAttention
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  void _openActiveOrderModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<ActiveOrdersBloc>(),
        child: const ActiveOrderModal(),
      ),
    );
  }
}