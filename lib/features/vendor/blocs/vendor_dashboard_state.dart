part of 'vendor_dashboard_bloc.dart';

class VendorStats extends Equatable {
  const VendorStats({
    required this.todayOrders,
    required this.todayRevenue,
    required this.weekOrders,
    required this.weekRevenue,
    required this.monthOrders,
    required this.monthRevenue,
    required this.pendingOrders,
    required this.activeOrders,
  });

  final int todayOrders;
  final double todayRevenue;
  final int weekOrders;
  final double weekRevenue;
  final int monthOrders;
  final double monthRevenue;
  final int pendingOrders;
  final int activeOrders;

  @override
  List<Object?> get props => [
        todayOrders,
        todayRevenue,
        weekOrders,
        weekRevenue,
        monthOrders,
        monthRevenue,
        pendingOrders,
        activeOrders,
      ];

  VendorStats copyWith({
    int? todayOrders,
    double? todayRevenue,
    int? weekOrders,
    double? weekRevenue,
    int? monthOrders,
    double? monthRevenue,
    int? pendingOrders,
    int? activeOrders,
  }) {
    return VendorStats(
      todayOrders: todayOrders ?? this.todayOrders,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      weekOrders: weekOrders ?? this.weekOrders,
      weekRevenue: weekRevenue ?? this.weekRevenue,
      monthOrders: monthOrders ?? this.monthOrders,
      monthRevenue: monthRevenue ?? this.monthRevenue,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      activeOrders: activeOrders ?? this.activeOrders,
    );
  }
}

class VendorDashboardState extends Equatable {
  const VendorDashboardState({
    this.isLoading = false,
    this.vendor,
    this.orders = const [],
    this.filteredOrders = const [],
    this.menuItems = const [],
    this.stats,
    this.statusFilter,
    this.errorMessage,
    this.successMessage,
    this.detailedAnalytics,
    this.performanceMetrics,
    this.popularItems,
  });

  final bool isLoading;
  final Map<String, dynamic>? vendor;
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> filteredOrders;
  final List<Map<String, dynamic>> menuItems;
  final VendorStats? stats;
  final String? statusFilter;
  final String? errorMessage;
  final String? successMessage;
  final Map<String, dynamic>? detailedAnalytics;
  final Map<String, dynamic>? performanceMetrics;
  final List<Map<String, dynamic>>? popularItems;

  @override
  List<Object?> get props => [
        isLoading,
        vendor,
        orders,
        filteredOrders,
        menuItems,
        stats,
        statusFilter,
        errorMessage,
        successMessage,
        detailedAnalytics,
        performanceMetrics,
        popularItems,
      ];

  VendorDashboardState copyWith({
    bool? isLoading,
    Map<String, dynamic>? vendor,
    List<Map<String, dynamic>>? orders,
    List<Map<String, dynamic>>? filteredOrders,
    List<Map<String, dynamic>>? menuItems,
    VendorStats? stats,
    String? statusFilter,
    String? errorMessage,
    String? successMessage,
    Map<String, dynamic>? detailedAnalytics,
    Map<String, dynamic>? performanceMetrics,
    List<Map<String, dynamic>>? popularItems,
  }) {
    return VendorDashboardState(
      isLoading: isLoading ?? this.isLoading,
      vendor: vendor ?? this.vendor,
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      menuItems: menuItems ?? this.menuItems,
      stats: stats ?? this.stats,
      statusFilter: statusFilter ?? this.statusFilter,
      errorMessage: errorMessage,
      successMessage: successMessage,
      detailedAnalytics: detailedAnalytics ?? this.detailedAnalytics,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      popularItems: popularItems ?? this.popularItems,
    );
  }
}