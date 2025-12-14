import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] as Map<String, dynamic>?;
    return PlacePrediction(
      placeId: json['place_id'] as String,
      description: json['description'] as String,
      mainText: structuredFormatting?['main_text'] as String? ?? json['description'],
      secondaryText: structuredFormatting?['secondary_text'] as String? ?? '',
    );
  }
}

class PlaceDetails {
  final String placeId;
  final String description;
  final double lat;
  final double lng;

  PlaceDetails({
    required this.placeId,
    required this.description,
    required this.lat,
    required this.lng,
  });
}

class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  String get _apiKey {
    final key = dotenv.env['MAPS_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('MAPS_API_KEY not found in .env');
    }
    return key;
  }

  Future<List<PlacePrediction>> getAutocompletePredictions(
    String query, {
    String? sessionToken,
  }) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
      '$_baseUrl/autocomplete/json?input=${Uri.encodeComponent(query)}&key=$_apiKey&sessiontoken=$sessionToken&components=country:za',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
          final predictions = (data['predictions'] as List)
              .map((item) => PlacePrediction.fromJson(item))
              .toList();
          return predictions;
        } else {
          throw Exception('Places API Error: ${data['status']} - ${data['error_message']}');
        }
      } else {
        throw Exception('Failed to load predictions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch predictions: $e');
    }
  }

  Future<PlaceDetails> getPlaceDetails(String placeId, {String? sessionToken}) async {
    final url = Uri.parse(
      '$_baseUrl/details/json?place_id=$placeId&key=$_apiKey&sessiontoken=$sessionToken&fields=geometry,formatted_address,name',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final location = result['geometry']['location'];
          return PlaceDetails(
            placeId: placeId,
            description: result['formatted_address'] ?? result['name'],
            lat: location['lat'],
            lng: location['lng'],
          );
        } else {
          throw Exception('Places API Error: ${data['status']} - ${data['error_message']}');
        }
      } else {
        throw Exception('Failed to load place details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch place details: $e');
    }
  }
}
