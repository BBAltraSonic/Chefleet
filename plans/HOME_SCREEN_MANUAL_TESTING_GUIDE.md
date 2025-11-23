# Home Screen Redesign - Manual Testing Guide
**Version**: 1.0  
**Date**: November 23, 2025  
**Phases Covered**: Phase 1-4 Implementation

---

## 🎯 Testing Overview

This guide provides comprehensive manual testing procedures for the Home Screen Redesign (Savor AI Style). Follow each section systematically to ensure all features work correctly.

---

## 📱 Test Environment Setup

### Prerequisites
- ✅ Flutter app running on device or emulator
- ✅ Test user account (both guest and authenticated)
- ✅ Network connection for live data
- ✅ Multiple screen sizes available (phone, tablet, desktop)

### Test Data Requirements
- Vendors with active dishes
- Dishes with various categories/tags (Sushi, Burger, Pizza, Healthy, Dessert)
- Sample images for dish cards
- User profile with avatar (optional)

---

## 🧪 Test Cases

### TC-001: PersonalizedHeader Display
**Objective**: Verify personalized header shows correct information

**Steps**:
1. Launch the app and navigate to home screen
2. Observe the header section at top of bottom sheet

**Expected Results**:
- ✅ User avatar/icon is displayed (48px circular)
- ✅ Green online indicator dot visible at bottom-right of avatar
- ✅ Greeting text shows time-appropriate message:
  - "Good Morning" (12 AM - 11:59 AM)
  - "Good Afternoon" (12 PM - 4:59 PM)
  - "Good Evening" (5 PM - 11:59 PM)
- ✅ User's first name displayed after greeting (or "Guest" if not authenticated)
- ✅ Subtitle "Ready to discover your next favorite meal?" displayed
- ✅ Text is readable and properly aligned
- ✅ Proper padding (20px all around)

**Pass Criteria**: All elements visible and correctly formatted

---

### TC-002: CategoryFilterBar Functionality
**Objective**: Verify category filter chips work correctly

**Steps**:
1. Locate the horizontal category filter bar below the header
2. Verify all categories are visible
3. Tap "All" category
4. Tap "Sushi" category
5. Tap other categories in sequence

**Expected Results**:
- ✅ All categories displayed: All, Sushi, Burger, Pizza, Healthy, Dessert
- ✅ Categories scroll horizontally
- ✅ Selected category has dark background (grey-900)
- ✅ Selected category has white text
- ✅ Unselected categories have white background with grey border
- ✅ Unselected categories have grey text
- ✅ Smooth animation (300ms) when switching categories
- ✅ Proper spacing (12px) between chips
- ✅ Each chip has rounded corners (12px radius)

**Pass Criteria**: All visual states correct and animations smooth

---

### TC-003: Category Filtering Logic
**Objective**: Verify dishes filter correctly by category

**Test Data Required**: 
- At least 2 dishes with "Sushi" tag
- At least 1 dish with "Burger" tag
- At least 1 dish with "Pizza" tag
- Mixed dishes for "All" category

**Steps**:
1. Start with "All" category selected
2. Count visible dishes
3. Tap "Sushi" category
4. Count visible dishes
5. Verify only sushi dishes are shown
6. Repeat for other categories
7. Return to "All" category

**Expected Results**:
- ✅ "All" category shows all available dishes
- ✅ "Sushi" category shows only dishes with sushi-related tags
- ✅ "Burger" category shows only burger dishes
- ✅ "Pizza" category shows only pizza dishes
- ✅ "Healthy" category shows only healthy/salad dishes
- ✅ "Dessert" category shows only dessert dishes
- ✅ Empty state shown if no dishes match category
- ✅ Filtering is instant (no loading delay)
- ✅ Grid layout maintains structure after filtering

**Pass Criteria**: Correct dishes displayed for each category

---

### TC-004: Dish Grid Layout - Mobile
**Objective**: Verify responsive grid on mobile screens

**Device**: Phone (< 600px width)

**Steps**:
1. Open app on mobile device or resize to mobile width
2. Scroll through dish grid
3. Observe layout and spacing

**Expected Results**:
- ✅ Grid displays 2 columns
- ✅ Cards have equal width
- ✅ 16px spacing between cards (horizontal and vertical)
- ✅ 20px padding on left and right edges
- ✅ Card aspect ratio is 0.75 (height = 1.33 * width)
- ✅ All cards visible without horizontal scrolling
- ✅ Smooth scrolling

