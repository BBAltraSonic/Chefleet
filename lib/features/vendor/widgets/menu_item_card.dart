import 'package:flutter/material.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../core/constants/app_strings.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.item,
    required this.onAvailabilityToggle,
    this.onEdit,
  });

  final Map<String, dynamic> item;
  final Function(bool) onAvailabilityToggle;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final name = item['name'] as String? ?? AppStrings.unknownItem;
    final description = item['description'] as String? ?? '';
    // Database stores price in cents (INTEGER), convert to rands for display
    final priceCents = (item['price'] as num?)?.toDouble() ?? 0.0;
    final price = priceCents;
    final isAvailable = item['available'] as bool? ?? true;
    final imageUrl = item['image_url'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.08),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Item image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.restaurant_menu_rounded,
                          size: 28,
                          color: Colors.grey[300],
                        );
                      },
                    )
                  : Icon(
                      Icons.restaurant_menu_rounded,
                      size: 28,
                      color: Colors.grey[300],
                    ),
            ),
          ),
          const SizedBox(width: 16),

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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? const Color(0xFF4CAF50).withOpacity(0.1)
                            : const Color(0xFFF44336).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAvailable ? AppStrings.active : AppStrings.hidden,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isAvailable ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CurrencyFormatter.format(price),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.edit_rounded,
                          onPressed: onEdit,
                          color: Colors.grey[700]!,
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: isAvailable ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          onPressed: () => onAvailabilityToggle(!isAvailable),
                          color: isAvailable ? const Color(0xFF4CAF50) : Colors.grey[500]!,
                          isActive: isAvailable,
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }
}