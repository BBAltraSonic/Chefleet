import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../feed/models/dish_model.dart';
import '../blocs/menu_management_bloc.dart';

class DishCard extends StatelessWidget {
  final Dish dish;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAvailability;

  const DishCard({
    super.key,
    required this.dish,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dish Image and Basic Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: dish.imageUrl != null
                    ? Image.network(
                        dish.imageUrl!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: const Icon(
                              Icons.restaurant,
                              size: 32,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: const Icon(
                          Icons.restaurant,
                          size: 32,
                        ),
                      ),
              ),

              // Dish Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dish.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (dish.isFeatured) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[600],
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Description
                      if (dish.description != null) ...[
                        Text(
                          dish.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Price and Category
                      Row(
                        children: [
                          Text(
                            '\$${(dish.priceCents / 100).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (dish.categoryEnum != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                dish.categoryEnum!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const Spacer(),
                          // Availability Status
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: dish.available
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: dish.available ? Colors.green : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  dish.available ? Icons.check_circle : Icons.cancel,
                                  size: 12,
                                  color: dish.available ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dish.available ? 'Available' : 'Unavailable',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: dish.available ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Additional Details
          if (dish.preparationTimeMinutes != null ||
              dish.spiceLevel != null ||
              (dish.dietaryRestrictions?.isNotEmpty ?? false)) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (dish.preparationTimeMinutes != null) ...[
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dish.preparationTimeMinutes} min',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (dish.spiceLevel != null) ...[
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Spice: ${dish.spiceLevel}/5',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (dish.dietaryRestrictions?.isNotEmpty ?? false)
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        children: dish.dietaryRestrictions!.take(3).map((restriction) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              restriction,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onTertiaryContainer,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],

          // Action Buttons
          ButtonBar(
            children: [
              // Toggle Availability
              TextButton.icon(
                onPressed: onToggleAvailability,
                icon: Icon(
                  dish.available ? Icons.visibility_off : Icons.visibility,
                ),
                label: Text(dish.available ? 'Hide' : 'Show'),
                style: TextButton.styleFrom(
                  foregroundColor: dish.available ? Colors.orange : Colors.green,
                ),
              ),

              // Edit
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),

              // Delete
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}