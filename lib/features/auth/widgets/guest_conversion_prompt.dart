import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/guest_conversion_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';
import '../blocs/auth_bloc.dart';
import '../screens/guest_conversion_screen.dart';

/// Prompt widget to encourage guest users to convert to registered accounts
/// 
/// Can be displayed in various contexts throughout the app
class GuestConversionPrompt extends StatelessWidget {
  const GuestConversionPrompt({
    super.key,
    this.context = ConversionPromptContext.general,
    this.onDismiss,
  });

  final ConversionPromptContext context;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Only show for guest users
        if (!state.isGuest || state.guestId == null) {
          return const SizedBox.shrink();
        }

        return _buildPrompt(context);
      },
    );
  }

  Widget _buildPrompt(BuildContext context) {
    final promptData = _getPromptData();

    return GlassContainer(
      margin: const EdgeInsets.all(AppTheme.spacing16),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      borderRadius: AppTheme.radiusLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  promptData.icon,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  promptData.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            promptData.message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDismiss,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.borderGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                  ),
                  child: const Text('Later'),
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _showConversionScreen(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Create Account'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PromptData _getPromptData() {
    switch (context) {
      case ConversionPromptContext.afterOrder:
        return const PromptData(
          icon: Icons.shopping_bag_outlined,
          title: 'Save Your Order',
          message:
              'Create an account to track your order and access your history.',
        );
      case ConversionPromptContext.afterChat:
        return const PromptData(
          icon: Icons.chat_bubble_outline,
          title: 'Continue Chatting',
          message:
              'Create an account to keep your conversations and get notifications.',
        );
      case ConversionPromptContext.profile:
        return const PromptData(
          icon: Icons.account_circle_outlined,
          title: 'Unlock All Features',
          message:
              'Create an account to save favorites, track orders, and more.',
        );
      case ConversionPromptContext.general:
        return const PromptData(
          icon: Icons.star_outline,
          title: 'Get More from Chefleet',
          message:
              'Create a free account to unlock all features and save your progress.',
        );
    }
  }

  Future<void> _showConversionScreen(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    final guestId = authState.guestId;

    if (guestId == null) return;

    // Get guest session stats
    final conversionService = GuestConversionService();
    final stats = await conversionService.getGuestSessionStats(guestId);

    if (!context.mounted) return;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => GuestConversionScreen(
          guestId: guestId,
          stats: stats,
          onSkip: () => Navigator.of(context).pop(false),
        ),
        fullscreenDialog: true,
      ),
    );

    // If conversion was successful, dismiss the prompt
    if (result == true && onDismiss != null) {
      onDismiss!();
    }
  }
}

/// Compact banner version of the conversion prompt
class GuestConversionBanner extends StatelessWidget {
  const GuestConversionBanner({
    super.key,
    this.onDismiss,
  });

  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Only show for guest users
        if (!state.isGuest || state.guestId == null) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing8,
          ),
          padding: const EdgeInsets.all(AppTheme.spacing12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryGreen.withOpacity(0.1),
                AppTheme.surfaceGreen,
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: AppTheme.borderGreen,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.account_circle_outlined,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create an account',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      'Save your progress and unlock features',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacing8),
              TextButton(
                onPressed: () => _showConversionScreen(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                ),
                child: const Text('Sign Up'),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onDismiss,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showConversionScreen(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    final guestId = authState.guestId;

    if (guestId == null) return;

    // Get guest session stats
    final conversionService = GuestConversionService();
    final stats = await conversionService.getGuestSessionStats(guestId);

    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GuestConversionScreen(
          guestId: guestId,
          stats: stats,
          onSkip: () => Navigator.of(context).pop(),
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

/// Bottom sheet version of the conversion prompt
class GuestConversionBottomSheet extends StatelessWidget {
  const GuestConversionBottomSheet({
    super.key,
    required this.guestId,
    this.stats,
  });

  final String guestId;
  final GuestSessionStats? stats;

  static Future<void> show(
    BuildContext context, {
    required String guestId,
    GuestSessionStats? stats,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GuestConversionBottomSheet(
        guestId: guestId,
        stats: stats,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),

              // Icon
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: const Icon(
                  Icons.account_circle_outlined,
                  size: 32,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Title
              Text(
                'Save Your Progress',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppTheme.spacing8),

              // Description
              Text(
                'Create a free account to keep your orders, messages, and preferences.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.secondaryGreen,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing24),

              // Stats
              if (stats != null && stats!.hasActivity) ...[
                Row(
                  children: [
                    if (stats!.orderCount > 0)
                      _buildStatChip(
                        context,
                        '${stats!.orderCount} ${stats!.orderCount == 1 ? "order" : "orders"}',
                      ),
                    if (stats!.orderCount > 0 && stats!.messageCount > 0)
                      const SizedBox(width: AppTheme.spacing8),
                    if (stats!.messageCount > 0)
                      _buildStatChip(
                        context,
                        '${stats!.messageCount} ${stats!.messageCount == 1 ? "message" : "messages"}',
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing24),
              ],

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.borderGreen),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      child: const Text('Not Now'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GuestConversionScreen(
                              guestId: guestId,
                              stats: stats,
                            ),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Create Account'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreen,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// Context for where the conversion prompt is being shown
enum ConversionPromptContext {
  general,
  afterOrder,
  afterChat,
  profile,
}

/// Data for a conversion prompt
class PromptData {
  const PromptData({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}
