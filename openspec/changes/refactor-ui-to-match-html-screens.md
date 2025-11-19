# Refactor UI to Match HTML Screens (Android-first)

Platform: Android priority. Accept minor Material deviations (ripples, elevation, scroll physics) if typography, spacing, colors, radii, and visual hierarchy match the HTML inspiration.

UI Parity Rule: All rebuilt screens MUST visually match the HTML references under `screens/stitch_buyer_order_confirmation/**/code.html`. Golden tests will be used to enforce parity for key views.

---

## Phase 0 — Planning & Foundations

- [ ] Create change ID and register in OpenSpec (this file)
- [ ] Define acceptance criteria and sign-off owners (Design, Product)
- [ ] Confirm font choice (Plus Jakarta Sans) and add to `pubspec.yaml`
- [ ] Decide image assets strategy (SVG/PNG, thumbnails)

Acceptance
- Fonts load on device; sample screen renders match HTML typography

---

## Phase 1 — Theme & Design System

- [ ] Update `lib/core/theme/app_theme.dart` with:
  - Colors, typography (Plus Jakarta Sans), spacing scale, radii, elevations
  - Glassmorphism tokens for nav, cards, and overlays
- [ ] Shared atoms: buttons, chips, tags, icon buttons, cards, glass containers
- [ ] Bottom navigation background (glass) and FAB shape to spec
- [ ] Add font assets in `pubspec.yaml` and test text styles across screens

Acceptance
- Theme tokens align with HTML specs; sample components match spacing and radii

---

## Phase 2 — Buyer Core Screens (UI parity)

- [ ] Home Aesthetic Restyle
  - Source: `buyer_home_screen_-_aesthetic_enhancement/code.html`
  - Targets: `lib/features/map/screens/map_screen.dart`, `lib/features/feed/screens/feed_screen.dart`
  - Tasks: map hero behavior polish, feed cards restyle, debounce 600ms
- [ ] Dish Detail
  - Source: `buyer_dish_detail_screen/code.html`, `buyer_dish_detail_screen_-_aesthetic_enhancement/code.html`
  - Target: `lib/features/dish/screens/dish_detail_screen.dart`
  - Tasks: layout, typography, CTA, price, prep time, tags, image treatment
- [ ] Order Confirmation
  - Source: `buyer_order_confirmation/code.html`, `buyer_order_confirmation_-_aesthetic_enhancement/code.html`
  - Target: `lib/features/order/screens/order_confirmation_screen.dart`
  - Tasks: pickup code prominence, ETA, chat CTA
- [ ] Active Order Modal
  - Source: `active_order_modal/code.html`
  - Target: `lib/features/order/widgets/active_order_modal.dart`
  - Tasks: status timeline, pickup code visibility rules, route quick access

Acceptance
- Visual parity vs HTML for all 4 screens; order flow remains via Edge `create_order`

---

## Phase 3 — Buyer Secondary Screens

- [ ] Profile Screen
  - Source: `buyer_profile_screen/code.html`
  - Target: `lib/features/profile/screens/profile_screen.dart`
  - Tasks: layout restyle; integrate profile drawer
- [ ] Profile Drawer
  - Source: `profile_drawer/code.html`
  - Target: `lib/features/profile/widgets/profile_drawer.dart`
- [ ] Favourites (placed under Profile)
  - Source: `favourites_screen/code.html`
  - Target: `lib/features/profile/screens/favourites_screen.dart` (new)
  - Tasks: list, empty state, optimistic fav/unfav
- [ ] Notifications (placed under Profile)
  - Source: `notifications_screen/code.html`
  - Target: `lib/features/settings/screens/notifications_screen.dart` (new)
- [ ] Chat Detail
  - Source: `in-app_chat_screen/code.html`
  - Target: `lib/features/chat/screens/chat_detail_screen.dart`
- [ ] Settings
  - Source: `settings_screen/code.html`
  - Target: `lib/features/settings/screens/settings_screen.dart`
- [ ] Role Selection
  - Source: `role_selection_screen/code.html`
  - Target: `lib/features/auth/screens/role_selection_screen.dart` (new)
- [ ] Splash
  - Source: `splash_screen/code.html`
  - Target: `lib/features/auth/screens/splash_screen.dart` (new)
- [ ] Allow Location Permission
  - Source: `allow_location_permission/code.html`
  - Target: `lib/features/map/widgets/location_permission_sheet.dart` (new)
- [ ] Buyer Route Overlay
  - Source: `buyer_route_overlay/code.html`
  - Target: `lib/features/order/widgets/route_overlay.dart` (new)

Acceptance
- All screens visually match; favourites/notifications accessible from Profile per IA decision

---

## Phase 4 — Vendor Screens

- [ ] Vendor Dashboard
  - Source: `vendor_dashboard/code.html`, `vendor_dashboard_quick_tour/code.html`
  - Targets: `lib/features/vendor/screens/vendor_dashboard_screen.dart`, `vendor_quick_tour_screen.dart` (new)
  - Tasks: order queue cards restyle, quick tour flow
- [ ] Order Detail
  - Source: `vendor_order_detail/code.html`
  - Target: `lib/features/vendor/screens/order_detail_screen.dart` (new)
- [ ] Add Dish / Media Upload
  - Source: `vendor_add_dish_screen/code.html`
  - Target: `lib/features/vendor/screens/dish_edit_screen.dart`
- [ ] Business Info Entry
  - Source: `vendor_business_info_entry/code.html`
  - Target: `lib/features/vendor/screens/vendor_onboarding_screen.dart`
