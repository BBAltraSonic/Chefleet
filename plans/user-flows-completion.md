# Chefleet User Flows Completion Plan

Status: planning only (no implementation in this commit)

## Goals

- Deliver complete buyer and vendor flows with zero inconsistencies.
- Achieve Android-first UI parity with the HTML reference screens.
- Unify navigation, data contracts, and backend calls to prevent mismatches.

## Global Consistency Decisions

- Navigation: use go_router only (`context.go`/`context.push`), route constants live in `AppRouter`.
- Data: use `total_amount` (decimal) across app; remove `total_cents` logic and conversions.
- Tables: persist notification preferences on `users_public.notification_preferences` (key = `id`).
- Backend: Edge Functions for order creation and status transitions (`create_order`, `change_order_status`). Use Postgres RPC for pickup verification (`verify_pickup_code`) to match current implementation. No direct client DB status writes.
- Platform/UI: Android priority, match HTML for typography, spacing, color tokens, radii; accept Material ripples/elevation deltas.
- Feature flags: gate moderation tools behind a flag; exclude admin flows from mobile.

## Screen Inventory and Mapping (HTML → Flutter)

Source of truth for coverage: `openspec/changes/refactor-ui-to-match-html-screens.md`

Buyer
- active_order_modal → `lib/features/order/widgets/active_order_modal.dart`
- allow_location_permission → `lib/features/map/widgets/location_permission_sheet.dart` (new)
- buyer_dish_detail_screen(+_aesthetic) → `lib/features/dish/screens/dish_detail_screen.dart`
- buyer_home_screen_-_aesthetic_enhancement → `lib/features/map/screens/map_screen.dart`, `lib/features/feed/screens/feed_screen.dart`
- buyer_order_confirmation(+_aesthetic) → `lib/features/order/screens/order_confirmation_screen.dart`
- buyer_profile_screen → `lib/features/profile/screens/profile_screen.dart`
- buyer_route_overlay → `lib/features/order/widgets/route_overlay.dart` (new)
- favourites_screen (Profile) → `lib/features/profile/screens/favourites_screen.dart`
- in-app_chat_screen → `lib/features/chat/screens/chat_detail_screen.dart`
- notifications_screen (Profile) → `lib/features/settings/screens/notifications_screen.dart`
- profile_drawer → `lib/features/profile/widgets/profile_drawer.dart`
- role_selection_screen → `lib/features/auth/screens/role_selection_screen.dart`
- settings_screen → `lib/features/settings/screens/settings_screen.dart`
- splash_screen → `lib/features/auth/screens/splash_screen.dart`

Vendor
- vendor_add_dish_screen → `lib/features/vendor/screens/dish_edit_screen.dart`
- vendor_business_info_entry → `lib/features/vendor/screens/vendor_onboarding_screen.dart`
- vendor_dashboard(+quick_tour) → `lib/features/vendor/screens/vendor_dashboard_screen.dart`, `lib/features/vendor/screens/vendor_quick_tour_screen.dart` (missing)
- vendor_moderation_tools → `lib/features/vendor/screens/moderation_tools_screen.dart`
- vendor_order_detail → `lib/features/vendor/screens/order_detail_screen.dart`
- vendor_place_pin_on_map → `lib/features/vendor/widgets/place_pin_map.dart`
- dish_availability_management → `lib/features/vendor/screens/availability_management_screen.dart`

Notes
- Orders tab (buyer) is part of the persistent nav shell; powered by `ActiveOrdersBloc`.
- New “quick tour” and “place pin” are tracked as new screens/widgets.

## Gaps and Fixes Matrix (high level)

- Function mismatch: ensure all calls use `change_order_status` (done where applicable; audit remains).
- Monetary fields: standardize on `total_amount` everywhere; update filters/sorters, UI formatting (ongoing audit).
- Notifications storage: use `users_public.id`; load/update `notification_preferences` there.
- Navigation: replace `Navigator.pushNamed`/`MaterialPageRoute` with `go_router`; grep to verify none remain in primary flows.
- Orders tab: implemented UI + bloc wiring; verify states and pull-to-refresh UX.
- Pickup code: keep `verify_pickup_code` as Postgres RPC (consistent with current bloc). Verify SQL function exists; add migration if missing. Wire buyer confirmation and vendor validation to shared flow.

