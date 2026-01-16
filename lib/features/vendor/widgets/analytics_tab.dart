import 'package:fl_chart/fl_chart.dart';
import '../../../shared/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../blocs/vendor_dashboard_bloc.dart';

class AnalyticsTab extends StatelessWidget {
  final VendorDashboardState state;

  const AnalyticsTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = state.stats!;
    // Mock data for the chart to show progression
    // In a real scenario, this would come from a historical data endpoint
    final weeklyData = [
      _ChartData('Mon', stats.todayRevenue * 0.7),
      _ChartData('Tue', stats.todayRevenue * 0.5),
      _ChartData('Wed', stats.todayRevenue * 0.8),
      _ChartData('Thu', stats.todayRevenue * 0.6),
      _ChartData('Fri', stats.todayRevenue * 0.9),
      _ChartData('Sat', stats.todayRevenue * 1.2),
      _ChartData('Sun', stats.todayRevenue),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Analytics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),
          
          Container(
            height: 300,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Revenue',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          CurrencyFormatter.format(stats.weekRevenue),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing12,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            size: 16,
                            color: AppTheme.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '12%',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing24),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (weeklyData.map((e) => e.value).reduce((a, b) => a > b ? a : b)) * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              CurrencyFormatter.format(rod.toY),
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < weeklyData.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    weeklyData[value.toInt()].label,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: weeklyData.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.value,
                              color: entry.key == weeklyData.length - 1 
                                  ? AppTheme.primaryGreen 
                                  : AppTheme.primaryGreen.withOpacity(0.3),
                              width: 30, // Thinner bars
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: (weeklyData.map((e) => e.value).reduce((a, b) => a > b ? a : b)) * 1.2,
                                color: Colors.grey[100],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacing20),
          
          Text(
            'Order Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          
          Row(
            children: [
              _buildStatBox(
                context,
                'Pending',
                stats.pendingOrders.toString(),
                Icons.pending_actions,
                Colors.orange,
              ),
              const SizedBox(width: AppTheme.spacing16),
              _buildStatBox(
                context,
                'Active',
                stats.activeOrders.toString(),
                Icons.local_fire_department,
                Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          Row(
            children: [
              _buildStatBox(
                context,
                'Completed',
                (stats.weekOrders - stats.activeOrders - stats.pendingOrders).toString(),
                Icons.check_circle_outline,
                AppTheme.primaryGreen,
              ),
              const SizedBox(width: AppTheme.spacing16),
              _buildStatBox(
                context,
                'Total (Week)',
                stats.weekOrders.toString(),
                Icons.receipt_long,
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final String label;
  final double value;

  _ChartData(this.label, this.value);
}
