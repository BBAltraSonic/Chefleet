import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/utils/currency_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/repositories/order_repository.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../cart/blocs/cart_bloc.dart';
import '../../cart/blocs/cart_state.dart';
import '../../cart/blocs/cart_event.dart';
import '../../auth/blocs/auth_bloc.dart';
import '../blocs/order_bloc.dart';
import '../blocs/order_event.dart';
import '../blocs/order_state.dart';
import '../blocs/active_orders_bloc.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderBloc(
        orderRepository: OrderRepository(Supabase.instance.client),
        supabaseClient: Supabase.instance.client,
        authBloc: context.read<AuthBloc>(),
      ),
      child: const _CheckoutContent(),
    );
  }
}

class _CheckoutContent extends StatefulWidget {
  const _CheckoutContent();

  @override
  State<_CheckoutContent> createState() => _CheckoutContentState();
}

class _CheckoutContentState extends State<_CheckoutContent> {
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeOrder();
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  void _initializeOrder() {
    final cartState = context.read<CartBloc>().state;
    
    // Check for multiple vendors
    if (cartState.hasMultipleVendors) {
      // Show error dialog and pop
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Order Error'),
            content: const Text(
              'Your cart contains items from different vendors. Please clear your cart and order from one vendor at a time.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to cart
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
      return;
    }

    final orderBloc = context.read<OrderBloc>();
    
    // Add items from cart to order
    for (final item in cartState.items) {
      orderBloc.add(OrderItemAdded(
        dishId: item.dish.id,
        quantity: item.quantity,
        specialInstructions: item.specialInstructions,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state.status == OrderStatus.success && state.placedOrderId != null) {
          // Refresh active orders to show FAB immediately
          context.read<ActiveOrdersBloc>().add(RefreshActiveOrders());

          // Clear cart
          context.read<CartBloc>().add(const ClearCart());
          
          // Navigate to confirmation
          context.go('${CustomerRoutes.orders}/${state.placedOrderId}/confirmation');
        } else if (state.status == OrderStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            color: AppTheme.darkText,
          ),
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state.items.isEmpty && state.status == OrderStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // Use pickup time from cart state if available, otherwise default
            final cartState = context.read<CartBloc>().state;
            final pickupTime = state.pickupTime ?? 
                             cartState.pickupTime ?? 
                             DateTime.now().add(const Duration(minutes: 15));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Items
                  _buildSectionTitle('Order Items'),
                  const SizedBox(height: 8),
                  _buildItemsList(state),
                  const SizedBox(height: 24),

                  // Pickup Time
                  _buildSectionTitle('Pickup Time'),
                  const SizedBox(height: 8),
                  _buildPickupTimeSelector(context, pickupTime),
                  const SizedBox(height: 24),

                  // Special Instructions
                  _buildSectionTitle('Special Instructions'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _instructionsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add notes for the kitchen...',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      context.read<OrderBloc>().add(
                        SpecialInstructionsUpdated(value),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Order Summary
                  _buildSectionTitle('Summary'),
                  const SizedBox(height: 8),
                  _buildOrderSummary(state),
                  const SizedBox(height: 32),

                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.status == OrderStatus.placing
                          ? null
                          : () {
                              // Ensure pickup time is set
                              if (state.pickupTime == null) {
                                context.read<OrderBloc>().add(
                                  PickupTimeSelected(pickupTime),
                                );
                              }
                              context.read<OrderBloc>().add(const OrderPlaced());
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: AppTheme.darkText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: state.status == OrderStatus.placing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkText),
                              ),
                            )
                          : const Text(
                              'Place Order',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.darkText,
      ),
    );
  }

  Widget _buildItemsList(OrderState state) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: state.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.quantity}x',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.dishName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (item.specialInstructions != null && item.specialInstructions!.isNotEmpty)
                          Text(
                            item.specialInstructions!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(item.itemTotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPickupTimeSelector(BuildContext context, DateTime selectedTime) {
    return GlassContainer(
      child: ListTile(
        leading: const Icon(Icons.access_time, color: AppTheme.primaryGreen),
        title: Text(
          DateFormat('MMM dd, h:mm a').format(selectedTime),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final now = DateTime.now();
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(selectedTime),
          );
          
          if (time != null) {
            final newDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              time.hour,
              time.minute,
            );
            
            // If time is in past (today), maybe user meant tomorrow? 
            // For simplicity, just assume today.
            // Proper validation happens in OrderBloc/Edge Function.
            
            if (mounted) {
              context.read<OrderBloc>().add(PickupTimeSelected(newDateTime));
            }
          }
        },
      ),
    );
  }

  Widget _buildOrderSummary(OrderState state) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', state.subtotal),
            const SizedBox(height: 8),
            _buildSummaryRow('Tax', state.tax),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
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
                  CurrencyFormatter.format(state.total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
        Text(
          CurrencyFormatter.format(amount),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