## Coverage and Status Matrix (by HTML reference)

Buyer
- Map (map_screen): Exists — `lib/features/map/screens/map_screen.dart` — UI parity pending (debounce 600ms, hero polish)
- Feed (feed_screen): Exists — `lib/features/feed/screens/feed_screen.dart` — UI parity pending (card restyle)
- Dish Detail: Exists — `lib/features/dish/screens/dish_detail_screen.dart` — UI parity pending (layout/CTA/price/tags)
- Order Confirmation: Exists — `lib/features/order/screens/order_confirmation_screen.dart` — UI parity pending (pickup code prominence, ETA, chat CTA)
- Active Order Modal: Exists — `lib/features/order/widgets/active_order_modal.dart` — UI parity pending (status timeline, pickup code rules)
- Buyer Route Overlay: Exists — `lib/features/order/widgets/route_overlay.dart` — Verify design tokens, attach points
- Profile Screen: Exists — `lib/features/profile/screens/profile_screen.dart` — Restyle to parity; uses profile drawer
- Profile Drawer: Exists — `lib/features/profile/widgets/profile_drawer.dart` — Restyle + routing unification
- Favourites: Exists — `lib/features/profile/screens/favourites_screen.dart` — Empty state and optimistic updates
- Notifications: Exists — `lib/features/settings/screens/notifications_screen.dart` — Storage unified to `users_public`
- Chat Detail: Exists — `lib/features/chat/screens/chat_detail_screen.dart` — Parity pass (header/status colors), quick replies
- Settings: Exists — `lib/features/settings/screens/settings_screen.dart` — Parity pass
- Role Selection: Exists — `lib/features/auth/screens/role_selection_screen.dart` — Parity pass
- Splash: Exists — `lib/features/auth/screens/splash_screen.dart` — Parity pass
- Allow Location Permission: Exists — `lib/features/map/widgets/location_permission_sheet.dart` — Parity pass

Vendor
- Dashboard: Exists — `lib/features/vendor/screens/vendor_dashboard_screen.dart` — Restyle cards, metrics
- Quick Tour: Missing — `lib/features/vendor/screens/vendor_quick_tour_screen.dart` — New screen required
- Order Detail: Exists — `lib/features/vendor/screens/order_detail_screen.dart` — Parity pass (actions/status timeline)
- Add/Edit Dish: Exists — `lib/features/vendor/screens/dish_edit_screen.dart` — Media upload polish per HTML
- Business Info Entry: Exists — `lib/features/vendor/screens/vendor_onboarding_screen.dart` — Parity pass
- Moderation Tools: Exists — `lib/features/vendor/screens/moderation_tools_screen.dart` — Feature-flagged
- Place Pin on Map: Exists — `lib/features/vendor/widgets/place_pin_map.dart` — Verify styling/tokens
- Availability Management: Exists — `lib/features/vendor/screens/availability_management_screen.dart` — Parity pass

## UI Parity Requirements (per key screen)

- Order Confirmation
  - Header: vendor name, order ID, status badge; ETA indicator
  - Pickup code: large, high-contrast; copy/share action; visibility rules by status
  - Summary: items with qty/price, subtotal/tax/total using `total_amount`
  - Actions: Chat CTA, view route, back to feed

- Active Order Modal
  - Status timeline: pending → accepted → preparing → ready → completed
  - Live status colors; pickup code shown only at accepted/ready/completed
  - Quick actions: chat, view route, refresh

- Dish Detail
  - Hero image with overlay; name, tags, prep time; price; quantity stepper
  - CTA: Add to order; state feedback; error handling

- Map/Feed
  - 600ms search debounce; glass nav and FAB; vendor card restyle per HTML

- Vendor Dashboard/Detail
  - Queue cards with status chips; revenue/metrics tiles; detail timeline
  - Actions: accept/prepare/ready via `change_order_status`; pickup verification entry

Acceptance for each: side-by-side golden snapshot matches within tolerance; tap flows functional.

