# Logging Implementation Checklist

Complete implementation checklist for user flow logging across the entire Chefleet app.

## Phase 1: Core Infrastructure ✓

### New Files to Create
- [ ] `lib/core/utils/user_flow_logger.dart` - Main logging utility
- [ ] `lib/core/router/flow_route_observer.dart` - Navigation observer
- [ ] `lib/core/flows/customer_flow_tracker.dart` - Customer flow helpers
- [ ] `lib/core/flows/vendor_flow_tracker.dart` - Vendor flow helpers

### Files to Modify
- [ ] `lib/core/blocs/app_bloc_observer.dart` - Enhanced BLoC logging
- [ ] `lib/main.dart` - Initialize logging system
- [ ] `lib/core/router/app_router.dart` - Add route observer

---

## Phase 2: Customer (Buyer) Flow Logging

### Authentication & Onboarding (4 files)

- [ ] **`lib/features/auth/blocs/auth_bloc.dart`**
  - [ ] Sign in/Sign up attempts
  - [ ] Guest mode activation
  - [ ] Session start/end
  - [ ] Password reset flows
  
- [ ] **`lib/features/auth/blocs/user_profile_bloc.dart`**
  - [ ] Profile creation
  - [ ] Profile updates
  - [ ] Profile loading
  
- [ ] **`lib/features/auth/screens/auth_screen.dart`**
  - [ ] Screen load
  - [ ] Button taps (sign in, sign up, guest)
  - [ ] Form submissions
  
- [ ] **`lib/features/auth/screens/splash_screen.dart`**
  - [ ] App launch
  - [ ] Auth check
  - [ ] Auto navigation

### Map & Discovery (3 files)

- [ ] **`lib/features/map/blocs/map_bloc.dart`**
  - [ ] Map initialization
  - [ ] Location permission requests
  - [ ] Map pan/zoom events
  - [ ] Vendor pin taps
  
- [ ] **`lib/features/map/blocs/map_feed_bloc.dart`**
  - [ ] Vendor data loading
  - [ ] Dish data loading
  - [ ] Filtering/sorting
  
- [ ] **`lib/features/map/screens/map_screen.dart`**
  - [ ] Screen load time
  - [ ] User interactions
  - [ ] FAB taps

### Vendor & Dish Details (4 files)

- [ ] **`lib/features/feed/screens/feed_screen.dart`**
  - [ ] Feed loading
  - [ ] Scroll events
  - [ ] Vendor selection
  
- [ ] **`lib/features/dish/screens/dish_detail_screen.dart`**
  - [ ] Dish detail loading
  - [ ] Add to cart actions
  - [ ] Image loading
  
- [ ] **`lib/features/cart/blocs/cart_bloc.dart`**
  - [ ] Add/remove items
  - [ ] Quantity changes
  - [ ] Cart total calculations

### Order Placement & Tracking (3 files)

- [ ] **`lib/features/order/blocs/order_bloc.dart`**
  - [ ] Order creation
  - [ ] Order submission
  - [ ] Payment processing (future)
  
- [ ] **`lib/features/order/blocs/active_orders_bloc.dart`**
  - [ ] Active order loading
  - [ ] Real-time status updates
  - [ ] Order completion
  
- [ ] **`lib/features/order/screens/order_confirmation_screen.dart`**
  - [ ] Screen display
  - [ ] Pickup code display

### Chat (2 files)

- [ ] **`lib/features/chat/blocs/chat_bloc.dart`**
  - [ ] Chat loading
  - [ ] Message send/receive
  - [ ] Real-time subscriptions
  - [ ] Rate limiting
  
- [ ] **`lib/features/chat/screens/chat_detail_screen.dart`**
  - [ ] Chat screen open
  - [ ] Message input
  - [ ] Attachment handling

### Navigation & Profile (3 files)

- [ ] **`lib/core/blocs/navigation_bloc.dart`**
  - [ ] Tab changes
  - [ ] FAB taps
  - [ ] Badge updates
  
- [ ] **`lib/features/profile/screens/profile_screen.dart`**
  - [ ] Profile view
  - [ ] Edit actions
  - [ ] Logout
  
- [ ] **`lib/features/profile/screens/favourites_screen.dart`**
  - [ ] Favorites loading
  - [ ] Add/remove favorites

