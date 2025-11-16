import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_method.dart';
import '../models/wallet.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _baseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  /// Initialize Stripe with publishable key
  Future<void> initializeStripe() async {
    try {
      // Get Stripe publishable key from environment or Supabase Edge Function
      final publishableKey = const String.fromEnvironment(
        'STRIPE_PUBLISHABLE_KEY',
        // In production, this should come from your environment variables
        defaultValue: 'pk_test_your_publishable_key_here',
      );

      await Stripe.instance.applySettings(
        StripeSettings(
          publishableKey: publishableKey,
          merchantIdentifier: 'merchant.com.chefleet',
          // Enable Apple Pay for iOS
          applePay: ApplePayParams(
            merchantId: 'merchant.com.chefleet',
          ),
        ),
      );
    } catch (e) {
      throw Exception('Failed to initialize Stripe: $e');
    }
  }

  /// Create a payment intent for an order
  Future<CreatePaymentIntentResponse> createPaymentIntent({
    required String orderId,
    String? paymentMethodId,
    bool savePaymentMethod = false,
    bool useSavedMethod = false,
  }) async {
    try {
      final request = CreatePaymentIntentRequest(
        orderId: orderId,
        paymentMethodId: paymentMethodId,
        savePaymentMethod: savePaymentMethod,
        useSavedMethod: useSavedMethod,
      );

      final response = await _supabase.functions.invoke(
        'create_payment_intent',
        body: request.toJson(),
      );

      if (response.data == null) {
        throw Exception('No response from payment service');
      }

      final paymentResponse = CreatePaymentIntentResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      if (!paymentResponse.success) {
        throw Exception(paymentResponse.message ?? 'Payment intent creation failed');
      }

      return paymentResponse;
    } catch (e) {
      throw Exception('Failed to create payment intent: $e');
    }
  }

  /// Confirm payment using Stripe SDK
  Future<void> confirmPayment({
    required String clientSecret,
    String? paymentMethodId,
  }) async {
    try {
      // Create payment method if not provided
      if (paymentMethodId != null) {
        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
          data: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: BillingDetails(
                // You can pre-fill billing details if available
                email: _supabase.auth.currentUser?.email,
              ),
            ),
          ),
        );
      } else {
        // If payment method is already attached to the intent
        await Stripe.instance.retrievePaymentIntent(clientSecret);
      }
    } catch (e) {
      throw Exception('Payment confirmation failed: $e');
    }
  }

  /// Handle payment action (3D Secure, etc.)
  Future<void> handleNextAction({
    required String clientSecret,
    required Map<String, dynamic> nextAction,
  }) async {
    try {
      await Stripe.instance.handleNextAction(clientSecret);
    } catch (e) {
      throw Exception('Payment action handling failed: $e');
    }
  }

  /// Get user's saved payment methods
  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase.functions.invoke(
        'manage_payment_methods',
        body: {'action': 'list'},
      );

      if (response.data == null) {
        return [];
      }

      final data = Map<String, dynamic>.from(response.data);
      if (!data['success']) {
        throw Exception(data['message'] ?? 'Failed to fetch payment methods');
      }

      final methodsData = data['payment_methods'] as List<dynamic>? ?? [];
      return methodsData
          .map((json) => PaymentMethod.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  /// Add a new payment method
  Future<PaymentMethod> addPaymentMethod({
    required String stripePaymentMethodId,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'manage_payment_methods',
        body: {
          'action': 'add',
          'stripe_payment_method_id': stripePaymentMethodId,
        },
      );

      if (response.data == null) {
        throw Exception('No response from payment service');
      }

      final data = Map<String, dynamic>.from(response.data);
      if (!data['success']) {
        throw Exception(data['message'] ?? 'Failed to add payment method');
      }

      final methodData = data['payment_method'];
      return PaymentMethod.fromJson(Map<String, dynamic>.from(methodData));
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  /// Remove a payment method
  Future<void> removePaymentMethod(String paymentMethodId) async {
    try {
      final response = await _supabase.functions.invoke(
        'manage_payment_methods',
        body: {
          'action': 'remove',
          'payment_method_id': paymentMethodId,
        },
      );

      if (response.data == null) {
        throw Exception('No response from payment service');
      }

      final data = Map<String, dynamic>.from(response.data);
      if (!data['success']) {
        throw Exception(data['message'] ?? 'Failed to remove payment method');
      }
    } catch (e) {
      throw Exception('Failed to remove payment method: $e');
    }
  }

  /// Set default payment method
  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      final response = await _supabase.functions.invoke(
        'manage_payment_methods',
        body: {
          'action': 'set_default',
          'payment_method_id': paymentMethodId,
        },
      );

      if (response.data == null) {
        throw Exception('No response from payment service');
      }

      final data = Map<String, dynamic>.from(response.data);
      if (!data['success']) {
        throw Exception(data['message'] ?? 'Failed to set default payment method');
      }
    } catch (e) {
      throw Exception('Failed to set default payment method: $e');
    }
  }

  /// Get user wallet information
  Future<Wallet> getWallet() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('user_wallets')
          .select()
          .eq('user_id', userId)
          .single();

      return Wallet.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get wallet: $e');
    }
  }

  /// Get wallet transaction history
  Future<List<WalletTransaction>> getWalletTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('wallet_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((json) => WalletTransaction.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get wallet transactions: $e');
    }
  }

  /// Get payment settings
  Future<List<PaymentSetting>> getPaymentSettings() async {
    try {
      final response = await _supabase
          .from('payment_settings')
          .select()
          .eq('is_active', true);

      return response
          .map((json) => PaymentSetting.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get payment settings: $e');
    }
  }

  /// Process payment using Apple Pay
  Future<CreatePaymentIntentResponse> processApplePayPayment({
    required String orderId,
    required Map<String, dynamic> applePayPaymentMethod,
    bool savePaymentMethod = false,
  }) async {
    try {
      // Create payment method from Apple Pay token
      final paymentMethod = await Stripe.instance.createApplePayPaymentMethod(
        ApplePayParams(
          paymentMethod: applePayPaymentMethod,
        ),
      );

      // Create payment intent with Apple Pay payment method
      return await createPaymentIntent(
        orderId: orderId,
        paymentMethodId: paymentMethod.id,
        savePaymentMethod: savePaymentMethod,
      );
    } catch (e) {
      throw Exception('Apple Pay payment failed: $e');
    }
  }

  /// Process payment using Google Pay
  Future<CreatePaymentIntentResponse> processGooglePayPayment({
    required String orderId,
    required Map<String, dynamic> googlePayPaymentData,
    bool savePaymentMethod = false,
  }) async {
    try {
      // Create payment method from Google Pay token
      final paymentMethod = await Stripe.instance.createGooglePayPaymentMethod(
        GooglePayParams(
          paymentMethodData: googlePayPaymentData,
        ),
      );

      // Create payment intent with Google Pay payment method
      return await createPaymentIntent(
        orderId: orderId,
        paymentMethodId: paymentMethod.id,
        savePaymentMethod: savePaymentMethod,
      );
    } catch (e) {
      throw Exception('Google Pay payment failed: $e');
    }
  }
}