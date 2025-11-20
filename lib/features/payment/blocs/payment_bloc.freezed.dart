// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PaymentEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentEventCopyWith<$Res> {
  factory $PaymentEventCopyWith(
    PaymentEvent value,
    $Res Function(PaymentEvent) then,
  ) = _$PaymentEventCopyWithImpl<$Res, PaymentEvent>;
}

/// @nodoc
class _$PaymentEventCopyWithImpl<$Res, $Val extends PaymentEvent>
    implements $PaymentEventCopyWith<$Res> {
  _$PaymentEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$PaymentInitializedEventImplCopyWith<$Res> {
  factory _$$PaymentInitializedEventImplCopyWith(
    _$PaymentInitializedEventImpl value,
    $Res Function(_$PaymentInitializedEventImpl) then,
  ) = __$$PaymentInitializedEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PaymentInitializedEventImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$PaymentInitializedEventImpl>
    implements _$$PaymentInitializedEventImplCopyWith<$Res> {
  __$$PaymentInitializedEventImplCopyWithImpl(
    _$PaymentInitializedEventImpl _value,
    $Res Function(_$PaymentInitializedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PaymentInitializedEventImpl implements PaymentInitializedEvent {
  const _$PaymentInitializedEventImpl();

  @override
  String toString() {
    return 'PaymentEvent.initialized()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentInitializedEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) {
    return initialized();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) {
    return initialized?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (initialized != null) {
      return initialized();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) {
    return initialized(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) {
    return initialized?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) {
    if (initialized != null) {
      return initialized(this);
    }
    return orElse();
  }
}

abstract class PaymentInitializedEvent implements PaymentEvent {
  const factory PaymentInitializedEvent() = _$PaymentInitializedEventImpl;
}

/// @nodoc
abstract class _$$PaymentIntentCreatedEventImplCopyWith<$Res> {
  factory _$$PaymentIntentCreatedEventImplCopyWith(
    _$PaymentIntentCreatedEventImpl value,
    $Res Function(_$PaymentIntentCreatedEventImpl) then,
  ) = __$$PaymentIntentCreatedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String orderId,
    String? paymentMethodId,
    bool savePaymentMethod,
    bool useSavedMethod,
  });
}

/// @nodoc
class __$$PaymentIntentCreatedEventImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$PaymentIntentCreatedEventImpl>
    implements _$$PaymentIntentCreatedEventImplCopyWith<$Res> {
  __$$PaymentIntentCreatedEventImplCopyWithImpl(
    _$PaymentIntentCreatedEventImpl _value,
    $Res Function(_$PaymentIntentCreatedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? paymentMethodId = freezed,
    Object? savePaymentMethod = null,
    Object? useSavedMethod = null,
  }) {
    return _then(
      _$PaymentIntentCreatedEventImpl(
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentMethodId: freezed == paymentMethodId
            ? _value.paymentMethodId
            : paymentMethodId // ignore: cast_nullable_to_non_nullable
                  as String?,
        savePaymentMethod: null == savePaymentMethod
            ? _value.savePaymentMethod
            : savePaymentMethod // ignore: cast_nullable_to_non_nullable
                  as bool,
        useSavedMethod: null == useSavedMethod
            ? _value.useSavedMethod
            : useSavedMethod // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$PaymentIntentCreatedEventImpl implements PaymentIntentCreatedEvent {
  const _$PaymentIntentCreatedEventImpl({
    required this.orderId,
    this.paymentMethodId,
    this.savePaymentMethod = false,
    this.useSavedMethod = false,
  });

  @override
  final String orderId;
  @override
  final String? paymentMethodId;
  @override
  @JsonKey()
  final bool savePaymentMethod;
  @override
  @JsonKey()
  final bool useSavedMethod;

  @override
  String toString() {
    return 'PaymentEvent.paymentIntentCreated(orderId: $orderId, paymentMethodId: $paymentMethodId, savePaymentMethod: $savePaymentMethod, useSavedMethod: $useSavedMethod)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentIntentCreatedEventImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.paymentMethodId, paymentMethodId) ||
                other.paymentMethodId == paymentMethodId) &&
            (identical(other.savePaymentMethod, savePaymentMethod) ||
                other.savePaymentMethod == savePaymentMethod) &&
            (identical(other.useSavedMethod, useSavedMethod) ||
                other.useSavedMethod == useSavedMethod));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    orderId,
    paymentMethodId,
    savePaymentMethod,
    useSavedMethod,
  );

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentIntentCreatedEventImplCopyWith<_$PaymentIntentCreatedEventImpl>
  get copyWith =>
      __$$PaymentIntentCreatedEventImplCopyWithImpl<
        _$PaymentIntentCreatedEventImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) {
    return paymentIntentCreated(
      orderId,
      paymentMethodId,
      savePaymentMethod,
      useSavedMethod,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) {
    return paymentIntentCreated?.call(
      orderId,
      paymentMethodId,
      savePaymentMethod,
      useSavedMethod,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (paymentIntentCreated != null) {
      return paymentIntentCreated(
        orderId,
        paymentMethodId,
        savePaymentMethod,
        useSavedMethod,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) {
    return paymentIntentCreated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) {
    return paymentIntentCreated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) {
    if (paymentIntentCreated != null) {
      return paymentIntentCreated(this);
    }
    return orElse();
  }
}

abstract class PaymentIntentCreatedEvent implements PaymentEvent {
  const factory PaymentIntentCreatedEvent({
    required final String orderId,
    final String? paymentMethodId,
    final bool savePaymentMethod,
    final bool useSavedMethod,
  }) = _$PaymentIntentCreatedEventImpl;

  String get orderId;
  String? get paymentMethodId;
  bool get savePaymentMethod;
  bool get useSavedMethod;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentIntentCreatedEventImplCopyWith<_$PaymentIntentCreatedEventImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PaymentConfirmedEventImplCopyWith<$Res> {
  factory _$$PaymentConfirmedEventImplCopyWith(
    _$PaymentConfirmedEventImpl value,
    $Res Function(_$PaymentConfirmedEventImpl) then,
  ) = __$$PaymentConfirmedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String clientSecret, String? paymentMethodId});
}

/// @nodoc
class __$$PaymentConfirmedEventImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$PaymentConfirmedEventImpl>
    implements _$$PaymentConfirmedEventImplCopyWith<$Res> {
  __$$PaymentConfirmedEventImplCopyWithImpl(
    _$PaymentConfirmedEventImpl _value,
    $Res Function(_$PaymentConfirmedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? clientSecret = null, Object? paymentMethodId = freezed}) {
    return _then(
      _$PaymentConfirmedEventImpl(
        clientSecret: null == clientSecret
            ? _value.clientSecret
            : clientSecret // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentMethodId: freezed == paymentMethodId
            ? _value.paymentMethodId
            : paymentMethodId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$PaymentConfirmedEventImpl implements PaymentConfirmedEvent {
  const _$PaymentConfirmedEventImpl({
    required this.clientSecret,
    this.paymentMethodId,
  });

  @override
  final String clientSecret;
  @override
  final String? paymentMethodId;

  @override
  String toString() {
    return 'PaymentEvent.paymentConfirmed(clientSecret: $clientSecret, paymentMethodId: $paymentMethodId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentConfirmedEventImpl &&
            (identical(other.clientSecret, clientSecret) ||
                other.clientSecret == clientSecret) &&
            (identical(other.paymentMethodId, paymentMethodId) ||
                other.paymentMethodId == paymentMethodId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, clientSecret, paymentMethodId);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentConfirmedEventImplCopyWith<_$PaymentConfirmedEventImpl>
  get copyWith =>
      __$$PaymentConfirmedEventImplCopyWithImpl<_$PaymentConfirmedEventImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) {
    return paymentConfirmed(clientSecret, paymentMethodId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) {
    return paymentConfirmed?.call(clientSecret, paymentMethodId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (paymentConfirmed != null) {
      return paymentConfirmed(clientSecret, paymentMethodId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) {
    return paymentConfirmed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) {
    return paymentConfirmed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) {
    if (paymentConfirmed != null) {
      return paymentConfirmed(this);
    }
    return orElse();
  }
}

abstract class PaymentConfirmedEvent implements PaymentEvent {
  const factory PaymentConfirmedEvent({
    required final String clientSecret,
    final String? paymentMethodId,
  }) = _$PaymentConfirmedEventImpl;

  String get clientSecret;
  String? get paymentMethodId;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentConfirmedEventImplCopyWith<_$PaymentConfirmedEventImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PaymentMethodsLoadedEventImplCopyWith<$Res> {
  factory _$$PaymentMethodsLoadedEventImplCopyWith(
    _$PaymentMethodsLoadedEventImpl value,
    $Res Function(_$PaymentMethodsLoadedEventImpl) then,
  ) = __$$PaymentMethodsLoadedEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PaymentMethodsLoadedEventImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$PaymentMethodsLoadedEventImpl>
    implements _$$PaymentMethodsLoadedEventImplCopyWith<$Res> {
  __$$PaymentMethodsLoadedEventImplCopyWithImpl(
    _$PaymentMethodsLoadedEventImpl _value,
    $Res Function(_$PaymentMethodsLoadedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PaymentMethodsLoadedEventImpl implements PaymentMethodsLoadedEvent {
  const _$PaymentMethodsLoadedEventImpl();

  @override
  String toString() {
    return 'PaymentEvent.paymentMethodsLoaded()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentMethodsLoadedEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) {
    return paymentMethodsLoaded();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) {
    return paymentMethodsLoaded?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (paymentMethodsLoaded != null) {
      return paymentMethodsLoaded();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) {
    return paymentMethodsLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) {
    return paymentMethodsLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) {
    if (paymentMethodsLoaded != null) {
      return paymentMethodsLoaded(this);
    }
    return orElse();
  }
}

abstract class PaymentMethodsLoadedEvent implements PaymentEvent {
  const factory PaymentMethodsLoadedEvent() = _$PaymentMethodsLoadedEventImpl;
}

/// @nodoc
abstract class _$$PaymentMethodAddedEventImplCopyWith<$Res> {
  factory _$$PaymentMethodAddedEventImplCopyWith(
    _$PaymentMethodAddedEventImpl value,
    $Res Function(_$PaymentMethodAddedEventImpl) then,
  ) = __$$PaymentMethodAddedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String stripePaymentMethodId});
}

/// @nodoc
class __$$PaymentMethodAddedEventImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$PaymentMethodAddedEventImpl>
    implements _$$PaymentMethodAddedEventImplCopyWith<$Res> {
  __$$PaymentMethodAddedEventImplCopyWithImpl(
    _$PaymentMethodAddedEventImpl _value,
    $Res Function(_$PaymentMethodAddedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? stripePaymentMethodId = null}) {
    return _then(
      _$PaymentMethodAddedEventImpl(
        stripePaymentMethodId: null == stripePaymentMethodId
            ? _value.stripePaymentMethodId
            : stripePaymentMethodId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PaymentMethodAddedEventImpl implements PaymentMethodAddedEvent {
  const _$PaymentMethodAddedEventImpl({required this.stripePaymentMethodId});

  @override
  final String stripePaymentMethodId;

  @override
  String toString() {
    return 'PaymentEvent.paymentMethodAdded(stripePaymentMethodId: $stripePaymentMethodId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentMethodAddedEventImpl &&
            (identical(other.stripePaymentMethodId, stripePaymentMethodId) ||
                other.stripePaymentMethodId == stripePaymentMethodId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, stripePaymentMethodId);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentMethodAddedEventImplCopyWith<_$PaymentMethodAddedEventImpl>
  get copyWith =>
      __$$PaymentMethodAddedEventImplCopyWithImpl<
        _$PaymentMethodAddedEventImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) {
    return paymentMethodAdded(stripePaymentMethodId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) {
    return paymentMethodAdded?.call(stripePaymentMethodId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (paymentMethodAdded != null) {
      return paymentMethodAdded(stripePaymentMethodId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) {
    return paymentMethodAdded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) {
    return paymentMethodAdded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) {
    if (paymentMethodAdded != null) {
      return paymentMethodAdded(this);
    }
    return orElse();
  }
}

abstract class PaymentMethodAddedEvent implements PaymentEvent {
  const factory PaymentMethodAddedEvent({
    required final String stripePaymentMethodId,
  }) = _$PaymentMethodAddedEventImpl;

  String get stripePaymentMethodId;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentMethodAddedEventImplCopyWith<_$PaymentMethodAddedEventImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PaymentMethodRemovedEventImplCopyWith<$Res> {
  factory _$$PaymentMethodRemovedEventImplCopyWith(
    _$PaymentMethodRemovedEventImpl value,
    $Res Function(_$PaymentMethodRemovedEventImpl) then,
  ) = __$$PaymentMethodRemovedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String paymentMethodId});
}

/// @nodoc
class __$$PaymentMethodRemovedEventImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$PaymentMethodRemovedEventImpl>
    implements _$$PaymentMethodRemovedEventImplCopyWith<$Res> {
  __$$PaymentMethodRemovedEventImplCopyWithImpl(
    _$PaymentMethodRemovedEventImpl _value,
    $Res Function(_$PaymentMethodRemovedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? paymentMethodId = null}) {
    return _then(
      _$PaymentMethodRemovedEventImpl(
        paymentMethodId: null == paymentMethodId
            ? _value.paymentMethodId
            : paymentMethodId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PaymentMethodRemovedEventImpl implements PaymentMethodRemovedEvent {
  const _$PaymentMethodRemovedEventImpl({required this.paymentMethodId});

  @override
  final String paymentMethodId;

  @override
  String toString() {
    return 'PaymentEvent.paymentMethodRemoved(paymentMethodId: $paymentMethodId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentMethodRemovedEventImpl &&
            (identical(other.paymentMethodId, paymentMethodId) ||
                other.paymentMethodId == paymentMethodId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, paymentMethodId);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentMethodRemovedEventImplCopyWith<_$PaymentMethodRemovedEventImpl>
  get copyWith =>
      __$$PaymentMethodRemovedEventImplCopyWithImpl<
        _$PaymentMethodRemovedEventImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) {
    return paymentMethodRemoved(paymentMethodId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) {
    return paymentMethodRemoved?.call(paymentMethodId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (paymentMethodRemoved != null) {
      return paymentMethodRemoved(paymentMethodId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) {
    return paymentMethodRemoved(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) {
    return paymentMethodRemoved?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) {
    if (paymentMethodRemoved != null) {
      return paymentMethodRemoved(this);
    }
    return orElse();
  }
}

abstract class PaymentMethodRemovedEvent implements PaymentEvent {
  const factory PaymentMethodRemovedEvent({
    required final String paymentMethodId,
  }) = _$PaymentMethodRemovedEventImpl;

  String get paymentMethodId;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentMethodRemovedEventImplCopyWith<_$PaymentMethodRemovedEventImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DefaultPaymentMethodSetEventImplCopyWith<$Res> {
  factory _$$DefaultPaymentMethodSetEventImplCopyWith(
    _$DefaultPaymentMethodSetEventImpl value,
    $Res Function(_$DefaultPaymentMethodSetEventImpl) then,
  ) = __$$DefaultPaymentMethodSetEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String paymentMethodId});
}

/// @nodoc
class __$$DefaultPaymentMethodSetEventImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$DefaultPaymentMethodSetEventImpl>
    implements _$$DefaultPaymentMethodSetEventImplCopyWith<$Res> {
  __$$DefaultPaymentMethodSetEventImplCopyWithImpl(
    _$DefaultPaymentMethodSetEventImpl _value,
    $Res Function(_$DefaultPaymentMethodSetEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? paymentMethodId = null}) {
    return _then(
      _$DefaultPaymentMethodSetEventImpl(
        paymentMethodId: null == paymentMethodId
            ? _value.paymentMethodId
            : paymentMethodId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$DefaultPaymentMethodSetEventImpl
    implements DefaultPaymentMethodSetEvent {
  const _$DefaultPaymentMethodSetEventImpl({required this.paymentMethodId});

  @override
  final String paymentMethodId;

  @override
  String toString() {
    return 'PaymentEvent.defaultPaymentMethodSet(paymentMethodId: $paymentMethodId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DefaultPaymentMethodSetEventImpl &&
            (identical(other.paymentMethodId, paymentMethodId) ||
                other.paymentMethodId == paymentMethodId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, paymentMethodId);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DefaultPaymentMethodSetEventImplCopyWith<
    _$DefaultPaymentMethodSetEventImpl
  >
  get copyWith =>
      __$$DefaultPaymentMethodSetEventImplCopyWithImpl<
        _$DefaultPaymentMethodSetEventImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) {
    return defaultPaymentMethodSet(paymentMethodId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) {
    return defaultPaymentMethodSet?.call(paymentMethodId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (defaultPaymentMethodSet != null) {
      return defaultPaymentMethodSet(paymentMethodId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) {
    return defaultPaymentMethodSet(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) {
    return defaultPaymentMethodSet?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) {
    if (defaultPaymentMethodSet != null) {
      return defaultPaymentMethodSet(this);
    }
    return orElse();
  }
}

abstract class DefaultPaymentMethodSetEvent implements PaymentEvent {
  const factory DefaultPaymentMethodSetEvent({
    required final String paymentMethodId,
  }) = _$DefaultPaymentMethodSetEventImpl;

  String get paymentMethodId;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DefaultPaymentMethodSetEventImplCopyWith<
    _$DefaultPaymentMethodSetEventImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WalletLoadedEventImplCopyWith<$Res> {
  factory _$$WalletLoadedEventImplCopyWith(
    _$WalletLoadedEventImpl value,
    $Res Function(_$WalletLoadedEventImpl) then,
  ) = __$$WalletLoadedEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$WalletLoadedEventImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$WalletLoadedEventImpl>
    implements _$$WalletLoadedEventImplCopyWith<$Res> {
  __$$WalletLoadedEventImplCopyWithImpl(
    _$WalletLoadedEventImpl _value,
    $Res Function(_$WalletLoadedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$WalletLoadedEventImpl implements WalletLoadedEvent {
  const _$WalletLoadedEventImpl();

  @override
  String toString() {
    return 'PaymentEvent.walletLoaded()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$WalletLoadedEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) {
    return walletLoaded();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) {
    return walletLoaded?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (walletLoaded != null) {
      return walletLoaded();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) {
    return walletLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) {
    return walletLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) {
    if (walletLoaded != null) {
      return walletLoaded(this);
    }
    return orElse();
  }
}

abstract class WalletLoadedEvent implements PaymentEvent {
  const factory WalletLoadedEvent() = _$WalletLoadedEventImpl;
}

/// @nodoc
abstract class _$$WalletTransactionsLoadedEventImplCopyWith<$Res> {
  factory _$$WalletTransactionsLoadedEventImplCopyWith(
    _$WalletTransactionsLoadedEventImpl value,
    $Res Function(_$WalletTransactionsLoadedEventImpl) then,
  ) = __$$WalletTransactionsLoadedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int limit, int offset});
}

/// @nodoc
class __$$WalletTransactionsLoadedEventImplCopyWithImpl<$Res>
    extends
        _$PaymentEventCopyWithImpl<$Res, _$WalletTransactionsLoadedEventImpl>
    implements _$$WalletTransactionsLoadedEventImplCopyWith<$Res> {
  __$$WalletTransactionsLoadedEventImplCopyWithImpl(
    _$WalletTransactionsLoadedEventImpl _value,
    $Res Function(_$WalletTransactionsLoadedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? limit = null, Object? offset = null}) {
    return _then(
      _$WalletTransactionsLoadedEventImpl(
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        offset: null == offset
            ? _value.offset
            : offset // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$WalletTransactionsLoadedEventImpl
    implements WalletTransactionsLoadedEvent {
  const _$WalletTransactionsLoadedEventImpl({this.limit = 20, this.offset = 0});

  @override
  @JsonKey()
  final int limit;
  @override
  @JsonKey()
  final int offset;

  @override
  String toString() {
    return 'PaymentEvent.walletTransactionsLoaded(limit: $limit, offset: $offset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletTransactionsLoadedEventImpl &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.offset, offset) || other.offset == offset));
  }

  @override
  int get hashCode => Object.hash(runtimeType, limit, offset);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletTransactionsLoadedEventImplCopyWith<
    _$WalletTransactionsLoadedEventImpl
  >
  get copyWith =>
      __$$WalletTransactionsLoadedEventImplCopyWithImpl<
        _$WalletTransactionsLoadedEventImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) {
    return walletTransactionsLoaded(limit, offset);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) {
    return walletTransactionsLoaded?.call(limit, offset);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (walletTransactionsLoaded != null) {
      return walletTransactionsLoaded(limit, offset);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) {
    return walletTransactionsLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) {
    return walletTransactionsLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) {
    if (walletTransactionsLoaded != null) {
      return walletTransactionsLoaded(this);
    }
    return orElse();
  }
}

abstract class WalletTransactionsLoadedEvent implements PaymentEvent {
  const factory WalletTransactionsLoadedEvent({
    final int limit,
    final int offset,
  }) = _$WalletTransactionsLoadedEventImpl;

  int get limit;
  int get offset;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletTransactionsLoadedEventImplCopyWith<
    _$WalletTransactionsLoadedEventImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PaymentSettingsLoadedEventImplCopyWith<$Res> {
  factory _$$PaymentSettingsLoadedEventImplCopyWith(
    _$PaymentSettingsLoadedEventImpl value,
    $Res Function(_$PaymentSettingsLoadedEventImpl) then,
  ) = __$$PaymentSettingsLoadedEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PaymentSettingsLoadedEventImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$PaymentSettingsLoadedEventImpl>
    implements _$$PaymentSettingsLoadedEventImplCopyWith<$Res> {
  __$$PaymentSettingsLoadedEventImplCopyWithImpl(
    _$PaymentSettingsLoadedEventImpl _value,
    $Res Function(_$PaymentSettingsLoadedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PaymentSettingsLoadedEventImpl implements PaymentSettingsLoadedEvent {
  const _$PaymentSettingsLoadedEventImpl();

  @override
  String toString() {
    return 'PaymentEvent.paymentSettingsLoaded()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentSettingsLoadedEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) {
    return paymentSettingsLoaded();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) {
    return paymentSettingsLoaded?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (paymentSettingsLoaded != null) {
      return paymentSettingsLoaded();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) {
    return paymentSettingsLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) {
    return paymentSettingsLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) {
    if (paymentSettingsLoaded != null) {
      return paymentSettingsLoaded(this);
    }
    return orElse();
  }
}

abstract class PaymentSettingsLoadedEvent implements PaymentEvent {
  const factory PaymentSettingsLoadedEvent() = _$PaymentSettingsLoadedEventImpl;
}

/// @nodoc
abstract class _$$ApplePayPaymentProcessedEventImplCopyWith<$Res> {
  factory _$$ApplePayPaymentProcessedEventImplCopyWith(
    _$ApplePayPaymentProcessedEventImpl value,
    $Res Function(_$ApplePayPaymentProcessedEventImpl) then,
  ) = __$$ApplePayPaymentProcessedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String orderId,
    Map<String, dynamic> applePayPaymentMethod,
    bool savePaymentMethod,
  });
}

/// @nodoc
class __$$ApplePayPaymentProcessedEventImplCopyWithImpl<$Res>
    extends
        _$PaymentEventCopyWithImpl<$Res, _$ApplePayPaymentProcessedEventImpl>
    implements _$$ApplePayPaymentProcessedEventImplCopyWith<$Res> {
  __$$ApplePayPaymentProcessedEventImplCopyWithImpl(
    _$ApplePayPaymentProcessedEventImpl _value,
    $Res Function(_$ApplePayPaymentProcessedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? applePayPaymentMethod = null,
    Object? savePaymentMethod = null,
  }) {
    return _then(
      _$ApplePayPaymentProcessedEventImpl(
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        applePayPaymentMethod: null == applePayPaymentMethod
            ? _value._applePayPaymentMethod
            : applePayPaymentMethod // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        savePaymentMethod: null == savePaymentMethod
            ? _value.savePaymentMethod
            : savePaymentMethod // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$ApplePayPaymentProcessedEventImpl
    implements ApplePayPaymentProcessedEvent {
  const _$ApplePayPaymentProcessedEventImpl({
    required this.orderId,
    required final Map<String, dynamic> applePayPaymentMethod,
    this.savePaymentMethod = false,
  }) : _applePayPaymentMethod = applePayPaymentMethod;

  @override
  final String orderId;
  final Map<String, dynamic> _applePayPaymentMethod;
  @override
  Map<String, dynamic> get applePayPaymentMethod {
    if (_applePayPaymentMethod is EqualUnmodifiableMapView)
      return _applePayPaymentMethod;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_applePayPaymentMethod);
  }

  @override
  @JsonKey()
  final bool savePaymentMethod;

  @override
  String toString() {
    return 'PaymentEvent.applePayPaymentProcessed(orderId: $orderId, applePayPaymentMethod: $applePayPaymentMethod, savePaymentMethod: $savePaymentMethod)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApplePayPaymentProcessedEventImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            const DeepCollectionEquality().equals(
              other._applePayPaymentMethod,
              _applePayPaymentMethod,
            ) &&
            (identical(other.savePaymentMethod, savePaymentMethod) ||
                other.savePaymentMethod == savePaymentMethod));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    orderId,
    const DeepCollectionEquality().hash(_applePayPaymentMethod),
    savePaymentMethod,
  );

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApplePayPaymentProcessedEventImplCopyWith<
    _$ApplePayPaymentProcessedEventImpl
  >
  get copyWith =>
      __$$ApplePayPaymentProcessedEventImplCopyWithImpl<
        _$ApplePayPaymentProcessedEventImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) {
    return applePayPaymentProcessed(
      orderId,
      applePayPaymentMethod,
      savePaymentMethod,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) {
    return applePayPaymentProcessed?.call(
      orderId,
      applePayPaymentMethod,
      savePaymentMethod,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (applePayPaymentProcessed != null) {
      return applePayPaymentProcessed(
        orderId,
        applePayPaymentMethod,
        savePaymentMethod,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) {
    return applePayPaymentProcessed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) {
    return applePayPaymentProcessed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) {
    if (applePayPaymentProcessed != null) {
      return applePayPaymentProcessed(this);
    }
    return orElse();
  }
}

abstract class ApplePayPaymentProcessedEvent implements PaymentEvent {
  const factory ApplePayPaymentProcessedEvent({
    required final String orderId,
    required final Map<String, dynamic> applePayPaymentMethod,
    final bool savePaymentMethod,
  }) = _$ApplePayPaymentProcessedEventImpl;

  String get orderId;
  Map<String, dynamic> get applePayPaymentMethod;
  bool get savePaymentMethod;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApplePayPaymentProcessedEventImplCopyWith<
    _$ApplePayPaymentProcessedEventImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GooglePayPaymentProcessedEventImplCopyWith<$Res> {
  factory _$$GooglePayPaymentProcessedEventImplCopyWith(
    _$GooglePayPaymentProcessedEventImpl value,
    $Res Function(_$GooglePayPaymentProcessedEventImpl) then,
  ) = __$$GooglePayPaymentProcessedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String orderId,
    Map<String, dynamic> googlePayPaymentData,
    bool savePaymentMethod,
  });
}

/// @nodoc
class __$$GooglePayPaymentProcessedEventImplCopyWithImpl<$Res>
    extends
        _$PaymentEventCopyWithImpl<$Res, _$GooglePayPaymentProcessedEventImpl>
    implements _$$GooglePayPaymentProcessedEventImplCopyWith<$Res> {
  __$$GooglePayPaymentProcessedEventImplCopyWithImpl(
    _$GooglePayPaymentProcessedEventImpl _value,
    $Res Function(_$GooglePayPaymentProcessedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? googlePayPaymentData = null,
    Object? savePaymentMethod = null,
  }) {
    return _then(
      _$GooglePayPaymentProcessedEventImpl(
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        googlePayPaymentData: null == googlePayPaymentData
            ? _value._googlePayPaymentData
            : googlePayPaymentData // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        savePaymentMethod: null == savePaymentMethod
            ? _value.savePaymentMethod
            : savePaymentMethod // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$GooglePayPaymentProcessedEventImpl
    implements GooglePayPaymentProcessedEvent {
  const _$GooglePayPaymentProcessedEventImpl({
    required this.orderId,
    required final Map<String, dynamic> googlePayPaymentData,
    this.savePaymentMethod = false,
  }) : _googlePayPaymentData = googlePayPaymentData;

  @override
  final String orderId;
  final Map<String, dynamic> _googlePayPaymentData;
  @override
  Map<String, dynamic> get googlePayPaymentData {
    if (_googlePayPaymentData is EqualUnmodifiableMapView)
      return _googlePayPaymentData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_googlePayPaymentData);
  }

  @override
  @JsonKey()
  final bool savePaymentMethod;

  @override
  String toString() {
    return 'PaymentEvent.googlePayPaymentProcessed(orderId: $orderId, googlePayPaymentData: $googlePayPaymentData, savePaymentMethod: $savePaymentMethod)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GooglePayPaymentProcessedEventImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            const DeepCollectionEquality().equals(
              other._googlePayPaymentData,
              _googlePayPaymentData,
            ) &&
            (identical(other.savePaymentMethod, savePaymentMethod) ||
                other.savePaymentMethod == savePaymentMethod));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    orderId,
    const DeepCollectionEquality().hash(_googlePayPaymentData),
    savePaymentMethod,
  );

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GooglePayPaymentProcessedEventImplCopyWith<
    _$GooglePayPaymentProcessedEventImpl
  >
  get copyWith =>
      __$$GooglePayPaymentProcessedEventImplCopyWithImpl<
        _$GooglePayPaymentProcessedEventImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) {
    return googlePayPaymentProcessed(
      orderId,
      googlePayPaymentData,
      savePaymentMethod,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) {
    return googlePayPaymentProcessed?.call(
      orderId,
      googlePayPaymentData,
      savePaymentMethod,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (googlePayPaymentProcessed != null) {
      return googlePayPaymentProcessed(
        orderId,
        googlePayPaymentData,
        savePaymentMethod,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) {
    return googlePayPaymentProcessed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) {
    return googlePayPaymentProcessed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) {
    if (googlePayPaymentProcessed != null) {
      return googlePayPaymentProcessed(this);
    }
    return orElse();
  }
}

abstract class GooglePayPaymentProcessedEvent implements PaymentEvent {
  const factory GooglePayPaymentProcessedEvent({
    required final String orderId,
    required final Map<String, dynamic> googlePayPaymentData,
    final bool savePaymentMethod,
  }) = _$GooglePayPaymentProcessedEventImpl;

  String get orderId;
  Map<String, dynamic> get googlePayPaymentData;
  bool get savePaymentMethod;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GooglePayPaymentProcessedEventImplCopyWith<
    _$GooglePayPaymentProcessedEventImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PaymentErrorEventImplCopyWith<$Res> {
  factory _$$PaymentErrorEventImplCopyWith(
    _$PaymentErrorEventImpl value,
    $Res Function(_$PaymentErrorEventImpl) then,
  ) = __$$PaymentErrorEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$PaymentErrorEventImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$PaymentErrorEventImpl>
    implements _$$PaymentErrorEventImplCopyWith<$Res> {
  __$$PaymentErrorEventImplCopyWithImpl(
    _$PaymentErrorEventImpl _value,
    $Res Function(_$PaymentErrorEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$PaymentErrorEventImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PaymentErrorEventImpl implements PaymentErrorEvent {
  const _$PaymentErrorEventImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'PaymentEvent.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentErrorEventImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentErrorEventImplCopyWith<_$PaymentErrorEventImpl> get copyWith =>
      __$$PaymentErrorEventImplCopyWithImpl<_$PaymentErrorEventImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class PaymentErrorEvent implements PaymentEvent {
  const factory PaymentErrorEvent(final String message) =
      _$PaymentErrorEventImpl;

  String get message;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentErrorEventImplCopyWith<_$PaymentErrorEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PaymentResetEventImplCopyWith<$Res> {
  factory _$$PaymentResetEventImplCopyWith(
    _$PaymentResetEventImpl value,
    $Res Function(_$PaymentResetEventImpl) then,
  ) = __$$PaymentResetEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PaymentResetEventImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$PaymentResetEventImpl>
    implements _$$PaymentResetEventImplCopyWith<$Res> {
  __$$PaymentResetEventImplCopyWithImpl(
    _$PaymentResetEventImpl _value,
    $Res Function(_$PaymentResetEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PaymentResetEventImpl implements PaymentResetEvent {
  const _$PaymentResetEventImpl();

  @override
  String toString() {
    return 'PaymentEvent.reset()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PaymentResetEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialized,
    required TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )
    paymentIntentCreated,
    required TResult Function(String clientSecret, String? paymentMethodId)
    paymentConfirmed,
    required TResult Function() paymentMethodsLoaded,
    required TResult Function(String stripePaymentMethodId) paymentMethodAdded,
    required TResult Function(String paymentMethodId) paymentMethodRemoved,
    required TResult Function(String paymentMethodId) defaultPaymentMethodSet,
    required TResult Function() walletLoaded,
    required TResult Function(int limit, int offset) walletTransactionsLoaded,
    required TResult Function() paymentSettingsLoaded,
    required TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )
    applePayPaymentProcessed,
    required TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )
    googlePayPaymentProcessed,
    required TResult Function(String message) error,
    required TResult Function() reset,
  }) {
    return reset();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialized,
    TResult? Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult? Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult? Function()? paymentMethodsLoaded,
    TResult? Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult? Function(String paymentMethodId)? paymentMethodRemoved,
    TResult? Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult? Function()? walletLoaded,
    TResult? Function(int limit, int offset)? walletTransactionsLoaded,
    TResult? Function()? paymentSettingsLoaded,
    TResult? Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult? Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult? Function(String message)? error,
    TResult? Function()? reset,
  }) {
    return reset?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialized,
    TResult Function(
      String orderId,
      String? paymentMethodId,
      bool savePaymentMethod,
      bool useSavedMethod,
    )?
    paymentIntentCreated,
    TResult Function(String clientSecret, String? paymentMethodId)?
    paymentConfirmed,
    TResult Function()? paymentMethodsLoaded,
    TResult Function(String stripePaymentMethodId)? paymentMethodAdded,
    TResult Function(String paymentMethodId)? paymentMethodRemoved,
    TResult Function(String paymentMethodId)? defaultPaymentMethodSet,
    TResult Function()? walletLoaded,
    TResult Function(int limit, int offset)? walletTransactionsLoaded,
    TResult Function()? paymentSettingsLoaded,
    TResult Function(
      String orderId,
      Map<String, dynamic> applePayPaymentMethod,
      bool savePaymentMethod,
    )?
    applePayPaymentProcessed,
    TResult Function(
      String orderId,
      Map<String, dynamic> googlePayPaymentData,
      bool savePaymentMethod,
    )?
    googlePayPaymentProcessed,
    TResult Function(String message)? error,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (reset != null) {
      return reset();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentInitializedEvent value) initialized,
    required TResult Function(PaymentIntentCreatedEvent value)
    paymentIntentCreated,
    required TResult Function(PaymentConfirmedEvent value) paymentConfirmed,
    required TResult Function(PaymentMethodsLoadedEvent value)
    paymentMethodsLoaded,
    required TResult Function(PaymentMethodAddedEvent value) paymentMethodAdded,
    required TResult Function(PaymentMethodRemovedEvent value)
    paymentMethodRemoved,
    required TResult Function(DefaultPaymentMethodSetEvent value)
    defaultPaymentMethodSet,
    required TResult Function(WalletLoadedEvent value) walletLoaded,
    required TResult Function(WalletTransactionsLoadedEvent value)
    walletTransactionsLoaded,
    required TResult Function(PaymentSettingsLoadedEvent value)
    paymentSettingsLoaded,
    required TResult Function(ApplePayPaymentProcessedEvent value)
    applePayPaymentProcessed,
    required TResult Function(GooglePayPaymentProcessedEvent value)
    googlePayPaymentProcessed,
    required TResult Function(PaymentErrorEvent value) error,
    required TResult Function(PaymentResetEvent value) reset,
  }) {
    return reset(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentInitializedEvent value)? initialized,
    TResult? Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult? Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult? Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult? Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult? Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult? Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult? Function(WalletLoadedEvent value)? walletLoaded,
    TResult? Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult? Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult? Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult? Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult? Function(PaymentErrorEvent value)? error,
    TResult? Function(PaymentResetEvent value)? reset,
  }) {
    return reset?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentInitializedEvent value)? initialized,
    TResult Function(PaymentIntentCreatedEvent value)? paymentIntentCreated,
    TResult Function(PaymentConfirmedEvent value)? paymentConfirmed,
    TResult Function(PaymentMethodsLoadedEvent value)? paymentMethodsLoaded,
    TResult Function(PaymentMethodAddedEvent value)? paymentMethodAdded,
    TResult Function(PaymentMethodRemovedEvent value)? paymentMethodRemoved,
    TResult Function(DefaultPaymentMethodSetEvent value)?
    defaultPaymentMethodSet,
    TResult Function(WalletLoadedEvent value)? walletLoaded,
    TResult Function(WalletTransactionsLoadedEvent value)?
    walletTransactionsLoaded,
    TResult Function(PaymentSettingsLoadedEvent value)? paymentSettingsLoaded,
    TResult Function(ApplePayPaymentProcessedEvent value)?
    applePayPaymentProcessed,
    TResult Function(GooglePayPaymentProcessedEvent value)?
    googlePayPaymentProcessed,
    TResult Function(PaymentErrorEvent value)? error,
    TResult Function(PaymentResetEvent value)? reset,
    required TResult orElse(),
  }) {
    if (reset != null) {
      return reset(this);
    }
    return orElse();
  }
}

abstract class PaymentResetEvent implements PaymentEvent {
  const factory PaymentResetEvent() = _$PaymentResetEventImpl;
}

/// @nodoc
mixin _$PaymentState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentStateCopyWith<$Res> {
  factory $PaymentStateCopyWith(
    PaymentState value,
    $Res Function(PaymentState) then,
  ) = _$PaymentStateCopyWithImpl<$Res, PaymentState>;
}

/// @nodoc
class _$PaymentStateCopyWithImpl<$Res, $Val extends PaymentState>
    implements $PaymentStateCopyWith<$Res> {
  _$PaymentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
    _$InitialImpl value,
    $Res Function(_$InitialImpl) then,
  ) = __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'PaymentState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements PaymentState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'PaymentState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements PaymentState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$ProcessingImplCopyWith<$Res> {
  factory _$$ProcessingImplCopyWith(
    _$ProcessingImpl value,
    $Res Function(_$ProcessingImpl) then,
  ) = __$$ProcessingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ProcessingImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$ProcessingImpl>
    implements _$$ProcessingImplCopyWith<$Res> {
  __$$ProcessingImplCopyWithImpl(
    _$ProcessingImpl _value,
    $Res Function(_$ProcessingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ProcessingImpl implements _Processing {
  const _$ProcessingImpl();

  @override
  String toString() {
    return 'PaymentState.processing()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ProcessingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return processing();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return processing?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return processing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return processing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(this);
    }
    return orElse();
  }
}

abstract class _Processing implements PaymentState {
  const factory _Processing() = _$ProcessingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
    _$LoadedImpl value,
    $Res Function(_$LoadedImpl) then,
  ) = __$$LoadedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
    _$LoadedImpl _value,
    $Res Function(_$LoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl();

  @override
  String toString() {
    return 'PaymentState.loaded()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return loaded();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements PaymentState {
  const factory _Loaded() = _$LoadedImpl;
}

/// @nodoc
abstract class _$$PaymentIntentCreatedImplCopyWith<$Res> {
  factory _$$PaymentIntentCreatedImplCopyWith(
    _$PaymentIntentCreatedImpl value,
    $Res Function(_$PaymentIntentCreatedImpl) then,
  ) = __$$PaymentIntentCreatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String clientSecret, String paymentIntentId});
}

/// @nodoc
class __$$PaymentIntentCreatedImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$PaymentIntentCreatedImpl>
    implements _$$PaymentIntentCreatedImplCopyWith<$Res> {
  __$$PaymentIntentCreatedImplCopyWithImpl(
    _$PaymentIntentCreatedImpl _value,
    $Res Function(_$PaymentIntentCreatedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? clientSecret = null, Object? paymentIntentId = null}) {
    return _then(
      _$PaymentIntentCreatedImpl(
        clientSecret: null == clientSecret
            ? _value.clientSecret
            : clientSecret // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentIntentId: null == paymentIntentId
            ? _value.paymentIntentId
            : paymentIntentId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PaymentIntentCreatedImpl implements _PaymentIntentCreated {
  const _$PaymentIntentCreatedImpl({
    required this.clientSecret,
    required this.paymentIntentId,
  });

  @override
  final String clientSecret;
  @override
  final String paymentIntentId;

  @override
  String toString() {
    return 'PaymentState.paymentIntentCreated(clientSecret: $clientSecret, paymentIntentId: $paymentIntentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentIntentCreatedImpl &&
            (identical(other.clientSecret, clientSecret) ||
                other.clientSecret == clientSecret) &&
            (identical(other.paymentIntentId, paymentIntentId) ||
                other.paymentIntentId == paymentIntentId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, clientSecret, paymentIntentId);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentIntentCreatedImplCopyWith<_$PaymentIntentCreatedImpl>
  get copyWith =>
      __$$PaymentIntentCreatedImplCopyWithImpl<_$PaymentIntentCreatedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return paymentIntentCreated(clientSecret, paymentIntentId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return paymentIntentCreated?.call(clientSecret, paymentIntentId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (paymentIntentCreated != null) {
      return paymentIntentCreated(clientSecret, paymentIntentId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return paymentIntentCreated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return paymentIntentCreated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (paymentIntentCreated != null) {
      return paymentIntentCreated(this);
    }
    return orElse();
  }
}

abstract class _PaymentIntentCreated implements PaymentState {
  const factory _PaymentIntentCreated({
    required final String clientSecret,
    required final String paymentIntentId,
  }) = _$PaymentIntentCreatedImpl;

  String get clientSecret;
  String get paymentIntentId;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentIntentCreatedImplCopyWith<_$PaymentIntentCreatedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RequiresActionImplCopyWith<$Res> {
  factory _$$RequiresActionImplCopyWith(
    _$RequiresActionImpl value,
    $Res Function(_$RequiresActionImpl) then,
  ) = __$$RequiresActionImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String clientSecret,
    String paymentIntentId,
    Map<String, dynamic> nextAction,
  });
}

/// @nodoc
class __$$RequiresActionImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$RequiresActionImpl>
    implements _$$RequiresActionImplCopyWith<$Res> {
  __$$RequiresActionImplCopyWithImpl(
    _$RequiresActionImpl _value,
    $Res Function(_$RequiresActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clientSecret = null,
    Object? paymentIntentId = null,
    Object? nextAction = null,
  }) {
    return _then(
      _$RequiresActionImpl(
        clientSecret: null == clientSecret
            ? _value.clientSecret
            : clientSecret // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentIntentId: null == paymentIntentId
            ? _value.paymentIntentId
            : paymentIntentId // ignore: cast_nullable_to_non_nullable
                  as String,
        nextAction: null == nextAction
            ? _value._nextAction
            : nextAction // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc

class _$RequiresActionImpl implements _RequiresAction {
  const _$RequiresActionImpl({
    required this.clientSecret,
    required this.paymentIntentId,
    required final Map<String, dynamic> nextAction,
  }) : _nextAction = nextAction;

  @override
  final String clientSecret;
  @override
  final String paymentIntentId;
  final Map<String, dynamic> _nextAction;
  @override
  Map<String, dynamic> get nextAction {
    if (_nextAction is EqualUnmodifiableMapView) return _nextAction;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_nextAction);
  }

  @override
  String toString() {
    return 'PaymentState.requiresAction(clientSecret: $clientSecret, paymentIntentId: $paymentIntentId, nextAction: $nextAction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequiresActionImpl &&
            (identical(other.clientSecret, clientSecret) ||
                other.clientSecret == clientSecret) &&
            (identical(other.paymentIntentId, paymentIntentId) ||
                other.paymentIntentId == paymentIntentId) &&
            const DeepCollectionEquality().equals(
              other._nextAction,
              _nextAction,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    clientSecret,
    paymentIntentId,
    const DeepCollectionEquality().hash(_nextAction),
  );

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequiresActionImplCopyWith<_$RequiresActionImpl> get copyWith =>
      __$$RequiresActionImplCopyWithImpl<_$RequiresActionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return requiresAction(clientSecret, paymentIntentId, nextAction);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return requiresAction?.call(clientSecret, paymentIntentId, nextAction);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (requiresAction != null) {
      return requiresAction(clientSecret, paymentIntentId, nextAction);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return requiresAction(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return requiresAction?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (requiresAction != null) {
      return requiresAction(this);
    }
    return orElse();
  }
}

abstract class _RequiresAction implements PaymentState {
  const factory _RequiresAction({
    required final String clientSecret,
    required final String paymentIntentId,
    required final Map<String, dynamic> nextAction,
  }) = _$RequiresActionImpl;

  String get clientSecret;
  String get paymentIntentId;
  Map<String, dynamic> get nextAction;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequiresActionImplCopyWith<_$RequiresActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PaymentConfirmedImplCopyWith<$Res> {
  factory _$$PaymentConfirmedImplCopyWith(
    _$PaymentConfirmedImpl value,
    $Res Function(_$PaymentConfirmedImpl) then,
  ) = __$$PaymentConfirmedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PaymentConfirmedImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$PaymentConfirmedImpl>
    implements _$$PaymentConfirmedImplCopyWith<$Res> {
  __$$PaymentConfirmedImplCopyWithImpl(
    _$PaymentConfirmedImpl _value,
    $Res Function(_$PaymentConfirmedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PaymentConfirmedImpl implements _PaymentConfirmed {
  const _$PaymentConfirmedImpl();

  @override
  String toString() {
    return 'PaymentState.paymentConfirmed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PaymentConfirmedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return paymentConfirmed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return paymentConfirmed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (paymentConfirmed != null) {
      return paymentConfirmed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return paymentConfirmed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return paymentConfirmed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (paymentConfirmed != null) {
      return paymentConfirmed(this);
    }
    return orElse();
  }
}

abstract class _PaymentConfirmed implements PaymentState {
  const factory _PaymentConfirmed() = _$PaymentConfirmedImpl;
}

/// @nodoc
abstract class _$$PaymentMethodsLoadedImplCopyWith<$Res> {
  factory _$$PaymentMethodsLoadedImplCopyWith(
    _$PaymentMethodsLoadedImpl value,
    $Res Function(_$PaymentMethodsLoadedImpl) then,
  ) = __$$PaymentMethodsLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<PaymentMethod> paymentMethods});
}

/// @nodoc
class __$$PaymentMethodsLoadedImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$PaymentMethodsLoadedImpl>
    implements _$$PaymentMethodsLoadedImplCopyWith<$Res> {
  __$$PaymentMethodsLoadedImplCopyWithImpl(
    _$PaymentMethodsLoadedImpl _value,
    $Res Function(_$PaymentMethodsLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? paymentMethods = null}) {
    return _then(
      _$PaymentMethodsLoadedImpl(
        null == paymentMethods
            ? _value._paymentMethods
            : paymentMethods // ignore: cast_nullable_to_non_nullable
                  as List<PaymentMethod>,
      ),
    );
  }
}

/// @nodoc

class _$PaymentMethodsLoadedImpl implements _PaymentMethodsLoaded {
  const _$PaymentMethodsLoadedImpl(final List<PaymentMethod> paymentMethods)
    : _paymentMethods = paymentMethods;

  final List<PaymentMethod> _paymentMethods;
  @override
  List<PaymentMethod> get paymentMethods {
    if (_paymentMethods is EqualUnmodifiableListView) return _paymentMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_paymentMethods);
  }

  @override
  String toString() {
    return 'PaymentState.paymentMethodsLoaded(paymentMethods: $paymentMethods)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentMethodsLoadedImpl &&
            const DeepCollectionEquality().equals(
              other._paymentMethods,
              _paymentMethods,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_paymentMethods),
  );

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentMethodsLoadedImplCopyWith<_$PaymentMethodsLoadedImpl>
  get copyWith =>
      __$$PaymentMethodsLoadedImplCopyWithImpl<_$PaymentMethodsLoadedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return paymentMethodsLoaded(paymentMethods);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return paymentMethodsLoaded?.call(paymentMethods);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (paymentMethodsLoaded != null) {
      return paymentMethodsLoaded(paymentMethods);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return paymentMethodsLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return paymentMethodsLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (paymentMethodsLoaded != null) {
      return paymentMethodsLoaded(this);
    }
    return orElse();
  }
}

abstract class _PaymentMethodsLoaded implements PaymentState {
  const factory _PaymentMethodsLoaded(
    final List<PaymentMethod> paymentMethods,
  ) = _$PaymentMethodsLoadedImpl;

  List<PaymentMethod> get paymentMethods;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentMethodsLoadedImplCopyWith<_$PaymentMethodsLoadedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PaymentMethodAddedImplCopyWith<$Res> {
  factory _$$PaymentMethodAddedImplCopyWith(
    _$PaymentMethodAddedImpl value,
    $Res Function(_$PaymentMethodAddedImpl) then,
  ) = __$$PaymentMethodAddedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    PaymentMethod paymentMethod,
    List<PaymentMethod> allPaymentMethods,
  });
}

/// @nodoc
class __$$PaymentMethodAddedImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$PaymentMethodAddedImpl>
    implements _$$PaymentMethodAddedImplCopyWith<$Res> {
  __$$PaymentMethodAddedImplCopyWithImpl(
    _$PaymentMethodAddedImpl _value,
    $Res Function(_$PaymentMethodAddedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? paymentMethod = null, Object? allPaymentMethods = null}) {
    return _then(
      _$PaymentMethodAddedImpl(
        null == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as PaymentMethod,
        null == allPaymentMethods
            ? _value._allPaymentMethods
            : allPaymentMethods // ignore: cast_nullable_to_non_nullable
                  as List<PaymentMethod>,
      ),
    );
  }
}

/// @nodoc

class _$PaymentMethodAddedImpl implements _PaymentMethodAdded {
  const _$PaymentMethodAddedImpl(
    this.paymentMethod,
    final List<PaymentMethod> allPaymentMethods,
  ) : _allPaymentMethods = allPaymentMethods;

  @override
  final PaymentMethod paymentMethod;
  final List<PaymentMethod> _allPaymentMethods;
  @override
  List<PaymentMethod> get allPaymentMethods {
    if (_allPaymentMethods is EqualUnmodifiableListView)
      return _allPaymentMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allPaymentMethods);
  }

  @override
  String toString() {
    return 'PaymentState.paymentMethodAdded(paymentMethod: $paymentMethod, allPaymentMethods: $allPaymentMethods)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentMethodAddedImpl &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            const DeepCollectionEquality().equals(
              other._allPaymentMethods,
              _allPaymentMethods,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    paymentMethod,
    const DeepCollectionEquality().hash(_allPaymentMethods),
  );

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentMethodAddedImplCopyWith<_$PaymentMethodAddedImpl> get copyWith =>
      __$$PaymentMethodAddedImplCopyWithImpl<_$PaymentMethodAddedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return paymentMethodAdded(paymentMethod, allPaymentMethods);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return paymentMethodAdded?.call(paymentMethod, allPaymentMethods);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (paymentMethodAdded != null) {
      return paymentMethodAdded(paymentMethod, allPaymentMethods);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return paymentMethodAdded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return paymentMethodAdded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (paymentMethodAdded != null) {
      return paymentMethodAdded(this);
    }
    return orElse();
  }
}

abstract class _PaymentMethodAdded implements PaymentState {
  const factory _PaymentMethodAdded(
    final PaymentMethod paymentMethod,
    final List<PaymentMethod> allPaymentMethods,
  ) = _$PaymentMethodAddedImpl;

  PaymentMethod get paymentMethod;
  List<PaymentMethod> get allPaymentMethods;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentMethodAddedImplCopyWith<_$PaymentMethodAddedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PaymentMethodRemovedImplCopyWith<$Res> {
  factory _$$PaymentMethodRemovedImplCopyWith(
    _$PaymentMethodRemovedImpl value,
    $Res Function(_$PaymentMethodRemovedImpl) then,
  ) = __$$PaymentMethodRemovedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<PaymentMethod> paymentMethods});
}

/// @nodoc
class __$$PaymentMethodRemovedImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$PaymentMethodRemovedImpl>
    implements _$$PaymentMethodRemovedImplCopyWith<$Res> {
  __$$PaymentMethodRemovedImplCopyWithImpl(
    _$PaymentMethodRemovedImpl _value,
    $Res Function(_$PaymentMethodRemovedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? paymentMethods = null}) {
    return _then(
      _$PaymentMethodRemovedImpl(
        null == paymentMethods
            ? _value._paymentMethods
            : paymentMethods // ignore: cast_nullable_to_non_nullable
                  as List<PaymentMethod>,
      ),
    );
  }
}

/// @nodoc

class _$PaymentMethodRemovedImpl implements _PaymentMethodRemoved {
  const _$PaymentMethodRemovedImpl(final List<PaymentMethod> paymentMethods)
    : _paymentMethods = paymentMethods;

  final List<PaymentMethod> _paymentMethods;
  @override
  List<PaymentMethod> get paymentMethods {
    if (_paymentMethods is EqualUnmodifiableListView) return _paymentMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_paymentMethods);
  }

  @override
  String toString() {
    return 'PaymentState.paymentMethodRemoved(paymentMethods: $paymentMethods)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentMethodRemovedImpl &&
            const DeepCollectionEquality().equals(
              other._paymentMethods,
              _paymentMethods,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_paymentMethods),
  );

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentMethodRemovedImplCopyWith<_$PaymentMethodRemovedImpl>
  get copyWith =>
      __$$PaymentMethodRemovedImplCopyWithImpl<_$PaymentMethodRemovedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return paymentMethodRemoved(paymentMethods);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return paymentMethodRemoved?.call(paymentMethods);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (paymentMethodRemoved != null) {
      return paymentMethodRemoved(paymentMethods);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return paymentMethodRemoved(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return paymentMethodRemoved?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (paymentMethodRemoved != null) {
      return paymentMethodRemoved(this);
    }
    return orElse();
  }
}

abstract class _PaymentMethodRemoved implements PaymentState {
  const factory _PaymentMethodRemoved(
    final List<PaymentMethod> paymentMethods,
  ) = _$PaymentMethodRemovedImpl;

  List<PaymentMethod> get paymentMethods;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentMethodRemovedImplCopyWith<_$PaymentMethodRemovedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DefaultPaymentMethodSetImplCopyWith<$Res> {
  factory _$$DefaultPaymentMethodSetImplCopyWith(
    _$DefaultPaymentMethodSetImpl value,
    $Res Function(_$DefaultPaymentMethodSetImpl) then,
  ) = __$$DefaultPaymentMethodSetImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<PaymentMethod> paymentMethods});
}

/// @nodoc
class __$$DefaultPaymentMethodSetImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$DefaultPaymentMethodSetImpl>
    implements _$$DefaultPaymentMethodSetImplCopyWith<$Res> {
  __$$DefaultPaymentMethodSetImplCopyWithImpl(
    _$DefaultPaymentMethodSetImpl _value,
    $Res Function(_$DefaultPaymentMethodSetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? paymentMethods = null}) {
    return _then(
      _$DefaultPaymentMethodSetImpl(
        null == paymentMethods
            ? _value._paymentMethods
            : paymentMethods // ignore: cast_nullable_to_non_nullable
                  as List<PaymentMethod>,
      ),
    );
  }
}

/// @nodoc

class _$DefaultPaymentMethodSetImpl implements _DefaultPaymentMethodSet {
  const _$DefaultPaymentMethodSetImpl(final List<PaymentMethod> paymentMethods)
    : _paymentMethods = paymentMethods;

  final List<PaymentMethod> _paymentMethods;
  @override
  List<PaymentMethod> get paymentMethods {
    if (_paymentMethods is EqualUnmodifiableListView) return _paymentMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_paymentMethods);
  }

  @override
  String toString() {
    return 'PaymentState.defaultPaymentMethodSet(paymentMethods: $paymentMethods)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DefaultPaymentMethodSetImpl &&
            const DeepCollectionEquality().equals(
              other._paymentMethods,
              _paymentMethods,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_paymentMethods),
  );

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DefaultPaymentMethodSetImplCopyWith<_$DefaultPaymentMethodSetImpl>
  get copyWith =>
      __$$DefaultPaymentMethodSetImplCopyWithImpl<
        _$DefaultPaymentMethodSetImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return defaultPaymentMethodSet(paymentMethods);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return defaultPaymentMethodSet?.call(paymentMethods);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (defaultPaymentMethodSet != null) {
      return defaultPaymentMethodSet(paymentMethods);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return defaultPaymentMethodSet(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return defaultPaymentMethodSet?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (defaultPaymentMethodSet != null) {
      return defaultPaymentMethodSet(this);
    }
    return orElse();
  }
}

abstract class _DefaultPaymentMethodSet implements PaymentState {
  const factory _DefaultPaymentMethodSet(
    final List<PaymentMethod> paymentMethods,
  ) = _$DefaultPaymentMethodSetImpl;

  List<PaymentMethod> get paymentMethods;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DefaultPaymentMethodSetImplCopyWith<_$DefaultPaymentMethodSetImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WalletLoadedImplCopyWith<$Res> {
  factory _$$WalletLoadedImplCopyWith(
    _$WalletLoadedImpl value,
    $Res Function(_$WalletLoadedImpl) then,
  ) = __$$WalletLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Wallet wallet});
}

/// @nodoc
class __$$WalletLoadedImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$WalletLoadedImpl>
    implements _$$WalletLoadedImplCopyWith<$Res> {
  __$$WalletLoadedImplCopyWithImpl(
    _$WalletLoadedImpl _value,
    $Res Function(_$WalletLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? wallet = null}) {
    return _then(
      _$WalletLoadedImpl(
        null == wallet
            ? _value.wallet
            : wallet // ignore: cast_nullable_to_non_nullable
                  as Wallet,
      ),
    );
  }
}

/// @nodoc

class _$WalletLoadedImpl implements _WalletLoaded {
  const _$WalletLoadedImpl(this.wallet);

  @override
  final Wallet wallet;

  @override
  String toString() {
    return 'PaymentState.walletLoaded(wallet: $wallet)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletLoadedImpl &&
            (identical(other.wallet, wallet) || other.wallet == wallet));
  }

  @override
  int get hashCode => Object.hash(runtimeType, wallet);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletLoadedImplCopyWith<_$WalletLoadedImpl> get copyWith =>
      __$$WalletLoadedImplCopyWithImpl<_$WalletLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return walletLoaded(wallet);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return walletLoaded?.call(wallet);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (walletLoaded != null) {
      return walletLoaded(wallet);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return walletLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return walletLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (walletLoaded != null) {
      return walletLoaded(this);
    }
    return orElse();
  }
}

abstract class _WalletLoaded implements PaymentState {
  const factory _WalletLoaded(final Wallet wallet) = _$WalletLoadedImpl;

  Wallet get wallet;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletLoadedImplCopyWith<_$WalletLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WalletTransactionsLoadedImplCopyWith<$Res> {
  factory _$$WalletTransactionsLoadedImplCopyWith(
    _$WalletTransactionsLoadedImpl value,
    $Res Function(_$WalletTransactionsLoadedImpl) then,
  ) = __$$WalletTransactionsLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<WalletTransaction> transactions});
}

/// @nodoc
class __$$WalletTransactionsLoadedImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$WalletTransactionsLoadedImpl>
    implements _$$WalletTransactionsLoadedImplCopyWith<$Res> {
  __$$WalletTransactionsLoadedImplCopyWithImpl(
    _$WalletTransactionsLoadedImpl _value,
    $Res Function(_$WalletTransactionsLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? transactions = null}) {
    return _then(
      _$WalletTransactionsLoadedImpl(
        null == transactions
            ? _value._transactions
            : transactions // ignore: cast_nullable_to_non_nullable
                  as List<WalletTransaction>,
      ),
    );
  }
}

/// @nodoc

class _$WalletTransactionsLoadedImpl implements _WalletTransactionsLoaded {
  const _$WalletTransactionsLoadedImpl(
    final List<WalletTransaction> transactions,
  ) : _transactions = transactions;

  final List<WalletTransaction> _transactions;
  @override
  List<WalletTransaction> get transactions {
    if (_transactions is EqualUnmodifiableListView) return _transactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactions);
  }

  @override
  String toString() {
    return 'PaymentState.walletTransactionsLoaded(transactions: $transactions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletTransactionsLoadedImpl &&
            const DeepCollectionEquality().equals(
              other._transactions,
              _transactions,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_transactions),
  );

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletTransactionsLoadedImplCopyWith<_$WalletTransactionsLoadedImpl>
  get copyWith =>
      __$$WalletTransactionsLoadedImplCopyWithImpl<
        _$WalletTransactionsLoadedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return walletTransactionsLoaded(transactions);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return walletTransactionsLoaded?.call(transactions);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (walletTransactionsLoaded != null) {
      return walletTransactionsLoaded(transactions);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return walletTransactionsLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return walletTransactionsLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (walletTransactionsLoaded != null) {
      return walletTransactionsLoaded(this);
    }
    return orElse();
  }
}

abstract class _WalletTransactionsLoaded implements PaymentState {
  const factory _WalletTransactionsLoaded(
    final List<WalletTransaction> transactions,
  ) = _$WalletTransactionsLoadedImpl;

  List<WalletTransaction> get transactions;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletTransactionsLoadedImplCopyWith<_$WalletTransactionsLoadedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PaymentSettingsLoadedImplCopyWith<$Res> {
  factory _$$PaymentSettingsLoadedImplCopyWith(
    _$PaymentSettingsLoadedImpl value,
    $Res Function(_$PaymentSettingsLoadedImpl) then,
  ) = __$$PaymentSettingsLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<PaymentSetting> settings});
}

/// @nodoc
class __$$PaymentSettingsLoadedImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$PaymentSettingsLoadedImpl>
    implements _$$PaymentSettingsLoadedImplCopyWith<$Res> {
  __$$PaymentSettingsLoadedImplCopyWithImpl(
    _$PaymentSettingsLoadedImpl _value,
    $Res Function(_$PaymentSettingsLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? settings = null}) {
    return _then(
      _$PaymentSettingsLoadedImpl(
        null == settings
            ? _value._settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as List<PaymentSetting>,
      ),
    );
  }
}

/// @nodoc

class _$PaymentSettingsLoadedImpl implements _PaymentSettingsLoaded {
  const _$PaymentSettingsLoadedImpl(final List<PaymentSetting> settings)
    : _settings = settings;

  final List<PaymentSetting> _settings;
  @override
  List<PaymentSetting> get settings {
    if (_settings is EqualUnmodifiableListView) return _settings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_settings);
  }

  @override
  String toString() {
    return 'PaymentState.paymentSettingsLoaded(settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentSettingsLoadedImpl &&
            const DeepCollectionEquality().equals(other._settings, _settings));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_settings));

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentSettingsLoadedImplCopyWith<_$PaymentSettingsLoadedImpl>
  get copyWith =>
      __$$PaymentSettingsLoadedImplCopyWithImpl<_$PaymentSettingsLoadedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return paymentSettingsLoaded(settings);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return paymentSettingsLoaded?.call(settings);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (paymentSettingsLoaded != null) {
      return paymentSettingsLoaded(settings);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return paymentSettingsLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return paymentSettingsLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (paymentSettingsLoaded != null) {
      return paymentSettingsLoaded(this);
    }
    return orElse();
  }
}

abstract class _PaymentSettingsLoaded implements PaymentState {
  const factory _PaymentSettingsLoaded(final List<PaymentSetting> settings) =
      _$PaymentSettingsLoadedImpl;

  List<PaymentSetting> get settings;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentSettingsLoadedImplCopyWith<_$PaymentSettingsLoadedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'PaymentState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() processing,
    required TResult Function() loaded,
    required TResult Function(String clientSecret, String paymentIntentId)
    paymentIntentCreated,
    required TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )
    requiresAction,
    required TResult Function() paymentConfirmed,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodsLoaded,
    required TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )
    paymentMethodAdded,
    required TResult Function(List<PaymentMethod> paymentMethods)
    paymentMethodRemoved,
    required TResult Function(List<PaymentMethod> paymentMethods)
    defaultPaymentMethodSet,
    required TResult Function(Wallet wallet) walletLoaded,
    required TResult Function(List<WalletTransaction> transactions)
    walletTransactionsLoaded,
    required TResult Function(List<PaymentSetting> settings)
    paymentSettingsLoaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? processing,
    TResult? Function()? loaded,
    TResult? Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult? Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult? Function()? paymentConfirmed,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult? Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult? Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult? Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult? Function(Wallet wallet)? walletLoaded,
    TResult? Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult? Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? processing,
    TResult Function()? loaded,
    TResult Function(String clientSecret, String paymentIntentId)?
    paymentIntentCreated,
    TResult Function(
      String clientSecret,
      String paymentIntentId,
      Map<String, dynamic> nextAction,
    )?
    requiresAction,
    TResult Function()? paymentConfirmed,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodsLoaded,
    TResult Function(
      PaymentMethod paymentMethod,
      List<PaymentMethod> allPaymentMethods,
    )?
    paymentMethodAdded,
    TResult Function(List<PaymentMethod> paymentMethods)? paymentMethodRemoved,
    TResult Function(List<PaymentMethod> paymentMethods)?
    defaultPaymentMethodSet,
    TResult Function(Wallet wallet)? walletLoaded,
    TResult Function(List<WalletTransaction> transactions)?
    walletTransactionsLoaded,
    TResult Function(List<PaymentSetting> settings)? paymentSettingsLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_PaymentIntentCreated value) paymentIntentCreated,
    required TResult Function(_RequiresAction value) requiresAction,
    required TResult Function(_PaymentConfirmed value) paymentConfirmed,
    required TResult Function(_PaymentMethodsLoaded value) paymentMethodsLoaded,
    required TResult Function(_PaymentMethodAdded value) paymentMethodAdded,
    required TResult Function(_PaymentMethodRemoved value) paymentMethodRemoved,
    required TResult Function(_DefaultPaymentMethodSet value)
    defaultPaymentMethodSet,
    required TResult Function(_WalletLoaded value) walletLoaded,
    required TResult Function(_WalletTransactionsLoaded value)
    walletTransactionsLoaded,
    required TResult Function(_PaymentSettingsLoaded value)
    paymentSettingsLoaded,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult? Function(_RequiresAction value)? requiresAction,
    TResult? Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult? Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult? Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult? Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult? Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult? Function(_WalletLoaded value)? walletLoaded,
    TResult? Function(_WalletTransactionsLoaded value)?
    walletTransactionsLoaded,
    TResult? Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_PaymentIntentCreated value)? paymentIntentCreated,
    TResult Function(_RequiresAction value)? requiresAction,
    TResult Function(_PaymentConfirmed value)? paymentConfirmed,
    TResult Function(_PaymentMethodsLoaded value)? paymentMethodsLoaded,
    TResult Function(_PaymentMethodAdded value)? paymentMethodAdded,
    TResult Function(_PaymentMethodRemoved value)? paymentMethodRemoved,
    TResult Function(_DefaultPaymentMethodSet value)? defaultPaymentMethodSet,
    TResult Function(_WalletLoaded value)? walletLoaded,
    TResult Function(_WalletTransactionsLoaded value)? walletTransactionsLoaded,
    TResult Function(_PaymentSettingsLoaded value)? paymentSettingsLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements PaymentState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
