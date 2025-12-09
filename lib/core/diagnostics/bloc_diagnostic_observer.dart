import 'package:flutter_bloc/flutter_bloc.dart';

import 'diagnostic_harness.dart';
import 'diagnostic_severity.dart';

class BlocDiagnosticObserver extends BlocObserver {
  BlocDiagnosticObserver();

  final DiagnosticHarness _harness = DiagnosticHarness.instance;

  void _log(
    String event,
    BlocBase bloc, {
    Object? change,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_harness.isEnabled) return;
    _harness.log(
      domain: 'bloc',
      event: event,
      severity: error == null ? DiagnosticSeverity.debug : DiagnosticSeverity.error,
      payload: {
        'bloc': bloc.runtimeType.toString(),
        if (change != null) 'change': change.toString(),
        if (error != null) 'error': error.toString(),
      },
      extra: stackTrace?.toString(),
    );
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _log('bloc.create', bloc);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _log('bloc.change', bloc, change: change);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _log('bloc.error', bloc, error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    _log('bloc.close', bloc);
    super.onClose(bloc);
  }
}
