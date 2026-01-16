import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../feed/models/dish_model.dart';
import '../blocs/vendor_dashboard_bloc.dart';
import '../widgets/order_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/menu_item_card.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/analytics_tab.dart';

class VendorDashboardScreen extends StatefulWidget {
  /// Optional initial tab index (0=Orders, 1=Menu, 2=Stats, 3=History)
  final int initialTab;

  const VendorDashboardScreen({super.key, this.initialTab = 0});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatusFilter = 'all';

  VendorDashboardBloc? _dashboardBloc;
  StreamSubscription<VendorDashboardState>? _blocSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    
    // safe lookups
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _dashboardBloc = context.read<VendorDashboardBloc>();
      _dashboardBloc?.add(LoadDashboardData());

      // Subscribe to real-time order updates after vendor data is loaded
      // IMPORTANT: Store subscription and cancel it in dispose
      _blocSubscription = _dashboardBloc?.stream.listen((state) {
        if (!mounted) return;
        if (state.vendor != null && !(_dashboardBloc?.isClosed ?? true)) {
          // Use captured bloc reference to be safe even if context is technically deactivated
          _dashboardBloc?.add(
            SubscribeToOrderUpdates(vendorId: state.vendor!['id']),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _blocSubscription?.cancel(); // Cancel stream subscription to prevent disposal errors
    // Bloc close() handles unsubscribe, no need to dispatch event here which might fail if bloc is closing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // clean off-white
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<VendorDashboardBloc>().add(RefreshDashboard());
        },
        child: BlocBuilder<VendorDashboardBloc, VendorDashboardState>(
          builder: (context, state) {
            if (state.isLoading && state.vendor == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return _buildErrorState(state.errorMessage!);
            }

            // Using NestedScrollView to prevent "dependents is empty" assertions
            // and handle tab scrolling properly
            return NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(child: _buildHeader(state)),
                  SliverToBoxAdapter(child: _buildStatsGrid(state)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      minHeight: 80.0,
                      maxHeight: 80.0,
                      child: _buildTabBar(),
                    ),
                  ),
                ];
              },
              body: _buildTabContent(state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(VendorDashboardState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20), // Added top padding for status bar area since we removed SafeArea
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.welcomeBack,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.vendor?['business_name'] as String? ?? 'Vendor',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildGlassIconButton(
                    icon: Icons.help_outline_rounded,
                    onPressed: () => context.push(VendorRoutes.quickTour),
                  ),
                  const SizedBox(width: 12),
                  _buildGlassIconButton(
                    icon: Icons.person_outline_rounded,
                    onPressed: () => context.push(VendorRoutes.profile),
                  ),
                ],
              ),
            ],
          ),
          if (state.successMessage != null) ...[
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: 16,
              color: const Color(0xFF4CAF50),
              opacity: 0.1,
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.successMessage!,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                       context.read<VendorDashboardBloc>().add(RefreshDashboard());
                    },
                    child: const Icon(Icons.close_rounded, size: 18, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGlassIconButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
             color: Colors.grey.withOpacity(0.1),
             blurRadius: 10,
             offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xFF1A1A1A), size: 22),
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(VendorDashboardState state) {
    final stats = state.stats;
    if (stats == null) return const SizedBox(height: 16);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.overviewTab,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35, // Make cards shorter to prevent overflow
            padding: EdgeInsets.zero,
            children: [
              StatsCard(
                title: AppStrings.todayOrders,
                value: stats.todayOrders.toString(),
                subtitle: CurrencyFormatter.format(stats.todayRevenue),
                icon: Icons.shopping_bag_outlined,
                color: const Color(0xFF2196F3),
              ),
              StatsCard(
                title: AppStrings.activeOrders,
                value: stats.activeOrders.toString(),
                subtitle: '${stats.pendingOrders} pending',
                icon: Icons.timer_outlined,
                color: const Color(0xFFFF9800),
              ),
              StatsCard(
                title: AppStrings.thisWeek,
                value: stats.weekOrders.toString(),
                subtitle: CurrencyFormatter.format(stats.weekRevenue),
                icon: Icons.calendar_view_week_rounded,
                color: const Color(0xFF4CAF50), // Green
              ),
              StatsCard(
                title: AppStrings.thisMonth,
                value: stats.monthOrders.toString(),
                subtitle: CurrencyFormatter.format(stats.monthRevenue),
                icon: Icons.calendar_month_rounded,
                color: const Color(0xFF9C27B0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFFF8F9FE), // Match background for sticky header
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: const Color(0xFF1A1A1A),
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: AppStrings.orders),
            Tab(text: AppStrings.menuItems),
            Tab(text: AppStrings.sales),
            Tab(text: AppStrings.history),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(VendorDashboardState state) {
     // No changes to logic here, just wrapping in logic above
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOrdersTab(state),
        _buildMenuTab(state),
        _buildAnalyticsTab(state),
        _buildHistoryTab(state),
      ],
    );
  }

  Widget _buildOrdersTab(VendorDashboardState state) {
    return Column(
      children: [
        _buildStatusFilter(),
        const SizedBox(height: 16),
        Expanded(
          child: state.filteredOrders.isEmpty
              ? _buildEmptyOrdersState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.filteredOrders.length,
                  primary: false,
                  itemBuilder: (context, index) {
                    final order = state.filteredOrders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OrderCard(
                        order: order,
                        onTap: () => context.push('${VendorRoutes.orders}/${order['id']}'),
                        onStatusUpdate: (newStatus) {
                          context.read<VendorDashboardBloc>().add(
                            UpdateOrderStatus(
                              orderId: order['id'],
                              newStatus: newStatus,
                            ),
                          );
                        },
                        onVerifyPickupCode: (orderId, pickupCode) {
                          context.read<VendorDashboardBloc>().add(
                            VerifyPickupCode(
                              orderId: orderId,
                              pickupCode: pickupCode,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', AppStrings.statusAll),
            const SizedBox(width: 8),
            _buildFilterChip('pending', AppStrings.statusPending),
            const SizedBox(width: 8),
            _buildFilterChip('accepted', AppStrings.statusAccepted),
            const SizedBox(width: 8),
            _buildFilterChip('preparing', AppStrings.statusPreparing),
            const SizedBox(width: 8),
            _buildFilterChip('ready', AppStrings.statusReady),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedStatusFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatusFilter = value;
        });

        final state = context.read<VendorDashboardBloc>().state;
        if (state.vendor != null) {
          context.read<VendorDashboardBloc>().add(
            LoadOrders(
              vendorId: state.vendor!['id'],
              statusFilter: value == 'all' ? null : value,
            ),
          );
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildMenuTab(VendorDashboardState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.menuItems,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  debugPrint('Add Item button pressed - attempting navigation to ${VendorRoutes.dishAdd}');
                  context.push(VendorRoutes.dishAdd).then((_) {
                    debugPrint('Returned from dish add screen');
                    if (context.mounted) {
                      context.read<VendorDashboardBloc>().add(RefreshDashboard());
                    }
                  }).catchError((error) {
                    debugPrint('Navigation error: $error');
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Theme.of(context).colorScheme.primary, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.addItem,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.menuItems.isEmpty
                ? _buildEmptyMenuState()
                : ListView.builder(
                    primary: false,
                    itemCount: state.menuItems.length,
                    itemBuilder: (context, index) {
                      final item = state.menuItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MenuItemCard(
                          item: item,
                          onEdit: () {
                            // Ensure all required fields for Dish are present or handled
                            try {
                              final dish = Dish.fromJson(item);
                              context.push('${VendorRoutes.dishes}/edit/${dish.id}', extra: dish);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error opening dish: $e')),
                              );
                            }
                          },
                          onAvailabilityToggle: (isAvailable) {
                            context.read<VendorDashboardBloc>().add(
                              UpdateMenuItemAvailability(
                                itemId: item['id'],
                                isAvailable: isAvailable,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(VendorDashboardState state) {
    return AnalyticsTab(state: state);
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.somethingWentWrong,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<VendorDashboardBloc>().add(LoadDashboardData()),
              child: Text(AppStrings.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noOrdersFound,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.ordersEmptyState,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMenuState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noMenuItems,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.startAddingMenuItems,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(VendorDashboardState state) {
    // Inline history content using parent state to avoid nested BlocBuilder disposal issues
    final historyOrders = state.filteredOrders.where((order) {
      final status = order['status'] as String? ?? 'pending';
      return ['completed', 'cancelled'].contains(status);
    }).toList();

    if (state.isLoading && historyOrders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (historyOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No order history found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completed and cancelled orders will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: historyOrders.length,
      primary: false,
      itemBuilder: (context, index) {
        final order = historyOrders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildHistoryOrderCard(order),
        );
      },
    );
  }

  Widget _buildHistoryOrderCard(Map<String, dynamic> order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = order['status'] as String? ?? 'pending';
    final totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
    final updatedAt = DateTime.tryParse(order['updated_at'] as String? ?? '') ?? DateTime.now();
    final buyer = order['buyer'] as Map<String, dynamic>? ?? {};
    final items = order['items'] as List<dynamic>? ?? [];

    Color backgroundColor;
    Color textColor;
    String displayText;
    final isDark = theme.brightness == Brightness.dark;

    switch (status) {
      case 'completed':
        backgroundColor = Colors.green.withValues(alpha: isDark ? 0.2 : 0.1);
        textColor = isDark ? Colors.green[300]! : Colors.green;
        displayText = 'Completed';
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withValues(alpha: isDark ? 0.2 : 0.1);
        textColor = isDark ? Colors.red[300]! : Colors.red;
        displayText = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: isDark ? 0.2 : 0.1);
        textColor = isDark ? Colors.grey[300]! : Colors.grey;
        displayText = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order['id'].toString().substring(0, 8).toUpperCase()}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      buyer['full_name'] as String? ?? 'Customer',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: textColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  displayText,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Items (${items.length})',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          ...items.take(3).map((item) {
            final dish = item['dishes'] as Map<String, dynamic>? ?? {};
            final quantity = item['quantity'] as int? ?? 1;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '$quantity × ${dish['name'] as String? ?? 'Item'}',
                style: theme.textTheme.bodySmall,
              ),
            );
          }),
          if (items.length > 3)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '+${items.length - 3} more items',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.format(totalAmount),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                DateFormat('MMM dd, h:mm a').format(updatedAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: status == 'completed' ? Colors.green[600] : Colors.red[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight; // Fixed to minHeight for static size if needed

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}