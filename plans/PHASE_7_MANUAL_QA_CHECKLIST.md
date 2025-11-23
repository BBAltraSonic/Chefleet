# Phase 7: Manual QA Checklist - Navigation Without Bottom Nav
**Date**: 2025-11-23  
**Tester**: _________________  
**Build Version**: _________________  
**Device**: _________________  

---

## Pre-Test Setup

- [ ] App installed on test device
- [ ] Test environment configured (dev/staging)
- [ ] Test data available (dishes, vendors)
- [ ] Network connectivity verified

---

## Section 1: Visual Verification - No Bottom Navigation

### 1.1 Bottom Navigation Removal
- [ ] **CRITICAL**: No bottom navigation bar visible on any screen
- [ ] **CRITICAL**: No Material 3 NavigationBar visible on any screen
- [ ] FAB (Orders button) visible and properly positioned bottom-right
- [ ] FAB has 16px margin from screen edges
- [ ] FAB animates with subtle pulse effect

**Notes:**
```
_____________________________________________________________
```

---

## Section 2: Guest User Flows

### 2.1 Initial App Launch (Guest)
- [ ] App launches to map or nearby dishes screen
- [ ] No errors during splash/initialization
- [ ] Location permission prompt appears (if first launch)
- [ ] Content loads within 3 seconds

**Landing Screen**: □ Map □ Nearby Dishes

**Notes:**
```
_____________________________________________________________
```

### 2.2 Map & Feed Navigation
- [ ] Can switch between map and nearby dishes list
- [ ] Map view shows vendor markers
- [ ] List view shows "Nearby Dishes" title
- [ ] List view has map icon to return to map
- [ ] Profile icon visible in header/app bar on both views

**Notes:**
```
_____________________________________________________________
```

### 2.3 Browsing Dishes (List View)
- [ ] Dishes load and display in list
- [ ] Can scroll through dishes smoothly
- [ ] Pull-to-refresh works (triggers reload)
- [ ] Infinite scroll loads more dishes
- [ ] Each dish card shows: image, name, price, vendor, distance
- [ ] No excessive bottom padding (content not clipped)

**Notes:**
```
_____________________________________________________________
```

### 2.4 Map Interaction
- [ ] Can pan and zoom map
- [ ] Vendor markers clickable
- [ ] Tapping marker shows vendor mini card
- [ ] Mini card shows vendor info and dish count
- [ ] Draggable sheet visible at bottom
- [ ] Sheet has "Nearby Dishes" title
- [ ] Can drag sheet between snap points (15%, 40%, 90%)
- [ ] Drag handle visible and responsive

**Notes:**
```
_____________________________________________________________
```

### 2.5 Dish Detail View
- [ ] Tap dish card opens dish detail
- [ ] Detail shows all dish information
- [ ] Can add dish to cart
- [ ] Can navigate back to feed/map
- [ ] FAB remains visible throughout

**Notes:**
```
_____________________________________________________________
```

### 2.6 Profile Access (Guest)
- [ ] Profile icon visible in app bar (person_outline)
- [ ] Tap profile icon navigates to profile screen
- [ ] Guest prompt or profile screen displays
- [ ] Can navigate back to feed/map

**Notes:**
```
_____________________________________________________________
```

---

## Section 3: Order Flow

### 3.1 Placing an Order (Cash-Only)
- [ ] Add dish to cart from dish detail
- [ ] Proceed to checkout
- [ ] Select cash payment method
- [ ] Complete order successfully
- [ ] Order confirmation screen displays
- [ ] Order confirmation shows pickup code

**Notes:**
```
_____________________________________________________________
```

### 3.2 Active Orders via FAB
- [ ] FAB opens Active Orders modal
- [ ] Modal animates in smoothly
- [ ] Modal shows list of active orders
- [ ] Each order card shows: vendor, items, status, total
- [ ] Modal dismisses via tap outside or drag down
- [ ] Can open modal multiple times without issues

**Active Order Count**: _____

**Notes:**
```
_____________________________________________________________
```

### 3.3 Order Details & Actions
- [ ] Order card shows vendor logo/name
- [ ] Order card shows pickup code
- [ ] Order card shows estimated time
- [ ] Order card shows total amount
- [ ] "Track Order" button visible
- [ ] "Chat" button visible and accessible

**Notes:**
```
_____________________________________________________________
```

### 3.4 Chat Access from Active Orders
- [ ] **CRITICAL**: Can open chat from order card
- [ ] Chat opens in new screen/modal
- [ ] Chat shows order context (order ID, status)
- [ ] Can send messages
- [ ] Can close chat and return to Active Orders
- [ ] **VERIFY**: No global chat tab exists

**Notes:**
```
_____________________________________________________________
```

---

## Section 4: Authenticated User Flows

### 4.1 Login/Registration
- [ ] Can access sign-up from profile
- [ ] Can complete registration
- [ ] Can log in successfully
- [ ] Profile populated after auth

**Notes:**
```
_____________________________________________________________
```

### 4.2 Profile Management (Authenticated)
- [ ] Profile screen shows user info
- [ ] Can edit profile fields
- [ ] Can view order history
- [ ] Can view favorites
- [ ] Can access settings

**Notes:**
```
_____________________________________________________________
```

### 4.3 Repeat Guest Flows as Authenticated User
- [ ] Browse nearby dishes ✓
- [ ] View dish details ✓
- [ ] Place order ✓
- [ ] Access Active Orders ✓
- [ ] Open chat from order ✓

