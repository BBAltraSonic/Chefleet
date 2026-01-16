import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/greeting_helper.dart';
import '../../auth/blocs/auth_bloc.dart';

/// Personalized header widget with greeting and user avatar
class PersonalizedHeader extends StatelessWidget {
  const PersonalizedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Get user name
        String? userName;
        String? userPhotoUrl;
        
        if (authState.isAuthenticated && authState.user != null) {
          // Try to get name from user metadata
          final metadata = authState.user!.userMetadata;
          userName = metadata?['name'] as String? ?? 
                    metadata?['full_name'] as String? ??
                    authState.user!.email?.split('@').first;
          userPhotoUrl = metadata?['avatar_url'] as String?;
        }

        final greeting = GreetingHelper.getPersonalizedGreeting(userName);
        final subtitle = GreetingHelper.getSubtitle();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Row(
            children: [
              // Avatar with online indicator - tappable to open profile
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.go(CustomerRoutes.profile),
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: userPhotoUrl != null
                              ? NetworkImage(userPhotoUrl)
                              : null,
                          child: userPhotoUrl == null
                              ? Icon(
                                  authState.isGuest
                                      ? Icons.person_outline_rounded
                                      : Icons.person_rounded,
                                  color: Colors.grey[400],
                                  size: 28,
                                )
                              : null,
                        ),
                        // Online indicator (only for authenticated users)
                        if (authState.isAuthenticated && !authState.isGuest)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor, // Green indicator
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Greeting text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937), // Dark grey
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
