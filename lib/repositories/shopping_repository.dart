import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/models/shopping_item.dart';

class ShoppingRepository {
  final FirebaseFirestore _firestore;

  ShoppingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getShoppingCollection(
      String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('shopping_list');
  }

  Stream<List<ShoppingItem>> getShoppingListStream(String householdId) {
    return _getShoppingCollection(householdId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ShoppingItem.fromSnapshot(doc);
      }).toList();
    });
  }

  Future<void> addShoppingItem(String householdId, ShoppingItem item) async {
    await _getShoppingCollection(householdId).add(item.toMap());
  }

  Future<void> updateShoppingItem(String householdId, ShoppingItem item) async {
    await _getShoppingCollection(householdId).doc(item.id).update(item.toMap());
  }

  Future<void> deleteShoppingItem(String householdId, String itemId) async {
    await _getShoppingCollection(householdId).doc(itemId).delete();
  }

  Future<void> clearShoppingList(String householdId) async {
    final collection = _getShoppingCollection(householdId);
    final snapshot = await collection.get();
    
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> addShoppingItems(String householdId, List<ShoppingItem> items) async {
    final batch = _firestore.batch();
    final collection = _getShoppingCollection(householdId);
    
    for (var item in items) {
      final docRef = collection.doc(); // Auto-generate ID if not provided or new
      // Note: If item.id is empty, we generate one. If it has one, we use it?
      // ShoppingItem usually has empty ID before adding.
      // We should probably update the item with the ID?
      // But here we just write.
      batch.set(docRef, item.toMap());
    }
    await batch.commit();
  }

  Future<void> updateShoppingItems(String householdId, List<ShoppingItem> items) async {
    final batch = _firestore.batch();
    final collection = _getShoppingCollection(householdId);
    
    for (var item in items) {
      batch.update(collection.doc(item.id), item.toMap());
    }
    await batch.commit();
  }

  Future<void> deleteShoppingItems(String householdId, List<String> itemIds) async {
    final batch = _firestore.batch();
    final collection = _getShoppingCollection(householdId);
    
    for (var id in itemIds) {
      batch.delete(collection.doc(id));
    }
    await batch.commit();
  }
}