**Pass Criteria**: 2-column grid with proper spacing

---

### TC-005: Dish Grid Layout - Tablet
**Objective**: Verify responsive grid on tablet screens

**Device**: Tablet (600-900px width)

**Steps**:
1. Open app on tablet or resize to tablet width
2. Observe grid layout

**Expected Results**:
- ✅ Grid displays 3 columns
- ✅ Maintains spacing and aspect ratio
- ✅ Utilizes available screen space efficiently

**Pass Criteria**: 3-column grid displays correctly

---

### TC-006: Dish Grid Layout - Desktop
**Objective**: Verify responsive grid on desktop screens

**Device**: Desktop (> 900px width)

**Steps**:
1. Open app in desktop browser or large window
2. Observe grid layout

**Expected Results**:
- ✅ Grid displays 4 columns
- ✅ Maintains spacing and aspect ratio
- ✅ Proper use of wide screen space

**Pass Criteria**: 4-column grid displays correctly

---

### TC-007: DishCard Content
**Objective**: Verify dish card displays all information correctly

**Steps**:
1. Locate any dish card in the grid
2. Examine all visible elements

**Expected Results**:
- ✅ Dish image fills top 60% of card (covers full width)
- ✅ Image has rounded top corners (16px radius)
- ✅ Restaurant name badge overlays bottom-left of image
- ✅ Badge has white background (90% opacity) with 8px padding
- ✅ Badge text is 10px, bold
- ✅ Dish name displayed below image (14px, bold)
- ✅ Name truncates with ellipsis if too long (max 2 lines)
- ✅ Rating icon (star) and value displayed
- ✅ Distance icon and value displayed
- ✅ Price displayed prominently (16px, bold, green color)
- ✅ Add button (circular, green, with + icon) at bottom-right
- ✅ Card has subtle shadow (4px blur, 2px offset)
- ✅ All content properly aligned with 12px internal padding

**Pass Criteria**: All card elements visible and properly styled

---

### TC-008: Add to Cart from DishCard
**Objective**: Verify add-to-cart button works

**Steps**:
1. Locate a dish card
2. Tap the circular "+" button at bottom-right of card
3. Observe cart FAB changes

**Expected Results**:
- ✅ Add button has tap feedback
- ✅ Cart FAB expands (see TC-009)
- ✅ Item count badge updates
- ✅ Total price updates
- ✅ Can add same item multiple times

**Pass Criteria**: Item successfully added to cart

---

### TC-009: SmartCartFAB - Empty State
**Objective**: Verify cart FAB in empty state

**Steps**:
1. Ensure cart is empty (clear app data if needed)
2. Navigate to home screen
3. Locate cart FAB at bottom-right

**Expected Results**:
- ✅ FAB is compact (56px diameter circle)
- ✅ Shows shopping bag icon only
- ✅ Icon is white on dark background (grey-900)
- ✅ Has prominent shadow (30% opacity, 20px blur, 8px offset)
- ✅ Positioned 24px from bottom and right edges
- ✅ Tappable

**Pass Criteria**: Compact FAB displayed correctly

---

### TC-010: SmartCartFAB - Expanded State
**Objective**: Verify cart FAB expands with items

**Steps**:
1. Add at least one item to cart
2. Observe cart FAB changes

**Expected Results**:
- ✅ FAB expands horizontally to ~160px width
- ✅ Maintains 56px height
- ✅ Smooth expansion animation (300ms, easeInOut curve)
- ✅ Shopping bag icon with badge showing item count
- ✅ Badge is circular, green background, black text
- ✅ Badge positioned at top-right of icon
- ✅ "View Cart" text displayed (12px, white, bold)
- ✅ Total price displayed below (10px, grey-400)
- ✅ Price formatted as \$XX.XX
- ✅ All content remains readable
- ✅ Rounded corners (28px radius)

**Pass Criteria**: FAB expands smoothly with correct content

---

### TC-011: SmartCartFAB - Item Count Updates
**Objective**: Verify badge updates with cart changes

**Test Data**: Multiple dishes to add

