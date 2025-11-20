# Chefleet App — Status Report and Remediation Plan

Date: 2025-11-20

## Executive Summary

Chefleet is a Flutter app backed by Supabase with BLoC state management and Google Maps for discovery. The codebase is feature-rich but not release-ready: navigation is duplicated, push notifications and payments are partially stubbed, Supabase Edge Functions live in two locations, database migrations are missing, and `flutter analyze` reports many issues (including broken/unstable tests). A focused set of decisions and a phased remediation plan will stabilize builds, consolidate the backend surface, and harden critical user flows.

## Environment Snapshot

- Flutter: 3.35.5 (stable) • Dart: 3.9.2
- Supabase client: `supabase_flutter ^2.8.3`
- Maps: `google_maps_flutter ^2.5.3`
- State: `flutter_bloc`, `freezed`
- Lints: `flutter_lints` with custom rules (vendor feature folder currently excluded)

## Current State and Key Findings

1) Navigation duplication
- `go_router` configured in `lib/core/router/app_router.dart`, but the app runs `MaterialApp` with a custom `MainAppShell`/`PersistentNavigationShell`. Two parallel approaches lead to drift and dead code.

2) Edge Functions split and stubs
- Active folder: `supabase/functions` (send_push, create_order, change_order_status, upload_image_signed_url).
- Legacy folder: `edge-functions` (includes payments-related functions like `create_payment_intent`, `manage_payment_methods`, `process_payment_webhook`).
- Push notifications are placeholders: backend logs and inserts DB records; no FCM/APNs send. App `NotificationService` is a no-op.

3) Payments are inconsistent with “cash-only”
- Pubspec removed `flutter_stripe` (commented). Client code still calls `create_payment_intent` via `PaymentService`, but that function exists only in the legacy folder. Apple/Google Pay paths throw `UnsupportedError` but are still wired into BLoC.

4) Secrets/config hygiene
- `lib/main.dart` contains hard-coded Supabase URL and anon key. Tests contain another project URL/key and attempt raw SQL via an `execute_sql` RPC—risky and brittle.

5) Database migrations and RLS
- No `supabase/migrations/` present, but code references many tables: `orders`, `order_items`, `vendors`, `dishes`, `messages`, `users_public`, `device_tokens`, `notifications`, `user_wallets`, `wallet_transactions`, `payment_settings`, `profiles`, etc. Environments aren’t reproducible without migrations and RLS policies.

6) Map feed correctness/perf
- Clustering/caching implemented and covered by perf tests. Supabase query uses a non-standard `filter('vendor_id', 'in', vendorIds)`. Use `inFilter('vendor_id', vendorIds)` or PostgREST `in` syntax.
- Many debug `print`/`debugPrint` statements remain despite lints disallowing prints.

7) Code quality and analyzer
- `analysis_options.yaml` excludes `lib/features/vendor/**` from analyzer; should be re-enabled to catch issues.
- `flutter analyze` found 800+ issues (many from test code: undefined identifiers, API drift, excessive prints, deprecated APIs, missing mocks).

8) Tests
- Multiple integration tests attempt live Supabase access and even trigger DDL via RPC. These must be isolated or mocked. Generated code and mocks appear out of sync.

## Decisions (locked)

1) Navigation: Adopt `go_router` with `MaterialApp.router` for deep links and URL-based navigation; remove the duplicate shell routes.

2) Payments: Cash-only. Remove payment intent creation, saved methods UIs/APIs, and payment-related Edge Functions. Keep only order flow and pickup with pickup code verification.

3) Push notifications: None for now. Keep `NotificationService` as a safe no-op; do not integrate FCM/APNs yet; skip device token tables and notification pipelines until re-scoped.

## Step-by-Step Remediation Plan

### Phase 0 — Project choices and freeze (1–2 days)
1. Record an ADR documenting the locked decisions above; update the backlog accordingly.
2. Freeze new feature development during remediation.

Deliverable: A short ADR noting decisions and scope for this phase.

### Phase 1 — Build stabilization and analyzer triage (1–2 days)
1. Ensure code generation is current:
   - Run: `flutter pub run build_runner build --delete-conflicting-outputs`
2. Make analyzer green for app code first:
   - Temporarily exclude `integration_test/**` and `test/**` from analyzer to focus on `lib/**` (or fix quickly if small).
   - Re-enable `lib/features/vendor/**` in `analysis_options.yaml` and fix surfaced issues.
3. Replace `print/debugPrint` with a logger gated by build mode (or remove in non-critical paths).
4. Fix map feed query to use `inFilter` for vendor IDs.

Acceptance: `flutter analyze` passes for `lib/**`; app builds and runs to home screen.

