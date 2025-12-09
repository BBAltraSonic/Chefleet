## 1. Specification & Change Control
- [ ] 1.1 Review existing `vendor-management` spec + open changes for conflicts.
- [ ] 1.2 Draft spec delta covering auto-approval behavior, role persistence, routing, and telemetry requirements.
- [ ] 1.3 Run `openspec validate auto-approve-vendor-onboarding --strict` and submit for approval.

## 2. Backend & Persistence
- [ ] 2.1 Update onboarding submission pipeline to treat every application as approved instantly (status `approved`, `is_active=true`).
- [ ] 2.2 Ensure Supabase auth metadata clears `vendor_onboarding_progress` atomically upon success; add telemetry on cleanup failures.
- [ ] 2.3 Guarantee `users_public` role + vendor profile ids persist during onboarding (idempotent writes, rollback handling).

## 3. App Logic & Routing
- [ ] 3.1 Update `VendorOnboardingBloc` to run new auto-approval flow, clear metadata, and emit success state once.
- [ ] 3.2 Update `RoleBloc` + storage sync so vendor role is persisted immediately and restored on restart.
- [ ] 3.3 Harden `RoleRouteGuard`/GoRouter redirects so approved vendors always land on `/vendor/dashboard`, while in-progress users stay in onboarding.

## 4. Testing & Telemetry
- [ ] 4.1 Add bloc/unit tests covering onboarding success, role persistence, and routing redirects.
- [ ] 4.2 Add integration test (submit -> relaunch -> still dashboard) plus failure telemetry assertions.
- [ ] 4.3 Document monitoring hooks (submission success, cleanup failures, reroute counts).