---

## Phase 3: Vendor Flow Logging

### Vendor Onboarding (2 files)

- [ ] **`lib/features/vendor/blocs/vendor_onboarding_bloc.dart`**
  - [ ] Onboarding steps
  - [ ] Business info submission
  - [ ] Location selection
  - [ ] Document uploads
  - [ ] Completion
  
- [ ] **`lib/features/vendor/screens/vendor_onboarding_screen.dart`**
  - [ ] Step navigation
  - [ ] Form submissions
  - [ ] Progress tracking

### Vendor Dashboard (2 files)

- [ ] **`lib/features/vendor/blocs/vendor_dashboard_bloc.dart`**
  - [ ] Dashboard data loading
  - [ ] Order statistics
  - [ ] Real-time order updates
  - [ ] Refresh actions
  
- [ ] **`lib/features/vendor/screens/vendor_dashboard_screen.dart`**
  - [ ] Screen load
  - [ ] Tab changes
  - [ ] Quick actions

### Order Management (3 files)

- [ ] **`lib/features/vendor/blocs/order_management_bloc.dart`**
  - [ ] Order list loading
  - [ ] Order acceptance/rejection
  - [ ] Status updates (ready, completed)
  - [ ] Pickup code verification
  
- [ ] **`lib/features/vendor/screens/order_detail_screen.dart`**
  - [ ] Order detail view
  - [ ] Action button taps
  
- [ ] **`lib/features/vendor/widgets/order_filter_bar.dart`**
  - [ ] Filter changes
  - [ ] Search queries

### Menu Management (3 files)

- [ ] **`lib/features/vendor/blocs/menu_management_bloc.dart`**
  - [ ] Menu loading
  - [ ] Dish creation
  - [ ] Dish updates
  - [ ] Availability toggles
  - [ ] Dish deletion
  
- [ ] **`lib/features/vendor/screens/dish_edit_screen.dart`**
  - [ ] Edit screen open
  - [ ] Form submissions
  - [ ] Image uploads
  
- [ ] **`lib/features/vendor/blocs/media_upload_bloc.dart`**
  - [ ] Upload start
  - [ ] Upload progress
  - [ ] Upload completion/failure

### Vendor Chat (2 files)

- [ ] **`lib/features/vendor/blocs/vendor_chat_bloc.dart`**
  - [ ] Conversations loading
  - [ ] Message sending
  - [ ] Quick replies
  - [ ] Search/filter
  
- [ ] **`lib/features/vendor/screens/vendor_chat_screen.dart`**
  - [ ] Chat screen navigation
  - [ ] Conversation selection
  - [ ] Quick reply usage

---

## Phase 4: API & Database Logging

### Supabase Integration

- [ ] **Create `lib/core/services/supabase_logger_wrapper.dart`**
  - [ ] Wrap `from()` queries with logging
  - [ ] Wrap `insert()` operations
  - [ ] Wrap `update()` operations
  - [ ] Wrap `delete()` operations
  - [ ] Wrap `rpc()` calls
  - [ ] Log response times
  - [ ] Flag slow queries (>1s)
  
- [ ] **Update all files using Supabase client**
  - [ ] Replace direct `Supabase.instance.client` usage
  - [ ] Use `SupabaseLoggerWrapper` instead

### Edge Functions

- [ ] **Log edge function calls**
  - [ ] `create_order`
  - [ ] `change_order_status`
  - [ ] `generate_pickup_code`
  - [ ] `migrate_guest_data`
  - [ ] Log request/response
  - [ ] Log execution time

### Real-time Subscriptions

- [ ] **Log real-time events**
  - [ ] Channel subscriptions
  - [ ] Connection status
  - [ ] Message events (INSERT, UPDATE, DELETE)
  - [ ] Connection errors

---

## Phase 5: Error & Performance Tracking

### Global Error Handler

- [ ] **Create `lib/core/errors/global_error_handler.dart`**
  - [ ] Catch Flutter errors
  - [ ] Catch platform errors
  - [ ] Log with full context
  
- [ ] **Update `main.dart`**
  - [ ] Initialize global error handler

### Performance Monitoring

- [ ] **Create `lib/core/utils/performance_tracker.dart`**
  - [ ] Screen load time tracking
  - [ ] API response time tracking
  - [ ] BLoC state change duration
  - [ ] Memory usage tracking
  
