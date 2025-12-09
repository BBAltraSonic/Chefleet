## ADDED Requirements

### Requirement: Diagnostic Harness Foundation
The system SHALL provide a comprehensive runtime diagnostic logging harness that enables deterministic, structured event capture across all application tiers without impacting production performance.

#### Scenario: Test-only activation
- **WHEN** running unit tests, widget tests, or integration tests
- **THEN** the diagnostic harness SHALL activate automatically via `DiagnosticTestBinding` and `ensureIntegrationDiagnostics()`
- **AND** SHALL remain completely disabled in production builds (release mode)

#### Scenario: Structured event emission
- **WHEN** any instrumented component emits a diagnostic event
- **THEN** the event SHALL include: timestamp, severity, domain, event name, correlation IDs, sanitized payload, and optional stack trace
- **AND** SHALL be serializable to JSON for artifact storage

#### Scenario: Sink configuration
- **WHEN** diagnostic harness is enabled
- **THEN** it SHALL support multiple concurrent sinks: stdout (CI logs), file (artifacts), and memory (test assertions)
- **AND** SHALL flush all sinks deterministically at test completion

### Requirement: Domain Coverage
The system SHALL instrument all critical application domains with structured diagnostic events.

#### Scenario: Authentication domain coverage
- **WHEN** authentication operations occur (login, logout, session validation, guest conversion)
- **THEN** the system SHALL emit events under `DiagnosticDomains.auth` with correlation IDs (`user-<id>`, `guest-<id>`)
- **AND** SHALL capture Supabase auth response metadata and error details

#### Scenario: Ordering domain coverage
- **WHEN** ordering operations occur (cart mutations, order creation, active order updates)
- **THEN** the system SHALL emit events under `DiagnosticDomains.ordering` with correlation IDs (`order-<id>`, `vendor-<id>`)
- **AND** SHALL capture edge function request/response payloads and timing metrics

#### Scenario: Chat domain coverage
- **WHEN** chat operations occur (message send, optimistic queue, realtime acks, retries)
- **THEN** the system SHALL emit events under `DiagnosticDomains.chat` with correlation IDs (`chat-<id>`, `message-<id>`)
- **AND** SHALL capture message state transitions and retry attempts

#### Scenario: Vendor dashboard domain coverage
- **WHEN** vendor dashboard operations occur (order actions, dish toggles, metrics refresh)
- **THEN** the system SHALL emit events under `DiagnosticDomains.vendorDashboard` with correlation IDs (`vendor-<id>`, `order-<id>`)
- **AND** SHALL capture action payloads and Supabase response metadata

#### Scenario: Map feed domain coverage
- **WHEN** map feed operations occur (viewport changes, cache hits/misses, vendor queries)
- **THEN** the system SHALL emit events under `DiagnosticDomains.buyerMapFeed` with correlation IDs (`viewport-<bounds>`)
- **AND** SHALL capture query parameters, cache statistics, and fetch timings

#### Scenario: Guest conversion domain coverage
- **WHEN** guest conversion operations occur (validation, migration, promotion)
- **THEN** the system SHALL emit events under `DiagnosticDomains.guestConversion` with correlation IDs (`guest-<id>`, `user-<id>`)
- **AND** SHALL capture migration counters and Supabase transaction metadata

#### Scenario: System services domain coverage
- **WHEN** Supabase RPC, edge functions, or database operations occur
- **THEN** the system SHALL emit events under `DiagnosticDomains.systemServices` with correlation IDs inherited from parent scope
- **AND** SHALL capture request/response payloads with automatic redaction of sensitive fields

#### Scenario: UI interaction domain coverage
- **WHEN** UI interactions occur (taps, drags, text entry, navigation)
- **THEN** the system SHALL emit events under `DiagnosticDomains.uiPointer` with widget metadata (type, key, semantics label)
- **AND** SHALL capture interaction timing and target coordinates

### Requirement: Correlation Scope Propagation
The system SHALL maintain correlation context across asynchronous boundaries and nested operations.

