# Profile Access Guide

**Last Updated**: 2025-11-23  
**Related**: Navigation Redesign Phase 5

---

## Overview

Profile access is available from both primary discovery surfaces in the Chefleet app. Users can access their profile via dedicated profile buttons positioned near search functionality.

---

## Access Points

### 1. Nearby Dishes Screen (Feed)

**Location**: Top-right corner of app bar

**Visual**: IconButton with person outline icon

**How to Access**:
1. Navigate to Nearby Dishes (list view)
2. Look at top app bar
3. Tap the profile icon (👤) on the right side

**Code Location**: `lib/features/feed/screens/feed_screen.dart` (lines 126-132)

---

### 2. Map Screen

**Location**: Inside search bar, far right

**Visual**: Glassmorphic button with person outline icon

**How to Access**:
1. Navigate to Map view
2. Look at search bar at top
3. Tap the profile button (👤) on the right side

**Code Location**: `lib/features/map/screens/map_screen.dart` (lines 190-202)

---

## User Experience

### For Guest Users

When a guest user taps the profile button:

1. **Navigates to profile screen**
2. **Sees profile creation/conversion prompt**
3. **Can create account** to save data
4. **Or continue as guest** with limited features

**Note**: Guest users have full access to the profile button but are encouraged to create an account.

---

### For Authenticated Users

When an authenticated user taps the profile button:

1. **Navigates to profile screen**
2. **Views profile information**
3. **Can edit profile**
4. **Access settings and preferences**

---

## Navigation Behavior

### Route
- Both buttons navigate to: `/profile`
- Uses `context.go('/profile')` for top-level navigation

### Back Navigation
- Users can return via:
  - Device back button
  - App bar back button (if shown)
  - Navigation gestures

### Tab Behavior
- **Does NOT** switch navigation tabs
- Uses route navigation instead
- Maintains navigation stack
- Provides natural back navigation

---

## Visual Design

### FeedScreen Button

```
┌──────────────────────────────────┐
│ Nearby Dishes    [🗺️][≡][👤]   │
└──────────────────────────────────┘
                            ↑
                      Profile Button
```

**Characteristics**:
- Standard Material IconButton
- No custom background
- Inherits app bar colors
- Tooltip: "Profile"

---

### MapScreen Button

```
┌──────────────────────────────────┐
│ [🔍] Search...  [≡][📋][👤]     │
└──────────────────────────────────┘
                         ↑
                   Profile Button
```

**Characteristics**:
- Glassmorphic container
- `surfaceGreen` background
- Rounded corners (8px)
- Matches search bar aesthetic

---

## Accessibility

### FeedScreen
- ✅ Tooltip: "Profile"
- ✅ Icon semantics
- ✅ Adequate tap target (48x48)

### MapScreen
- ✅ Visual affordance
- ✅ Adequate tap target
- ⚠️ Consider adding tooltip

---

## For Developers

### Consistent Pattern

Both implementations follow this pattern:

```dart
// FeedScreen style
IconButton(
  icon: const Icon(Icons.person_outline),
  tooltip: 'Profile',
  onPressed: () => context.go('/profile'),
)

// MapScreen style
InkWell(
  onTap: () => context.go('/profile'),
  child: Container(
    decoration: BoxDecoration(
      color: AppTheme.surfaceGreen,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.person_outline),
  ),
)
```

### Key Points
- Icon: `Icons.person_outline` (consistent)
- Navigation: `context.go('/profile')` (same route)
- Positioning: Right side of header area
- Accessibility: Tooltip or semantic label

---

## Common Questions

### Q: Why is the profile button styled differently on each screen?

**A**: Each button follows the design language of its parent screen:
- **FeedScreen**: Standard Material Design (simple, clean)
- **MapScreen**: Glassmorphic (matches search bar aesthetic)

Both are recognizable by their position and icon.

---

### Q: Can guest users access the profile?

**A**: Yes! Guest users can tap the profile button and will be shown:
- Profile creation screen
- Guest conversion prompt
- Option to create account

---

### Q: Why doesn't the profile button switch tabs?

**A**: The profile button uses route navigation instead of tab switching because:
1. Provides more natural back navigation
2. Works consistently from both screens
3. Follows standard mobile patterns
4. Doesn't interfere with current tab state

---

### Q: Can I customize the profile button?

**A**: Yes, but maintain:
- Consistent icon (`Icons.person_outline`)
- Same route (`/profile`)
- Accessible tap target
- Clear visual affordance

---

## Future Enhancements

Potential improvements:

1. **User Avatar**: Show user's avatar image (when authenticated)
2. **Notification Badge**: Show unread count or updates
3. **Quick Actions**: Long-press menu for quick profile actions
4. **Shared Widget**: Extract to reusable component

---

## Testing

### Manual Test Cases

1. **From Feed to Profile**
   - [ ] Navigate to Nearby Dishes
   - [ ] Tap profile button
   - [ ] Verify navigation to profile
   - [ ] Tap back
   - [ ] Verify return to Feed

2. **From Map to Profile**
   - [ ] Navigate to Map
   - [ ] Tap profile button in search bar
   - [ ] Verify navigation to profile
   - [ ] Tap back
   - [ ] Verify return to Map

3. **Guest User Flow**
   - [ ] Launch as guest
   - [ ] Tap profile button
   - [ ] Verify conversion prompt shown
   - [ ] Can return to previous screen

4. **Authenticated User Flow**
   - [ ] Launch as authenticated user
   - [ ] Tap profile button
   - [ ] Verify profile data shown
   - [ ] Can edit profile

---

## Related Documentation

- [NAVIGATION_PHASE_5_COMPLETION.md](../plans/NAVIGATION_PHASE_5_COMPLETION.md) - Implementation details
- [NAVIGATION_REDESIGN_2025-11-23.md](../plans/NAVIGATION_REDESIGN_2025-11-23.md) - Overall plan
- [CHAT_ACCESS_GUIDE.md](CHAT_ACCESS_GUIDE.md) - Chat access patterns

---

## Summary

Profile access is consistently available from both Map and Nearby Dishes screens via dedicated profile buttons. The buttons are positioned near search functionality, use consistent iconography, and navigate to the same profile route regardless of the entry point.
