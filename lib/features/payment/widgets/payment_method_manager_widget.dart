import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../blocs/payment_bloc.dart';
import '../../../core/models/payment_method.dart';
import '../../../shared/widgets/glass_container.dart';

class PaymentMethodManagerWidget extends StatefulWidget {
  final Function(PaymentMethod)? onPaymentMethodSelected;
  final bool allowSelection;
  final String? selectedPaymentMethodId;

  const PaymentMethodManagerWidget({
    super.key,
    this.onPaymentMethodSelected,
    this.allowSelection = false,
    this.selectedPaymentMethodId,
  });

  @override
  State<PaymentMethodManagerWidget> createState() => _PaymentMethodManagerWidgetState();
}

class _PaymentMethodManagerWidgetState extends State<PaymentMethodManagerWidget> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(const PaymentEvent.paymentMethodsLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          processing: () => _buildContent([]),
          loaded: () => _buildEmptyState(),
          paymentMethodsLoaded: (paymentMethods) => _buildContent(paymentMethods),
          paymentMethodAdded: (paymentMethod, allPaymentMethods) =>
              _buildContent(allPaymentMethods),
          paymentMethodRemoved: (paymentMethods) => _buildContent(paymentMethods),
          defaultPaymentMethodSet: (paymentMethods) => _buildContent(paymentMethods),
          error: (message) => _buildErrorState(message),
          paymentIntentCreated: (clientSecret, paymentIntentId) =>
              _buildContent([]),
          requiresAction: (clientSecret, paymentIntentId, nextAction) =>
              _buildContent([]),
          paymentConfirmed: () => _buildContent([]),
          walletLoaded: (wallet) => const SizedBox.shrink(),
          walletTransactionsLoaded: (transactions) => const SizedBox.shrink(),
          paymentSettingsLoaded: (settings) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildContent(List<PaymentMethod> paymentMethods) {
    if (paymentMethods.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Methods',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: _addNewPaymentMethod,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        ...paymentMethods.map((paymentMethod) => _buildPaymentMethodCard(paymentMethod)),

        const SizedBox(height: 16),

        _buildSecurityNotice(),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod paymentMethod) {
    final isSelected = widget.selectedPaymentMethodId == paymentMethod.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () => _handlePaymentMethodTap(paymentMethod),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Payment method icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _getPaymentMethodIcon(paymentMethod.type),
              ),

              const SizedBox(width: 16),

              // Payment method details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            paymentMethod.displayText,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (paymentMethod.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Default',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (paymentMethod.type == 'card' &&
                        paymentMethod.expiryMonth != null &&
                        paymentMethod.expiryYear != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Expires ${paymentMethod.expiryMonth.toString().padLeft(2, '0')}/${paymentMethod.expiryYear.toString().substring(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.allowSelection) ...[
                    Radio<String>(
                      value: paymentMethod.id,
                      groupValue: widget.selectedPaymentMethodId,
                      onChanged: (_) => _handlePaymentMethodTap(paymentMethod),
                    ),
                  ] else ...[
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onSelected: (value) => _handleMenuAction(value, paymentMethod),
                      itemBuilder: (context) => [
                        if (!paymentMethod.isDefault)
                          const PopupMenuItem(
                            value: 'set_default',
                            child: Row(
                              children: [
                                Icon(Icons.star_border, size: 18),
                                SizedBox(width: 12),
                                Text('Set as Default'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Remove', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.credit_card_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Text(
          'No Payment Methods',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add a payment method to make checkout faster and easier',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: _addNewPaymentMethod,
            icon: const Icon(Icons.add),
            label: const Text('Add Payment Method'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Payment Methods',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PaymentBloc>().add(const PaymentEvent.paymentMethodsLoaded());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            Icons.security,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your payment information is encrypted and securely stored by Stripe.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPaymentMethodIcon(String type) {
    switch (type) {
      case 'card':
        return Icon(
          FontAwesomeIcons.creditCard,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        );
      case 'apple_pay':
        return Icon(
          FontAwesomeIcons.apple,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        );
      case 'google_pay':
        return Icon(
          FontAwesomeIcons.google,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        );
      default:
        return Icon(
          Icons.payment,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        );
    }
  }

  void _handlePaymentMethodTap(PaymentMethod paymentMethod) {
    if (widget.allowSelection && widget.onPaymentMethodSelected != null) {
      widget.onPaymentMethodSelected!(paymentMethod);
    } else {
      // Show payment method details or actions
      _showPaymentMethodDetails(paymentMethod);
    }
  }

  void _handleMenuAction(String action, PaymentMethod paymentMethod) {
    switch (action) {
      case 'set_default':
        _confirmSetDefault(paymentMethod);
        break;
      case 'remove':
        _confirmRemovePaymentMethod(paymentMethod);
        break;
    }
  }

  void _addNewPaymentMethod() {
    Navigator.of(context).pushNamed('/add-payment-method');
  }

  void _showPaymentMethodDetails(PaymentMethod paymentMethod) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildPaymentMethodBottomSheet(paymentMethod),
    );
  }

  Widget _buildPaymentMethodBottomSheet(PaymentMethod paymentMethod) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getPaymentMethodIcon(paymentMethod.type),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMethod.displayText,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (paymentMethod.isDefault) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Default payment method',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (paymentMethod.type == 'card' &&
              paymentMethod.expiryMonth != null &&
              paymentMethod.expiryYear != null) ...[
            Text(
              'Expiry Date',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${paymentMethod.expiryMonth.toString().padLeft(2, '0')}/${paymentMethod.expiryYear.toString()}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],

          Text(
            'Added on',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${paymentMethod.createdAt.day}/${paymentMethod.createdAt.month}/${paymentMethod.createdAt.year}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 24),

          if (!paymentMethod.isDefault)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _confirmSetDefault(paymentMethod);
                },
                child: const Text('Set as Default'),
              ),
            ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmRemovePaymentMethod(paymentMethod);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Remove Payment Method'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSetDefault(PaymentMethod paymentMethod) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set as Default'),
        content: Text('Do you want to set ${paymentMethod.displayText} as your default payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PaymentBloc>().add(
                PaymentEvent.defaultPaymentMethodSet(
                  paymentMethodId: paymentMethod.id,
                ),
              );
            },
            child: const Text('Set Default'),
          ),
        ],
      ),
    );
  }

  void _confirmRemovePaymentMethod(PaymentMethod paymentMethod) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Payment Method'),
        content: Text('Are you sure you want to remove ${paymentMethod.displayText}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PaymentBloc>().add(
                PaymentEvent.paymentMethodRemoved(
                  paymentMethodId: paymentMethod.id,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}