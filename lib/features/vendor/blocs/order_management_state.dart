part of 'order_management_bloc.dart';

enum OrderManagementStatus {
  initial,
  loading,
  loaded,
  error,
  updating,
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  completed,
  cancelled,
  rejected,
}

class OrderManagementState extends Equatable {
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> filteredOrders;
  final OrderManagementStatus status;
  final String? errorMessage;
  final OrderFilters filters;
  final OrderSortOption sortBy;
  final SortOrder sortOrder;
  final Map<String, String> orderStatuses;
  final int? totalOrders;
  final Map<String, int> statusCounts;
  final DateTime? lastUpdated;

  const OrderManagementState({
    this.orders = const [],
    this.filteredOrders = const [],
    this.status = OrderManagementStatus.initial,
    this.errorMessage,
    this.filters = const OrderFilters(),
    this.sortBy = OrderSortOption.orderTime,
    this.sortOrder = SortOrder.descending,
    this.orderStatuses = const {},
    this.totalOrders,
    this.statusCounts = const {},
    this.lastUpdated,
  });

  OrderManagementState copyWith({
    List<Map<String, dynamic>>? orders,
    List<Map<String, dynamic>>? filteredOrders,
    OrderManagementStatus? status,
    String? errorMessage,
    OrderFilters? filters,
    OrderSortOption? sortBy,
    SortOrder? sortOrder,
    Map<String, String>? orderStatuses,
    int? totalOrders,
    Map<String, int>? statusCounts,
    DateTime? lastUpdated,
    bool clearErrorMessage = false,
  }) {
    return OrderManagementState(
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      filters: filters ?? this.filters,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      orderStatuses: orderStatuses ?? this.orderStatuses,
      totalOrders: totalOrders ?? this.totalOrders,
      statusCounts: statusCounts ?? this.statusCounts,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        filteredOrders,
        status,
        errorMessage,
        filters,
        sortBy,
        sortOrder,
        orderStatuses,
        totalOrders,
        statusCounts,
        lastUpdated,
      ];

  // Getters for convenience
  bool get isLoading => status == OrderManagementStatus.loading;
  bool get isLoaded => status == OrderManagementStatus.loaded;
  bool get isError => status == OrderManagementStatus.error;
  bool get isUpdating => status == OrderManagementStatus.updating;
  bool get hasError => errorMessage != null;
  bool get isEmpty => filteredOrders.isEmpty;
  bool get hasFilters => filters != const OrderFilters();

  int get pendingOrdersCount => statusCounts['pending'] ?? 0;
  int get confirmedOrdersCount => statusCounts['confirmed'] ?? 0;
  int get preparingOrdersCount => statusCounts['preparing'] ?? 0;
  int get readyOrdersCount => statusCounts['ready'] ?? 0;
  int get completedOrdersCount => statusCounts['completed'] ?? 0;
  int get urgentOrdersCount => _countUrgentOrders();

  List<Map<String, dynamic>> get urgentOrders =>
      filteredOrders.where(_isUrgentOrder).toList();

  List<Map<String, dynamic>> get overdueOrders =>
      filteredOrders.where(_isOverdueOrder).toList();

  // Order status methods
  static String getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppStrings.statusNewOrder;
      case 'confirmed':
        return AppStrings.statusConfirmed;
      case 'preparing':
        return AppStrings.statusPreparing;
      case 'ready':
        return AppStrings.statusReadyForPickup;
      case 'completed':
        return AppStrings.statusCompleted;
      case 'cancelled':
        return AppStrings.statusCancelled;
      case 'rejected':
        return AppStrings.statusRejected;
      default:
        return status;
    }
  }

  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FF9500'; // Orange
      case 'confirmed':
        return '#007AFF'; // Blue
      case 'preparing':
        return '#5856D6'; // Purple
      case 'ready':
        return '#34C759'; // Green
      case 'completed':
        return '#8E8E93'; // Gray
      case 'cancelled':
        return '#FF3B30'; // Red
      case 'rejected':
        return '#FF3B30'; // Red
      default:
        return '#8E8E93'; // Gray
    }
  }

  static bool isActionableStatus(String status) {
    return ['pending', 'confirmed', 'preparing'].contains(status.toLowerCase());
  }

  static bool isFinalStatus(String status) {
    return ['completed', 'cancelled', 'rejected'].contains(status.toLowerCase());
  }

  // Private helper methods
  int _countUrgentOrders() {
    return filteredOrders.where(_isUrgentOrder).length;
  }

  bool _isUrgentOrder(Map<String, dynamic> order) {
    final pickupTime = DateTime.tryParse(order['pickup_time'] ?? '');
    if (pickupTime == null) return false;

    final now = DateTime.now();
    final timeUntilPickup = pickupTime.difference(now);

    // Consider urgent if pickup is within 30 minutes
    return timeUntilPickup.inMinutes <= 30 && timeUntilPickup.inMinutes > 0;
  }

  bool _isOverdueOrder(Map<String, dynamic> order) {
    final pickupTime = DateTime.tryParse(order['pickup_time'] ?? '');
    if (pickupTime == null) return false;

    final now = DateTime.now();
    final status = order['status']?.toString().toLowerCase() ?? '';

    return pickupTime.isBefore(now) && !isFinalStatus(status);
  }

  // Order time calculations
  String getTimeUntilPickup(String pickupTime) {
    final pickup = DateTime.tryParse(pickupTime);
    if (pickup == null) return 'Unknown';

    final now = DateTime.now();
    final difference = pickup.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    }

    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }

  double getPreparationProgress(Map<String, dynamic> order) {
    final status = order['status']?.toString().toLowerCase() ?? '';
    final createdAt = DateTime.tryParse(order['created_at'] ?? '');
    final pickupTime = DateTime.tryParse(order['pickup_time'] ?? '');

    if (createdAt == null || pickupTime == null) return 0.0;

    final totalTime = pickupTime.difference(createdAt).inMinutes;
    final elapsed = DateTime.now().difference(createdAt).inMinutes;

    switch (status) {
      case 'pending':
        return 0.0;
      case 'confirmed':
        return 0.25;
      case 'preparing':
        return 0.75;
      case 'ready':
        return 1.0;
      case 'completed':
        return 1.0;
      default:
        return elapsed > totalTime ? 1.0 : elapsed / totalTime;
    }
  }
}