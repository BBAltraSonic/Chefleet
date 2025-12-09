import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../diagnostic_domains.dart';
import '../diagnostic_harness.dart';
import '../diagnostic_severity.dart';

/// Diagnostic-aware wrappers around common [WidgetTester] interactions.
///
/// These helpers emit structured events to the diagnostic harness before executing
/// the underlying tester action, so diagnostics timelines include UI intent (tap,
/// drag, text entry, navigation). This enables:
/// - Fast triage of UI-level failures via terminal logs
/// - Correlation of user gestures to backend events (cart updates, orders, etc.)
/// - Deterministic replays of test interactions
///
/// ## Usage Pattern
///
/// 1. Import this file in your test:
///    ```dart
///    import 'package:chefleet/core/diagnostics/testing/diagnostic_tester_helpers.dart';
///    ```
///
/// 2. Replace standard tester calls with diagnostic equivalents:
///    ```dart
///    // Before:
///    await tester.tap(find.text('Add to Cart'));
///    await tester.pumpAndSettle();
///
///    // After:
///    await diagnosticTap(tester, find.text('Add to Cart'), description: 'add item to cart');
///    await diagnosticPumpAndSettle(tester);
///    ```
///
/// 3. Provide descriptive context in the `description` parameter for clarity in logs.
///
/// ## Helper Functions
///
/// - **diagnosticTap**: Logs a pointer tap event before calling tester.tap()
/// - **diagnosticTapAt**: Logs a tap at specific coordinates
/// - **diagnosticEnterText**: Logs text entry before calling tester.enterText()
/// - **diagnosticDrag**: Logs a drag/swipe gesture before calling tester.drag()
/// - **diagnosticEnsureVisible**: Logs scrolling to ensure widget visibility
/// - **diagnosticPump**: Logs animation frame advances
/// - **diagnosticPumpAndSettle**: Logs wait-for-settle with frame count and duration
/// - **diagnosticNavigate**: Combines tap + settle for navigation actions
///
/// ## Behavior When Harness is Disabled
///
/// When the diagnostic harness is disabled (via CI_DIAGNOSTICS=false or test config),
/// these helpers delegate directly to the corresponding tester methods with no overhead.
/// This means you can safely use them everywhere without performance impact in CI/cd.
///
/// ## Domain & Event Mapping
///
/// All helpers log to `DiagnosticDomains.uiTester` with events following this pattern:
/// - `ui.pointer.tap`, `ui.pointer.tap.complete`, `ui.pointer.tap.error`
/// - `ui.text.enter`, `ui.text.enter.complete`, `ui.text.enter.error`
/// - `ui.pump`, `ui.pumpAndSettle`, `ui.navigation.*`
///
/// Payloads include widget metadata (type, key, text content) and timing info
/// for performance analysis. See payload structure in payload metadata helpers below.
///
/// ## Integration Test Usage
///
/// In `integration_test/*.dart` files, ensure the test imports diagnostic_harness.dart
/// and calls `ensureIntegrationDiagnostics(scenarioName: '...')` before defining groups:
/// ```dart
/// import 'diagnostic_harness.dart';
///
/// void main() {
///   ensureIntegrationDiagnostics(scenarioName: 'my_flow');
///   group('My Flow Tests', () { ... });
/// }
/// ```
///
/// See `docs/DIAGNOSTIC_LOGGING.md` for complete documentation.
Future<void> diagnosticTap(
  WidgetTester tester,
  Finder target, {
  String? description,
  int? pointer,
  bool warnIfMissed = true,
}) {
  return _logWidgetAction(
    tester: tester,
    target: target,
    action: 'ui.pointer.tap',
    description: description,
    extraPayload: <String, Object?>{
      if (pointer != null) 'pointer': pointer,
      'warnIfMissed': warnIfMissed,
    },
    body: () => tester.tap(target, pointer: pointer, warnIfMissed: warnIfMissed),
  );
}

Future<void> diagnosticTapAt(
  WidgetTester tester,
  Offset position, {
  String? description,
}) {
  return _logHarnessAction(
    action: 'ui.pointer.tapAt',
    description: description ?? 'tap at ${position.dx},${position.dy}',
    payload: <String, Object?>{'position': position.toString()},
    body: () => tester.tapAt(position),
  );
}

Future<void> diagnosticEnterText(
  WidgetTester tester,
  Finder target,
  String text, {
  String? description,
}) {
  return _logWidgetAction(
    tester: tester,
    target: target,
    action: 'ui.text.enter',
    description: description,
    extraPayload: <String, Object?>{'textLength': text.length},
    body: () => tester.enterText(target, text),
  );
}

Future<void> diagnosticDrag(
  WidgetTester tester,
  Finder target,
  Offset offset, {
  int? pointer,
  String? description,
}) {
  return _logWidgetAction(
    tester: tester,
    target: target,
    action: 'ui.pointer.drag',
    description: description,
    extraPayload: <String, Object?>{
      'offset': offset.toString(),
      if (pointer != null) 'pointer': pointer,
    },
    body: () => tester.drag(target, offset, pointer: pointer),
  );
}

