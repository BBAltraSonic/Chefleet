import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

/// Widget that displays a pickup code as both QR code and manual text
/// 
/// Features:
/// - Large QR code for easy scanning
/// - Manual code entry fallback
/// - Expiry countdown timer
/// - Auto-refresh on expiry (optional)
class PickupCodeQrWidget extends StatefulWidget {
  final String pickupCode;
  final DateTime expiresAt;
  final VoidCallback? onExpired;
  final VoidCallback? onRefresh;

  const PickupCodeQrWidget({
    Key? key,
    required this.pickupCode,
    required this.expiresAt,
    this.onExpired,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<PickupCodeQrWidget> createState() => _PickupCodeQrWidgetState();
}

class _PickupCodeQrWidgetState extends State<PickupCodeQrWidget> {
  Timer? _countdownTimer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    final remaining = widget.expiresAt.difference(now);
    setState(() {
      _timeRemaining = remaining.isNegative ? Duration.zero : remaining;
    });

    if (_timeRemaining.inSeconds == 0 && widget.onExpired != null) {
      widget.onExpired!();
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining();
    });
  }

  String _formatTimeRemaining() {
    final minutes = _timeRemaining.inMinutes;
    final seconds = _timeRemaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getExpiryColor() {
    if (_timeRemaining.inMinutes >= 10) {
      return Colors.green;
    } else if (_timeRemaining.inMinutes >= 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _timeRemaining.inSeconds == 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Pickup Code',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // QR Code
            if (!isExpired) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: QrImageView(
                  data: widget.pickupCode,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                ),
              ),
              const SizedBox(height: 16),

              // Manual code
              Text(
                'Or enter code manually:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  widget.pickupCode,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        fontFamily: 'monospace',
                      ),
                ),
              ),
              const SizedBox(height: 16),

              // Expiry countdown
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: _getExpiryColor(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Expires in ${_formatTimeRemaining()}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _getExpiryColor(),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ] else ...[
              // Expired state
              Icon(
                Icons.timer_off,
                size: 80,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Code Expired',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please generate a new pickup code',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              if (widget.onRefresh != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: widget.onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Generate New Code'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],

            // Instructions
            if (!isExpired) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Show this code to the vendor when picking up your order',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade900,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
