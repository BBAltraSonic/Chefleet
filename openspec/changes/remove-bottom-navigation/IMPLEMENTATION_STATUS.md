# Implementation Status - Remove Bottom Navigation

**Last Updated**: 2025-11-23  
**Current Phase**: Phase 3 Complete ✅  
**Next Phase**: Phase 4 (Chat Access via Active Orders Only)

---

## Quick Status

| Phase | Status | Progress |
|-------|--------|----------|
| Phase 1: Specification & Safety | ✅ Complete | 7/7 tasks |
| Phase 2: Core Navigation Model | ✅ Complete | 4/4 tasks |
| Phase 3: Nearby Dishes Surface | ✅ Complete | 3/3 tasks |
| Phase 4: Chat Access | ⏳ Pending | 0/2 tasks |
| Phase 5: Profile Entry | 🟡 Partial | 1/2 tasks |
| Phase 6: UI Polish | ⏳ Pending | 0/4 tasks |
| Phase 7: Testing | ⏳ Pending | 0/4 tasks |

---

## What's Working Now

✅ **Navigation Model Simplified**
- Only 2 tabs: Map (index 0) and Profile (index 1)
- NavigationTab.feed, NavigationTab.chat, NavigationTab.orders removed
- NavigationBloc still tracks active order count and unread chat count

✅ **Bottom Navigation Removed**
- GlassBottomNavigation widget completely deleted
- Scaffold no longer renders bottomNavigationBar
- More vertical screen space available

✅ **Routing Simplified**
- ShellRoute only manages Map and Profile screens
- /feed, /orders, /chat routes removed
- /chat/detail/:orderId retained for order-specific chat
- NEW: /nearby route added for FeedScreen

✅ **FAB Repositioned**
- OrdersFloatingActionButton moved from centerDocked to endFloat
- Still opens Active Orders modal on tap
- Animation and styling preserved

✅ **Stale References Fixed**
- order_confirmation_screen.dart navigates to map instead of feed
- favourites_screen.dart navigates to map instead of feed
- profile_drawer.dart "Order History" temporarily disabled

✅ **Map ↔ List Navigation (Phase 3)**
- MapScreen has List View button (green) in search bar
- FeedScreen has Map View button in app bar
- Seamless toggle between map and list views
- Both show consistent "Nearby Dishes" data

✅ **Profile Access (Phase 5 - Partial)**
- Profile icon in MapScreen search bar
- Profile icon in FeedScreen app bar
- Accessible from both primary discovery surfaces

---

## What Needs Work

⚠️ **Chat Access Patterns** (Phase 4)
- Need to audit chat entry points
- Ensure chat only accessible via order context
- Remove any remaining global chat navigation

⚠️ **Order History** (Future)
- Menu item in profile drawer commented out
- Need to decide access pattern for past orders
- Active orders work via FAB

⚠️ **Bloc State Optimization** (Future)
- MapFeedBloc created separately in Map and Feed screens
- Not shared between screens (causes re-fetch on navigation)
- Consider promoting bloc to shell level for shared state

⚠️ **Testing** (Phase 7)
- Integration tests reference removed tabs
- Manual testing not yet completed
- No automated validation of new flow

---

## Breaking Changes Summary

**Removed Constants:**
```dart
NavigationTab.feed    // Use NavigationTab.map instead
NavigationTab.chat    // Chat only via order context
NavigationTab.orders  // Orders only via FAB modal
```

**Removed Routes:**
```dart
AppRouter.feedRoute    // Use AppRouter.mapRoute
AppRouter.ordersRoute  // Use FAB instead
AppRouter.chatRoute    // Use AppRouter.chatDetailRoute with orderId
```

**Removed Widget:**
```dart
GlassBottomNavigation  // Entire widget deleted
```

---

## Files Changed

### Phase 1: OpenSpec Documentation
- `openspec/changes/remove-bottom-navigation/proposal.md` - Created
- `openspec/changes/remove-bottom-navigation/tasks.md` - Created
- `openspec/changes/remove-bottom-navigation/specs/navigation/spec.md` - Created
- `openspec/changes/remove-bottom-navigation/specs/feed/spec.md` - Created
- `openspec/changes/remove-bottom-navigation/IMPLEMENTATION_STATUS.md` - Created

### Phase 2: Core Navigation (Phase 2)
- `lib/core/blocs/navigation_bloc.dart` - 35 lines changed
- `lib/shared/widgets/persistent_navigation_shell.dart` - 107 lines removed
- `lib/core/router/app_router.dart` - 40 lines changed
- `lib/features/order/screens/order_confirmation_screen.dart` - 1 line changed
- `lib/features/profile/screens/favourites_screen.dart` - 2 lines changed
- `lib/features/profile/widgets/profile_drawer.dart` - 10 lines commented

### Phase 3: Discovery Surface
- `lib/features/feed/screens/feed_screen.dart` - 15 lines changed
- `lib/features/map/screens/map_screen.dart` - 42 lines added
- `lib/core/router/app_router.dart` - 8 lines added
- `openspec/changes/remove-bottom-navigation/proposal.md` - Updated
- `NAVIGATION_REDESIGN_PHASE3_COMPLETION.md` - Created

**Total Impact**: ~270 lines changed/removed/added across 3 phases

---

## How to Continue

### For Next Session (Phase 4):

1. **Read this status document** to understand current state
2. **Review tasks.md** Phase 4 section
3. **Audit chat entry points** in chat_screen.dart and chat_detail_screen.dart
4. **Verify chat access** from Active Orders modal
5. **Remove any global chat navigation** that remains

### For Testing (Phase 7):

1. Run `flutter test` after Phase 3-6 complete
2. Update integration_test files to remove bottom nav interactions
3. Manual QA with guest and authenticated users
4. Verify no regressions in order/chat/profile flows

---

## Commands Reference

```bash
# Validate OpenSpec change
openspec validate remove-bottom-navigation --strict

# View spec details
openspec show remove-bottom-navigation

# Search for stale references
rg -n "NavigationTab.feed|NavigationTab.chat|feedRoute|ordersRoute" lib/

# Run tests
flutter test
flutter analyze

# After completion, archive change
openspec archive remove-bottom-navigation --yes
```

---

**Status**: Phase 3 complete. Ready for Phase 4 implementation (Chat Access via Active Orders).
