import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';

class PlacePinMap extends StatefulWidget {
  final LatLng? initialPosition;
  final Function(LatLng) onLocationSelected;

  const PlacePinMap({
    super.key,
    this.initialPosition,
    required this.onLocationSelected,
  });

  @override
  State<PlacePinMap> createState() => _PlacePinMapState();
}

class _PlacePinMapState extends State<PlacePinMap> {
  late LatLng _currentPosition;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition ?? AppConstants.defaultLocationSouthAfrica; // Default to Johannesburg
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition,
            zoom: 15,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onCameraMove: (position) {
            setState(() {
              _currentPosition = position.target;
            });
          },
          myLocationEnabled: true, // DEBUG: Google Maps location - may trigger permission request
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
        ),
        
        // Center pin
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40), // Adjust for pin anchor
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 48,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Instructions at top
        Positioned(
          top: AppTheme.spacing20,
          left: AppTheme.spacing20,
          right: AppTheme.spacing20,
          child: GlassContainer(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            borderRadius: AppTheme.radiusMedium,
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.darkText,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: Text(
                    'Move the map to position the pin at your location',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Set location button
        Positioned(
          bottom: AppTheme.spacing24,
          left: AppTheme.spacing20,
          right: AppTheme.spacing20,
          child: ElevatedButton(
            onPressed: () {
              widget.onLocationSelected(_currentPosition);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            child: const Text('Confirm Location'),
          ),
        ),
      ],
    );
  }
}
