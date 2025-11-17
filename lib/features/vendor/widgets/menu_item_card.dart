import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/glass_container.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.item,
    required this.onAvailabilityToggle,
  });

  final Map<String, dynamic> item;
  final Function(bool) onAvailabilityToggle;

  @override
  Widget build(BuildContext context) {
    final name = item['name'] as String? ?? 'Unknown Item';
    final description = item['description'] as String? ?? '';
    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
    final isAvailable = item['is_available'] as bool? ?? true;
    final imageUrl = item['image_url'] as String?;

    return GlassContainer(
      borderRadius: 12,
      opacity: 0.1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Item image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.restaurant,
                            size: 24,
                            color: Colors.grey[400],
                          );
                        },
                      )
                    : Icon(
                        Icons.restaurant,
                        size: 24,
                        color: Colors.grey[400],
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : 'Unavailable',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isAvailable ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    // TODO: Navigate to edit item screen
                  },
                  icon: const Icon(Icons.edit_outlined),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: () => onAvailabilityToggle(!isAvailable),
                  icon: Icon(
                    isAvailable ? Icons.visibility : Icons.visibility_off,
                  ),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  color: isAvailable ? Colors.green : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}