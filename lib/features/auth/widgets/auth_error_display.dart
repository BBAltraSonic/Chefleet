import 'package:flutter/material.dart';
import '../models/auth_error_type.dart';
import '../models/error_message.dart';
import '../constants/auth_error_messages.dart';

class AuthErrorDisplay extends StatefulWidget {
  final AuthErrorType type;
  final String? customMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final VoidCallback? onSecondaryAction;

  const AuthErrorDisplay({
    super.key,
    required this.type,
    this.customMessage,
    this.onRetry,
    this.onDismiss,
    this.onSecondaryAction,
  });

  @override
  State<AuthErrorDisplay> createState() => _AuthErrorDisplayState();
}

class _AuthErrorDisplayState extends State<AuthErrorDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = authErrorMessages[widget.type] ?? authErrorMessages[AuthErrorType.unknown]!;
    final messageText = widget.customMessage ?? errorMessage.message;
    
    // Determine color based on severity (could be expanded)
    final Color color = widget.type == AuthErrorType.networkError 
        ? Colors.orange 
        : Colors.red;
        
    return SlideTransition(
      position: _offsetAnimation,
      child: Semantics(
        liveRegion: true,
        label: "Error: ${errorMessage.title}. $messageText",
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getIconForErrorType(widget.type), color: color, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          errorMessage.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          messageText,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (widget.onDismiss != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: widget.onDismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              if (errorMessage.actions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: errorMessage.actions.map((action) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: _buildActionButton(context, action, color),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ErrorAction action, Color color) {
    if (action.type == ErrorActionType.retry && widget.onRetry != null) {
      return TextButton(
        onPressed: widget.onRetry,
        style: TextButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(action.label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
      );
    }
    
    if (action.type == ErrorActionType.forgotPassword && widget.onSecondaryAction != null) {
      return TextButton(
        onPressed: widget.onSecondaryAction,
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[700],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(action.label),
      );
    }

    if (action.type == ErrorActionType.signIn && widget.onSecondaryAction != null) {
      return TextButton(
        onPressed: widget.onSecondaryAction,
        style: TextButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(action.label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
      );
    }
    
    // Default or other actions
    return const SizedBox.shrink();
  }

  IconData _getIconForErrorType(AuthErrorType type) {
    switch (type) {
      case AuthErrorType.invalidCredentials:
        return Icons.lock_outline;
      case AuthErrorType.networkError:
        return Icons.wifi_off;
      case AuthErrorType.serverError:
        return Icons.cloud_off;
      case AuthErrorType.rateLimited:
        return Icons.timer_outlined;
      case AuthErrorType.emailExists:
        return Icons.email_outlined;
      case AuthErrorType.weakPassword:
        return Icons.shield_outlined;
      case AuthErrorType.sessionExpired:
        return Icons.refresh_outlined;
      case AuthErrorType.firebaseInit:
      case AuthErrorType.profileCreation:
        return Icons.warning_outlined;
      case AuthErrorType.unknown:
        return Icons.error_outline;
    }
  }
}