- [ ] Moderation Tools
  - Source: `vendor_moderation_tools/code.html`
  - Target: `lib/features/vendor/screens/moderation_tools_screen.dart` (new)
- [ ] Place Pin on Map
  - Source: `vendor_place_pin_on_map/code.html`
  - Target: `lib/features/vendor/widgets/place_pin_map.dart` (new or extracted)
- [ ] Availability Management
  - Source: `dish_availability_management/code.html`
  - Target: `lib/features/vendor/screens/availability_management_screen.dart` (new or integrate)

Acceptance
- Dashboard + detail workflows match HTML; actions still go through Edge functions

---

## Phase 5 — Routing, Guards, Deep Links

- [ ] Expand `lib/core/router/app_router.dart` with new routes
- [ ] Wire `MainAppShell`, `AuthGuard`, `ProfileGuard` to new screens
- [ ] Extend `deep_link_service.dart` for dish, chat, orders

Acceptance
- Navigation works across all new screens; back stack and guards correct

---

## Phase 6 — Backend Wiring (no schema changes)

- [ ] Orders
  - Ensure create via Edge `create_order`; pickup-only; code visibility rules
  - Status changes via `change_order_status`; completion requires code
- [ ] Chat
  - Realtime by `order_id`; optimistic UI; retry states
- [ ] Favourites
  - CRUD to `favourites`; optimistic updates
- [ ] Notifications
  - Hook to `notification_service`; settings persist
- [ ] Media Uploads
  - Signed URLs; validate type/size; show progress
- [ ] Location
  - Permission flow; vendor lat/lng save
- [ ] Secrets
  - Move Supabase URL/key to `--dart-define`; remove from `lib/main.dart`

Acceptance
- All flows functional on Android device; no direct DB writes for order status

---

## Phase 7 — Testing & Quality

- [ ] Widget tests: dish detail, order confirmation, active order modal, chat, vendor dashboard/detail, settings/notifications
- [ ] Golden tests for visual parity (selected screens)
- [ ] Integration: buyer create→ready→completed (pickup code); vendor queue; chat
- [ ] Analyze/lints green

Acceptance
- Tests pass locally and in CI; golden diffs within tolerance

---

## Phase 8 — Accessibility & Performance

- [ ] A11y: labels, contrast, tap targets, dynamic text
- [ ] Performance: list virtualization, image thumbnails, map marker clustering hooks, 600ms debounce

Acceptance
- A11y checklist pass; smooth scroll and map interactions on mid-range Android

---

## Phase 9 — UAT & Sign-off

- [ ] Stakeholder reviews per screen against HTML references
- [ ] Fix delta issues; capture deviations with rationale (Material behavior)
- [ ] OpenSpec validation; archive change after release

Acceptance
- Design/Product sign-off; OpenSpec change archived

---

## Material Deviation Policy (Android)

- Acceptable: ripple effects, slight elevation differences, platform scroll physics, input focus rings
- Not acceptable: typography scale mismatches, color token deviations, spacing/radius inconsistencies, missing elements

---

## Traceability (HTML → Flutter)

- Buyer
  - active_order_modal → `lib/features/order/widgets/active_order_modal.dart`
  - allow_location_permission → `lib/features/map/widgets/location_permission_sheet.dart`
  - buyer_dish_detail_screen(+_aesthetic) → `lib/features/dish/screens/dish_detail_screen.dart`
  - buyer_home_screen_-_aesthetic_enhancement → `lib/features/map/screens/map_screen.dart`, `lib/features/feed/screens/feed_screen.dart`
  - buyer_order_confirmation(+_aesthetic) → `lib/features/order/screens/order_confirmation_screen.dart`
  - buyer_profile_screen → `lib/features/profile/screens/profile_screen.dart`
  - buyer_route_overlay → `lib/features/order/widgets/route_overlay.dart`
  - favourites_screen (Profile) → `lib/features/profile/screens/favourites_screen.dart`
  - in-app_chat_screen → `lib/features/chat/screens/chat_detail_screen.dart`
  - notifications_screen (Profile) → `lib/features/settings/screens/notifications_screen.dart`
  - profile_drawer → `lib/features/profile/widgets/profile_drawer.dart`
  - role_selection_screen → `lib/features/auth/screens/role_selection_screen.dart`
  - settings_screen → `lib/features/settings/screens/settings_screen.dart`
  - splash_screen → `lib/features/auth/screens/splash_screen.dart`
- Vendor
  - vendor_add_dish_screen → `lib/features/vendor/screens/dish_edit_screen.dart`
  - vendor_business_info_entry → `lib/features/vendor/screens/vendor_onboarding_screen.dart`
  - vendor_dashboard(+quick_tour) → `lib/features/vendor/screens/vendor_dashboard_screen.dart`, `vendor_quick_tour_screen.dart`
  - vendor_moderation_tools → `lib/features/vendor/screens/moderation_tools_screen.dart`
  - vendor_order_detail → `lib/features/vendor/screens/order_detail_screen.dart`
  - vendor_place_pin_on_map → `lib/features/vendor/widgets/place_pin_map.dart`
  - dish_availability_management → `lib/features/vendor/screens/availability_management_screen.dart`

---

## Acceptance Criteria (Overall)

- Android UI matches HTML inspiration across all targeted screens
- All flows wired to Supabase and Edge Functions; no direct status mutations
- Tests and analyze green; a11y and performance acceptable
