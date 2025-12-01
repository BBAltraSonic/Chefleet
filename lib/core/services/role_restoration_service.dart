import '../models/user_role.dart';
import 'role_storage_service.dart';
import 'role_sync_service.dart';

/// Service for restoring user role state during app initialization.
///
/// This service handles the complex logic of:
/// - Restoring role from local storage
/// - Validating against backend data
/// - Resolving conflicts (backend wins)
/// - Handling offline scenarios
/// - Ensuring consistent state before app renders
///
/// Should be called early in app initialization, before building the app root.
class RoleRestorationService {
  RoleRestorationService({
    required RoleStorageService storageService,
    required RoleSyncService syncService,
  })  : _storageService = storageService,
        _syncService = syncService;

  final RoleStorageService _storageService;
  final RoleSyncService _syncService;

  /// Restores the user's role state during app startup.
  ///
  /// Returns a [RoleRestorationResult] containing:
  /// - The active role to use (nullable)
  /// - Available roles
  /// - Whether restoration was successful
  /// - Any errors encountered
  ///
  /// Strategy:
  /// 1. Try to read from local storage (fast)
  /// 2. Try to fetch from backend (authoritative)
  /// 3. If backend differs, use backend and update local
  /// 4. If offline, use local storage
  /// 5. If nothing available, default to customer
  Future<RoleRestorationResult> restoreRole() async {
    try {
      // Step 1: Preload cache for fast access
      await _storageService.preloadCache();

      // Step 2: Get local data
      final localActiveRole = await _storageService.getActiveRole();
      final localAvailableRoles = await _storageService.getAvailableRoles();

      // Step 3: Try to fetch from backend
      try {
        final (backendActiveRole, backendAvailableRoles) = await _syncService.fetchRoleData();

        // Step 4: Check for conflicts
        final hasConflict = localActiveRole != null &&
            localActiveRole != backendActiveRole;

        if (hasConflict) {
          // Backend wins - update local storage
          if (backendActiveRole != null) {
            await _storageService.saveActiveRole(backendActiveRole);
          }
          await _storageService.saveAvailableRoles(backendAvailableRoles);

          return RoleRestorationResult(
            activeRole: backendActiveRole,
            availableRoles: backendAvailableRoles,
            source: RoleRestorationSource.backendConflictResolved,
            hadConflict: true,
          );
        }

        // No conflict - use backend data and update local if needed
        if (localActiveRole == null || localAvailableRoles == null) {
          if (backendActiveRole != null) {
            await _storageService.saveActiveRole(backendActiveRole);
          }
          await _storageService.saveAvailableRoles(backendAvailableRoles);
        }

        return RoleRestorationResult(
          activeRole: backendActiveRole,
          availableRoles: backendAvailableRoles,
          source: RoleRestorationSource.backend,
        );
      } catch (backendError) {
        // Backend fetch failed - use local storage if available
        if (localActiveRole != null && localAvailableRoles != null) {
          return RoleRestorationResult(
            activeRole: localActiveRole,
            availableRoles: localAvailableRoles,
            source: RoleRestorationSource.localStorage,
            error: backendError.toString(),
          );
        }

        // No local data either - use defaults
        final defaultRole = UserRole.customer;
        final defaultRoles = {UserRole.customer};

        await _storageService.saveActiveRole(defaultRole);
        await _storageService.saveAvailableRoles(defaultRoles);

        return RoleRestorationResult(
          activeRole: defaultRole,
          availableRoles: defaultRoles,
          source: RoleRestorationSource.defaultFallback,
          error: backendError.toString(),
        );
      }
    } catch (e) {
      // Complete failure - return safe defaults
      return RoleRestorationResult(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer},
        source: RoleRestorationSource.defaultFallback,
        error: e.toString(),
      );
    }
  }

  /// Validates that the active role is in the available roles.
  ///
  /// If not, switches to customer role and updates storage.
  /// Returns the validated active role.
  Future<UserRole> validateAndCorrectRole(
    UserRole activeRole,
    Set<UserRole> availableRoles,
  ) async {
    if (!availableRoles.contains(activeRole)) {
      // Active role is not available - switch to customer
      final correctedRole = UserRole.customer;

      await _storageService.saveActiveRole(correctedRole);

      // Try to sync to backend (don't wait)
      _syncService.syncActiveRole(correctedRole).catchError((e) {
        // Sync will retry later if it fails
        print('Failed to sync corrected role: $e');
      });

      return correctedRole;
    }

    return activeRole;
  }

  /// Performs a background sync after restoration.
  ///
  /// This ensures local and backend are in sync without blocking app startup.
  /// Should be called after the app has rendered.
  Future<void> backgroundSync(UserRole activeRole) async {
    try {
      await _syncService.syncActiveRole(activeRole);
    } catch (e) {
      // Sync will retry later via queue
      print('Background sync failed: $e');
    }
  }

  /// Clears all role data (called on logout).
  Future<void> clearRoleData() async {
    await _storageService.clearRoleData();
    _syncService.clearSyncQueue();
  }
}

/// Result of role restoration operation.
class RoleRestorationResult {
  const RoleRestorationResult({
    required this.activeRole,
    required this.availableRoles,
    required this.source,
    this.hadConflict = false,
    this.error,
  });

  /// The active role to use
  final UserRole? activeRole;

  /// Available roles for the user
  final Set<UserRole> availableRoles;

  /// Where the role data came from
  final RoleRestorationSource source;

  /// Whether there was a conflict between local and backend
  final bool hadConflict;

  /// Any error that occurred during restoration
  final String? error;

  /// Whether restoration was completely successful
  bool get isSuccess => error == null;

  /// Whether restoration used fallback defaults
  bool get usedDefaults => source == RoleRestorationSource.defaultFallback;

  /// Whether restoration came from backend (most reliable)
  bool get isFromBackend =>
      source == RoleRestorationSource.backend ||
      source == RoleRestorationSource.backendConflictResolved;
}

/// Source of restored role data.
enum RoleRestorationSource {
  /// Data came from backend (most reliable)
  backend,

  /// Data came from local storage (offline mode)
  localStorage,

  /// Backend had different data, conflict was resolved
  backendConflictResolved,

  /// Used default values (no data available)
  defaultFallback,
}
