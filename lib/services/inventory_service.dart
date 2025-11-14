import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryService {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  final CollectionReference _inventoryCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('inventory');

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
        'earliestExpirationDate': _getEarliestDate(newBatches),
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

  Timestamp _getEarliestDate(List<dynamic> batches) {
    if (batches.isEmpty) {
      return Timestamp.now();
    }
    // Sort to find the earliest (closest) date
    batches.sort((a, b) => (a['expirationDate'] as Timestamp).compareTo(b['expirationDate']));
    return batches.first['expirationDate'];
  }
}
