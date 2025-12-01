import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/models/batch.dart';

class InventoryRepository {
  final FirebaseFirestore _firestore;

  InventoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getInventoryCollection(
      String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('inventory');
  }

  Stream<List<InventoryItem>> getInventoryStream(String householdId,
      {String? location}) {
    Query<Map<String, dynamic>> query = _getInventoryCollection(householdId);

    if (location != null && location != "Tout") {
      query = query.where('location', isEqualTo: location);
    }

    return query
        .orderBy('earliestExpirationDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return InventoryItem.fromSnapshot(doc);
      }).toList();
    });
  }

  Future<void> addInventoryItem(
      String householdId, InventoryItem item) async {
    await _getInventoryCollection(householdId).add(item.toMap());
  }

  Future<void> updateInventoryItem(
      String householdId, InventoryItem item) async {
    await _getInventoryCollection(householdId)
        .doc(item.id)
        .update(item.toMap());
  }

  Future<void> deleteInventoryItem(String householdId, String itemId) async {
    await _getInventoryCollection(householdId).doc(itemId).delete();
  }

  Future<InventoryItem?> getInventoryItemByCanonicalName(
      String householdId, String canonicalName) async {
    final query = await _getInventoryCollection(householdId)
        .where('canonicalName', isEqualTo: canonicalName)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return InventoryItem.fromSnapshot(query.docs.first);
    }
    return null;
  }
  
  // Helper to calculate earliest date from batches, useful if logic needs to be reused
  DateTime getEarliestDate(List<Batch> batches) {
    if (batches.isEmpty) {
      return DateTime.now();
    }
    final sortedBatches = List<Batch>.from(batches);
    sortedBatches.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
    return sortedBatches.first.expirationDate;
  }
}
