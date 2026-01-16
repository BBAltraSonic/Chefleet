import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_role.dart';
import '../../features/auth/models/user_profile_model.dart';
import 'role_service.dart';

/// Service for synchronizing user role data with Supabase backend.
///
/// This service handles:
/// - Syncing active role to backend
/// - Fetching role data from backend
/// - Handling sync conflicts (backend always wins)
/// - Retry logic for failed syncs
/// - Offline queue for pending syncs
///
/// Works in conjunction with RoleStorageService for local persistence.
class RoleSyncService {
  RoleSyncService({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  // Queue for pending sync operations when offline
  final List<_PendingSyncOperation> _syncQueue = [];
  Timer? _retryTimer;

  /// Syncs the active role to the backend.
  ///
  /// Updates the profiles table with the new active role.
  /// Throws [RoleSyncException] if sync fails and user is online.
  /// Queues operation for retry if user is offline.
  Future<void> syncActiveRole(UserRole role) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const RoleNotAuthenticatedException();
    }

    try {
      await _supabase.from('users_public').update({
        'role': role.value,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);
    } catch (e) {
      // Queue for retry if network error
      if (_isNetworkError(e)) {
        _queueSync(_PendingSyncOperation(
          userId: userId,
          role: role,
          timestamp: DateTime.now(),
        ));
        _scheduleRetry();
      } else {
        throw RoleSyncException(e.toString());
      }
    }
  }

  /// Fetches the user's role data from the backend.
  ///
  /// Returns a tuple of (activeRole, availableRoles).
  /// activeRole may be null if the user hasn't selected a role yet.
  /// Throws [RoleSyncException] if fetch fails.
  Future<(UserRole?, Set<UserRole>)> fetchRoleData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const RoleNotAuthenticatedException();
    }

    try {
      final response = await _supabase
          .from('users_public')
          .select('role, vendor_profile_id')
          .eq('user_id', userId)
          .maybeSingle(); // Use maybeSingle to handle new users without profile

      // No profile exists yet - new user needs to create profile
      if (response == null) {
        return (null, {UserRole.customer});
      }

      final activeRoleString = response['role'] as String?;
      final activeRole = UserRole.tryFromString(activeRoleString);

      // Derive available roles
      final availableRoles = {UserRole.customer};
      if (response['vendor_profile_id'] != null || activeRole == UserRole.vendor) {
        availableRoles.add(UserRole.vendor);
      }

      return (activeRole, availableRoles);
    } catch (e) {
      throw RoleSyncException('Failed to fetch role data: ${e.toString()}');
    }
  }

  /// Fetches the complete user profile including role data.
  ///
  /// Returns UserProfile or null if not found.
  Future<UserProfile?> fetchUserProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const RoleNotAuthenticatedException();
    }

    try {
      final response = await _supabase
          .from('users_public')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserProfile.fromJson(response);
    } catch (e) {
      throw RoleSyncException('Failed to fetch user profile: ${e.toString()}');
    }
  }

  /// Grants vendor role to the current user.
  ///
  /// Updates the available_roles array to include 'vendor'.
  /// Also updates the vendor_profile_id if provided.
  Future<void> grantVendorRole({String? vendorProfileId}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const RoleNotAuthenticatedException();
    }

    try {
      // Update with new roles (just update vendor_profile_id in new schema)
      final updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (vendorProfileId != null) {
        updateData['vendor_profile_id'] = vendorProfileId;
      }

      await _supabase.from('users_public').update(updateData).eq('user_id', userId);
    } catch (e) {
      throw RoleSyncException('Failed to grant vendor role: ${e.toString()}');
    }
  }

  /// Revokes vendor role from the current user.
  ///
  /// Removes 'vendor' from available_roles array.
  /// If user was in vendor mode, switches them to customer mode.
  Future<void> revokeVendorRole() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const RoleNotAuthenticatedException();
    }

    try {
      // Fetch current data
      final response = await _supabase
          .from('users_public')
          .select('role')
          .eq('user_id', userId)
          .single();

      final currentActiveRole =
          UserRole.tryFromString(response['role'] as String?) ?? UserRole.customer;

      // If currently in vendor mode, switch to customer
      final newActiveRole =
          currentActiveRole == UserRole.vendor ? UserRole.customer : currentActiveRole;

      await _supabase.from('users_public').update({
        'role': newActiveRole.value,
        'vendor_profile_id': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);
    } catch (e) {
      throw RoleSyncException('Failed to revoke vendor role: ${e.toString()}');
    }
  }

  /// Processes the sync queue, retrying failed operations.
  ///
  /// Called automatically by retry timer.
  Future<void> processSyncQueue() async {
    if (_syncQueue.isEmpty) return;

    final operations = List<_PendingSyncOperation>.from(_syncQueue);
    _syncQueue.clear();

    for (final operation in operations) {
      try {
        await _supabase.from('users_public').update({
          'role': operation.role.value,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', operation.userId);
      } catch (e) {
        // Re-queue if still failing
        if (_isNetworkError(e)) {
          _syncQueue.add(operation);
        }
      }
    }

    // Schedule another retry if queue is not empty
    if (_syncQueue.isNotEmpty) {
      _scheduleRetry();
    }
  }

  /// Clears the sync queue.
  ///
  /// Useful when user logs out.
  void clearSyncQueue() {
    _syncQueue.clear();
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// Checks if there are pending sync operations.
  bool hasPendingSyncs() => _syncQueue.isNotEmpty;

  /// Disposes resources.
  void dispose() {
    _retryTimer?.cancel();
    _syncQueue.clear();
  }

  // Private helper methods

  void _queueSync(_PendingSyncOperation operation) {
    // Avoid duplicate operations for same user
    _syncQueue.removeWhere((op) => op.userId == operation.userId);
    _syncQueue.add(operation);
  }

  void _scheduleRetry() {
    // Cancel existing timer
    _retryTimer?.cancel();

    // Retry after 30 seconds
    _retryTimer = Timer(const Duration(seconds: 30), () {
      processSyncQueue();
    });
  }

  bool _isNetworkError(dynamic error) {
    // Check if error is network-related
    if (error is PostgrestException) {
      // Network errors typically don't have a code
      return error.code == null || error.code!.isEmpty;
    }
    return error.toString().toLowerCase().contains('network') ||
        error.toString().toLowerCase().contains('connection') ||
        error.toString().toLowerCase().contains('timeout');
  }
}

/// Internal class representing a pending sync operation.
class _PendingSyncOperation {
  const _PendingSyncOperation({
    required this.userId,
    required this.role,
    required this.timestamp,
  });

  final String userId;
  final UserRole role;
  final DateTime timestamp;
}
