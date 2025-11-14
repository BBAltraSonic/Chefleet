
# Phase 1 — Architecture & Project Foundations

Goal: create the project skeleton, infra accounts, shared conventions and the canonical Supabase schema + RLS + Edge function surface. (Outputs: infra projects, git repos, base schema/migrations, CI pipelines, environment config.)

## Task 1.1 — Accounts, projects, repos, access

-   Sub-tasks

    -   [ ] Create org accounts: Supabase (dev/staging/prod), Firebase (analytics + FCM), Google Cloud account (Maps billing & Routes API), Sentry, GitHub (or your Git provider), App Store & Play Console.

    -   [ ] Create Git repositories: `chefleet-app` (Flutter mono-repo), `chefleet-edge` (Edge functions), `chefleet-admin` (admin web), `chefleet-infra` (infra as code / migrations).

    -   [ ] Configure CI secrets/Env variables in CI and in Supabase Edge (API keys stored in secrets).

    -   [ ] Add team access + role-based permissions.

-   Owner: DevOps / Project Lead

-   Deliverables: account list, repo links, env key spreadsheet (secure), CI secrets set.
    

## Task 1.2 — Project conventions & developer setup

-   Sub-tasks

    -   [ ] Define branch strategy, PR rules, commit formatting (conventional commits).

    -   [ ] Pre-commit hooks: dartfmt, eslint (Edge), SQL lint.

    -   [ ] Local dev docs: how to run Flutter app, how to run Edge functions, how to run migrations, how to spin up a local supabase emulator (if used).

    -   [ ] Dependency policy (pin versions) and release checklist.

-   Owner: Tech Lead

-   Deliverable: `CONTRIBUTING.md`, `README.dev`.
    

## Task 1.3 — Supabase initial setup

-   Sub-tasks

    -   [x] Create Supabase projects for dev & staging & prod.

    -   [x] Enable Auth (phone OTP + email) and turn on Row Level Security.

    -   [x] Create Storage bucket `vendor_media` and default access policy (signed URLs by default).

    -   [x] Configure Realtime (allowing channels but RLS still enforced).

-   Owner: Backend

-   Deliverable: Supabase projects ready, credentials in CI.
    

## Task 1.4 — Database schema & migrations (canonical)

-   Sub-tasks

    -   [x] Add full table set: `users_public`, `user_addresses`, `vendors`, `dishes`, `orders`, `order_items`, `messages`, `favourites`, `device_tokens`, `notifications`, `payments` (future), `audit_logs`, `moderation_reports`, `app_settings`.

    -   [x] Add enums and indexes (price cents, vendor geography point with PostGIS if available).

    -   [x] Add unique and FK constraints, idempotency_key for orders.

    -   [x] Commit SQL migrations to `chefleet-infra`.

-   Owner: Backend

-   Deliverable: Migration files + schema docs (field descriptions).
    

## Task 1.5 — RLS policy design & example policies

-   Sub-tasks

    -   [x] Draft RLS policies for every table (read/write rules by role).

    -   [x] Ensure `orders` SELECT/UPDATE only for `buyer_id` or `vendor_id` or admin.

    -   [x] Enforce message insertion only when the sender is party to the order.

    -   [x] Disallow direct client-side status updates — status changes must be performed via Edge functions.

    -   [x] Create test accounts for policy validation.

-   Owner: Backend

-   Deliverable: RLS SQL snippets + test plan for RLS.
    

## Task 1.6 — Edge function surface design

-   Sub-tasks

    -   [x] Define RPCs/Edge endpoints: `create_order`, `change_order_status`, `generate_pickup_code`, `send_push`, `upload_image_signed_url`, `report_user`, `process_payment_webhook`.

    -   [x] Document contracts for each endpoint (input/response/errors).

    -   [x] Decide auth model for Edge functions (Supabase JWT verification).

-   Owner: Backend

-   Deliverable: API spec (OpenAPI-like), list of endpoints.
    

**Phase 1 Acceptance criteria**

-   All repos and infra accounts exist and are accessible.
    
-   Supabase environments provisioned and migrations applied to dev.
    
-   RLS policies created and passing automated policy tests.
    
-   Edge function API contract documented.
    

----------

# Phase 2 — Product Design & Prototyping

Goal: finalize UX, motion specs, component library, and produce Figma assets for dev. (Outputs: Figma designs, motion specs, Flutter Theme & component token spec)

## Task 2.1 — UX flows & information architecture

