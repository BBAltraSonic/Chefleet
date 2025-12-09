import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chefleet/core/diagnostics/testing/diagnostic_harness_config.dart';
import '../lib/core/diagnostics/testing/diagnostic_test_binding.dart';

const bool _diagnosticsDisabled = bool.fromEnvironment('DISABLE_TEST_DIAGNOSTICS');

bool _tearDownRegistered = false;
bool _diagnosticsEnabled = false;

/// Enables the diagnostic harness for widget/unit tests.
void enableTestDiagnostics({
  String? suiteName,
  Map<String, String> attributes = const <String, String>{},
}) {
  if (_diagnosticsEnabled) {
    return;
  }
  if (_diagnosticsDisabled) {
    debugPrint('⚠️ Diagnostics disabled via DISABLE_TEST_DIAGNOSTICS');
    return;
  }

  final resolvedRunName = suiteName ?? _defaultSuiteName();
  DiagnosticTestBinding.ensureInitialized(
    runName: resolvedRunName,
    attributes: <String, String>{
      'suite': resolvedRunName,
      ...attributes,
    },
  );
  _diagnosticsEnabled = true;
  _registerTearDownOnce();
}

/// Disables diagnostics and disposes all configured sinks.
Future<void> disableTestDiagnostics() async {
  if (!_diagnosticsEnabled) {
    return;
  }
  await DiagnosticHarnessConfigurator.reset();
  _diagnosticsEnabled = false;
}

String _defaultSuiteName() {
  final envOverride = Platform.environment['TEST_SUITE'];
  if (envOverride != null && envOverride.trim().isNotEmpty) {
    return envOverride.trim();
  }
  return 'unit-tests';
}

void _registerTearDownOnce() {
  if (_tearDownRegistered) {
    return;
  }
  tearDownAll(() async {
    await disableTestDiagnostics();
  });
  _tearDownRegistered = true;
}
