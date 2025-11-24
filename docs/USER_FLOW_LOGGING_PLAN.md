# Comprehensive User Flow Logging Plan

**Version**: 1.0.0  
**Created**: 2025-11-24  
**Status**: Implementation Ready

## Executive Summary

This plan implements comprehensive terminal logging for all customer and vendor user flows in the Chefleet app to enable effective debugging and error tracking.

## Goals

1. **Track every user interaction** - Navigation, button clicks, form submissions
2. **Monitor all BLoC state changes** - Events, state transitions, errors
3. **Log API calls** - Supabase queries, edge function calls, response times
4. **Capture errors and exceptions** - With full context and stack traces
5. **Identify performance bottlenecks** - Slow operations, memory issues
6. **Enable flow replay** - Reconstruct user sessions from logs

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Terminal Output                          │
│  [FLOW] [NAV] [BLOC] [API] [ERROR] [PERF] logs              │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
┌───────────────────────────┴─────────────────────────────────┐
│                   Flow Logger Service                        │
│  - User Flow Tracker                                         │
│  - Navigation Observer                                       │
│  - BLoC Observer (Enhanced)                                  │
│  - API Call Interceptor                                      │
│  - Error Handler                                             │
│  - Performance Monitor                                       │
└──────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Enhanced Logging Infrastructure

### 1.1 Create UserFlowLogger

**File**: `lib/core/utils/user_flow_logger.dart`

```dart
enum FlowCategory {
  navigation,
  bloc,
  api,
  error,
  performance,
  userAction,
  auth,
  order,
  chat,
  vendor
}

enum UserRole { customer, vendor, guest, admin }

class UserFlowLogger {
  static UserRole? _currentUserRole;
  static String? _currentUserId;
  static String? _currentSessionId;
  
  // Flow tracking methods
  static void logUserAction(String action, Map<String, dynamic> details);
  static void logNavigation(String from, String to, Map<String, dynamic>? params);
  static void logBlocEvent(String blocName, String event, Map<String, dynamic> data);
  static void logBlocState(String blocName, String state, Map<String, dynamic> data);
  static void logApiCall(String endpoint, String method, Map<String, dynamic> params);
  static void logApiResponse(String endpoint, int statusCode, Duration duration);
  static void logError(String context, dynamic error, StackTrace? stackTrace);
  static void logPerformance(String operation, Duration duration);
  
  // Flow session management
  static void startSession(String userId, UserRole role);
  static void endSession();
  static void logFlowMilestone(String milestone);
}
```

### 1.2 Enhanced AppBlocObserver

**File**: `lib/core/blocs/app_bloc_observer.dart` (Enhanced)

Add detailed BLoC flow tracking with user context and flow categorization.

### 1.3 Navigation Observer

**File**: `lib/core/router/flow_route_observer.dart`

```dart
class FlowRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    UserFlowLogger.logNavigation(
      previousRoute?.settings.name ?? 'unknown',
      route.settings.name ?? 'unknown',
      {'action': 'push'}
    );
  }
  
  @override
  void didPop(Route route, Route? previousRoute);
  @override
  void didReplace({Route? newRoute, Route? oldRoute});
  @override
  void didRemove(Route route, Route? previousRoute);
}
```

---

## Phase 2: Customer (Buyer) Flow Logging

### 2.1 Authentication & Onboarding Flows

**Tracked Events**:
- App launch
- Splash screen display
- Auth screen visit
- Sign in/Sign up attempts (success/failure)
- Guest mode activation
- Role selection (buyer)
- Permission requests (location, notifications)
- First app launch completion

**Implementation**: Add logging to `AuthBloc`, `UserProfileBloc`, role selection screen

### 2.2 Discovery & Browse Flows

**Tracked Events**:
- Map screen load
- Location permission granted/denied
- Vendor pins loaded (count, duration)
- Map pan/zoom (with debouncing)
- Vendor marker tap
- Vendor detail screen open
- Menu items loaded
- Dish detail screen open
- Add to cart
- Cart modifications

**Implementation**: Add logging to `MapBloc`, `MapFeedBloc`, vendor/dish screens

### 2.3 Order Placement Flow

**Tracked Events**:
- Cart review opened
- Order summary modal displayed
- Order confirmation tap
- API: Create order request
- API: Create order response (success/error)
- Order ID generated
- Navigation to active order screen
- Real-time subscription established

**Implementation**: Add logging to `CartBloc`, `OrderBloc`, order screens

### 2.4 Order Tracking & Chat Flow

**Tracked Events**:
- Active order screen load
- Order status updates (pending → accepted → ready → completed)
- Chat screen open
- Message sent/received
- Message rate limiting triggered
- Pickup code display
- Order completion

**Implementation**: Add logging to `ActiveOrdersBloc`, `ChatBloc`

### 2.5 Navigation & Profile Flows

