import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';
import '../blocs/active_orders_bloc.dart';
import '../../chat/screens/chat_detail_screen.dart';

class ActiveOrderModal extends StatefulWidget {
  const ActiveOrderModal({super.key});

  @override
  State<ActiveOrderModal> createState() => _ActiveOrderModalState();
}

class _ActiveOrderModalState extends State<ActiveOrderModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveOrdersBloc, ActiveOrdersState>(
      builder: (context, state) {
        final activeOrders = state.orders;

        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(20),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: GlassContainer(
                    borderRadius: 20,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 20),
                          if (state.isLoading)
                            const CircularProgressIndicator()
                          else if (state.errorMessage != null)
                            _buildErrorState(state.errorMessage!)
                          else if (activeOrders.isEmpty)
                            _buildEmptyState()
                          else
                            _buildActiveOrdersList(activeOrders),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Active Orders',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.withOpacity(0.1),
            foregroundColor: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load orders',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => context.read<ActiveOrdersBloc>().refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No active orders',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your active orders will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrdersList(List<Map<String, dynamic>> activeOrders) {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: activeOrders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = activeOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['id'] as String;
    final status = order['status'] as String? ?? 'pending';
    final totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
    final createdAt = DateTime.parse(order['created_at'] as String);
    final updatedAt = order['updated_at'] != null
        ? DateTime.parse(order['updated_at'] as String)
        : createdAt;
    final vendorName = order['vendors']?['business_name'] as String? ?? 'Vendor';
    final vendorAddress = order['vendors']?['address'] as String? ?? 'Address not available';
    final pickupCode = order['pickup_code'] as String?;
    final items = order['items'] as List<dynamic>? ?? [];
    final specialInstructions = order['special_instructions'] as String?;

    return GlassContainer(
      borderRadius: 16,
      opacity: 0.1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with vendor name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    vendorName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 8),

            // Order ID and time
            Text(
              'Order #${orderId.substring(0, 8).toUpperCase()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Placed ${_formatDateTime(createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),

            // Total amount
            Text(
              '\$${totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            // Order status timeline
            const SizedBox(height: 12),
            _buildOrderTimeline(status, createdAt, updatedAt),

            // Pickup code (if available and order is ready)
            if (pickupCode != null && status == 'ready') ...[
              const SizedBox(height: 12),
              _buildPickupCodeSection(pickupCode),
            ],

            // Vendor location
            const SizedBox(height: 12),
            _buildVendorLocationSection(vendorAddress),

            // Items preview
            if (items.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildOrderItemsPreview(items),
            ],

            // Special instructions (if any)
            if (specialInstructions != null && specialInstructions.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSpecialInstructionsSection(specialInstructions),
            ],

            // Action buttons
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewOrderDetails(order),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openChat(order),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.chat_outlined, size: 16),
                    label: const Text('Chat'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        displayText = 'Pending';
        break;
      case 'accepted':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        displayText = 'Accepted';
        break;
      case 'preparing':
        backgroundColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        displayText = 'Preparing';
        break;
      case 'ready':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        displayText = 'Ready';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _viewOrderDetails(Map<String, dynamic> order) {
    Navigator.of(context).pop();
    // TODO: Navigate to order details screen
    // For now, just close the modal
  }

  void _openChat(Map<String, dynamic> order) {
    final orderId = order['id'] as String;
    final status = order['status'] as String? ?? 'pending';

    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          orderId: orderId,
          orderStatus: status,
        ),
      ),
    );
  }

  // Helper methods for enhanced order display
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }

  Widget _buildOrderTimeline(String status, DateTime createdAt, DateTime updatedAt) {
    final List<Map<String, dynamic>> timelineSteps = [
      {'status': 'pending', 'title': 'Order Placed', 'completed': true, 'time': createdAt},
    ];

    // Add steps based on current status
    if (['accepted', 'preparing', 'ready', 'completed'].contains(status)) {
      timelineSteps.add({
        'status': 'accepted',
        'title': 'Order Accepted',
        'completed': true,
        'time': updatedAt, // This would be the actual acceptance time in a real implementation
      });
    }

    if (['preparing', 'ready', 'completed'].contains(status)) {
      timelineSteps.add({
        'status': 'preparing',
        'title': 'Preparing',
        'completed': status == 'preparing' || status == 'ready' || status == 'completed',
        'time': status == 'preparing' ? updatedAt : null,
      });
    }

    if (['ready', 'completed'].contains(status)) {
      timelineSteps.add({
        'status': 'ready',
        'title': 'Ready for Pickup',
        'completed': status == 'ready' || status == 'completed',
        'time': status == 'ready' ? updatedAt : null,
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Progress',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        ...timelineSteps.map((step) => _buildTimelineStep(step)).toList(),
      ],
    );
  }

  Widget _buildTimelineStep(Map<String, dynamic> step) {
    final isCompleted = step['completed'] as bool;
    final isCurrentStep = !isCompleted && step['time'] != null;
    final time = step['time'] as DateTime?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : isCurrentStep
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300],
              shape: BoxShape.circle,
              border: isCurrentStep
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                  : null,
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 10)
                : null,
          ),
          const SizedBox(width: 12),

          // Step details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['title'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isCompleted || isCurrentStep
                        ? Colors.black87
                        : Colors.grey[500],
                    fontWeight: isCurrentStep ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (time != null)
                  Text(
                    _formatDateTime(time),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCodeSection(String pickupCode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.qr_code,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickup Code',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  pickupCode,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorLocationSection(String vendorAddress) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            vendorAddress,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemsPreview(List<dynamic> items) {
    final displayItems = items.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Items',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        ...displayItems.map((item) {
          final dish = item['dishes'] as Map<String, dynamic>? ?? {};
          final quantity = item['quantity'] as int? ?? 1;
          final name = dish['name'] as String? ?? 'Item';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$quantity × $name',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        if (items.length > 3) ...[
          const SizedBox(height: 2),
          Text(
            '+${items.length - 3} more items',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecialInstructionsSection(String instructions) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              instructions,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}