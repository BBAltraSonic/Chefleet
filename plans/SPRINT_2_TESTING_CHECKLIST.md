# Sprint 2: Navigation Testing Checklist

**Date**: 2025-11-22  
**Sprint**: Navigation Unification  
**Status**: Ready for Testing

---

## Test Environment Setup

- [ ] App built successfully
- [ ] No compilation errors
- [ ] `.env` file configured
- [ ] Test device/emulator ready

---

## Main Navigation Flows

### Tab Navigation
- [ ] **Map Tab**: Tap map icon → Map screen displays
- [ ] **Feed Tab**: Tap feed icon → Feed screen displays
- [ ] **Orders Tab**: Tap orders icon → Orders screen displays
- [ ] **Chat Tab**: Tap chat icon → Chat screen displays
- [ ] **Profile Tab**: Tap profile icon → Profile screen displays
- [ ] **Tab Indicator**: Selected tab is highlighted
- [ ] **State Preservation**: Switch tabs → Previous tab state preserved
- [ ] **Badge Display**: Order/chat badges show correct counts

### Authentication Flow
- [ ] **Splash Screen**: App opens → Splash screen shows
- [ ] **Unauthenticated**: No auth → Redirects to auth screen
- [ ] **Guest Mode**: Guest login → Access to allowed screens
- [ ] **Guest Restrictions**: Guest tries restricted feature → Redirects to auth
- [ ] **Authenticated**: Login → Redirects to map
- [ ] **Profile Incomplete**: No profile → Redirects to profile creation

### Detail Screen Navigation
- [ ] **Dish Detail**: Tap dish → Dish detail screen opens
- [ ] **Dish Detail Back**: Back button → Returns to previous screen
- [ ] **Chat Detail**: Tap order → Chat detail opens
- [ ] **Chat Detail Back**: Back button → Returns to orders
- [ ] **Vendor Order**: Tap vendor order → Order detail opens

### Settings & Profile
- [ ] **Settings**: Tap settings → Settings screen opens
- [ ] **Notifications**: Tap notifications → Notifications screen opens
- [ ] **Favourites**: Tap favourites → Favourites screen opens
- [ ] **Profile Edit**: Tap edit profile → Profile creation screen opens

### Vendor Navigation
- [ ] **Vendor Dashboard**: Navigate to `/vendor` → Dashboard displays
- [ ] **Add Dish**: Tap add dish → Dish edit screen opens
- [ ] **Edit Dish**: Tap edit dish → Dish edit screen with data
- [ ] **Order Detail**: Tap vendor order → Order detail opens
- [ ] **Availability**: Navigate to availability → Availability screen opens

---

## Navigation Behavior

### Back Button
- [ ] **Detail Screen**: Back button closes detail screen
- [ ] **Tab Screen**: Back button exits app (or shows exit dialog)
- [ ] **Dialog**: Back button closes dialog
- [ ] **Bottom Sheet**: Back button closes bottom sheet
- [ ] **Drawer**: Back button closes drawer

### Deep Linking (Manual Test)
- [ ] **Dish Link**: `chefleet://dish/123` → Opens dish detail
- [ ] **Chat Link**: `chefleet://chat/detail/456` → Opens chat detail
- [ ] **Vendor Link**: `chefleet://vendor/orders/789` → Opens vendor order

**Note**: Deep link platform configuration deferred to v1.1

### Route Guards
- [ ] **Unauthenticated**: Try accessing profile → Redirects to auth
- [ ] **Guest User**: Try accessing vendor → Redirects to auth
- [ ] **No Profile**: Try restricted feature → Redirects to profile creation
- [ ] **Authenticated**: Access all features → Works correctly

---

## State Management

### NavigationBloc
- [ ] **Tab Selection**: Select tab → `currentTab` updates
- [ ] **Order Badge**: Place order → Badge count increases
- [ ] **Chat Badge**: New message → Badge count increases
- [ ] **Badge Reset**: View orders/chat → Badge count resets

### Screen State
- [ ] **Map State**: Switch tabs → Map position preserved
- [ ] **Feed Scroll**: Switch tabs → Scroll position preserved
- [ ] **Orders List**: Switch tabs → List state preserved
- [ ] **Chat List**: Switch tabs → List state preserved
- [ ] **Profile Data**: Switch tabs → Profile data preserved

