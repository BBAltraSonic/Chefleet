import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';

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
    _currentPosition = widget.initialPosition ?? const LatLng(37.7749, -122.4194); // Default to SF
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
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30), // Adjust for pin anchor
            child: Icon(
              Icons.location_on,
              size: 40,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: ElevatedButton(
            onPressed: () {
              widget.onLocationSelected(_currentPosition);
            },
            child: const Text('Set Location'),
          ),
        ),
      ],
    );
  }
}
