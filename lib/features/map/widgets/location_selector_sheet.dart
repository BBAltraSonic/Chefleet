import 'package:flutter/material.dart';
import '../../../core/constants/timing_constants.dart';
import '../../../core/theme/app_theme.dart';

import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../../core/services/google_places_service.dart';

class LocationSelectorSheet extends StatefulWidget {
  const LocationSelectorSheet({
    super.key,
    required this.onLocationSelected,
    required this.onUseCurrentLocation,
  });

  final Function(String address, double lat, double lng) onLocationSelected;
  final VoidCallback onUseCurrentLocation;

  @override
  State<LocationSelectorSheet> createState() => _LocationSelectorSheetState();
}

class _LocationSelectorSheetState extends State<LocationSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  final GooglePlacesService _placesService = GooglePlacesService();
  final Uuid _uuid = const Uuid();
  
  String? _sessionToken;
  Timer? _debounce;
  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _sessionToken = _uuid.v4();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(TimingConstants.searchDebounce, () {
      _fetchPredictions(query);
    });
  }

  Future<void> _fetchPredictions(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final predictions = await _placesService.getAutocompletePredictions(
        query,
        sessionToken: _sessionToken,
      );
      if (mounted) {
        setState(() {
          _predictions = predictions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load predictions';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onPredictionSelected(PlacePrediction prediction) async {
    try {
      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      final details = await _placesService.getPlaceDetails(
        prediction.placeId,
        sessionToken: _sessionToken,
      );

      // Close sheet and return result
      if (mounted) {
        Navigator.pop(context); // Close sheet
        widget.onLocationSelected(
          details.description,
          details.lat,
          details.lng,
        );
      }
      
      // Reset session token for next session
      _sessionToken = _uuid.v4();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting location: $e'),
            duration: TimingConstants.snackbarError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9, // Expand to almost full screen for search
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search for your address',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              const Divider(),
              
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(child: Text(_errorMessage!))
                        : ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              // Predictions List
                              if (_predictions.isNotEmpty) ...[
                                Text(
                                  'Search Results',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ..._predictions.map((p) => _buildPredictionItem(p)),
                                const SizedBox(height: 20),
                              ],

                              // Current Location Option (Only show if not searching or few results)
                              if (_predictions.isEmpty) ...[
                                ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
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
                                    widget.onUseCurrentLocation();
                                  },
                                ),
                                const SizedBox(height: 20),
                                
                                // Saved Addresses Section (Placeholder for now)
                                // Only show when no search is active
                                if (_searchController.text.isEmpty) ...[
                                  Text(
                                    'Saved Addresses',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildAddressItem(
                                    'Home',
                                    '123 Main Street, Cape Town',
                                    Icons.home_outlined,
                                  ),
                                  _buildAddressItem(
                                    'Work',
                                    '45 Office Park, Sandton',
                                    Icons.work_outline,
                                  ),
                                ],
                              ],
                            ],
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPredictionItem(PlacePrediction prediction) {
    return ListTile(
      leading: const Icon(Icons.location_on_outlined, color: Colors.grey),
      title: Text(
        prediction.mainText,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        prediction.secondaryText,
        style: TextStyle(color: Colors.grey[600]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _onPredictionSelected(prediction),
    );
  }

  Widget _buildAddressItem(
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
        // TODO: Implement selection for saved addresses
        Navigator.pop(context);
        widget.onLocationSelected(address, 0, 0); // Placeholder coords
      },
    );
  }
}
