# Navigation Redesign Plan - Remove Bottom Navigation & Center Nearby Dishes
**Created**: 2025-11-23  
**Priority**: High  
**Owner**: Navigation / UX  

---

## 1. Objectives

- **Remove bottom navigation** entirely from the consumer app shell.
- **Delete the Feed tab** and rely on "Nearby Dishes" as the primary discovery surface.
- **Keep Chat entry inside Active Orders only** (no dedicated chat tab).
- **Expose Profile entry by the search bar** in the primary browsing surface.
- Preserve existing order and vendor flows while simplifying navigation.

---

## 2. Current State Overview

### 2.1 Navigation Architecture
- `lib/core/router/app_router.dart`
  - Uses `GoRouter` with a `ShellRoute` that wraps `PersistentNavigationShell`.
  - Defines routes for `/map`, `/feed`, `/orders`, `/chat`, `/profile` and others.
- `lib/shared/widgets/persistent_navigation_shell.dart`
  - Renders the main scaffold with:
    - `IndexedStack` of tab children: Map, Feed, Orders, Chat, Profile.
    - `GlassBottomNavigation` as `bottomNavigationBar` (glassmorphic bottom nav).
    - `OrdersFloatingActionButton` docked in the center.
- `lib/core/blocs/navigation_bloc.dart`
  - `NavigationTab` model with 5 tabs: `map`, `feed`, `orders`, `chat`, `profile`.
  - BLoC manages `currentTab`, active order count, unread chat count.
  - `NavigationTabExtension.navigationTabs` returns [map, feed, chat, profile].
  - `NavigationBloc.selectTab` used by `GlassBottomNavigation` to change tabs.

### 2.2 Discovery Surfaces
- `lib/features/feed/screens/feed_screen.dart`
  - Implements "Nearby Dishes" as a scrollable list driven by `MapFeedBloc`.
  - Uses `SliverAppBar` with title "Nearby Dishes" and filter icon.
  - Has 100px bottom padding (`SliverToBoxAdapter`) for the bottom nav.
- `lib/features/map/blocs/map_feed_bloc.dart`
  - Provides dishes and vendors data for map and feed surfaces.
- `lib/features/map/screens/map_screen.dart`
  - Primary map-based exploration surface (exact UI to be referenced during implementation).

### 2.3 Chat & Orders
- `lib/features/order/blocs/active_orders_bloc.dart`
- `lib/features/order/widgets/active_order_modal.dart`
- `lib/features/chat/screens/chat_screen.dart` and `chat_detail_screen.dart`
  - Chat currently has a dedicated bottom nav tab and detailed chat routes.
  - Active orders already expose order-specific chat via chat detail routes.

### 2.4 Profile Access
- `lib/features/profile/screens/profile_screen.dart`
  - Currently surfaced as a dedicated bottom nav tab.
- No dedicated profile affordance in the search / app bar surfaces yet.

---

## 3. Target Navigation Model

### 3.1 High-Level UX
- **Primary Surface**: Nearby Dishes list + map context.
  - Either:
    - A unified screen combining map + list, or
    - Map as entry point with a clear entry to the Nearby Dishes list.
- **No global bottom navigation**.
- **Orders FAB** remains the primary entry point to active orders.
- **Chat**: accessed from active orders / order detail only.
- **Profile**: accessed via an icon/avatar button near the search bar / app bar.

### 3.2 Technical Target State
- `PersistentNavigationShell` no longer renders `GlassBottomNavigation`.
- `NavigationTab` no longer includes `feed` and `chat` tabs.
- Router no longer exposes `/feed` as a top-level tab route, and `/chat` is only used for order-specific chat as appropriate.
- Main consumer entry (after splash/auth/profile) lands on the map / nearby dishes experience.

---

## 4. Implementation Phases

### Phase 1: Specification & Safety

1. **Create OpenSpec change**: `remove-bottom-navigation`.
   - Location: `openspec/changes/remove-bottom-navigation/`.
   - Files:
     - `proposal.md`: rationale and high-level UX.
     - `tasks.md`: mirror the phases below as checklist.
     - `specs/navigation/spec.md`: deltas for navigation capability.
     - `specs/feed/spec.md`: deltas for feed / discovery capability.
2. **Update specs** to:
   - **REMOVED Requirements**: bottom navigation, feed tab, chat tab.
   - **MODIFIED Requirements**: navigation, discovery, and profile access.
3. Run `openspec validate remove-bottom-navigation --strict` and fix any spec issues.

### Phase 2: Core Navigation Model Refactor

#### 2.1 Update NavigationTab Model
- File: `lib/core/blocs/navigation_bloc.dart`
- Actions:
  - Remove `NavigationTab.feed` and `NavigationTab.chat` constants.
  - Re-index tabs as needed:
    - `map` → index 0.
    - `orders` (if still represented) → index 1.
    - `profile` → index 2.
  - Update `NavigationTab.values` to reflect new set.
  - Update `NavigationTabExtension.navigationTabs` list (no feed/chat).