-   Sub-tasks

    -   [x] Complete Buyer & Vendor user flows: onboarding, map/feed, dish detail, checkout, active order, chat, vendor onboarding, vendor menu management.

    -   [x] Define admin flows: search, moderation, refund/dispute.

-   Owner: Product / UX

-   Deliverable: Flow diagrams.
    

## Task 2.2 — High fidelity designs & motion specs

-   Sub-tasks

    -   [x] Design Map hero (shrink & fade rules), feed grid, dish card, bottom nav (liquid glass), center pulsing FAB, profile overlay.

    -   [x] Create annotated motion specs: map 60% → 20% shrink, AnimatedOpacity fade, map→feed debounce 600ms, FAB pulsing when active order exists.

    -   [x] Vendor dashboard UI: order queue, order card states, quick replies.

-   Owner: UI Designer

-   Deliverable: Figma final screens + motion tokens.
    

## Task 2.3 — Component library & Flutter ThemeData

-   Sub-tasks

    -   [x] Export color tokens, typography, spacing, components (buttons, cards, nav, FAB, dialogs).

    -   [x] Provide ThemeData and component examples for Flutter (liquid glass nav background, FAB notch).

    -   [x] Implement glass morphism design system with consistent styling across app.

-   Owner: Frontend Lead

-   Deliverable: `design-system` folder with ThemeData and component references; complete glass morphism implementation.
    

## Task 2.4 — Usability validation (prototype testing)

-   Sub-tasks

    -   [ ] Run 5–8 moderated usability sessions for core flows (map discovery, ordering, pickup).

    -   [ ] Iterate on confusing affordances (pickup code display, order FAB visibility).

-   Owner: Product / UX

-   Deliverable: Usability report + prioritized fixes.
    

**Phase 2 Acceptance criteria**

-   Approved Figma & motion spec.
    
-   ThemeData + components exported and validated with dev team.
    

----------

# Phase 3 — Core Buyer App Implementation (MVP buyer experience)

Goal: implement buyer app flows: onboarding, map/feed, dish detail, order creation and active order experience; include offline basics and optimistic chat.

> Note: client must never directly mutate order status; order creation must call `create_order` Edge function.

## Task 3.1 — Project scaffolding & navigation

-   Sub-tasks

    -   [x] Scaffold Flutter app with folder structure: `auth`, `home`, `map`, `feed`, `dish`, `order`, `chat`, `profile`, `settings`.

    -   [x] Implement bottom navigation with liquid glass style and center notch + FAB.

    -   [x] Implement persistent Map widget instance across tabs.

    -   [x] Implement comprehensive navigation architecture with BLoC state management.

-   Owner: Frontend

-   Deliverable: Working scaffold branch; complete navigation system.
    

## Task 3.2 — Auth & onboarding (Supabase Auth: Phone OTP)

-   Sub-tasks

    -   [x] Implement phone OTP flow with Supabase Auth.

    -   [x] On first sign in, complete profile (name, avatar, default address).

    -   [x] Store minimal metadata (notif prefs) in `users_public.metadata`.

    -   [x] Implement comprehensive testing for auth onboarding (unit, widget, integration tests).

-   Owner: Frontend / Backend

-   Deliverable: Auth flow integrated; user rows created in DB; comprehensive test coverage.
    

## Task 3.3 — Map + Feed implementation

-   Sub-tasks

    -   [x] Integrate Google Maps SDK (Android & iOS) + Routes API key config.

    -   [x] Implement pin clustering, map hero behavior (animated shrink/fade), and map bounds→feed query debounce (600ms).

    -   [x] Implement feed as grid of dish cards (only `dishes.available = TRUE`).

    -   [x] Implement "pin → mini card" interaction.

    -   [x] Cache last feed & vendor list locally.

-   Owner: Frontend

-   Deliverable: Map + feed working locally, feed updates when map moves.
    

## Task 3.4 — Dish detail & order creation

-   Sub-tasks

    -   [ ] Dish detail screen with quantity, pickup time selector (time windows validated by vendor `open_hours_json`).

    -   [ ] On "Place Order", call `create_order` Edge function with idempotency_key.

    -   [x] Edge function validates dish availability, calculates total (server-side), generates pickup_code, inserts `orders` + `order_items`, notifies vendor via realtime and push.

    -   [ ] Frontend receives order response and shows Active Order modal.

-   Owner: Frontend / Backend

-   Deliverable: Order creation working via Edge function.
    

## Task 3.5 — Active Order FAB & order modal

