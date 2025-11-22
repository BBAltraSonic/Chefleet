# Phase 9: UAT & Sign-off Guide

**Date:** 2025-01-21  
**Status:** 🔄 In Progress

## Overview

Phase 9 focuses on User Acceptance Testing (UAT), stakeholder validation, and final sign-off for the Chefleet mobile application. This guide provides comprehensive checklists, validation criteria, and documentation for ensuring the app meets all requirements before production release.

## UAT Objectives

1. **Visual Parity Validation** - Verify Flutter screens match HTML reference designs
2. **Functional Completeness** - Confirm all user flows work end-to-end
3. **Platform Consistency** - Document acceptable Material Design deviations
4. **Performance Validation** - Verify app meets performance benchmarks
5. **Accessibility Compliance** - Ensure WCAG AA standards are met
6. **Stakeholder Sign-off** - Obtain approval from Design, Product, and Engineering

## Stakeholder Roles

- **Design Team** - Visual parity and UX validation
- **Product Team** - Feature completeness and business requirements
- **Engineering Team** - Technical quality and performance
- **QA Team** - Test execution and bug verification
- **End Users** - Beta testing feedback (optional)

## Screen-by-Screen Validation Checklist

### Buyer Screens

#### 1. Splash Screen
**Reference:** `design/ui/layouts/splash_screen.html`  
**Flutter:** `lib/features/auth/screens/splash_screen.dart`

- [ ] Logo and branding match design
- [ ] Loading animation smooth (60fps)
- [ ] Transition to auth/map screen works
- [ ] Deep link handling functional
- [ ] No flash of unstyled content

**Acceptance Criteria:**
- Visual match: ≥95%
- Load time: <2s
- Animation: 60fps

**Notes:**
_[To be filled during UAT]_

---

#### 2. Role Selection Screen
**Reference:** `design/ui/layouts/role_selection_screen.html`  
**Flutter:** `lib/features/auth/screens/role_selection_screen.dart`

- [ ] Buyer/Vendor cards styled correctly
- [ ] Typography matches (Plus Jakarta Sans)
- [ ] Spacing and padding per design tokens
- [ ] Tap targets ≥48x48dp
- [ ] Navigation to onboarding works
- [ ] Back button behavior correct

**Acceptance Criteria:**
- Visual match: ≥95%
- Tap target compliance: 100%
- Navigation: Functional

**Notes:**
_[To be filled during UAT]_

---

#### 3. Map Screen (Buyer Home)
**Reference:** `design/ui/layouts/buyer_home_screen_-_aesthetic_enhancement.html`  
**Flutter:** `lib/features/map/screens/map_screen.dart`

- [ ] Glass UI navigation bar (blur, opacity per tokens)
- [ ] Search bar with 600ms debounce
- [ ] Vendor markers with clustering
- [ ] FAB for active orders
- [ ] Location permission handling
- [ ] Map controls (zoom, center)
- [ ] Loading states (skeleton)
- [ ] Empty state when no vendors

**Acceptance Criteria:**
- Visual match: ≥90% (Material map controls acceptable)
- Search debounce: 600ms ±50ms
- Marker clustering: >50 markers
- Frame rate: ≥55fps during pan/zoom

**Notes:**
_Material map controls differ from HTML but are platform-appropriate._

---

#### 4. Feed Screen
**Reference:** `design/ui/layouts/buyer_home_screen_-_aesthetic_enhancement.html`  
**Flutter:** `lib/features/feed/screens/feed_screen.dart`

- [ ] Dish cards styled per design
- [ ] Card spacing and radii correct
- [ ] Typography hierarchy matches
- [ ] Skeleton loading states
- [ ] Pull-to-refresh functional
- [ ] Pagination smooth
- [ ] Empty state with CTA
- [ ] Favorite icon toggle

**Acceptance Criteria:**
- Visual match: ≥95%
- Card layout: Exact match
- Scroll performance: ≥55fps
- Pagination: <500ms load time

**Notes:**
_[To be filled during UAT]_

---

