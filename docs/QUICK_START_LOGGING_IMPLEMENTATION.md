# Quick Start: Implementing User Flow Logging

This guide helps you quickly implement the comprehensive logging system.

## Step 1: Add Logger Package (Optional Enhancement)

While the app already has `AppLogger`, you can optionally add the `logger` package for color-coded output:

```yaml
# pubspec.yaml
dependencies:
  logger: ^2.0.2+1  # Optional: for color-coded terminal output
```

## Step 2: Create Core Logging Files

### File 1: `lib/core/utils/user_flow_logger.dart`

```dart
import 'package:flutter/foundation.dart';
import '../../../features/auth/blocs/auth_bloc.dart';

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
  vendor,
  realtime,
  session,
  milestone
}

enum UserRole { customer, vendor, guest, admin, system }

class UserFlowLogger {
  static UserRole _currentUserRole = UserRole.guest;
  static String? _currentUserId;
  static String? _currentSessionId;
  static DateTime? _sessionStartTime;
  static final List<String> _sessionMilestones = [];
  
  // Configuration
  static bool _enabled = kDebugMode;
  static Set<FlowCategory> _enabledCategories = FlowCategory.values.toSet();
  static Set<UserRole> _enabledRoles = UserRole.values.toSet();
  
  // ANSI color codes for terminal
  static const String _reset = '\x1B[0m';
  static const String _blue = '\x1B[34m';   // Customer
  static const String _green = '\x1B[32m';  // Vendor
  static const String _yellow = '\x1B[33m'; // Warning
  static const String _red = '\x1B[31m';    // Error
  static const String _cyan = '\x1B[36m';   // API
  static const String _magenta = '\x1B[35m'; // BLoC
  
  // Session Management
  static void startSession(String userId, UserRole role) {
    _currentUserId = userId;
    _currentUserRole = role;
    _currentSessionId = 'sess_${DateTime.now().millisecondsSinceEpoch}';
    _sessionStartTime = DateTime.now();
    _sessionMilestones.clear();
    
    _log(FlowCategory.session, 'SESSION_STARTED', {
      'sessionId': _currentSessionId,
      'userId': userId,
      'role': role.name,
    }, UserRole.system);
  }
  
  static void endSession() {
    final duration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!)
        : Duration.zero;
        
    _log(FlowCategory.session, 'SESSION_ENDED', {
      'sessionId': _currentSessionId,
      'duration': '${duration.inMinutes}min ${duration.inSeconds % 60}s',
      'milestones': _sessionMilestones.length,
    }, UserRole.system);
    
    _currentSessionId = null;
    _sessionStartTime = null;
    _sessionMilestones.clear();
  }
  
  static void logFlowMilestone(String milestone) {
    _sessionMilestones.add(milestone);
    _log(FlowCategory.milestone, milestone, {}, _currentUserRole);
  }
  
  // User Actions
  static void logUserAction(String action, [Map<String, dynamic>? details]) {
    _log(FlowCategory.userAction, action, details ?? {}, _currentUserRole);
  }
  
  // Navigation
  static void logNavigation(String from, String to, [Map<String, dynamic>? params]) {
    _log(FlowCategory.navigation, '$from → $to', params ?? {}, _currentUserRole);
  }
  
  // BLoC Events & States
  static void logBlocEvent(String blocName, String event, [Map<String, dynamic>? data]) {
    _log(FlowCategory.bloc, '$blocName.$event', data ?? {}, _currentUserRole);
  }
  
  static void logBlocState(String blocName, String state, [Map<String, dynamic>? data]) {
    _log(FlowCategory.bloc, '$blocName.$state', data ?? {}, _currentUserRole);
  }
  
  // API Calls
  static void logApiCall(String endpoint, String method, [Map<String, dynamic>? params]) {
    _log(FlowCategory.api, '$method $endpoint [Request]', params ?? {}, _currentUserRole);
  }
  
  static void logApiResponse(String endpoint, int statusCode, Duration duration, [Map<String, dynamic>? data]) {
    final status = statusCode >= 200 && statusCode < 300 ? 'Success' : 'Error';
    _log(FlowCategory.api, '$endpoint [$status] [${duration.inMilliseconds}ms]', 
         {...?data, 'statusCode': statusCode}, _currentUserRole);
    
    // Flag slow queries
    if (duration.inMilliseconds > 1000) {
      logPerformance('SLOW_API_CALL', duration, {'endpoint': endpoint});
    }
  }
  
  // Real-time Events
  static void logRealtimeEvent(String channel, String event, [Map<String, dynamic>? data]) {
    _log(FlowCategory.realtime, '$event on $channel', data ?? {}, _currentUserRole);
  }
  
  // Errors
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    _log(FlowCategory.error, context, {
      'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString().split('\n').take(5).join('\n'),
    }, _currentUserRole);
  }
  
  // Performance
  static void logPerformance(String operation, Duration duration, [Map<String, dynamic>? details]) {
    _log(FlowCategory.performance, operation, {
      'duration': '${duration.inMilliseconds}ms',
      ...?details,
    }, _currentUserRole);
  }
  
  // Configuration
  static void setEnabled(bool enabled) => _enabled = enabled;
  static void setCategories(Set<FlowCategory> categories) => _enabledCategories = categories;
  static void setRoles(Set<UserRole> roles) => _enabledRoles = roles;
  static void setUserRole(UserRole role) => _currentUserRole = role;
  
  // Core logging method
  static void _log(FlowCategory category, String message, Map<String, dynamic> data, UserRole role) {
    if (!_enabled) return;
    if (!_enabledCategories.contains(category)) return;
    if (!_enabledRoles.contains(role)) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final roleStr = role.name.toUpperCase().padRight(8);
    final categoryStr = category.name.toUpperCase().padRight(12);
    
    // Color coding based on role and category
    String color = _reset;
    if (category == FlowCategory.error) {
      color = _red;
    } else if (category == FlowCategory.api) {
      color = _cyan;
    } else if (category == FlowCategory.bloc) {
      color = _magenta;
    } else if (role == UserRole.customer) {
      color = _blue;
    } else if (role == UserRole.vendor) {
      color = _green;
    }
    
    // Format data string
    final dataStr = data.isEmpty ? '' : ' ${_formatData(data)}';
    
    // Print colored log
    if (kDebugMode) {
      // ignore: avoid_print
      print('$color[$timestamp] [$roleStr] [$categoryStr] $message$dataStr$_reset');
    }
  }
  
  static String _formatData(Map<String, dynamic> data) {
    final entries = data.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    return '{$entries}';
  }
}
```

