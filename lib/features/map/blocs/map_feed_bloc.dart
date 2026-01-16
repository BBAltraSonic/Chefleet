import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/timing_constants.dart';
import '../../../core/diagnostics/diagnostic_domains.dart';
import '../../../core/diagnostics/diagnostic_harness.dart';
import '../../../core/diagnostics/diagnostic_severity.dart';
import '../../../core/blocs/base_bloc.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/vendor_cluster_manager.dart';
import '../../feed/models/dish_model.dart';
import '../../feed/models/vendor_model.dart';

const _undefined = Object();

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

class MapCategorySelected extends MapFeedEvent {
  const MapCategorySelected(this.category);

  final String category;

  @override
  List<Object?> get props => [category];
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
    this.allDishes = const [],
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
    this.selectedCategory = 'All',
  });

  final Position? currentPosition;
  final LatLngBounds? mapBounds;
  final List<Vendor> vendors;
  final List<Dish> dishes;
  final List<Dish> allDishes;
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
  final String selectedCategory;

  MapFeedState copyWith({
    Object? currentPosition = _undefined,
    Object? mapBounds = _undefined,
    List<Vendor>? vendors,
    List<Dish>? dishes,
    List<Dish>? allDishes,
    Object? selectedVendor = _undefined,
    Map<String, Marker>? markers,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMoreData,
    int? currentPage,
    Object? errorMessage = _undefined,
    Object? lastUpdated = _undefined,
    bool? isOffline,
    double? zoomLevel,
    Object? searchQuery = _undefined,
    Object? selectedCategory = _undefined,
  }) {
    return MapFeedState(
      currentPosition: currentPosition == _undefined ? this.currentPosition : currentPosition as Position?,
      mapBounds: mapBounds == _undefined ? this.mapBounds : mapBounds as LatLngBounds?,
      vendors: vendors ?? this.vendors,
      dishes: dishes ?? this.dishes,
      allDishes: allDishes ?? this.allDishes,
      selectedVendor: selectedVendor == _undefined ? this.selectedVendor : selectedVendor as Vendor?,
      markers: markers ?? this.markers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage == _undefined ? this.errorMessage : errorMessage as String?,
      lastUpdated: lastUpdated == _undefined ? this.lastUpdated : lastUpdated as DateTime?,
      isOffline: isOffline ?? this.isOffline,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      searchQuery: searchQuery == _undefined ? this.searchQuery : searchQuery as String,
      selectedCategory: selectedCategory == _undefined ? this.selectedCategory : selectedCategory as String,
    );
  }

  @override
  List<Object?> get props => [
        currentPosition,
        mapBounds,
        vendors,
        dishes,
        allDishes,
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
        selectedCategory,
      ];
}

extension MapFeedStateX on MapFeedState {
  bool get hasError => errorMessage != null;
}

class MapFeedBloc extends AppBloc<MapFeedEvent, MapFeedState> {
  MapFeedBloc({
    SupabaseClient? supabaseClient,
    VendorClusterManager? clusterManager,
  })  : _supabaseClient = supabaseClient ?? Supabase.instance.client,
        _clusterManager = clusterManager ?? VendorClusterManager(),
        super(const MapFeedState()) {
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
    on<MapCategorySelected>(_onCategorySelected);

    _debouncer = Timer(const Duration(milliseconds: 600), () {});
  }

  Timer? _debouncer;
  Timer? _searchDebouncer;
  Timer? _clusterUpdateDebouncer;
  LatLngBounds? _lastRefreshBounds;
  static const double _searchRadiusKm = 5.0;
  static const int _pageSize = 20;
  static const double _boundsChangeThreshold = 0.1;
  final CacheService _cacheService = CacheService();
  final SupabaseClient _supabaseClient;
  final VendorClusterManager _clusterManager;
  final DiagnosticHarness _diagnostics = DiagnosticHarness.instance;

  VendorClusterManager get clusterManager => _clusterManager;

