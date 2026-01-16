import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../blocs/map_feed_bloc.dart';

/// Debug overlay showing map state information
/// Only visible in debug mode
class MapDebugOverlay extends StatelessWidget {
  const MapDebugOverlay({
    super.key,
    required this.state,
  });

  final MapFeedState state;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.greenAccent.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDebugRow('📍 Vendors', '${state.vendors.length}'),
            _buildDebugRow('🗺️ Markers', '${state.markers.length}'),
            _buildDebugRow('🍽️ Dishes', '${state.dishes.length}'),
            _buildDebugRow('🔍 Zoom', state.zoomLevel.toStringAsFixed(1)),
            if (state.currentPosition != null)
              _buildDebugRow('📌 Location', 
                '${state.currentPosition!.latitude.toStringAsFixed(4)}, '
                '${state.currentPosition!.longitude.toStringAsFixed(4)}'),
            if (state.selectedVendor != null)
              _buildDebugRow('✅ Selected', state.selectedVendor!.name),
            if (state.isLoading)
              _buildDebugRow('⏳ Status', 'Loading...'),
            if (state.errorMessage != null)
              _buildDebugRow('❌ Error', state.errorMessage!, isError: true),
            if (state.isOffline)
              _buildDebugRow('📡 Mode', 'Offline (cached data)', isWarning: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugRow(String label, String value, {bool isError = false, bool isWarning = false}) {
    Color valueColor = Colors.white;
    if (isError) valueColor = Colors.redAccent;
    if (isWarning) valueColor = Colors.orangeAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
