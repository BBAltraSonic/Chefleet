import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_role.dart';
import '../blocs/role_bloc.dart';

/// Manages FCM (Firebase Cloud Messaging) tokens with role awareness.
///
/// This service:
/// - Registers FCM tokens with Supabase backend
/// - Tags tokens with active user role
/// - Updates tokens when role changes
/// - Handles token refresh
/// - Manages token lifecycle
///
/// Usage:
/// ```dart
/// final manager = FCMTokenManager(
///   firebaseMessaging: FirebaseMessaging.instance,
///   supabase: Supabase.instance.client,
///   roleBloc: roleBloc,
/// );
/// await manager.initialize();
/// ```
class FCMTokenManager {
  FCMTokenManager({
    required FirebaseMessaging firebaseMessaging,
    required SupabaseClient supabase,
    required RoleBloc roleBloc,
  })  : _firebaseMessaging = firebaseMessaging,
        _supabase = supabase,
        _roleBloc = roleBloc;

  final FirebaseMessaging _firebaseMessaging;
  final SupabaseClient _supabase;
  final RoleBloc _roleBloc;

  String? _currentToken;
  UserRole? _currentRole;
  StreamSubscription<UserRole>? _roleSubscription;
  StreamSubscription<String>? _tokenSubscription;

  /// Initializes the FCM token manager.
  Future<void> initialize() async {
    print('Initializing FCM token manager...');

    // Get current role
    _currentRole = _roleBloc.currentRole;

    // Request notification permissions
    await _requestPermissions();

    // Get initial token
    await _refreshToken();

    // Listen to token refresh
    _tokenSubscription = _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);

    // Listen to role changes
    _roleSubscription = _roleBloc.roleChanges.listen(_onRoleChanged);