- Consider whether `NavigationBloc` is still needed; if navigation is simplified to one main surface with contextual entries, we might:
  - Keep the bloc but reduce it to track orders badge counts only, **or**
  - Retain it short-term to minimize risk, and de-scope full removal from this change.

#### 2.2 Remove GlassBottomNavigation from Shell
- File: `lib/shared/widgets/persistent_navigation_shell.dart`
- Actions:
  - Remove `bottomNavigationBar: const GlassBottomNavigation(),` from `Scaffold`.
  - Decide final shell structure:
    - Option A (minimal): keep `IndexedStack` with a single child (map / nearby dishes), still using `OrdersFloatingActionButton`.
    - Option B (simpler): replace `IndexedStack` with a direct child widget (map / nearby dishes), if no tabbing is needed.
  - If `IndexedStack` stays (e.g., map + vendor dashboard), document clearly which indices are used.
- Ensure FAB still appears and opens Active Orders modal as before.

#### 2.3 Simplify AppRouter Tab Routing
- File: `lib/core/router/app_router.dart`
- Actions:
  - In `ShellRoute` builder:
    - Update `PersistentNavigationShell(children: [...])` to reflect reduced set of root children.
    - Remove `FeedScreen()` and `ChatScreen()` from the children list.
  - In shell `routes` list:
    - Remove `/feed` and `/chat` as shell tab locations.
    - Retain `/orders` and `/profile` only if they are still conceptually separate root surfaces.
  - Update `navigateToTab` mapping to match new tab indices or deprecate this helper if no longer required.
- Run a full-text search for `/feed` and `/chat` usage to ensure there are no stale tab references.

### Phase 3: Nearby Dishes as Primary Discovery Surface

#### 3.1 Decide Screen Ownership
- Options to clarify before coding:
  - **Option 1 (Preferred)**: Make `FeedScreen` the main "Nearby Dishes" list screen, navigable from the map (e.g., button or bottom sheet), and/or used as the primary post-auth entry surface.
  - **Option 2**: Integrate the list view into `MapScreen` (combined map + list layout).
- Document final decision in the OpenSpec change and this plan.

#### 3.2 Refactor FeedScreen if Kept
- File: `lib/features/feed/screens/feed_screen.dart`
- Actions:
  - Rename visually (and optionally via file/class name) to emphasize "Nearby Dishes" rather than generic feed.
  - Remove the bottom padding `SliverToBoxAdapter` with `SizedBox(height: 100)` that existed purely for the bottom nav.
  - Ensure `MapFeedBloc` initialization and infinite scroll behavior remain intact.
- Routing:
  - Add an explicit `GoRoute` (if not present after shell adjustments) for the "Nearby Dishes" surface, e.g. `/nearby` or nested under map.
  - Ensure the map or main entry can navigate to this route (e.g., "See nearby dishes" button).

#### 3.3 MapScreen Integration
- File: `lib/features/map/screens/map_screen.dart`
- Actions (depending on chosen UX):
  - Add a clear entry point (button, handle, or tab-like toggle) to open the Nearby Dishes list.
  - Optionally inject a collapsing/expanding sheet that shows snippets of nearby dishes backed by the same `MapFeedBloc`.
- Ensure location + dish loading logic is consistent across map and list.

### Phase 4: Chat Access via Active Orders Only

#### 4.1 Audit Chat Entry Points
- Files:
  - `lib/features/chat/screens/chat_screen.dart`
  - `lib/features/chat/screens/chat_detail_screen.dart`
  - `lib/features/order/widgets/active_order_modal.dart`
  - Any widgets that navigate to `/chat` or `/chat/detail`.
- Actions:
  - Remove navigation links/buttons that lead to a global `/chat` tab screen.
  - **Keep** order-specific chat detail screens accessible from:
    - Active Orders modal.
    - Order detail screens.

#### 4.2 Router Cleanup
- File: `lib/core/router/app_router.dart`
- Actions:
  - Decide whether to keep a generic `/chat` screen route at all.
    - If not needed, remove the `chatRoute` constant and the `GoRoute` for `/chat`.
  - Keep `chatDetailRoute` (`/chat/detail/:orderId`) for order-specific conversations.

### Phase 5: Profile Entry near Search Bar

#### 5.1 Identify Primary App Bar / Search Bar
- Likely locations:
  - `FeedScreen` `SliverAppBar` (currently shows "Nearby Dishes" title and filter icon).
  - `MapScreen` app bar / search input.

#### 5.2 Add Profile Icon/Button
- Files:
  - `lib/features/feed/screens/feed_screen.dart` and/or `lib/features/map/screens/map_screen.dart`.
- Actions:
  - Add an `IconButton` or avatar button in the app bar actions to open Profile.
  - Style it consistently with app theme and glass UI where applicable.
  - On tap, navigate to `AppRouter.profileRoute` using `context.go()` or `context.push()` as appropriate.
