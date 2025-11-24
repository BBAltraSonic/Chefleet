# Routing Manual Test Checklist

This comprehensive checklist covers all routing scenarios that need manual testing after implementing the routing fix.

## Test Environment Setup

- [ ] Clean install of the app
- [ ] Test device/emulator ready
- [ ] Database seeded with test data
- [ ] Test accounts created (customer, vendor, dual-role)
- [ ] Network connectivity enabled

---

## 1. Authentication Flow Tests

### Splash Screen
- [ ] App launches and shows splash screen
- [ ] Splash screen transitions to auth screen (if logged out)
- [ ] Splash screen transitions to role selection (if logged in, no role)
- [ ] Splash screen transitions to home screen (if logged in with role)

### Auth Screen
- [ ] Can navigate to auth screen from splash
- [ ] Can sign up as new user
- [ ] Can log in as existing user
- [ ] Can log in as guest
- [ ] After auth, redirects to role selection
- [ ] Back button behavior is correct

### Role Selection
- [ ] Shows available roles after authentication
- [ ] Can select customer role → navigates to map
- [ ] Can select vendor role → navigates to dashboard
- [ ] Selection persists after app restart

---

## 2. Customer Navigation Tests

### Map Screen (Customer Home)
- [ ] Map screen loads successfully
- [ ] Bottom navigation is NOT shown (customer shell has no tabs)
- [ ] FAB or cart button is visible
- [ ] Can tap on dish markers
- [ ] Can search for dishes
- [ ] Can filter dishes

### Dish Detail Navigation
- [ ] Tap dish from map → opens dish detail
- [ ] Dish detail screen shows correct data
- [ ] Back button returns to map
- [ ] Can add dish to cart
- [ ] "View Cart" navigates to cart screen

### Cart Navigation
- [ ] Can navigate to cart from map
- [ ] Cart shows correct items
- [ ] Can modify quantities
- [ ] Can remove items
- [ ] "Checkout" button navigates to checkout
- [ ] Back button returns to previous screen

### Checkout Flow
- [ ] Checkout screen loads with cart items
- [ ] Can enter delivery details
- [ ] Can select payment method
- [ ] "Place Order" creates order
- [ ] After order placed, navigates to order confirmation
- [ ] Order confirmation shows correct details

### Orders Navigation
- [ ] Can navigate to orders list
- [ ] Orders list shows all customer orders
- [ ] Tap order → opens order detail
- [ ] Order detail shows correct status
- [ ] Can navigate to chat from order detail
- [ ] Back button works correctly

### Chat Navigation
- [ ] Can navigate to chat list
- [ ] Chat list shows all conversations
- [ ] Tap chat → opens chat detail
- [ ] Chat detail loads messages
- [ ] Can send messages
- [ ] Real-time updates work
- [ ] Back button returns to chat list

### Profile Navigation
- [ ] Can navigate to profile screen
- [ ] Profile shows user data
- [ ] Can edit profile
- [ ] Can access settings
- [ ] Can log out
- [ ] Back button works correctly

### Favourites Navigation
- [ ] Can navigate to favourites
- [ ] Favourites list loads
- [ ] Tap favourite → opens dish detail
- [ ] Back button works correctly

### Settings Navigation
- [ ] Can navigate to settings
- [ ] All settings options are accessible
- [ ] Changes save correctly
- [ ] Back button works correctly

---

## 3. Vendor Navigation Tests

### Vendor Dashboard (Vendor Home)
- [ ] Dashboard loads successfully
- [ ] Bottom navigation is shown with 4 tabs
- [ ] Statistics cards show correct data
- [ ] Recent orders list is visible
- [ ] Tab navigation works (Dashboard, Orders, Dishes, Profile)

### Vendor Orders Navigation
- [ ] Navigate to orders tab
- [ ] Orders list loads all vendor orders
- [ ] Can filter orders by status
- [ ] Tap order → opens order detail
- [ ] Order detail shows customer info
- [ ] Can change order status
- [ ] Can navigate to chat from order

### Dishes Management Navigation
- [ ] Navigate to dishes tab
- [ ] Dishes list loads all vendor dishes
- [ ] Can search/filter dishes
- [ ] Tap "Add Dish" → opens add dish screen
- [ ] Tap dish → opens edit dish screen
- [ ] Can edit dish details
- [ ] Can toggle dish availability
- [ ] Changes save correctly

### Add Dish Flow
- [ ] Add dish screen loads
- [ ] All form fields are accessible
- [ ] Can upload images
- [ ] Form validation works
- [ ] "Save" creates dish → returns to dishes list
- [ ] Back button confirms unsaved changes

### Edit Dish Flow
- [ ] Edit dish screen loads with existing data
- [ ] Can modify all fields
- [ ] Can change images
- [ ] "Save" updates dish → returns to dishes list
- [ ] "Delete" removes dish after confirmation
- [ ] Back button confirms unsaved changes

### Vendor Profile Navigation
- [ ] Navigate to profile tab
- [ ] Profile shows vendor data
- [ ] Can edit business info
- [ ] Can manage availability
- [ ] Can access analytics
- [ ] Back navigation works

### Vendor Onboarding
- [ ] New vendor → redirects to onboarding
- [ ] Onboarding steps flow correctly
- [ ] Can complete all steps
- [ ] After completion → redirects to dashboard

---

## 4. Role Switching Tests

### Dual-Role User
- [ ] User with both roles sees role switcher
- [ ] Can switch from customer to vendor
- [ ] Navigation updates to vendor shell
- [ ] Can switch from vendor to customer
- [ ] Navigation updates to customer shell
- [ ] Role preference persists

