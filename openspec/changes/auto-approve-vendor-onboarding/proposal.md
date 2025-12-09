# Change: Auto-approve vendor onboarding submissions

## Why
Completing onboarding currently bounces vendors back into the onboarding flow after relaunch because the active role is not persisted and onboarding metadata is never cleared. At the same time, vendors must wait for a non-existent manual review step even though we want them active immediately. We need an authoritative spec change that mandates instant approval, enforces cleanup, and locks routing so new vendors land on their dashboard every time the app opens.

## What Changes
- Define that vendor applications are auto-approved at submit time; no manual reviewer flow.
- Require RoleBloc/storage to persist the vendor role the moment onboarding succeeds and keep it across app restarts.
- Require onboarding metadata to be cleared atomically so users are never redirected back into the flow after success.
- Tighten routing/guards so approved vendors always reach `/vendor/dashboard`, while incomplete onboarding still redirects appropriately.
- Document telemetry + regression testing expectations for the auto-approval journey.

## Impact
- Affected specs: `vendor-management` capability.
- Affected code: `VendorOnboardingBloc`, `RoleBloc`, `RoleRouteGuard`, GoRouter redirects, Supabase onboarding metadata, regression/integration tests.
