import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/blocs/base_bloc.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/utils/vendor_cluster_manager.dart';
import '../../feed/models/dish_model.dart';
import '../../feed/models/vendor_model.dart';

class MapFeedEvent extends AppEvent {
  const MapFeedEvent();
}

class MapFeedInitialized extends MapFeedEvent {
  const MapFeedInitialized();
}

class MapSearchQueryChanged extends MapFeedEvent {
  const MapSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class MapLocationChanged extends MapFeedEvent {
  const MapLocationChanged(this.position);

  final Position position;

  @override
  List<Object?> get props => [position];
}

class MapBoundsChanged extends MapFeedEvent {
  const MapBoundsChanged(this.bounds);

  final LatLngBounds bounds;

  @override
  List<Object?> get props => [bounds];
}

class MapVendorSelected extends MapFeedEvent {
  const MapVendorSelected(this.vendor);

  final Vendor vendor;

  @override
  List<Object?> get props => [vendor];
}

class MapFeedRefreshed extends MapFeedEvent {
  const MapFeedRefreshed();
}

class MapZoomChanged extends MapFeedEvent {
  const MapZoomChanged(this.zoom);

  final double zoom;

  @override
  List<Object?> get props => [zoom];
}

class MapFeedLoadMore extends MapFeedEvent {
  const MapFeedLoadMore();
}

class MapVendorDeselected extends MapFeedEvent {
  const MapVendorDeselected();
}

class MapClusterTapped extends MapFeedEvent {
  const MapClusterTapped(this.clusterPosition, this.vendorIds);

  final LatLng clusterPosition;
  final List<String> vendorIds;

  @override
  List<Object?> get props => [clusterPosition, vendorIds];
}

class MapMarkersUpdated extends MapFeedEvent {
  const MapMarkersUpdated(this.markers);

  final Set<Marker> markers;

  @override
  List<Object?> get props => [markers];
}

class MapFeedState extends AppState {
  const MapFeedState({
    this.currentPosition,
    this.mapBounds,
    this.vendors = const [],
    this.dishes = const [],
    this.selectedVendor,
    this.markers = const {},
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMoreData = true,
    this.currentPage = 0,
    this.errorMessage,
    this.lastUpdated,
    this.isOffline = false,
    this.zoomLevel = 15.0,
    this.searchQuery = '',
  });

  final Position? currentPosition;
  final LatLngBounds? mapBounds;
  final List<Vendor> vendors;
  final List<Dish> dishes;
  final Vendor? selectedVendor;
  final Map<String, Marker> markers;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final int currentPage;
  final String? errorMessage;
  final DateTime? lastUpdated;
  final bool isOffline;
  final double zoomLevel;
  final String searchQuery;

  MapFeedState copyWith({
    Position? currentPosition,
    LatLngBounds? mapBounds,
    List<Vendor>? vendors,
    List<Dish>? dishes,
    Vendor? selectedVendor,
    Map<String, Marker>? markers,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMoreData,
    int? currentPage,
    String? errorMessage,
    DateTime? lastUpdated,
    bool? isOffline,
    double? zoomLevel,
    String? searchQuery,
  }) {
    return MapFeedState(
      currentPosition: currentPosition ?? this.currentPosition,
      mapBounds: mapBounds ?? this.mapBounds,
      vendors: vendors ?? this.vendors,
      dishes: dishes ?? this.dishes,
      selectedVendor: selectedVendor ?? this.selectedVendor,
      markers: markers ?? this.markers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isOffline: isOffline ?? this.isOffline,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        currentPosition,
        mapBounds,
        vendors,
        dishes,
        selectedVendor,
        markers,
        isLoading,
        isLoadingMore,
        hasMoreData,
        currentPage,
        errorMessage,
        lastUpdated,
        isOffline,
        zoomLevel,
        searchQuery,
      ];
}

extension MapFeedStateX on MapFeedState {
  bool get hasError => errorMessage != null;
}

class MapFeedBloc extends AppBloc<MapFeedEvent, MapFeedState> {
  MapFeedBloc() : super(const MapFeedState()) {
    on<MapFeedInitialized>(_onInitialized);
    on<MapLocationChanged>(_onLocationChanged);
    on<MapBoundsChanged>(_onBoundsChanged);
    on<MapVendorSelected>(_onVendorSelected);
    on<MapVendorDeselected>(_onVendorDeselected);
    on<MapFeedRefreshed>(_onRefreshed);
    on<MapZoomChanged>(_onZoomChanged);
    on<MapFeedLoadMore>(_onLoadMore);
    on<MapClusterTapped>(_onClusterTapped);
    on<MapMarkersUpdated>(_onMarkersUpdated);
    on<MapSearchQueryChanged>(_onSearchQueryChanged);

    _debouncer = Timer(const Duration(milliseconds: 600), () {});
  }

