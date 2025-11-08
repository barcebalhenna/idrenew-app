import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'services/location_service.dart'; // ✅ Import your new service
import 'main.dart';
// ❌ We no longer import Firebase

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService(); // ✅ Add service
  final TextEditingController _searchController = TextEditingController(); // ✅ For the search bar

  LatLng? _currentLocation;
  Map<String, dynamic>? _selectedCenter; // currently selected center

  // --- STATE CHANGES ---
  bool _isSearching = false; // To show a loading spinner
  List<Map<String, dynamic>> _searchResults = []; // Replaces disposalCenters

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Get the user's location on start
  }

  Future<void> _getCurrentLocation() async {
    // ... (Your _getCurrentLocation function is perfect, no changes) ...
    // ... (Just make sure it's here) ...
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable location services")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(pos.latitude, pos.longitude);
    });
    _mapController.move(_currentLocation!, 15);
  }

  /// ✅ NEW: This runs the search
  Future<void> _runSearch() async {
    if (_searchController.text.isEmpty || _currentLocation == null) {
      return; // Don't search for nothing
    }

    // Hide keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isSearching = true;
      _selectedCenter = null; // Clear selection
      _searchResults = []; // Clear old results
    });

    final results = await _locationService.searchLocations(
      _searchController.text,
      _currentLocation!,
    );

    // Convert Nominatim results to the format our UI expects
    final formattedResults = results.map((result) {
      return {
        "name": result['display_name'].split(',')[0], // "EcoTech Recycling"
        "address": result['display_name'], // The full address
        "coords": LatLng(
          double.parse(result['lat']),
          double.parse(result['lon']),
        ),
        // We add the 'raw' result in case we need more details
        "raw": result,
      };
    }).toList();

    setState(() {
      _searchResults = formattedResults;
      _isSearching = false;
    });

    if (formattedResults.isNotEmpty) {
      // Move map to the first result
      _mapController.move(formattedResults[0]['coords'], 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showingList = _selectedCenter == null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // ... (Your AppBar is perfect, no changes) ...
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: GestureDetector(
          onTap: () {
            mainPageKey.currentState?.navigateTo(0);
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.recycling, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text(
                "IDRenew",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Search + Auto-locate
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController, // ✅ Connect controller
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "e.g., e-waste recycling", // ✅ Better hint
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) => _runSearch(), // ✅ Run search on submit
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF10B981),
                  child: IconButton(
                    icon: _isSearching
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,))
                        : const Icon(Icons.search, color: Colors.white),
                    onPressed: _runSearch, // ✅ Run search on button tap
                  ),
                ),
              ],
            ),
          ),

          // 🗺️ Map Section
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation ?? LatLng(7.0731, 125.6131),
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      if (_currentLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentLocation!,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.my_location,
                                  color: Colors.blue, size: 36),
                            ),
                          ],
                        ),
                      // ✅ Markers from Search Results
                      MarkerLayer(
                        markers: _searchResults.map((center) {
                          return Marker(
                            point: center["coords"] as LatLng,
                            width: 50,
                            height: 50,
                            child: const Icon(Icons.location_pin,
                                color: Color(0xFF10B981), size: 40),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                if (showingList && _searchResults.isNotEmpty) // ✅ Show count
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Card(
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        child: Text(
                          "${_searchResults.length} Results Found",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 📋 List OR Single Details
          Expanded(
            child: showingList
                ? _buildCentersList() // ✅ This will show search results
                : _buildCenterDetails(_selectedCenter!), // ✅ This is simplified
          ),
        ],
      ),
    );
  }

  Widget _buildCentersList() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Search for Locations',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Try "e-waste disposal" or "recycling center".',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _searchResults.length, // ✅ Use search results
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey.shade300),
      itemBuilder: (context, index) {
        final center = _searchResults[index];
        final distance = _calculateDistance(center["coords"]);

        return ListTile(
          leading: const Icon(Icons.recycling, color: Color(0xFF10B981)),
          title: Text(center["name"] as String),
          subtitle: Text("$distance • ${center["address"]}"), // ✅ Show full address
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            setState(() {
              // We need to add 'distance' to the map for the details page
              center['distance'] = distance;
              _selectedCenter = center;
            });
            _mapController.move(center["coords"] as LatLng, 16);
          },
        );
      },
    );
  }

  /// ✅ Helper to calculate distance
  String _calculateDistance(LatLng centerCoords) {
    if (_currentLocation == null) return "N/A";
    final distanceInMeters = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      centerCoords.latitude,
      centerCoords.longitude,
    );
    return "${(distanceInMeters / 1000).toStringAsFixed(1)} km";
  }

  Widget _buildCenterDetails(Map<String, dynamic> center) {
    // ❌ We no longer have "supported items", ratings, or hours.
    // This is the trade-off for a free API.
    // We only have the name and address.

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedCenter = null;
                  });
                },
              ),
              Expanded(
                child: Text(center["name"] as String,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.location_pin,
                  color: Color(0xFF10B981), size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Distance: ${center["distance"]}",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87)),
                    Text(center["address"] as String,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            "Details like hours, ratings, and supported items are not available from this free data source.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () {
              // Here you would launch a maps app
              // This is a more complex topic (url_launcher package)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Opening directions to ${center["name"]}...")),
              );
            },
            icon: const Icon(Icons.directions, color: Colors.white),
            label: const Text("Get Directions",
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}