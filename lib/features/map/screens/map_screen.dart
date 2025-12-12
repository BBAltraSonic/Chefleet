import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/app_theme.dart';

import '../../../shared/widgets/glass_container.dart';
import '../utils/map_styles.dart';
import '../../feed/models/vendor_model.dart';
import '../../feed/widgets/dish_card.dart';
import '../../feed/widgets/dish_card_skeleton.dart';

import '../../dish/widgets/dish_modal.dart';
import '../blocs/map_feed_bloc.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/location_selector_sheet.dart';
import '../widgets/map_feed_empty_state.dart';
import '../widgets/personalized_header.dart';
import '../widgets/animated_map_feed_layout.dart';
import '../widgets/animated_vendor_info_card.dart';

import '../../../shared/widgets/staggered_sliver_list.dart';
import '../../feed/widgets/animated_dish_card_wrapper.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  String? _mapStyle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMapStyle();
  }

  void _updateMapStyle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    setState(() {
      _mapStyle = isDark ? MapStyles.dark : MapStyles.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapFeedBloc()..add(const MapFeedInitialized()),
      child: BlocBuilder<MapFeedBloc, MapFeedState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Stack(
              children: [
                AnimatedMapFeedLayout(
                  mapBuilder: (opacity, heightPercent) => _buildMapLayer(context, state),
                  feedBuilder: (scrollController, height) => _buildFeedContent(
                    context,
                    state,
                    scrollController,
                  ),
                  searchBarBuilder: () => _buildSearchBar(context),
                  minMapHeightPercent: 0.20,
                  maxMapHeightPercent: 0.60,
                ),
                if (state.selectedVendor != null)
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.4 + 24,
                    left: 0,
                    right: 0,
                    child: AnimatedVendorInfoCard(
                      vendor: state.selectedVendor!,
                      dishCount: state.dishes
                          .where((dish) => dish.vendorId == state.selectedVendor!.id)
                          .length,
                      distance: state.currentPosition != null
                          ? _calculateDistance(
                              state.currentPosition!.latitude,
                              state.currentPosition!.longitude,
                              state.selectedVendor!.latitude,
                              state.selectedVendor!.longitude,
                            )
                          : null,
                      onClose: () {
                        context.read<MapFeedBloc>().add(const MapVendorDeselected());
                      },
                      onViewMenu: () {
                        // TODO: Navigate to vendor details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Navigate to Vendor Menu')),
                        );
                      },
                      onCall: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Call Vendor')),
                        );
                      },
                    ),
                  ),
              ],
            ),
            floatingActionButton: _buildLocationButton(context),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }

  Widget _buildMapLayer(BuildContext context, MapFeedState state) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: state.currentPosition != null
            ? LatLng(
                state.currentPosition!.latitude,
                state.currentPosition!.longitude,
              )
            : const LatLng(37.7749, -122.4194),
        zoom: 14,
      ),
      style: _mapStyle,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      onCameraMove: (position) {
        context.read<MapFeedBloc>().add(MapZoomChanged(position.zoom));
      },
      onCameraIdle: () async {
        if (_mapController != null && mounted) {
          final bounds = await _mapController!.getVisibleRegion();
          if (mounted) {
            // ignore: use_build_context_synchronously
            context.read<MapFeedBloc>().add(MapBoundsChanged(bounds));
          }
        }
      },
      markers: Set<Marker>.from(state.markers.values),
      myLocationEnabled: true, // DEBUG: Google Maps location - may trigger permission request
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      padding: EdgeInsets.only(
        top: 120, // Space for search bar
        bottom: MediaQuery.of(context).size.height * 0.35, // Space for sheet
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      height: 56,
      blur: 18,
      opacity: 0.8,
      color: theme.cardTheme.color?.withValues(alpha: 0.9) ?? theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
      borderRadius: 30,
      child: Row(
        children: [
          // Search Icon
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.search_rounded,
              color: theme.iconTheme.color?.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
          
          // Text Field
          Expanded(
            child: TextField(
              onChanged: (value) {
                context.read<MapFeedBloc>().add(MapSearchQueryChanged(value));
              },
              decoration: InputDecoration(
                hintText: 'Search dishes, cuisines...',
                hintStyle: TextStyle(
                  color: theme.hintColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: false,
              ),
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: theme.primaryColor,
            ),
          ),

          // Location Selector Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showLocationSelector,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 24,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildFeedContent(
    BuildContext context,
    MapFeedState state,
    ScrollController scrollController,
  ) {
    final theme = Theme.of(context);
    
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // 1. Personalized Header
        const SliverToBoxAdapter(
          child: PersonalizedHeader(),
        ),

        // 2. Category Filter Bar
        SliverToBoxAdapter(
          child: CategoryFilterBar(
            selectedCategory: state.selectedCategory,
            onCategorySelected: (category) {
              context.read<MapFeedBloc>().add(
                MapCategorySelected(category),
              );
            },
          ),
        ),

        // 3. Section Title
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Recommended for you',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Dishes list - full width cards
        if (state.isLoading && state.dishes.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: DishCardSkeleton(),
                ),
                childCount: 3,
              ),
            ),
          )
        else if (state.dishes.isEmpty)
          const MapFeedEmptyState(
            title: 'No dishes found nearby',
            subtitle: 'Try adjusting your location or check back later',
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: StaggeredSliverList(
              itemCount: state.dishes.length,
              itemBuilder: (context, index, animation) {
                if (index >= state.dishes.length) return const SizedBox.shrink();

                final dish = state.dishes[index];
                final vendor = state.vendors.firstWhere(
                  (v) => v.id == dish.vendorId,
                  orElse: () => Vendor.empty(),
                );
                
                // Calculate distance
                double? distance;
                if (state.currentPosition != null) {
                  distance = _calculateDistance(
                    state.currentPosition!.latitude,
                    state.currentPosition!.longitude,
                    vendor.latitude,
                    vendor.longitude,
                  );
                }

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    )),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AnimatedDishCardWrapper(
                        index: index,
                        enableLoadAnimation: false,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => DishModal(
                              dish: dish,
                              vendor: vendor,
                            ),
                          );
                        },
                        child: DishCard(
                          dish: dish,
                          vendorName: vendor.displayName,
                          distance: distance,
                          onTap: null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Loading indicator
        if (state.isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.primaryColor,
                ),
              ),
            ),
          ),

        // Bottom padding for FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildLocationButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.42,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom In
          FloatingActionButton(
            mini: true,
            heroTag: 'zoom_in',
            backgroundColor: Theme.of(context).cardTheme.color,
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.zoomIn(),
              );
            },
            child: const Icon(Icons.add, size: 20),
          ),
          const SizedBox(height: 8),
          // Zoom Out
          FloatingActionButton(
            mini: true,
            heroTag: 'zoom_out',
            backgroundColor: Theme.of(context).cardTheme.color,
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.zoomOut(),
              );
            },
            child: const Icon(Icons.remove, size: 20),
          ),
          const SizedBox(height: 8),
          // Center on user with loading state
          BlocBuilder<MapFeedBloc, MapFeedState>(
            builder: (context, state) {
              return FloatingActionButton(
                mini: true,
                heroTag: 'center_user',
                backgroundColor: Theme.of(context).cardTheme.color,
                onPressed: state.isLoading ? null : _centerOnUser,
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, size: 20),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper for distance calculation
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
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
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationSelectorSheet(
        onLocationSelected: (address, lat, lng) {
          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(lat, lng),
                15,
              ),
            );
          }
        },
        onUseCurrentLocation: () {
          _centerOnUser();
        },
      ),
    );
  }

  Future<void> _centerOnUser() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled. Please enable them.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: Geolocator.openLocationSettings,
            ),
          ),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: Geolocator.openAppSettings,
            ),
          ),
        );
      }
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted && _mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }
}

// Math extensions
extension MathDouble on double {
  double sin() => math.sin(this);
  double cos() => math.cos(this);
  double sqrt() => math.sqrt(this);
  double asin() => math.asin(this);
  double toRadians() => this * (math.pi / 180.0);
}