Future<void> diagnosticEnsureVisible(
  WidgetTester tester,
  Finder target, {
  String? description,
}) {
  return _logWidgetAction(
    tester: tester,
    target: target,
    action: 'ui.navigation.ensureVisible',
    description: description,
    body: () => tester.ensureVisible(target),
  );
}

Future<void> diagnosticPump(
  WidgetTester tester, {
  Duration duration = Duration.zero,
  String? description,
}) {
  return _logHarnessAction(
    action: 'ui.pump',
    description: description ?? 'pump ${duration.inMilliseconds}ms',
    payload: <String, Object?>{'durationMs': duration.inMilliseconds},
    body: () => tester.pump(duration),
  );
}

Future<void> diagnosticPumpAndSettle(
  WidgetTester tester, {
  Duration duration = const Duration(milliseconds: 100),
  Duration timeout = const Duration(minutes: 5),
  String? description,
}) {
  return _logHarnessAction(
    action: 'ui.pumpAndSettle',
    description: description ?? 'pumpAndSettle',
    payload: <String, Object?>{
      'stepDurationMs': duration.inMilliseconds,
      'timeoutMs': timeout.inMilliseconds,
    },
    body: () async {
      // pumpAndSettle uses first param as duration, second as timeout
      await tester.pumpAndSettle(duration);
    },
  );
}Future<void> diagnosticNavigate(
  WidgetTester tester,
  Finder target, {
  Duration settleDuration = const Duration(milliseconds: 300),
  String? description,
}) async {
  await diagnosticTap(
    tester,
    target,
    description: description ?? 'navigation tap',
  );
  await diagnosticPumpAndSettle(
    tester,
    duration: settleDuration,
    description: 'settle after navigation',
  );
}

Future<void> _logWidgetAction({
  required WidgetTester tester,
  required Finder target,
  required String action,
  required Future<void> Function() body,
  Map<String, Object?> extraPayload = const <String, Object?>{},
  String? description,
}) async {
  final harness = DiagnosticHarness.instance;
  if (!harness.isEnabled) {
    await body();
    return;
  }

  final stopwatch = Stopwatch()..start();
  final payload = _metadataForFinder(target, description)
    ..addAll(extraPayload);

  harness.log(
    domain: DiagnosticDomains.uiTester,
    event: action,
    payload: payload,
  );

  try {
    await body();
    stopwatch.stop();
    harness.log(
      domain: DiagnosticDomains.uiTester,
      event: '$action.complete',
      payload: <String, Object?>{
        ...payload,
        'elapsedMs': stopwatch.elapsedMilliseconds,
      },
    );
  } catch (error, stackTrace) {
    stopwatch.stop();
    harness.log(
      domain: DiagnosticDomains.uiTester,
      event: '$action.error',
      severity: DiagnosticSeverity.error,
      payload: <String, Object?>{
        ...payload,
        'elapsedMs': stopwatch.elapsedMilliseconds,
        'error': error.toString(),
      },
      extra: stackTrace.toString(),
    );
    rethrow;
  }
}

Future<void> _logHarnessAction({
  required String action,
  required Future<void> Function() body,
  Map<String, Object?> payload = const <String, Object?>{},
  String? description,
}) async {
  final harness = DiagnosticHarness.instance;
  if (!harness.isEnabled) {
    await body();
    return;
  }

  final stopwatch = Stopwatch()..start();
  final actionPayload = <String, Object?>{
    if (description != null) 'description': description,
    ...payload,
  };

  harness.log(
    domain: DiagnosticDomains.uiTester,
    event: action,
    payload: actionPayload,
  );

  try {
    await body();
    stopwatch.stop();
    harness.log(
      domain: DiagnosticDomains.uiTester,
      event: '$action.complete',
      payload: <String, Object?>{
        ...actionPayload,
        'elapsedMs': stopwatch.elapsedMilliseconds,
      },
    );
  } catch (error, stackTrace) {
    stopwatch.stop();
    harness.log(
      domain: DiagnosticDomains.uiTester,
      event: '$action.error',
      severity: DiagnosticSeverity.error,
      payload: <String, Object?>{
        ...actionPayload,
        'elapsedMs': stopwatch.elapsedMilliseconds,
        'error': error.toString(),
      },
      extra: stackTrace.toString(),
    );
    rethrow;
  }
}

Map<String, Object?> _metadataForFinder(Finder target, String? description) {
  final matches = target.evaluate().toList();
  final element = matches.isEmpty ? null : matches.first;
  final widget = element?.widget;
  final key = widget?.key;

  return <String, Object?>{
    if (description != null) 'description': description,
    'finder': target.description,
    'matchCount': matches.length,
    if (widget != null) 'widgetType': widget.runtimeType.toString(),
    if (key != null) 'widgetKey': key.toString(),
    if (widget is Text) 'text': widget.data ?? widget.textSpan?.toPlainText(),
    if (widget is Icon) 'icon': widget.icon?.codePoint,
  };
}
