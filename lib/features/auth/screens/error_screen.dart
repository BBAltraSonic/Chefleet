import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/exceptions/app_exceptions.dart';

/// Global error screen for navigation and routing errors.
///
/// Provides a recovery UI when navigation fails, allowing users to:
/// - See what went wrong
/// - Return to a safe location (home)
/// - View technical details (in debug mode)
///
/// This is part of Phase 6: Error Boundaries implementation.
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    this.error,
    this.errorMessage,
  });

  final NavigationException? error;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final displayMessage = error?.message ?? errorMessage ?? 'An unexpected error occurred';
    final route = error?.route;
    final showDetails = error != null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.surfaceGreen.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Error Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.shade50,
                      border: Border.all(
                        color: Colors.red.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    'Navigation Error',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Error Message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      displayMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red.shade900,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  // Route details (if available)
                  if (showDetails && route != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.borderGreen,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.route,
                            size: 16,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Route: $route',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.secondaryColor,
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      // Return Home
                      ElevatedButton.icon(
                        onPressed: () {
                          try {
                            context.go('/splash');
                          } catch (e) {
                            if (context.canPop()) context.pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: AppTheme.darkText,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.home, size: 20),
                        label: const Text('Return Home'),
                      ),

                      // Back to Login
                      OutlinedButton.icon(
                        onPressed: () => context.go('/auth'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.darkText,
                          side: BorderSide(color: AppTheme.darkText.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.login, size: 20),
                        label: const Text('Back to Login'),
                      ),

                      // Get Help
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Need Help?'),
                              content: const Text('Please contact support at support@chefleet.com if this issue persists.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.secondaryColor,
                        ),
                        icon: const Icon(Icons.help_outline, size: 20),
                        label: const Text('Get Help'),
                      ),
                    ],
                  ),
                  
                  // Debug info (only in debug mode)
                  if (showDetails && error?.stackTrace != null) ...[
                    const SizedBox(height: 24),
                    ExpansionTile(
                      title: Text(
                        'Technical Details',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            error!.stackTrace.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