**Tracked Events**:
- Bottom nav tab changes
- FAB tap (active order)
- Favorites screen visit
- Order history screen visit
- Profile screen visit
- Settings changes
- Logout

**Implementation**: Add logging to `NavigationBloc`, profile screens

---

## Phase 3: Vendor Flow Logging

### 3.1 Vendor Onboarding Flow

**Tracked Events**:
- Role selection (vendor)
- Vendor onboarding start
- Business info step completed
- Location selection step
- Documents upload step
- Terms acceptance
- Menu wizard started
- Dish added (count)
- Onboarding completion
- Navigation to vendor dashboard

**Implementation**: Add logging to `VendorOnboardingBloc`

### 3.2 Vendor Dashboard Flow

**Tracked Events**:
- Dashboard load
- Vendor data fetch (success/error)
- Orders loaded (pending/accepted/ready counts)
- Menu items loaded
- Real-time subscription established
- Stats calculated
- Tab changes (orders/menu/chat/analytics)
- Refresh triggered

**Implementation**: Add logging to `VendorDashboardBloc`

### 3.3 Order Management Flow

**Tracked Events**:
- New order notification received
- Order detail opened
- Order status update (accept/reject/ready/complete)
- API: Update order status
- Pickup code verification
- Order filter applied
- Order search performed

**Implementation**: Add logging to `OrderManagementBloc`

### 3.4 Menu Management Flow

**Tracked Events**:
- Menu management screen opened
- Dish availability toggled
- Add dish modal opened
- Dish created
- Dish updated
- Dish deleted
- Image upload started/completed
- Dish categories changed

**Implementation**: Add logging to `MenuManagementBloc`, `MediaUploadBloc`

### 3.5 Vendor Chat Flow

**Tracked Events**:
- Chat screen opened
- Conversations loaded
- Conversation selected
- Messages loaded
- Message sent
- Quick reply used
- Quick reply created/updated
- Search/filter applied
- Unread count updated

**Implementation**: Add logging to `VendorChatBloc`

---

## Phase 4: API & Database Logging

### 4.1 Supabase Call Interceptor

**File**: `lib/core/services/supabase_logger_wrapper.dart`

```dart
class SupabaseLoggerWrapper {
  final SupabaseClient _client;
  
  PostgrestFilterBuilder from(String table) {
    final startTime = DateTime.now();
    UserFlowLogger.logApiCall('supabase.from', 'SELECT', {'table': table});
    
    // Wrap response with logging
    return _client.from(table).then((data) {
      final duration = DateTime.now().difference(startTime);
      UserFlowLogger.logApiResponse('supabase.from.$table', 200, duration);
      return data;
    }).catchError((error) {
      UserFlowLogger.logError('supabase.from.$table', error, StackTrace.current);
      throw error;
    });
  }
  
  // Similar wrappers for insert, update, delete, rpc
}
```

### 4.2 Edge Function Call Logging

Track all edge function invocations:
- `create_order`
- `change_order_status`
- `generate_pickup_code`
- `migrate_guest_data`

### 4.3 Real-time Subscription Logging

Track channel subscriptions, connection status, message events.

---

## Phase 5: Error & Exception Handling

### 5.1 Global Error Handler

**File**: `lib/core/errors/global_error_handler.dart`

```dart
class GlobalErrorHandler {
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      UserFlowLogger.logError(
        'FlutterError',
        details.exception,
        details.stack
      );
    };
    
    PlatformDispatcher.instance.onError = (error, stack) {
      UserFlowLogger.logError('PlatformError', error, stack);
      return true;
    };
  }
}
```

### 5.2 Context-Aware Error Logging

Include current user role, screen, and recent actions in error logs.

---

## Phase 6: Performance Monitoring

### 6.1 Screen Load Time Tracking

```dart
class PerformanceTracker {
  static void trackScreenLoad(String screenName) {
    final startTime = DateTime.now();
    return () {
      final duration = DateTime.now().difference(startTime);
      UserFlowLogger.logPerformance('screen_load:$screenName', duration);
    };
  }
}
```

### 6.2 API Response Time Tracking

Log slow queries (>1s), failed requests, retry attempts.

### 6.3 BLoC State Change Duration

Track time between event dispatch and state emission.

---

## Phase 7: Log Output Formatting

### 7.1 Terminal Output Format

```
[2025-11-24 10:30:45.123] [CUSTOMER] [NAV] /map → /vendor/abc123 (push)
[2025-11-24 10:30:45.456] [CUSTOMER] [BLOC] VendorDetailBloc.LoadVendorData {vendorId: abc123}
[2025-11-24 10:30:45.789] [CUSTOMER] [API] supabase.from.vendors SELECT {id: abc123} [234ms]
[2025-11-24 10:30:46.012] [CUSTOMER] [BLOC] VendorDetailBloc.VendorLoaded {vendor: {...}}
[2025-11-24 10:30:47.345] [CUSTOMER] [ACTION] add_to_cart {dishId: xyz789, quantity: 2}
[2025-11-24 10:30:50.678] [CUSTOMER] [ERROR] CartBloc.AddItemError {error: "Dish not available"}
```

