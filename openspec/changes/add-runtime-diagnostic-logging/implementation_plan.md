# Diagnostic Logging Harness — Implementation Plan

## 1. Core Harness Finalization
1.1 Complete `DiagnosticHarness` APIs (context stack, child contexts, payload sanitization, release guards).
1.2 Implement `DiagnosticHarnessConfigurator` to wire default sinks (stdout, memory, file) and respect env toggles (`CI_DIAGNOSTICS`).
1.3 Provide helper utilities for enabling/disabling diagnostics in unit tests, integration tests, and local debug runs.

## 2. Test Binding & Bootstrap
2.1 Create `DiagnosticTestBinding` (unit/widget) and `DiagnosticIntegrationBinding` (integration) that:
- configure the harness via the configurator,
- wrap each test with per-test contexts (based on test description),
- log pointer/interaction activity for deterministic traces.
2.2 Add `test/test_harness.dart` exporting setup helpers; ensure every `test/...` file imports it before other code.
2.3 Update `integration_test/*.dart` to import a shared harness helper (e.g., `integration_test/diagnostic_harness.dart`) that runs `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` + diagnostics setup.

## 3. Instrumentation Adapters
3.1 Replace `AppBlocObserver` usage with `BlocDiagnosticObserver` when diagnostics enabled (main app + tests).
3.2 Apply `RepositoryDiagnosticsMixin` (already created) to all Supabase repositories and core services; ensure each method reports `start/success/error` events with correlation IDs.
3.3 Implement `SupabaseDiagnosticClient` wrapper that logs RPC/Edge function requests/responses, redacts sensitive fields, and propagates correlation IDs.
3.4 Add widget tester helpers (`diagnosticTap`, `diagnosticPump`, etc.) logging gestures/navigation; migrate high-value integration tests to use them.

## 4. Domain Coverage
4.1 Define canonical logging domains/events (auth, buyer_map_feed, ordering, chat, vendor_dashboard, guest_conversion, system_services, ui.pointer).
4.2 Instrument key flows:
- **Ordering**: cart/BLoC mutations, `create_order` invocation, Active Order FAB/Realtime updates.
- **Chat**: optimistic send queue, retries, realtime acknowledgements.
- **Vendor dashboard**: order actions (accept/prep/ready), dish toggles, quick replies.
- **Auth & guest conversion**: Supabase auth calls, conversion services, prompt displays.
- **Map/feed**: viewport queries, cache hits/misses, pan debounce events.
4.3 Ensure correlation scope propagation (orderId, vendorId, userId, mapViewport) via harness context helpers.

## 5. Test Utilities & Assertions
5.1 Extend `MemoryDiagnosticSink` with APIs to retrieve events per test for assertions.
5.2 Author sample regression tests (unit/widget) verifying expected log sequences (e.g., `OrderBloc` emits `ordering.create_order.request/response`).
5.3 Document how to assert on logs within tests (e.g., `DiagnosticLogMatcher`).

## 6. CI & Artifact Integration
6.1 Update `.github/workflows/ci.yml` test matrix to export `CI_DIAGNOSTICS=true` and ensure `flutter test` creates `build/diagnostics/<run-name>/`.
6.2 After tests complete (success or fail), upload `build/diagnostics/**` as artifacts for each job; include run name + Flutter version in artifact name.
6.3 For quick triage, tail `build/diagnostics/stdout.jsonl` on failure so verbose logs appear directly in CI output.

## 7. Documentation & Spec Tracking
7.1 Update `openspec/changes/add-runtime-diagnostic-logging/tasks.md` marking steps complete as work lands.
7.2 Author spec delta(s) in `openspec/changes/add-runtime-diagnostic-logging/specs/observability/spec.md` with requirements/scenarios covering: harness capabilities, instrumentation coverage, CI retention.
7.3 Write `docs/DIAGNOSTIC_LOGGING.md` detailing:
- how to enable harness locally/CI,
- available domains/events,
- how to retrieve artifacts and assert logs in tests.
7.4 Run `openspec validate add-runtime-diagnostic-logging --strict` once deltas + docs prepared.