**Steps**:
1. Add 1 item - verify badge shows "1"
2. Add another item - verify badge shows "2"
3. Add 3 more items - verify badge shows "5"
4. Continue to 10+ items

**Expected Results**:
- ✅ Badge count updates instantly
- ✅ Count is always accurate
- ✅ Badge handles double-digit numbers (99+)
- ✅ Total price updates correspondingly

**Pass Criteria**: Badge always shows correct count

---

### TC-012: SmartCartFAB - Navigation
**Objective**: Verify tapping FAB navigates to cart

**Steps**:
1. Add items to cart
2. Tap the expanded cart FAB
3. Observe navigation

**Expected Results**:
- ✅ Navigates to cart screen/sheet
- ✅ Cart shows added items
- ✅ Navigation is instant (no delay)

**Pass Criteria**: Successful navigation to cart

---

### TC-013: Bottom Sheet Drag Behavior
**Objective**: Verify bottom sheet can be dragged

**Steps**:
1. Locate drag handle at top of bottom sheet
2. Drag handle downward
3. Drag handle upward
4. Try rapid dragging motions

**Expected Results**:
- ✅ Sheet follows finger/cursor smoothly
- ✅ Snaps to 15% (minimized), 40% (default), or 90% (expanded)
- ✅ Snap animation is smooth
- ✅ Map remains interactive when sheet is minimized
- ✅ Content scrolls when sheet is expanded
- ✅ Drag handle is visible (grey-300, 40px wide, 4px tall, centered)
- ✅ Sheet never fully closes
- ✅ Sheet never overlaps status bar

**Pass Criteria**: Sheet drags smoothly and snaps correctly

---

### TC-014: Bottom Sheet Scrolling
**Objective**: Verify content scrolls within sheet

**Steps**:
1. Expand sheet to 90%
2. Try scrolling dish grid
3. Try scrolling when at top
4. Try scrolling when at bottom

**Expected Results**:
- ✅ Content scrolls smoothly within sheet
- ✅ Scroll physics feel natural (bounces on iOS, glows on Android)
- ✅ Can't scroll past top
- ✅ Can't scroll past bottom
- ✅ Dragging at top edge collapses sheet
- ✅ Scrolling doesn't interfere with category bar

**Pass Criteria**: Smooth scrolling with correct physics

---

### TC-015: Section Title and "See All" Button
**Objective**: Verify section header displays correctly

**Steps**:
1. Locate section title between category bar and dish grid
2. Observe "See All" button

**Expected Results**:
- ✅ Title text: "Recommended for you" (18px, bold)
- ✅ Title changes to "Search Results" when searching
- ✅ "SEE ALL" button on right side
- ✅ Button has green tint background (10% opacity)
- ✅ Button text is 10px, bold, green
- ✅ Tapping button navigates to full feed (/nearby route)
- ✅ Section has 16px vertical padding

**Pass Criteria**: Title and button work correctly

---

### TC-016: Loading States
**Objective**: Verify loading indicators appear correctly

**Steps**:
1. Clear app cache
2. Launch app (or trigger refresh)
3. Observe loading states

**Expected Results**:
- ✅ Loading indicator shown while fetching dishes
- ✅ Skeleton screens or progress indicator displayed
- ✅ Loading doesn't block category selection
- ✅ Smooth transition when data loads
- ✅ Loading indicator at bottom when loading more dishes

**Pass Criteria**: Loading states are clear and non-blocking

---

### TC-017: Empty States
**Objective**: Verify empty state displays correctly

**Steps**:
1. Select a category with no dishes
2. Or ensure no vendors are active

**Expected Results**:
- ✅ Empty state icon displayed (restaurant menu icon, 48px, grey-300)
- ✅ Message "No dishes found" displayed
- ✅ Text is centered and grey (600)
- ✅ No broken layouts
- ✅ Other UI elements remain functional

**Pass Criteria**: Empty state is clear and friendly

---

### TC-018: Rapid Category Switching
**Objective**: Test performance under rapid interaction

**Steps**:
1. Rapidly tap different categories in sequence
2. Tap same category multiple times
3. Switch categories while scrolling

**Expected Results**:
- ✅ No lag or stuttering
- ✅ Animations complete smoothly
- ✅ No crashes or errors
- ✅ Filtering remains accurate
- ✅ UI remains responsive
- ✅ No memory leaks (extended testing)

