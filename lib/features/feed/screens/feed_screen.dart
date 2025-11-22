import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../models/vendor_model.dart';
import '../widgets/dish_card.dart';
import '../widgets/dish_card_skeleton.dart';
import '../../map/blocs/map_feed_bloc.dart';
import '../../../core/theme/app_theme.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<MapFeedBloc>().add(const MapFeedLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapFeedBloc()..add(const MapFeedInitialized()),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<MapFeedBloc, MapFeedState>(
            builder: (context, state) {
              if (state.isLoading && state.dishes.isEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 3,
                  itemBuilder: (context, index) => const DishCardSkeleton(),
                );
              }

              if (state.errorMessage != null && state.dishes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(state.errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<MapFeedBloc>().add(const MapFeedInitialized());
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<MapFeedBloc>().add(const MapFeedRefreshed());
                  // Wait for a bit or wait for state change (simplified here)
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Text(
                        'Nearby Dishes',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      centerTitle: false,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () {
                            // TODO: Implement filter
                          },
                        ),
                      ],
                    ),
                    if (state.dishes.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant_menu,
                                  size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'No dishes found nearby',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1, // Full width cards
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.1, // Adjust based on card content
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final dish = state.dishes[index];
                              final vendor = state.vendors.firstWhere(
                                (v) => v.id == dish.vendorId,
                                orElse: () => Vendor.empty(),
                              );

                              // Calculate distance if user location is available
                              double? distance;
                              if (state.currentPosition != null) {
                                distance = _calculateDistance(
                                  state.currentPosition!.latitude,
                                  state.currentPosition!.longitude,
                                  vendor.latitude,
                                  vendor.longitude,
                                );
                              }

                              return DishCard(
                                dish: dish,
                                vendorName: vendor.displayName,
                                distance: distance,
                                onTap: () {
                                  context.push('/dish/${dish.id}');
                                },
                              );
                            },
                            childCount: state.dishes.length,
                          ),
                        ),
                      ),
                    if (state.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    // Bottom padding for nav bar
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
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

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.asin(math.sqrt(a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}
