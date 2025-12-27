import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Attempts to get current GPS location with auto-detection.
  /// Returns user's position if successful, otherwise returns Johannesburg default.
  /// 
  /// This should be called every time a map screen opens.
  Future<LatLng> getLocationOrDefault() async {
    try {
      debugPrint('🔍 LocationService: Starting auto-detection...');

      // Check if location services are enabled
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('⚠️ LocationService: Location services disabled, using Johannesburg default');
        return AppConstants.defaultLocationSouthAfrica;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('🔍 LocationService: Current permission: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('🔍 LocationService: Permission request result: $permission');
      }

      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        debugPrint('⚠️ LocationService: Permission denied, using Johannesburg default');
        return AppConstants.defaultLocationSouthAfrica;
      }

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint('✅ LocationService: Got position: ${position.latitude}, ${position.longitude}');
      return LatLng(position.latitude, position.longitude);
      
    } catch (e) {
      debugPrint('❌ LocationService: Error during auto-detection: $e');
      debugPrint('⚠️ LocationService: Falling back to Johannesburg default');
      return AppConstants.defaultLocationSouthAfrica;
    }
  }

  /// Gets Position object (for MapFeedBloc compatibility)
  Future<Position?> getCurrentPosition() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('❌ LocationService.getCurrentPosition: $e');
      return null;
    }
  }
}