  Timer? _debouncer;
  Timer? _searchDebouncer;
  Timer? _clusterUpdateDebouncer;
  static const double _searchRadiusKm = 5.0;
  static const int _pageSize = 20;
  final CacheService _cacheService = CacheService();
  final VendorClusterManager _clusterManager = VendorClusterManager();

  VendorClusterManager get clusterManager => _clusterManager;

  Future<void> _onInitialized(
    MapFeedInitialized event,
    Emitter<MapFeedState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final isCacheValid = await _cacheService.isCacheValid();
      
      if (isCacheValid) {
        final cachedDishes = await _cacheService.getCachedDishes();
        final cachedVendors = await _cacheService.getCachedVendors();
        final lastUpdated = await _cacheService.getLastUpdated();
        
        if (cachedDishes.isNotEmpty && cachedVendors.isNotEmpty) {
          // Update clustering with cached vendor data
        _clusterManager.setVendors(cachedVendors);

        emit(state.copyWith(
          dishes: cachedDishes,
          vendors: cachedVendors,
          lastUpdated: lastUpdated,
          isLoading: false,
        ));

        // Trigger clustering update for cached data if bounds available
        _updateClustering(emit);
        }
      }

      final position = await _getCurrentLocation();
      if (position != null) {
        add(MapLocationChanged(position));
      }

      await _loadVendorsAndDishes(emit);

      emit(state.copyWith(
        isLoading: false,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize map: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLocationChanged(
    MapLocationChanged event,
    Emitter<MapFeedState> emit,
  ) async {
    emit(state.copyWith(
      currentPosition: event.position,
      isLoading: true,
    ));

    try {
      await _loadVendorsAndDishes(emit);
      emit(state.copyWith(
        isLoading: false,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load data for location: ${e.toString()}',
      ));
    }
  }

  void _onBoundsChanged(
    MapBoundsChanged event,
    Emitter<MapFeedState> emit,
  ) {
    emit(state.copyWith(mapBounds: event.bounds));

    // Debounce the feed refresh
    _debouncer?.cancel();
    _debouncer = Timer(const Duration(milliseconds: 600), () {
      add(const MapFeedRefreshed());
    });
  }

  Future<void> _onRefreshed(
    MapFeedRefreshed event,
    Emitter<MapFeedState> emit,
  ) async {
    if (state.mapBounds == null) return;

    emit(state.copyWith(isLoading: true));

    try {
      await _loadVendorsAndDishes(emit);
      emit(state.copyWith(
        isLoading: false,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh feed: ${e.toString()}',
      ));
    }
  }

  void _onSearchQueryChanged(
    MapSearchQueryChanged event,
    Emitter<MapFeedState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));

    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 600), () {
      add(const MapFeedRefreshed());
    });
  }

  void _onVendorSelected(
    MapVendorSelected event,
    Emitter<MapFeedState> emit,
  ) {
    emit(state.copyWith(selectedVendor: event.vendor));
  }

  void _onVendorDeselected(
    MapVendorDeselected event,
    Emitter<MapFeedState> emit,
  ) {
    emit(state.copyWith(selectedVendor: null));
  }

