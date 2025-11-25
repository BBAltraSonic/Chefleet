import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../map/blocs/map_feed_bloc.dart';
import '../models/dish_model.dart';
import 'dish_card_skeleton.dart';

class DishFeedWidget extends StatelessWidget {
  final String? vendorId;

  const DishFeedWidget({
    super.key,
    this.vendorId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapFeedBloc, MapFeedState>(
      builder: (context, state) {
        if (state.isLoading) {
          return ListView.builder(
            itemCount: 3, // Show 3 skeletons
            itemBuilder: (context, index) {
              return const DishCardSkeleton();
            },
          );
        }

        if (state.hasError) {
          return Center(
            child: Text(
              'Error loading dishes',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
                  ),
            ),
          );
        }

        List<Dish> dishes = state.dishes;

        // Filter by vendor if specified
        if (vendorId != null) {
          dishes = dishes.where((dish) => dish.vendorId == vendorId).toList();
        }

        if (dishes.isEmpty) {
          return Center(
            child: Text(
              vendorId != null ? 'No dishes available' : 'No dishes found in this area',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          );
        }

        return ListView.builder(
          itemCount: dishes.length,
          itemBuilder: (context, index) {
            final dish = dishes[index];
            return DishCard(dish: dish);
          },
        );
      },
    );
  }
}

class DishCard extends StatelessWidget {
  final Dish dish;

  const DishCard({
    super.key,
    required this.dish,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to dish details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: dish.imageUrl != null
                      ? Image.network(
                          dish.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.restaurant, size: 40);
                          },
                        )
                      : const Icon(Icons.restaurant, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dish.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dish.formattedPrice,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              dish.formattedPrepTime,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (dish.spiceLevel > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: dish.spiceLevelEmojis.map((emoji) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}