**Notes:**
```
_____________________________________________________________
```

---

## Section 5: Navigation Regression Tests

### 5.1 No Bottom Nav References
- [ ] **CRITICAL**: No "Feed" tab label anywhere
- [ ] **CRITICAL**: No "Chat" tab label in navigation context
- [ ] No UI elements reference removed tabs
- [ ] No broken navigation flows

**Notes:**
```
_____________________________________________________________
```

### 5.2 Screen Transitions
- [ ] Map → List transition smooth
- [ ] List → Map transition smooth
- [ ] Profile → Feed/Map transition smooth
- [ ] FAB remains accessible during all transitions
- [ ] No navigation errors or crashes

**Notes:**
```
_____________________________________________________________
```

### 5.3 Spacing & Layout
- [ ] No 100px bottom spacing anywhere
- [ ] Content extends to bottom with safe area
- [ ] No clipped content at screen bottom
- [ ] FAB doesn't overlap important content
- [ ] Draggable sheet doesn't interfere with FAB

**Notes:**
```
_____________________________________________________________
```

---

## Section 6: Glass Aesthetic Verification

### 6.1 Glass Container Usage
- [ ] Search bar uses glass container (frosted effect)
- [ ] Glass has appropriate blur and opacity
- [ ] Glass containers visible throughout app
- [ ] Glass borders subtle and consistent
- [ ] Glass effect works in light and dark modes

**Notes:**
```
_____________________________________________________________
```

---

## Section 7: Accessibility Tests

### 7.1 Touch Targets
- [ ] FAB touch target ≥ 48x48 (actual: 64x64)
- [ ] Profile icon touch target adequate
- [ ] Map/List toggle touch target adequate
- [ ] All buttons have adequate spacing

**Notes:**
```
_____________________________________________________________
```

### 7.2 Screen Reader Support
- [ ] FAB has "Active Orders" label/tooltip
- [ ] Profile icon has "Profile" label/tooltip
- [ ] Map icon has "Map View" label/tooltip
- [ ] Filter icon has "Filter" label/tooltip
- [ ] All interactive elements have labels

**Screen Reader Tested**: □ Yes □ No

**Notes:**
```
_____________________________________________________________
```

---

## Section 8: Performance & Stability

### 8.1 Performance
- [ ] App launches in < 3 seconds
- [ ] Screen transitions < 500ms
- [ ] Scrolling smooth (60fps)
- [ ] No jank during animations
- [ ] FAB animation smooth

**Notes:**
```
_____________________________________________________________
```

### 8.2 Memory & Stability
- [ ] No memory leaks after 10 navigation cycles
- [ ] No crashes during 30-minute session
- [ ] FAB tap responsive every time
- [ ] Modal open/close reliable

**Notes:**
```
_____________________________________________________________
```

---

## Section 9: Edge Cases

### 9.1 Network Conditions
- [ ] Works on WiFi
- [ ] Works on cellular
- [ ] Handles network loss gracefully
- [ ] Offline indicator shows when appropriate

**Notes:**
```
_____________________________________________________________
```

### 9.2 Empty States
- [ ] Empty dishes list shows proper message
- [ ] No active orders shows proper empty state
- [ ] Empty chat shows proper placeholder

**Notes:**
```
_____________________________________________________________
```

### 9.3 Error Handling
- [ ] API errors display user-friendly messages
- [ ] Failed order shows retry option
- [ ] Navigation errors recover gracefully

**Notes:**
```
_____________________________________________________________
```

---

## Section 10: Device Compatibility

### 10.1 Screen Sizes
Test on multiple devices:

**Device 1** (Small Phone - ~360x640):
- [ ] All elements visible
- [ ] No layout overflow
- [ ] FAB properly positioned
- [ ] _Device: ______________

**Device 2** (Medium Phone - ~375x812):
- [ ] All elements visible
- [ ] No layout overflow
- [ ] FAB properly positioned
- [ ] _Device: ______________

**Device 3** (Large Phone - ~414x896):
- [ ] All elements visible
- [ ] No layout overflow
- [ ] FAB properly positioned
- [ ] _Device: ______________

**Device 4** (Tablet - if applicable):
- [ ] Layout adapts appropriately
- [ ] No excessive whitespace
- [ ] FAB positioning reasonable
- [ ] _Device: ______________

### 10.2 Orientations
- [ ] Portrait mode works correctly
- [ ] Landscape mode works correctly (if supported)
- [ ] Orientation changes don't break navigation

**Notes:**
```
_____________________________________________________________
```

---

## Test Summary

**Total Issues Found**: _____

**Critical Issues** (blocking): _____
```
_____________________________________________________________
```

**Major Issues** (non-blocking): _____
```
_____________________________________________________________
```

**Minor Issues** (cosmetic): _____
```
_____________________________________________________________
```

**Overall Result**: □ PASS □ FAIL □ CONDITIONAL PASS

**Tester Signature**: _________________ **Date**: _______

**Additional Comments**:
```
_____________________________________________________________
_____________________________________________________________
_____________________________________________________________
```

---

## Test Completion Checklist

- [ ] All sections completed
- [ ] All critical items verified
- [ ] Issues logged in tracking system
- [ ] Screenshots captured for issues
- [ ] Test results documented
- [ ] Stakeholders notified

---

**End of Manual QA Checklist**
