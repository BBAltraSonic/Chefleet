import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../feed/models/dish_model.dart';
import '../blocs/vendor_dashboard_bloc.dart';
import '../widgets/order_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/menu_item_card.dart';
import 'order_history_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/glass_container.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load dashboard data and subscribe to real-time updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorDashboardBloc>().add(LoadDashboardData());

      // Subscribe to real-time order updates after vendor data is loaded
      context.read<VendorDashboardBloc>().stream.listen((state) {
        if (state.vendor != null) {
          context.read<VendorDashboardBloc>().add(
            SubscribeToOrderUpdates(vendorId: state.vendor!['id']),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    context.read<VendorDashboardBloc>().add(UnsubscribeFromOrderUpdates());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
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

              return Column(
                children: [
                  _buildHeader(state),
                  _buildStatsGrid(state),
                  _buildTabBar(),
                  _buildTabContent(state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(VendorDashboardState state) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
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
                      'Welcome back!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.vendor?['business_name'] as String? ?? 'Vendor',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.push(VendorRoutes.quickTour),
                    icon: const Icon(Icons.help_outline),
                    tooltip: 'Quick Tour',
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.surfaceGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => context.read<VendorDashboardBloc>().add(RefreshDashboard()),
                    icon: const Icon(Icons.refresh),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.surfaceGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (state.successMessage != null) ...[
            const SizedBox(height: AppTheme.spacing12),
            GlassContainer(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              borderRadius: AppTheme.radiusSmall,
              color: AppTheme.primaryGreen,
              opacity: 0.1,
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20),
                  const SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: Text(
                      state.successMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.darkText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<VendorDashboardBloc>().add(RefreshDashboard());
                    },
                    icon: const Icon(Icons.close, size: 18),
                    color: AppTheme.darkText,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsGrid(VendorDashboardState state) {
    final stats = state.stats;
    if (stats == null) return const SizedBox(height: 16);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              StatsCard(
                title: 'Today\'s Orders',
                value: stats.todayOrders.toString(),
                subtitle: '\$${stats.todayRevenue.toStringAsFixed(2)}',
                icon: Icons.shopping_bag,
                color: Colors.blue,
              ),
              StatsCard(
                title: 'Active Orders',
                value: stats.activeOrders.toString(),
                subtitle: '${stats.pendingOrders} pending',
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
              StatsCard(
                title: 'This Week',
                value: stats.weekOrders.toString(),
                subtitle: '\$${stats.weekRevenue.toStringAsFixed(2)}',
                icon: Icons.date_range,
                color: Colors.green,
              ),
              StatsCard(
                title: 'This Month',
                value: stats.monthOrders.toString(),
                subtitle: '\$${stats.monthRevenue.toStringAsFixed(2)}',
                icon: Icons.calendar_month,
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(text: 'Orders'),
          Tab(text: 'Menu'),
          Tab(text: 'Analytics'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildTabContent(VendorDashboardState state) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersTab(state),
          _buildMenuTab(state),
          _buildAnalyticsTab(state),
          _buildHistoryTab(),
        ],
      ),
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
            _buildFilterChip('all', 'All'),
            const SizedBox(width: 8),
            _buildFilterChip('pending', 'Pending'),
            const SizedBox(width: 8),
            _buildFilterChip('accepted', 'Accepted'),
            const SizedBox(width: 8),
            _buildFilterChip('preparing', 'Preparing'),
            const SizedBox(width: 8),
            _buildFilterChip('ready', 'Ready'),
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
                'Menu Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.push(VendorRoutes.dishAdd),
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.menuItems.isEmpty
                ? _buildEmptyMenuState()
                : ListView.builder(
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
                              context.push('${VendorRoutes.dishes}/edit', extra: dish);
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // TODO: Implement analytics charts and detailed stats
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Analytics coming soon',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
              'Something went wrong',
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
              child: const Text('Try Again'),
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
            'No orders found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here when customers place them',
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
            'No menu items yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first menu item to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push(VendorRoutes.dishAdd),
            icon: const Icon(Icons.add),
            label: const Text('Add First Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return const OrderHistoryScreen();
  }
}