#### Scenario: Scoped operation execution
- **WHEN** a service or repository initiates a scoped operation via `DiagnosticHarness.runScoped()`
- **THEN** all downstream events SHALL inherit the correlation IDs from the parent scope
- **AND** SHALL maintain scope isolation across concurrent operations

#### Scenario: Cross-tier correlation
- **WHEN** a BLoC event triggers repository operations and Supabase calls
- **THEN** all emitted events SHALL share common correlation IDs (e.g., `order-<id>`)
- **AND** SHALL enable end-to-end trace reconstruction from logs

### Requirement: Payload Sanitization and Redaction
The system SHALL automatically sanitize and redact sensitive data from all diagnostic payloads.

#### Scenario: Sensitive field redaction
- **WHEN** emitting events containing sensitive fields (passwords, tokens, API keys, PII)
- **THEN** the system SHALL redact these fields using the harness sanitizer
- **AND** SHALL replace values with `[REDACTED]` markers

#### Scenario: Nested payload sanitization
- **WHEN** emitting events with nested JSON payloads
- **THEN** the system SHALL recursively sanitize all nested objects and arrays
- **AND** SHALL preserve non-sensitive fields for debugging

### Requirement: CI Integration and Artifact Retention
The system SHALL integrate with CI/CD pipelines to capture, surface, and retain diagnostic artifacts.

#### Scenario: CI environment detection
- **WHEN** tests run in CI environment (GitHub Actions)
- **THEN** the system SHALL activate diagnostics via `CI_DIAGNOSTICS=true` environment variable
- **AND** SHALL configure stdout sink via `DIAGNOSTIC_SINK_TYPE=stdout`

#### Scenario: Artifact collection
- **WHEN** test jobs complete (success or failure)
- **THEN** CI SHALL collect all files under `build/diagnostics/` directory
- **AND** SHALL upload as artifacts with descriptive names: `unit-test-diagnostics-{version}`, `integration-test-diagnostics-{version}`

#### Scenario: Artifact retention policy
- **WHEN** diagnostic artifacts are uploaded
- **THEN** CI SHALL retain artifacts for 14 days (ci.yml) or 7 days (test.yml)
- **AND** SHALL organize artifacts by scenario name for integration tests

#### Scenario: Failure triage surfacing
- **WHEN** test jobs fail
- **THEN** CI SHALL display last 200 lines (unit tests) or last 50 lines per scenario (integration tests) in job output
- **AND** SHALL include event statistics (total, errors, warnings) when available

### Requirement: Test Assertion Support
The system SHALL provide utilities for asserting on diagnostic events within tests.

#### Scenario: Memory sink event retrieval
- **WHEN** a test needs to verify diagnostic events
- **THEN** it SHALL retrieve events from `MemoryDiagnosticSink` filtered by domain, severity, or event name
- **AND** SHALL assert on event count, payload contents, and correlation IDs

#### Scenario: Tester helper adoption
- **WHEN** widget or integration tests perform UI interactions
- **THEN** they SHALL use diagnostic tester helpers (`diagnosticTap()`, `diagnosticEnterText()`, etc.)
- **AND** SHALL automatically emit UI interaction events with widget metadata

### Requirement: BLoC and Repository Instrumentation
The system SHALL provide mixins and observers for automatic diagnostic emission from BLoCs and repositories.

#### Scenario: BLoC lifecycle instrumentation
- **WHEN** a BLoC transitions state or handles events
- **THEN** `BlocDiagnosticObserver` SHALL emit events with BLoC type, event type, and state transitions
- **AND** SHALL capture error details and stack traces for exceptions

#### Scenario: Repository operation instrumentation
- **WHEN** a repository performs CRUD or search operations
- **THEN** `RepositoryDiagnosticsMixin.runRepositorySpan()` SHALL emit `start/success/error` events
- **AND** SHALL include operation name, correlation IDs, and timing metrics