#### 5. Dish Detail Screen
**Reference:** `design/ui/layouts/buyer_dish_detail_screen.html`  
**Flutter:** `lib/features/dish/screens/dish_detail_screen.dart`

- [ ] Hero image with overlay
- [ ] Dish name, tags, prep time
- [ ] Price display (uses total_amount)
- [ ] Quantity stepper functional
- [ ] Pickup time selector
- [ ] Add to order CTA prominent
- [ ] Glass container styling
- [ ] Back navigation works
- [ ] Loading/error states
- [ ] Accessibility labels present

**Acceptance Criteria:**
- Visual match: ≥95%
- Hero animation: Smooth
- Quantity stepper: Functional
- Order creation: <2s response

**Notes:**
_[To be filled during UAT]_

---

#### 6. Order Confirmation Screen
**Reference:** `design/ui/layouts/buyer_order_confirmation.html`  
**Flutter:** `lib/features/order/screens/order_confirmation_screen.dart`

- [ ] Pickup code large and prominent
- [ ] Copy/share code actions work
- [ ] Vendor name and order ID
- [ ] Status badge with correct color
- [ ] ETA indicator
- [ ] Order summary (items, qty, price)
- [ ] Subtotal/tax/total using total_amount
- [ ] Chat CTA navigates correctly
- [ ] View route CTA works
- [ ] Back to feed navigation

**Acceptance Criteria:**
- Visual match: ≥95%
- Pickup code: High contrast, ≥24sp
- Total calculation: Accurate
- Navigation: All CTAs functional

**Notes:**
_[To be filled during UAT]_

---

#### 7. Active Order Modal
**Reference:** `design/ui/layouts/active_order_modal.html`  
**Flutter:** `lib/features/order/widgets/active_order_modal.dart`

- [ ] Status timeline complete
- [ ] Status colors match design
- [ ] Pickup code visibility by status
- [ ] Quick actions (chat, route, refresh)
- [ ] Order details display
- [ ] Modal dismissal works
- [ ] Realtime updates functional

**Acceptance Criteria:**
- Visual match: ≥95%
- Timeline: All 5 states
- Realtime: <3s update latency
- Modal animation: Smooth

**Notes:**
_[To be filled during UAT]_

---

#### 8. Profile Screen
**Reference:** `design/ui/layouts/buyer_profile_screen.html`  
**Flutter:** `lib/features/profile/screens/profile_screen.dart`

- [ ] Profile header with avatar
- [ ] User info display
- [ ] Navigation to settings
- [ ] Navigation to favorites
- [ ] Navigation to notifications
- [ ] Logout functionality
- [ ] Profile drawer integration

**Acceptance Criteria:**
- Visual match: ≥90%
- Navigation: All links functional
- Logout: Clears session

**Notes:**
_[To be filled during UAT]_

---

#### 9. Favorites Screen
**Reference:** `design/ui/layouts/favourites_screen.html`  
**Flutter:** `lib/features/profile/screens/favourites_screen.dart`

- [ ] Favorite dishes list
- [ ] Card styling matches feed
- [ ] Empty state with CTA
- [ ] Optimistic fav/unfav updates
- [ ] Navigation to dish detail
- [ ] Pull-to-refresh

**Acceptance Criteria:**
- Visual match: ≥95%
- Optimistic updates: <100ms
- Empty state: Explore CTA works

**Notes:**
_[To be filled during UAT]_

---

#### 10. Notifications Screen
**Reference:** `design/ui/layouts/notifications_screen.html`  
**Flutter:** `lib/features/settings/screens/notifications_screen.dart`

- [ ] Notification toggles styled
- [ ] Order updates toggle
- [ ] Chat messages toggle
- [ ] Promotions toggle
- [ ] Storage in users_public.notification_preferences
- [ ] Loading states
- [ ] Error handling
- [ ] Success toast

**Acceptance Criteria:**
- Visual match: ≥95%
- Storage: users_public table
- Toggle response: <500ms

**Notes:**
_[To be filled during UAT]_

---

#### 11. Chat Detail Screen
**Reference:** `design/ui/layouts/in-app_chat_screen.html`  
**Flutter:** `lib/features/chat/screens/chat_detail_screen.dart`

