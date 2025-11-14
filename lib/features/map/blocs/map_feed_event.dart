part of 'map_feed_bloc.dart';

abstract class MapFeedEvent extends Equatable {
  const MapFeedEvent();

  @override
  List<Object> get props => [];
}

class MapFeedStarted extends MapFeedEvent {
  const MapFeedStarted();
}

class MapFeedViewportChanged extends MapFeedEvent {
  final LatLngBounds bounds;
  final double zoomLevel;

  const MapFeedViewportChanged({
    required this.bounds,
    required this.zoomLevel,
  });

  @override
  List<Object> get props => [bounds, zoomLevel];
}

class MapFeedDishesLoaded extends MapFeedEvent {
  final List<Dish> dishes;
  final bool isFromCache;

  const MapFeedDishesLoaded({
    required this.dishes,
    this.isFromCache = false,
  });

  @override
  List<Object> get props => [dishes, isFromCache];
}

class MapFeedVendorsLoaded extends MapFeedEvent {
  final List<Vendor> vendors;
  final bool isFromCache;

  const MapFeedVendorsLoaded({
    required this.vendors,
    this.isFromCache = false,
  });

  @override
  List<Object> get props => [vendors, isFromCache];
}

class MapFeedVendorSelected extends MapFeedEvent {
  final String vendorId;

  const MapFeedVendorSelected({required this.vendorId});

  @override
  List<Object> get props => [vendorId];
}

class MapFeedVendorDeselected extends MapFeedEvent {
  const MapFeedVendorDeselected();
}

class MapFeedRefreshRequested extends MapFeedEvent {
  const MapFeedRefreshRequested();
}

class MapFeedError extends MapFeedEvent {
  final String message;

  const MapFeedError({required this.message});

  @override
  List<Object> get props => [message];
}