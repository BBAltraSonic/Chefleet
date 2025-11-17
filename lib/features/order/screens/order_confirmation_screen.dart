import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../blocs/order_bloc.dart';
import '../blocs/order_state.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../core/theme/app_theme.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderId;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  Map<String, dynamic>? _orderDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('orders')
          .select('''
            *,
            vendors!inner(
              business_name,
              address,
              phone_number
            ),
            order_items(
              *,
              dishes(
                name,
                price
              )
            )
          ''')
          .eq('id', widget.orderId)
          .single();

      setState(() {
        _orderDetails = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load order details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _orderDetails != null
                  ? _buildConfirmationContent()
                  : _buildEmptyState(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Order',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadOrderDetails,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('Order not found'),
    );
  }

  Widget _buildConfirmationContent() {
    final order = _orderDetails!;
    final status = order['status'] as String? ?? 'pending';
    final pickupCode = order['pickup_code'] as String?;
    final vendor = order['vendors'] as Map<String, dynamic>? ?? {};
    final items = order['order_items'] as List<dynamic>? ?? [];
    final createdAt = DateTime.parse(order['created_at'] as String);
    final totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;

    return Column(
      children: [
        // Success Animation Area
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 24),

                // Success Message
                Text(
                  'Order Confirmed!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Your order has been placed successfully',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  'Order #${widget.orderId.substring(0, 8).toUpperCase()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Order Details
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Status and Pickup Code
                _buildStatusSection(status, pickupCode),

                const SizedBox(height: 24),

                // Vendor Information
                _buildVendorSection(vendor),

                const SizedBox(height: 24),

                // Order Items
                _buildOrderItemsSection(items),

                const SizedBox(height: 24),

                // Timing Information
                _buildTimingSection(createdAt, order),

                const SizedBox(height: 24),

                // Total Amount
                _buildTotalSection(totalAmount),

                const SizedBox(height: 32),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(String status, String? pickupCode) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Status',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        status.toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (pickupCode != null && status == 'ready') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.qr_code,
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup Code',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            pickupCode,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVendorSection(Map<String, dynamic> vendor) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendor Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.store,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    vendor['business_name'] as String? ?? 'Unknown Vendor',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (vendor['address'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      vendor['address'] as String,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsSection(List<dynamic> items) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) {
              final dish = item['dishes'] as Map<String, dynamic>? ?? {};
              final quantity = item['quantity'] as int? ?? 1;
              final unitPrice = (item['unit_price'] as num?)?.toDouble() ?? 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dish['name'] as String? ?? 'Item',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$quantity × \$${unitPrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${(quantity * unitPrice).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingSection(DateTime createdAt, Map<String, dynamic> order) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Timing',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Placed at',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, h:mm a').format(createdAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (order['pickup_time'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pickup Time',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, h:mm a').format(
                            DateTime.parse(order['pickup_time']),
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection(double totalAmount) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Paid',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '\$${totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Track Order Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _trackOrder,
            icon: const Icon(Icons.location_on),
            label: const Text('Track Order'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Contact Vendor Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _contactVendor,
            icon: const Icon(Icons.chat),
            label: const Text('Contact Vendor'),
          ),
        ),
        const SizedBox(height: 12),

        // Back to Home Button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _navigateToHome,
            child: const Text('Back to Home'),
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'accepted':
        return Icons.check_circle;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.restaurant_menu;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _trackOrder() {
    // Navigate to order tracking screen
    Navigator.of(context).pushNamed('/order-tracking', arguments: widget.orderId);
  }

  void _contactVendor() {
    // Navigate to chat screen with vendor
    Navigator.of(context).pushNamed('/chat', arguments: {
      'orderId': widget.orderId,
      'orderStatus': _orderDetails!['status'],
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }
}
}