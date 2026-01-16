import 'dart:async';
import 'package:flutter/material.dart';

class AuthLoadingState extends StatefulWidget {
  final String message;
  final int? timeoutSeconds;
  final VoidCallback? onTimeout;
  final VoidCallback? onCancel;

  const AuthLoadingState({
    super.key,
    required this.message,
    this.timeoutSeconds = 15,
    this.onTimeout,
    this.onCancel,
  });

  @override
  State<AuthLoadingState> createState() => _AuthLoadingStateState();
}

class _AuthLoadingStateState extends State<AuthLoadingState> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;
  Timer? _timeoutTimer;
  String _currentMessage = "";
  bool _showCancel = false;

  @override
  void initState() {
    super.initState();
    _currentMessage = widget.message;
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Show cancel/help options after 5 seconds
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _currentMessage = "Taking longer than usual...";
          _showCancel = true;
        });
      }
    });
    
    // Timeout logic
    if (widget.timeoutSeconds != null) {
      _timeoutTimer = Timer(Duration(seconds: widget.timeoutSeconds!), () {
        if (mounted) {
          widget.onTimeout?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  strokeWidth: 3,
                ),
              ),
              RotationTransition(
                turns: _controller,
                child: Icon(
                  Icons.hourglass_empty,
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _currentMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_showCancel && widget.onCancel != null) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: widget.onCancel,
              child: const Text("Cancel"),
            ),
          ],
        ],
      ),
    );
  }
}
