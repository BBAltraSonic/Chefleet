# Implementation Tasks

## 1. Specification & Safety (Phase 1)
- [x] 1.1 Create OpenSpec change directory structure
- [x] 1.2 Write proposal.md with rationale and impact analysis
- [x] 1.3 Create tasks.md checklist
- [x] 1.4 Create navigation capability spec deltas
- [x] 1.5 Create feed/discovery capability spec deltas  
- [x] 1.6 Run `openspec validate remove-bottom-navigation --strict`
- [x] 1.7 Fix any validation issues

## 2. Core Navigation Model Refactor (Phase 2)
- [x] 2.1 Update NavigationTab enum in `lib/core/blocs/navigation_bloc.dart`
  - [x] Remove `NavigationTab.feed` constant
  - [x] Remove `NavigationTab.chat` constant
  - [x] Update tab indices (map=0, profile=1)
  - [x] Update `NavigationTabExtension.navigationTabs` list
- [x] 2.2 Remove GlassBottomNavigation from `lib/shared/widgets/persistent_navigation_shell.dart`
  - [x] Remove `bottomNavigationBar` parameter from Scaffold
  - [x] Simplify IndexedStack children to match new tab count
  - [x] Ensure OrdersFloatingActionButton still renders correctly
  - [x] Remove GlassBottomNavigation widget entirely
  - [x] Remove unused imports (dart:ui, app_router.dart)
- [x] 2.3 Simplify AppRouter in `lib/core/router/app_router.dart`
  - [x] Remove FeedScreen from ShellRoute children list
  - [x] Remove ChatScreen from ShellRoute children list
  - [x] Remove OrdersScreen from ShellRoute children list
  - [x] Remove `/feed` route definition
  - [x] Remove global `/chat` route definition
  - [x] Remove `/orders` route definition
  - [x] Keep `/chat/detail/:orderId` for order-specific chat
  - [x] Update navigateToTab helper to match new indices
  - [x] Remove unused imports
  - [x] Update redirect logic to remove stale route references
- [x] 2.4 Full-text search for stale references
  - [x] Search for `NavigationTab.feed` usage - none found
  - [x] Search for `NavigationTab.chat` usage - none found
  - [x] Search for feedRoute references - fixed in order_confirmation_screen.dart and favourites_screen.dart
  - [x] Search for ordersRoute references - commented out in profile_drawer.dart with TODO

## 3. Nearby Dishes as Primary Discovery Surface (Phase 3)
- [x] 3.1 Decide screen ownership
  - [x] Document decision: standalone FeedScreen, accessible from MapScreen
  - [x] Rationale: MapScreen has draggable sheet, FeedScreen provides full-screen list
- [x] 3.2 Refactor FeedScreen
  - [x] Remove bottom nav padding (replaced with safe area padding)
  - [x] Add Map View button in app bar for navigation back to map
  - [x] Add Profile icon in app bar for profile access
  - [x] MapFeedBloc initialization intact
  - [x] Added explicit route /nearby
  - [x] AppRouter updated with nearbyRoute constant and route definition
- [x] 3.3 Update MapScreen integration
  - [x] Added List View button (green icon) in search bar
  - [x] Added Profile icon in search bar
  - [x] Added Filter button with InkWell for touch feedback
  - [x] All buttons navigate correctly (List → /nearby, Profile → /profile)

## 4. Chat Access via Active Orders Only (Phase 4)
- [ ] 4.1 Audit chat entry points
  - [ ] Review `lib/features/chat/screens/chat_screen.dart`
  - [ ] Review `lib/features/chat/screens/chat_detail_screen.dart`
  - [ ] Review `lib/features/order/widgets/active_order_modal.dart`
  - [ ] Remove global chat tab navigation
  - [ ] Keep order-specific chat detail access
- [ ] 4.2 Router cleanup
  - [ ] Remove generic `/chat` route if not needed
  - [ ] Keep `/chat/detail/:orderId` route

## 5. Profile Entry near Search Bar (Phase 5)
- [ ] 5.1 Identify primary app bar location
  - [ ] Check FeedScreen SliverAppBar
  - [ ] Check MapScreen app bar
- [ ] 5.2 Add profile icon/button
  - [ ] Add IconButton to app bar actions
  - [ ] Style with glass UI if applicable
  - [ ] Wire navigation to profile route
  - [ ] Add accessibility labels

## 6. UI Polish & Theming (Phase 6)
- [ ] 6.1 Remove bottom-nav-specific spacing
  - [ ] Audit screens for bottom nav padding
  - [ ] Adjust FAB safe area padding
- [ ] 6.2 Verify glass aesthetic consistency
  - [ ] Check new containers use GlassContainer
  - [ ] Verify AppTheme.glassTokens usage
- [ ] 6.3 Visual regression testing
  - [ ] Map screen
  - [ ] Nearby Dishes list
  - [ ] Orders modal
  - [ ] Profile screen

## 7. Testing & Validation (Phase 7)
- [ ] 7.1 Update unit tests
  - [ ] Navigation bloc tests
  - [ ] Router tests
  - [ ] Feed screen tests
- [ ] 7.2 Update widget tests
  - [ ] PersistentNavigationShell tests
  - [ ] Navigation flow tests
- [ ] 7.3 Update integration tests
  - [ ] Remove bottom nav tap interactions
  - [ ] Add FAB + profile icon flows
  - [ ] Add "browse nearby dishes without bottom nav" test
- [ ] 7.4 Manual QA checklist
  - [ ] Guest user: browse, order, chat via order
  - [ ] Auth user: browse, order, chat, profile
  - [ ] No widget references bottom nav
  - [ ] No stale navigation references

## 8. Documentation & Completion
- [ ] 8.1 Update user-facing docs if any exist
- [ ] 8.2 Create runtime assessment doc
- [ ] 8.3 Update CHANGELOG.md
- [ ] 8.4 Mark all tasks complete
- [ ] 8.5 Archive change: `openspec archive remove-bottom-navigation`