-   Sub-tasks

    -   [ ] FAB pulses if active order exists (any non-final state).

    -   [ ] Tapping FAB opens Active Order modal: status timeline, pickup code (first-time visibility rules), vendor ETA, map route overlay.

    -   [ ] Add "Contact vendor" button opening in-app chat.

-   Owner: Frontend

-   Deliverable: FAB + Active Order modal functional.
    

## Task 3.6 — In-app Chat (buyer side)

-   Sub-tasks

    -   [ ] Chat messages use `messages` table; subscribe to `messages:order_id` Realtime channel.

    -   [ ] Implement optimistic UI (local message marked `pending`), retry on failure, show sent/delivered/failed states.

    -   [ ] Enforce client-side rate limiting UI warning (but server will enforce hard limit).

-   Owner: Frontend / Backend

-   Deliverable: Chat implemented with optimistic writes.
    

**Phase 3 Acceptance criteria**

-   Buyer can sign in via phone OTP & place an order via Edge function.
    
-   Orders appear in DB with pickup_code generated server-side.
    
-   Buyer receives push notifications on status changes and can chat with vendor.
    
-   Active Order FAB behaves to spec.
    

----------

# Phase 4 — Vendor Dashboard & Management

Goal: vendor onboarding, menu and order management, vendor chat and quick replies, media upload.

## Task 4.1 — Vendor onboarding in-app

-   Sub-tasks

    -   [ ] Onboarding flow: create vendor record linked to `users_public.id`.

    -   [ ] Add drop-pin location selector (lat/lng) and address_text, upload business logo and first dish image.

    -   [ ] Validate vendor details (phone verified); create `vendors` row.

-   Owner: Frontend / Backend

-   Deliverable: Vendor onboarding flow.
    

## Task 4.2 — Menu management

-   Sub-tasks

    -   [ ] CRUD for dishes: add name, description, price_cents, image_url (upload via signed URL), prep_time_minutes, tags, availability toggle.

    -   [ ] Each change updates `dishes` table; RLS ensures vendor only modifies own dishes.

    -   [ ] Realtime propagation to buyers (dishes become available/unavailable instantly).

-   Owner: Frontend / Backend

-   Deliverable: Vendor menu management UI.
    

## Task 4.3 — Order queue & order management

-   Sub-tasks

    -   [ ] Vendor subscribes to `orders:vendor_id` realtime channel.

    -   [ ] Order card with state machine UI: Pending → Accept → Preparing → Ready → Completed. Provide accept/cancel actions (with confirmations).

    -   [ ] Implement "Ready" quick action that triggers push to buyer and moves order status via Edge function.

    -   [ ] Include pickup_code reveal and verification flow: vendor scans or enters pickup code to mark completed.

-   Owner: Frontend / Backend

-   Deliverable: Vendor dashboard with live order queue.
    

## Task 4.4 — Vendor chat & quick replies

-   Sub-tasks

    -   [ ] Scope chat to `order_id`; show sender role badges.

    -   [ ] Add quick replies and canned messages (configurable).

    -   [ ] Show unread badges and last message preview on order cards.

-   Owner: Frontend

-   Deliverable: Vendor chat UI working.
    

## Task 4.5 — Media uploads & storage

-   Sub-tasks

    -   [ ] Use an Edge function to return signed PUT URLs to `vendor_media` bucket.

    -   [ ] Validate file types & size server-side or via storage rules.

    -   [ ] Generate thumbnails on upload trigger (Edge function or scheduled job).

-   Owner: Backend

-   Deliverable: Secure image upload flow + thumbnails.
    

**Phase 4 Acceptance criteria**

-   Vendors can onboard, add dishes, and receive realtime orders.
    
-   Vendor cannot access or modify other vendors’ data (RLS enforced).
    
-   Order state changes are only via Edge function validated transitions.
    

----------

# Phase 5 — Payments, Wallets & Financial Flows (optional / modular)

Goal: add payments or keep cash-only initially. Prepare wallet integration architecture for future.

## Task 5.1 — Decide payment model (outcome recorded in system)

-   Sub-tasks

    -   [ ] If cash-only initially: add flags in UI & record payment_method = cash.

    -   [ ] If payments: integrate a provider (Stripe Connect / local provider) via Edge functions for payment intents and webhooks.

-   Owner: Product / Finance

-   Deliverable: Payment decision and provider chosen.
    

## Task 5.2 — Payment implementation (if chosen)

-   Sub-tasks

    -   [ ] Implement `payments` table and webhook handlers in Edge functions.

    -   [ ] Ensure server-side order status changes only after successful payment (or use authorized hold).

    -   [ ] Implement refund/dispute endpoints for admin.

    -   [ ] Ensure PCI scope minimized by using hosted payment flows or connectors.

