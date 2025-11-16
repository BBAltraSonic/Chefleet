import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/payment_bloc.dart';
import '../widgets/payment_status_widget.dart';
import '../../order/blocs/order_bloc.dart';
import '../../../shared/widgets/glass_container.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _paymentProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, orderState) {
          orderState.when(
            paymentConfirmed: () {
              // Navigate to order confirmation
              _navigateToOrderConfirmation();
            },
            paymentFailed: (error) {
              setState(() {
                _paymentProcessing = false;
              });
              _showErrorDialog('Payment failed: $error');
            },
            // Handle other states
            idle: () {},
            loading: () {},
            success: () {},
            placing: () {},
            error: (errorMessage) {},
            paymentPending: () {},
            paymentProcessing: () {},
          );
        },
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, orderState) {
            return BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, paymentState) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order Summary
                            _buildOrderSummary(orderState),

                            const SizedBox(height: 24),

                            // Payment Method Selection
                            _buildPaymentSection(orderState, paymentState),

                            const SizedBox(height: 24),

                            // Special Instructions
                            _buildSpecialInstructions(orderState),

                            const SizedBox(height: 24),

                            // Order Details Review
                            _buildOrderDetails(orderState),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Action Area
                    _buildBottomAction(orderState, paymentState),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderSummary(orderState) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Items list
          ...orderState.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.dishName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (item.specialInstructions?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Note: ${item.specialInstructions}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  '${item.quantity}x \$${item.dishPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),

          const Divider(height: 32),

          // Price breakdown
          _buildPriceBreakdown(orderState),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(orderState) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal'),
            Text('\$${orderState.subtotal.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tax (8.75%)'),
            Text('\$${orderState.tax.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '\$${orderState.total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentSection(orderState, paymentState) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          if (orderState.paymentMethodId != null)
            _buildSelectedPaymentMethod(paymentState)
          else
            _buildPaymentMethodSelection(),

          const SizedBox(height: 16),

          // Payment status
          if (orderState.requiresPayment)
            PaymentStatusWidget(
              status: _mapOrderStatusToPaymentStatus(orderState.status),
              message: orderState.paymentError,
              onRetry: () => _retryPayment(),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedPaymentMethod(paymentState) {
    return paymentState.when(
      paymentMethodsLoaded: (paymentMethods) {
        final selectedMethod = paymentMethods
            .where((method) => method.stripePaymentMethodId ==
                   context.read<OrderBloc>().state.paymentMethodId)
            .firstOrNull;

        if (selectedMethod != null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.credit_card,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedMethod.displayText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _selectPaymentMethod,
                  child: const Text('Change'),
                ),
              ],
            ),
          );
        }

        return _buildPaymentMethodSelection();
      },
      // Handle other payment states
      initial: () => _buildPaymentMethodSelection(),
      loading: () => const Center(child: CircularProgressIndicator()),
      processing: () => _buildPaymentMethodSelection(),
      loaded: () => _buildPaymentMethodSelection(),
      paymentMethodAdded: (paymentMethod, allPaymentMethods) =>
          _buildPaymentMethodSelection(),
      paymentMethodRemoved: (paymentMethods) =>
          _buildPaymentMethodSelection(),
      defaultPaymentMethodSet: (paymentMethods) =>
          _buildPaymentMethodSelection(),
      error: (message) => _buildPaymentMethodSelection(),
      paymentIntentCreated: (clientSecret, paymentIntentId) =>
          _buildPaymentMethodSelection(),
      requiresAction: (clientSecret, paymentIntentId, nextAction) =>
          _buildPaymentMethodSelection(),
      paymentConfirmed: () => _buildPaymentMethodSelection(),
      walletLoaded: (wallet) => _buildPaymentMethodSelection(),
      walletTransactionsLoaded: (transactions) =>
          _buildPaymentMethodSelection(),
      paymentSettingsLoaded: (settings) => _buildPaymentMethodSelection(),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return InkWell(
      onTap: _selectPaymentMethod,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Select Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialInstructions(orderState) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Instructions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            initialValue: orderState.specialInstructions,
            onChanged: (value) {
              context.read<OrderBloc>().updateSpecialInstructions(value);
            },
            decoration: const InputDecoration(
              hintText: 'Add any special requests or notes for the vendor...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(orderState) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pickup Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          if (orderState.pickupTime != null) ...[
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Pickup Time',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${orderState.pickupTime!.hour.toString().padLeft(2, '0')}:${orderState.pickupTime!.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ] else ...[
            InkWell(
              onTap: _selectPickupTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Select Pickup Time',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomAction(orderState, paymentState) {
    return GlassContainer(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show payment processing indicator
            if (_paymentProcessing || orderState.isPlacingOrder) ...[
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _paymentProcessing ? 'Processing Payment...' : 'Placing Order...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Place Order button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_paymentProcessing || orderState.isPlacingOrder)
                    ? null
                    : _canPlaceOrder(orderState)
                        ? _placeOrder
                        : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Place Order • \$${orderState.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canPlaceOrder(orderState) {
    return orderState.isValid &&
           orderState.isPaymentReady &&
           !_paymentProcessing &&
           !orderState.isPlacingOrder;
  }

  PaymentStatus _mapOrderStatusToPaymentStatus(OrderStatus orderStatus) {
    switch (orderStatus) {
      case OrderStatus.paymentProcessing:
        return PaymentStatus.processing;
      case OrderStatus.paymentFailed:
        return PaymentStatus.failed;
      case OrderStatus.paymentConfirmed:
        return PaymentStatus.succeeded;
      case OrderStatus.paymentPending:
        return PaymentStatus.pending;
      default:
        return PaymentStatus.pending;
    }
  }

  void _selectPaymentMethod() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<PaymentBloc>(),
          child: PaymentMethodSelectionScreen(
            orderId: 'temp_order_id', // This would come from the order state
            amount: context.read<OrderBloc>().state.total,
            onPaymentMethodSelected: (paymentMethodId) {
              context.read<OrderBloc>().selectPaymentMethod(paymentMethodId);
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  void _selectPickupTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final now = DateTime.now();
      final pickupTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      context.read<OrderBloc>().setPickupTime(pickupTime);
    }
  }

  void _placeOrder() {
    setState(() {
      _paymentProcessing = true;
    });

    // Start payment process
    context.read<OrderBloc>().startPayment();

    // Trigger payment intent creation through PaymentBloc
    final orderState = context.read<OrderBloc>().state;
    context.read<PaymentBloc>().add(
      PaymentEvent.paymentIntentCreated(
        orderId: 'temp_order_id', // This would be generated or retrieved
        paymentMethodId: orderState.paymentMethodId,
        useSavedMethod: true,
      ),
    );
  }

  void _retryPayment() {
    _placeOrder();
  }

  void _navigateToOrderConfirmation() {
    setState(() {
      _paymentProcessing = false;
    });

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/order-confirmation',
      (route) => false,
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}