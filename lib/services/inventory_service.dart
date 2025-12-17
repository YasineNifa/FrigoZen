import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/services/history_service.dart';
import 'package:frigo_zen/models/activity_log.dart';
import 'package:frigo_zen/repositories/product_catalog_repository.dart';

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
    final inventoryCollection = await _getInventoryCollection();
    await inventoryCollection.doc(documentId).delete();
  }

  Future<void> updateItem(String documentId, Map<String, dynamic> data) async {
    final inventoryCollection = await _getInventoryCollection();
    await inventoryCollection.doc(documentId).update(data);
  }

  Future<DocumentSnapshot> getInventoryDocument(String documentId) async {
    final inventoryCollection = await _getInventoryCollection();
    return await inventoryCollection.doc(documentId).get();
  }

  Future<QuerySnapshot> getInventory() async {
    final inventoryCollection = await _getInventoryCollection();
    return await inventoryCollection.get();
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
    String? imageUrl = '',
    String? nutriscore = '',
    String? storeName = '',
    String? brands = '',
    double? price,
    Map<String, String>? images,
  }) async {
    final inventoryCollection = await _getInventoryCollection();
    final now = Timestamp.now();
    final user = FirebaseAuth.instance.currentUser;
    final existingDoc = await _findExistingItem(canonicalName, name);
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
      'imageUrl': imageUrl, // Keep main image url for backward compatibility
      'nutriscore': nutriscore,
      'brands': brands,
      'storeName': storeName,
      'price': price,
      'images': images,
      'addedBy': user?.uid,
      'addedByName': user?.displayName ?? 'Utilisateur',
      'addedByAvatar': user?.photoURL,
      'method': 'scan_validation', // Added method
    };

    if (existingDoc != null) {
      final data = existingDoc.data() as Map<String, dynamic>;
      List<dynamic> oldBatches = List<dynamic>.from(data['batches'] ?? []);
      final newBatches = [...oldBatches, newBatch];

      await inventoryCollection.doc(existingDoc.id).update({
        'totalQuantity': FieldValue.increment(quantity),
        'batches': FieldValue.arrayUnion([newBatch]),
        // Update main fields in case they were empty or we have better data
        if ((imageUrl != null && imageUrl.isNotEmpty) &&
            (data['imageUrl'] == null || data['imageUrl'] == ''))
          'imageUrl': imageUrl,
        'earliestExpirationDate': getEarliestDate(newBatches),
        'name': name,
        'dvm': dvm,
        'category': category ?? data['category'] ?? 'Other',
        'location': location ?? data['location'] ?? 'Fridge',
      });

      // Log activity
      await HistoryService().logActivity(
        type: ActivityType.bought,
        itemName: name,
        details: {
          'quantity': quantity,
          'unit': 'unit',
          'action': 'added',
          'price': price, // Added price
        },
      );
    } else {
      await inventoryCollection.add({
        'name': name,
        'cleanedName': cleanedName,
        'canonicalName': canonicalName,
        'totalQuantity': quantity, // Initial total
        'category': category,
        'location': location,
        'imageUrl': imageUrl,
        'nutriscore': nutriscore,
        'brands': brands,
        'storeName': storeName,
        'createdAt': now,
        'updatedAt': now,
        'earliestExpirationDate': finalExpirationDate,
        'batches': [newBatch],
        'images': images,
      });

      // Log activity
      await HistoryService().logActivity(
        type: ActivityType.bought,
        itemName: name,
        details: {
          'quantity': quantity,
          'unit': 'unit',
          'action': 'created',
          'price': price, // Added price
        },
      );
    }

    try {
       // Log history separate from Inventory logic if needed, but above we already called HistoryService.
       // Sync to Product Catalog
      final catalogRepo = ProductCatalogRepository();
      await catalogRepo.logItemToCatalog(
        name: name,
        canonicalName: canonicalName,
        category: category ?? 'Other',
        defaultDVM: dvm ?? 7,
        imageUrl: imageUrl, // Takes priority if set
        brands: brands,
        nutriscore: nutriscore,
        storeName: storeName,
        lastPrice: price,
      );
    } catch (e) {
      debugPrint("Error logging history/catalog: $e");
    }
  }

  Future<QueryDocumentSnapshot?> _findExistingItem(String canonicalName, String name) async {
    final inventoryCollection = await _getInventoryCollection();
    debugPrint("DEBUG: _findExistingItem searching for canonicalName: '$canonicalName', name: '$name'");
    
    // 1. Try exact canonicalName
    var query = await inventoryCollection
        .where('canonicalName', isEqualTo: canonicalName)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      debugPrint("DEBUG: Found exact canonicalName match: ${query.docs.first.id}");
      return query.docs.first;
    }

    // 2. Try lowercase canonicalName (if different)
    if (canonicalName != canonicalName.toLowerCase()) {
       debugPrint("DEBUG: Trying lowercase canonicalName: '${canonicalName.toLowerCase()}'");
       query = await inventoryCollection
          .where('canonicalName', isEqualTo: canonicalName.toLowerCase())
          .limit(1)
          .get();
       if (query.docs.isNotEmpty) {
         debugPrint("DEBUG: Found lowercase canonicalName match: ${query.docs.first.id}");
         return query.docs.first;
       }
    }

    // 3. Try exact name match (fallback)
    debugPrint("DEBUG: Trying exact name match: '$name'");
    query = await inventoryCollection
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      debugPrint("DEBUG: Found name match: ${query.docs.first.id}");
      return query.docs.first;
    }

    debugPrint("DEBUG: No existing item found.");
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

  Future<void> incrementItemQuantity(
    String docId, 
    int currentQuantity, {
    required String defaultStoreName,
    required String defaultUserName,
  }) async {
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

    final user = FirebaseAuth.instance.currentUser;
    debugPrint("DEBUG: Current user: ${user?.uid}");
    debugPrint("DEBUG: Current user: ${user?.displayName}");
    debugPrint("DEBUG: Current user: ${user?.photoURL}");
    
    // Find first non-empty values from existing batches
    String? brands;
    String? canonicalName;
    String? cleanedName;
    String? imageUrl;
    String? name;
    String? nutriscore;
    double? price;
    Map<String, String>? images;

    debugPrint("DEBUG: Batches: $batches");

    for (final b in batches) {
      final batch = b as Map<String, dynamic>;
      if (brands == null || brands.isEmpty) brands = batch['brands'];
      if (canonicalName == null || canonicalName.isEmpty) canonicalName = batch['canonicalName'];
      if (cleanedName == null || cleanedName.isEmpty) cleanedName = batch['cleanedName'];
      if (imageUrl == null || imageUrl.isEmpty) imageUrl = batch['imageUrl'];
      if (name == null || name.isEmpty) name = batch['name'];
      if (nutriscore == null || nutriscore.isEmpty) nutriscore = batch['nutriscore'];
      if (price == null) price = batch['price'];
       // Handle images map carefully - if we don't have one, take the first valid one we find
      if (images == null && batch['images'] != null && (batch['images'] as Map).isNotEmpty) {
         images = Map<String, String>.from(batch['images']);
      }
    }

    final newBatch = {
      'quantity': 1,
      'expirationDate': expirationDate,
      'addedAt': now,
      'storeName': defaultStoreName,
      // Enriched fields
      'brands': brands,
      'canonicalName': canonicalName,
      'cleanedName': cleanedName,
      'imageUrl': imageUrl,
      'name': name,
      'nutriscore': nutriscore,
      'price': price,
      'images': images,
      // User info
      'addedBy': user?.uid,
      'addedByName': user?.displayName ?? defaultUserName,
      'addedByAvatar': user?.photoURL,
    };

    debugPrint("DEBUG: New batch: $newBatch");

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
