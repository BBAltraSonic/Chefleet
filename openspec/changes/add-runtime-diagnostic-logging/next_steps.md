# Pending Work — Runtime Diagnostic Logging

The original proposal for this change ("add-runtime-diagnostic-logging") focused on producing deterministic runtime traces that stream directly to the terminal/CI logs for fast triage. The remaining items below are prioritized to fulfill that core requirement first (stdout visibility), then broaden coverage.

## 1. Harness Adoption Across Test Suites
1. **Widget/Unit Tests**
   - Create a `flutter_test_config.dart` (or similar entrypoint) that imports `test/test_harness.dart` before any other test code so every `flutter test` run auto-enrolls in diagnostics and emits JSONL to stdout.
   - For files that require explicit control, ensure they import `../test_harness.dart` as the very first statement so terminal logging is not skipped.
2. **Integration Tests**
   - Update every file under `integration_test/` to import `diagnostic_harness.dart` and call `ensureIntegrationDiagnostics(scenarioName: '<suite>')` *before* defining groups so integration runs also stream structured logs to the terminal. Remaining suites include:
     - `chat_realtime_test.dart` ✅
     - `buyer_flow_test.dart` ✅
     - `vendor_flow_test.dart`
     - `guest_journey_e2e_test.dart`
     - `map_feed_integration_test.dart`
     - `profile_order_integration_test.dart`
     - `role_switching_flow_test.dart`
     - `role_switching_realtime_test.dart`
     - `schema_validation_test.dart`
     - `home_screen_redesign_test.dart`
     - `navigation_without_bottom_nav_test.dart`
     - `end_to_end_workflow_test.dart`
     - `vendor_onboarding_test.dart`

## 2. Instrumentation & Client Wrappers
1. Replace `AppBlocObserver` usage with `BlocDiagnosticObserver`, gated by the harness `isEnabled` flag so every bloc lifecycle event is printed to stdout when diagnostics run (per proposal).
2. Ensure every Supabase-backed repository/service mixes in `RepositoryDiagnosticsMixin`, emitting `start/success/error` spans (and therefore stdout lines) with useful correlation IDs (orderId, vendorId, etc.).
3. Implement `SupabaseDiagnosticClient` (or decorator) that logs RPC/Edge Function requests/responses with automatic payload redaction, and update repositories/services to use it so network traces appear in the terminal stream.
4. Build widget tester helpers (`diagnosticTap`, `diagnosticEnterText`, `diagnosticPump`) that log gestures/navigation; migrate high-value integration and widget tests to those helpers so UI interactions are visible in terminal logs.

## 3. Domain-Level Coverage
1. Define canonical domain constants/events (auth, ordering, chat, vendor_dashboard, buyer_map_feed, guest_conversion, system_services, ui.pointer) so stdout logs are filterable.
2. Instrument critical flows so each significant action yields a terminal log line:
   - Ordering: cart mutations, `create_order`, Active Order FAB updates.
   - Chat: optimistic sends, retries, realtime acks.
   - Vendor dashboard: order actions, quick replies, dish toggles.
   - Auth/Guest conversion: Supabase auth calls, conversion prompts, migration flows.
   - Map/feed: viewport queries, cache hits/misses, debounce events, and map gestures.
3. Ensure correlation propagation helpers (e.g., `runScoped('order', orderId)`) are used consistently so terminal logs can be stitched per entity without writing new tests.

## 4. CI & Documentation
1. Wire `.github/workflows/ci.yml` to set `CI_DIAGNOSTICS=true`, ensure `flutter test` produces `build/diagnostics/<run-name>/`, streams JSONL to stdout (primary triage channel), and uploads artifacts on every job.
2. Update docs:
   - `docs/DIAGNOSTIC_LOGGING.md` covering enablement, domains, artifact retrieval, and test assertions.
   - Spec delta under `openspec/changes/add-runtime-diagnostic-logging/specs/observability/spec.md` describing harness guarantees and CI retention.
3. Run `openspec validate add-runtime-diagnostic-logging --strict` once deltas/docs/tests are finalized.

Keeping this list up to date will make it easy to track Task 2 completion before moving on to Task 3+.
