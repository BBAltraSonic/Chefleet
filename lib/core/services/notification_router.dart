import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/user_role.dart';
import '../blocs/role_bloc.dart';
import '../routes/app_routes.dart';

/// Routes push notifications to the appropriate screen based on user role.
///
/// This service:
/// - Parses notification payloads
/// - Determines target role and route
/// - Switches role if needed (with user consent)
/// - Navigates to the target screen
///
/// Usage:
/// ```dart
/// final router = NotificationRouter(
///   roleBloc: roleBloc,
///   goRouter: goRouter,
/// );
/// await router.handleNotification(notificationData);
/// ```
class NotificationRouter {
  NotificationRouter({
    required RoleBloc roleBloc,
    required GoRouter goRouter,
  })  : _roleBloc = roleBloc,
        _goRouter = goRouter;

  final RoleBloc _roleBloc;
  final GoRouter _goRouter;

  /// Handles an incoming notification and routes to the appropriate screen.
  ///
  /// Returns true if navigation was successful, false otherwise.
  Future<bool> handleNotification(
    Map<String, dynamic> notificationData, {
    BuildContext? context,
  }) async {
    try {
      // Parse notification data
      final notification = _parseNotification(notificationData);
      
      if (notification == null) {
        print('Failed to parse notification data');
        return false;
      }

      print('Handling notification: ${notification.type} for role: ${notification.targetRole}');

      // Check if user has the required role
      final availableRoles = _roleBloc.availableRoles;
      if (availableRoles == null || !availableRoles.contains(notification.targetRole)) {
        print('User does not have required role: ${notification.targetRole}');
        _showRoleNotAvailableDialog(context, notification.targetRole);
        return false;
      }

      // Check if role switch is needed
      final currentRole = _roleBloc.currentRole;
      if (currentRole != notification.targetRole) {
        // Ask user for consent to switch roles
        final shouldSwitch = await _requestRoleSwitchConsent(
          context,
          currentRole!,
          notification.targetRole,
        );

        if (!shouldSwitch) {
          print('User declined role switch');
          return false;
        }

        // Switch role
        await _switchRole(notification.targetRole);
      }

      // Navigate to target route
      await _navigateToRoute(notification);

      return true;
    } catch (e) {
      print('Error handling notification: $e');
      return false;
    }
  }

