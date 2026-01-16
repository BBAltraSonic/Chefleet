import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';
import '../blocs/role_bloc.dart';
import '../../features/auth/blocs/auth_bloc.dart';
import '../../features/auth/blocs/user_profile_bloc.dart';
import 'bootstrap_orchestrator.dart';
import 'bootstrap_result.dart';

/// Minimal gate widget that blocks rendering until bootstrap completes.
///
/// This widget:
/// - Shows minimal branded UI (centered logo + spinner)
/// - Runs bootstrap orchestrator to resolve auth, profile, and role state
/// - Shows error UI with retry capability if bootstrap fails
/// - Once complete, signals router with initial route
/// - No complex animations or delays - just fast hydration
class BootstrapGate extends StatefulWidget {
  const BootstrapGate({
    super.key,
    required this.onBootstrapComplete,
    required this.child,
  });

  /// Callback when bootstrap completes with the resolved initial route.
  final void Function(BootstrapResult result) onBootstrapComplete;

  /// The child widget to display after bootstrap completes.
  final Widget child;

  @override
  State<BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<BootstrapGate> {
  bool _isBootstrapping = true;
  BootstrapResult? _result;

  @override
  void initState() {
    super.initState();
    // Defer bootstrap to after first frame when providers are fully available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runBootstrap();
    });
  }

  Future<void> _runBootstrap() async {
    if (!mounted) return;

    final orchestrator = BootstrapOrchestrator();
    final authBloc = context.read<AuthBloc>();
    final roleBloc = context.read<RoleBloc>();
    final profileBloc = context.read<UserProfileBloc>();

    try {
      final result = await orchestrator.initialize(
        authBloc: authBloc,
        roleBloc: roleBloc,
        profileBloc: profileBloc,
      );

      if (!mounted) return;

      setState(() {
        _result = result;
        _isBootstrapping = false;
      });

      // Notify parent that bootstrap is complete (even if there's an error)
      widget.onBootstrapComplete(result);
    } catch (e) {
      // On unexpected error, create error result
      if (!mounted) return;

      final errorResult = BootstrapResult(
        initialRoute: '/auth',
        error: BootstrapError(
          message: 'Unexpected error during initialization: ${e.toString()}',
          canRetry: true,
        ),
      );

      setState(() {
        _result = errorResult;
        _isBootstrapping = false;
      });

      widget.onBootstrapComplete(errorResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isBootstrapping) {
      return _buildLoadingUI();
    }

    // Check for error state
    if (_result?.hasError == true) {
      return _buildErrorUI(_result!.error!);
    }

    // Bootstrap complete - render child
    return widget.child;
  }

  Widget _buildLoadingUI() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minimal logo (no animation)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 40,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 24),
              // Minimal spinner
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Loading text
              Text(
                'Initializing...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildErrorUI(BootstrapError error) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 24),
              const Text(
                'Startup Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                error.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (error.canRetry)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isBootstrapping = true;
                      _result = null;
                    });
                    _runBootstrap();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.darkText,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

