import 'package:flutter/material.dart';
import 'dart:async';

import '../../../core/theme/app_theme.dart' show AppTheme;
import '../../../shared/widgets/glass_container.dart';

class RouteOverlay extends StatefulWidget {
  const RouteOverlay({
    super.key,
    required this.orderId,
    required this.vendorName,
    required this.vendorAddress,
    required this.estimatedMinutes,
    required this.orderStatus,
    this.onClose,
    this.onViewDetails,
    this.onContactVendor,
  });

  final String orderId;
  final String vendorName;
  final String vendorAddress;
  final int estimatedMinutes;
  final String orderStatus;
  final VoidCallback? onClose;
  final VoidCallback? onViewDetails;
  final VoidCallback? onContactVendor;

  @override
  State<RouteOverlay> createState() => _RouteOverlayState();
}

class _RouteOverlayState extends State<RouteOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  Timer? _etaUpdateTimer;
  late int _remainingMinutes;

  @override
  void initState() {
    super.initState();
    _remainingMinutes = widget.estimatedMinutes;
    _setupAnimations();
    _startEtaUpdates();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  void _startEtaUpdates() {
    // Simulate ETA countdown (in real app, would sync with backend)
    _etaUpdateTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) {
        if (_remainingMinutes > 0) {
          setState(() {
            _remainingMinutes--;
          });
        } else {
          timer.cancel();
        }
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _etaUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(AppTheme.spacing16),
          child: GlassContainer(
            borderRadius: AppTheme.radiusLarge,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusText(),
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: _getStatusColor(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.vendorName,
                              style: Theme.of(context).textTheme.headlineMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onClose,
                        color: AppTheme.darkText,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing12),

                  // ETA Display
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGreen,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.access_time,
                            color: AppTheme.darkText,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getEtaText(),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Estimated pickup time',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing12),

                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppTheme.secondaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Expanded(
                        child: Text(
                          widget.vendorAddress,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onContactVendor,
                          icon: const Icon(Icons.chat_bubble_outline, size: 20),
                          label: const Text('Chat'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacing12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onViewDetails,
                          icon: const Icon(Icons.receipt_long, size: 20),
                          label: const Text('Details'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacing12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Order ID (small text)
                  const SizedBox(height: AppTheme.spacing8),
                  Center(
                    child: Text(
                      'Order #${widget.orderId.substring(0, 8).toUpperCase()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryGreen,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (widget.orderStatus) {
      case 'pending':
        return 'ORDER PENDING';
      case 'accepted':
        return 'ORDER ACCEPTED';
      case 'preparing':
        return 'PREPARING YOUR FOOD';
      case 'ready':
        return 'READY FOR PICKUP';
      case 'completed':
        return 'ORDER COMPLETED';
      default:
        return 'ORDER STATUS';
    }
  }

  Color _getStatusColor() {
    switch (widget.orderStatus) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return AppTheme.primaryGreen;
      case 'completed':
        return AppTheme.secondaryGreen;
      default:
        return AppTheme.secondaryGreen;
    }
  }

  String _getEtaText() {
    if (widget.orderStatus == 'ready') {
      return 'Ready Now!';
    } else if (widget.orderStatus == 'completed') {
      return 'Completed';
    } else if (_remainingMinutes <= 0) {
      return 'Almost Ready';
    } else {
      return '$_remainingMinutes min';
    }
  }
}
