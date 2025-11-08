import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationService {

  /// Searches Nominatim (OpenStreetMap's free search) for locations.
  ///
  /// [query] is the text to search for (e.g., "e-waste recycling")
  /// [userLocation] is used to bias the search and make local results
  /// more relevant.
  ///
  /// Returns a List of Maps, where each map is a search result.
  ///
  Future<List<dynamic>> searchLocations(String query, LatLng userLocation) async {
    // Nominatim's free search API endpoint
    final endpoint = Uri.parse('https://nominatim.openstreetmap.org/search');

    // Create a "bounding box" around the user to improve search results
    // This creates a box ~20km x 20km around the user
    final double latOffset = 0.1;
    final double lonOffset = 0.1;
    final String viewBox =
        '${userLocation.longitude - lonOffset},${userLocation.latitude - latOffset},${userLocation.longitude + lonOffset},${userLocation.latitude + latOffset}';

    final params = {
      'q': query,
      'format': 'jsonv2', // Request JSONv2 format
      'viewbox': viewBox, // Prioritize results in this box
      'bounded': '1',     // Strictly limit results to the box
      'limit': '20',      // Get up to 20 results
      'addressdetails': '1', // Get the address
    };

    // --- IMPORTANT: Nominatim Policy ---
    // You MUST include a valid User-Agent.
    // Replace 'idrenew_app' with your app's name.
    final headers = {
      'User-Agent': 'idrenew_app/1.0 (hbarcebal_230000001414@uic.edu.ph)',
    };

    try {
      final response = await http.get(
        endpoint.replace(queryParameters: params),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Success! Parse the JSON response
        final List<dynamic> results = json.decode(response.body);
        return results;
      } else {
        // Error from the server
        print('Nominatim search failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // Network error
      print('Network error during search: $e');
      return [];
    }
  }
}