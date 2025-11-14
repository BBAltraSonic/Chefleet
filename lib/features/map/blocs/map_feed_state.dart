part of 'map_feed_bloc.dart';

abstract class MapFeedState extends Equatable {
  const MapFeedState();

  @override
  List<Object> get props => [];
}

class MapFeedInitial extends MapFeedState {
  const MapFeedInitial();
}

class MapFeedLoading extends MapFeedState {
  const MapFeedLoading();
}

class MapFeedLoaded extends MapFeedState {
  final List<Dish> dishes;
  final List<Vendor> vendors;
  final String? selectedVendorId;
  final bool isFromCache;
  final LatLngBounds? currentViewport;

  const MapFeedLoaded({
    required this.dishes,
    required this.vendors,
    this.selectedVendorId,
    this.isFromCache = false,
    this.currentViewport,
  });

  @override
  List<Object?> get props => [
        dishes,
        vendors,
        selectedVendorId,
        isFromCache,
        currentViewport,
      ];

  MapFeedLoaded copyWith({
    List<Dish>? dishes,
    List<Vendor>? vendors,
    String? selectedVendorId,
    bool? isFromCache,
    LatLngBounds? currentViewport,
  }) {
    return MapFeedLoaded(
      dishes: dishes ?? this.dishes,
      vendors: vendors ?? this.vendors,
      selectedVendorId: selectedVendorId ?? this.selectedVendorId,
      isFromCache: isFromCache ?? this.isFromCache,
      currentViewport: currentViewport ?? this.currentViewport,
    );
  }
}

class MapFeedError extends MapFeedState {
  final String message;

  const MapFeedError({required this.message});

  @override
  List<Object> get props => [message];
}

extension MapFeedStateX on MapFeedState {
  bool get isLoading => this is MapFeedLoading;
  bool get isLoaded => this is MapFeedLoaded;
  bool get hasError => this is MapFeedError;

  List<Dish> get dishes => isLoaded ? (this as MapFeedLoaded).dishes : [];
  List<Vendor> get vendors => isLoaded ? (this as MapFeedLoaded).vendors : [];
  String? get selectedVendorId => isLoaded ? (this as MapFeedLoaded).selectedVendorId : null;
  bool get isFromCache => isLoaded ? (this as MapFeedLoaded).isFromCache : false;
}