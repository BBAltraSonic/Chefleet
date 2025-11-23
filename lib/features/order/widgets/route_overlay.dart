import 'package:flutter/material.dart';
import 'dart:async';

import '../../../core/theme/app_theme.dart' show AppTheme;

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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppTheme.borderGreen,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Header Row with status badge
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor().withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getStatusColor(),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                _getStatusText(),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.vendorName,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.surfaceGreen,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: widget.onClose,
                          color: AppTheme.darkText,
                          iconSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing12),

                  // ETA Display with enhanced styling
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryGreen.withOpacity(0.1),
                          AppTheme.surfaceGreen,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGreen.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.access_time,
                            color: AppTheme.darkText,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getEtaText(),
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Estimated pickup time',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
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

                  // Action Buttons with improved styling
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onContactVendor,
                          icon: const Icon(Icons.chat_bubble_outline, size: 20),
                          label: const Text(
                            'Chat',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacing16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                            side: const BorderSide(
                              color: AppTheme.borderGreen,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onViewDetails,
                          icon: const Icon(Icons.receipt_long, size: 20),
                          label: const Text(
                            'Details',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacing16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
        return const Color(0xFFFF9800); // Orange
      case 'accepted':
        return const Color(0xFF2196F3); // Blue
      case 'preparing':
        return const Color(0xFF9C27B0); // Purple
      case 'ready':
        return AppTheme.primaryGreen; // Green
      case 'completed':
        return AppTheme.secondaryGreen; // Grey-green
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
