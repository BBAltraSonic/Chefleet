import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../blocs/active_orders_bloc.dart';
import '../models/preparation_step_model.dart';
import '../models/order_preparation_state.dart';
import 'preparation_timer_widget.dart';
import 'preparation_steps_list.dart';
import '../../../core/utils/date_time_utils.dart';

class ActiveOrderModal extends StatefulWidget {
  const ActiveOrderModal({super.key});

  @override
  State<ActiveOrderModal> createState() => _ActiveOrderModalState();
}

class _ActiveOrderModalState extends State<ActiveOrderModal> {
  final Map<String, bool> _expandedSteps = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveOrdersBloc, ActiveOrdersState>(
      builder: (context, state) {
        final activeOrders = state.orders;

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.borderGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header with close button
                  _buildHeader(),
                  // Content
                  Expanded(
                    child: state.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : state.errorMessage != null
                            ? _buildErrorState(state.errorMessage!)
                            : activeOrders.isEmpty
                                ? _buildEmptyState()
                                : _buildActiveOrdersList(activeOrders, scrollController),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Active Orders',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
            tooltip: 'Close',
          ),
        ],
      ),
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

  Widget _buildActiveOrdersList(
    List<Map<String, dynamic>> activeOrders,
    ScrollController scrollController,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ActiveOrdersBloc>().refresh();
      },
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 24),
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
    final createdAt = DateTimeUtils.parse(order['created_at'] as String) ?? DateTime.now();
    final vendorName = order['vendors']?['business_name'] as String? ?? 'Vendor';
    final vendorLogo = order['vendors']?['logo_url'] as String?;
    final pickupCode = order['pickup_code'] as String?;
    
    final stepsData = context.read<ActiveOrdersBloc>().state.getPreparationSteps(orderId);
    final steps = stepsData.map((json) => PreparationStep.fromJson(json)).toList();
    final preparationState = steps.isNotEmpty
        ? OrderPreparationState(
            orderId: orderId,
            steps: steps,
            preparationStartedAt: DateTimeUtils.parse(order['preparation_started_at'] as String?),
            estimatedReadyAt: DateTimeUtils.parse(order['estimated_ready_at'] as String?),
          )
        : null;
    
    final isExpanded = _expandedSteps[orderId] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.borderGreen,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: vendorLogo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          child: Image.network(
                            vendorLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.restaurant, color: AppTheme.secondaryGreen);
                            },
                          ),
                        )
                      : Icon(Icons.restaurant, color: AppTheme.secondaryGreen),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order from $vendorName',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.darkText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (pickupCode != null)
                        Text(
                          'Pickup code: $pickupCode',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryGreen,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (preparationState != null && steps.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.borderGreen),
                ),
              ),
              child: Column(
                children: [
                  PreparationTimerWidget(
                    currentStep: preparationState.currentStep,
                    totalSteps: preparationState.totalStepsCount,
                    completedSteps: preparationState.completedStepsCount,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _expandedSteps[orderId] = !isExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isExpanded ? 'Hide steps' : 'View all steps',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: AppTheme.primaryGreen,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: 12),
                    PreparationStepsList(steps: steps),
                  ],
                ],
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.borderGreen),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimated time',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryGreen,
                    ),
                  ),
                  Text(
                    order['estimated_prep_time_minutes'] != null
                        ? '${order['estimated_prep_time_minutes']} minutes'
                        : '15 minutes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkText,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.borderGreen),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order total',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryGreen,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(totalAmount),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.darkText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Close modal and navigate to tracking
                    context.pop();
                    // TODO: Implement route overlay when ready
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Route tracking coming soon')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.darkText,
                    side: BorderSide(color: AppTheme.borderGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                  ),
                  child: const Text('Track Order'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _openChat(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.darkText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Chat'),
                ),
              ),
            ],
          ),
        ],
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
    context.pop();
    // TODO: Navigate to order details screen
    // For now, just close the modal
  }

  /// Opens the order-specific chat screen.
  /// 
  /// This is one of the primary entry points for chat functionality.
  /// Per Phase 4 of the navigation redesign, chat is ONLY accessible
  /// through order-specific routes (Active Orders, Order Detail, Order Confirmation).
  /// There is no global chat tab.
  void _openChat(Map<String, dynamic> order) {
    final orderId = order['id'] as String;
    final status = order['status'] as String? ?? 'pending';

    context.pop();
    context.push('${CustomerRoutes.chat}/$orderId?orderStatus=$status');
  }

  // Helper methods for enhanced order display
  String _formatDateTime(DateTime dateTime) {
    return DateTimeUtils.formatTimeAgo(dateTime);
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