---

## Error Handling

### Navigation Errors
- [ ] **Invalid Route**: Navigate to invalid route → Shows error or 404
- [ ] **Missing Parameter**: Navigate without required param → Shows error
- [ ] **Network Error**: Load screen with network error → Shows error message
- [ ] **Permission Denied**: Access restricted screen → Shows appropriate message

### Recovery
- [ ] **Retry**: Error screen retry button → Reloads screen
- [ ] **Back Navigation**: Error screen back button → Returns to previous screen
- [ ] **Fallback**: Critical error → Falls back to safe screen (map/auth)

---

## Performance

### Navigation Speed
- [ ] **Tab Switch**: < 100ms response time
- [ ] **Screen Push**: < 300ms transition
- [ ] **Screen Pop**: < 200ms transition
- [ ] **Deep Link**: < 500ms to target screen

### Memory
- [ ] **Tab Switching**: No memory leaks
- [ ] **Screen Stack**: Deep stack doesn't cause issues
- [ ] **State Preservation**: Doesn't consume excessive memory

---

## Edge Cases

### Rapid Navigation
- [ ] **Fast Tab Switching**: Rapid tab switches → No crashes
- [ ] **Fast Back Button**: Rapid back presses → Handles gracefully
- [ ] **Simultaneous Navigation**: Multiple nav requests → Handles correctly

### Lifecycle
- [ ] **Background**: App to background → State preserved
- [ ] **Foreground**: App to foreground → Resumes correctly
- [ ] **Process Death**: Kill app → Restarts at appropriate screen
- [ ] **Deep Link While Running**: Deep link while app running → Navigates correctly

### Special Cases
- [ ] **Empty States**: Navigate to empty list → Shows empty state
- [ ] **Loading States**: Navigate while loading → Shows loading indicator
- [ ] **Offline**: Navigate while offline → Shows offline message
- [ ] **Slow Network**: Navigate with slow network → Shows loading, then content

---

## Accessibility

### Screen Reader
- [ ] **Tab Labels**: Screen reader announces tab names
- [ ] **Navigation**: Screen reader announces screen changes
- [ ] **Back Button**: Screen reader announces "Go back"
- [ ] **Focus**: Focus moves logically through navigation

### Keyboard Navigation
- [ ] **Tab Key**: Tab key navigates through elements
- [ ] **Enter Key**: Enter key activates navigation items
- [ ] **Arrow Keys**: Arrow keys navigate bottom nav (if applicable)

---

## Platform-Specific

### Android
- [ ] **System Back**: System back button works correctly
- [ ] **Recent Apps**: App in recent apps shows correct screen
- [ ] **Deep Links**: Android intent deep links work
- [ ] **Notifications**: Notification tap navigates correctly

### iOS (Future)
- [ ] **Swipe Back**: Swipe gesture goes back
- [ ] **Universal Links**: Universal links work
- [ ] **Notifications**: Notification tap navigates correctly

---

## Regression Tests

### Previously Working Features
- [ ] **Order Flow**: Complete order flow works
- [ ] **Chat Flow**: Send/receive messages works
- [ ] **Profile Update**: Update profile works
- [ ] **Vendor Dashboard**: All vendor features work
- [ ] **Search**: Search functionality works
- [ ] **Filters**: Filter functionality works

---

## Test Results

### Summary
- **Total Tests**: ___
- **Passed**: ___
- **Failed**: ___
- **Blocked**: ___
- **Skipped**: ___

### Critical Issues
_List any critical issues found during testing_

1. 
2. 
3. 

### Non-Critical Issues
_List any non-critical issues found during testing_

1. 
2. 
3. 

### Notes
_Any additional notes or observations_

---

## Sign-Off

- [ ] **Developer**: All tests passed
- [ ] **QA**: Testing complete
- [ ] **Product**: Approved for release

**Tested By**: _______________  
**Date**: _______________  
**Signature**: _______________

---

**Testing Status**: ⏳ Pending  
**Next Steps**: Complete testing checklist before marking Sprint 2 complete
