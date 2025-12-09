import 'dart:async';

import 'test/test_harness.dart' as diagnostics;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  diagnostics.enableTestDiagnostics();
  await testMain();
  await diagnostics.disableTestDiagnostics();
}
