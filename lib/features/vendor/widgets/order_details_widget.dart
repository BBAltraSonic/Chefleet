import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../blocs/order_management_bloc.dart';

class OrderDetailsWidget extends StatefulWidget {
  final String orderId;
  final VoidCallback onClose;

  const OrderDetailsWidget({
    super.key,
    required this.orderId,
    required this.onClose,
  });

  @override
  State<OrderDetailsWidget> createState() => _OrderDetailsWidgetState();
}

class _OrderDetailsWidgetState extends State<OrderDetailsWidget> {
  Map<String, dynamic>? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseClient = Supabase.instance.client;
      final response = await supabaseClient
          .from('orders')
          .select('''
            *,
            customer:customers!orders_customer_id_fkey (
              id,
              name,
              phone,
              email
            ),
            order_items (
              id,
              dish_id,
              quantity,
              price_cents,
              special_instructions,
              dishes (
                id,
                name,
                description,
                image_url,
                category_enum
              )
            )
          ''')
          .eq('id', widget.orderId)
          .single();

      setState(() {
        _order = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_order == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64),
            const SizedBox(height: 16),
            Text(
              'Order not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onClose,
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Order Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // Order Details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Status and Actions
                  _buildStatusSection(context),

                  const SizedBox(height: 24),

                  // Customer Information
                  _buildCustomerSection(context),

                  const SizedBox(height: 24),

                  // Order Items
                  _buildOrderItemsSection(context),

                  const SizedBox(height: 24),

                  // Timing Information
                  _buildTimingSection(context),

                  const SizedBox(height: 24),

                  // Notes Section
                  _buildNotesSection(context),

                  const SizedBox(height: 24), // Space before action buttons
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    final status = _order!['status'] as String? ?? 'pending';
    final statusColor = Color(
      int.parse(
        OrderManagementState.getStatusColor(status).substring(1),
        radix: 16,
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: statusColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      OrderManagementState.getStatusDisplayName(status),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusTimeline(context, status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(BuildContext context, String currentStatus) {
    final statuses = ['pending', 'confirmed', 'preparing', 'ready', 'completed'];
    final currentIndex = statuses.indexOf(currentStatus.toLowerCase());
    
    return Column(
      children: List.generate(statuses.length, (index) {
        final status = statuses[index];
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final statusColor = isCompleted ? Colors.green : Colors.grey;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted ? statusColor : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(
                          isCurrent ? _getStatusIcon(status) : Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                if (index < statuses.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? statusColor : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  OrderManagementState.getStatusDisplayName(status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCustomerSection(BuildContext context) {
    final customer = _order!['customer'] as Map<String, dynamic>?;
    final customerName = customer?['name'] as String? ?? 'Unknown Customer';
    final customerPhone = customer?['phone'] as String?;
    final customerEmail = customer?['email'] as String?;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Name'),
              subtitle: Text(customerName),
            ),
            if (customerPhone != null)
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: Text(customerPhone),
                trailing: IconButton(
                  onPressed: () {
                    // Make phone call functionality
                  },
                  icon: const Icon(Icons.call),
                  tooltip: 'Call customer',
                ),
              ),
            if (customerEmail != null)
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(customerEmail),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsSection(BuildContext context) {
    final orderItems = _order!['order_items'] as List<dynamic>? ?? [];
    final totalAmount = (_order!['total_amount'] as num?)?.toDouble() ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items (${orderItems.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...orderItems.map((item) {
              final itemData = item as Map<String, dynamic>;
              final dish = itemData['dishes'] as Map<String, dynamic>?;
              final dishName = dish?['name'] as String? ?? 'Unknown item';
              final dishDescription = dish?['description'] as String?;
              final dishImageUrl = dish?['image_url'] as String?;
              final quantity = itemData['quantity'] as int? ?? 1;
              final priceCents = itemData['price_cents'] as int? ?? 0;
              final specialInstructions = itemData['special_instructions'] as String?;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dish Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: dishImageUrl != null
                          ? Image.network(
                              dishImageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Theme.of(context).colorScheme.surfaceVariant,
                                  child: const Icon(Icons.restaurant),
                                );
                              },
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              child: const Icon(Icons.restaurant),
                            ),
                    ),

                    const SizedBox(width: 12),

                    // Item Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dishName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (dishDescription != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              dishDescription,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (specialInstructions != null && specialInstructions.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Note: $specialInstructions',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Quantity and Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'x$quantity',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(priceCents * quantity / 100),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(totalAmount),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingSection(BuildContext context) {
    final createdAt = DateTime.tryParse(_order!['created_at'] ?? '');
    final pickupTime = DateTime.tryParse(_order!['pickup_time'] ?? '');
    final estimatedPrepTime = _order!['estimated_prep_time_minutes'] as int?;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timing Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (createdAt != null)
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Order Time'),
                subtitle: Text(_formatDateTime(createdAt)),
              ),
            if (pickupTime != null)
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Pickup Time'),
                subtitle: Text(_formatDateTime(pickupTime)),
              ),
            if (estimatedPrepTime != null)
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Estimated Prep Time'),
                subtitle: Text('$estimatedPrepTime minutes'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final vendorNotes = _order!['vendor_notes'] as String?;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (vendorNotes != null && vendorNotes.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(vendorNotes),
              )
            else
              Text(
                'No notes added',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAddNoteDialog(context),
                icon: const Icon(Icons.note_add),
                label: const Text('Add Note'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final status = _order!['status'] as String? ?? 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status-specific action buttons
          if (status == 'pending') ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAcceptOrderDialog(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Accept Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectOrderDialog(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (status == 'confirmed') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<OrderManagementBloc>().add(
                    StartOrderPreparation(orderId: widget.orderId),
                  );
                },
                icon: const Icon(Icons.restaurant),
                label: const Text('Start Preparation'),
              ),
            ),
          ] else if (status == 'preparing') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<OrderManagementBloc>().add(
                    MarkOrderReady(orderId: widget.orderId),
                  );
                },
                icon: const Icon(Icons.notifications_active),
                label: const Text('Mark Ready for Pickup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ] else if (status == 'ready') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<OrderManagementBloc>().add(
                    CompleteOrder(orderId: widget.orderId),
                  );
                },
                icon: const Icon(Icons.done_all),
                label: const Text('Complete Order'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAcceptOrderDialog(BuildContext context) {
    final prepTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Estimated preparation time:'),
            const SizedBox(height: 16),
            TextField(
              controller: prepTimeController,
              decoration: const InputDecoration(
                labelText: 'Minutes',
                border: OutlineInputBorder(),
                hintText: 'Enter preparation time in minutes',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final prepTime = int.tryParse(prepTimeController.text) ?? 15;
              context.read<OrderManagementBloc>().add(
                AcceptOrder(
                  orderId: widget.orderId,
                  estimatedPrepTime: prepTime,
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showRejectOrderDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
                hintText: 'Enter rejection reason',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                context.read<OrderManagementBloc>().add(
                  RejectOrder(
                    orderId: widget.orderId,
                    reason: reasonController.text.trim(),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Order Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: 'Note',
            border: OutlineInputBorder(),
            hintText: 'Enter your note',
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (noteController.text.trim().isNotEmpty) {
                context.read<OrderManagementBloc>().add(
                  AddOrderNote(
                    orderId: widget.orderId,
                    note: noteController.text.trim(),
                    isInternal: true,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add Note'),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'confirmed':
        return Icons.check_circle;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.notifications_active;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      case 'rejected':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}