- Ensure accessibility (tooltip/semantics label: "Profile").

### Phase 6: UI Polish & Theming

1. **Remove bottom-nav-specific spacing** across screens that anticipated the nav height.
2. Ensure FAB has adequate safe area padding now that the nav is gone.
3. Confirm no visual regressions on:
   - Map screen.
   - Nearby Dishes list.
   - Orders modal.
4. Align with glass aesthetic:
   - If new containers are added (e.g., for profile avatar or filters), use `GlassContainer` and `AppTheme.glassTokens` as per existing patterns.

### Phase 7: Testing & Validation

#### 7.1 Unit & Widget Tests
- Update or add tests in:
  - `test/features/.../navigation_*_test.dart` (create if missing).
  - `test/features/feed/...` for Nearby Dishes screen behavior.
- Test cases:
  - **Navigation**:
    - App launches → post-auth → lands on map/nearby surface.
    - Tapping profile icon opens profile screen.
    - FAB opens Active Orders modal.
  - **Regression**:
    - No widget still expects a bottom nav.
    - No references to `NavigationTab.feed` or `NavigationTab.chat`.

#### 7.2 Integration Tests
- Update existing integration tests in `integration_test/`:
  - Remove flows that tap on bottom nav items.
  - Replace with flows using FAB, map, and profile icon.
- Add at least one new high-level test:
  - "Guest can browse nearby dishes and view dish details without bottom navigation".

#### 7.3 Manual QA Checklist
- Launch as guest:
  - Browse map, open nearby dishes, view a dish, start an order.
  - Place cash-only order, open Active Orders, open chat for that order.
  - Access profile via header icon (if/when allowed by auth rules).
- Launch as authenticated user:
  - Same flows as above, plus profile editing.

---

## 5. Risks & Mitigations

- **Risk**: Removing bottom nav breaks existing navigation flows.
  - **Mitigation**: Implement behind feature flag or branch; run full regression tests.
- **Risk**: Users lose quick access to chat.
  - **Mitigation**: Ensure order-related chat entry is prominent in Active Orders.
- **Risk**: Complex coupling between map and feed screens.
  - **Mitigation**: Keep `MapFeedBloc` single-source-of-truth and avoid duplicating fetching logic.

---

## 6. Task Checklist (Engineering)

- [x] **Phase 1 COMPLETE**: Create specification documentation and safety measures.
- [x] **Phase 2 COMPLETE**: Refactor `NavigationTab` and `NavigationBloc` to remove feed/chat tabs.
- [x] **Phase 2 COMPLETE**: Remove `GlassBottomNavigation` and bottomNavigationBar usage in `PersistentNavigationShell`.
- [x] **Phase 2 COMPLETE**: Simplify `AppRouter` shell children and routes (no `/feed` or `/chat` tab routes).
- [x] **Phase 3 COMPLETE**: Implemented dual-surface model (Map with sheet + FeedScreen list).
- [x] **Phase 6 COMPLETE**: Remove bottom-nav padding from screens (order_details_widget.dart adjusted).
- [x] **Phase 4 COMPLETE**: Restrict chat access to Active Orders and order-specific flows.
- [x] **Phase 5 COMPLETE**: Add profile icon/button near search/app bar and wire to profile route.
- [x] **Phase 6 COMPLETE**: Verify FAB safe area padding (adequate 16px margin confirmed).
- [x] **Phase 6 COMPLETE**: Confirm glass aesthetic alignment across all screens.
- [x] **Phase 7 COMPLETE**: Update unit and widget tests for new navigation model (6 test files created).
- [x] **Phase 7 COMPLETE**: Update integration tests to remove bottom nav interactions (navigation_without_bottom_nav_test.dart).
- [x] **Phase 7 COMPLETE**: Create comprehensive manual QA checklist (100+ checkpoints).

---

## Phase Completion Status

- **Phase 1**: Specification & Safety - ✅ **COMPLETE** (2025-11-23)
- **Phase 2**: Core Navigation Model Refactor - ✅ **COMPLETE** (2025-11-23)
- **Phase 3**: Nearby Dishes as Primary Discovery - ✅ **COMPLETE** (2025-11-23)
- **Phase 4**: Chat Access via Active Orders Only - ✅ **COMPLETE** (2025-11-23)
- **Phase 5**: Profile Entry near Search Bar - ✅ **COMPLETE** (2025-11-23)
- **Phase 6**: UI Polish & Theming - ✅ **COMPLETE** (2025-11-23)
- **Phase 7**: Testing & Validation - ✅ **COMPLETE** (2025-11-23)

---

## 🎉 PROJECT STATUS: 100% COMPLETE

**All 7 phases successfully completed and production-ready!**

See `NAVIGATION_REDESIGN_FINAL_COMPLETION.md` for comprehensive completion report.
