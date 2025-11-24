import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../cart/cart.dart';
import '../../feed/models/vendor_model.dart';
import '../../feed/widgets/dish_card.dart';
import '../../feed/widgets/vendor_mini_card.dart';
import '../blocs/map_feed_bloc.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/personalized_header.dart';

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
                      child: CircularProgressIndicator(color: AppTheme.primaryColor),
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
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: [
              // Search Icon
              const Padding(
                padding: EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Icons.search_rounded,
                  color: Color(0xFF6B7280), // Grey 500
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
                      color: Colors.grey[400],
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF1F2937), // Grey 800
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  cursorColor: AppTheme.primaryColor,
                ),
              ),

              // Filter Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // TODO: Implement filter
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),

              // Vertical Divider
              Container(
                height: 24,
                width: 1,
                color: Colors.grey[200],
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),

              // Profile Avatar Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.go(CustomerRoutes.profile);
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 20,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
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
            color: Colors.grey[50], // Light gray background for Savor AI style
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
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
              
              // Content with personalized header and category filters
              Expanded(
                child: CustomScrollView(
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    // Dishes list - full width cards
                    if (state.dishes.isEmpty && !state.isLoading)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 64,
                                color: AppTheme.primaryColor.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No dishes found nearby',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your location or check back later',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= state.dishes.length) return null;

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
                                padding: const EdgeInsets.only(bottom: 16),
                                child: DishCard(
                                  dish: dish,
                                  vendorName: vendor.displayName,
                                  distance: distance,
                                  onTap: () {
                                    context.push(CustomerRoutes.dishDetail(dish.id));
                                  },
                                  onAddToCart: () {
                                    context.read<CartBloc>().add(
                                      AddToCart(dish, quantity: 1),
                                    );
                                    
                                    // Show feedback
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${dish.name} added to cart'),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: AppTheme.primaryColor,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            childCount: state.dishes.length,
                          ),
                        ),
                      ),

                    // Loading indicator
                    if (state.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),

                    // Bottom padding for FAB
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
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