  Future<void> _onInitialized(
    MapFeedInitialized event,
    Emitter<MapFeedState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      isOffline: false,
    ));
    _logMap(
      'initialize.start',
      severity: DiagnosticSeverity.debug,
    );

    try {
      // Allow UI to render by yielding to the event loop
      await Future.delayed(const Duration(milliseconds: 100));
      
      final isCacheValid = await _cacheService.isCacheValid();
      
      if (isCacheValid) {
        final cachedDishes = await _cacheService.getCachedDishes();
        final cachedVendors = await _cacheService.getCachedVendors();
        final lastUpdated = await _cacheService.getLastUpdated();
        
        if (cachedDishes.isNotEmpty && cachedVendors.isNotEmpty) {
          // Update clustering with cached vendor data
        _clusterManager.setVendors(cachedVendors);
        _logMap(
          'cache.hit',
          severity: DiagnosticSeverity.debug,
          payload: {
            'dishes': cachedDishes.length,
            'vendors': cachedVendors.length,
          },
        );

        // Apply category filter if not 'All'
        final displayDishes = state.selectedCategory == 'All'
            ? cachedDishes
            : cachedDishes.where((dish) {
                if (dish.tags.isNotEmpty) {
                  return dish.tags.any((tag) =>
                    tag.toLowerCase().contains(state.selectedCategory.toLowerCase())
                  );
                }
                return dish.name.toLowerCase().contains(state.selectedCategory.toLowerCase());
              }).toList();

        emit(state.copyWith(
          dishes: displayDishes,
          allDishes: cachedDishes,
          vendors: cachedVendors,
          lastUpdated: lastUpdated,
          isLoading: false,
        ));

        // Trigger clustering update for cached data if bounds available
        _updateClustering(emit);
        }
      }

      // Get location before loading data to ensure we have position or bounds
      try {
        debugPrint('🔍 MapFeedBloc: Fetching current location...');
        final position = await _getCurrentLocation();
        if (position != null) {
          debugPrint('✅ MapFeedBloc: Location obtained: ${position.latitude}, ${position.longitude}');
          emit(state.copyWith(currentPosition: position));
          _logMap(
            'location.success',
            payload: {
              'lat': position.latitude,
              'lng': position.longitude,
            },
          );
        } else {
          debugPrint('⚠️ MapFeedBloc: Location is null, will load all vendors');
          _logMap(
            'location.null',
            severity: DiagnosticSeverity.warn,
          );
        }
      } catch (e) {
        // Silently fail location, app can work without it
        debugPrint('❌ MapFeedBloc: Location error: $e');
        _logMap(
          'location.error',
          severity: DiagnosticSeverity.error,
          payload: {'message': e.toString()},
        );
      }

      debugPrint('📥 MapFeedBloc: Loading vendors and dishes...');
      await _loadVendorsAndDishes(emit);
      debugPrint('✅ MapFeedBloc: Loaded ${state.dishes.length} dishes, ${state.vendors.length} vendors');
      _logMap(
        'initialize.success',
        payload: {
          'vendors': state.vendors.length,
          'dishes': state.dishes.length,
        },
      );

      emit(state.copyWith(
        isLoading: false,
        lastUpdated: DateTime.now(),
        errorMessage: null,
        isOffline: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize map: ${e.toString()}',
        isOffline: false,
      ));
      _logMap(
        'initialize.error',
        severity: DiagnosticSeverity.error,
        payload: {'message': e.toString()},
      );
    }
  }

  Future<void> _onLocationChanged(
    MapLocationChanged event,
    Emitter<MapFeedState> emit,
  ) async {
    emit(state.copyWith(
      currentPosition: event.position,
      isLoading: true,
      errorMessage: null,
      isOffline: false,
    ));

    try {
      await _loadVendorsAndDishes(emit);
      emit(state.copyWith(
        isLoading: false,
        lastUpdated: DateTime.now(),
        errorMessage: null,
        isOffline: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load data for location: ${e.toString()}',
        isOffline: false,
      ));
    }
  }

  void _onBoundsChanged(
    MapBoundsChanged event,
    Emitter<MapFeedState> emit,
  ) {
    emit(state.copyWith(mapBounds: event.bounds));
    
    if (kDebugMode) {
      _logMap(
        'bounds.changed',
        severity: DiagnosticSeverity.debug,
        payload: {
          ..._boundsPayload(event.bounds),
          'hasVendors': state.vendors.isNotEmpty,
          'vendorCount': state.vendors.length,
        },
      );
    }

    if (state.vendors.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('🎯 MapFeedBloc: Bounds changed, generating markers for ${state.vendors.length} vendors');
      }
      _updateClustering(emit);
    } else {
      if (kDebugMode) {
        debugPrint('🔄 MapFeedBloc: Bounds changed but no vendors yet, will trigger data refresh');
      }
    }

    final shouldRefresh = _shouldRefreshData(event.bounds);
    
    _debouncer?.cancel();
    if (shouldRefresh) {
      _debouncer = Timer(TimingConstants.mapDebounce, () {
        _lastRefreshBounds = event.bounds;
        add(const MapFeedRefreshed());
      });
    }
  }

  bool _shouldRefreshData(LatLngBounds newBounds) {
    if (state.vendors.isEmpty) return true;
    
    if (_lastRefreshBounds == null) {
      return true;
    }

    final latDelta = (newBounds.northeast.latitude - newBounds.southwest.latitude).abs();
    final lngDelta = (newBounds.northeast.longitude - newBounds.southwest.longitude).abs();
    
    final lastLatDelta = (_lastRefreshBounds!.northeast.latitude - _lastRefreshBounds!.southwest.latitude).abs();
    final lastLngDelta = (_lastRefreshBounds!.northeast.longitude - _lastRefreshBounds!.southwest.longitude).abs();
    
    final latChange = ((latDelta - lastLatDelta) / lastLatDelta).abs();
    final lngChange = ((lngDelta - lastLngDelta) / lastLngDelta).abs();
    
    final centerLat = (newBounds.northeast.latitude + newBounds.southwest.latitude) / 2;
    final centerLng = (newBounds.northeast.longitude + newBounds.southwest.longitude) / 2;
    final lastCenterLat = (_lastRefreshBounds!.northeast.latitude + _lastRefreshBounds!.southwest.latitude) / 2;
    final lastCenterLng = (_lastRefreshBounds!.northeast.longitude + _lastRefreshBounds!.southwest.longitude) / 2;
    
    final centerLatChange = ((centerLat - lastCenterLat) / latDelta).abs();
    final centerLngChange = ((centerLng - lastCenterLng) / lngDelta).abs();
    
    final isSignificantChange = latChange > _boundsChangeThreshold || 
                               lngChange > _boundsChangeThreshold ||
                               centerLatChange > _boundsChangeThreshold ||
                               centerLngChange > _boundsChangeThreshold;
    
    return isSignificantChange;
  }

  Future<void> _onRefreshed(
    MapFeedRefreshed event,
    Emitter<MapFeedState> emit,
  ) async {
    if (state.mapBounds == null) return;
    _logMap(
      'feed.refresh.request',
      severity: DiagnosticSeverity.debug,
      payload: _boundsPayload(state.mapBounds!),
    );

    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      isOffline: false,
    ));

    try {
      await _loadVendorsAndDishes(emit);
      emit(state.copyWith(
        isLoading: false,
        lastUpdated: DateTime.now(),
        errorMessage: null,
        isOffline: false,
      ));
      _logMap(
        'feed.refresh.success',
        payload: {
          'vendors': state.vendors.length,
          'dishes': state.dishes.length,
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh feed: ${e.toString()}',
        isOffline: false,
      ));
      _logMap(
        'feed.refresh.error',
        severity: DiagnosticSeverity.error,
        payload: {'message': e.toString()},
      );
    }
  }

  void _onSearchQueryChanged(
    MapSearchQueryChanged event,
    Emitter<MapFeedState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
    _logMap(
      'search.query_changed',
      severity: DiagnosticSeverity.debug,
      payload: {'query': event.query},
    );

    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(TimingConstants.searchDebounce, () {
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

  void _onCategorySelected(
    MapCategorySelected event,
    Emitter<MapFeedState> emit,
  ) {
    // Use allDishes if available, otherwise use dishes as the source
    final sourceDishes = state.allDishes.isNotEmpty ? state.allDishes : state.dishes;
    
    // Filter dishes by category
    final filteredDishes = event.category == 'All'
        ? sourceDishes
        : sourceDishes.where((dish) {
            // Check if dish has tags and if any tag contains the category
            if (dish.tags.isNotEmpty) {
              return dish.tags.any((tag) =>
                tag.toLowerCase().contains(event.category.toLowerCase())
              );
            }
            // If no tags, also check dish name for category match
            return dish.name.toLowerCase().contains(event.category.toLowerCase());
          }).toList();
    
    emit(state.copyWith(
      selectedCategory: event.category,
      dishes: filteredDishes,
    ));
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
    _logMap(
      'zoom.changed',
      severity: DiagnosticSeverity.debug,
      payload: {'zoom': event.zoom},
    );

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
    return await LocationService().getCurrentPosition();
  }

  Future<void> _loadVendorsAndDishes(Emitter<MapFeedState> emit) async {
    final bounds = state.mapBounds;
    final hasLocationContext = bounds != null || state.currentPosition != null;
    _logMap(
      'data.load.request',
      severity: DiagnosticSeverity.debug,
      payload: {
        'hasBounds': bounds != null,
        'hasPosition': state.currentPosition != null,
        'searchQuery': state.searchQuery,
      },
    );
    
    debugPrint('📍 MapFeedBloc: hasLocationContext=$hasLocationContext, bounds=$bounds, position=${state.currentPosition}');
    
    // If no location context, we'll load all vendors (fallback for feed screen)
    // The map screen will have bounds, feed screen should have position, 
    // but if neither is available, we load without filtering

    try {
      debugPrint('🔄 MapFeedBloc: Fetching vendors from Supabase...');
      final vendorsResponse = await _supabaseClient
          .from('vendors')
          .select('*')
          .eq('is_active', true);

      debugPrint('📦 MapFeedBloc: Received ${vendorsResponse.length} vendors from database');

      final vendors = vendorsResponse
          .map((json) => Vendor.fromJson(json))
          .where((vendor) {
            // If we have no location context, include all vendors
            if (!hasLocationContext) return true;
            
            // Prioritize bounds-based filtering to support panning
            // This ensures users can see vendors by moving the map
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

      debugPrint('✅ MapFeedBloc: Filtered to ${vendors.length} vendors');
      _logMap(
        'vendors.loaded',
        payload: {'count': vendors.length},
      );

      // Load dishes from these vendors
      if (vendors.isNotEmpty) {
        final vendorIds = vendors.map((v) => v.id).toList();

        debugPrint('🔄 MapFeedBloc: Fetching dishes from ${vendors.length} vendors...');
        final dishesResponse = await _supabaseClient
            .from('dishes')
            .select('*')
            .inFilter('vendor_id', vendorIds)
            .eq('available', true)
            .order('created_at', ascending: false)
            .range(0, _pageSize - 1);

        debugPrint('📦 MapFeedBloc: Received ${dishesResponse.length} dishes from database');

        final dishes = dishesResponse
            .map((json) => Dish.fromJson(json))
            .toList();
        
        final hasMoreData = dishes.length >= _pageSize;
        debugPrint('💾 MapFeedBloc: Parsed ${dishes.length} dishes, hasMore=$hasMoreData');

        await _cacheService.cacheDishes(dishes);
        await _cacheService.cacheVendors(vendors);
        if (bounds != null) {
          await _cacheService.cacheViewport(bounds);
        }
        _logMap(
          'cache.update',
          severity: DiagnosticSeverity.debug,
          payload: {
            'dishes': dishes.length,
            'vendors': vendors.length,
          },
        );

        // Update clustering with new vendor data
        _clusterManager.setVendors(vendors);

        // Apply category filter if not 'All'
        final displayDishes = state.selectedCategory == 'All'
            ? dishes
            : dishes.where((dish) {
                if (dish.tags.isNotEmpty) {
                  return dish.tags.any((tag) =>
                    tag.toLowerCase().contains(state.selectedCategory.toLowerCase())
                  );
                }
                return dish.name.toLowerCase().contains(state.selectedCategory.toLowerCase());
              }).toList();

        emit(state.copyWith(
          vendors: vendors,
          dishes: displayDishes,
          allDishes: dishes,
          currentPage: 0,
          hasMoreData: hasMoreData,
          isOffline: false,
          errorMessage: null,
        ));

        // Trigger clustering update if bounds are available
        if (bounds != null) {
          _updateClustering(emit);
        }
      } else {
        debugPrint('⚠️ MapFeedBloc: No vendors found, emitting empty state');
        emit(state.copyWith(
          vendors: [],
          dishes: [],
          markers: {},
          isOffline: false,
          errorMessage: null,
        ));
      }
    } catch (e) {
      debugPrint('❌ MapFeedBloc: Error in _loadVendorsAndDishes: $e');
      // Check if it's a network error
      final isNetworkError = e.toString().contains('SocketException') ||
          e.toString().contains('NetworkException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Connection timed out');
      
      if (!isNetworkError) {
        // For non-network errors, show the actual error
        emit(state.copyWith(
          errorMessage: 'Error loading data: ${e.toString()}',
          isOffline: false,
        ));
        _logMap(
          'data.load.error',
          severity: DiagnosticSeverity.error,
          payload: {'message': e.toString()},
        );
        return;
      }
      
      final cachedDishes = await _cacheService.getCachedDishes();
      final cachedVendors = await _cacheService.getCachedVendors();
      final lastUpdated = await _cacheService.getLastUpdated();
      
      if (cachedDishes.isNotEmpty && cachedVendors.isNotEmpty) {
        // Update clustering with cached vendor data
        _clusterManager.setVendors(cachedVendors);

        // Apply category filter if not 'All'
        final displayDishes = state.selectedCategory == 'All'
            ? cachedDishes
            : cachedDishes.where((dish) {
                if (dish.tags.isNotEmpty) {
                  return dish.tags.any((tag) =>
                    tag.toLowerCase().contains(state.selectedCategory.toLowerCase())
                  );
                }
                return dish.name.toLowerCase().contains(state.selectedCategory.toLowerCase());
              }).toList();

        emit(state.copyWith(
          dishes: displayDishes,
          allDishes: cachedDishes,
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
        _logMap(
          'data.load.failure_no_cache',
          severity: DiagnosticSeverity.error,
          payload: {'message': e.toString()},
        );
      }
    }
  }

  void _logMap(
    String event, {
    DiagnosticSeverity severity = DiagnosticSeverity.info,
    Map<String, Object?> payload = const <String, Object?>{},
  }) {
    _diagnostics.log(
      domain: DiagnosticDomains.buyerMapFeed,
      event: event,
      severity: severity,
      payload: payload,
    );
  }

  Map<String, Object?> _boundsPayload(LatLngBounds bounds) {
    return {
      'southwestLat': bounds.southwest.latitude,
      'southwestLng': bounds.southwest.longitude,
      'northeastLat': bounds.northeast.latitude,
      'northeastLng': bounds.northeast.longitude,
    };
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
      final dishesResponse = await _supabaseClient
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
    if (kDebugMode) {
      debugPrint('📍 MapFeedBloc: Markers updated, count=${event.markers.length}');
      _logMap(
        'markers.updated',
        severity: DiagnosticSeverity.debug,
        payload: {'markerCount': event.markers.length},
      );
    }
    emit(state.copyWith(markers: {for (var m in event.markers) m.markerId.value: m}));
  }

  void _updateClustering(Emitter<MapFeedState> emit) {
    if (state.vendors.isEmpty || state.mapBounds == null) {
      if (kDebugMode) {
        debugPrint('⚠️ MapFeedBloc._updateClustering: Early return - vendors=${state.vendors.length}, hasBounds=${state.mapBounds != null}');
        _logMap(
          'clustering.skipped',
          severity: DiagnosticSeverity.warn,
          payload: {
            'vendorCount': state.vendors.length,
            'hasBounds': state.mapBounds != null,
          },
        );
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('🔄 MapFeedBloc._updateClustering: Starting clustering for ${state.vendors.length} vendors at zoom ${state.zoomLevel}');
      _logMap(
        'clustering.start',
        severity: DiagnosticSeverity.debug,
        payload: {
          'vendorCount': state.vendors.length,
          'zoomLevel': state.zoomLevel,
          'boundsCenter': {
            'lat': (state.mapBounds!.northeast.latitude + state.mapBounds!.southwest.latitude) / 2,
            'lng': (state.mapBounds!.northeast.longitude + state.mapBounds!.southwest.longitude) / 2,
          },
        },
      );
    }

    final clusterUpdateDebouncer = _clusterUpdateDebouncer;
    clusterUpdateDebouncer?.cancel();

    _clusterUpdateDebouncer = Timer(const Duration(milliseconds: 200), () async {
      try {
        if (kDebugMode) {
          debugPrint('🎨 MapFeedBloc: Generating markers...');
        }
        final markers = await _clusterManager.getMarkers(
          state.mapBounds!,
          state.zoomLevel,
          state.selectedVendor?.id,
        );

        if (kDebugMode) {
          debugPrint('✅ MapFeedBloc: Generated ${markers.length} markers');
          _logMap(
            'clustering.complete',
            payload: {'markerCount': markers.length},
          );

          final metrics = _clusterManager.getPerformanceMetrics();
          if (metrics['totalClusterOperations'] % 10 == 0) {
            debugPrint('📊 Clustering performance: ${metrics['averageClusteringTime']}ms avg, '
                  '${metrics['totalItemsProcessed']} items processed');
          }
        }

        add(MapMarkersUpdated(markers.values.toSet()));
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ MapFeedBloc: Clustering error: $e');
          _logMap(
            'clustering.error',
            severity: DiagnosticSeverity.error,
            payload: {'message': e.toString()},
          );
        }
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