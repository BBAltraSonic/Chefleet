import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(
            children: [
              // Avatar with online indicator
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: userPhotoUrl != null
                        ? NetworkImage(userPhotoUrl)
                        : null,
                    child: userPhotoUrl == null
                        ? Icon(
                            authState.isGuest
                                ? Icons.person_outline
                                : Icons.person,
                            color: Colors.grey[600],
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
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // Green indicator
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Greeting text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
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
