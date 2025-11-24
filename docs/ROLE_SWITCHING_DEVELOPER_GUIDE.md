# Role Switching Developer Guide

## Overview

This guide provides technical implementation details for developers working with the role switching system in Chefleet.

## Table of Contents

1. [File Structure](#file-structure)
2. [Core Services](#core-services)
3. [State Management](#state-management)
4. [Routing](#routing)
5. [Testing](#testing)
6. [Code Examples](#code-examples)

---

## File Structure

```
lib/
├── core/
│   ├── models/
│   │   ├── user_role.dart                    # Role enum
│   │   └── user_profile.dart                 # User profile with roles
│   ├── services/
│   │   ├── role_service.dart                 # Main role service interface
│   │   ├── role_storage_service.dart         # Local persistence
│   │   ├── role_sync_service.dart            # Backend sync
│   │   ├── role_restoration_service.dart     # Startup restoration
│   │   └── realtime_subscription_manager.dart # Realtime management
│   ├── blocs/
│   │   ├── role_bloc.dart                    # Role state management
│   │   ├── role_event.dart                   # Role events
│   │   └── role_state.dart                   # Role states
│   ├── routes/
│   │   ├── app_routes.dart                   # Route definitions
│   │   ├── app_router.dart                   # GoRouter config
│   │   ├── role_route_guard.dart             # Route protection
│   │   └── deep_link_handler.dart            # Deep link routing
│   ├── widgets/
│   │   └── role_shell_switcher.dart          # Shell switcher
│   └── app_root.dart                         # App root widget
├── features/
│   ├── customer/
│   │   ├── customer_app_shell.dart           # Customer navigation shell
│   │   └── [customer features]
│   ├── vendor/
│   │   ├── vendor_app_shell.dart             # Vendor navigation shell
│   │   ├── screens/
│   │   │   ├── vendor_dashboard_screen.dart
│   │   │   ├── vendor_orders_screen.dart
│   │   │   └── vendor_dishes_screen.dart
│   │   ├── widgets/
│   │   └── blocs/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── role_selection_screen.dart    # Role selection on signup
│   │   │   └── vendor_onboarding_screen.dart # Vendor setup
│   ├── profile/
│   │   ├── screens/
│   │   │   └── profile_screen.dart           # Profile with role switcher
│   │   └── widgets/
│   │       ├── role_switcher_widget.dart     # Role switcher UI
│   │       └── role_switch_dialog.dart       # Confirmation dialog
│   └── shared/
│       └── widgets/
│           └── role_indicator.dart           # Role badge
└── main.dart

test/
├── core/
│   ├── blocs/
│   │   └── role_bloc_test.dart
│   ├── services/
│   │   ├── role_service_test.dart
│   │   ├── role_storage_service_test.dart
│   │   └── role_restoration_service_test.dart
│   └── routes/
│       └── role_route_guard_test.dart
└── features/
    └── profile/
        └── widgets/
            └── role_switcher_test.dart

integration_test/
├── role_switching_flow_test.dart
└── role_switching_realtime_test.dart
```

---

## Core Services

### RoleService

Main interface for role operations:

```dart
abstract class RoleService {
  /// Get the currently active role
  Future<UserRole> getActiveRole();
  
  /// Switch to a new role
  Future<void> switchRole(UserRole newRole);
  
  /// Get all roles available to the user
  Future<Set<UserRole>> getAvailableRoles(String userId);
  
  /// Stream of role changes
  Stream<UserRole> get roleChanges;
}
```

### RoleStorageService

Handles local persistence:

```dart
class RoleStorageService {
  final FlutterSecureStorage _storage;
  
  Future<void> saveActiveRole(UserRole role);
  Future<UserRole?> getActiveRole();
  Future<void> clearActiveRole();
}
```

### RoleSyncService

Syncs with backend:

```dart
class RoleSyncService {
  final SupabaseClient _supabase;
  
  Future<void> syncRole(UserRole role, String userId);
  Future<UserRole> fetchRoleFromBackend(String userId);
}
```

---

## State Management

### RoleBloc

```dart
class RoleBloc extends Bloc<RoleEvent, RoleState> {
  final RoleStorageService _storageService;
  final RoleSyncService _syncService;
  final AuthBloc _authBloc;
  
  RoleBloc({
    required RoleStorageService storageService,
    required RoleSyncService syncService,
    required AuthBloc authBloc,
  })  : _storageService = storageService,
        _syncService = syncService,
        _authBloc = authBloc,
        super(RoleInitial()) {
    on<RoleRequested>(_onRoleRequested);
    on<RoleSwitchRequested>(_onRoleSwitchRequested);
    on<RoleRestored>(_onRoleRestored);
    on<AvailableRolesRequested>(_onAvailableRolesRequested);
  }
  
  Future<void> _onRoleSwitchRequested(
    RoleSwitchRequested event,
    Emitter<RoleState> emit,
  ) async {
    try {
      emit(RoleSwitching());
      
      // Optimistic update
      await _storageService.saveActiveRole(event.newRole);
      
      // Sync to backend
      final userId = _authBloc.currentUser?.id;
      if (userId != null) {
        await _syncService.syncRole(event.newRole, userId);
      }
      
      emit(RoleSwitched(event.newRole));
    } catch (e) {
      emit(RoleError(e.toString()));
    }
  }
}
```

---

## Routing

### Route Guards

```dart
String? roleGuard(BuildContext context, GoRouterState state, UserRole requiredRole) {
  final roleBloc = context.read<RoleBloc>();
  
  if (roleBloc.state is RoleLoaded) {
    final activeRole = (roleBloc.state as RoleLoaded).activeRole;
    
    if (activeRole != requiredRole) {
      // Redirect to appropriate home
      return requiredRole == UserRole.customer 
          ? '/customer/feed' 
          : '/vendor/dashboard';
    }
  }
  
  return null; // Allow access
}
```

### Adding Routes

**Customer Route:**
```dart
GoRoute(
  path: '/customer/new-feature',
  builder: (context, state) => const NewFeatureScreen(),
  redirect: (context, state) => roleGuard(context, state, UserRole.customer),
)
```

**Vendor Route:**
```dart
GoRoute(
  path: '/vendor/new-feature',
  builder: (context, state) => const NewFeatureScreen(),
  redirect: (context, state) => roleGuard(context, state, UserRole.vendor),
)
```

---

## Testing

### Unit Tests

```dart
blocTest<RoleBloc, RoleState>(
  'switches role successfully',
  build: () => RoleBloc(
    storageService: mockStorageService,
    syncService: mockSyncService,
    authBloc: mockAuthBloc,
  ),
  act: (bloc) => bloc.add(RoleSwitchRequested(UserRole.vendor)),
  expect: () => [
    RoleSwitching(),
    RoleSwitched(UserRole.vendor),
  ],
);
```

### Widget Tests

```dart
testWidgets('shows role switcher for multi-role users', (tester) async {
  when(() => mockRoleBloc.state).thenReturn(
    RoleLoaded(
      UserRole.customer,
      {UserRole.customer, UserRole.vendor},
    ),
  );
  
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<RoleBloc>.value(
        value: mockRoleBloc,
        child: ProfileScreen(),
      ),
    ),
  );
  
  expect(find.byType(RoleSwitcherWidget), findsOneWidget);
});
```

---

## Code Examples

### Checking Active Role

```dart
final roleBloc = context.read<RoleBloc>();
if (roleBloc.state is RoleLoaded) {
  final activeRole = (roleBloc.state as RoleLoaded).activeRole;
  
  if (activeRole.isVendor) {
    // Vendor-specific code
  }
}
```

### Listening to Role Changes

```dart
BlocListener<RoleBloc, RoleState>(
  listener: (context, state) {
    if (state is RoleSwitched) {
      // Refresh data for new role
      context.read<DataBloc>().add(LoadData());
    }
  },
  child: YourWidget(),
)
```

### Role-Aware Repository

```dart
class OrderRepository {
  final RoleBloc _roleBloc;
  final SupabaseClient _supabase;
  
  Future<List<Order>> getOrders() async {
    final state = _roleBloc.state;
    
    if (state is RoleLoaded) {
      if (state.activeRole.isCustomer) {
        return _getCustomerOrders();
      } else {
        return _getVendorOrders();
      }
    }
    
    throw Exception('Role not loaded');
  }
}
```

---

**Last Updated:** 2025-01-24  
**Version:** 1.0.0
