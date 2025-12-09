# Diagnostic Logging Harness — Design Notes

## Context
Buyer and vendor flows span multiple BLoCs, repositories, Supabase calls, and widget interactions. When tests fail we only see assertion errors, not the sequence of actions that led there. Existing logging relies on `AppLogger` and ad-hoc `print` statements that only run in debug mode and are not structured, so CI logs give little insight. We need a deterministic, opt-in harness that instruments every critical interaction during automated tests and emits structured traces we can persist as artifacts.

## Goals / Non-Goals
- **Goals**
  - Provide deterministic, structured logs (JSON) for every significant runtime interaction triggered during tests.
  - Cover buyer core flows (map/feed/order, chat), vendor dashboard/order management, authentication, guest conversion, shared system services (Supabase, geolocation, push, storage).
  - Allow tests to enable/disable logging and fetch aggregated traces for assertions.
  - Preserve production performance by defaulting harness to "off" outside debug/test contexts.
- **Non-Goals**
  - Replacing existing analytics/telemetry stacks in production builds.
  - Persisting logs outside the test process (no remote upload yet).
  - Real-user session replay—focus is automated coverage first.

## Current State Audit
### Logging utilities
- `lib/core/utils/app_logger.dart` exposes `debug/info/warning/error` but only emits debug-level logs when `kDebugMode` is true, so CI/headless runs miss info/warn messages, and payloads are plain strings without metadata or correlation identifiers @lib/core/utils/app_logger.dart#1-48.
- `lib/core/blocs/app_bloc_observer.dart` hooks into bloc lifecycle and prints simple strings via `AppLogger`, but it only covers bloc-level events and still lacks structure/correlation @lib/core/blocs/app_bloc_observer.dart#1-28.
- Additional prints (e.g., `RoleRouteGuard._logUnauthorizedAccess`) rely on `kDebugMode` and emit free-form text @lib/core/routes/role_route_guard.dart#76-93.

### Critical flows lacking deterministic traces
1. **Buyer Map & Feed** – pan/debounce logic, feed query triggers, dish selection, cart state transitions.
2. **Order Creation** – edge function invocations, validation failures, BLoC transitions between cart → checkout → active order FAB.
3. **Chat** – optimistic send retries, realtime channel events, rate-limit warnings.
4. **Vendor Dashboard** – order queue updates, quick actions, dish status toggles.
5. **Authentication & Guest Conversion** – Supabase auth calls, metadata migrations, conversion prompts.
6. **Shared Services** – geolocation, opening hours validation, caching layers.

## Logging Domains & Events
| Domain | Typical Events | Notes |
| --- | --- | --- |
| `auth` | start/end of login/signup, Supabase auth responses, RLS errors | capture user role/context IDs
| `buyer_map_feed` | map idle, viewport query issued/completed, feed cache hits | include lat/lng bounds hash
| `ordering` | cart mutation, create_order request/response, FAB transitions, Supabase realtime updates | correlate by `orderId`
| `chat` | message queued/sent/acked, channel connectivity, retry attempts | correlate by `orderId` + `messageId`
| `vendor_dashboard` | order list sync, action taps (accept/prep/ready), dish toggle, quick replies | correlate by `vendorId`
| `guest_conversion` | prompt shown/dismissed, conversion attempt, edge function results | correlate by `userId`
| `system_services` | Supabase RPC calls, storage uploads, push notification dispatch, geolocation status | correlate by `requestId`

## Event Schema (JSON)
```jsonc
{
  "timestamp": "2025-12-05T04:46:12.123Z",
  "testCaseId": "buyer_flow_test should_place_order",
  "domain": "ordering",
  "event": "create_order.request",
  "correlationId": "order-abc123",
  "parentId": "session-xyz",
  "severity": "info",
  "payload": {
    "endpoint": "create_order",
    "cartItems": 2,
    "pickupSlot": "18:30"
  },
  "tags": ["edge_function", "supabase"],
  "extra": "optional string for quick scanning"
}
```
Field definitions:
- `timestamp` – UTC ISO8601 with millisecond precision.
- `testCaseId` – derived from `FlutterTestDescription` or manual label from helper mixin.
- `domain` – one of the table above.
- `event` – `namespace.action` pattern (e.g., `bloc.transition`, `supabase.request`).
- `correlationId` – stable identifier for the entity (orderId, vendorId, sessionId).
- `parentId` – allows hierarchical traces (e.g., map interaction session).
- `severity` – enum (`debug|info|warn|error`).
- `payload` – arbitrary JSON map, must remain serializable.
- `tags` – optional short strings for quick filtering.
- `extra` – free-form string reserved for human notes.

## Correlation & ID Strategy
- **Session ID** – each test run generates a root `session-<uuid>` stored in the harness.
- **Test Case ID** – for widget/unit tests use the `description` provided by the Flutter test framework. Integration tests pass a manual label via helper mixin.
- **Entity-specific IDs** – instrumentation points pass the domain entity: `order-{id}`, `vendor-{id}`, `user-{id}`. When no natural key exists, generate deterministic hashes (e.g., `mapViewport-{boundsHash}`).
- **Propagation** – harness exposes `DiagnosticContext.current()` so repos/BLoCs can fetch the active correlation IDs without threading dozens of parameters. Context is carried via `Zone` values during tests to remain thread-safe.

## Harness Architecture (High-Level)
1. **Harness Core** – singleton managing:
   - configuration (enabled domains, severity threshold, sinks),
   - registration of event sinks (stdout writer, in-memory buffer, file exporter),
   - context propagation helper (Zone-based) and correlation utilities.