**Pass Criteria**: Smooth performance under stress

---

### TC-019: Authenticated vs Guest User
**Objective**: Verify different states for user types

**Steps**:
1. Test as authenticated user
2. Log out and test as guest
3. Compare experiences

**Expected Results**:

**Authenticated User**:
- ✅ Shows user's first name in greeting
- ✅ Shows user avatar if available
- ✅ All features available

**Guest User**:
- ✅ Shows "Guest" in greeting
- ✅ Shows default avatar
- ✅ All features still work
- ✅ May show guest conversion prompts

**Pass Criteria**: Both user types have good experience

---

### TC-020: Orientation Changes (Mobile)
**Objective**: Verify layout adapts to orientation

**Device**: Mobile phone

**Steps**:
1. Use app in portrait mode
2. Rotate to landscape mode
3. Rotate back to portrait

**Expected Results**:
- ✅ Layout adapts smoothly
- ✅ Grid column count adjusts appropriately
- ✅ Bottom sheet remains functional
- ✅ No content loss
- ✅ State preserved (selected category, cart items)

**Pass Criteria**: Smooth orientation transitions

---

### TC-021: Offline Behavior
**Objective**: Verify app works offline with cached data

**Steps**:
1. Use app with network connection (load data)
2. Disable network connection
3. Restart app
4. Try using features

**Expected Results**:
- ✅ Cached dishes displayed
- ✅ Category filtering still works
- ✅ Offline indicator shown
- ✅ Add to cart works (stored locally)
- ✅ Graceful error messages for features requiring network

**Pass Criteria**: Core features work offline

---

### TC-022: Search Bar Integration
**Objective**: Verify search works with new design

**Steps**:
1. Locate search bar at top of map
2. Tap search bar
3. Enter search query
4. Try searching for dish names, restaurants

**Expected Results**:
- ✅ Search bar is glass-morphic (blur: 18.0)
- ✅ Search bar always visible above map
- ✅ Tapping opens keyboard
- ✅ Results filter in bottom sheet
- ✅ Category filter still accessible
- ✅ Can combine search + category filter
- ✅ Clearing search resets to category-filtered view

**Pass Criteria**: Search integrates seamlessly

---

### TC-023: Map Interactions
**Objective**: Verify map remains fully functional

**Steps**:
1. Try panning map
2. Try zooming map
3. Tap vendor markers
4. Move map to different area

**Expected Results**:
- ✅ Map pans smoothly
- ✅ Map zooms correctly
- ✅ Markers are clickable
- ✅ Vendor mini-card displays on marker tap
- ✅ Bottom sheet updates with nearby dishes
- ✅ Map doesn't interfere with bottom sheet drag
- ✅ Bottom sheet doesn't block map unnecessarily

**Pass Criteria**: Map fully functional alongside redesign

---

### TC-024: Animation Performance
**Objective**: Verify all animations run at 60fps

**Tools Required**: Flutter DevTools (Performance tab)

**Steps**:
1. Enable performance overlay
2. Test each animation:
   - Category selection
   - Cart FAB expansion
   - Sheet dragging
   - Dish card loading
3. Monitor frame rate

**Expected Results**:
- ✅ All animations run at ~60fps
- ✅ No dropped frames during animations
- ✅ Smooth transitions throughout
- ✅ No jank or stuttering
- ✅ Build times < 16ms per frame

**Pass Criteria**: Consistent 60fps performance

---

### TC-025: Memory Management
**Objective**: Verify no memory leaks

**Tools Required**: Flutter DevTools (Memory tab)

**Steps**:
1. Monitor memory usage
2. Add/remove items from cart repeatedly
3. Switch categories repeatedly
4. Scroll through many dishes
5. Navigate away and back
6. Check memory graph

**Expected Results**:
- ✅ Memory usage stays stable
- ✅ No steady increase in memory
- ✅ Garbage collection occurs regularly
- ✅ No leaked objects accumulating
- ✅ Memory returns to baseline after actions

**Pass Criteria**: Stable memory profile

---

### TC-026: Accessibility
**Objective**: Verify accessibility features work

**Steps**:
1. Enable screen reader (TalkBack/VoiceOver)
2. Navigate through UI
3. Try all interactive elements
4. Enable large text
5. Enable high contrast

