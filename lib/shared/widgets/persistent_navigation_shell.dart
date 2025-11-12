import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../core/blocs/navigation_bloc.dart';

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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listener: (context, state) {
        _pageController.animateToPage(
          state.currentTab.index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      },
      child: Scaffold(
        body: IndexedStack(
          index: context.select(
            (NavigationBloc bloc) => bloc.state.currentTab.index,
          ),
          children: widget.children,
        ),
        bottomNavigationBar: const GlassBottomNavigation(),
        floatingActionButton: const OrdersFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
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
      onTap: () => context.read<NavigationBloc>().selectTab(tab),
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

class OrdersFloatingActionButton extends StatelessWidget {
  const OrdersFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.read<NavigationBloc>().selectTab(NavigationTab.orders),
          borderRadius: BorderRadius.circular(32),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 24,
                color: Colors.white,
              ),
              SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }
}