import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../feed/models/vendor_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated vendor info card that slides up from bottom
class AnimatedVendorInfoCard extends StatefulWidget {
  const AnimatedVendorInfoCard({
    super.key,
    required this.vendor,
    required this.dishCount,
    this.distance,
    required this.onClose,
    required this.onViewMenu,
    this.onCall,
    this.autoDismissSeconds = 8,
  });

  final Vendor vendor;
  final int dishCount;
  final double? distance;
  final VoidCallback onClose;
  final VoidCallback onViewMenu;
  final VoidCallback? onCall;
  final int autoDismissSeconds;

  @override
  State<AnimatedVendorInfoCard> createState() => _AnimatedVendorInfoCardState();
}

class _AnimatedVendorInfoCardState extends State<AnimatedVendorInfoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  
  // Timer for auto-dismiss
  // ignore: unused_field
  Future<void>? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Play entrance animation with haptic feedback
    HapticFeedback.lightImpact();
    _controller.forward();

    // Auto-dismiss after timeout
    if (widget.autoDismissSeconds > 0) {
       // We don't want to store the future if we don't cancel it, but for safety in dispose we could.
       // For simple usage, just letting it run and check mounted is fine.
       Future.delayed(Duration(seconds: widget.autoDismissSeconds), () {
        if (mounted && _controller.isCompleted) {
          _dismiss();
        }
      });
    }
  }

  void _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      widget.onClose();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            // Swipe down to dismiss
            if (details.velocity.pixelsPerSecond.dy > 100) {
              HapticFeedback.selectionClick();
              _dismiss();
            }
          },
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.85) // Adjusted for dark theme visibility
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          // Vendor logo
                          _buildVendorLogo(),
                          const SizedBox(width: 12),
                          
                          // Vendor info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.vendor.displayName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    if (widget.vendor.cuisineType != null) ...[
                                      Text(
                                        widget.vendor.cuisineType!,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.hintColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    if (widget.distance != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _formatDistance(widget.distance!),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: AppTheme.primaryGreen,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Close button
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _dismiss();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: theme.dividerColor.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Stats row
                      Row(
                        children: [
                          _buildStatChip(
                            context,
                            icon: Icons.star,
                            iconColor: Colors.amber,
                            label: widget.vendor.rating.toStringAsFixed(1),
                          ),
                          const SizedBox(width: 12),
                          _buildStatChip(
                            context,
                            icon: Icons.restaurant_menu,
                            label: '${widget.dishCount} dishes',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          // View Menu - Primary
                          Expanded(
                            flex: 2,
                            child: _AnimatedButton(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                widget.onViewMenu();
                              },
                              isPrimary: true,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.menu_book, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'View Menu',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Call button (if available)
                          if (widget.onCall != null) ...[
                            const SizedBox(width: 12),
                            _AnimatedButton(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                widget.onCall!();
                              },
                              isPrimary: false,
                              child: const Icon(Icons.phone, size: 20),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVendorLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryGreen.withOpacity(0.1),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: widget.vendor.logoUrl != null && widget.vendor.logoUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                widget.vendor.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildLogoFallback(),
              ),
            )
          : _buildLogoFallback(),
    );
  }

  Widget _buildLogoFallback() {
    return Center(
      child: Text(
        widget.vendor.displayName.isNotEmpty
            ? widget.vendor.displayName[0].toUpperCase()
            : 'V',
        style: TextStyle(
          color: AppTheme.primaryGreen,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    Color? iconColor,
    required String label,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? theme.hintColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()}m';
    }
    return '${km.toStringAsFixed(1)}km';
  }
}

/// Animated button with press feedback
class _AnimatedButton extends StatefulWidget {
  const _AnimatedButton({
    required this.onTap,
    required this.child,
    this.isPrimary = true,
  });

  final VoidCallback onTap;
  final Widget child;
  final bool isPrimary;

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isPrimary
                    ? AppTheme.primaryGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: widget.isPrimary
                    ? null
                    : Border.all(color: AppTheme.primaryGreen),
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: widget.isPrimary ? Colors.white : AppTheme.primaryGreen,
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: widget.isPrimary ? Colors.white : AppTheme.primaryGreen,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
