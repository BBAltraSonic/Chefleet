# Runtime Diagnostic Logging Guide

This document describes how to use the Chefleet diagnostic logging harness to emit structured traces, retrieve diagnostics artifacts, and assert on logs in tests.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Enablement](#enablement)
3. [Diagnostic Domains & Events](#diagnostic-domains--events)
4. [Tester Helpers](#tester-helpers)
5. [Payload Schema](#payload-schema)
6. [Correlation Scopes](#correlation-scopes)
7. [CI Integration & Artifacts](#ci-integration--artifacts)
8. [Test Assertions](#test-assertions)
9. [Redaction & Privacy](#redaction--privacy)

## Quick Start

### For Test Authors

**Import diagnostic helpers:**
```dart
import 'package:chefleet/core/diagnostics/testing/diagnostic_tester_helpers.dart';
import 'integration_test/diagnostic_harness.dart';
```

**Use in tests:**
```dart
void main() {
  // Initialize diagnostics for integration tests
  ensureIntegrationDiagnostics(scenarioName: 'my_flow');
  
  group('My Tests', () {
    testWidgets('example test', (tester) async {
      // Replace tester.tap() with diagnosticTap()
      await diagnosticTap(tester, find.text('Button'), description: 'click button');
      
      // Replace tester.pumpAndSettle() with diagnosticPumpAndSettle()
      await diagnosticPumpAndSettle(tester, description: 'wait for transition');
      
      expect(find.text('Result'), findsOneWidget);
    });
  });
}
```

### For Local Development

**Enable diagnostics in flutter_test_config.dart:**
The test harness automatically enables diagnostics when running `flutter test`. Logs are streamed to stdout in JSONL format.

**View logs during test run:**
```bash
flutter test --define CI_DIAGNOSTICS=true 2>&1 | grep 'ui\.'
```

## Enablement

### Environment Variables

- **CI_DIAGNOSTICS=true**: Enable harness in CI/Flutter test runs (default: auto-detected)
- **DIAGNOSTIC_SINK_TYPE**: Choose sink: `stdout` (default), `memory`, or `file`
- **DIAGNOSTIC_OUTPUT_DIR**: Directory for file-based sinks (default: `build/diagnostics/<run-name>/`)

### Test Configuration

**Unit/Widget tests** (`flutter_test_config.dart`):
```dart
import 'test/test_harness.dart';
```
This auto-initializes `DiagnosticTestBinding` for all unit/widget tests.

**Integration tests** (`integration_test/*.dart`):
```dart
import 'diagnostic_harness.dart';

void main() {
  ensureIntegrationDiagnostics(scenarioName: 'my_scenario');
  // ... rest of test file
}
```

## Diagnostic Domains & Events

Domains organize logs by feature/system. Events are specific actions within each domain.

### Core Domains

| Domain | Events | Example |
|--------|--------|---------|
| `auth` | `auth.start`, `auth.success`, `auth.error` | User login |
| `ordering` | `ordering.create_order.request`, `ordering.create_order.response` | Cart checkout |
| `chat` | `chat.send`, `chat.receive`, `chat.ack` | Message flow |
| `vendor_dashboard` | `vendor_dashboard.load`, `vendor_dashboard.accept_order` | Vendor actions |
| `buyer_map_feed` | `buyer_map_feed.viewport_change`, `buyer_map_feed.fetch` | Map/feed queries |
| `guest_conversion` | `guest_conversion.start`, `guest_conversion.success` | Guest→registered flow |
| `system_services` | `system_services.supabase.request`, `system_services.supabase.response` | Backend RPC calls |
| `ui.pointer` | `ui.pointer.tap`, `ui.pointer.drag` | Pointer events |
| `ui.tester` | `ui.pump`, `ui.pumpAndSettle`, `ui.text.enter` | Test helper actions |

## Tester Helpers

Tester helpers log UI interactions before executing the action, providing correlation with backend events.

### Available Helpers

#### diagnosticTap
Logs a pointer tap event with widget metadata.

```dart
await diagnosticTap(
  tester,
  find.text('Add to Cart'),
  description: 'add item to cart',
);
```

**Logged Event:**
- `ui.pointer.tap` (start)
- `ui.pointer.tap.complete` (on success, with elapsed time)
- `ui.pointer.tap.error` (on failure, with error message)

#### diagnosticTapAt
Logs a tap at specific screen coordinates.

```dart
await diagnosticTapAt(tester, Offset(100, 200));
```

#### diagnosticEnterText
Logs text entry before calling `tester.enterText()`.

```dart
await diagnosticEnterText(tester, find.byType(TextField), 'search term', description: 'enter search');
```

#### diagnosticDrag
Logs a drag/swipe gesture.

```dart
await diagnosticDrag(
  tester,
  find.text('Swipe me'),
  const Offset(100, 0),
  description: 'swipe left',
);
```

#### diagnosticEnsureVisible
Logs scrolling to ensure a widget is visible.

```dart
await diagnosticEnsureVisible(tester, find.text('Bottom item'));
```

#### diagnosticPump
Logs animation frame advances.

```dart
await diagnosticPump(tester, duration: const Duration(milliseconds: 500));
```

#### diagnosticPumpAndSettle
Logs waiting for the UI to settle after animations.

```dart
await diagnosticPumpAndSettle(tester, description: 'wait for dialog');
```

#### diagnosticNavigate
Convenience helper combining `diagnosticTap` + `diagnosticPumpAndSettle`.

```dart
await diagnosticNavigate(tester, find.text('Next'), description: 'navigate to next page');
```

## Payload Schema

Each diagnostic log entry contains structured JSON with:

```json
{
  "timestamp": "2025-01-15T10:30:45.123Z",
  "domain": "ui.pointer",
  "event": "ui.pointer.tap",
  "severity": "info",
  "correlationId": "test-case-abc123",
  "payload": {
    "description": "add item to cart",
    "finder": "find.text('Add to Cart')",
    "matchCount": 1,
    "widgetType": "ElevatedButton",
    "widgetKey": "cart_button_key",
    "elapsedMs": 45
  },
  "extra": null
}
```

### Payload Fields

| Field | Purpose |
|-------|---------|
| `timestamp` | RFC3339 UTC timestamp |
| `domain` | Domain (e.g., `ui.pointer`, `ordering`) |
| `event` | Event type (e.g., `ui.pointer.tap`, `ui.pointer.tap.complete`) |
| `severity` | `debug`, `info`, `warning`, `error` |
| `correlationId` | Trace ID linking related events (test case ID, order ID, etc.) |
| `payload` | Action-specific metadata |
| `extra` | Stack traces or error details (for errors) |

## Correlation Scopes

Correlation IDs link related events across domains (e.g., UI tap → backend order creation).

### Using Scoped Contexts

**In tests:**
```dart
final guard = DiagnosticHarness.instance.runScoped(
  'order',
  'order-123',
  () async {
    await diagnosticTap(tester, find.text('Checkout'));
    // All logs here inherit correlationId = 'order-123'
  },
);
```

**In services:**
```dart
Future<void> convertGuestToRegistered(String guestId) async {
  final guard = harness.runScoped('guest', guestId, () async {
    // Logs will be tagged with guest-id correlation
    final user = await supabase.rpc('convert_guest_to_user', params: {...});
    return user;
  });
}
```

## CI Integration & Artifacts

### GitHub Actions

Diagnostics are automatically captured in CI when `flutter test` runs with the default config:

**Standard output:**
```bash
flutter test
# Logs streamed to stdout in JSONL format
```

**Artifact storage:**
Logs are saved to `build/diagnostics/<run-name>/`:
- `stdout.jsonl`: All JSONL events
- `test-results.json`: Test summary with file locations

### Retrieving Artifacts

In GitHub Actions, artifacts are uploaded per job:
```yaml
- name: Upload diagnostic logs
  if: always()
  uses: actions/upload-artifact@v3
  with:
    name: diagnostics-${{ matrix.flutter-version }}
    path: build/diagnostics/**
```

**Download locally:**
```bash
# From GitHub Actions run
gh run download <run-id> -n diagnostics-stable
cat diagnostics-stable/stdout.jsonl | jq '.event'
```

## Test Assertions

Use `MemoryDiagnosticSink` to assert on logs within tests.

### Example: Assert on Log Sequence

```dart
testWidgets('order creation logs expected events', (tester) async {
  final sink = MemoryDiagnosticSink();
  DiagnosticHarness.instance.addSink(sink);
  
  // Perform action
  await diagnosticTap(tester, find.text('Checkout'));
  await diagnosticPumpAndSettle(tester);
  
  // Assert on logs
  final logs = sink.getEvents();
  expect(logs.map((e) => e.event), containsAll([
    'ui.pointer.tap',
    'ui.pointer.tap.complete',
    'ui.pumpAndSettle',
  ]));
});
```

### Helper: DiagnosticLogMatcher

```dart
// Assert event was logged with specific payload
expect(
  sink.getEvents(),
  contains(
    isA<DiagnosticEvent>()
        .having((e) => e.domain, 'domain', 'ui.pointer')
        .having((e) => e.event, 'event', 'ui.pointer.tap')
        .having((e) => e.payload['description'], 'description', 'add to cart'),
  ),
);
```

## Redaction & Privacy

Sensitive fields (passwords, tokens, PII) are automatically redacted from payloads.

### Redacted Fields

Default redaction patterns:
- Fields containing `password`, `token`, `secret`, `apiKey`, `bearerToken`
- Values containing `@` (emails)
- Credit card numbers (16+ digits)
- Phone numbers (10+ digits with formatting)

### Custom Redaction

To redact custom fields:

```dart
DiagnosticHarness.instance.configure(
  redactionPatterns: [
    RegExp(r'ssn'),
    RegExp(r'medicalId'),
  ],
);
```

## Troubleshooting

### Logs not appearing?

1. **Check enablement:** `flutter test --define CI_DIAGNOSTICS=true`
2. **Verify binding:** Ensure `flutter_test_config.dart` is imported first in test files
3. **Integration tests:** Call `ensureIntegrationDiagnostics()` before `group()` definitions

### Logs contain redacted values?

1. Review redaction patterns in `DiagnosticHarness.configure()`
2. Add your field to `redactionPatterns` if it contains sensitive data
3. Test with `MemoryDiagnosticSink` to inspect payloads locally

### Performance degradation in tests?

1. Diagnostics are **disabled by default** when `CI_DIAGNOSTICS != 'true'`
2. Test runtime should have **no overhead** when harness is disabled
3. To verify: Run `flutter test` without the env var and check timing

## Further Reading

- [Diagnostic Harness API](../lib/core/diagnostics/diagnostic_harness.dart)
- [Tester Helpers Implementation](../lib/core/diagnostics/testing/diagnostic_tester_helpers.dart)
- [Integration Harness Setup](../integration_test/diagnostic_harness.dart)
- [Test Binding Configuration](../lib/core/diagnostics/testing/diagnostic_test_binding.dart)
