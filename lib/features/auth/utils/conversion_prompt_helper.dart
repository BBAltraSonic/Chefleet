import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/guest_conversion_service.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/guest_conversion_prompt.dart';

/// Helper class for managing guest conversion prompts throughout the app
/// 
/// Provides utilities to show prompts at appropriate times based on user activity
class ConversionPromptHelper {
  ConversionPromptHelper({
    GuestConversionService? conversionService,
  }) : _conversionService = conversionService ?? GuestConversionService();

  final GuestConversionService _conversionService;

  /// Check if user should be prompted for conversion
  Future<bool> shouldShowPrompt(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;

    // Only show for guest users
    if (!authState.isGuest || authState.guestId == null) {
      return false;
    }

    // Get guest session stats
    final stats = await _conversionService.getGuestSessionStats(authState.guestId!);

    // Use service logic to determine if prompt should be shown
    return _conversionService.shouldPromptConversion(stats);
  }

  /// Show conversion prompt after order placement
  static Future<void> showAfterOrder(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;

    if (!authState.isGuest || authState.guestId == null) {
      return;
    }

    final conversionService = GuestConversionService();
    final stats = await conversionService.getGuestSessionStats(authState.guestId!);

    if (!context.mounted) return;

    // Show bottom sheet after first order
    if (stats.orderCount == 1) {
      await GuestConversionBottomSheet.show(
        context,
        guestId: authState.guestId!,
        stats: stats,
      );
    }
  }

  /// Show conversion prompt after chat interaction
  static Future<void> showAfterChat(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;

    if (!authState.isGuest || authState.guestId == null) {
      return;
    }

    final conversionService = GuestConversionService();
    final stats = await conversionService.getGuestSessionStats(authState.guestId!);

    if (!context.mounted) return;

    // Show bottom sheet after 5 messages
    if (stats.messageCount == 5) {
      await GuestConversionBottomSheet.show(
        context,
        guestId: authState.guestId!,
        stats: stats,
      );
    }
  }

  /// Show conversion prompt on profile screen
  static Widget buildProfilePrompt(BuildContext context) {
    return const GuestConversionPrompt(
      context: ConversionPromptContext.profile,
    );
  }

  /// Show conversion banner (can be added to any screen)
  static Widget buildBanner({VoidCallback? onDismiss}) {
    return GuestConversionBanner(onDismiss: onDismiss);
  }
}

/// Mixin to add conversion prompt functionality to screens
mixin ConversionPromptMixin<T extends StatefulWidget> on State<T> {
  bool _promptDismissed = false;

  /// Check if prompt should be shown
  bool get shouldShowPrompt {
    final authState = context.read<AuthBloc>().state;
    return authState.isGuest && !_promptDismissed;
  }

  /// Dismiss the prompt
  void dismissPrompt() {
    setState(() {
      _promptDismissed = true;
    });
  }

  /// Build conversion banner widget
  Widget buildConversionBanner() {
    if (!shouldShowPrompt) {
      return const SizedBox.shrink();
    }

    return GuestConversionBanner(
      onDismiss: dismissPrompt,
    );
  }

  /// Show conversion bottom sheet
  Future<void> showConversionBottomSheet() async {
    final authState = context.read<AuthBloc>().state;

    if (!authState.isGuest || authState.guestId == null) {
      return;
    }

    final conversionService = GuestConversionService();
    final stats = await conversionService.getGuestSessionStats(authState.guestId!);

    if (!mounted) return;

    await GuestConversionBottomSheet.show(
      context,
      guestId: authState.guestId!,
      stats: stats,
    );
  }
}