-   Owner: Backend

-   Deliverable: Payments wired with webhooks & audit logging.
    

**Phase 5 Acceptance criteria**

-   Payment events are recorded in DB and tie to orders; refunds handled via admin panel.
    

----------

# Phase 6 — Polishing, Performance & Accessibility

Goal: optimize, harden, and finalize UX polish for production quality.

## Task 6.1 — Performance tuning

-   Sub-tasks

    -   [ ] Map optimizations: reduce redraws, reuse marker instances, cluster markers server-side.

    -   [ ] Pre-cache images (thumbnails) and use progressive loading.

    -   [ ] Use lazy loading for feed; avoid full rebuilds on small state changes.

-   Owner: Frontend

-   Deliverable: Performance checklist validated.
    

## Task 6.2 — Accessibility & internationalization

-   Sub-tasks

    -   [ ] WCAG AA pass: color contrast, touch target sizes, screen reader labels.

    -   [ ] I18n hooks: locale support in `users_public.metadata.locale`.

-   Owner: Frontend / QA

-   Deliverable: Accessibility report.
    

## Task 6.3 — Offline resiliency & sync

-   Sub-tasks

    -   [ ] Local cache of last feed & current vendor list.

    -   [ ] Message queue for outgoing chat; exponential backoff retry & conflict resolution.

    -   [ ] UI states for offline (disabled ordering with clear messaging).

-   Owner: Frontend

-   Deliverable: Offline behavior validated.
    

## Task 6.4 — Security hardening

-   Sub-tasks

    -   [ ] Penetration checklist: RLS review, audit log verification, secret rotation, least privilege access.

    -   [ ] Rate limit protections in Edge functions (requests per IP, messages per second).

    -   [ ] CD pipeline integration to only deploy Edge functions via CI.

-   Owner: Backend / DevOps

-   Deliverable: Security review & remediation log.
    

**Phase 6 Acceptance criteria**

-   App has acceptable performance on target devices; offline & accessibility checklist passed.
    

----------

# Phase 7 — QA, Testing & Compliance

Goal: exhaustive testing, RLS policy tests, and regulatory checklists.

## Task 7.1 — Automated tests

-   Sub-tasks

    -   [ ] Unit tests for Edge functions (happy paths + edge cases).

    -   [ ] Integration tests for create_order workflow (RPC call -> DB insert -> realtime event).

    -   [ ] RLS automated tests: create test sessions (buyer, vendor, admin) and verify table access denies/permits as expected.

    -   [ ] Flutter widget tests for core flows and Golden tests for visual regressions.

-   Owner: QA / Backend / Frontend

-   Deliverable: Test suites executed via CI.
    

## Task 7.2 — E2E acceptance tests

-   Sub-tasks

    -   [ ] Full flow: buyer places order -> vendor accepts -> vendor marks ready -> buyer picks up & completes.

    -   [ ] Simulate concurrency / duplicate order attempts to verify idempotency_key handling.

    -   [ ] Realtime stress test for channels (simulate many subscriptions).

-   Owner: QA

-   Deliverable: E2E run reports & bug list.
    

## Task 7.3 — Legal & privacy compliance

-   Sub-tasks

    -   [ ] Add privacy policy & terms of service for phone OTP and data usage.

    -   [ ] Implement data export & delete endpoints (per privacy laws).

    -   [ ] If payments used, validate PCI expectations with payment provider.

-   Owner: Legal / Product

-   Deliverable: Policy pages & data subject request doc.
    

**Phase 7 Acceptance criteria**

-   RLS tests pass; E2E flows pass; privacy & legal checks signed off.
    

----------

# Phase 8 — Beta Launch & Pilot

Goal: pilot in a small area with a handful of vendors and buyers to collect real metrics.

## Task 8.1 — Pilot onboarding & ops

-   Sub-tasks

    -   [ ] Onboard 2–10 vendors manually; provide vendor training material.

    -   [ ] Invite a small buyer cohort.

    -   [ ] Provide live support channel & log early issues in `moderation_reports`.

-   Owner: Ops / Product

-   Deliverable: Pilot cohort running.
    

## Task 8.2 — Monitoring & metrics

-   Sub-tasks

    -   [ ] Track key metrics: `orders_per_day`, `vendor_acceptance_rate`, `pickup_success_rate`, `avg_chat_messages_per_order`, `time_from_ready_to_pickup`.

    -   [ ] Capture Sentry errors & crash rate.

    -   [ ] Evaluate push reliability (delivery vs open).