  void _onClusterTapped(
    MapClusterTapped event,
    Emitter<MapFeedState> emit,
  ) {
    // Get vendors in the cluster
    final clusterVendors = _clusterManager.getVendorsInCluster(
      event.clusterPosition,
      state.mapBounds!,
      state.zoomLevel,
    );

    if (clusterVendors.isEmpty) return;

    // If small cluster (2-3 vendors), zoom to show individual vendors
    if (clusterVendors.length <= 3) {
      // Calculate bounds that encompass all vendors in the cluster
      final lats = clusterVendors.map((v) => v.latitude);
      final lngs = clusterVendors.map((v) => v.longitude);

      final bounds = LatLngBounds(
        southwest: LatLng(
          lats.reduce(math.min) - 0.002,
          lngs.reduce(math.min) - 0.002,
        ),
        northeast: LatLng(
          lats.reduce(math.max) + 0.002,
          lngs.reduce(math.max) + 0.002,
        ),
      );

      // This would typically trigger a map zoom animation
      // For now, we update the bounds to show the vendors
      emit(state.copyWith(mapBounds: bounds));

      // Update zoom level to show individual markers
      final newZoomLevel = (state.zoomLevel + 2).clamp(15.0, 20.0);
      add(MapZoomChanged(newZoomLevel));
    } else {
      // For larger clusters, show a message or take no action
      emit(state.copyWith(
        errorMessage: 'Large cluster (${clusterVendors.length} vendors). Zoom in to see individual vendors.',
      ));
    }
  }

  void _onZoomChanged(
    MapZoomChanged event,
    Emitter<MapFeedState> emit,
  ) {
    emit(state.copyWith(zoomLevel: event.zoom));

    // Update clustering with new zoom level
    _updateClustering(emit);
  }

  Future<void> _onLoadMore(
    MapFeedLoadMore event,
    Emitter<MapFeedState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMoreData) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      await _loadMoreDishes(emit);
      emit(state.copyWith(
        isLoadingMore: false,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Failed to load more dishes: ${e.toString()}',
      ));
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadVendorsAndDishes(Emitter<MapFeedState> emit) async {
    final bounds = state.mapBounds;
    if (bounds == null && state.currentPosition == null) return;

    try {
      final vendorsResponse = await Supabase.instance.client
          .from('vendors')
          .select('*')
          .eq('is_active', true);

      final vendors = vendorsResponse
          .map((json) => Vendor.fromJson(json))
          .where((vendor) {
            if (bounds != null) {
              return _isPointInBounds(
                LatLng(vendor.latitude, vendor.longitude),
                bounds,
              );
            } else if (state.currentPosition != null) {
              return _isWithinRadius(
                vendor.latitude,
                vendor.longitude,
                state.currentPosition!.latitude,
                state.currentPosition!.longitude,
                _searchRadiusKm,
              );
            }
            return false;
          }).toList();

      // Load dishes from these vendors
      if (vendors.isNotEmpty) {
        final vendorIds = vendors.map((v) => v.id).toList();

        final dishesResponse = await Supabase.instance.client
            .from('dishes')
            .select('*')
            .inFilter('vendor_id', vendorIds)
            .eq('available', true)
            .order('created_at', ascending: false)
            .range(0, _pageSize - 1);

        final dishes = dishesResponse
            .map((json) => Dish.fromJson(json))
            .toList();
        
        final hasMoreData = dishes.length >= _pageSize;

        await _cacheService.cacheDishes(dishes);
        await _cacheService.cacheVendors(vendors);
        if (bounds != null) {
          await _cacheService.cacheViewport(bounds);
        }

        // Update clustering with new vendor data
        _clusterManager.setVendors(vendors);

        emit(state.copyWith(
          vendors: vendors,
          dishes: dishes,
          currentPage: 0,
          hasMoreData: hasMoreData,
        ));

        // Trigger clustering update if bounds are available
        if (bounds != null) {
          _updateClustering(emit);
        }
      } else {
        emit(state.copyWith(
          vendors: [],
          dishes: [],
          markers: {},
        ));
      }
    } catch (e) {
      final cachedDishes = await _cacheService.getCachedDishes();
      final cachedVendors = await _cacheService.getCachedVendors();
      final lastUpdated = await _cacheService.getLastUpdated();
      
      if (cachedDishes.isNotEmpty && cachedVendors.isNotEmpty) {
        // Update clustering with cached vendor data
        _clusterManager.setVendors(cachedVendors);

        emit(state.copyWith(
          dishes: cachedDishes,
          vendors: cachedVendors,
          lastUpdated: lastUpdated,
          isOffline: true,
          errorMessage: 'Network unavailable. Showing cached data.',
        ));

        // Trigger clustering update for cached data
        if (bounds != null) {
          _updateClustering(emit);
        }
      } else {
        emit(state.copyWith(
          errorMessage: 'Network unavailable and no cached data available.',
          isOffline: true,
        ));
      }
    }
  }

