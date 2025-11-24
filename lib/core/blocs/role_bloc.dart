import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user_role.dart';
import '../services/role_storage_service.dart';
import '../services/role_sync_service.dart';
import '../services/role_service.dart';
import 'role_event.dart';
import 'role_state.dart';

/// BLoC for managing user role state and role switching.
///
/// This BLoC coordinates between:
/// - Local storage (RoleStorageService) for persistence
/// - Backend sync (RoleSyncService) for server-side state
/// - UI state management
///
/// Key responsibilities:
/// - Load and restore active role on app startup
/// - Handle role switching with optimistic updates
/// - Sync role changes with backend
/// - Emit role change events for listeners
/// - Handle errors gracefully with rollback
class RoleBloc extends Bloc<RoleEvent, RoleState> {
  RoleBloc({
    required RoleStorageService storageService,
    required RoleSyncService syncService,
  })  : _storageService = storageService,
        _syncService = syncService,
        super(const RoleInitial()) {
    // Register event handlers
    on<RoleRequested>(_onRoleRequested);
    on<RoleSwitchRequested>(_onRoleSwitchRequested);
    on<RoleRestored>(_onRoleRestored);
    on<AvailableRolesRequested>(_onAvailableRolesRequested);
    on<RoleRefreshRequested>(_onRoleRefreshRequested);
    on<GrantVendorRole>(_onVendorRoleGranted);
    on<RoleSyncCompleted>(_onRoleSyncCompleted);
    on<RoleSyncFailed>(_onRoleSyncFailed);
  }

  final RoleStorageService _storageService;
  final RoleSyncService _syncService;

  // Stream controller for role changes
  final _roleChangesController = StreamController<UserRole>.broadcast();

  /// Stream that emits whenever the active role changes.
  Stream<UserRole> get roleChanges => _roleChangesController.stream;

  /// Gets the current active role synchronously.
  ///
  /// Returns null if role is not loaded yet.
  UserRole? get currentRole {
    final currentState = state;
    if (currentState is RoleLoaded) {
      return currentState.activeRole;
    }
    return null;
  }

  /// Gets the available roles synchronously.
  ///
  /// Returns null if roles are not loaded yet.
  Set<UserRole>? get availableRoles {
    final currentState = state;
    if (currentState is RoleLoaded) {
      return currentState.availableRoles;
    }
    return null;
  }

  /// Handles RoleRequested event.
  ///
  /// Loads the active role from storage and backend.
  Future<void> _onRoleRequested(
    RoleRequested event,
    Emitter<RoleState> emit,
  ) async {
    emit(const RoleLoading());

    try {
      // First, try to load from local storage for fast startup
      final cachedRole = await _storageService.getActiveRole();
      final cachedAvailableRoles = await _storageService.getAvailableRoles();

      if (cachedRole != null && cachedAvailableRoles != null) {
        // Emit cached data immediately
        emit(RoleLoaded(
          activeRole: cachedRole,
          availableRoles: cachedAvailableRoles,
        ));

        // Then sync with backend in background
        _syncWithBackend(emit);
      } else {
        // No cached data, fetch from backend
        final (activeRole, availableRoles) = await _syncService.fetchRoleData();

        // Save to storage
        await _storageService.saveActiveRole(activeRole);
        await _storageService.saveAvailableRoles(availableRoles);

        emit(RoleLoaded(
          activeRole: activeRole,
          availableRoles: availableRoles,
        ));
      }
    } on RoleNotAuthenticatedException catch (e) {
      emit(RoleError(
        message: 'User not authenticated',
        code: 'NOT_AUTHENTICATED',
        previousState: state,
      ));
    } on RoleSyncException catch (e) {
      // If we have cached data, use it despite sync failure
      final cachedRole = await _storageService.getActiveRole();
      final cachedAvailableRoles = await _storageService.getAvailableRoles();

      if (cachedRole != null && cachedAvailableRoles != null) {
        emit(RoleLoaded(
          activeRole: cachedRole,
          availableRoles: cachedAvailableRoles,
        ));
      } else {
        emit(RoleError(
          message: e.message,
          code: e.code,
          previousState: state,
        ));
      }
    } catch (e) {
      emit(RoleError(
        message: 'Failed to load role: ${e.toString()}',
        previousState: state,
      ));
    }
  }

