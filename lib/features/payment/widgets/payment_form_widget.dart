import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../blocs/payment_bloc.dart';
import '../../../shared/widgets/glass_container.dart';

class PaymentFormWidget extends StatefulWidget {
  final String orderId;
  final double amount;
  final bool savePaymentMethod;
  final Function(String)? onPaymentMethodCreated;

  const PaymentFormWidget({
    super.key,
    required this.orderId,
    required this.amount,
    this.savePaymentMethod = false,
    this.onPaymentMethodCreated,
  });

  @override
  State<PaymentFormWidget> createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends State<PaymentFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late CardFieldCardDetails _cardDetails;
  bool _isProcessing = false;
  bool _savePaymentMethod = false;

  @override
  void initState() {
    super.initState();
    _savePaymentMethod = widget.savePaymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Payment Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          state.when(
            requiresAction: (clientSecret, paymentIntentId, nextAction) {
              _handleNextAction(clientSecret);
            },
            paymentConfirmed: () {
              _showPaymentSuccessDialog();
            },
            error: (message) {
              _showErrorDialog(message);
            },
            paymentMethodAdded: (paymentMethod, allPaymentMethods) {
              if (widget.onPaymentMethodCreated != null) {
                widget.onPaymentMethodCreated!(paymentMethod.id);
                Navigator.of(context).pop();
              }
            },
            // Handle other states as needed
            initial: () {},
            loading: () {},
            processing: () {},
            loaded: () {},
            paymentIntentCreated: (clientSecret, paymentIntentId) {},
            paymentMethodsLoaded: (paymentMethods) {},
            paymentMethodRemoved: (paymentMethods) {},
            defaultPaymentMethodSet: (paymentMethods) {},
            walletLoaded: (wallet) {},
            walletTransactionsLoaded: (transactions) {},
            paymentSettingsLoaded: (settings) {},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Amount display
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Order Total',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${widget.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Card Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stripe Card Field
                      GlassContainer(
                        padding: const EdgeInsets.all(4),
                        child: CardField(
                          onCardChanged: (card) {
                            _cardDetails = card!;
                          },
                          decoration: InputDecoration(
                            hintText: 'Card Number',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Save payment method checkbox
                      CheckboxListTile(
                        title: const Text('Save payment method for future orders'),
                        subtitle: const Text('Your card information will be securely stored'),
                        value: _savePaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _savePaymentMethod = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),

                      const Spacer(),

                      // Security notice
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your payment information is encrypted and secure. Powered by Stripe.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Pay button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _processPayment,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isProcessing
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Processing...'),
                                  ],
                                )
                              : Text(
                                  'Pay \$${widget.amount.toStringAsFixed(2)}',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processPayment() async {
    if (_formKey.currentState!.validate() && _cardDetails.complete) {
      setState(() {
        _isProcessing = true;
      });

      try {
        // First create payment method with Stripe
        final paymentMethod = await Stripe.instance.createPaymentMethod(
          const PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(),
          ),
        );

        if (_savePaymentMethod) {
          // Save payment method to user's account
          context.read<PaymentBloc>().add(
            PaymentEvent.paymentMethodAdded(
              stripePaymentMethodId: paymentMethod.id,
            ),
          );
        } else {
          // Create payment intent directly
          context.read<PaymentBloc>().add(
            PaymentEvent.paymentIntentCreated(
              orderId: widget.orderId,
              paymentMethodId: paymentMethod.id,
              savePaymentMethod: _savePaymentMethod,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isProcessing = false;
        });
        _showErrorDialog('Payment failed: ${e.toString()}');
      }
    } else {
      _showErrorDialog('Please complete all required fields');
    }
  }

  void _handleNextAction(String clientSecret) async {
    try {
      await Stripe.instance.handleNextAction(clientSecret);
    } catch (e) {
      _showErrorDialog('Authentication failed: ${e.toString()}');
    }
  }

  void _showPaymentSuccessDialog() {
    setState(() {
      _isProcessing = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: const Text('Your payment has been processed successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    setState(() {
      _isProcessing = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Error'),
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