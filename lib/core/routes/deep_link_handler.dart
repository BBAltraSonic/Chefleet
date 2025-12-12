import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/user_role.dart';
import '../blocs/role_bloc.dart';
import '../blocs/role_event.dart';
import '../blocs/role_state.dart';
import 'app_routes.dart';

/// Handles deep links and ensures user is in the correct role.
///
/// Deep links follow the pattern:
/// - `chefleet://customer/*` - Customer role routes
/// - `chefleet://vendor/*` - Vendor role routes
/// - `https://chefleet.app/customer/*` - Customer role routes
/// - `https://chefleet.app/vendor/*` - Vendor role routes
///
/// This handler:
/// - Parses deep link URLs
/// - Extracts target role from path
/// - Switches role if needed (with user consent)
/// - Navigates to target route
/// - Shows error if user doesn't have required role
///
/// Usage:
/// ```dart
/// final handler = DeepLinkHandler(
///   roleBloc: roleBloc,
///   goRouter: goRouter,
/// );
/// await handler.handleDeepLink(uri);
/// ```
class DeepLinkHandler {
  DeepLinkHandler({
    required RoleBloc roleBloc,
    required GoRouter goRouter,
  })  : _roleBloc = roleBloc,
        _goRouter = goRouter;

  final RoleBloc _roleBloc;
  final GoRouter _goRouter;

  // Supported deep link schemes
  static const List<String> supportedSchemes = ['chefleet', 'https', 'http'];
  
  // Supported hosts for HTTPS deep links
  static const List<String> supportedHosts = [
    'chefleet.app',
    'www.chefleet.app',
    'app.chefleet.com',
  ];

  /// Handles a deep link URI.
  ///
  /// Returns true if the deep link was handled successfully, false otherwise.
  Future<bool> handleDeepLink(
    Uri uri, {
    BuildContext? context,
  }) async {
    try {
      print('Handling deep link: $uri');

      // Validate URI
      if (!_isValidDeepLink(uri)) {
        print('Invalid deep link: $uri');
        _showInvalidLinkDialog(context);
        return false;
      }

      // Parse deep link
      final deepLink = _parseDeepLink(uri);
      if (deepLink == null) {
        print('Failed to parse deep link: $uri');
        _showInvalidLinkDialog(context);
        return false;
      }

      print('Parsed deep link: role=${deepLink.targetRole}, path=${deepLink.path}');

      // Check if user has the required role
      final availableRoles = _roleBloc.availableRoles;
      if (availableRoles == null || !availableRoles.contains(deepLink.targetRole)) {
        print('User does not have required role: ${deepLink.targetRole}');
        _showRoleNotAvailableDialog(context, deepLink.targetRole);
        return false;
      }

      // Check if role switch is needed
      final currentRole = _roleBloc.currentRole;
      if (currentRole != deepLink.targetRole) {
        // Ask user for consent to switch roles
        final shouldSwitch = await _requestRoleSwitchConsent(
          context,
          currentRole!,
          deepLink.targetRole,
        );

        if (!shouldSwitch) {
          print('User declined role switch for deep link');
          return false;
        }

        // Switch role
        await _switchRole(deepLink.targetRole);
      }

      // Navigate to target path
      await _navigateToPath(deepLink);

      return true;
    } catch (e) {
      print('Error handling deep link: $e');
      _showErrorDialog(context, e.toString());
      return false;
    }
  }

  /// Validates if a URI is a supported deep link.
  bool _isValidDeepLink(Uri uri) {
    // Check scheme
    if (!supportedSchemes.contains(uri.scheme.toLowerCase())) {
      return false;
    }

    // For HTTPS/HTTP, check host
    if (uri.scheme == 'https' || uri.scheme == 'http') {
      if (!supportedHosts.contains(uri.host.toLowerCase())) {
        return false;
      }
    }

    return true;
  }