## Routing Consistency Tasks (no code changes in this plan)

Replace remaining Navigator/MaterialPageRoute usage with go_router; add routes as needed.
- Files/locations to migrate:
  - lib/features/profile/widgets/profile_drawer.dart:272 (`/profile/edit`)
  - lib/features/order/screens/order_confirmation_screen.dart:646,651,658
  - lib/features/order/widgets/active_order_modal.dart:412
  - lib/features/profile/screens/profile_screen.dart:32,98 (MaterialPageRoute usages)
  - lib/features/profile/screens/favourites_screen.dart:273 (MaterialPageRoute)
  - lib/features/vendor/screens/media_upload_screen.dart:508 (MaterialPageRoute)
  - lib/features/chat/screens/chat_list_screen.dart:186 (MaterialPageRoute)
  - lib/core/router/app_router.dart:295 (temporary MaterialPageRoute to ChatDetail)

Router additions to support detail pages with params:
- `/chat/detail/:orderId` (ChatDetailScreen) with `orderStatus` via query/extra
- `/profile/edit` (Profile management) if kept
- `/vendor/quick-tour` (new)

## Backend Contract Audit (to avoid mismatches)

Client usage (current):
- Edge Functions: `create_order` (order creation), `change_order_status` (vendor actions)
- Postgres RPC: `verify_pickup_code` (pickup completion)

Actions:
- Confirm `verify_pickup_code` SQL function exists and enforces ownership and one-time code use; add migration if missing.
- Ensure `change_order_status` and `create_order` return consistent shapes: `{ success:boolean, message?:string, data?:{...} }`.
- Add error code enums and map to user-facing messages consistently.

## No-more-mismatches Checks (automatable)

- Navigation: `rg -n "Navigator\.pushNamed|MaterialPageRoute\(" lib/` must return 0 before sign-off.
- Data contract: `rg -n "total_cents"` must return 0; `total_amount` used everywhere.
- Tables: `rg -n "from\('user_profiles'\)|eq\('user_id'"` must return 0 in app code.
- Backend: `rg -n "order_status_update"` must return 0 in app code.

## Work Plan (aligned to OpenSpec Phases)

Phase 0 — Planning & Foundations
- [ ] Register change in OpenSpec (create change ID, reference this plan)
- [ ] Confirm font choice (Plus Jakarta Sans) is added to `pubspec.yaml`
- [ ] Add/verify font assets and licenses in assets/fonts
- [ ] Decide image assets strategy (SVG/PNG), and compression pipeline
- [ ] Define acceptance criteria per screen and sign-off owners (Design/Product/Eng)

Phase 1 — Theme & Design System
- [ ] Update `lib/core/theme/app_theme.dart` tokens: colors, typography, spacing, radii, elevations
- [ ] Implement glass tokens: nav background, cards, overlays
- [ ] Create shared atoms: buttons (primary/secondary/tertiary), chips/tags, icon buttons, cards, glass container
- [ ] Style Persistent bottom navigation (glass) and FAB shape per HTML
- [ ] Add fonts to `pubspec.yaml` and preload; verify sample text styles
- [ ] Golden baseline: sample components snapshot

Phase 2 — Buyer Core Screens (UI parity)
- Map (map_screen)
  - [ ] Implement 600ms search debounce
  - [ ] Apply hero/blur aesthetics and glass UI per tokens
  - [ ] Verify clustering hooks exist (no change if out-of-scope)
- Feed (feed_screen)
  - [ ] Restyle cards per HTML (spacing, radii, typography)
  - [ ] Loading skeletons and empty state
  - [ ] Pagination/refresh behavior parity
- Dish Detail (dish_detail_screen)
  - [ ] Layout to spec (hero image, name, tags, prep time)
  - [ ] Price display (uses `total_amount` math for line items)
  - [ ] Quantity stepper + add to order CTA (wire to OrderBloc)
  - [ ] Error/empty states
- Order Confirmation (order_confirmation_screen)
  - [ ] Pickup code prominence (large code, copy/share)
  - [ ] ETA indicator and status badge
  - [ ] Order summary (subtotal/tax/total using `total_amount`)
  - [ ] Actions: Chat CTA, View Route CTA
