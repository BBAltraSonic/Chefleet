import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/blocs/auth_bloc.dart';
import '../widgets/main_app_shell.dart';
import '../../features/auth/screens/auth_screen.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle navigation based on auth state
        if (state.isAuthenticated) {
          // User is authenticated, show main app
        } else {
          // User is not authenticated, show auth screen
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.isAuthenticated) {
            return const MainAppShell();
          } else {
            return BlocProvider(
              create: (context) => AuthBloc(),
              child: const AuthScreen(),
            );
          }
        },
      ),
    );
  }
}