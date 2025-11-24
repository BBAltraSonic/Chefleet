import '../models/user_role.dart';

/// Abstract service interface for managing user roles.
///
/// This service handles:
/// - Getting the current active role
/// - Switching between available roles
/// - Fetching available roles for a user
/// - Streaming role changes
///
/// Implementations should coordinate between local storage and backend sync.
abstract class RoleService {
  /// Gets the currently active role for the user.
  ///
  /// Returns the active role from local storage/cache.
  /// Throws [RoleException] if no role is found or user is not authenticated.
  Future<UserRole> getActiveRole();

  /// Switches the user's active role to [newRole].
  ///
  /// This will:
  /// 1. Validate that [newRole] is in the user's available roles
  /// 2. Update local storage
  /// 3. Sync with backend
  /// 4. Emit role change event
  ///
  /// Throws [RoleException] if:
  /// - User doesn't have access to [newRole]
  /// - Backend sync fails (will retry in background)
  /// - User is not authenticated
  Future<void> switchRole(UserRole newRole);

  /// Gets the set of roles available to the user with [userId].
  ///
  /// Returns a set of roles the user can switch between.
  /// Most users will have {customer}, some will have {customer, vendor}.
  ///
  /// Throws [RoleException] if user is not found.
  Future<Set<UserRole>> getAvailableRoles(String userId);

  /// Stream that emits whenever the active role changes.
  ///
  /// Listeners can react to role changes to update UI, subscriptions, etc.
  /// The stream emits the new active role immediately after a switch.
  Stream<UserRole> get roleChanges;

  /// Checks if the user has a specific role available.
  ///
  /// Returns true if [role] is in the user's available roles.
  Future<bool> hasRole(String userId, UserRole role);

  /// Grants vendor role to the current user.
  ///
  /// This is typically called after vendor onboarding is complete.
  /// It adds vendor to available roles and optionally switches to it.
  ///
  /// Parameters:
  /// - [vendorProfileId]: ID of the created vendor profile
  /// - [switchToVendor]: If true, immediately switch to vendor mode
  Future<void> grantVendorRole({
    required String vendorProfileId,
    bool switchToVendor = true,
  });
}

/// Exception thrown when role operations fail.
class RoleException implements Exception {
  const RoleException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() => 'RoleException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Specific role exception types for better error handling
class RoleNotAvailableException extends RoleException {
  RoleNotAvailableException(UserRole role)
      : super('Role ${role.displayName} is not available for this user', 'ROLE_NOT_AVAILABLE');
}

class RoleNotAuthenticatedException extends RoleException {
  const RoleNotAuthenticatedException()
      : super('User must be authenticated to access roles', 'NOT_AUTHENTICATED');
}

class RoleSyncException extends RoleException {
  const RoleSyncException([String? details])
      : super('Failed to sync role with backend${details != null ? ': $details' : ''}', 'SYNC_FAILED');
}
