import 'package:equatable/equatable.dart';
import '../models/user_role.dart';

/// Base class for all role-related events.
abstract class RoleEvent extends Equatable {
  const RoleEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request the current active role.
///
/// Triggers loading of the active role from storage/backend.
class RoleRequested extends RoleEvent {
  const RoleRequested();
}

/// Event to request switching to a new role.
///
/// Parameters:
/// - [newRole]: The role to switch to
/// - [skipConfirmation]: If true, skip confirmation dialog (for testing)
class RoleSwitchRequested extends RoleEvent {
  const RoleSwitchRequested({
    required this.newRole,
    this.skipConfirmation = false,
  });

  final UserRole newRole;
  final bool skipConfirmation;

  @override
  List<Object?> get props => [newRole, skipConfirmation];
}

/// Event to restore role from storage on app startup.
///
/// Parameters:
/// - [role]: The role to restore
class RoleRestored extends RoleEvent {
  const RoleRestored(this.role);

  final UserRole role;

  @override
  List<Object?> get props => [role];
}

/// Event when user selects their initial role (from RoleSelectionScreen).
class InitialRoleSelected extends RoleEvent {
  const InitialRoleSelected(this.role);

  final UserRole role;

  @override
  List<Object?> get props => [role];
}

/// Event to request the user's available roles.
///
/// Fetches the set of roles the user can switch between.
class AvailableRolesRequested extends RoleEvent {
  const AvailableRolesRequested();
}

/// Event to refresh role data from backend.
///
/// Forces a sync with the backend to get latest role data.
class RoleRefreshRequested extends RoleEvent {
  const RoleRefreshRequested();
}

/// Event to grant vendor role to the user.
///
/// Parameters:
/// - [vendorProfileId]: ID of the created vendor profile
/// - [switchToVendor]: If true, immediately switch to vendor mode
class GrantVendorRole extends RoleEvent {
  const GrantVendorRole({
    required this.vendorProfileId,
    this.switchToVendor = true,
  });

  final String vendorProfileId;
  final bool switchToVendor;

  @override
  List<Object?> get props => [vendorProfileId, switchToVendor];
}

/// Event to handle role sync completion.
///
/// Internal event emitted after successful backend sync.
class RoleSyncCompleted extends RoleEvent {
  const RoleSyncCompleted(this.role);

  final UserRole role;

  @override
  List<Object?> get props => [role];
}

/// Event to handle role sync failure.
///
/// Internal event emitted when backend sync fails.
class RoleSyncFailed extends RoleEvent {
  const RoleSyncFailed(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
