# Change: Add comprehensive runtime diagnostic logging harness

## Why
- Current failures in complex buyer/vendor flows are difficult to diagnose because runtime side effects (BLoC transitions, Supabase calls, chat events, map updates) are not captured in a single, searchable stream.
- Tests only assert outcomes; when they fail we lack the contextual breadcrumbs needed to reproduce production issues or understand regressions quickly.

## What Changes
- Introduce a deterministic diagnostic logging harness that instruments BLoC lifecycle hooks, repository/service calls, Supabase edge-function invocations, and widget interaction events when tests run.
- Provide a Flutter test utility that enables the harness, collects structured logs, and exports them to the test runner stdout/artifacts so every test execution surfaces granular traces.
- Define logging domains (auth, map/feed, ordering, chat, vendor dashboard, system services) with standardized payload schema and correlation IDs to stitch together sequences.
- Ensure opt-in controls so the verbose logging is gated to debug/test contexts and cannot leak into production builds.

## Impact
- Affected specs: Observability & Diagnostics (new capability to define logging harness expectations).
- Affected code: `lib/core/utils/app_logger.dart`, `lib/core/services/*`, BLoC observers, repository layers, test utilities under `test/` and `integration_test/`.
- Tooling: Flutter test runners, CI output parsing, potential updates to `scripts/` helpers that execute test suites.
