import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class LocationSelectorSheet extends StatelessWidget {
  const LocationSelectorSheet({
    super.key,
    required this.onLocationSelected,
    required this.onUseCurrentLocation,
  });

  final Function(String address, double lat, double lng) onLocationSelected;
  final VoidCallback onUseCurrentLocation;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Select Location',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close)),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Current Location Option
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      title: const Text('Use current location'),
                      subtitle: const Text('Enable location services'),
                      onTap: () {
                        Navigator.pop(context);
                        onUseCurrentLocation();
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Saved Addresses Section
                    Text(
                      'Saved Addresses',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // TODO: Replace with actual saved addresses list
                    _buildAddressItem(
                      context,
                      'Home',
                      '123 Main Street, Cape Town',
                      Icons.home_outlined,
                    ),
                    _buildAddressItem(
                      context,
                      'Work',
                      '45 Office Park, Sandton',
                      Icons.work_outline,
                    ),

                    const SizedBox(height: 20),

                    // Recent Locations Section
                    Text(
                      'Recent Locations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // TODO: Replace with actual recent locations
                    _buildAddressItem(
                      context,
                      'Mall of Africa',
                      'Lone Creek Cres, Waterfall City',
                      Icons.history,
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

  Widget _buildAddressItem(
    BuildContext context,
    String title,
    String address,
    IconData icon,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.grey[700],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        address,
        style: TextStyle(color: Colors.grey[600]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        // TODO: Implement selection
        Navigator.pop(context);
        onLocationSelected(address, 0, 0); // Placeholder coords
      },
    );
  }
}
