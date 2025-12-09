## 1. Gathering & Alignment
- [x] 1.1 Audit existing logging utilities (AppLogger, BlocObserver, service-level logs)
- [x] 1.2 Catalog critical flows (buyer map/feed/order, vendor dashboard, chat, auth, guest conversion) needing runtime traces
- [x] 1.3 Define logging domains, payload schema, and correlation ID strategy

## 2. Harness & Instrumentation
- [x] 2.1 Design test-only diagnostic harness API (enable/disable, sink registration, metadata collectors)
- [x] 2.2 Instrument BLoC lifecycle + repositories/services with structured events
- [x] 2.3 Wire Supabase/edge-function client wrappers to emit request/response diagnostics
- [x] 2.4 Add widget/test utilities to wrap interactions and log gestures/navigation

## 3. Test Utilities & CI Integration
- [x] 3.1 Build Flutter test mixins/helpers to activate harness and export logs to stdout/artifacts
- [x] 3.2 Update integration tests to adopt helpers and validate log coverage (Phase 3 COMPLETE)
- [x] 3.3 Ensure CI scripts capture and retain diagnostic logs for failing suites (Phase 4 COMPLETE)

## 4. Specification & Validation
- [x] 4.1 Author Observability & Diagnostics spec deltas (requirements + scenarios)
- [x] 4.2 Run `openspec validate add-runtime-diagnostic-logging --strict`
- [x] 4.3 Review with stakeholders and iterate on feedback
