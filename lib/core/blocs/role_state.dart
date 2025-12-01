import 'package:equatable/equatable.dart';
import '../models/user_role.dart';

/// Base class for all role-related states.
abstract class RoleState extends Equatable {
  const RoleState();

  @override
  List<Object?> get props => [];
}

/// Initial state before role is loaded.
class RoleInitial extends RoleState {
  const RoleInitial();
}

/// State when role is being loaded from storage/backend.
class RoleLoading extends RoleState {
  const RoleLoading();
}

/// State when role is successfully loaded.
///
/// Contains:
/// - [activeRole]: The currently active role
/// - [availableRoles]: Set of roles the user can switch between
class RoleLoaded extends RoleState {
  const RoleLoaded({
    required this.activeRole,
    required this.availableRoles,
  });

  final UserRole activeRole;
  final Set<UserRole> availableRoles;

  /// Checks if the user has multiple roles available.
  bool get hasMultipleRoles => availableRoles.length > 1;

  /// Checks if the user has vendor role available.
  bool get hasVendorRole => availableRoles.contains(UserRole.vendor);

  /// Checks if the user can switch to a specific role.
  bool canSwitchTo(UserRole role) => availableRoles.contains(role) && role != activeRole;

  @override
  List<Object?> get props => [activeRole, availableRoles];

  /// Creates a copy with updated fields.
  RoleLoaded copyWith({
    UserRole? activeRole,
    Set<UserRole>? availableRoles,
  }) {
    return RoleLoaded(
      activeRole: activeRole ?? this.activeRole,
      availableRoles: availableRoles ?? this.availableRoles,
    );
  }
}

/// State when role is being switched.
///
/// Shows loading UI during the switch operation.
class RoleSwitching extends RoleState {
  const RoleSwitching({
    required this.fromRole,
    required this.toRole,
  });

  final UserRole fromRole;
  final UserRole toRole;

  @override
  List<Object?> get props => [fromRole, toRole];
}

/// State when role has been successfully switched.
///
/// Contains:
/// - [newRole]: The newly activated role
/// - [availableRoles]: Updated set of available roles
class RoleSwitched extends RoleState {
  const RoleSwitched({
    required this.newRole,
    required this.availableRoles,
  });

  final UserRole newRole;
  final Set<UserRole> availableRoles;

  @override
  List<Object?> get props => [newRole, availableRoles];
}

/// State when a role operation fails.
///
/// Contains:
/// - [message]: Human-readable error message
/// - [code]: Optional error code for programmatic handling
/// - [previousState]: The state before the error occurred
class RoleError extends RoleState {
  const RoleError({
    required this.message,
    this.code,
    this.previousState,
  });

  final String message;
  final String? code;
  final RoleState? previousState;

  @override
  List<Object?> get props => [message, code, previousState];
}

/// State when role sync is in progress.
///
/// Used for background sync operations that don't block UI.
class RoleSyncing extends RoleLoaded {
  const RoleSyncing({
    required super.activeRole,
    required super.availableRoles,
  });
}

/// State when vendor role is being granted.
///
/// Shows loading UI during vendor role grant operation.
class VendorRoleGranting extends RoleState {
  const VendorRoleGranting();
}

/// State when vendor role has been successfully granted.
///
/// Contains:
/// - [activeRole]: The current active role (may be vendor if switched)
/// - [availableRoles]: Updated set including vendor role
class VendorRoleGranted extends RoleLoaded {
  const VendorRoleGranted({
    required super.activeRole,
    required super.availableRoles,
  });
}

/// State when user needs to select a role (new user flow).
class RoleSelectionRequired extends RoleState {
  const RoleSelectionRequired();
}