- [ ] Header with order status color
- [ ] Message list display
- [ ] Message input field
- [ ] Send button functional
- [ ] Quick replies
- [ ] Autoscroll to latest
- [ ] Empty state
- [ ] Error states
- [ ] Attachment stub
- [ ] Realtime updates

**Acceptance Criteria:**
- Visual match: ≥90%
- Realtime: <2s message delivery
- Autoscroll: Functional
- Quick replies: Tap to send

**Notes:**
_[To be filled during UAT]_

---

#### 12. Settings Screen
**Reference:** `design/ui/layouts/settings_screen.html`  
**Flutter:** `lib/features/settings/screens/settings_screen.dart`

- [ ] Settings sections styled
- [ ] Account section
- [ ] Notifications navigation
- [ ] Privacy policy dialog
- [ ] Terms of service dialog
- [ ] Logout confirmation
- [ ] App version display

**Acceptance Criteria:**
- Visual match: ≥95%
- All navigation functional
- Dialogs display correctly

**Notes:**
_[To be filled during UAT]_

---

### Vendor Screens

#### 13. Vendor Dashboard
**Reference:** `design/ui/layouts/vendor_dashboard.html`  
**Flutter:** `lib/features/vendor/screens/vendor_dashboard_screen.dart`

- [ ] Dashboard header
- [ ] Revenue metrics tiles
- [ ] Order queue cards
- [ ] Status chips styled
- [ ] Filter buttons (pending/active/completed)
- [ ] Quick tour entry point
- [ ] Realtime updates
- [ ] Empty state
- [ ] Pull-to-refresh

**Acceptance Criteria:**
- Visual match: ≥95%
- Metrics: Accurate calculations
- Realtime: <3s update latency
- Filters: Functional

**Notes:**
_[To be filled during UAT]_

---

#### 14. Vendor Quick Tour
**Reference:** `design/ui/layouts/vendor_dashboard_quick_tour.html`  
**Flutter:** `lib/features/vendor/screens/vendor_quick_tour_screen.dart`

- [ ] Tour steps display
- [ ] Navigation between steps
- [ ] Skip functionality
- [ ] Completion state saved
- [ ] Visual styling matches

**Acceptance Criteria:**
- Visual match: ≥95%
- All steps accessible
- Completion persists

**Notes:**
_New screen - requires implementation._

---

#### 15. Vendor Order Detail
**Reference:** `design/ui/layouts/vendor_order_detail.html`  
**Flutter:** `lib/features/vendor/screens/order_detail_screen.dart`

- [ ] Order detail header
- [ ] Status timeline
- [ ] Accept button (change_order_status)
- [ ] Prepare button
- [ ] Ready button
- [ ] Order items display
- [ ] Customer information
- [ ] Pickup code verification
- [ ] Error handling
- [ ] Success toasts
- [ ] Chat navigation

**Acceptance Criteria:**
- Visual match: ≥95%
- Status changes: change_order_status Edge Function
- Pickup verification: verify_pickup_code RPC
- Error messages: User-friendly

**Notes:**
_[To be filled during UAT]_

---

#### 16. Add/Edit Dish Screen
**Reference:** `design/ui/layouts/vendor_add_dish_screen.html`  
**Flutter:** `lib/features/vendor/screens/dish_edit_screen.dart`

- [ ] Form fields styled
- [ ] Media upload flow
- [ ] Image preview
- [ ] Progress indicator
- [ ] Type/size validation
- [ ] Form validation
- [ ] Error messages
- [ ] Success toast
- [ ] Navigation after save

**Acceptance Criteria:**
- Visual match: ≥95%
- Upload: Signed URLs
- Validation: Client-side
- Max file size: 5MB

**Notes:**
_[To be filled during UAT]_

---

#### 17. Business Info Entry
**Reference:** `design/ui/layouts/vendor_business_info_entry.html`  
**Flutter:** `lib/features/vendor/screens/vendor_onboarding_screen.dart`

- [ ] Business fields styled
- [ ] Form validation
- [ ] Place pin map integration
- [ ] Error handling
- [ ] Success navigation

