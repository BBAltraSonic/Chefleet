part of 'order_management_bloc.dart';

abstract class OrderManagementEvent extends Equatable {
  const OrderManagementEvent();

  @override
  List<Object> get props => [];
}

class LoadOrders extends OrderManagementEvent {
  final String? statusFilter;

  const LoadOrders({this.statusFilter});
}

class UpdateOrderStatus extends OrderManagementEvent {
  final String orderId;
  final String newStatus;
  final String? note;

  const UpdateOrderStatus({
    required this.orderId,
    required this.newStatus,
    this.note,
  });

  @override
  List<Object> get props => [orderId, newStatus, note ?? ''];
}

class AcceptOrder extends OrderManagementEvent {
  final String orderId;
  final int estimatedPrepTime;

  const AcceptOrder({
    required this.orderId,
    required this.estimatedPrepTime,
  });

  @override
  List<Object> get props => [orderId, estimatedPrepTime];
}

class RejectOrder extends OrderManagementEvent {
  final String orderId;
  final String reason;

  const RejectOrder({
    required this.orderId,
    required this.reason,
  });

  @override
  List<Object> get props => [orderId, reason];
}

class StartOrderPreparation extends OrderManagementEvent {
  final String orderId;

  const StartOrderPreparation({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class CompleteOrder extends OrderManagementEvent {
  final String orderId;

  const CompleteOrder({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class MarkOrderReady extends OrderManagementEvent {
  final String orderId;

  const MarkOrderReady({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class AddOrderNote extends OrderManagementEvent {
  final String orderId;
  final String note;
  final bool isInternal;

  const AddOrderNote({
    required this.orderId,
    required this.note,
    this.isInternal = true,
  });

  @override
  List<Object> get props => [orderId, note, isInternal];
}

class FilterOrders extends OrderManagementEvent {
  final OrderFilters filters;

  const FilterOrders({required this.filters});

  @override
  List<Object> get props => [filters];
}

class SortOrders extends OrderManagementEvent {
  final OrderSortOption sortBy;
  final SortOrder sortOrder;

  const SortOrders({
    required this.sortBy,
    required this.sortOrder,
  });

  @override
  List<Object> get props => [sortBy, sortOrder];
}

class RefreshOrders extends OrderManagementEvent {
  const RefreshOrders();
}

class OrderUpdated extends OrderManagementEvent {
  final Map<String, dynamic> orderData;

  const OrderUpdated({required this.orderData});

  @override
  List<Object> get props => [orderData];
}

class OrderFilters extends Equatable {
  final String? status;
  final String? timeRange;
  final String? customerId;
  final int? minAmount;
  final int? maxAmount;
  final bool urgentOnly;

  const OrderFilters({
    this.status,
    this.timeRange,
    this.customerId,
    this.minAmount,
    this.maxAmount,
    this.urgentOnly = false,
  });

  @override
  List<Object?> get props => [
        status,
        timeRange,
        customerId,
        minAmount,
        maxAmount,
        urgentOnly,
      ];

  OrderFilters copyWith({
    String? status,
    String? timeRange,
    String? customerId,
    int? minAmount,
    int? maxAmount,
    bool? urgentOnly,
  }) {
    return OrderFilters(
      status: status ?? this.status,
      timeRange: timeRange ?? this.timeRange,
      customerId: customerId ?? this.customerId,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      urgentOnly: urgentOnly ?? this.urgentOnly,
    );
  }
}

enum OrderSortOption {
  orderTime,
  pickupTime,
  customerName,
  totalAmount,
  priority,
  preparationTime,
}

enum SortOrder {
  ascending,
  descending,
}