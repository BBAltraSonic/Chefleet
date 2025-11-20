import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../blocs/order_management_bloc.dart';

class OrderAnalyticsWidget extends StatefulWidget {
  const OrderAnalyticsWidget({super.key});

  @override
  State<OrderAnalyticsWidget> createState() => _OrderAnalyticsWidgetState();
}

class _OrderAnalyticsWidgetState extends State<OrderAnalyticsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date Range Selector
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Order Analytics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range),
                label: Text(_formatDateRange()),
              ),
            ],
          ),
        ),

        // Tab Bar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Performance'),
            Tab(text: 'Items'),
          ],
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildPerformanceTab(),
              _buildItemsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadAnalyticsData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading analytics: ${snapshot.error}'),
          );
        }

        final analytics = snapshot.data ?? {};
        final totalOrders = analytics['total_orders'] as int? ?? 0;
        final totalRevenue = analytics['total_revenue'] as int? ?? 0;
        final averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;
        final completedOrders = analytics['completed_orders'] as int? ?? 0;
        final cancelledOrders = analytics['cancelled_orders'] as int? ?? 0;
        final completionRate = totalOrders > 0 ? (completedOrders / totalOrders * 100) : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Key Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Total Orders',
                      totalOrders.toString(),
                      Icons.receipt_long,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      'Total Revenue',
                      '\$${(totalRevenue / 100).toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Avg Order Value',
                      '\$${averageOrderValue.toStringAsFixed(2)}',
                      Icons.trending_up,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      'Completion Rate',
                      '${completionRate.toStringAsFixed(1)}%',
                      Icons.check_circle,
                      Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Order Status Breakdown
              _buildStatusBreakdownCard(context, analytics),

              const SizedBox(height: 16),

              // Revenue Chart
              _buildRevenueChartCard(context, analytics),

              const SizedBox(height: 16),

              // Peak Hours Analysis
              _buildPeakHoursCard(context, analytics),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadPerformanceData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final performance = snapshot.data ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Performance Metrics
              _buildPerformanceMetrics(context, performance),

              const SizedBox(height: 16),

              // Preparation Time Analysis
              _buildPreparationTimeCard(context, performance),

              const SizedBox(height: 16),

              // Customer Satisfaction
              _buildCustomerSatisfactionCard(context, performance),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadPopularItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final popularItems = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Popular Items
              _buildPopularItemsCard(context, popularItems),

              const SizedBox(height: 16),

              // Category Performance
              _buildCategoryPerformanceCard(context, popularItems),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBreakdownCard(BuildContext context, Map<String, dynamic> analytics) {
    final statusCounts = analytics['status_counts'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Status Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...statusCounts.entries.map((entry) {
              final status = entry.key as String;
              final count = entry.value as int? ?? 0;
              final color = _getStatusColor(status);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        OrderManagementState.getStatusDisplayName(status),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      count.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChartCard(BuildContext context, Map<String, dynamic> analytics) {
    final dailyRevenue = analytics['daily_revenue'] as List<dynamic>? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: dailyRevenue.isEmpty
                  ? const Center(child: Text('No data available'))
                  : _buildSimpleRevenueChart(dailyRevenue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleRevenueChart(List<dynamic> dailyRevenue) {
    if (dailyRevenue.isEmpty) return const SizedBox.shrink();

    final maxValue = dailyRevenue.fold<double>(
      0,
      (prev, item) {
        final revenue = (item as Map<String, dynamic>)['revenue'] as int? ?? 0;
        return revenue > prev ? revenue.toDouble() : prev;
      },
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: dailyRevenue.take(7).map((item) {
        final data = item as Map<String, dynamic>;
        final revenue = (data['revenue'] as int? ?? 0).toDouble();
        final height = maxValue > 0 ? (revenue / maxValue) * 180 : 0.0;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${(revenue / 100).toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPeakHoursCard(BuildContext context, Map<String, dynamic> analytics) {
    final peakHours = analytics['peak_hours'] as List<dynamic>? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peak Hours',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (peakHours.isEmpty)
              const Text('No peak hour data available')
            else
              Wrap(
                spacing: 8,
                children: peakHours.map((hour) {
                  final hourData = hour as Map<String, dynamic>;
                  final hourLabel = '${hourData['hour']}:00';
                  final orderCount = hourData['order_count'] as int? ?? 0;

                  return Chip(
                    label: Text('$hourLabel ($orderCount)'),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context, Map<String, dynamic> performance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPerformanceRow(
              'Average Prep Time',
              '${performance['avg_prep_time'] ?? 'N/A'} min',
              Icons.timer,
            ),
            _buildPerformanceRow(
              'On-Time Rate',
              '${performance['on_time_rate'] ?? 'N/A'}%',
              Icons.schedule,
            ),
            _buildPerformanceRow(
              'Daily Average',
              '${performance['daily_average'] ?? 'N/A'} orders',
              Icons.trending_up,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationTimeCard(BuildContext context, Map<String, dynamic> performance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preparation Time Analysis',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Preparation time distribution will be shown here'),
            // Placeholder for preparation time chart
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSatisfactionCard(BuildContext context, Map<String, dynamic> performance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Satisfaction',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Customer ratings and feedback will be shown here'),
            // Placeholder for customer satisfaction metrics
          ],
        ),
      ),
    );
  }

  Widget _buildPopularItemsCard(BuildContext context, List<Map<String, dynamic>> popularItems) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Popular Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (popularItems.isEmpty)
              const Text('No item data available')
            else
              Column(
                children: popularItems.take(10).map((item) {
                  final name = item['dish_name'] as String? ?? 'Unknown';
                  final orderCount = item['order_count'] as int? ?? 0;
                  final revenue = item['total_revenue'] as int? ?? 0;

                  return ListTile(
                    leading: const Icon(Icons.restaurant),
                    title: Text(name),
                    subtitle: Text('$orderCount orders'),
                    trailing: Text(
                      '\$${(revenue / 100).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPerformanceCard(BuildContext context, List<Map<String, dynamic>> items) {
    final categoryRevenue = <String, int>{};

    for (final item in items) {
      final category = item['category'] as String? ?? 'Other';
      final revenue = item['total_revenue'] as int? ?? 0;
      categoryRevenue[category] = (categoryRevenue[category] ?? 0) + revenue;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Performance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...categoryRevenue.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text(
                      '\$${(entry.value / 100).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _loadAnalyticsData() async {
    // This would be replaced with actual analytics queries
    return {
      'total_orders': 150,
      'total_revenue': 15000, // in cents
      'completed_orders': 140,
      'cancelled_orders': 10,
      'status_counts': {
        'completed': 140,
        'cancelled': 8,
        'rejected': 2,
      },
      'daily_revenue': [
        {'date': '2024-01-01', 'revenue': 1200},
        {'date': '2024-01-02', 'revenue': 1500},
        {'date': '2024-01-03', 'revenue': 900},
        // ... more days
      ],
      'peak_hours': [
        {'hour': 12, 'order_count': 25},
        {'hour': 13, 'order_count': 30},
        {'hour': 18, 'order_count': 35},
        {'hour': 19, 'order_count': 28},
      ],
    };
  }

  Future<Map<String, dynamic>> _loadPerformanceData() async {
    // Placeholder for performance data
    return {
      'avg_prep_time': 15,
      'on_time_rate': 95.5,
      'daily_average': 12.5,
    };
  }

  Future<List<Map<String, dynamic>>> _loadPopularItems() async {
    // Placeholder for popular items data
    return [
      {'dish_name': 'Burger', 'order_count': 45, 'total_revenue': 4500, 'category': 'Main Course'},
      {'dish_name': 'Pizza', 'order_count': 38, 'total_revenue': 3800, 'category': 'Main Course'},
      {'dish_name': 'Salad', 'order_count': 25, 'total_revenue': 1250, 'category': 'Salads'},
      // ... more items
    ];
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String _formatDateRange() {
    if (_selectedDateRange == null) return 'Select Range';

    final start = _selectedDateRange!.start;
    final end = _selectedDateRange!.end;

    if (start.day == end.day && start.month == end.month && start.year == end.year) {
      return '${start.day}/${start.month}/${start.year}';
    } else {
      return '${start.day}/${start.month} - ${end.day}/${end.month}';
    }
  }

  Color _getStatusColor(String status) {
    return Color(
      int.parse(
        OrderManagementState.getStatusColor(status).substring(1),
        radix: 16,
      ),
    );
  }
}