**Acceptance Criteria:**
- Visual match: ≥95%
- Validation: All required fields
- Map: Pin placement functional

**Notes:**
_[To be filled during UAT]_

---

#### 18. Moderation Tools
**Reference:** `design/ui/layouts/vendor_moderation_tools.html`  
**Flutter:** `lib/features/vendor/screens/moderation_tools_screen.dart`

- [ ] Feature flag enabled
- [ ] Route guard functional
- [ ] Moderation actions styled
- [ ] Hidden in production

**Acceptance Criteria:**
- Feature flag: Functional
- Production: Hidden
- Actions: Admin-only

**Notes:**
_Feature-flagged - test in dev only._

---

#### 19. Availability Management
**Reference:** `design/ui/layouts/dish_availability_management.html`  
**Flutter:** `lib/features/vendor/screens/availability_management_screen.dart`

- [ ] Schedule UI styled
- [ ] Day toggles functional
- [ ] Time pickers work
- [ ] Save functionality
- [ ] Loading states

**Acceptance Criteria:**
- Visual match: ≥95%
- Schedule: Persists correctly
- UI: Intuitive

**Notes:**
_[To be filled during UAT]_

---

## Material Design vs HTML Acceptable Deviations

### Platform-Appropriate Differences

These deviations are **acceptable** and align with platform best practices:

#### 1. Ripple Effects
- **HTML:** Hover states, CSS transitions
- **Flutter:** Material ripple effects on tap
- **Rationale:** Native Android interaction pattern

#### 2. Elevation/Shadows
- **HTML:** CSS box-shadow with specific blur/spread
- **Flutter:** Material elevation levels (0-24)
- **Rationale:** Material Design specification

#### 3. Map Controls
- **HTML:** Custom styled controls
- **Flutter:** Google Maps native controls
- **Rationale:** Platform consistency and accessibility

#### 4. Bottom Navigation
- **HTML:** Custom tab bar
- **Flutter:** Material BottomNavigationBar with glass overlay
- **Rationale:** Native navigation pattern with design enhancement

#### 5. Text Selection
- **HTML:** Custom selection color
- **Flutter:** System text selection handles
- **Rationale:** Platform accessibility features

#### 6. Scrollbars
- **HTML:** Custom styled scrollbars
- **Flutter:** Platform scrollbars (hidden on mobile)
- **Rationale:** Mobile convention

#### 7. Dialogs/Modals
- **HTML:** Custom modal animations
- **Flutter:** Material dialog transitions
- **Rationale:** Platform consistency

#### 8. Form Inputs
- **HTML:** Custom input styling
- **Flutter:** Material TextFormField with custom decoration
- **Rationale:** Platform keyboard integration

### Unacceptable Deviations

These differences require **design review and approval**:

- Color palette mismatches
- Typography hierarchy changes
- Spacing/padding significant differences (>8dp)
- Border radius changes (>4dp)
- Missing UI elements
- Incorrect layout structure
- Wrong component hierarchy

## Functional Validation Checklist

### Buyer Flow End-to-End

- [ ] **Auth Flow**
  - [ ] Splash screen loads
  - [ ] Role selection works
  - [ ] Sign up with email/password
  - [ ] Email verification (if enabled)
  - [ ] Profile creation
  - [ ] Navigation to map/feed

- [ ] **Browse & Search**
  - [ ] Map loads with vendor markers
  - [ ] Search with 600ms debounce
  - [ ] Filter results
  - [ ] Switch to feed view
  - [ ] Scroll pagination
  - [ ] Pull-to-refresh

- [ ] **Order Creation**
  - [ ] Tap dish card
  - [ ] Dish detail loads
  - [ ] Adjust quantity
  - [ ] Select pickup time
  - [ ] Add to order
  - [ ] Order confirmation displays
  - [ ] Pickup code visible
  - [ ] Copy code works

- [ ] **Order Tracking**
  - [ ] Active orders tab shows order
  - [ ] Tap order opens modal
  - [ ] Status timeline updates
  - [ ] Realtime status changes
  - [ ] Chat button navigates
  - [ ] View route works

