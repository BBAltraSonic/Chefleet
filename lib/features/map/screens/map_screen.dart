import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../feed/models/vendor_model.dart';
import '../../feed/widgets/dish_card.dart';
import '../../feed/widgets/vendor_mini_card.dart';
import '../blocs/map_feed_bloc.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

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
                // 1. Map Layer
                _buildMapLayer(context, state),

                // 2. Top Search Bar
                _buildSearchBar(context),

                // 3. Draggable Feed Sheet
                _buildFeedSheet(context, state),
                
                // 4. Loading Overlay (if initial load)
                if (state.isLoading && state.dishes.isEmpty)
                  Container(
                    color: AppTheme.backgroundColor,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                    ),
                  ),

                // 5. Vendor Mini Card (if selected)
                if (state.selectedVendor != null)
                   Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.4 + 20, // Position above sheet
                    left: 16,
                    right: 16,
                    child: VendorMiniCard(
                      vendor: state.selectedVendor!,
                      onClose: () {
                        context.read<MapFeedBloc>().add(const MapVendorDeselected());
                      },
                      onViewDetails: () {
                        // TODO: Navigate to vendor details
                      },
                      dishCount: state.dishes
                          .where((dish) => dish.vendorId == state.selectedVendor!.id)
                          .length,
                    ),
                  ),
              ],
            ),
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
      onMapCreated: (controller) {
        _mapController = controller;
        // Set map style here if needed
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
      myLocationEnabled: true,
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
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: GlassContainer(
        blur: 15,
        opacity: 0.8,
        borderRadius: AppTheme.radiusLarge,
        color: AppTheme.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppTheme.secondaryGreen),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search dishes, cuisines...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.darkText.withOpacity(0.5),
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune, size: 20, color: AppTheme.darkText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedSheet(BuildContext context, MapFeedState state) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.4,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.15, 0.4, 0.9],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // Header
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nearby Dishes',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            if (state.isOffline)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.cloud_off, size: 14, color: Colors.orange),
                                    SizedBox(width: 4),
                                    Text(
                                      'Offline',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Dishes List
                    if (state.dishes.isEmpty && !state.isLoading)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 48,
                                color: AppTheme.secondaryGreen.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No dishes found nearby',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= state.dishes.length) {
                              // Loading indicator at bottom
                              if (state.isLoadingMore) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return const SizedBox(height: 80); // Bottom padding
                            }

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

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: DishCard(
                                dish: dish,
                                vendorName: vendor.displayName,
                                distance: distance,
                                onTap: () {
                                  context.push('/dish/${dish.id}');
                                },
                              ),
                            );
                          },
                          childCount: state.dishes.length + 1, // +1 for bottom padding/loader
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
}

// Math extensions
extension MathDouble on double {
  double sin() => math.sin(this);
  double cos() => math.cos(this);
  double sqrt() => math.sqrt(this);
  double asin() => math.asin(this);
  double toRadians() => this * (math.pi / 180.0);
}
