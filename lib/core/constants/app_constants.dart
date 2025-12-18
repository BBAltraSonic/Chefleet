import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppConstants {
  // South Africa - Default to Johannesburg (largest city, central location)
  static const LatLng defaultLocationSouthAfrica = LatLng(-26.2041, 28.0473); // Johannesburg
  static const double defaultZoom = 14.0;
  
  // Alternative: Cape Town if preferred
  // static const LatLng defaultLocationSouthAfrica = LatLng(-33.9249, 18.4241);
  
  // Backup locations for testing
  static const LatLng johannesburg = LatLng(-26.2041, 28.0473);
  static const LatLng capeTown = LatLng(-33.9249, 18.4241);
  static const LatLng durban = LatLng(-29.8587, 31.0218);
  static const LatLng pretoria = LatLng(-25.7479, 28.2293);
}