    print('FCM token manager initialized');
  }

  /// Requests notification permissions from the user.
  Future<void> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permissions');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional notification permissions');
      } else {
        print('User declined notification permissions');
      }
    } catch (e) {
      print('Error requesting notification permissions: $e');
    }
  }

  /// Refreshes the FCM token and registers it with backend.
  Future<void> _refreshToken() async {
    try {
      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      
      if (token == null) {
        print('Failed to get FCM token');
        return;
      }

      print('Got FCM token: ${token.substring(0, 20)}...');
      _currentToken = token;

      // Register token with backend
      await _registerToken(token);
    } catch (e) {
      print('Error refreshing FCM token: $e');
    }
  }

  /// Registers the FCM token with Supabase backend.
  Future<void> _registerToken(String token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('Cannot register token: user not authenticated');
        return;
      }

      final role = _currentRole ?? UserRole.customer;

      print('Registering FCM token for user $userId with role $role');

      // Upsert token in database
      await _supabase.from('fcm_tokens').upsert({
        'user_id': userId,
        'token': token,
        'active_role': role.value,
        'platform': _getPlatform(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'token');

      print('FCM token registered successfully');
    } catch (e) {
      print('Error registering FCM token: $e');
      rethrow;
    }
  }

  /// Updates the role associated with the current token.
  Future<void> _updateTokenRole(UserRole newRole) async {
    if (_currentToken == null) {
      print('Cannot update token role: no token available');
      return;
    }

    try {
      print('Updating FCM token role to: $newRole');

      await _supabase.from('fcm_tokens').update({
        'active_role': newRole.value,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('token', _currentToken!);

      print('FCM token role updated successfully');
    } catch (e) {
      print('Error updating FCM token role: $e');
    }
  }

  /// Handles FCM token refresh events.
  Future<void> _onTokenRefresh(String newToken) async {
    print('FCM token refreshed');
    _currentToken = newToken;
    await _registerToken(newToken);
  }

  /// Handles role change events.
  Future<void> _onRoleChanged(UserRole newRole) async {
    print('Role changed to $newRole, updating FCM token...');
    _currentRole = newRole;
    await _updateTokenRole(newRole);
  }

  /// Deletes the current FCM token from backend.
  Future<void> deleteToken() async {
    if (_currentToken == null) {
      print('No token to delete');
      return;
    }

    try {
      print('Deleting FCM token...');

      // Delete from backend
      await _supabase.from('fcm_tokens').delete().eq('token', _currentToken!);

      // Delete from Firebase
      await _firebaseMessaging.deleteToken();

      _currentToken = null;
      print('FCM token deleted successfully');
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
  }

  /// Gets the current platform identifier.
  String _getPlatform() {
    // This is a simplified version. In production, use Platform.isIOS, Platform.isAndroid, etc.
    return 'mobile';
  }

  /// Gets the current FCM token.
  String? get currentToken => _currentToken;

  /// Checks if notifications are enabled.
  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Opens app notification settings.
  Future<void> openNotificationSettings() async {
    await _firebaseMessaging.requestPermission();
  }

  /// Disposes the FCM token manager and cleans up resources.
  Future<void> dispose() async {
    print('Disposing FCM token manager...');
    
    await _roleSubscription?.cancel();
    await _tokenSubscription?.cancel();
    
    print('FCM token manager disposed');
  }
}

/// Service for sending push notifications (backend use).
class FCMNotificationService {
  FCMNotificationService({
    required SupabaseClient supabase,
  }) : _supabase = supabase;

  final SupabaseClient _supabase;

  /// Sends a notification to a user in a specific role.
  Future<void> sendNotificationToUser({
    required String userId,
    required UserRole targetRole,
    required String title,
    required String body,
    required String type,
    required String route,
    Map<String, dynamic>? params,
  }) async {
    try {
      // Get user's FCM tokens for the target role
      final response = await _supabase
          .from('fcm_tokens')
          .select('token')
          .eq('user_id', userId)
          .eq('active_role', targetRole.value);

      final tokens = (response as List).map((row) => row['token'] as String).toList();

      if (tokens.isEmpty) {
        print('No FCM tokens found for user $userId with role $targetRole');
        return;
      }

      // Build notification payload
      final payload = {
        'title': title,
        'body': body,
        'type': type,
        'target_role': targetRole.value,
        'route': route,
        if (params != null) 'params': params,
      };

      // Call edge function to send notifications
      await _supabase.functions.invoke(
        'send-push-notification',
        body: {
          'tokens': tokens,
          'notification': payload,
        },
      );

      print('Notification sent to ${tokens.length} device(s)');
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  /// Sends a notification to all users with a specific role.
  Future<void> sendBroadcastNotification({
    required UserRole targetRole,
    required String title,
    required String body,
    required String type,
    required String route,
    Map<String, dynamic>? params,
  }) async {
    try {
      // Get all FCM tokens for the target role
      final response = await _supabase
          .from('fcm_tokens')
          .select('token')
          .eq('active_role', targetRole.value);

      final tokens = (response as List).map((row) => row['token'] as String).toList();

      if (tokens.isEmpty) {
        print('No FCM tokens found for role $targetRole');
        return;
      }

      // Build notification payload
      final payload = {
        'title': title,
        'body': body,
        'type': type,
        'target_role': targetRole.value,
        'route': route,
        if (params != null) 'params': params,
      };

      // Send in batches of 500 (FCM limit)
      const batchSize = 500;
      for (var i = 0; i < tokens.length; i += batchSize) {
        final batch = tokens.skip(i).take(batchSize).toList();
        
        await _supabase.functions.invoke(
          'send-push-notification',
          body: {
            'tokens': batch,
            'notification': payload,
          },
        );
      }

      print('Broadcast notification sent to ${tokens.length} device(s)');
    } catch (e) {
      print('Error sending broadcast notification: $e');
      rethrow;
    }
  }
}

/// Exception thrown when FCM operations fail.
class FCMException implements Exception {
  FCMException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'FCMException: $message${code != null ? ' (code: $code)' : ''}';
}