  /// Parses a deep link URI into structured data.
  DeepLinkData? _parseDeepLink(Uri uri) {
    try {
      // Extract path segments
      final segments = uri.pathSegments;
      
      if (segments.isEmpty) {
        return null;
      }

      // First segment should be the role
      final roleString = segments.first.toLowerCase();
      UserRole? targetRole;

      try {
        targetRole = UserRole.fromString(roleString);
      } catch (e) {
        // Not a valid role, might be a shared route
        return _parseSharedRoute(uri);
      }

      // Build the internal path
      final internalPath = '/${segments.join('/')}';

      return DeepLinkData(
        targetRole: targetRole,
        path: internalPath,
        queryParameters: uri.queryParameters,
      );
    } catch (e) {
      print('Error parsing deep link: $e');
      return null;
    }
  }

  /// Parses shared routes that don't require a specific role.
  DeepLinkData? _parseSharedRoute(Uri uri) {
    final path = uri.path;

    // Check if it's an auth or onboarding route
    if (path.startsWith('/auth') || path.startsWith('/onboarding')) {
      // Default to customer role for shared routes
      return DeepLinkData(
        targetRole: UserRole.customer,
        path: path,
        queryParameters: uri.queryParameters,
      );
    }

    return null;
  }

  /// Requests user consent to switch roles for deep link.
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
          'This link is for your ${targetRole.displayName} account. '
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

  /// Navigates to the target path.
  Future<void> _navigateToPath(DeepLinkData deepLink) async {
    // Add a small delay to ensure role switch UI has settled
    await Future.delayed(const Duration(milliseconds: 300));

    // Build full path with query parameters
    final uri = Uri(
      path: deepLink.path,
      queryParameters: deepLink.queryParameters.isNotEmpty
          ? deepLink.queryParameters
          : null,
    );

    print('Navigating to: ${uri.toString()}');
    _goRouter.go(uri.toString());
  }

  /// Shows dialog when user doesn't have the required role.
  void _showRoleNotAvailableDialog(BuildContext? context, UserRole requiredRole) {
    if (context == null || !context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Role Not Available'),
        content: Text(
          'This link requires a ${requiredRole.displayName} account, '
          'but you don\'t have access to this role.\n\n'
          'To access ${requiredRole.displayName} features, you need to set up a ${requiredRole.displayName} account first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (requiredRole.isVendor)
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to vendor onboarding
                _goRouter.go(VendorRoutes.onboarding);
              },
              child: const Text('Become a Vendor'),
            ),
        ],
      ),
    );
  }

  /// Shows dialog for invalid deep links.
  void _showInvalidLinkDialog(BuildContext? context) {
    if (context == null || !context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Link'),
        content: const Text(
          'This link is not valid or is not supported by Chefleet.',
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

  /// Shows generic error dialog.
  void _showErrorDialog(BuildContext? context, String error) {
    if (context == null || !context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to open link: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Generates a deep link for a given route and role.
  static Uri generateDeepLink({
    required UserRole role,
    required String path,
    Map<String, String>? queryParameters,
    bool useHttps = false,
  }) {
    if (useHttps) {
      return Uri.https(
        supportedHosts.first,
        '/${role.value}$path',
        queryParameters,
      );
    } else {
      return Uri(
        scheme: 'chefleet',
        host: role.value,
        path: path,
        queryParameters: queryParameters,
      );
    }
  }

  /// Generates a shareable HTTPS link for a given route and role.
  static String generateShareableLink({
    required UserRole role,
    required String path,
    Map<String, String>? queryParameters,
  }) {
    final uri = generateDeepLink(
      role: role,
      path: path,
      queryParameters: queryParameters,
      useHttps: true,
    );
    return uri.toString();
  }
}

/// Structured deep link data.
class DeepLinkData {
  DeepLinkData({
    required this.targetRole,
    required this.path,
    required this.queryParameters,
  });

  final UserRole targetRole;
  final String path;
  final Map<String, String> queryParameters;

  @override
  String toString() {
    return 'DeepLinkData(targetRole: $targetRole, path: $path, params: $queryParameters)';
  }
}

/// Exception thrown when deep link handling fails.
class DeepLinkException implements Exception {
  DeepLinkException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'DeepLinkException: $message${code != null ? ' (code: $code)' : ''}';
}
