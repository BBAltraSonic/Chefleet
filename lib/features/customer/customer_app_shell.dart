import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/user_role.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/offline_banner.dart';
import '../order/widgets/active_order_modal.dart';
import '../order/blocs/active_orders_bloc.dart';

/// Customer app shell for the main customer experience.
///
/// This shell provides:
/// - Map screen as the primary interface
/// - Floating action button for cart/orders
/// - Full-screen edge-to-edge display
class CustomerAppShell extends StatefulWidget {
  const CustomerAppShell({
    super.key,
    required this.child,
    required this.availableRoles,
  });

  final Widget child;
  final Set<UserRole> availableRoles;

  @override
  State<CustomerAppShell> createState() => _CustomerAppShellState();
}

class _CustomerAppShellState extends State<CustomerAppShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: widget.child),
        ],
      ),
      floatingActionButton: const _CustomerFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// Floating action button for cart and active orders
class _CustomerFloatingActionButton extends StatefulWidget {
  const _CustomerFloatingActionButton();

  @override
  State<_CustomerFloatingActionButton> createState() =>
      __CustomerFloatingActionButtonState();
}

class __CustomerFloatingActionButtonState
    extends State<_CustomerFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for "ready" state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Bounce animation for status changes
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    ));
  }

  // Call this when order status changes
  void _triggerBounce() {
    HapticFeedback.mediumImpact();
    _bounceController.forward(from: 0);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActiveOrdersBloc, ActiveOrdersState>(
      listenWhen: (previous, current) {
        // Trigger bounce when order count or status changes
        if (previous.orders.length != current.orders.length) return true;
        if (previous.orders.isNotEmpty && current.orders.isNotEmpty) {
          return previous.orders.first['status'] != current.orders.first['status'];
        }
        return false;
      },
      listener: (context, state) {
        _triggerBounce();
      },
      builder: (context, activeOrdersState) {
        final activeOrders = activeOrdersState.orders;
        final hasActiveOrders = activeOrders.isNotEmpty;

        // Determine FAB mode (Only Active Order Mode)
        final isOrderMode = true;
        
        // Calculate progress and status for active order mode
        double progress = 0.0;
        IconData icon = Icons.receipt_long_rounded;
        Color color = AppTheme.primaryColor;
        String? status;

        if (hasActiveOrders && isOrderMode) {
          // Get the most relevant order (e.g., the first one or the one needing attention)
          // For now, we take the first one.
          final order = activeOrders.first;
          status = order['status'] as String? ?? 'pending';

          switch (status) {
            case 'pending':
              progress = 0.1;
              icon = Icons.hourglass_top_rounded;
              color = Colors.orange;
              break;
            case 'accepted':
              progress = 0.3;
              icon = Icons.store_rounded; // Vendor checked/accepted
              color = Colors.blue;
              break;
            case 'preparing':
              progress = 0.6;
              icon = Icons.soup_kitchen_rounded; // Food preparation
              color = Colors.orangeAccent; // Hot/Cooking color
              break;
            case 'ready':
              progress = 1.0;
              icon = Icons.shopping_bag_rounded;
              color = Colors.green;
              break;
            default:
              progress = 0.0;
              icon = Icons.receipt_long_rounded;
              color = AppTheme.primaryColor;
          }
        }

        return AnimatedOpacity(
          opacity: hasActiveOrders ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: hasActiveOrders
              ? AnimatedBuilder(
                  animation: Listenable.merge([_pulseAnimation, _bounceAnimation]),
                  builder: (context, child) {
                    final scaleStatus = isOrderMode && status == 'ready' ? _pulseAnimation.value : 1.0;
                    final scaleBounce = _bounceAnimation.value;
                    final scale = scaleStatus * scaleBounce;

                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            // Progress Indicator
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 4,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                            
                            // Main Button
                            Container(
                              width: 50, // Slightly smaller to fit inside progress
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _handleTap(context),
                                  borderRadius: BorderRadius.circular(25),
                                  child: Center(
                                    child: Icon(
                                      icon,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // Vendor Check Badge (If accepted/preparing/ready)
                            if (status == 'accepted' || status == 'preparing' || status == 'ready')
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ),

                            // Count Badge (Multiple Orders)
                            if (activeOrders.length > 1)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${activeOrders.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        height: 1.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  void _handleTap(BuildContext context) {
    // Show active orders modal
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return BlocProvider.value(
          value: context.read<ActiveOrdersBloc>(),
          child: const ActiveOrderModal(),
        );
      },
    );
  }
}
