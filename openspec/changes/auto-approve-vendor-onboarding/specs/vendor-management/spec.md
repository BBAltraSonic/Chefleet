## ADDED Requirements

### Requirement: Instant vendor approval on submission
Vendor onboarding SHALL auto-approve the vendor the moment submission succeeds, eliminating any pending review state and immediately activating the vendor account.

#### Scenario: Auto-approval end-to-end
- **WHEN** a user submits a valid vendor application
- **THEN** the system SHALL insert/update the vendor record with `status=approved` and `is_active=true`
- **AND** persist the vendor profile ID onto `users_public`
- **AND** grant the vendor role and store it in local secure storage so it survives relaunch
- **AND** clear `vendor_onboarding_progress` metadata before emitting success to the UI

### Requirement: Post-onboarding routing guarantees
The routing stack SHALL ensure newly approved vendors always land on the vendor dashboard on every app open, while users who have not finished onboarding remain confined to the onboarding flow.

#### Scenario: Dashboard after relaunch
- **WHEN** a vendor finishes onboarding and subsequently force-closes + relaunches the app
- **THEN** RoleBloc SHALL restore `UserRole.vendor` from storage
- **AND** `RoleRouteGuard` SHALL allow access to `/vendor/dashboard`
- **AND** GoRouter SHALL not redirect them back to `/vendor/onboarding`

#### Scenario: Incomplete onboarding still restricted
- **WHEN** a user abandons onboarding before submission
- **THEN** GoRouter SHALL continue redirecting them to `/vendor/onboarding` until submission succeeds and metadata is cleared

### Requirement: Telemetry and regression coverage for auto-approval
The platform SHALL capture metrics and enforce automated tests covering the auto-approval journey to prevent regressions.

#### Scenario: Metrics recorded for submissions
- **WHEN** onboarding completes
- **THEN** the system SHALL emit telemetry counters for submission success, metadata cleanup success/failure, and dashboard redirect success

#### Scenario: Automated tests prevent regressions
- **WHEN** continuous integration runs
- **THEN** there SHALL be unit + integration tests that fail if onboarding success does not persist vendor role or if rerouting to dashboard breaks
