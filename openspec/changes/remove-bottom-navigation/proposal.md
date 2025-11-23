# Change: Remove Bottom Navigation & Simplify Navigation Model

## Why

The current bottom navigation with 5 tabs (Map, Feed, Orders, Chat, Profile) creates unnecessary complexity and navigation friction. Users primarily need to discover nearby dishes and manage orders. By removing the bottom navigation and centering on "Nearby Dishes" as the primary discovery surface, we simplify the UX and reduce cognitive load while maintaining all essential functionality through contextual access patterns.

## What Changes

- **BREAKING**: Remove global bottom navigation bar from consumer app shell
- **BREAKING**: Remove Feed tab as a dedicated navigation destination  
- **BREAKING**: Remove Chat tab as a dedicated navigation destination
- Retain "Nearby Dishes" functionality as the primary discovery surface
- Keep Active Orders access via FAB (floating action button)
- Restrict Chat access to order-specific contexts (Active Orders modal, Order Detail screens)
- Add Profile access via app bar icon/button near search bar
- Simplify navigation model from 5 tabs to single primary surface + contextual navigation

## Impact

### Affected Capabilities
- **navigation**: Remove bottom nav, simplify tab model
- **discovery/feed**: Transform from tab to primary surface
- **chat**: Remove global tab, keep order-specific access
- **profile**: Change from tab to app bar access

### Affected Code
- `lib/core/blocs/navigation_bloc.dart` - Remove feed/chat tabs from NavigationTab model
- `lib/shared/widgets/persistent_navigation_shell.dart` - Remove GlassBottomNavigation, simplify scaffold
- `lib/core/router/app_router.dart` - Remove /feed and /chat as shell tab routes
- `lib/features/feed/screens/feed_screen.dart` - Remove bottom nav padding, adjust routing
- `lib/features/map/screens/map_screen.dart` - May need profile icon in app bar
- `lib/features/chat/screens/chat_screen.dart` - Restrict access patterns
- `lib/shared/widgets/glass_bottom_navigation.dart` - May be deprecated/removed

### User Impact
- **Positive**: Cleaner UI, reduced navigation complexity, more screen real estate
- **Neutral**: Chat access pattern changes from global tab to contextual access
- **Migration**: No data migration needed, purely UI/navigation changes

## Timeline

- Phase 1 (Spec & Safety): Create OpenSpec structure and validate - ✅ Complete
- Phase 2 (Core Refactor): Navigation model and routing changes - ✅ Complete
- Phase 3 (Discovery Surface): Nearby Dishes as primary surface - ✅ Complete
- Phase 4-7 (Feature Work): Chat patterns, profile access, polish, testing - ⏳ Pending

Estimated: 2-3 development sessions for Phase 1-2, 4-5 total sessions for complete implementation.

### Phase 3 Decision (Implemented)

**Screen Ownership Decision**: Standalone FeedScreen (Option 1)

**Rationale:**
- MapScreen already has draggable bottom sheet with dish preview
- FeedScreen provides dedicated full-screen list browsing experience
- Clean separation: map for spatial exploration, list for detailed browsing
- Users can toggle between views via prominent navigation buttons
- Both screens share MapFeedBloc for consistent data

**Implementation:**
- FeedScreen: Removed bottom nav padding, added Map View + Profile buttons
- MapScreen: Added List View button (green) + Profile button in search bar
- AppRouter: Added /nearby route accessible to guests
- Navigation: Seamless map ↔ list toggle with back stack support

## Success Criteria

- [ ] Bottom navigation completely removed from app shell
- [ ] Navigation model simplified to primary surface + contextual access
- [ ] All existing functionality (orders, chat, profile) remains accessible
- [ ] No regressions in order creation, chat, or profile flows
- [ ] Integration tests updated and passing
- [ ] Manual QA completed for guest and authenticated user flows
