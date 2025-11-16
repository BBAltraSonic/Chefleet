part of 'payment_bloc.dart';

@freezed
class PaymentEvent with _$PaymentEvent {
  const factory PaymentEvent.initialized() = PaymentInitialized;

  const factory PaymentEvent.paymentIntentCreated({
    required String orderId,
    String? paymentMethodId,
    bool savePaymentMethod = false,
    bool useSavedMethod = false,
  }) = PaymentIntentCreated;

  const factory PaymentEvent.paymentConfirmed({
    required String clientSecret,
    String? paymentMethodId,
  }) = PaymentConfirmed;

  const factory PaymentEvent.paymentMethodsLoaded() = PaymentMethodsLoaded;

  const factory PaymentEvent.paymentMethodAdded({
    required String stripePaymentMethodId,
  }) = PaymentMethodAdded;

  const factory PaymentEvent.paymentMethodRemoved({
    required String paymentMethodId,
  }) = PaymentMethodRemoved;

  const factory PaymentEvent.defaultPaymentMethodSet({
    required String paymentMethodId,
  }) = DefaultPaymentMethodSet;

  const factory PaymentEvent.walletLoaded() = WalletLoaded;

  const factory PaymentEvent.walletTransactionsLoaded({
    int limit = 20,
    int offset = 0,
  }) = WalletTransactionsLoaded;

  const factory PaymentEvent.paymentSettingsLoaded() = PaymentSettingsLoaded;

  const factory PaymentEvent.applePayPaymentProcessed({
    required String orderId,
    required Map<String, dynamic> applePayPaymentMethod,
    bool savePaymentMethod = false,
  }) = ApplePayPaymentProcessed;

  const factory PaymentEvent.googlePayPaymentProcessed({
    required String orderId,
    required Map<String, dynamic> googlePayPaymentData,
    bool savePaymentMethod = false,
  }) = GooglePayPaymentProcessed;

  const factory PaymentEvent.error(String message) = PaymentError;

  const factory PaymentEvent.reset() = PaymentStateReset;
}