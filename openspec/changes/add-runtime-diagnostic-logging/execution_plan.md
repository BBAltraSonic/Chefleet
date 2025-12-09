# Runtime Diagnostic Logging — Comprehensive Execution Plan

## Context
- `current_status.md` documents the harness foundation (core APIs, bloc coverage, partial test adoption) and enumerates remaining scope across services, tests, CI, docs, and specs.
- `implementation_plan.md` (Sections 3–7) and `next_steps.md` specify the desired end state: deterministic diagnostics in every tier, CI surfacing, and spec/documentation updates.
- `tasks.md` still has Sections 2–4 unchecked, so this plan targets completing those deliverables in a structured order.

## Phase 1 — Service & Repository Instrumentation (Task 3 §3.1–3.3)
1. **Guest Conversion Service (DiagnosticDomains.guestConversion)**
   - Instrument `convertGuestToRegistered`, `_validateGuestSession`, `_migrateGuestData`.
   - Emit `guest_conversion.start|success|error` with correlation IDs (`guest-<id>`, `user-<id>`), include Supabase response metadata and migration counters.
   - Capture exceptions via `DiagnosticSeverity.error`, attaching stack traces (`extra`).
2. **System Services & Supabase Wrappers (DiagnosticDomains.systemServices)**
   - Introduce a `SupabaseDiagnosticClient` (decorator) or utility that wraps `rpc`, `from().select/update/insert`, and `functions.invoke`.
   - Ensure payload sanitization + redaction reuse harness sanitizer.
   - Update repositories/services (OrderRepository, Vendor services, Auth flows, etc.) to use the wrapper or mixin so every RPC/edge-function emits `system_services.supabase.request|response|error` with timings and HTTP metadata.
3. **Correlation Scope Propagation**
   - Add helper(s) for `DiagnosticHarness.runScoped('order', orderId)` etc.
   - Ensure repositories and background services wrap long-running ops so downstream logs inherit the right correlation keys.
4. **RepositoryDiagnosticsMixin Alignment**
   - Verify all concrete Supabase repositories mix in the helper (search for `with RepositoryDiagnosticsMixin`); retrofit any missing ones.
   - Extend mixin to accept `diagnosticsDomain` overrides so services can re-route to `system_services` when appropriate.

## Phase 2 — Tester Utilities & Widget Helpers (Implementation Plan §3.4)
1. **Create Tester Helpers** under `lib/core/diagnostics/testing/`:
   - `Future<void> diagnosticTap(WidgetTester tester, Finder target, {String? description})` logging `ui.pointer.tap` with widget semantics before delegating to `tester.tap`.
   - Similar helpers for `enterText`, `pump`, `pumpAndSettle`, `drag`, navigation actions.
2. **Adopt Helpers in High-Signal Suites**
   - Prioritize integration/widget tests covering ordering, chat, vendor dashboard, guest conversion, and navigation flows.
   - Ensure helpers respect `context.mounted` and existing semantics.
3. **Document Usage** in inline comments + upcoming `docs/DIAGNOSTIC_LOGGING.md` so other contributors know to import the helpers.

## Phase 3 — Integration Suite Harness Adoption (Next Steps §1) ✅ COMPLETE
1. **Bootstrap** ✅
   - All 13 files in `integration_test/` now import `diagnostic_harness.dart` and call `ensureIntegrationDiagnostics(scenarioName: '<suite>')` before defining groups/tests.
   - Consistent scenario names implemented: `buyer_flow`, `vendor_flow`, `guest_journey_e2e`, `chat_realtime`, `map_feed`, `profile_order`, `role_switching_flow`, `role_switching_realtime`, `schema_validation`, `home_screen_redesign`, `navigation_without_bottom_nav`, `end_to_end_workflow`, `vendor_onboarding`.
2. **Regression Pass** ✅
   - All integration suites properly instrumented with no harness conflicts.
   - `current_status.md` updated with Phase 3 completion section.
   - Coverage: 100% (13/13 integration test files).
   - See `phase3_completion_report.md` for detailed verification.

## Phase 4 — CI Surfacing & Artifacts (Implementation Plan §6) ✅ COMPLETE
1. **Workflow Updates** ✅
   - ✅ `.github/workflows/ci.yml` - Updated test, integration, and performance jobs
   - ✅ `.github/workflows/test.yml` - Updated standalone test job
   - ✅ Export `CI_DIAGNOSTICS=true` and `DIAGNOSTIC_SINK_TYPE=stdout` for all test jobs
   - ✅ Collect `build/diagnostics/**/*` after each test run
   - ✅ Display last 200 lines (unit tests) or last 50 lines per scenario (integration) on failure
   - ✅ Upload artifacts with descriptive names: `unit-test-diagnostics-{version}`, `integration-test-diagnostics-{version}`, etc.
   - ✅ Set retention to 14 days (ci.yml) and 7 days (test.yml)
2. **Enhanced Failure Reporting** ✅
   - ✅ Event statistics displayed (total, errors, warnings) when available
   - ✅ Per-scenario log display for integration tests
   - ✅ Graceful handling when diagnostics not found
   - ✅ File counting and directory structure validation
3. **Consistency Checks** ✅
   - ✅ Deterministic run names via scenario-based organization
   - ✅ Artifact directories predictable and well-organized
   - ✅ `tasks.md` Section 3.3 marked as complete
   - ✅ See `phase4_completion_report.md` for detailed verification

## Phase 5 — Documentation & Spec Deltas (Implementation Plan §7 / Tasks §4)
1. **Docs (`docs/DIAGNOSTIC_LOGGING.md`)**
   - Cover enablement toggles (env vars, `flutter_test_config.dart`, integration harness).
   - Enumerate domains/events, payload schema, redaction rules, correlation scopes.
   - Describe tester helpers and how to assert logs via `MemoryDiagnosticSink`.
   - Provide CI artifact retrieval instructions + sample triage workflow.
2. **Observability Spec Delta**
   - Under `openspec/changes/add-runtime-diagnostic-logging/specs/observability/spec.md`, add ADDED/MODIFIED requirements for harness guarantees, domain coverage, CI retention, and tracer usage criteria.
3. **Task Tracking**
   - Update `tasks.md` checkboxes for Sections 2–4 as each deliverable lands.

## Phase 6 — Validation & Finalization
1. **`openspec validate add-runtime-diagnostic-logging --strict`**
   - Run after code/tests/docs/spec updates, resolve any findings.
2. **Regression Suite**
   - Execute `flutter test`, `flutter test integration_test`, and any smoke tests to confirm harness doesn’t introduce flakes.
3. **Stakeholder Review**
   - Share updated `current_status.md`, docs, and spec diff for approval.
4. **Archive Prep (Post-approval)**
   - Once deployed, follow OpenSpec archive steps (copy change folder under archive + update specs per instructions).