- [ ] **Chat**
  - [ ] Chat screen loads
  - [ ] Send message
  - [ ] Receive message (realtime)
  - [ ] Quick replies work
  - [ ] Autoscroll functional

- [ ] **Order Completion**
  - [ ] Vendor marks ready
  - [ ] Pickup code shown
  - [ ] Buyer confirms pickup
  - [ ] Order marked completed
  - [ ] Order moves to history

- [ ] **Profile & Settings**
  - [ ] View profile
  - [ ] Edit profile
  - [ ] View favorites
  - [ ] Add/remove favorite
  - [ ] Update notification preferences
  - [ ] Logout

### Vendor Flow End-to-End

- [ ] **Vendor Onboarding**
  - [ ] Business info entry
  - [ ] Place pin on map
  - [ ] Profile creation
  - [ ] Navigation to dashboard

- [ ] **Dashboard**
  - [ ] Metrics display correctly
  - [ ] Order queue loads
  - [ ] Filter orders
  - [ ] Realtime updates

- [ ] **Order Management**
  - [ ] Tap order card
  - [ ] Order detail loads
  - [ ] Accept order (change_order_status)
  - [ ] Mark preparing
  - [ ] Mark ready
  - [ ] Verify pickup code
  - [ ] Complete order

- [ ] **Dish Management**
  - [ ] Add new dish
  - [ ] Upload image
  - [ ] Edit dish
  - [ ] Toggle availability
  - [ ] Delete dish

- [ ] **Chat**
  - [ ] Receive customer message
  - [ ] Send reply
  - [ ] Quick replies work

## Performance Validation

### Benchmarks

- [ ] **App Launch**
  - Cold start: <3s
  - Warm start: <1s

- [ ] **Screen Transitions**
  - Navigation: <300ms
  - Hero animations: 60fps

- [ ] **List Scrolling**
  - Feed scroll: ≥55fps
  - No jank on fast scroll

- [ ] **Search Debounce**
  - Delay: 600ms ±50ms
  - No duplicate requests

- [ ] **Realtime Updates**
  - Order status: <3s latency
  - Chat messages: <2s latency

- [ ] **Image Loading**
  - Cached images: <100ms
  - Network images: Progressive load
  - Thumbnails: <500ms

- [ ] **API Response Times**
  - Order creation: <2s
  - Status change: <1s
  - Profile update: <1s

### Performance Testing Tools

```bash
# Profile build performance
flutter run --profile --trace-startup

# Measure frame rendering
flutter run --profile --trace-skia

# Analyze app size
flutter build apk --analyze-size

# Run performance tests
flutter test integration_test/map_feed_performance_test.dart
```

## Accessibility Validation

### WCAG AA Compliance

- [ ] **Color Contrast**
  - Text: ≥4.5:1
  - Large text: ≥3:1
  - UI components: ≥3:1

- [ ] **Tap Targets**
  - Minimum size: 48x48dp
  - Spacing: ≥8dp

- [ ] **Semantic Labels**
  - All buttons labeled
  - All images have alt text
  - Form fields have labels

- [ ] **Focus Order**
  - Logical tab order
  - Focus indicators visible

- [ ] **Text Scaling**
  - Supports up to 2.5x
  - No text truncation
  - Layout adapts

- [ ] **Screen Reader**
  - TalkBack (Android) functional
  - All content accessible
  - Navigation clear

### Accessibility Testing

```bash
# Run accessibility tests
flutter test test/features/dish/screens/dish_detail_accessibility_test.dart

# Enable TalkBack on Android
adb shell settings put secure enabled_accessibility_services com.google.android.marvin.talkback/com.google.android.marvin.talkback.TalkBackService

# Test with large text
adb shell settings put system font_scale 2.0
```

## Backend Contract Validation

### Edge Functions

- [ ] **create_order**
  - Request shape correct
  - Response: `{ success, message, data }`
  - Idempotency key handling
  - Error codes mapped

- [ ] **change_order_status**
  - Request shape correct
  - Response: `{ success, message, data }`
  - Status validation
  - Ownership checks

