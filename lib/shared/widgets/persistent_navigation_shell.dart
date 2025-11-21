import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../core/blocs/navigation_bloc.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../features/order/widgets/active_order_modal.dart';
import '../../features/order/blocs/active_orders_bloc.dart';

class PersistentNavigationShell extends StatefulWidget {
  const PersistentNavigationShell({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  State<PersistentNavigationShell> createState() => _PersistentNavigationShellState();
}

class _PersistentNavigationShellState extends State<PersistentNavigationShell> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.currentTab.index,
            children: widget.children,
          ),
          bottomNavigationBar: const GlassBottomNavigation(),
          floatingActionButton: const OrdersFloatingActionButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
}

class GlassBottomNavigation extends StatelessWidget {
  const GlassBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BlocBuilder<NavigationBloc, NavigationState>(
            builder: (context, state) {
              return Row(
                children: [
                  Expanded(
                    child: _buildNavItem(
                      context,
                      NavigationTab.map,
                      state.currentTab == NavigationTab.map,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      context,
                      NavigationTab.feed,
                      state.currentTab == NavigationTab.feed,
                    ),
                  ),
                  const Expanded(child: SizedBox()), // Space for FAB
                  Expanded(
                    child: _buildNavItem(
                      context,
                      NavigationTab.chat,
                      state.currentTab == NavigationTab.chat,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      context,
                      NavigationTab.profile,
                      state.currentTab == NavigationTab.profile,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, NavigationTab tab, bool isSelected) {
    return InkWell(
      onTap: () {
        context.read<NavigationBloc>().selectTab(tab);
        AppRouter.navigateToTab(context, tab);
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tab.icon,
              size: 24,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersFloatingActionButton extends StatefulWidget {
  const OrdersFloatingActionButton({super.key});

  @override
  State<OrdersFloatingActionButton> createState() => _OrdersFloatingActionButtonState();
}

class _OrdersFloatingActionButtonState extends State<OrdersFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 64,
            height: 64,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showActiveOrderModal,
                borderRadius: BorderRadius.circular(32),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 24,
                      color: AppTheme.darkText,
                    ),
                    SizedBox(height: 2),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showActiveOrderModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return BlocProvider.value(
          value: context.read<ActiveOrdersBloc>(),
          child: const ActiveOrderModal(),
        );
      },
    );
  }
}