import 'dart:async';

import '../diagnostic_context.dart';
import '../diagnostic_harness.dart';

class CorrelationScopes {
  const CorrelationScopes._();

  static final DiagnosticHarness _harness = DiagnosticHarness.instance;

  static FutureOr<T> runGuest<T>(String guestId, FutureOr<T> Function() body) {
    return _runScoped('guest', 'guest-$guestId', body);
  }

  static FutureOr<T> runUser<T>(String userId, FutureOr<T> Function() body) {
    return _runScoped('user', 'user-$userId', body);
  }

  static FutureOr<T> runOrder<T>(String orderId, FutureOr<T> Function() body) {
    return _runScoped('order', 'order-$orderId', body);
  }

  static FutureOr<T> _runScoped<T>(
    String key,
    String value,
    FutureOr<T> Function() body,
  ) {
    final scopedContext = _harness.currentContext.withScope(key, value);
    return _harness.runInContext(scopedContext, body);
  }
}
