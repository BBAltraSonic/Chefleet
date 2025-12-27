part of 'vendor_dashboard_bloc.dart';

abstract class VendorDashboardEvent extends Equatable {
  const VendorDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends VendorDashboardEvent {
  const LoadDashboardData();
}

class LoadOrders extends VendorDashboardEvent {
  const LoadOrders({
    required this.vendorId,
    this.statusFilter,
  });

  final String vendorId;
  final String? statusFilter;

  @override
  List<Object?> get props => [vendorId, statusFilter];
}

class LoadOrderStats extends VendorDashboardEvent {
  const LoadOrderStats({
    required this.vendorId,
  });

  final String vendorId;

  @override
  List<Object?> get props => [vendorId];
}

class UpdateOrderStatus extends VendorDashboardEvent {
  const UpdateOrderStatus({
    required this.orderId,
    required this.newStatus,
    this.notes,
  });

  final String orderId;
  final String newStatus;
  final String? notes;

  @override
  List<Object?> get props => [orderId, newStatus, notes];
}

class LoadMenuItems extends VendorDashboardEvent {
  const LoadMenuItems({
    required this.vendorId,
  });

  final String vendorId;

  @override
  List<Object?> get props => [vendorId];
}

class UpdateMenuItemAvailability extends VendorDashboardEvent {
  const UpdateMenuItemAvailability({
    required this.itemId,
    required this.isAvailable,
  });

  final String itemId;
  final bool isAvailable;

  @override
  List<Object?> get props => [itemId, isAvailable];
}

class SubscribeToOrderUpdates extends VendorDashboardEvent {
  const SubscribeToOrderUpdates({
    required this.vendorId,
  });

  final String vendorId;

  @override
  List<Object?> get props => [vendorId];
}

class UnsubscribeFromOrderUpdates extends VendorDashboardEvent {
  const UnsubscribeFromOrderUpdates();
}

class VerifyPickupCode extends VendorDashboardEvent {
  const VerifyPickupCode({
    required this.orderId,
    required this.pickupCode,
  });

  final String orderId;
  final String pickupCode;

  @override
  List<Object?> get props => [orderId, pickupCode];
}

class RefreshDashboard extends VendorDashboardEvent {
  const RefreshDashboard();
}

class LoadDetailedAnalytics extends VendorDashboardEvent {
  const LoadDetailedAnalytics({required this.vendorId});
  final String vendorId;
  @override
  List<Object?> get props => [vendorId];
}

class LoadPerformanceMetrics extends VendorDashboardEvent {
  const LoadPerformanceMetrics({required this.vendorId});
  final String vendorId;
  @override
  List<Object?> get props => [vendorId];
}

class LoadPopularItems extends VendorDashboardEvent {
  const LoadPopularItems({required this.vendorId});
  final String vendorId;
  @override
  List<Object?> get props => [vendorId];
}