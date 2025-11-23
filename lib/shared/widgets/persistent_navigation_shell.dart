import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/blocs/navigation_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../features/order/widgets/active_order_modal.dart';
import '../../features/order/blocs/active_orders_bloc.dart';

class PersistentNavigationShell extends StatefulWidget {
  const PersistentNavigationShell({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  State<PersistentNavigationShell> createState() => _PersistentNavigationShellState();
}

class _PersistentNavigationShellState extends State<PersistentNavigationShell> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.currentTab.index,
            children: widget.children,
          ),
          floatingActionButton: const OrdersFloatingActionButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}

class OrdersFloatingActionButton extends StatefulWidget {
  const OrdersFloatingActionButton({super.key});

  @override
  State<OrdersFloatingActionButton> createState() => _OrdersFloatingActionButtonState();
}

class _OrdersFloatingActionButtonState extends State<OrdersFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
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
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 64,
            height: 64,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showActiveOrderModal,
                borderRadius: BorderRadius.circular(32),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 24,
                      color: AppTheme.darkText,
                    ),
                    SizedBox(height: 2),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showActiveOrderModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return BlocProvider.value(
          value: context.read<ActiveOrdersBloc>(),
          child: const ActiveOrderModal(),
        );
      },
    );
  }
}