import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;
import '../blocs/map_feed_bloc.dart';
import '../../feed/widgets/dish_card.dart';
import '../../feed/widgets/vendor_mini_card.dart';
import '../../feed/models/vendor_model.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../dish/screens/dish_detail_screen.dart';
import '../../../core/theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _mapHeightAnimation;
  late Animation<double> _mapOpacityAnimation;
  GoogleMapController? _mapController;

  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _mapHeightAnimation = Tween<double>(
      begin: 0.6, // 60% of screen height
      end: 0.2,  // 20% of screen height
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _mapOpacityAnimation = Tween<double>(
      begin: 1.0, // Fully visible
      end: 0.15, // Mostly faded
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 50;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
      if (isScrolled) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider(
      create: (context) => MapFeedBloc()..add(const MapFeedInitialized()),
      child: MapView(
        scrollController: _scrollController,
        mapController: _mapController,
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({
    super.key,
    required this.scrollController,
    required this.onMapCreated,
    this.mapController,
  });

  final ScrollController scrollController;
  final Function(GoogleMapController) onMapCreated;
  final GoogleMapController? mapController;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final GlobalKey _mapKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapFeedBloc, MapFeedState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: Stack(
            children: [
              // Map + Feed with CustomScrollView
              CustomScrollView(
                controller: widget.scrollController,
                slivers: [
                  // Map as persistent header
                  SliverPersistentHeader(
                    pinned: true,
                    floating: false,
                    delegate: MapHeaderDelegate(
                      child: GoogleMap(
                        key: _mapKey,
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
                          widget.onMapCreated(controller);
                          context.read<MapFeedBloc>().add(MapCameraControllerChanged(controller));
                        },
                        onCameraMove: (position) {
                          context.read<MapFeedBloc>().add(MapCameraMoved(position));
                        },
                        onCameraIdle: () {
                          if (widget.mapController != null && mounted) {
                            Future.delayed(const Duration(milliseconds: 600), () {
                              if (widget.mapController != null && mounted) {
                                widget.mapController!.getVisibleRegion().then((bounds) {
                                  context.read<MapFeedBloc>().add(MapCameraIdle(bounds));
                                });
                              }
                            });
                          }
                        },
                        markers: Set<Marker>.from(state.markers.values),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        compassEnabled: true,
                        padding: const EdgeInsets.only(
                          bottom: 20,
                          top: 80,
                        ),
                      ),
                    ),
                  ),

                  // Feed section
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppTheme.radiusLarge),
                        ),
                      ),
                      child: _buildFeedContent(context, state),
                    ),
                  ),
                ],
              ),

              _buildMapControls(context, state),

              // Vendor mini card overlay
              if (state.selectedVendor != null)
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: VendorMiniCard(
                    vendor: state.selectedVendor!,
                    onClose: () {
                      context.read<MapFeedBloc>().add(const MapVendorDeselected());
                    },
                    onViewDetails: () {
                      // Navigate to vendor details
                    },
                    dishCount: state.dishes
                        .where((dish) => dish.vendorId == state.selectedVendor!.id)
                        .length,
                  ),
                ),

              if (state.isLoading)
                Container(
                  color: AppTheme.modalOverlay,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.primaryGreen),
                        const SizedBox(height: 16),
                        Text(
                          'Loading nearby vendors...',
                          style: TextStyle(color: AppTheme.darkText),
                        ),
                      ],
                    ),
                  ),
                ),

              if (state.errorMessage != null)
                Positioned(
                  top: 120,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

    Widget _buildMapControls(BuildContext context, MapFeedState state) {
      return Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 16,
            right: 16,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Icon(
                      Icons.search,
                      color: AppTheme.secondaryGreen,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for an address',
                        hintStyle: TextStyle(
                          color: AppTheme.secondaryGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 120,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppTheme.radiusMedium),
                          ),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            widget.mapController?.animateCamera(CameraUpdate.zoomIn());
                          },
                          icon: Icon(
                            Icons.add,
                            color: AppTheme.darkText,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(AppTheme.radiusMedium),
                          ),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            widget.mapController?.animateCamera(CameraUpdate.zoomOut());
                          ),
                          icon: Icon(
                            Icons.remove,
                            color: AppTheme.darkText,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      context.read<MapFeedBloc>().add(const MapFeedRefreshed());
                    },
                    icon: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: Icon(
                        Icons.navigation,
                        color: AppTheme.darkText,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget _buildFeedContent(BuildContext context, MapFeedState state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.isOffline)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Offline Mode',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (state.lastUpdated != null)
                                Text(
                                  'Last updated ${_formatTime(state.lastUpdated!)}',
                                  style: TextStyle(
                                    color: AppTheme.secondaryGreen,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  'Dishes near you',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.darkText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Dish grid
          if (state.dishes.isNotEmpty)
            NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.extentAfter < 500 &&
                    state.hasMoreData &&
                    !state.isLoadingMore) {
                  context.read<MapFeedBloc>().add(const MapFeedLoadMore());
                }
                return false;
              },
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: state.dishes.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.dishes.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                      ),
                    );
                  }

                  final dish = state.dishes[index];
                  final vendor = state.vendors.firstWhere(
                    (v) => v.id == dish.vendorId,
                    orElse: () => Vendor.empty(),
                  );

                  return DishCard(
                    dish: dish,
                    vendorName: vendor.displayName,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DishDetailScreen(dishId: dish.id),
                        ),
                      );
                    },
                    distance: _calculateDistance(
                      state.currentPosition?.latitude ?? 0,
                      state.currentPosition?.longitude ?? 0,
                      vendor.latitude,
                      vendor.longitude,
                    ),
                  );
                },
              ),
            ),

          if (state.dishes.isEmpty && !state.isLoading)
            Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: AppTheme.secondaryGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No dishes found nearby',
                    style: TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try moving the map to explore other areas',
                    style: TextStyle(
                      color: AppTheme.secondaryGreen,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Bottom padding for navigation
          const SizedBox(height: 100),
        ],
      );
    }

    String _formatTime(DateTime dateTime) {
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    }

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
      final double distance = earthRadiusKm * c;

      return distance;
    }

    double _toRadians(double degrees) {
      return degrees * (3.14159265359 / 180.0);
    }
  }

class MapHeaderDelegate extends SliverPersistentHeaderDelegate {
  const MapHeaderDelegate({
    required this.child,
  });

  final Widget child;

  @override
  double get minExtent => 200.0; // Fixed height for min

  @override
  double get maxExtent => 400.0; // Fixed height for max

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(MapHeaderDelegate oldDelegate) {
    return false;
  }
}

extension on double {
  double toRadians() => this * (3.14159265359 / 180.0);
  double sin() => math.sin(this);
  double cos() => math.cos(this);
  double asin() => math.asin(this);
  double sqrt() => math.sqrt(this);
}