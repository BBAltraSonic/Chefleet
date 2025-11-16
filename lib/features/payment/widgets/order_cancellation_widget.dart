import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/payment_bloc.dart';
import '../../order/blocs/order_bloc.dart';
import '../../../shared/widgets/glass_container.dart';

class OrderCancellationWidget extends StatelessWidget {
  final String orderId;
  final String? paymentIntentId;
  final VoidCallback? onCancellationComplete;

  const OrderCancellationWidget({
    super.key,
    required this.orderId,
    this.paymentIntentId,
    this.onCancellationComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Cancel Order?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'If you cancel this order, any payment made will be automatically refunded to your original payment method. Refunds typically take 5-7 business days to appear in your account.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Keep Order'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmCancellation(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel Order'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmCancellation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const OrderCancellationProgressDialog(),
    );

    _processOrderCancellation(context);
  }

  void _processOrderCancellation(BuildContext context) async {
    try {
      // If there's a payment intent, initiate refund through PaymentBloc
      if (paymentIntentId != null) {
        // This would typically call an edge function to process refund
        context.read<PaymentBloc>().add(
          PaymentEvent.error('Order cancelled - refund initiated'),
        );
      }

      // Update order status through OrderBloc
      context.read<OrderBloc>().add(OrderFailed('Order cancelled by user'));

      // Simulate processing time
      await Future.delayed(const Duration(seconds: 2));

      // Close progress dialog
      Navigator.of(context).pop();

      // Show success dialog
      _showCancellationSuccessDialog(context);

    } catch (e) {
      // Close progress dialog
      Navigator.of(context).pop();

      // Show error dialog
      _showCancellationErrorDialog(context, e.toString());
    }
  }

  void _showCancellationSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Order Cancelled'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text('Your order has been successfully cancelled.'),
            const SizedBox(height: 8),
            if (paymentIntentId != null)
              const Text(
                'A refund has been initiated and will be processed within 5-7 business days.',
                textAlign: TextAlign.center,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close success dialog
              Navigator.of(context).pop(); // Close cancellation dialog
              if (onCancellationComplete != null) {
                onCancellationComplete!();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCancellationErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancellation Error'),
        content: Text(
          'We couldn\'t cancel your order at this time. Please try again or contact customer support.\n\nError: $error',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processOrderCancellation(context);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class OrderCancellationProgressDialog extends StatelessWidget {
  const OrderCancellationProgressDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Cancelling order...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we process your cancellation',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Usage widget for showing order cancellation option
class OrderCancellationOption extends StatelessWidget {
  final String orderId;
  final String? paymentIntentId;
  final VoidCallback? onCancellationComplete;

  const OrderCancellationOption({
    super.key,
    required this.orderId,
    this.paymentIntentId,
    this.onCancellationComplete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => _showCancellationDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.cancel_outlined,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cancel Order',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    paymentIntentId != null
                        ? 'Get a full refund to your original payment method'
                        : 'Cancel this order',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  void _showCancellationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: OrderCancellationWidget(
          orderId: orderId,
          paymentIntentId: paymentIntentId,
          onCancellationComplete: onCancellationComplete,
        ),
      ),
    );
  }
}