### Postgres RPC

- [ ] **verify_pickup_code**
  - Code validation
  - One-time use enforced
  - Ownership verified
  - Error handling

### Data Consistency

- [ ] **total_amount Usage**
  - No total_cents in code
  - Decimal calculations correct
  - UI formatting consistent

- [ ] **Notification Preferences**
  - Stored in users_public table
  - Key is id (not user_id)
  - Load/save functional

## Bug Tracking

### Critical Bugs (Blockers)
_Must be fixed before release_

| ID | Screen | Issue | Status | Assignee |
|----|--------|-------|--------|----------|
| - | - | - | - | - |

### High Priority Bugs
_Should be fixed before release_

| ID | Screen | Issue | Status | Assignee |
|----|--------|-------|--------|----------|
| - | - | - | - | - |

### Medium Priority Bugs
_Can be fixed post-release_

| ID | Screen | Issue | Status | Assignee |
|----|--------|-------|--------|----------|
| - | - | - | - | - |

### Low Priority Bugs
_Nice to have fixes_

| ID | Screen | Issue | Status | Assignee |
|----|--------|-------|--------|----------|
| - | - | - | - | - |

## Sign-off Checklist

### Design Team Sign-off

- [ ] All screens reviewed against HTML reference
- [ ] Visual parity acceptable (≥90% match)
- [ ] Material deviations approved
- [ ] Typography and spacing verified
- [ ] Color palette consistent
- [ ] Glass UI implementation approved

**Signed:** _________________ **Date:** _________

### Product Team Sign-off

- [ ] All user flows functional
- [ ] Feature completeness verified
- [ ] Business requirements met
- [ ] Edge cases handled
- [ ] Error messaging appropriate
- [ ] Performance acceptable

**Signed:** _________________ **Date:** _________

### Engineering Team Sign-off

- [ ] Code quality standards met
- [ ] Test coverage adequate (>80%)
- [ ] Performance benchmarks met
- [ ] Accessibility compliance verified
- [ ] Backend contracts validated
- [ ] Security review completed

**Signed:** _________________ **Date:** _________

### QA Team Sign-off

- [ ] All test cases executed
- [ ] Critical bugs resolved
- [ ] High priority bugs resolved
- [ ] Regression testing completed
- [ ] Device compatibility verified
- [ ] Release notes prepared

**Signed:** _________________ **Date:** _________

## Release Readiness

### Pre-Release Checklist

- [ ] All sign-offs obtained
- [ ] Critical bugs resolved
- [ ] Release notes finalized
- [ ] App store assets prepared
- [ ] Privacy policy updated
- [ ] Terms of service updated
- [ ] Analytics configured
- [ ] Crash reporting enabled
- [ ] Feature flags configured
- [ ] Environment variables set

### Post-Release Monitoring

- [ ] Crash rate monitoring
- [ ] Performance metrics tracking
- [ ] User feedback collection
- [ ] Analytics review
- [ ] Support ticket tracking

## OpenSpec Validation

### Change Archive

- [ ] Update OpenSpec with final status
- [ ] Archive completed changes
- [ ] Document lessons learned
- [ ] Update project.md with release info

### Documentation Updates

- [ ] README.md updated
- [ ] CHANGELOG.md updated
- [ ] API documentation current
- [ ] User guides prepared

## Resources

- **UAT Guide:** This document
- **Test Guide:** `PHASE_7_TESTING_GUIDE.md`
- **Implementation Summary:** `IMPLEMENTATION_SUMMARY.md`
- **User Flows Plan:** `plans/user-flows-completion.md`
- **Design Reference:** `design/ui/layouts/`
- **OpenSpec:** `openspec/`

## Next Steps

1. **Execute UAT** - Complete all validation checklists
2. **Document Findings** - Record all issues and deviations
3. **Obtain Sign-offs** - Get stakeholder approvals
4. **Prepare Release** - Finalize release artifacts
5. **Archive Change** - Update OpenSpec and close project

---

**Phase 9 Status:** 🔄 In Progress  
**Target Completion:** TBD  
**Release Target:** TBD