### 7.2 Color-Coded Output (Development)

- 🔵 CUSTOMER flows (blue)
- 🟢 VENDOR flows (green)
- 🟡 WARNING (yellow)
- 🔴 ERROR (red)
- ⚪ INFO (white)

---

## Implementation Files to Create

### Core Utilities
1. `lib/core/utils/user_flow_logger.dart` - Main flow logger
2. `lib/core/utils/flow_session.dart` - Session management
3. `lib/core/utils/log_formatter.dart` - Output formatting
4. `lib/core/utils/performance_tracker.dart` - Performance monitoring

### Observers & Interceptors
5. `lib/core/router/flow_route_observer.dart` - Navigation observer
6. `lib/core/blocs/enhanced_bloc_observer.dart` - Enhanced BLoC observer
7. `lib/core/services/supabase_logger_wrapper.dart` - API call logger
8. `lib/core/errors/global_error_handler.dart` - Error handler

### Flow Trackers
9. `lib/core/flows/customer_flow_tracker.dart` - Customer-specific tracking
10. `lib/core/flows/vendor_flow_tracker.dart` - Vendor-specific tracking

---

## Integration Points

### main.dart Modifications

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logging
  GlobalErrorHandler.initialize();
  Bloc.observer = EnhancedBlocObserver();
  
  runApp(ChefleetApp());
}
```

### AppRouter Modifications

Add `FlowRouteObserver` to GoRouter observers.

### BLoC Modifications

Add flow logging to all existing BLoCs (14 total identified).

---

## Testing & Validation

### Manual Testing Checklist

**Customer Flows**:
- [ ] Complete signup → browse → order → track → complete flow
- [ ] Guest mode → browse → conversion prompt
- [ ] Add favorites → view favorites
- [ ] View order history
- [ ] Send chat messages

**Vendor Flows**:
- [ ] Complete vendor onboarding
- [ ] Receive and accept order
- [ ] Update order status
- [ ] Manage menu items
- [ ] Respond to customer chat

### Log Validation

- [ ] All navigation events logged
- [ ] All BLoC events/states logged
- [ ] All API calls logged with timing
- [ ] Errors include full context
- [ ] Performance issues flagged (>1s operations)

---

## Configuration & Control

### Environment Variables

```env
# .env
ENABLE_FLOW_LOGGING=true
LOG_LEVEL=debug  # debug, info, warn, error
LOG_CATEGORIES=nav,bloc,api,error,perf  # comma-separated
LOG_USER_ROLES=customer,vendor  # which roles to log
```

### Runtime Toggle

```dart
UserFlowLogger.setEnabled(true);
UserFlowLogger.setCategories([FlowCategory.navigation, FlowCategory.error]);
UserFlowLogger.setRoles([UserRole.customer]);
```

---

## Expected Benefits

1. **Faster Debugging** - Identify exact point of failure in user flows
2. **Error Context** - Know exactly what user was doing when error occurred
3. **Performance Insights** - Find slow screens, API calls, BLoC operations
4. **Flow Optimization** - Identify unnecessary navigation or redundant API calls
5. **User Experience** - Replay sessions to understand user frustrations
6. **Production Monitoring** - Track real user flows (with privacy safeguards)

---

## Privacy & Security Considerations

1. **No PII in logs** - User IDs only, no names/emails/phones
2. **Sensitive data masking** - Passwords, tokens, payment info excluded
3. **Configurable retention** - Logs auto-deleted after N days
4. **Production safeguards** - Reduced logging in release builds

---

## Timeline

- **Phase 1-2**: 2 days (Core infrastructure + Customer flows)
- **Phase 3**: 1 day (Vendor flows)
- **Phase 4**: 1 day (API & Database logging)
- **Phase 5-6**: 1 day (Error handling + Performance)
- **Phase 7**: 1 day (Output formatting + Testing)

**Total**: ~6 days of development

---

## Success Metrics

1. ✅ 100% of user flows logged
2. ✅ All BLoC events/states tracked
3. ✅ All API calls timed and logged
4. ✅ Errors provide actionable context
5. ✅ <5% performance overhead from logging
6. ✅ Can replay any user session from logs

---

## Next Steps

1. Review and approve plan
2. Set up logging infrastructure (Phase 1)
3. Implement customer flow tracking (Phase 2)
4. Implement vendor flow tracking (Phase 3)
5. Add API and error logging (Phases 4-5)
6. Test and validate (Phase 7)
7. Deploy and monitor

---

**End of Plan**
