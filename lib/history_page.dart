import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Import Firestore
import 'services/firebase_service.dart'; // ✅ Import your service
import 'package:intl/intl.dart'; // For date formatting
import 'scan_details_page.dart';
import 'dispose_details_page.dart';
import 'main.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // --- STATE VARIABLES ---
  String _selectedFilter = "All"; // Tracks which filter is active
  final FirebaseService _firebaseService = FirebaseService(); // Your service

  // ❌ We no longer need the hard-coded _historyItems list
  // final List<Map<String, dynamic>> _historyItems = [ ... ];

  // --- HELPER METHODS ---

  /// 1. Gets the correct stream from Firebase based on the selected filter.
  Stream<QuerySnapshot> _getStream() {
    if (_selectedFilter == "Reusable") {
      // Get only documents where condition == "Reusable"
      return _firebaseService.getScansByCondition("Reusable");
    }
    if (_selectedFilter == "Dispose") {
      // Get only documents where condition == "Damaged"
      // Note: We map the UI's "Dispose" to the model's "Damaged"
      return _firebaseService.getScansByCondition("Damaged");
    }
    // Otherwise, get all history
    return _firebaseService.getScanHistory();
  }

  /// 2. Maps the "itemType" string from Firebase to a specific Icon.
  /// You can add more items here as your model's labels.txt grows.
  IconData _getIconForItem(String itemType) {
    switch (itemType) {
      case "Phone Battery":
        return Icons.battery_full;
      case "RAM Module":
        return Icons.memory;
      case "Laptop Screen":
        return Icons.laptop;
      case "Hard Drive":
        return Icons.storage;
      case "Phone Charger":
        return Icons.power;
      case "Keyboard Keys":
        return Icons.keyboard;
      case "Phone Camera":
        return Icons.camera_alt;
      default:
        return Icons.device_unknown; // Fallback icon
    }
  }

  /// 3. Builds the filter chip buttons.
  /// This is the same as your code, just with a small tweak.
  Widget _buildFilterChip(String label, String filter) {
    final isSelected = _selectedFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // When tapped, update the filter state.
          // This will cause the StreamBuilder to rebuild with a new stream.
          setState(() => _selectedFilter = filter);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  // --- MAIN BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    // ❌ We no longer need to filter items here
    // final filteredItems = ...

    return Scaffold(
      appBar: AppBar(
        // Your AppBar is perfect, no changes needed
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
                  color: Color(0xFF10B981),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Your header text is perfect, no changes
            const Text(
              "Scan History",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "View all your previously scanned items",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // 🔹 Filter buttons (Your code, no changes)
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildFilterChip("All Items", "All"),
                  _buildFilterChip("Reusable", "Reusable"),
                  _buildFilterChip("Dispose", "Dispose"),
                ],
              ),
            ),

            // 🔹 History list (This is the main change)
            Expanded(
              // We replace the simple ListView with a StreamBuilder
              child: StreamBuilder<QuerySnapshot>(
                stream: _getStream(), // It listens to the stream from our helper
                builder: (context, snapshot) {
                  // --- Handle different states ---

                  // 1. While loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2. If there's an error
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}'));
                  }

                  // 3. If there's no data
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No History Yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          Text(
                            'Scanned items will appear here.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  // 4. If we have data, get the list of documents
                  final scans = snapshot.data!.docs;

                  // --- Build the list ---
                  return ListView.builder(
                    itemCount: scans.length,
                    itemBuilder: (context, index) {
                      // Get the data from the Firestore document
                      final scanData = scans[index].data() as Map<String, dynamic>;

                      // --- Map Firestore data to your UI's needs ---
                      final String itemType = scanData['itemType'] ?? 'Unknown Item';
                      final String condition = scanData['condition'] ?? 'Damaged';
                      final String confidence = scanData['confidencePercentage'] ?? 'N/A';

                      final bool isReusable = condition == 'Reusable';

                      // This creates the status string, e.g., "✓ Reusable (98.5%)"
                      final String statusText = isReusable
                          ? "✓ Reusable ($confidence)"
                          : "⚠ Damaged ($confidence)";

                      // This gets the correct icon, e.g., Icons.battery_full
                      final IconData itemIcon = _getIconForItem(itemType);

                      // --- Build your Card (this is your original widget) ---
                      return InkWell(
                        onTap: () {
                          if (isReusable) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScanDetailsPage(
                                  partName: itemType,
                                  status: statusText, // Pass the new status text
                                  statusColor: const Color(0xFF10B981),
                                  icon: itemIcon,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DisposeDetailsPage(
                                  partName: itemType,
                                  status: statusText, // Pass the new status text
                                  icon: itemIcon,
                                ),
                              ),
                            );
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          color: const Color(0xFFF9FAFB),
                          child: ListTile(
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: (isReusable
                                    ? const Color(0xFF10B981)
                                    : Colors.red)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                itemIcon, // Use the dynamic icon
                                color: isReusable
                                    ? const Color(0xFF10B981)
                                    : Colors.red,
                              ),
                            ),
                            title: Text(itemType), // Use the dynamic item type
                            subtitle: Text(
                              statusText, // Use the new dynamic status text
                              style: TextStyle(
                                color: isReusable
                                    ? const Color(0xFF10B981)
                                    : Colors.red,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}