### Role-Based Access Control
- [ ] Customer cannot access vendor routes directly
- [ ] Vendor cannot access customer routes (if vendor-only)
- [ ] Attempting unauthorized access redirects correctly
- [ ] No error screens or crashes

---

## 5. Deep Link Tests

### Customer Deep Links
- [ ] `chefleet://customer/map` → opens map
- [ ] `chefleet://customer/dish/[id]` → opens dish detail
- [ ] `chefleet://customer/orders` → opens orders list
- [ ] `chefleet://customer/orders/[id]` → opens order detail
- [ ] `chefleet://customer/chat/[id]` → opens chat
- [ ] HTTPS links work (`https://chefleet.app/customer/*`)

### Vendor Deep Links
- [ ] `chefleet://vendor/dashboard` → opens dashboard
- [ ] `chefleet://vendor/orders` → opens vendor orders
- [ ] `chefleet://vendor/orders/[id]` → opens order detail
- [ ] `chefleet://vendor/dishes` → opens dishes list
- [ ] `chefleet://vendor/dishes/edit/[id]` → opens edit dish
- [ ] HTTPS links work (`https://chefleet.app/vendor/*`)

### Deep Link Role Switching
- [ ] Customer receives vendor deep link → prompts role switch
- [ ] Vendor receives customer deep link → prompts role switch
- [ ] User accepts role switch → navigates correctly
- [ ] User declines role switch → stays on current screen

### Invalid Deep Links
- [ ] Invalid deep link shows error dialog
- [ ] User without required role sees appropriate message
- [ ] App doesn't crash on malformed links

---

## 6. Push Notification Navigation

### Order Notifications
- [ ] "New order" (vendor) → navigates to orders
- [ ] "Order status update" (customer) → navigates to order detail
- [ ] "Order ready for pickup" → navigates to order detail

### Chat Notifications
- [ ] "New message" → navigates to chat detail
- [ ] Shows correct conversation
- [ ] Messages load properly

### Dish Notifications
- [ ] "Dish update" (customer) → navigates to dish detail
- [ ] "Dish approved" (vendor) → navigates to dishes list

### Notification Role Switching
- [ ] Notification for different role prompts switch
- [ ] Accept switch → navigates correctly
- [ ] Decline switch → notification dismissed

---

## 7. Back Navigation Tests

### Normal Back Navigation
- [ ] Back button pops navigation stack
- [ ] Multiple back presses work correctly
- [ ] System back button behaves same as UI back button
- [ ] Back navigation respects modal routes

### Back at Root
- [ ] Back button at customer home (map) exits app
- [ ] Back button at vendor home (dashboard) exits app
- [ ] App exit confirmation dialog works (if implemented)

### Form Back Navigation
- [ ] Back from form with unsaved changes shows confirmation
- [ ] Accept → discards changes and navigates back
- [ ] Cancel → stays on form

---

## 8. Guest User Tests

### Allowed Routes
- [ ] Guest can view map
- [ ] Guest can view dish details
- [ ] Guest can search/filter dishes

### Restricted Routes
- [ ] Guest cannot access orders
- [ ] Guest cannot access chat
- [ ] Guest cannot checkout
- [ ] Attempting restricted action shows auth prompt

### Guest Conversion
- [ ] Conversion prompt appears at correct triggers
- [ ] Can convert to registered user
- [ ] After conversion, can access all features
- [ ] Guest data migrates correctly

---

## 9. Edge Cases & Error Handling

### Network Errors
- [ ] Navigation works offline (cached routes)
- [ ] Error states show when data fails to load
- [ ] Retry mechanisms work

### Invalid Routes
- [ ] Invalid route URL redirects to safe route
- [ ] No white screen of death
- [ ] Error logged appropriately

### Missing Parameters
- [ ] Routes with missing IDs handle gracefully
- [ ] Shows "Not found" or redirects appropriately
- [ ] Doesn't crash the app

### Concurrent Navigation
- [ ] Multiple rapid navigation calls don't break routing
- [ ] No duplicate screens in stack
- [ ] State remains consistent

---

## 10. State Preservation Tests

### App Lifecycle
- [ ] Navigation state preserved on app background
- [ ] Returns to same screen when app reopened
- [ ] Scroll position preserved
- [ ] Form data preserved (if appropriate)

### Role Switch State
- [ ] Customer navigation state preserved on role switch
- [ ] Vendor navigation state preserved on role switch
- [ ] Can return to previous role state

---

## 11. Performance Tests

### Navigation Speed
- [ ] Route transitions are smooth
- [ ] No noticeable lag when navigating
- [ ] Animations work correctly
- [ ] No jank or stuttering

### Memory Usage
- [ ] No memory leaks after extensive navigation
- [ ] Old screens disposed properly
- [ ] Large lists don't cause performance issues

---

## 12. Accessibility Tests

### Screen Reader
- [ ] Navigation announces screen changes
- [ ] Back button is announced correctly
- [ ] Route transitions are clear to screen reader users

### Keyboard Navigation
- [ ] Can navigate with keyboard (web/desktop)
- [ ] Tab order is logical
- [ ] Enter/Space activate navigation

---

## Sign-Off

### Test Summary
- **Total Tests**: _____
- **Passed**: _____
- **Failed**: _____
- **Blocked**: _____

### Critical Issues Found
1. _____________________________________
2. _____________________________________
3. _____________________________________

### Tester Information
- **Name**: _____________________
- **Date**: _____________________
- **Build Version**: _____________
- **Test Device**: _______________

### Approval
- [ ] All critical tests passed
- [ ] All blockers resolved
- [ ] Ready for production deployment

**Signature**: ___________________  
**Date**: _______________________
