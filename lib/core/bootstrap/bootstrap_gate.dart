import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';
import '../blocs/role_bloc.dart';
import '../../features/auth/blocs/auth_bloc.dart';
import 'bootstrap_orchestrator.dart';
import 'bootstrap_result.dart';

/// Minimal gate widget that blocks rendering until bootstrap completes.
///
/// This widget:
/// - Shows minimal branded UI (centered logo + spinner)
/// - Runs bootstrap orchestrator to resolve auth state
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
    _runBootstrap();
  }

  Future<void> _runBootstrap() async {
    if (!mounted) return;

    final orchestrator = BootstrapOrchestrator();
    final authBloc = context.read<AuthBloc>();
    final roleBloc = context.read<RoleBloc>();

    try {
      final result = await orchestrator.initialize(
        authBloc: authBloc,
        roleBloc: roleBloc,
      );

      if (!mounted) return;

      setState(() {
        _result = result;
        _isBootstrapping = false;
      });

      // Notify parent that bootstrap is complete
      widget.onBootstrapComplete(result);
    } catch (e) {
      // On error, still complete bootstrap but with auth screen as fallback
      if (!mounted) return;

      setState(() {
        _result = const BootstrapResult(initialRoute: '/auth');
        _isBootstrapping = false;
      });

      widget.onBootstrapComplete(_result!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isBootstrapping) {
      // Show minimal branded loader while bootstrapping
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
              ],
            ),
          ),
        ),
      );
    }

    // Bootstrap complete - render child
    return widget.child;
  }
}





