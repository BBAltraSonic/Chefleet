import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/user_role.dart';
import '../../core/theme/app_theme.dart';
import '../map/screens/map_screen.dart';
import '../order/widgets/active_order_modal.dart';
import '../order/blocs/active_orders_bloc.dart';
import '../cart/cart.dart';

/// Customer app shell for the main customer experience.
///
/// This shell provides:
/// - Map screen as the primary interface
/// - Floating action button for cart/orders
/// - Full-screen edge-to-edge display
class CustomerAppShell extends StatefulWidget {
  const CustomerAppShell({
    super.key,
    required this.availableRoles,
  });

  final Set<UserRole> availableRoles;

  @override
  State<CustomerAppShell> createState() => _CustomerAppShellState();
}

class _CustomerAppShellState extends State<CustomerAppShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapScreen(),
      floatingActionButton: const _CustomerFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// Floating action button for cart and active orders
class _CustomerFloatingActionButton extends StatefulWidget {
  const _CustomerFloatingActionButton();

  @override
  State<_CustomerFloatingActionButton> createState() =>
      __CustomerFloatingActionButtonState();
}

class __CustomerFloatingActionButtonState
    extends State<_CustomerFloatingActionButton>
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
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor, // Use theme primary color (Black)
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleTap(context, hasItems),
                        borderRadius: BorderRadius.circular(30),
                        child: Center(
                          child: Icon(
                            hasItems
                                ? Icons.shopping_cart_rounded
                                : Icons.shopping_bag_outlined,
                            size: 26,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Badge for cart item count
                    if (hasItems)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red, // Standard notification red
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          child: Center(
                            child: Text(
                              '${cartState.totalItems}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
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
      _showCartBottomSheet(context);
    } else {
      // Show active orders modal
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        builder: (context) {
          return BlocProvider.value(
            value: context.read<ActiveOrdersBloc>(),
            child: const ActiveOrderModal(),
          );
        },
      );
    }
  }

  void _showCartBottomSheet(BuildContext context) {
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
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
                                  subtitle: Text(
                                      '\$${item.dish.price.toStringAsFixed(2)} × ${item.quantity}'),
                                  trailing: IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      context
                                          .read<CartBloc>()
                                          .add(RemoveFromCart(item.dish.id));
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
                            border: Border(
                                top: BorderSide(color: Colors.grey[300]!)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
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
  }
}
