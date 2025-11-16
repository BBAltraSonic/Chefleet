import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../core/models/payment_method.dart';
import '../../../core/models/wallet.dart';
import '../../../core/services/payment_service.dart';

part 'payment_bloc.freezed.dart';
part 'payment_event.dart';
part 'payment_state.dart';

@lazySingleton
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentService _paymentService;

  PaymentBloc(this._paymentService) : super(const PaymentState.initial()) {
    on<PaymentEvent>((event, emit) async {
      await event.map(
        initialized: (event) => _onInitialized(event, emit),
        paymentIntentCreated: (event) => _onPaymentIntentCreated(event, emit),
        paymentConfirmed: (event) => _onPaymentConfirmed(event, emit),
        paymentMethodsLoaded: (event) => _onPaymentMethodsLoaded(event, emit),
        paymentMethodAdded: (event) => _onPaymentMethodAdded(event, emit),
        paymentMethodRemoved: (event) => _onPaymentMethodRemoved(event, emit),
        defaultPaymentMethodSet: (event) => _onDefaultPaymentMethodSet(event, emit),
        walletLoaded: (event) => _onWalletLoaded(event, emit),
        walletTransactionsLoaded: (event) => _onWalletTransactionsLoaded(event, emit),
        paymentSettingsLoaded: (event) => _onPaymentSettingsLoaded(event, emit),
        applePayPaymentProcessed: (event) => _onApplePayPaymentProcessed(event, emit),
        googlePayPaymentProcessed: (event) => _onGooglePayPaymentProcessed(event, emit),
        paymentError: (event) => _onPaymentError(event, emit),
        paymentStateReset: (event) => _onPaymentStateReset(event, emit),
      );
    });
  }

  Future<void> _onInitialized(
    PaymentInitialized event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.loading());
    try {
      await _paymentService.initializeStripe();
      emit(const PaymentState.loaded());
    } catch (error) {
      emit(PaymentState.error(error.toString()));
    }
  }

  Future<void> _onPaymentIntentCreated(
    PaymentIntentCreated event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.processing());
    try {
      final response = await _paymentService.createPaymentIntent(
        orderId: event.orderId,
        paymentMethodId: event.paymentMethodId,
        savePaymentMethod: event.savePaymentMethod,
        useSavedMethod: event.useSavedMethod,
      );

      if (response.requiresAction && response.nextAction != null) {
        emit(PaymentState.requiresAction(
          clientSecret: response.clientSecret!,
          paymentIntentId: response.paymentIntentId!,
          nextAction: response.nextAction!,
        ));
      } else {
        emit(PaymentState.paymentIntentCreated(
          clientSecret: response.clientSecret!,
          paymentIntentId: response.paymentIntentId!,
        ));
      }
    } catch (error) {
      emit(PaymentState.error(error.toString()));
    }
  }

  Future<void> _onPaymentConfirmed(
    PaymentConfirmed event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.processing());
    try {
      await _paymentService.confirmPayment(
        clientSecret: event.clientSecret,
        paymentMethodId: event.paymentMethodId,
      );
      emit(const PaymentState.paymentConfirmed());
    } catch (error) {
      emit(PaymentState.error(error.toString()));
    }
  }

  Future<void> _onPaymentMethodsLoaded(
    PaymentMethodsLoaded event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.loading());
    try {
      final paymentMethods = await _paymentService.getPaymentMethods();
      emit(PaymentState.paymentMethodsLoaded(paymentMethods));
    } catch (error) {
      emit(PaymentState.error(error.toString()));
    }
  }

  Future<void> _onPaymentMethodAdded(
    PaymentMethodAdded event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      final paymentMethod = await _paymentService.addPaymentMethod(
        stripePaymentMethodId: event.stripePaymentMethodId,
      );

      // Reload payment methods to get updated list
      final paymentMethods = await _paymentService.getPaymentMethods();
      emit(PaymentState.paymentMethodAdded(paymentMethod, paymentMethods));
    } catch (error) {
      emit(PaymentState.error(error.toString()));
    }
  }

  Future<void> _onPaymentMethodRemoved(
    PaymentMethodRemoved event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      await _paymentService.removePaymentMethod(event.paymentMethodId);

      // Reload payment methods to get updated list
      final paymentMethods = await _paymentService.getPaymentMethods();
      emit(PaymentState.paymentMethodRemoved(paymentMethods));
    } catch (error) {
      emit(PaymentState.error(error.toString()));
    }
  }

  Future<void> _onDefaultPaymentMethodSet(
    DefaultPaymentMethodSet event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      await _paymentService.setDefaultPaymentMethod(event.paymentMethodId);

      // Reload payment methods to get updated list
      final paymentMethods = await _paymentService.getPaymentMethods();
      emit(PaymentState.defaultPaymentMethodSet(paymentMethods));
    } catch (error) {
      emit(PaymentState.error(error.toString()));
    }
  }

  Future<void> _onWalletLoaded(
    WalletLoaded event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.loading());
    try {
      final wallet = await _paymentService.getWallet();
      emit(PaymentState.walletLoaded(wallet));
    } catch (error) {
      emit(PaymentState.error(error.toString()));
    }
  }

  Future<void> _onWalletTransactionsLoaded(
    WalletTransactionsLoaded event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      final transactions = await _paymentService.getWalletTransactions(
        limit: event.limit,
        offset: event.offset,
      );
      emit(PaymentState.walletTransactionsLoaded(transactions));
    } catch (error) {
      emit(PaymentState.error(error.toString()));
    }
  }

  Future<void> _onPaymentSettingsLoaded(
    PaymentSettingsLoaded event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      final settings = await _paymentService.getPaymentSettings();
      emit(PaymentState.paymentSettingsLoaded(settings));
    } catch (error) {
      emit(PaymentState.error(error.toString()));
    }
  }

  Future<void> _onApplePayPaymentProcessed(
    ApplePayPaymentProcessed event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.processing());
    try {
      final response = await _paymentService.processApplePayPayment(
        orderId: event.orderId,
        applePayPaymentMethod: event.applePayPaymentMethod,
        savePaymentMethod: event.savePaymentMethod,
      );

      if (response.requiresAction && response.nextAction != null) {
        emit(PaymentState.requiresAction(
          clientSecret: response.clientSecret!,
          paymentIntentId: response.paymentIntentId!,
          nextAction: response.nextAction!,
        ));
      } else {
        emit(PaymentState.paymentIntentCreated(
          clientSecret: response.clientSecret!,
          paymentIntentId: response.paymentIntentId!,
        ));
      }
    } catch (error) {
      emit(PaymentState.error(error.toString()));
    }
  }

  Future<void> _onGooglePayPaymentProcessed(
    GooglePayPaymentProcessed event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.processing());
    try {
      final response = await _paymentService.processGooglePayPayment(
        orderId: event.orderId,
        googlePayPaymentData: event.googlePayPaymentData,
        savePaymentMethod: event.savePaymentMethod,
      );

      if (response.requiresAction && response.nextAction != null) {
        emit(PaymentState.requiresAction(
          clientSecret: response.clientSecret!,
          paymentIntentId: response.paymentIntentId!,
          nextAction: response.nextAction!,
        ));
      } else {
        emit(PaymentState.paymentIntentCreated(
          clientSecret: response.clientSecret!,
          paymentIntentId: response.paymentIntentId!,
        ));
      }
    } catch (error) {
      emit(PaymentState.error(error.toString()));
    }
  }

  Future<void> _onPaymentError(
    PaymentError event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentState.error(event.message));
  }

  Future<void> _onPaymentStateReset(
    PaymentStateReset event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.initial());
  }
}