/// Enum representing the different roles a user can have in the Chefleet app.
///
/// Users can have multiple roles available but only one active at a time.
/// The active role determines which app experience (customer or vendor) is shown.
enum UserRole {
  /// Customer role - for users who order food
  customer,

  /// Vendor role - for users who sell food
  vendor;

  /// Returns a human-readable display name for the role
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.vendor:
        return 'Vendor';
    }
  }

  /// Returns a lowercase string representation for database storage
  String get value => name;

  /// Checks if this role is customer
  bool get isCustomer => this == UserRole.customer;

  /// Checks if this role is vendor
  bool get isVendor => this == UserRole.vendor;

  /// Creates a UserRole from a string value
  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'vendor':
        return UserRole.vendor;
      default:
        throw ArgumentError('Invalid user role: $value');
    }
  }

  /// Safely parses a string to UserRole, returning null if invalid
  static UserRole? tryFromString(String? value) {
    if (value == null) return null;
    try {
      return fromString(value);
    } catch (_) {
      return null;
    }
  }
}

/// Extension to convert a list of string values to UserRole set
extension UserRoleListExtension on List<String> {
  /// Converts a list of role strings to a Set of UserRole enums
  Set<UserRole> toUserRoles() {
    return map((roleString) => UserRole.tryFromString(roleString))
        .whereType<UserRole>()
        .toSet();
  }
}

/// Extension to convert a Set of UserRole to list of strings
extension UserRoleSetExtension on Set<UserRole> {
  /// Converts a Set of UserRole enums to a list of strings
  List<String> toStringList() {
    return map((role) => role.value).toList();
  }
}