  /// Handles RoleSwitchRequested event.
  ///
  /// Switches to the new role with optimistic update and backend sync.
  Future<void> _onRoleSwitchRequested(
    RoleSwitchRequested event,
    Emitter<RoleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RoleLoaded) {
      emit(const RoleError(
        message: 'Cannot switch role: role not loaded',
        code: 'ROLE_NOT_LOADED',
      ));
      return;
    }

    // Validate that the new role is available
    if (!currentState.availableRoles.contains(event.newRole)) {
      emit(RoleError(
        message: 'Role ${event.newRole.displayName} is not available',
        code: 'ROLE_NOT_AVAILABLE',
        previousState: currentState,
      ));
      return;
    }

    // Don't switch if already in that role
    if (currentState.activeRole == event.newRole) {
      return;
    }

    // Emit switching state
    emit(RoleSwitching(
      fromRole: currentState.activeRole,
      toRole: event.newRole,
    ));

    try {
      // Optimistic update: save to local storage first
      await _storageService.saveActiveRole(event.newRole);

      // Emit switched state immediately for responsive UI
      emit(RoleSwitched(
        newRole: event.newRole,
        availableRoles: currentState.availableRoles,
      ));

      // Then emit loaded state
      emit(RoleLoaded(
        activeRole: event.newRole,
        availableRoles: currentState.availableRoles,
      ));

      // Emit role change event
      _roleChangesController.add(event.newRole);

      // Sync with backend in background
      try {
        await _syncService.syncActiveRole(event.newRole);
      } catch (e) {
        // Backend sync failed, but local state is updated
        // The sync service will retry in background
        print('Role sync failed, will retry: $e');
      }
    } catch (e) {
      // Rollback to previous role
      await _storageService.saveActiveRole(currentState.activeRole);

      emit(RoleError(
        message: 'Failed to switch role: ${e.toString()}',
        previousState: currentState,
      ));

      // Restore previous state
      emit(currentState);
    }
  }

  /// Handles RoleRestored event.
  ///
  /// Restores a role from storage on app startup.
  Future<void> _onRoleRestored(
    RoleRestored event,
    Emitter<RoleState> emit,
  ) async {
    try {
      // Get available roles from storage
      final availableRoles = await _storageService.getAvailableRoles() ?? {UserRole.customer};

      // Validate that restored role is available
      if (!availableRoles.contains(event.role)) {
        // Fallback to customer if restored role is not available
        emit(RoleLoaded(
          activeRole: UserRole.customer,
          availableRoles: availableRoles,
        ));
        return;
      }

      emit(RoleLoaded(
        activeRole: event.role,
        availableRoles: availableRoles,
      ));

      // Sync with backend in background
      _syncWithBackend(emit);
    } catch (e) {
      emit(RoleError(
        message: 'Failed to restore role: ${e.toString()}',
        previousState: state,
      ));
    }
  }

  /// Handles AvailableRolesRequested event.
  ///
  /// Fetches the user's available roles from backend.
  Future<void> _onAvailableRolesRequested(
    AvailableRolesRequested event,
    Emitter<RoleState> emit,
  ) async {
    final currentState = state;

    try {
      final (activeRole, availableRoles) = await _syncService.fetchRoleData();

      // Update storage
      await _storageService.saveActiveRole(activeRole);
      await _storageService.saveAvailableRoles(availableRoles);

      emit(RoleLoaded(
        activeRole: activeRole,
        availableRoles: availableRoles,
      ));
    } catch (e) {
      emit(RoleError(
        message: 'Failed to fetch available roles: ${e.toString()}',
        previousState: currentState,
      ));

      // Restore previous state if available
      if (currentState is RoleLoaded) {
        emit(currentState);
      }
    }
  }

  /// Handles RoleRefreshRequested event.
  ///
  /// Forces a refresh of role data from backend.
  Future<void> _onRoleRefreshRequested(
    RoleRefreshRequested event,
    Emitter<RoleState> emit,
  ) async {
    final currentState = state;

    // Keep current state visible during refresh
    if (currentState is RoleLoaded) {
      emit(RoleSyncing(
        activeRole: currentState.activeRole,
        availableRoles: currentState.availableRoles,
      ));
    }

    try {
      final (activeRole, availableRoles) = await _syncService.fetchRoleData();

      // Update storage
      await _storageService.saveActiveRole(activeRole);
      await _storageService.saveAvailableRoles(availableRoles);

      emit(RoleLoaded(
        activeRole: activeRole,
        availableRoles: availableRoles,
      ));

      // If role changed on backend, emit change event
      if (currentState is RoleLoaded && currentState.activeRole != activeRole) {
        _roleChangesController.add(activeRole);
      }
    } catch (e) {
      emit(RoleError(
        message: 'Failed to refresh role data: ${e.toString()}',
        previousState: currentState,
      ));

      // Restore previous state if available
      if (currentState is RoleLoaded) {
        emit(currentState);
      }
    }
  }

  /// Handles VendorRoleGranted event.
  ///
  /// Grants vendor role to the user and optionally switches to it.
  Future<void> _onVendorRoleGranted(
    GrantVendorRole event,
    Emitter<RoleState> emit,
  ) async {
    final currentState = state;

    emit(const VendorRoleGranting());

    try {
      // Grant vendor role on backend
      await _syncService.grantVendorRole(vendorProfileId: event.vendorProfileId);

      // Fetch updated role data
      final (activeRole, availableRoles) = await _syncService.fetchRoleData();

      // Update storage
      await _storageService.saveAvailableRoles(availableRoles);

      // Switch to vendor if requested
      if (event.switchToVendor) {
        await _storageService.saveActiveRole(UserRole.vendor);
        emit(VendorRoleGranted(
          activeRole: UserRole.vendor,
          availableRoles: availableRoles,
        ));
        _roleChangesController.add(UserRole.vendor);
      } else {
        emit(VendorRoleGranted(
          activeRole: activeRole,
          availableRoles: availableRoles,
        ));
      }
    } catch (e) {
      emit(RoleError(
        message: 'Failed to grant vendor role: ${e.toString()}',
        previousState: currentState,
      ));

      // Restore previous state if available
      if (currentState is RoleLoaded) {
        emit(currentState);
      }
    }
  }

  /// Handles RoleSyncCompleted event.
  ///
  /// Updates state after successful backend sync.
  Future<void> _onRoleSyncCompleted(
    RoleSyncCompleted event,
    Emitter<RoleState> emit,
  ) async {
    // This is an internal event for future use
    // Currently, sync happens in background
  }

  /// Handles RoleSyncFailed event.
  ///
  /// Handles backend sync failures.
  Future<void> _onRoleSyncFailed(
    RoleSyncFailed event,
    Emitter<RoleState> emit,
  ) async {
    // This is an internal event for future use
    // Currently, sync failures are logged but don't affect UI
    print('Role sync failed: ${event.error}');
  }

  /// Syncs role data with backend in background.
  ///
  /// Does not emit errors to avoid disrupting UI.
  Future<void> _syncWithBackend(Emitter<RoleState> emit) async {
    try {
      final (activeRole, availableRoles) = await _syncService.fetchRoleData();

      // Update storage if data changed
      final currentState = state;
      if (currentState is RoleLoaded) {
        if (currentState.activeRole != activeRole ||
            !_setsEqual(currentState.availableRoles, availableRoles)) {
          await _storageService.saveActiveRole(activeRole);
          await _storageService.saveAvailableRoles(availableRoles);

          emit(RoleLoaded(
            activeRole: activeRole,
            availableRoles: availableRoles,
          ));

          // Emit change event if role changed
          if (currentState.activeRole != activeRole) {
            _roleChangesController.add(activeRole);
          }
        }
      }
    } catch (e) {
      // Silently fail - we already have cached data
      print('Background role sync failed: $e');
    }
  }

  /// Checks if two sets are equal.
  bool _setsEqual<T>(Set<T> set1, Set<T> set2) {
    if (set1.length != set2.length) return false;
    return set1.containsAll(set2);
  }

  @override
  Future<void> close() {
    _roleChangesController.close();
    return super.close();
  }
}
