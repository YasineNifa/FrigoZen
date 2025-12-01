import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/models/shopping_item.dart';

class ShoppingRepository {
  final FirebaseFirestore _firestore;

  ShoppingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getShoppingCollection(
      String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('shopping_list');
  }

  Stream<List<ShoppingItem>> getShoppingListStream(String userId) {
    return _getShoppingCollection(userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ShoppingItem.fromSnapshot(doc);
      }).toList();
    });
  }

  Future<void> addShoppingItem(String userId, ShoppingItem item) async {
    await _getShoppingCollection(userId).add(item.toMap());
  }

  Future<void> updateShoppingItem(String userId, ShoppingItem item) async {
    await _getShoppingCollection(userId).doc(item.id).update(item.toMap());
  }

  Future<void> deleteShoppingItem(String userId, String itemId) async {
    await _getShoppingCollection(userId).doc(itemId).delete();
  }
}
