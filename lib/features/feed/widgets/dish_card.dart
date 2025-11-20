import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/dish_model.dart';

class DishCard extends StatelessWidget {
  const DishCard({
    super.key,
    required this.dish,
    required this.vendorName,
    required this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.distance,
  });

  final Dish dish;
  final String vendorName;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final double? distance;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreen,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              _buildImageSection(context),
              // Content section
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vendor name and favorite button
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vendorName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: AppTheme.secondaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onFavorite != null)
                          IconButton(
                            onPressed: onFavorite,
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : AppTheme.secondaryGreen,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Dish name
                    Text(
                      dish.displayName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Description
                    if (dish.displayDescription.isNotEmpty)
                      Text(
                        dish.displayDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.darkText.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),

                    // Bottom row: price, prep time, and distance
                    Row(
                      children: [
                        // Price
                        Text(
                          dish.formattedPrice,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        
                        // Stats Row
                        Row(
                          children: [
                            // Prep time
                            _buildStatBadge(
                              context,
                              Icons.access_time_rounded,
                              dish.formattedPrepTime,
                            ),
                            
                            if (distance != null) ...[
                              const SizedBox(width: 8),
                              // Distance
                              _buildStatBadge(
                                context,
                                Icons.location_on_outlined,
                                '${distance?.toStringAsFixed(1) ?? '0.0'} km',
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.borderGreen.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppTheme.secondaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 160,
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLarge),
            ),
            color: AppTheme.surfaceGreen,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLarge),
            ),
            child: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
                ? Image.network(
                    dish.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
        ),

        // Badges
        Positioned(
          top: 12,
          left: 12,
          child: Row(
            children: [
              if (!dish.available)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Sold Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (dish.available && dish.popularityScore > 0.7)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: AppTheme.darkText,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Popular',
                        style: TextStyle(
                          color: AppTheme.darkText,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        // Spice Level
        if (dish.spiceLevel > 0)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.glassDark.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  dish.spiceLevel,
                  (index) => const Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Text('🌶️', style: TextStyle(fontSize: 10)),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppTheme.surfaceGreen,
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 40,
          color: AppTheme.borderGreen,
        ),
      ),
    );
  }
}