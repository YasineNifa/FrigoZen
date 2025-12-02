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

  Future<InventoryItem?> findExistingItem(
      String householdId, String canonicalName, String name) async {
    final collection = _getInventoryCollection(householdId);
    
    // 1. Try exact canonicalName
    var query = await collection
        .where('canonicalName', isEqualTo: canonicalName)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) return InventoryItem.fromSnapshot(query.docs.first);

    // 2. Try lowercase canonicalName
    if (canonicalName != canonicalName.toLowerCase()) {
      query = await collection
          .where('canonicalName', isEqualTo: canonicalName.toLowerCase())
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) return InventoryItem.fromSnapshot(query.docs.first);
    }

    // 3. Try exact name
    query = await collection
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) return InventoryItem.fromSnapshot(query.docs.first);

    return null;
  }

  Future<void> upsertInventoryItem(
      String householdId, InventoryItem newItem) async {
    
    final existingItem = await findExistingItem(
        householdId, newItem.canonicalName, newItem.name);

    if (existingItem != null) {
      // Merge batches
      final List<Batch> updatedBatches = List.from(existingItem.batches);
      updatedBatches.addAll(newItem.batches);
      
      // Sort batches
      updatedBatches.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
      
      // Recalculate totals
      final newTotalQuantity = updatedBatches.fold(0, (prev, b) => prev + b.quantity);
      final newEarliestDate = updatedBatches.first.expirationDate;

      final updatedItem = existingItem.copyWith(
        batches: updatedBatches,
        totalQuantity: newTotalQuantity,
        earliestExpirationDate: newEarliestDate,
        // Update metadata if needed, e.g. location/category if they were generic?
        // For now, keep existing item's metadata as primary.
      );

      await updateInventoryItem(householdId, updatedItem);
    } else {
      await addInventoryItem(householdId, newItem);
    }
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
