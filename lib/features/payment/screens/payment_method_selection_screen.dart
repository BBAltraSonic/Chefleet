import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/payment_bloc.dart';
import '../../../core/models/payment_method.dart';
import '../../../shared/widgets/glass_container.dart';

class PaymentMethodSelectionScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final Function(String)? onPaymentMethodSelected;
  final Function()? onAddNewPaymentMethod;

  const PaymentMethodSelectionScreen({
    super.key,
    required this.orderId,
    required this.amount,
    this.onPaymentMethodSelected,
    this.onAddNewPaymentMethod,
  });

  @override
  State<PaymentMethodSelectionScreen> createState() => _PaymentMethodSelectionScreenState();
}

class _PaymentMethodSelectionScreenState extends State<PaymentMethodSelectionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(const PaymentEvent.paymentMethodsLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Select Payment Method'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            processing: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing payment...'),
                ],
              ),
            ),
            loaded: () => const Center(
              child: Text('No payment methods found'),
            ),
            paymentMethodsLoaded: (paymentMethods) => _buildPaymentMethodsList(paymentMethods),
            paymentMethodAdded: (paymentMethod, allPaymentMethods) =>
                _buildPaymentMethodsList(allPaymentMethods),
            paymentMethodRemoved: (paymentMethods) => _buildPaymentMethodsList(paymentMethods),
            defaultPaymentMethodSet: (paymentMethods) => _buildPaymentMethodsList(paymentMethods),
            error: (message) => Center(
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
                    'Error loading payment methods',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PaymentBloc>().add(const PaymentEvent.paymentMethodsLoaded());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            paymentIntentCreated: (clientSecret, paymentIntentId) =>
                _buildPaymentSuccessWidget(),
            requiresAction: (clientSecret, paymentIntentId, nextAction) =>
                _buildActionRequiredWidget(),
            paymentConfirmed: () => _buildPaymentSuccessWidget(),
            walletLoaded: (wallet) => const SizedBox.shrink(),
            walletTransactionsLoaded: (transactions) => const SizedBox.shrink(),
            paymentSettingsLoaded: (settings) => const SizedBox.shrink(),
          );
        },
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildPaymentMethodsList(List<PaymentMethod> paymentMethods) {
    return Column(
      children: [
        // Amount display
        GlassContainer(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '\$${widget.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        // Payment methods list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: paymentMethods.length + 1, // +1 for "Add new card" option
            itemBuilder: (context, index) {
              if (index == paymentMethods.length) {
                return _buildAddNewPaymentMethodCard();
              }

              final paymentMethod = paymentMethods[index];
              return _buildPaymentMethodCard(paymentMethod);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod paymentMethod) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () => _selectPaymentMethod(paymentMethod),
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
                    Text(
                      paymentMethod.displayText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (paymentMethod.isDefault) ...[
                      const SizedBox(height: 4),
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
              ),

              // Selection radio button
              Radio<String>(
                value: paymentMethod.id,
                groupValue: null, // This will be managed by parent
                onChanged: (_) => _selectPaymentMethod(paymentMethod),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewPaymentMethodCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: _addNewPaymentMethod,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  'Add New Payment Method',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getPaymentMethodIcon(String type) {
    switch (type) {
      case 'card':
        return Icon(
          Icons.credit_card,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        );
      case 'apple_pay':
        return Icon(
          Icons.apple,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        );
      case 'google_pay':
        return Icon(
          Icons.android,
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

  Widget _buildBottomAction() {
    return GlassContainer(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                final isProcessing = state.maybeWhen(
                  processing: () => true,
                  orElse: () => false,
                );

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isProcessing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Processing...'),
                            ],
                          )
                        : const Text(
                            'Continue to Payment',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            Text(
              'Payment secured by Stripe',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSuccessWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Payment Successful!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your order has been confirmed.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRequiredWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Additional Authentication Required',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please complete the authentication in the pop-up to continue.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _selectPaymentMethod(PaymentMethod paymentMethod) {
    if (widget.onPaymentMethodSelected != null) {
      widget.onPaymentMethodSelected!(paymentMethod.id);
    } else {
      // Default behavior: create payment intent
      context.read<PaymentBloc>().add(
        PaymentEvent.paymentIntentCreated(
          orderId: widget.orderId,
          paymentMethodId: paymentMethod.stripePaymentMethodId,
          useSavedMethod: true,
        ),
      );
    }
  }

  void _addNewPaymentMethod() {
    if (widget.onAddNewPaymentMethod != null) {
      widget.onAddNewPaymentMethod!();
    } else {
      // Navigate to add payment method screen
      Navigator.of(context).pushNamed('/add-payment-method');
    }
  }

  void _processPayment() {
    // This would be called after a payment method is selected
    // The actual payment processing is handled by the BLoC
    context.read<PaymentBloc>().add(
      PaymentEvent.paymentIntentCreated(
        orderId: widget.orderId,
      ),
    );
  }
}