- Active Order Modal (active_order_modal)
  - [ ] Status timeline (pending→accepted→preparing→ready→completed)
  - [ ] Pickup code visibility rules by status
  - [ ] Quick actions: chat, view route, refresh
  - [ ] Bloc state parity and error messaging

Phase 3 — Buyer Secondary Screens
- Profile (profile_screen)
  - [ ] Restyle layout per HTML
  - [ ] Integrate profile drawer and route entries
- Profile Drawer (profile_drawer)
  - [ ] Restyle and unify navigation via go_router
- Favourites (favourites_screen)
  - [ ] List rendering and card style
  - [ ] Empty state and Explore CTA to Feed
  - [ ] Optimistic fav/unfav updates
- Notifications (notifications_screen)
  - [ ] Ensure storage is `users_public.notification_preferences`
  - [ ] Load/save toggles; error/empty states; toasts
- Chat Detail (chat_detail_screen)
  - [ ] Header parity with order status color
  - [ ] Quick replies; autoscroll; empty/error states
  - [ ] Attachment stub and snackbar
- Settings (settings_screen)
  - [ ] Layout parity; policy/terms dialogs; go_router navigation
- Role Selection (role_selection_screen)
  - [ ] Visual parity and flow into onboarding
- Splash (splash_screen)
  - [ ] Visual parity and go_router redirects validated
- Location Permission (location_permission_sheet)
  - [ ] Visual parity and permission handling UX
- Buyer Route Overlay (route_overlay)
  - [ ] Visual parity and attach points in order views

Phase 4 — Vendor Screens
- Dashboard (vendor_dashboard_screen)
  - [ ] Restyle queue cards; status chips; metrics tiles
  - [ ] Filters (pending/active/completed) and realtime updates
  - [ ] Quick Tour entry point
- Quick Tour (vendor_quick_tour_screen) — missing
  - [ ] Create screen and route; mark onboarding completion state
- Order Detail (order_detail_screen)
  - [ ] Status timeline parity; actions trigger `change_order_status`
  - [ ] Error handling and success toasts; refresh after action
- Add/Edit Dish (dish_edit_screen)
  - [ ] Media upload flow (signed URLs), progress, type/size validation
  - [ ] Form validation and error messaging
- Business Info (vendor_onboarding_screen)
  - [ ] Parity for business fields and validation
- Moderation Tools (moderation_tools_screen)
  - [ ] Feature flag and route guard; hidden in production builds
- Place Pin on Map (place_pin_map)
  - [ ] Style tokens and onboarding integration
- Availability Management (availability_management_screen)
  - [ ] Schedule UI, toggles, parity checks

Phase 5 — Routing, Guards, Deep Links
- [ ] Expand `AppRouter` with missing routes:
  - [ ] `/chat/detail/:orderId` (ChatDetailScreen; pass `orderStatus` via query/extra)
  - [ ] `/profile/edit` (if kept)
  - [ ] `/vendor/quick-tour`
- [ ] Verify `ShellRoute` tabs (`/map`, `/feed`, `/orders`, `/chat`, `/profile`)
- [ ] Guards: auth/profile creation logic; allow settings/map/feed/profile when profile missing
- [ ] Deep links: dish, chat (by order), orders
- Migrate remaining Navigator/MaterialPageRoute usages to go_router:
  - [ ] lib/features/profile/widgets/profile_drawer.dart:272 (`/profile/edit`)
  - [ ] lib/features/order/screens/order_confirmation_screen.dart:646,651,658
  - [ ] lib/features/order/widgets/active_order_modal.dart:412
  - [ ] lib/features/profile/screens/profile_screen.dart:32,98
  - [ ] lib/features/profile/screens/favourites_screen.dart:273
  - [ ] lib/features/vendor/screens/media_upload_screen.dart:508
  - [ ] lib/features/chat/screens/chat_list_screen.dart:186
  - [ ] lib/core/router/app_router.dart:295 (temporary)