- [ ] **Add performance tracking to all screens**
  - [ ] Measure screen load time
  - [ ] Flag slow loads (>1s)

---

## Phase 6: Testing & Validation

### Manual Testing

**Customer Flows** (Complete each flow and verify logs):
- [ ] Signup → Browse → Order → Track → Complete
- [ ] Guest mode → Browse → Conversion
- [ ] Add/remove favorites
- [ ] View order history
- [ ] Send chat messages
- [ ] Update profile

**Vendor Flows** (Complete each flow and verify logs):
- [ ] Vendor onboarding
- [ ] Receive and accept order
- [ ] Update order status
- [ ] Create/edit/delete menu items
- [ ] Toggle dish availability
- [ ] Respond to customer chats
- [ ] View analytics

### Log Validation Checks

- [ ] All navigation events logged
- [ ] All BLoC events logged
- [ ] All BLoC states logged
- [ ] All API calls logged with timing
- [ ] Errors include full context
- [ ] Slow operations flagged
- [ ] User role correctly identified
- [ ] Session tracking works
- [ ] Milestones recorded

### Error Scenario Testing

- [ ] Network timeout during order
- [ ] Permission denied (location)
- [ ] API errors logged properly
- [ ] BLoC errors caught
- [ ] Real-time disconnection
- [ ] Invalid data handling

---

## Implementation Progress Tracker

### Summary Statistics

- **Total Files to Create**: 6
- **Total Files to Modify**: 35
- **Total BLoCs to Update**: 14
- **Total Screens to Update**: 21
- **Estimated Time**: 6 days

### Daily Goals

**Day 1**: Core Infrastructure
- [ ] Create logging utilities
- [ ] Create route observer
- [ ] Update BLoC observer
- [ ] Update main.dart and router

**Day 2**: Customer Flows (Part 1)
- [ ] Auth flows
- [ ] Map & Discovery
- [ ] Vendor/Dish details

**Day 3**: Customer Flows (Part 2)
- [ ] Order placement
- [ ] Order tracking
- [ ] Chat integration

**Day 4**: Vendor Flows
- [ ] Vendor onboarding
- [ ] Dashboard
- [ ] Order management
- [ ] Menu management

**Day 5**: API & Error Handling
- [ ] Supabase wrapper
- [ ] Edge function logging
- [ ] Real-time logging
- [ ] Global error handler
- [ ] Performance tracking

**Day 6**: Testing & Refinement
- [ ] Manual testing all flows
- [ ] Fix issues
- [ ] Validate logs
- [ ] Documentation
- [ ] Performance optimization

---

## Configuration Checklist

- [ ] Set `ENABLE_FLOW_LOGGING=true` in `.env`
- [ ] Configure log levels
- [ ] Configure enabled categories
- [ ] Configure enabled roles
- [ ] Test production safeguards
- [ ] Set up log retention policy

---

## Deployment Checklist

Before deploying to production:

- [ ] Disable verbose logging in release builds
- [ ] Enable only error and critical logs
- [ ] Test performance impact (<5% overhead)
- [ ] Verify no PII in logs
- [ ] Test log file rotation
- [ ] Set up log aggregation (optional)
- [ ] Document logging for team

---

## Success Criteria

✅ **Implementation is complete when**:
1. All 35 files updated with logging
2. All customer flows fully logged
3. All vendor flows fully logged
4. All API calls timed and logged
5. All errors provide actionable context
6. Performance overhead <5%
7. Can replay user sessions from logs
8. All manual tests passing

---

## Troubleshooting

### Logs not appearing?
- Check `UserFlowLogger.setEnabled(true)` in main.dart
- Verify you're running in debug mode
- Check category and role filters

### Too many logs?
- Filter by category: `UserFlowLogger.setCategories({FlowCategory.error})`
- Filter by role: `UserFlowLogger.setRoles({UserRole.vendor})`

### Colors not working?
- Some terminals don't support ANSI colors
- Use plain text mode or a terminal that supports colors

### Performance issues?
- Reduce enabled categories
- Increase slow query threshold
- Disable BLoC state logging

---

**Total Progress**: 0 / 35 files modified

Start with Phase 1 and work through each phase systematically!
