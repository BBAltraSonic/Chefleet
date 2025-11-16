import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_container.dart';

enum PaymentStatus {
  pending,
  processing,
  succeeded,
  failed,
  cancelled,
  refunded,
}

class PaymentStatusWidget extends StatelessWidget {
  final PaymentStatus status;
  final String? message;
  final Function()? onRetry;
  final bool showDetails;

  const PaymentStatusWidget({
    super.key,
    required this.status,
    this.message,
    this.onRetry,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildStatusIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        message!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (status == PaymentStatus.processing)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                  ),
                ),
            ],
          ),

          if (showDetails) ...[
            const SizedBox(height: 16),
            _buildStatusDetails(),
          ],

          if (onRetry != null && status == PaymentStatus.failed) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _getStatusColor()),
                ),
                child: Text(
                  'Retry Payment',
                  style: TextStyle(color: _getStatusColor()),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData iconData;
    Color color;

    switch (status) {
      case PaymentStatus.pending:
        iconData = Icons.pending_outlined;
        color = Colors.orange;
        break;
      case PaymentStatus.processing:
        iconData = Icons.payment;
        color = Colors.blue;
        break;
      case PaymentStatus.succeeded:
        iconData = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case PaymentStatus.failed:
        iconData = Icons.error_outline;
        color = Colors.red;
        break;
      case PaymentStatus.cancelled:
        iconData = Icons.cancel_outlined;
        color = Colors.grey;
        break;
      case PaymentStatus.refunded:
        iconData = Icons.replay_outlined;
        color = Colors.purple;
        break;
    }

    return Icon(
      iconData,
      color: color,
      size: 24,
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.succeeded:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      case PaymentStatus.refunded:
        return Colors.purple;
    }
  }

  String _getStatusTitle() {
    switch (status) {
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.processing:
        return 'Processing Payment';
      case PaymentStatus.succeeded:
        return 'Payment Successful';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.cancelled:
        return 'Payment Cancelled';
      case PaymentStatus.refunded:
        return 'Payment Refunded';
    }
  }

  Widget _buildStatusDetails() {
    String description;

    switch (status) {
      case PaymentStatus.pending:
        description = 'Your payment is pending confirmation. This usually takes a few seconds.';
        break;
      case PaymentStatus.processing:
        description = 'We\'re processing your payment securely with Stripe. Please wait...';
        break;
      case PaymentStatus.succeeded:
        description = 'Your payment has been processed successfully. You will receive a confirmation email shortly.';
        break;
      case PaymentStatus.failed:
        description = 'We couldn\'t process your payment. Please check your payment details and try again.';
        break;
      case PaymentStatus.cancelled:
        description = 'This payment has been cancelled. No charges were made to your account.';
        break;
      case PaymentStatus.refunded:
        description = 'This payment has been refunded. The refund should appear in your account within 5-7 business days.';
        break;
    }

    return Text(
      description,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
    );
  }
}

class PaymentStatusIndicator extends StatelessWidget {
  final PaymentStatus status;
  final double size;

  const PaymentStatusIndicator({
    super.key,
    required this.status,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
      ),
      child: status == PaymentStatus.processing
          ? SizedBox(
              width: size * 0.6,
              height: size * 0.6,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(
              _getStatusIcon(),
              color: Colors.white,
              size: size * 0.6,
            ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.succeeded:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      case PaymentStatus.refunded:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case PaymentStatus.succeeded:
        return Icons.check;
      case PaymentStatus.failed:
        return Icons.close;
      case PaymentStatus.cancelled:
        return Icons.close;
      case PaymentStatus.refunded:
        return Icons.keyboard_double_arrow_down;
      default:
        return Icons.circle;
    }
  }
}