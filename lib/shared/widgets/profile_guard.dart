import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/blocs/user_profile_bloc.dart';
import '../../features/auth/screens/profile_creation_screen.dart';

class ProfileGuard extends StatelessWidget {
  final Widget child;
  final bool requireProfile;

  const ProfileGuard({
    super.key,
    required this.child,
    this.requireProfile = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        // Show loading while checking profile
        if (state.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        // If profile is required and user doesn't have one, show profile creation
        if (requireProfile && state.profile.isEmpty) {
          return const ProfileCreationScreen();
        }

        // Allow access to the protected route
        return child;
      },
    );
  }
}