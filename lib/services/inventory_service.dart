import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryService {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  final CollectionReference _inventoryCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('inventory');

  Future<void> removeItemFromInventory(String documentId) async {
    await _inventoryCollection.doc(documentId).delete();
  }

  Future<void> updateItem(String documentId, Map<String, dynamic> data) async {
    await _inventoryCollection.doc(documentId).update(data);
  }

  Future<DocumentSnapshot> getInventoryDocument(String documentId) async {
    return await _inventoryCollection.doc(documentId).get();
  }

  Future<void> upsertItemToInventory({
    required String name,
    required String canonicalName,
    required int quantity,
    Timestamp? expirationDate,
    String? category,
    String? location,
  })
  async {
    final now = Timestamp.now();
    final existingDoc = await _findExistingItem(canonicalName);
    final newBatch = {
      'quantity':quantity,
      'expirationDate': expirationDate ?? Timestamp.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch + 7 * 24 * 60 * 60 * 1000),
      'addedAt': now,
    };

    if(existingDoc != null) {
      final data = existingDoc.data() as Map<String, dynamic>;     
      final List<dynamic> oldBatches = data['batches'] ?? [];
      final newBatches = [...oldBatches, newBatch];

      int newTotalQuantity = 0;
      for (var batch in newBatches) {
        newTotalQuantity += (batch['quantity'] as int? ?? 0);
      }

      await _inventoryCollection.doc(existingDoc.id).update({
        'batches': newBatches,
        'totalQuantity': newTotalQuantity,
        'earliestExpirationDate': getEarliestDate(newBatches),
        'name': name, 
        'category': category ?? data['category'] ?? 'Other',
        'location': location ?? data['location'] ?? 'Fridge',
      });
    } else {
      await _inventoryCollection.add({
        'name': name,
        'canonicalName': canonicalName,
        'category': category ?? 'Other',
        'location': location ?? 'Fridge',
        'totalQuantity': quantity,
        'batches': [newBatch],
        'earliestExpirationDate': newBatch['expirationDate'],
        'createdAt': now,
      });
    }
  }

  Future<QueryDocumentSnapshot?> _findExistingItem(String canonicalName) async {
    final query = await _inventoryCollection
        .where('canonicalName', isEqualTo: canonicalName)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first;
    }
    return null;
  }

  Timestamp getEarliestDate(List<dynamic> batches) {
    if (batches.isEmpty) {
      return Timestamp.now();
    }
    // Sort to find the earliest (closest) date
    batches.sort((a, b) => (a['expirationDate'] as Timestamp).compareTo(b['expirationDate']));
    return batches.first['expirationDate'];
  }

  Stream<QuerySnapshot> getInventoryStream({String location = "Tout"}) {
    if (_userId == null) {
      return Stream.empty();
    }

    Query query = _inventoryCollection;

    if (location != "Tout") {
      query = query.where('location', isEqualTo: location);
    }
    
    query = query.orderBy('name');

    return query.snapshots();
  }

  Future<void> incrementItemQuantity(String docId, int currentQuantity) async {
    await updateItem(docId, {'totalQuantity': currentQuantity + 1});
  }

  Future<void> decrementItemQuantity(String docId, int currentQuantity) async {
    if (currentQuantity <= 1) {
      await removeItemFromInventory(docId);
      return;
    }

    final doc = await getInventoryDocument(docId);
    if (!doc.exists) {
      throw Exception("Document not found");
    }
    
    final data = doc.data() as Map<String, dynamic>;
    List<dynamic> batches = List<dynamic>.from(data['batches'] ?? []);
    
    batches.sort((a, b) => (a['expirationDate'] as Timestamp).compareTo(b['expirationDate']));
    
    if (batches.isEmpty) {
      throw Exception("No batches to decrement");
    }
    
    if (batches.first['quantity'] > 1) {
      batches.first['quantity'] = batches.first['quantity'] - 1;
    } else {
      batches.removeAt(0);
    }
    
    await updateItem(docId, {
      'totalQuantity': currentQuantity - 1,
      'batches': batches,
      'earliestExpirationDate': getEarliestDate(batches),
    });
  }
}
