import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../diagnostic_harness.dart';
import '../diagnostic_severity.dart';
import 'diagnostic_harness_config.dart';

class DiagnosticTestBinding extends AutomatedTestWidgetsFlutterBinding {
  DiagnosticTestBinding._({
    required String runName,
    required Map<String, String> attributes,
  }) {
    debugPrint('DiagnosticTestBinding initialized for $runName');
    _configureHarness(runName, attributes);
  }

  static DiagnosticTestBinding ensureInitialized({
    String runName = 'unit-tests',
    Map<String, String> attributes = const <String, String>{},
  }) {
    if (WidgetsBinding.instance is! DiagnosticTestBinding) {
      DiagnosticTestBinding._(runName: runName, attributes: attributes);
    } else {
      (WidgetsBinding.instance as DiagnosticTestBinding)
          ._configureHarness(runName, attributes, ensureOnly: true);
    }
    return WidgetsBinding.instance as DiagnosticTestBinding;
  }

  final DiagnosticHarness _harness = DiagnosticHarness.instance;

  void _configureHarness(
    String runName,
    Map<String, String> attributes, {
    bool ensureOnly = false,
  }) {
    DiagnosticHarnessConfigurator.configure(
      runName: runName,
      attributes: <String, String>{
        'mode': 'unit',
        'platform': defaultTargetPlatform.name,
        ...attributes,
      },
    );
    if (!ensureOnly) {
      _harness.log(
        domain: 'test',
        event: 'test.binding_initialized',
        severity: DiagnosticSeverity.info,
        payload: {
          'runName': runName,
        },
      );
    }
  }

  @override
  Future<void> runTest(
    Future<void> Function() testBody,
    VoidCallback invariantTester, {
    String description = '',
    @Deprecated('This parameter has no effect. Use `timeout` on the test function instead.')
    Duration? timeout,
  }) {
    DiagnosticContextGuard? guard;
    if (_harness.isEnabled) {
      final scopedContext = _harness.createChildContext(testCaseId: description);
      guard = _harness.pushContext(scopedContext);
    }

    return super
        .runTest(
          testBody,
          invariantTester,
          description: description,
        )
        .whenComplete(() async {
      guard?.release();
      if (_harness.isEnabled) {
        await _harness.flush();
      }
    });
  }

  @override
  void handlePointerEvent(PointerEvent event) {
    if (_harness.isEnabled) {
      _harness.log(
        domain: 'ui.pointer',
        event: 'pointer.${event.runtimeType}',
        severity: DiagnosticSeverity.debug,
        payload: {
          'position': event.position.toString(),
          'kind': event.kind.name,
          'buttons': event.buttons,
        },
      );
    }
    super.handlePointerEvent(event);
  }
}
