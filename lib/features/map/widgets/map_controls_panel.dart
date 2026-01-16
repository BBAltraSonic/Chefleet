import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_compass_button.dart';
import 'map_zoom_controls.dart';
import 'map_style_toggle.dart';
import 'map_location_button.dart';

/// Main control panel for map containing all controls
class MapControlsPanel extends StatelessWidget {
  const MapControlsPanel({
    super.key,
    required this.mapController,
    required this.currentZoom,
    required this.mapBearing,
    required this.isDarkMode,
    required this.onLocationTap,
    required this.onStyleChange,
    this.locationState = LocationButtonState.idle,
    this.minZoom = 3.0,
    this.maxZoom = 20.0,
  });

  final GoogleMapController? mapController;
  final double currentZoom;
  final double mapBearing;
  final bool isDarkMode;
  final VoidCallback onLocationTap;
  final ValueChanged<bool> onStyleChange;
  final LocationButtonState locationState;
  final double minZoom;
  final double maxZoom;

  Future<void> _zoomIn() async {
    if (mapController != null && currentZoom < maxZoom) {
      await mapController!.animateCamera(
        CameraUpdate.zoomTo(currentZoom + 1),
      );
    }
  }

  Future<void> _zoomOut() async {
    if (mapController != null && currentZoom > minZoom) {
      await mapController!.animateCamera(
        CameraUpdate.zoomTo(currentZoom - 1),
      );
    }
  }

  Future<void> _resetBearing() async {
    if (mapController != null) {
      final position = await mapController!.getVisibleRegion();
      final center = LatLng(
        (position.northeast.latitude + position.southwest.latitude) / 2,
        (position.northeast.longitude + position.southwest.longitude) / 2,
      );
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: center,
            zoom: currentZoom,
            bearing: 0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compass (only visible when map is rotated)
        MapCompassButton(
          rotation: mapBearing,
          onTap: _resetBearing,
        ),
        if (mapBearing.abs() >= 1.0) const SizedBox(height: 12),

        // Zoom Controls
        MapZoomControls(
          onZoomIn: _zoomIn,
          onZoomOut: _zoomOut,
          canZoomIn: currentZoom < maxZoom,
          canZoomOut: currentZoom > minZoom,
        ),
        const SizedBox(height: 12),

        // Map Style Toggle
        MapStyleToggle(
          isDarkMode: isDarkMode,
          onChanged: onStyleChange,
        ),
        const SizedBox(height: 12),

        // Location Button
        MapLocationButton(
          onTap: onLocationTap,
          state: locationState,
        ),
      ],
    );
  }
}
