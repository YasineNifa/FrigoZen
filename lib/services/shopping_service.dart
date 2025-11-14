import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ShoppingService {

  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  final CollectionReference _shoppingCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('shopping_list');

  Stream<QuerySnapshot> getShoppingListStream() {
    return _shoppingCollection.orderBy('createdAt', descending: false).snapshots();
  }

  Future<void> addItemToShoppingList({
    required String name,
    required String canonicalName,
    bool? isChecked,
  }) async {
    await _shoppingCollection.add({
      'name': name,
      'canonicalName': canonicalName,
      'isChecked': isChecked ?? false,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> removeItemFromShoppingList(String documentId) async {
    await _shoppingCollection.doc(documentId).delete();
  }

  Future<void> updateItem(String documentId, Map<String, dynamic> data) async {
    await _shoppingCollection.doc(documentId).update(data);
  }
}
