import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/blocs/navigation_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../features/order/widgets/active_order_modal.dart';
import '../../features/order/blocs/active_orders_bloc.dart';
import '../../features/cart/cart.dart';

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
    return BlocBuilder<ActiveOrdersBloc, ActiveOrdersState>(
      builder: (context, ordersState) {
        return BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            // Determine what to show based on priority
            final readyOrders = ordersState.orders.where((o) {
              final order = o;
              return order['status'] == 'ready';
            }).toList();
            final preparingOrders = ordersState.orders.where((o) {
              final order = o;
              return order['status'] == 'preparing';
            }).toList();
            final hasCartItems = cartState.totalItems > 0;
            
            // Priority: Ready orders > Preparing orders > Cart
            final showReadyOrder = readyOrders.isNotEmpty;
            final showPreparingOrder = !showReadyOrder && preparingOrders.isNotEmpty;
            
            // Only pulse for ready orders
            final shouldPulse = showReadyOrder;
            
            return AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: shouldPulse ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 64,
                    height: 64,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: showReadyOrder 
                          ? Colors.orange 
                          : showPreparingOrder 
                              ? AppTheme.secondaryGreen 
                              : AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (showReadyOrder 
                              ? Colors.orange 
                              : AppTheme.primaryGreen).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _handleTap(context),
                            borderRadius: BorderRadius.circular(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  showReadyOrder 
                                      ? Icons.restaurant 
                                      : showPreparingOrder 
                                          ? Icons.soup_kitchen 
                                          : hasCartItems 
                                              ? Icons.shopping_cart 
                                              : Icons.shopping_bag_outlined,
                                  size: 24,
                                  color: AppTheme.darkText,
                                ),
                                const SizedBox(height: 2),
                              ],
                            ),
                          ),
                        ),
                        // Badge for cart item count or order count
                        if (hasCartItems && !showReadyOrder && !showPreparingOrder)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                '${cartState.totalItems}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        // Badge for active orders
                        if (showReadyOrder || showPreparingOrder)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: showReadyOrder ? Colors.white : AppTheme.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                '${showReadyOrder ? readyOrders.length : preparingOrders.length}',
                                style: TextStyle(
                                  color: showReadyOrder ? Colors.orange : AppTheme.darkText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _handleTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider.value(
          value: context.read<ActiveOrdersBloc>(),
          child: const ActiveOrderModal(),
        );
      },
    );
  }
}