  /// Parses notification data into a structured format.
  NotificationData? _parseNotification(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String?;
      final targetRole = data['target_role'] as String?;
      final route = data['route'] as String?;
      final params = data['params'] as Map<String, dynamic>?;

      if (type == null || targetRole == null || route == null) {
        return null;
      }

      return NotificationData(
        type: type,
        targetRole: UserRole.fromString(targetRole),
        route: route,
        params: params ?? {},
        title: data['title'] as String?,
        body: data['body'] as String?,
      );
    } catch (e) {
      print('Error parsing notification: $e');
      return null;
    }
  }

  /// Requests user consent to switch roles.
  Future<bool> _requestRoleSwitchConsent(
    BuildContext? context,
    UserRole currentRole,
    UserRole targetRole,
  ) async {
    if (context == null || !context.mounted) {
      // No context available, switch without consent
      return true;
    }

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Role'),
        content: Text(
          'This notification is for your ${targetRole.displayName} account. '
          'Would you like to switch from ${currentRole.displayName} to ${targetRole.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Switch'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Switches to the specified role.
  Future<void> _switchRole(UserRole targetRole) async {
    final completer = Completer<void>();

    // Listen for role switch completion
    final subscription = _roleBloc.stream.listen((state) {
      if (state is RoleLoaded && state.activeRole == targetRole) {
        completer.complete();
      } else if (state is RoleError) {
        completer.completeError(state.message);
      }
    });

    // Request role switch
    _roleBloc.add(RoleSwitchRequested(targetRole));

    // Wait for completion with timeout
    try {
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Role switch timed out');
        },
      );
    } finally {
      await subscription.cancel();
    }
  }

  /// Navigates to the target route based on notification data.
  Future<void> _navigateToRoute(NotificationData notification) async {
    // Add a small delay to ensure role switch UI has settled
    await Future.delayed(const Duration(milliseconds: 300));

    // Build the full route path with parameters
    final routePath = _buildRoutePath(notification);

    print('Navigating to: $routePath');
    _goRouter.go(routePath);
  }

  /// Builds the full route path with query parameters.
  String _buildRoutePath(NotificationData notification) {
    final uri = Uri.parse(notification.route);
    
    // Merge notification params with existing query params
    final queryParams = Map<String, String>.from(uri.queryParameters);
    notification.params.forEach((key, value) {
      queryParams[key] = value.toString();
    });

    // Rebuild URI with all params
    final newUri = uri.replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    
    return newUri.toString();
  }

  /// Shows a dialog when user doesn't have the required role.
  void _showRoleNotAvailableDialog(BuildContext? context, UserRole requiredRole) {
    if (context == null || !context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Role Not Available'),
        content: Text(
          'This notification requires a ${requiredRole.displayName} account, '
          'but you don\'t have access to this role.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Handles notification when app is in foreground.
  Future<void> handleForegroundNotification(
    Map<String, dynamic> notificationData, {
    BuildContext? context,
  }) async {
    // Show in-app notification banner
    if (context != null && context.mounted) {
      final notification = _parseNotification(notificationData);
      if (notification != null) {
        _showInAppNotification(context, notification);
      }
    }
  }

  /// Shows an in-app notification banner.
  void _showInAppNotification(BuildContext context, NotificationData notification) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.title != null)
              Text(
                notification.title!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (notification.body != null)
              Text(notification.body!),
          ],
        ),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            handleNotification(notification.toMap(), context: context);
          },
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Gets the appropriate route for a notification type.
  static String getRouteForNotificationType(
    String type,
    UserRole role, {
    Map<String, String>? params,
  }) {
    switch (type) {
      case 'new_order':
        // Vendors receive new order notifications, customers see their own orders
        return role.isVendor
            ? VendorRoutes.orders
            : CustomerRoutes.orders;
      
      case 'order_status_update':
        final orderId = params?['order_id'];
        if (orderId == null) {
          return role.isCustomer ? CustomerRoutes.orders : VendorRoutes.orders;
        }
        return role.isCustomer
            ? CustomerRoutes.orderDetail(orderId)
            : VendorRoutes.orderDetailWithId(orderId);
      
      case 'new_message':
        final chatId = params?['chat_id'];
        if (chatId == null) {
          return role.isCustomer ? CustomerRoutes.chat : VendorRoutes.chat;
        }
        return role.isCustomer
            ? CustomerRoutes.chatDetail(chatId)
            : VendorRoutes.chatDetail(chatId);
      
      case 'dish_update':
        final dishId = params?['dish_id'];
        if (dishId == null) {
          return role.isVendor ? VendorRoutes.dishes : CustomerRoutes.map;
        }
        return role.isVendor
            ? VendorRoutes.dishEditWithId(dishId)
            : CustomerRoutes.dishDetail(dishId);
      
      case 'vendor_application_status':
        return role.isVendor
            ? VendorRoutes.dashboard
            : VendorRoutes.onboarding;
      
      case 'vendor_moderation':
        return VendorRoutes.moderation;
      
      default:
        return role.isCustomer
            ? CustomerRoutes.map
            : VendorRoutes.dashboard;
    }
  }
}

/// Structured notification data.
class NotificationData {
  NotificationData({
    required this.type,
    required this.targetRole,
    required this.route,
    required this.params,
    this.title,
    this.body,
  });

  final String type;
  final UserRole targetRole;
  final String route;
  final Map<String, dynamic> params;
  final String? title;
  final String? body;

  /// Converts notification data back to a map.
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'target_role': targetRole.value,
      'route': route,
      'params': params,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
    };
  }

  @override
  String toString() {
    return 'NotificationData(type: $type, targetRole: $targetRole, route: $route)';
  }
}

/// Exception thrown when notification routing fails.
class NotificationRoutingException implements Exception {
  NotificationRoutingException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'NotificationRoutingException: $message${code != null ? ' (code: $code)' : ''}';
}