### File 2: `lib/core/router/flow_route_observer.dart`

```dart
import 'package:flutter/material.dart';
import '../utils/user_flow_logger.dart';

class FlowRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    
    final from = previousRoute?.settings.name ?? 'unknown';
    final to = route.settings.name ?? 'unknown';
    
    UserFlowLogger.logNavigation(from, to, {'action': 'push'});
  }
  
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    
    final from = route.settings.name ?? 'unknown';
    final to = previousRoute?.settings.name ?? 'unknown';
    
    UserFlowLogger.logNavigation(from, to, {'action': 'pop'});
  }
  
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    
    final from = oldRoute?.settings.name ?? 'unknown';
    final to = newRoute?.settings.name ?? 'unknown';
    
    UserFlowLogger.logNavigation(from, to, {'action': 'replace'});
  }
  
  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    
    final routeName = route.settings.name ?? 'unknown';
    UserFlowLogger.logNavigation(routeName, 'removed', {'action': 'remove'});
  }
}
```

### File 3: Enhanced `lib/core/blocs/app_bloc_observer.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/user_flow_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    UserFlowLogger.logBlocEvent(
      bloc.runtimeType.toString(),
      'Created',
    );
  }

  @override
  void onEvent(BlocBase bloc, Object? event) {
    super.onEvent(bloc, event);
    UserFlowLogger.logBlocEvent(
      bloc.runtimeType.toString(),
      event.runtimeType.toString(),
      _extractEventData(event),
    );
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    UserFlowLogger.logBlocState(
      bloc.runtimeType.toString(),
      change.nextState.runtimeType.toString(),
      _extractStateData(change.nextState),
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    UserFlowLogger.logError(
      'BLoC Error: ${bloc.runtimeType}',
      error,
      stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    UserFlowLogger.logBlocEvent(
      bloc.runtimeType.toString(),
      'Closed',
    );
  }
  
  Map<String, dynamic> _extractEventData(Object? event) {
    // Extract meaningful data from event
    // You can customize this based on your event types
    return {};
  }
  
  Map<String, dynamic> _extractStateData(Object? state) {
    // Extract meaningful data from state
    // You can customize this based on your state types
    return {};
  }
}
```

## Step 3: Update main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/blocs/app_bloc_observer.dart';
import 'core/utils/user_flow_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize BLoC observer with enhanced logging
  Bloc.observer = AppBlocObserver();
  
  // Initialize user flow logging
  UserFlowLogger.setEnabled(true);
  UserFlowLogger.logFlowMilestone('APP_LAUNCHED');
  
  runApp(const ChefleetApp());
}
```

## Step 4: Update AppRouter

```dart
// In lib/core/router/app_router.dart
import 'flow_route_observer.dart';

static GoRouter create(BuildContext context) {
  return GoRouter(
    initialLocation: initialRoute,
    observers: [
      FlowRouteObserver(), // Add this
    ],
    redirect: (BuildContext context, GoRouterState state) {
      // ... existing redirect logic
    },
    routes: [
      // ... existing routes
    ],
  );
}
```

## Step 5: Add Logging to Key User Actions

### Example: AuthBloc

```dart
// In lib/features/auth/blocs/auth_bloc.dart
import '../../../core/utils/user_flow_logger.dart';

Future<void> _onSignInWithEmail(
  SignInWithEmail event,
  Emitter<AuthState> emit,
) async {
  UserFlowLogger.logUserAction('sign_in_attempt', {'method': 'email'});
  
  try {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: event.email,
      password: event.password,
    );
    
    if (response.user != null) {
      UserFlowLogger.startSession(response.user!.id, UserRole.customer);
      UserFlowLogger.logFlowMilestone('USER_AUTHENTICATED');
      emit(Authenticated(user: response.user!));
    }
  } catch (e) {
    UserFlowLogger.logError('sign_in_failed', e);
    emit(AuthError(message: e.toString()));
  }
}
```

### Example: Order Creation

```dart
// In lib/features/order/blocs/order_bloc.dart
Future<void> _onCreateOrder(
  CreateOrder event,
  Emitter<OrderState> emit,
) async {
  UserFlowLogger.logUserAction('create_order_initiated', {
    'vendorId': event.vendorId,
    'itemCount': event.items.length,
    'total': event.totalAmount,
  });
  
  final startTime = DateTime.now();
  
  try {
    final response = await _supabaseClient.functions.invoke(
      'create_order',
      body: {...},
    );
    
    final duration = DateTime.now().difference(startTime);
    UserFlowLogger.logApiResponse('create_order', 200, duration, {
      'orderId': response.data['order_id'],
    });
    
    UserFlowLogger.logFlowMilestone('ORDER_CREATED');
    
    emit(OrderCreated(orderId: response.data['order_id']));
  } catch (e) {
    UserFlowLogger.logError('create_order_failed', e);
    emit(OrderError(message: e.toString()));
  }
}
```

## Step 6: Test the Logging

Run your app and observe the terminal output:

```bash
flutter run
```

You should see colored, formatted logs like:

```
[2025-11-24T10:00:00.123] [SYSTEM  ] [SESSION     ] SESSION_STARTED {sessionId: sess_1732444800123, userId: user_123, role: customer}
[2025-11-24T10:00:00.456] [CUSTOMER] [NAVIGATION  ] /splash → /auth {action: push}
[2025-11-24T10:00:00.789] [CUSTOMER] [BLOC        ] AuthBloc.CheckAuthStatus {}
[2025-11-24T10:00:01.012] [CUSTOMER] [API         ] supabase.auth.currentUser [Request] {}
```

## Step 7: Add Logging to Screens

Add logging in `initState` and user actions:

```dart
class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    
    final startTime = DateTime.now();
    
    UserFlowLogger.logUserAction('screen_opened', {'screen': 'VendorDashboard'});
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loadTime = DateTime.now().difference(startTime);
      UserFlowLogger.logPerformance('screen_load:VendorDashboard', loadTime);
    });
  }
  
  void _handleRefresh() {
    UserFlowLogger.logUserAction('refresh_dashboard');
    context.read<VendorDashboardBloc>().add(RefreshDashboard());
  }
}
```

## Configuration Options

### Disable Logging in Production

```dart
// main.dart
void main() {
  // Only enable in debug mode
  UserFlowLogger.setEnabled(kDebugMode);
}
```

### Filter by Category

```dart
// Only log navigation and errors
UserFlowLogger.setCategories({
  FlowCategory.navigation,
  FlowCategory.error,
  FlowCategory.performance,
});
```

### Filter by Role

```dart
// Only log vendor flows
UserFlowLogger.setRoles({UserRole.vendor});
```

## Next Steps

1. ✅ Implement core logging infrastructure
2. Add logging to all 14 BLoCs
3. Add logging to all major screens
4. Add API call wrapper for Supabase
5. Test all customer flows
6. Test all vendor flows
7. Create log analysis tools

---

**Congratulations!** You now have comprehensive user flow logging. Check your terminal to debug issues and understand user behavior.
