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
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        final hasItems = cartState.totalItems > 0;
        
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
                child: Stack(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleTap(context, hasItems),
                        borderRadius: BorderRadius.circular(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              hasItems ? Icons.shopping_cart : Icons.shopping_bag_outlined,
                              size: 24,
                              color: AppTheme.darkText,
                            ),
                            const SizedBox(height: 2),
                          ],
                        ),
                      ),
                    ),
                    // Badge for cart item count
                    if (hasItems)
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleTap(BuildContext context, bool hasCartItems) {
    if (hasCartItems) {
      // Show cart bottom sheet
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return BlocProvider.value(
            value: context.read<CartBloc>(),
            child: DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your Cart',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Cart items
                      Expanded(
                        child: BlocBuilder<CartBloc, CartState>(
                          builder: (context, cartState) {
                            if (cartState.items.isEmpty) {
                              return const Center(
                                child: Text('Your cart is empty'),
                              );
                            }
                            return ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(20),
                              itemCount: cartState.items.length,
                              itemBuilder: (context, index) {
                                final item = cartState.items[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    title: Text(item.dish.displayName),
                                    subtitle: Text('\$${item.dish.price.toStringAsFixed(2)} × ${item.quantity}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () {
                                        context.read<CartBloc>().add(RemoveFromCart(item.dish.id));
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // Total and checkout
                      BlocBuilder<CartBloc, CartState>(
                        builder: (context, cartState) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              border: Border(top: BorderSide(color: Colors.grey[300]!)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '\$${cartState.total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // TODO: Navigate to checkout
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGreen,
                                      foregroundColor: AppTheme.darkText,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Checkout',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      // Show active orders modal
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
}