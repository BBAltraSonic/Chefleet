import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/core/diagnostics/testing/diagnostic_harness_config.dart';
import '../lib/core/diagnostics/testing/diagnostic_test_binding.dart';

const bool _diagnosticsDisabled = bool.fromEnvironment('DISABLE_TEST_DIAGNOSTICS');

IntegrationTestWidgetsFlutterBinding ensureIntegrationDiagnostics({
  String? scenarioName,
  Map<String, String> attributes = const <String, String>{},
}) {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  if (_diagnosticsDisabled) {
    debugPrint('⚠️ Diagnostics disabled via DISABLE_TEST_DIAGNOSTICS');
    return binding;
  }

  final resolvedScenario = scenarioName ?? _defaultScenarioName();
  DiagnosticTestBinding.ensureInitialized(
    runName: resolvedScenario,
    attributes: <String, String>{
      'mode': 'integration',
      'scenario': resolvedScenario,
      ...attributes,
    },
  );

  tearDownAll(() async {
    await DiagnosticHarnessConfigurator.reset();
  });

  return binding;
}

String _defaultScenarioName() {
  final envScenario = Platform.environment['INTEGRATION_SCENARIO'];
  if (envScenario != null && envScenario.trim().isNotEmpty) {
    return envScenario.trim();
  }
  return 'integration-tests';
}