### Phase 2 — Edge Functions consolidation (1–2 days)
1. Move all required Edge Functions into `supabase/functions` (Supabase CLI default). Remove the legacy `edge-functions/` folder or archive it.
2. Since payments are cash-only, remove or archive payment-related functions (`create_payment_intent`, `manage_payment_methods`, `process_payment_webhook`) and ensure the app no longer invokes them.
3. Align function names used by the app with deployed functions; remove `PaymentService` flows as part of Phase 6.
4. Add `deno.json` and ensure imports pin to stable versions.
5. Deploy to dev project via Supabase CLI:
   - `supabase functions deploy <function>`

Acceptance: Single source-of-truth folder; functions deploy and can be invoked in dev.

### Phase 3 — Database migrations and RLS (2–4 days)
1. Initialize migrations:
   - `supabase migration new 0001_base_schema`
2. Define tables referenced by the app (orders, order_items, vendors, dishes, messages, users_public, profiles, etc.) with indexes and constraints. Defer push-related tables (`device_tokens`, `notifications`) until notifications are in scope.
3. Add RLS policies aligned to roles (authenticated users, vendors, admin). Verify via `sqlfluff` and simple queries.
4. Apply migrations to dev and commit them.

Acceptance: Fresh dev project can be stood up from migrations; core CRUD works with RLS.

### Phase 4 — Navigation unification (1 day)
1. Adopt `go_router` across the app with `MaterialApp.router`.
2. Remove duplicate `MainAppShell` plumbing not required, or wrap it as a shell route inside go_router.
3. Ensure guards (`AuthGuard`, `ProfileGuard`) integrate with `go_router` redirects.

Acceptance: Single navigation system; deep links and tab routing verified.

### Phase 5 — Deferred: Push notifications (out of scope for now)
No implementation in this phase. Keep placeholders and avoid adding device token/notification tables. Revisit when notifications are prioritized.

### Phase 6 — Payments alignment (2–4 days)
Cash-only path:
1. Remove `PaymentService` flows and UI not needed; strip payment methods screens, BLoC events, and any calls to payment Edge Functions.
2. Ensure order flow reflects cash pickup only; confirm statuses and pickup code handling on the backend and client.

Acceptance: Cash-only flow fully works end-to-end with clear UX and no dead payment code.

### Phase 7 — Secrets and configuration (0.5–1 day)
1. Remove hard-coded Supabase URL/keys from `lib/main.dart` and tests.
2. Use `--dart-define` or a build-time config layer:
   - Example: `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
3. Read values via `const String.fromEnvironment('SUPABASE_URL')` pattern.

Acceptance: No secrets in source; builds rely on environment defines.

### Phase 8 — Tests rework (2–4 days)
1. Unit tests: prefer mocking Supabase client; remove RPC-DDL attempts.
2. Integration tests: avoid live DB; use fakes or run against local Supabase started with CLI (document credentials separately).
3. Fix undefined symbols in tests (e.g., `GoogleMap`, missing mocks) and update for API changes.
4. Add `build_runner` step before tests to generate code.

Acceptance: `flutter test` passes locally and in CI; no external destructive calls.

### Phase 9 — CI/CD hardening (0.5–1 day)
1. Wire pipeline to run: `flutter analyze`, `build_runner`, `flutter test`, and (optionally) `scripts/quality-gate-check.sh`.
2. Add secret management for Supabase/Sentry/FCM as needed.

Acceptance: CI green on main; PRs blocked on analyzer/tests.

## Targeted Fix Notes

- Map feed query fix (example):
```dart
final vendorIds = vendors.map((v) => v.id).toList();
final dishesResponse = await Supabase.instance.client
  .from('dishes')
  .select('*')
  .inFilter('vendor_id', vendorIds)
  .eq('available', true)
  .order('created_at', ascending: false)
  .range(0, _pageSize - 1);
```

- Secrets in main.dart:
```dart
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

## Risks and Mitigations

- Refactor fallout: Removing payment code and unifying navigation may surface hidden dependencies. Mitigate with incremental PRs, strong analyzer gates, and targeted end-to-end checks.
- Missing migrations: Slows onboarding/CI; mitigate by drafting base schema quickly and iterating.

## Immediate Next Actions (72-hour plan)

1. Publish ADR capturing locked decisions (go_router, cash-only, no notifications).
2. Phase 1: update codegen, fix analyzer in `lib/**`, correct map feed `inFilter`, remove prints; re-enable vendor folder in analyzer.
3. Phase 2: consolidate functions under `supabase/functions`; remove/retire payment-related functions and client invocations; deploy remaining functions to dev.
4. Phase 3: start migrations scaffold (excluding push-related tables) and commit.
5. Phase 4: switch to `MaterialApp.router` and remove duplicate shell routes; wire guards via `go_router`.

— End of Report —