**Expected Results**:
- ✅ All elements have semantic labels
- ✅ Screen reader announces all content
- ✅ Tap targets are 48x48dp minimum
- ✅ Color contrast meets WCAG AA standards
- ✅ Text scales with system settings
- ✅ Interactive elements are keyboard accessible (web)

**Pass Criteria**: WCAG AA compliance

---

### TC-027: Error Handling
**Objective**: Verify graceful error handling

**Steps**:
1. Simulate network errors
2. Simulate server errors (500)
3. Test with malformed data
4. Test with missing images

**Expected Results**:
- ✅ User-friendly error messages
- ✅ No crashes or blank screens
- ✅ Retry options provided
- ✅ Fallback images for missing dish images
- ✅ Cached data shown when possible
- ✅ App remains usable after errors

**Pass Criteria**: Graceful degradation

---

## 📊 Test Results Template

### Test Session Information
- **Date**: _______________
- **Tester**: _______________
- **Device**: _______________
- **OS Version**: _______________
- **App Version**: _______________
- **Build Number**: _______________

### Results Summary

| Test Case | Status | Notes |
|-----------|--------|-------|
| TC-001 | ⬜ Pass / ⬜ Fail | |
| TC-002 | ⬜ Pass / ⬜ Fail | |
| TC-003 | ⬜ Pass / ⬜ Fail | |
| ... | ... | ... |

### Issues Found
1. **Issue #1**
   - Severity: Critical / High / Medium / Low
   - Description: 
   - Steps to Reproduce:
   - Expected:
   - Actual:

---

## 🎯 Sign-Off Criteria

For Phase 5 to be marked complete, the following must be achieved:

### ✅ Must Pass (Blockers)
- [ ] All category filtering works correctly (TC-003)
- [ ] Responsive grid displays on all screen sizes (TC-004, 005, 006)
- [ ] Cart FAB works correctly (TC-009, 010, 011, 012)
- [ ] No crashes or critical bugs
- [ ] Performance is acceptable (TC-024)

### ⚠️ Should Pass (High Priority)
- [ ] PersonalizedHeader displays correctly (TC-001)
- [ ] CategoryFilterBar works smoothly (TC-002)
- [ ] DishCards display all content (TC-007)
- [ ] Add to cart functions properly (TC-008)
- [ ] Bottom sheet drag behavior works (TC-013, 014)
- [ ] Empty and loading states handled (TC-016, 017)

### 💡 Nice to Have (Medium Priority)
- [ ] Orientation changes handled (TC-020)
- [ ] Offline behavior acceptable (TC-021)
- [ ] Accessibility features work (TC-026)
- [ ] No memory leaks (TC-025)

---

## 📝 Testing Tips

### Best Practices
1. **Test on Real Devices**: Emulators are useful, but test on physical devices for accurate performance assessment
2. **Test Different Network Speeds**: Use slow 3G to test loading states
3. **Clear Cache Between Tests**: Ensure fresh state for consistent results
4. **Take Screenshots**: Document issues with visual proof
5. **Test Edge Cases**: Very long names, many items, no items, etc.
6. **Test Continuously**: Don't wait until the end to test

### Common Issues to Watch For
- Text overflow on small screens
- Images not loading
- Tap targets too small
- Animations stuttering
- Memory usage growing
- State not preserving after navigation
- Category filter not resetting properly

---

## 🐛 Bug Report Template

```markdown
### Bug #___

**Title**: Clear, concise description

**Severity**: Critical / High / Medium / Low

**Device**: [Device name, OS version]

**Steps to Reproduce**:
1. 
2. 
3. 

**Expected Behavior**:
[What should happen]

**Actual Behavior**:
[What actually happens]

**Screenshots/Video**:
[Attach visual proof]

**Additional Context**:
[Any other relevant information]
```

---

## ✅ Completion Checklist

Before marking Phase 5 as complete:

- [ ] All critical test cases passed
- [ ] All high-priority test cases passed
- [ ] Bugs documented and assigned
- [ ] Performance benchmarks met
- [ ] Accessibility verified
- [ ] Test results documented
- [ ] Sign-off from stakeholders
- [ ] Ready for production release

---

**Document Version**: 1.0  
**Last Updated**: November 23, 2025  
**Next Review**: Before Production Release
