import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_role.dart';

/// Service for persisting user role data locally using secure storage.
///
/// This service handles:
/// - Saving active role to secure storage
/// - Reading active role from secure storage
/// - Caching role in memory for fast synchronous access
/// - Clearing role data on logout
///
/// Uses flutter_secure_storage for encrypted local persistence.
class RoleStorageService {
  RoleStorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  // Storage keys
  static const String _activeRoleKey = 'user_active_role';
  static const String _availableRolesKey = 'user_available_roles';

  // In-memory cache for fast synchronous access
  UserRole? _cachedActiveRole;
  Set<UserRole>? _cachedAvailableRoles;

  /// Saves the active role to secure storage and updates cache.
  ///
  /// Returns true if save was successful.
  Future<bool> saveActiveRole(UserRole role) async {
    try {
      await _secureStorage.write(
        key: _activeRoleKey,
        value: role.value,
      );
      _cachedActiveRole = role;
      return true;
    } catch (e) {
      // Log error but don't throw - storage failures shouldn't crash the app
      print('Error saving active role: $e');
      return false;
    }
  }

  /// Reads the active role from secure storage.
  ///
  /// Returns cached value if available, otherwise reads from storage.
  /// Returns null if no role is stored or if read fails.
  Future<UserRole?> getActiveRole() async {
    // Return cached value if available
    if (_cachedActiveRole != null) {
      return _cachedActiveRole;
    }

    try {
      final roleString = await _secureStorage.read(key: _activeRoleKey);
      if (roleString != null) {
        _cachedActiveRole = UserRole.tryFromString(roleString);
        return _cachedActiveRole;
      }
      return null;
    } catch (e) {
      print('Error reading active role: $e');
      return null;
    }
  }

  /// Gets the active role synchronously from cache.
  ///
  /// Returns null if cache is not populated.
  /// Call [getActiveRole] first to populate cache.
  UserRole? getActiveRoleSync() {
    return _cachedActiveRole;
  }

  /// Saves the set of available roles to secure storage.
  ///
  /// Returns true if save was successful.
  Future<bool> saveAvailableRoles(Set<UserRole> roles) async {
    try {
      final roleStrings = roles.toStringList().join(',');
      await _secureStorage.write(
        key: _availableRolesKey,
        value: roleStrings,
      );
      _cachedAvailableRoles = roles;
      return true;
    } catch (e) {
      print('Error saving available roles: $e');
      return false;
    }
  }

  /// Reads the available roles from secure storage.
  ///
  /// Returns cached value if available, otherwise reads from storage.
  /// Returns null if no roles are stored or if read fails.
  Future<Set<UserRole>?> getAvailableRoles() async {
    // Return cached value if available
    if (_cachedAvailableRoles != null) {
      return _cachedAvailableRoles;
    }

    try {
      final rolesString = await _secureStorage.read(key: _availableRolesKey);
      if (rolesString != null && rolesString.isNotEmpty) {
        final roleList = rolesString.split(',');
        _cachedAvailableRoles = roleList.toUserRoles();
        return _cachedAvailableRoles;
      }
      return null;
    } catch (e) {
      print('Error reading available roles: $e');
      return null;
    }
  }

  /// Gets the available roles synchronously from cache.
  ///
  /// Returns null if cache is not populated.
  /// Call [getAvailableRoles] first to populate cache.
  Set<UserRole>? getAvailableRolesSync() {
    return _cachedAvailableRoles;
  }

  /// Clears all role data from storage and cache.
  ///
  /// Should be called on logout.
  Future<void> clearRoleData() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _activeRoleKey),
        _secureStorage.delete(key: _availableRolesKey),
      ]);
      _cachedActiveRole = null;
      _cachedAvailableRoles = null;
    } catch (e) {
      print('Error clearing role data: $e');
      // Still clear cache even if storage delete fails
      _cachedActiveRole = null;
      _cachedAvailableRoles = null;
    }
  }

  /// Checks if role data exists in storage.
  ///
  /// Returns true if active role is stored.
  Future<bool> hasStoredRole() async {
    try {
      final roleString = await _secureStorage.read(key: _activeRoleKey);
      return roleString != null && roleString.isNotEmpty;
    } catch (e) {
      print('Error checking stored role: $e');
      return false;
    }
  }

  /// Preloads role data into cache for fast synchronous access.
  ///
  /// Should be called during app initialization.
  Future<void> preloadCache() async {
    await Future.wait([
      getActiveRole(),
      getAvailableRoles(),
    ]);
  }

  /// Clears only the in-memory cache without affecting storage.
  ///
  /// Useful for testing or forcing a fresh read from storage.
  void clearCache() {
    _cachedActiveRole = null;
    _cachedAvailableRoles = null;
  }
}