  bool _isPointInBounds(LatLng point, LatLngBounds bounds) {
    return point.latitude >= bounds.southwest.latitude &&
        point.latitude <= bounds.northeast.latitude &&
        point.longitude >= bounds.southwest.longitude &&
        point.longitude <= bounds.northeast.longitude;
  }

  bool _isWithinRadius(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double radiusKm,
  ) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.toRadians().cos() *
            lat2.toRadians().cos() *
            (dLon / 2).sin() *
            (dLon / 2).sin();

    final double c = 2 * a.sqrt().asin();
    final double distance = earthRadiusKm * c;

    return distance <= radiusKm;
  }

  double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180.0);
  }

  Future<void> _loadMoreDishes(Emitter<MapFeedState> emit) async {
    if (state.vendors.isEmpty) return;

    final vendorIds = state.vendors.map((v) => v.id).toList();
    final nextPage = state.currentPage + 1;
    final start = nextPage * _pageSize;
    final end = start + _pageSize - 1;

    try {
      final dishesResponse = await Supabase.instance.client
          .from('dishes')
          .select('*')
          .inFilter('vendor_id', vendorIds)
          .eq('available', true)
          .order('created_at', ascending: false)
          .range(start, end);

      final newDishes = dishesResponse
          .map((json) => Dish.fromJson(json))
          .toList();

      final hasMoreData = newDishes.length >= _pageSize;
      final allDishes = [...state.dishes, ...newDishes];

      emit(state.copyWith(
        dishes: allDishes,
        currentPage: nextPage,
        hasMoreData: hasMoreData,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load more dishes: ${e.toString()}',
      ));
    }
  }

  
  void _onMarkersUpdated(MapMarkersUpdated event, Emitter<MapFeedState> emit) {
    emit(state.copyWith(markers: {for (var m in event.markers) m.markerId.value: m}));
  }

  void _updateClustering(Emitter<MapFeedState> emit) {
    if (state.vendors.isEmpty || state.mapBounds == null) return;

    final clusterUpdateDebouncer = _clusterUpdateDebouncer;
    clusterUpdateDebouncer?.cancel();

    _clusterUpdateDebouncer = Timer(const Duration(milliseconds: 200), () {
      try {
        final markers = _clusterManager.getMarkers(
          state.mapBounds!,
          state.zoomLevel,
          state.selectedVendor?.id,
        );

        // Log clustering performance for debugging
        final metrics = _clusterManager.getPerformanceMetrics();
        if (metrics['totalClusterOperations'] % 10 == 0) {
          print('Clustering performance: ${metrics['averageClusteringTime']}ms avg, '
                '${metrics['totalItemsProcessed']} items processed');
        }

        add(MapMarkersUpdated(markers.values.toSet()));
      } catch (e) {
        // Handle clustering errors gracefully
        emit(state.copyWith(
          errorMessage: 'Clustering error: ${e.toString()}',
        ));
      }
    });
  }

  @override
  Future<void> close() {
    _debouncer?.cancel();
    _searchDebouncer?.cancel();
    _clusterUpdateDebouncer?.cancel();
    _clusterManager.clear();
    return super.close();
  }
}

extension on double {
  double toRadians() => this * (3.14159265359 / 180.0);
  double sin() => math.sin(this);
  double cos() => math.cos(this);
  double asin() => math.asin(this);
  double sqrt() => math.sqrt(this);
}