part of 'payment_bloc.dart';

@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState.initial() = _Initial;

  const factory PaymentState.loading() = _Loading;

  const factory PaymentState.processing() = _Processing;

  const factory PaymentState.loaded() = _Loaded;

  const factory PaymentState.paymentIntentCreated({
    required String clientSecret,
    required String paymentIntentId,
  }) = _PaymentIntentCreated;

  const factory PaymentState.requiresAction({
    required String clientSecret,
    required String paymentIntentId,
    required Map<String, dynamic> nextAction,
  }) = _RequiresAction;

  const factory PaymentState.paymentConfirmed() = _PaymentConfirmed;

  const factory PaymentState.paymentMethodsLoaded(List<PaymentMethod> paymentMethods) =
      _PaymentMethodsLoaded;

  const factory PaymentState.paymentMethodAdded(
    PaymentMethod paymentMethod,
    List<PaymentMethod> allPaymentMethods,
  ) = _PaymentMethodAdded;

  const factory PaymentState.paymentMethodRemoved(List<PaymentMethod> paymentMethods) =
      _PaymentMethodRemoved;

  const factory PaymentState.defaultPaymentMethodSet(List<PaymentMethod> paymentMethods) =
      _DefaultPaymentMethodSet;

  const factory PaymentState.walletLoaded(Wallet wallet) = _WalletLoaded;

  const factory PaymentState.walletTransactionsLoaded(List<WalletTransaction> transactions) =
      _WalletTransactionsLoaded;

  const factory PaymentState.paymentSettingsLoaded(List<PaymentSetting> settings) =
      _PaymentSettingsLoaded;

  const factory PaymentState.error(String message) = _Error;
}