-   Owner: Product / Analytics

-   Deliverable: Pilot metrics dashboard.
    

## Task 8.3 — Iteration

-   Sub-tasks

    -   [ ] Triage pilot issues, prioritize fixes, deploy hotfixes via CI.

    -   [ ] Roll out UX tweaks (pickup code visibility, order FAB behavior) and vendor workflow improvements.

-   Owner: Product / Dev

-   Deliverable: Updated release notes & changelog.
    

**Phase 8 Acceptance criteria**

-   Pilot metrics acceptable for launch decision; critical bugs fixed.
    

----------

# Phase 9 — Public Launch & Distribution

Goal: app store releases, support flows, and marketing readiness.

## Task 9.1 — App Store & Play Console

-   Sub-tasks

    -   [ ] Build release bundles, sign binaries, prepare store listings, screenshots, and privacy info.

    -   [ ] Set up release pipelines to publish via CI.

-   Owner: DevOps / Product

-   Deliverable: App store pages & release builds.
    

## Task 9.2 — Support & operations

-   Sub-tasks

    -   [ ] Setup customer support triage (in-app support + email + quick admin ops).

    -   [ ] Create escalation paths for disputes, refunds, banned vendors.

-   Owner: Ops / Product

-   Deliverable: Support runbook.
    

## Task 9.3 — Monitoring & autoscale

-   Sub-tasks

    -   [ ] Put in place alerts for errors, high DB CPU, high Realtime connections.

    -   [ ] Schedule backups & snapshots; confirm restore process.

-   Owner: DevOps

-   Deliverable: Monitoring dashboards & runbook.
    

**Phase 9 Acceptance criteria**

-   Apps available in stores; support system live; production monitoring active.
    

----------

# Phase 10 — Post-Launch Operations, Growth & Scale

Goal: grow user base and vendor coverage while iterating product-market fit.

## Task 10.1 — Growth experiments

-   Sub-tasks

    -   [ ] Implement promos & referral programs via `app_settings` and `notifications`.

    -   [ ] A/B test onboarding copy & map feed discovery.

-   Owner: Growth / Product

-   Deliverable: Experiment backlog & measurement.
    

## Task 10.2 — Scale & optimization

-   Sub-tasks

    -   [ ] Tune Postgres for higher load; consider read replicas if necessary.

    -   [ ] Introduce materialized views or geospatial tiling for dense vendor areas.

    -   [ ] Consider migrating static media to a CDN.

-   Owner: DevOps / Backend

-   Deliverable: Scaling plan & implementation.
    

## Task 10.3 — New features roadmap

-   Sub-tasks

    -   [ ] Wallets & in-app payments.

    -   [ ] Web vendor dashboard.

    -   [ ] Loyalty & subscriptions.

    -   [ ] Advanced analytics for vendors.

-   Owner: Product

-   Deliverable: Prioritized roadmap.
    

**Phase 10 Acceptance criteria**

-   System operates stably at target scale, growth experiments measured, new features prioritized.
    

----------

# Cross-cutting tasks (ongoing during many phases)

1.  **[ ] Audit logging & observability** — log key actions to `audit_logs` and wire Sentry.

2.  **[ ] Backups & retention** — daily DB backups and retention policy for PII.

3.  **[ ] Security reviews** — periodic pen tests & secret rotation.

4.  **[ ] Feature flags** — use `app_settings` to toggle features during rollout.

5.  **[ ] Documentation** — keep API docs, runbooks, design tokens, and onboarding docs updated.

6.  **[ ] Accessibility** — enforce on every UI change.
    

----------

# Deliverables you’ll get at the end of this plan (pick which you want generated now)

-   Full SQL migration file set (schema + RLS policies).
    
-   Edge function implementations for `create_order`, `change_order_status`, `send_push`.
    
-   Flutter scaffold with ThemeData, bottom nav, map+feed skeleton, Active Order FAB.
    
-   QA test suite skeleton and RLS tests.
    
-   Admin panel wireframe + permission model.
    

Tell me which of the above deliverables you want me to **produce right now** (pick one or more):  
A) Full SQL migrations + RLS policies  
B) Edge function code samples (Node/TS) for create_order & status transitions  
C) Flutter scaffold + ThemeData + sample components (liquid glass nav, FAB, persistent map)  
D) QA & RLS test plan (test scripts + assertions)

Pick A/B/C/D (or any combination) and I’ll generate it immediately.
