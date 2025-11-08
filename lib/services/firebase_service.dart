import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // Reference to Firestore database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection name where we'll store scan history
  final String _collectionName = 'scan_history';

  /// Saves a scan result to Firestore (text details only)
  Future<void> saveScanResult(Map<String, dynamic> result) async {
    try {
      await _firestore.collection(_collectionName).add({
        ...result, // Spreads all fields from your classifier
        'timestamp': FieldValue.serverTimestamp(), // Adds the server time
      });

      print('✅ Scan saved to Firebase successfully');
    } catch (e) {
      print('❌ Error saving to Firebase: $e');
      throw Exception('Failed to save scan result: $e');
    }
  }

  /// Get all scan history (sorted by newest first)
  /// Returns a raw QuerySnapshot stream for the StreamBuilder
  Stream<QuerySnapshot> getScanHistory() {
    return _firestore
        .collection(_collectionName)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get scans by condition (Reusable or Damaged)
  /// 🚨 REMEMBER: This query requires a composite index to be created in Firebase!
  Stream<QuerySnapshot> getScansByCondition(String condition) {
    return _firestore
        .collection(_collectionName)
        .where('condition', isEqualTo: condition)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}