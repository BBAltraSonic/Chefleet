import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/role_bloc.dart';
import 'blocs/role_state.dart';
import 'blocs/role_event.dart';
import 'models/user_role.dart';
import 'widgets/role_shell_switcher.dart';
import '../features/auth/blocs/auth_bloc.dart' as auth;
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/auth_screen.dart';

/// Root widget that manages authentication and role-based app shell switching.
///
/// This widget coordinates:
/// 1. Authentication state checking
/// 2. Role loading after authentication
/// 3. App shell switching based on role
///
/// Flow:
/// - Unauthenticated -> Show auth screen
/// - Authenticated but no role -> Load role from backend
/// - Authenticated with role -> Show appropriate shell
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _hasRequestedRole = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<auth.AuthBloc, auth.AuthState>(
      listener: (context, authState) {
        print('DEBUG AppRoot: Auth state changed - mode: ${authState.mode}, isAuth: ${authState.isAuthenticated}, isLoading: ${authState.isLoading}');
        
        // Only authenticated users should request role data from backend
        // Guest users get default role without backend fetch
        if (authState.isAuthenticated && !_hasRequestedRole) {
          print('DEBUG AppRoot: Requesting role data for authenticated user');
          _hasRequestedRole = true;
          context.read<RoleBloc>().add(const RoleRequested());
        }
        // Reset flag when user logs out
        if (authState.mode == auth.AuthMode.unauthenticated) {
          print('DEBUG AppRoot: User logged out, resetting role request flag');
          _hasRequestedRole = false;
        }
      },
      child: BlocBuilder<auth.AuthBloc, auth.AuthState>(
        builder: (context, authState) {
          print('DEBUG AppRoot: Building with auth state - mode: ${authState.mode}, isLoading: ${authState.isLoading}');
          
          // Show splash while checking auth
          if (authState.isLoading) {
            print('DEBUG AppRoot: Showing splash (auth loading)');
            return const SplashScreen();
          }

          // User not authenticated - show auth screen
          if (authState.mode == auth.AuthMode.unauthenticated) {
            print('DEBUG AppRoot: Showing auth screen (unauthenticated)');
            return const AuthScreen();
          }

          // Guest user - show customer shell directly without role fetch
          if (authState.mode == auth.AuthMode.guest) {
            print('DEBUG AppRoot: Showing customer shell for guest user');
            return RoleShellSwitcher(
              activeRole: UserRole.customer,
              availableRoles: {UserRole.customer},
            );
          }

          // Authenticated user - load role from backend
          return BlocBuilder<RoleBloc, RoleState>(
            builder: (context, roleState) {
              print('DEBUG AppRoot: Building with role state: ${roleState.runtimeType}');
              
              // Show splash screen while role is loading (only on first load)
              if (roleState is RoleLoading || roleState is RoleInitial) {
                print('DEBUG AppRoot: Showing splash (role loading/initial)');
                return const SplashScreen();
              }

            // Show splash screen while switching roles
            if (roleState is RoleSwitching) {
              print('DEBUG AppRoot: Showing splash (role switching)');
              return const SplashScreen();
            }

            // Show error screen if role loading failed
            if (roleState is RoleError) {
              print('DEBUG AppRoot: Showing error screen');
              return _RoleErrorScreen(
                message: roleState.message,
                onRetry: () {
                  print('DEBUG AppRoot: User clicked retry');
                  _hasRequestedRole = false;
                  context.read<RoleBloc>().add(const RoleRequested());
                },
              );
            }

            // Show the appropriate shell based on active role
            if (roleState is RoleLoaded) {
              return RoleShellSwitcher(
                activeRole: roleState.activeRole,
                availableRoles: roleState.availableRoles,
              );
            }

            // Fallback to splash screen for any other state
            return const SplashScreen();
          },
        );
        },
      ),
    );
  }
}

/// Error screen displayed when role loading fails.
class _RoleErrorScreen extends StatelessWidget {
  const _RoleErrorScreen({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Failed to Load Role',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
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
    );
  }
}
