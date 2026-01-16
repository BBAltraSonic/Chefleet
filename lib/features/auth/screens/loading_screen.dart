import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/auth_loading_state.dart';
import '../widgets/auth_error_display.dart';
import '../models/auth_error_type.dart';

/// Dedicated loading screen shown during state transitions.
///
/// This screen is distinct from SplashScreen:
/// - SplashScreen: Initial bootstrap only
/// - LoadingScreen: Transient loading states during navigation
///
/// This prevents circular redirect loops where loading states
/// would redirect back to splash, triggering re-bootstrap.
class LoadingScreen extends StatefulWidget {
  final String? message;
  
  const LoadingScreen({
    super.key,
    this.message,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _hasTimedOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.surfaceGreen.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: _hasTimedOut 
              ? _buildTimeoutError() 
              : AuthLoadingState(
                  message: widget.message ?? "Loading...",
                  timeoutSeconds: 30,
                  onTimeout: () {
                    if (mounted) {
                      setState(() {
                        _hasTimedOut = true;
                      });
                    }
                  },
                  onCancel: () {
                     // If user cancels, go back or to auth
                     if (context.canPop()) {
                       context.pop();
                     } else {
                       context.go('/auth');
                     }
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildTimeoutError() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AuthErrorDisplay(
            type: AuthErrorType.networkError, // Assume network/timeout issue
            customMessage: "This is taking too long. Please check your connection or try again.",
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/auth');
                  }
                },
                child: const Text("Go Back"),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // Reset state to try again (reload)
                  setState(() {
                    _hasTimedOut = false;
                  });
                },
                child: const Text("Wait Longer"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
