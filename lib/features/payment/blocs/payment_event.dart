part of 'payment_bloc.dart';

@freezed
class PaymentEvent with _$PaymentEvent {
  const factory PaymentEvent.initialized() = PaymentInitializedEvent;

  const factory PaymentEvent.paymentIntentCreated({
    required String orderId,
    String? paymentMethodId,
    @Default(false) bool savePaymentMethod,
    @Default(false) bool useSavedMethod,
  }) = PaymentIntentCreatedEvent;

  const factory PaymentEvent.paymentConfirmed({
    required String clientSecret,
    String? paymentMethodId,
  }) = PaymentConfirmedEvent;

  const factory PaymentEvent.paymentMethodsLoaded() = PaymentMethodsLoadedEvent;

  const factory PaymentEvent.paymentMethodAdded({
    required String stripePaymentMethodId,
  }) = PaymentMethodAddedEvent;

  const factory PaymentEvent.paymentMethodRemoved({
    required String paymentMethodId,
  }) = PaymentMethodRemovedEvent;

  const factory PaymentEvent.defaultPaymentMethodSet({
    required String paymentMethodId,
  }) = DefaultPaymentMethodSetEvent;

  const factory PaymentEvent.walletLoaded() = WalletLoadedEvent;

  const factory PaymentEvent.walletTransactionsLoaded({
    @Default(20) int limit,
    @Default(0) int offset,
  }) = WalletTransactionsLoadedEvent;

  const factory PaymentEvent.paymentSettingsLoaded() = PaymentSettingsLoadedEvent;

  const factory PaymentEvent.applePayPaymentProcessed({
    required String orderId,
    required Map<String, dynamic> applePayPaymentMethod,
    @Default(false) bool savePaymentMethod,
  }) = ApplePayPaymentProcessedEvent;

  const factory PaymentEvent.googlePayPaymentProcessed({
    required String orderId,
    required Map<String, dynamic> googlePayPaymentData,
    @Default(false) bool savePaymentMethod,
  }) = GooglePayPaymentProcessedEvent;

  const factory PaymentEvent.error(String message) = PaymentErrorEvent;

  const factory PaymentEvent.reset() = PaymentResetEvent;
}