Phase 6 — Backend Wiring (no schema changes)
- [ ] Confirm `verify_pickup_code` Postgres function exists; add migration if missing
- [ ] Align Edge responses (`create_order`, `change_order_status`) to `{ success, message, data }`
- [ ] Order creation idempotency key handling and error mapping
- [ ] Ensure `total_amount` used consistently in UI calculations
- [ ] Notifications persist to `users_public.notification_preferences`
- [ ] Media uploads via signed URLs; enforce size/type checks client-side
- [ ] Chat realtime subscription by `order_id`; unsubscribe on dispose
- [ ] Move secrets to `--dart-define`; remove from code

Phase 7 — Testing & Quality
- Widget tests
  - [ ] Dish Detail
  - [ ] Order Confirmation
  - [ ] Active Order Modal
  - [ ] Chat Detail
  - [ ] Vendor Dashboard/Detail
  - [ ] Settings/Notifications
- Golden tests (visual parity)
  - [ ] Map hero sample, Feed card, Dish Detail, Order Confirmation, Dashboard card
- Integration tests
  - [ ] Buyer flow: create → ready → completed (pickup code)
  - [ ] Vendor queue and status transitions
  - [ ] Chat realtime
- [ ] Analyze/lints green

Phase 8 — Accessibility & Performance
- A11y
  - [ ] Semantics, labels, focus order
  - [ ] Dynamic text scaling and tap targets
  - [ ] Contrast per tokens
- Performance
  - [ ] List virtualization and image thumbnails/caching
  - [ ] Map marker clustering hooks
  - [ ] 600ms debounce verified; jank monitoring

Phase 9 — UAT & Sign-off
- [ ] Stakeholder reviews against HTML per screen
- [ ] Capture/resolve delta issues and document acceptable Material deviations
- [ ] OpenSpec validation and archive change after release

## Routes and Deep Links Catalog

App Routes (go_router)
- Core: `/splash`, `/auth`, `/role-selection`, `/profile-creation`, `/map`, `/feed`, `/orders`, `/chat`, `/profile`, `/favourites`, `/notifications`, `/settings`, `/dish/:dishId`
- Vendor: `/vendor`, `/vendor/orders/:orderId`, `/vendor/dishes/add`, `/vendor/dishes/edit`, `/vendor/availability/:vendorId`, `/vendor/moderation`, `/vendor/onboarding`, `/vendor/quick-tour` (new)

Non-route surfaces
- Location permission sheet (bottom sheet/inline widget)
- Buyer route overlay (attached to map/order views)

Deep Links (examples)
- `chefleet://dish/:dishId`
- `chefleet://chat?order=:orderId`
- `chefleet://orders/:orderId`

## Definition of Done (per flow)

Buyer
- Auth → Profile creation → Map/Feed → Dish Detail → Create order → Confirmation (pickup code visible) → Active Orders list → Chat → Pickup complete.
- UI parity checks pass against HTML; totals shown using `total_amount`; routes use go_router; no direct DB status writes; tests pass.

Vendor
- Dashboard queue → Order Detail → Status transitions via Edge → Pickup verification by code → Chat workflow → Completed.
- UI parity checks pass; routes and state management consistent; tests pass.

## Risks & Mitigations

- Visual parity drift: cover critical screens with golden tests and pinned fonts/assets.
- Contract mismatches: maintain a data contract doc in code (types/constants); add CI grep checks for `Navigator.pushNamed` and `total_cents`.
- Pickup code security: validate on server with one-time semantics; throttle attempts.

## Estimates (rough)

- Theme/system: 0.5–1d
- Buyer core: 1.5–2d
- Buyer secondary: 1–1.5d
- Vendor screens: 1.5–2d
- Routing/deep links: 0.5d
- Backend wiring: 0.5d
- Tests/quality: 1–1.5d
- A11y/perf: 0.5d

Total: ~6–7.5 days

## Acceptance Checklist (high level)

- [ ] All screens listed above exist and render with parity on Android
- [ ] All buyer and vendor flows work end-to-end
- [ ] Navigation unified on go_router; route constants referenced everywhere
- [ ] Data contracts aligned (`total_amount`, users_public preferences)
- [ ] Edge Functions used for status changes and pickup verification
- [ ] Tests (widget, golden, integration) pass locally and in CI
