import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryService {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  Future<String?> _getHouseholdId() async {
    if (_userId == null) return null;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .get();

    if (userDoc.exists && userDoc.data()!.containsKey('householdId')) {
      return userDoc.data()!['householdId'];
    }
    return null;
  }

  Future<CollectionReference<Map<String, dynamic>>>
  _getInventoryCollection() async {
    final householdId = await _getHouseholdId();
    if (householdId == null) throw Exception("No householdId found!");
    return FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection('inventory');
  }

  Future<void> removeItemFromInventory(String documentId) async {
    final _inventoryCollection = await _getInventoryCollection();
    await _inventoryCollection.doc(documentId).delete();
  }

  Future<void> updateItem(String documentId, Map<String, dynamic> data) async {
    final _inventoryCollection = await _getInventoryCollection();
    await _inventoryCollection.doc(documentId).update(data);
  }

  Future<DocumentSnapshot> getInventoryDocument(String documentId) async {
    final _inventoryCollection = await _getInventoryCollection();
    return await _inventoryCollection.doc(documentId).get();
  }

  Future<QuerySnapshot> getInventory() async {
    final _inventoryCollection = await _getInventoryCollection();
    return await _inventoryCollection.get();
  }

  Future<void> upsertItemToInventory({
    required String name,
    required String cleanedName,
    required String canonicalName,
    required int quantity,
    int? dvm,
    Timestamp? expirationDate,
    String? category,
    String? location,
  }) async {
    final _inventoryCollection = await _getInventoryCollection();
    final now = Timestamp.now();
    final existingDoc = await _findExistingItem(canonicalName);
    final Timestamp finalExpirationDate;
    if (expirationDate != null) {
      finalExpirationDate = expirationDate;
    } else {
      final int days = dvm ?? 7;
      final int dvmMillis = days * 24 * 60 * 60 * 1000;
      finalExpirationDate = Timestamp.fromMillisecondsSinceEpoch(
        now.millisecondsSinceEpoch + dvmMillis,
      );
    }
    final newBatch = {
      'quantity': quantity,
      'expirationDate': finalExpirationDate,
      'addedAt': now,
      'name': name, // Shop, Scan, Manual Add
      'cleanedName': cleanedName,
      'canonicalName': canonicalName,
      // 'storeName': '',
    };

    if (existingDoc != null) {
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
        'dvm': dvm,
        'category': category ?? data['category'] ?? 'Other',
        'location': location ?? data['location'] ?? 'Fridge',
      });
    } else {
      await _inventoryCollection.add({
        'name': name,
        'cleanedName': cleanedName,
        'canonicalName': canonicalName,
        'category': category ?? 'Other',
        'location': location ?? 'Fridge',
        'totalQuantity': quantity,
        'batches': [newBatch],
        'earliestExpirationDate': finalExpirationDate,
        'createdAt': now,
        'dvm': dvm,
      });
    }
  }

  Future<QueryDocumentSnapshot?> _findExistingItem(String canonicalName) async {
    final _inventoryCollection = await _getInventoryCollection();
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
    batches.sort(
      (a, b) =>
          (a['expirationDate'] as Timestamp).compareTo(b['expirationDate']),
    );
    return batches.first['expirationDate'];
  }

  Stream<QuerySnapshot> getInventoryStream({String location = "Tout"}) async* {
    final householdId = await _getHouseholdId();

    if (householdId == null) {
      yield* Stream.empty();
      return;
    }

    Query query = FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection('inventory');

    if (location != "Tout") {
      query = query.where('location', isEqualTo: location);
    }

    yield* query
        .orderBy('earliestExpirationDate', descending: false)
        .snapshots();
  }

  Future<void> incrementItemQuantity(String docId, int currentQuantity) async {
    final collection = await _getInventoryCollection();
    final docRef = collection.doc(docId);

    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    List<dynamic> batches = List<dynamic>.from(data['batches'] ?? []);

    final int dvm = data['dvm'] ?? 7;
    final now = Timestamp.now();
    final int dvmMillis = dvm * 24 * 60 * 60 * 1000;
    final Timestamp expirationDate = Timestamp.fromMillisecondsSinceEpoch(
      now.millisecondsSinceEpoch + dvmMillis,
    );

    final newBatch = {
      'quantity': 1,
      'expirationDate': expirationDate,
      'addedAt': now,
      'storeName': 'Ajout Rapide',
    };

    batches.add(newBatch);

    batches.sort(
      (a, b) =>
          (a['expirationDate'] as Timestamp).compareTo(b['expirationDate']),
    );

    await docRef.update({
      'totalQuantity': currentQuantity + 1,
      'batches': batches,
      'earliestExpirationDate': getEarliestDate(batches),
    });
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

    batches.sort(
      (a, b) =>
          (a['expirationDate'] as Timestamp).compareTo(b['expirationDate']),
    );

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

  Future<void> updateBatchDate(
    String docId,
    Map<String, dynamic> oldBatch,
    DateTime newDate,
  ) async {
    final collection = await _getInventoryCollection();
    final docRef = collection.doc(docId);

    final snapshot = await docRef.get();
    if (!snapshot.exists) throw Exception("Article not found.");

    final data = snapshot.data() as Map<String, dynamic>;
    List<dynamic> batches = List<dynamic>.from(data['batches'] ?? []);

    final int indexToUpdate = batches.indexWhere((b) {
      final batchMap = b as Map<String, dynamic>;
      return batchMap['addedAt'] == oldBatch['addedAt'] &&
          batchMap['expirationDate'] == oldBatch['expirationDate'];
    });

    if (indexToUpdate == -1) throw Exception("Lot not found in inventory.");

    batches[indexToUpdate]['expirationDate'] = Timestamp.fromDate(newDate);

    batches.sort(
      (a, b) =>
          (a['expirationDate'] as Timestamp).compareTo(b['expirationDate']),
    );

    await docRef.update({
      'batches': batches,
      'earliestExpirationDate': getEarliestDate(batches),
    });
  }
}