2. **Instrumentation Adapters**
   - `BlocDiagnosticObserver` – extends `BlocObserver`, emits `bloc.create/change/error/close` with payloads referencing state types.
   - `RepositoryInstrumentation` – mixin/wrapper for repositories/services (order, chat, Supabase) that call `Harness.log()` before/after network/storage actions.
   - `SupabaseClientDiagnostics` – wrapper around Supabase client to log RPC inputs/outputs (with PII masking where necessary).
   - `WidgetInteractionLogger` – Flutter test utility that wraps `WidgetTester` actions (`tap`, `pump`, `enterText`) to emit `ui.interaction` events.
3. **Test Utilities**
   - `DiagnosticTestHarness` mixin sets up root session, attaches sinks, and flushes logs to stdout after each test (plus writes JSON artifact into `build/diagnostics/<test>.json`).
   - CLI helper script collects artifacts post-run (Task 3).

## Task 2 Deliverables — Detailed Design

### Core Types & API surface
- `DiagnosticEvent` data class mirrors the JSON schema and enforces `domain`, `event`, `severity`, `payload`, `timestamp`, `correlationId`, `testCaseId`, `tags`, `extra`.
- `DiagnosticHarness` singleton exposes:
  - `void configure(DiagnosticConfig config)` – set severity threshold, enabled domains, default sinks.
  - `void registerSink(DiagnosticSink sink)` / `void removeSink(String sinkId)` – sinks implement `void write(DiagnosticEvent event)`.
  - `void log({required String domain, required String event, DiagnosticSeverity severity = DiagnosticSeverity.info, String? correlationId, Map<String, Object?> payload = const {}, List<String> tags = const [], String? extra})` – builds event with current context/test metadata and dispatches to sinks.
  - `R runWithContext(DiagnosticContext context, R Function() body)` – wraps `Zone` to propagate correlation IDs throughout async gaps during tests.
  - `DiagnosticContext currentContext()` – returns ambient context; throws if harness disabled to avoid accidental production usage.

### Context & correlation plumbing
- `DiagnosticContext` holds `sessionId`, optional `testCaseId`, stack of `correlationScopes` (orderId, vendorId, etc.), and `traceAttributes` (custom key/value pairs).
- Tests invoke `DiagnosticTestHarness.setUpHarness(testInfo)` which:
  1. Generates a `session-<uuid>` root context.
  2. Registers default sinks (stdout + JSON file sink) unless overridden.
  3. Wraps the test body via `runWithContext` so any downstream async tasks inherit the root context automatically.
- Repositories/BLoCs call `DiagnosticContext.current().withScope('order', orderId)` before performing work; the returned disposable scope ensures nesting is unwound correctly (RAII pattern via `ScopeGuard`).

### Instrumentation adapters (per layer)
1. **BLoC layer**
   - `BlocDiagnosticObserver` extends `BlocObserver` and logs `bloc.created`, `bloc.state_change`, `bloc.error`, `bloc.closed` with payload of state transition summaries. Observer is wired once inside `main_test.dart` when harness enabled.
2. **Repositories/Services**
   - Introduce `DiagnosticRepositoryMixin` with helpers `logCallStart`, `logCallSuccess`, `logCallError`. Each helper accepts domain + correlation details and automatically includes repository name, method, and sanitized params.
   - Apply mixin to `OrderRepository`, `ChatRepository`, `SupabaseRepository`, `GuestConversionService`, etc.
3. **Supabase/HTTP clients**
   - Wrap Supabase client with `SupabaseDiagnosticClient` that intercepts `rpc`, `from`, and `auth` operations. Sensitive fields (passwords, tokens) are redacted before logging.
4. **Widget/Tester utilities**
   - Extend `WidgetTester` via helper functions (`diagnosticTap`, `diagnosticEnterText`, `diagnosticPump`) that log `ui.interaction` events with widget descriptions and semantics labels. These helpers internally call standard tester APIs to avoid behavior changes.

### Sink strategy
- **Stdout sink** – writes compact single-line JSON to stdout for immediate visibility during CI/test runs.
- **Memory sink** – accumulates events per test case so assertions can verify specific sequences (e.g., ensure `create_order.response` follows `create_order.request`).
- **File sink** – dumps prettified JSON array per test into `build/diagnostics/<test-case>.json` for post-mortem downloads.
- Sinks are pluggable; configuration specifies which sinks activate by default. Each sink receives events on the same isolate, so backpressure is handled by buffering; future work can add async/file batching if needed.

### Guardrails & production safety
- Harness initialization requires `kDebugMode || Platform.environment['CI_DIAGNOSTICS'] == 'true'`; otherwise `configure` throws to prevent enabling verbose logging in release builds.
- Event payload mutators perform depth-limited serialization (max depth 4) to avoid recursive models crashing tests.
- Sensitive fields are redacted via `SensitiveFieldRegistry` before events reach sinks.

### Integration touchpoints
1. `test/test_harness.dart` (new) configures harness per test suite and exposes helper mixins.
2. `integration_test/diagnostic_config.dart` ensures driver tests pass scenario names to the harness and collect artifacts via `IntegrationTestWidgetsFlutterBinding`.
3. `scripts/run_tests_with_logs.sh` (Task 3) will wrap `flutter test` to capture diagnostic files and attach them to CI artifacts.

These details provide the blueprint for implementing the harness (Task 2 execution) and ensure downstream teams understand the API contracts before instrumentation begins.

## Deliverables for Task 1
- Documented current-state audit (this section) covering existing logging utilities and coverage gaps.
- Enumerated critical flows requiring instrumentation.
- Defined logging domains, event schema, and correlation strategy.

These artifacts unblock Task 2 (API and instrumentation design) and Task 3 (test adoption/CI export).
