import 'dart:convert';
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
  ///
  /// Stripe SDK integration has been removed for the current cash-only
  /// configuration, so this becomes a no-op to keep existing flows stable.
  Future<void> initializeStripe() async {
    // No-op: payments are handled via Supabase Edge Functions / backend only.
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
    // No-op: client-side Stripe SDK is not used in the cash-only flow.
    // The backend should mark intents as confirmed where applicable.
  }

  /// Handle payment action (3D Secure, etc.)
  Future<void> handleNextAction({
    required String clientSecret,
    required Map<String, dynamic> nextAction,
  }) async {
    // No-op: without Stripe SDK there are no client-side next actions.
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
    throw UnsupportedError(
      'Apple Pay is not supported in the current cash-only payment configuration.',
    );
  }

  /// Process payment using Google Pay
  Future<CreatePaymentIntentResponse> processGooglePayPayment({
    required String orderId,
    required Map<String, dynamic> googlePayPaymentData,
    bool savePaymentMethod = false,
  }) async {
    throw UnsupportedError(
      'Google Pay is not supported in the current cash-only payment configuration.',
    );
  }
}