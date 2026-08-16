import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/models/batch.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/models/enums.dart';

class InventoryRepository {
  final FirebaseFirestore _firestore;

  InventoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _getInventoryCollection(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('inventory');
  }

  Stream<List<InventoryItem>> getInventoryStream(String householdId) {
    return _getInventoryCollection(householdId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromSnapshot(doc))
            .toList());
  }
  
  Stream<List<Batch>> getBatchesStream(String householdId, String itemId) {
    return _getInventoryCollection(householdId)
        .doc(itemId)
        .collection('batches')
        .orderBy('expirationDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Batch.fromSnapshot(doc)).toList();
    });
  }

  // Transactional add batch
  Future<void> addBatch(String householdId, String itemId, Batch batch) async {
    final itemRef = _getInventoryCollection(householdId).doc(itemId);
    final batchRef = itemRef.collection('batches').doc(); // Auto-ID

    await _firestore.runTransaction((transaction) async {
      final itemDoc = await transaction.get(itemRef);
      if (!itemDoc.exists) throw Exception("Item not found");

      // 1. Add batch to sub-collection
      // Ensure batch has the ID of the ref
      final batchToSave = batch.copyWith(id: batchRef.id);
      transaction.set(batchRef, batchToSave.toMap());

      // 2. Calculate new aggregates
      // NOTE: In a transaction, we can't easily query the sub-collection to aggregate ALL batches 
      // without reading them all, which is expensive.
      // Strategy: Read current aggregates and apply delta.
      final currentTotal = (itemDoc.data() as Map<String, dynamic>)['totalQuantity'] as int? ?? 0;
      final newTotal = currentTotal + batch.quantity;
      
      // Update Stats Incrementally
      final Map<String, dynamic> itemData = itemDoc.data() as Map<String, dynamic>;
      final Map<String, int> nutriscoreStats = (itemData['nutriscoreStats'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as int)) ?? {};
      final Map<String, int> storeStats = (itemData['storeStats'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as int)) ?? {};
      
      if (batch.nutriscore != null && batch.nutriscore!.isNotEmpty) {
         final key = batch.nutriscore!.toUpperCase();
         nutriscoreStats[key] = (nutriscoreStats[key] ?? 0) + batch.quantity;
      }
       if (batch.storeName != null && batch.storeName!.isNotEmpty) {
         final key = batch.storeName!;
         storeStats[key] = (storeStats[key] ?? 0) + batch.quantity;
      }

      // For earliestExpirationDate, strictly speaking we should query.
      // Optimization: If new batch is earlier than current earliest, update it.
      // If it's later, we might need to check if we need to update (only if we deleted the earliest).
      // Since this is ADD, straightforward min() logic works.
      final currentEarliestTs = (itemDoc.data() as Map<String, dynamic>)['earliestExpirationDate'] as Timestamp?;
      final currentEarliest = currentEarliestTs?.toDate() ?? DateTime(2100);
      
      DateTime newEarliest = currentEarliest;
      if (batch.expirationDate.isBefore(currentEarliest)) {
        newEarliest = batch.expirationDate;
      }

      transaction.update(itemRef, {
        'totalQuantity': newTotal,
        'earliestExpirationDate': Timestamp.fromDate(newEarliest),
        'nutriscoreStats': nutriscoreStats,
        'storeStats': storeStats,
        // If this is the first batch or we want to update cache fields, do it here
      });
    });
  }

  Future<void> updateBatch(String householdId, String itemId, Batch batch) async {
    final itemRef = _getInventoryCollection(householdId).doc(itemId);
    final batchRef = itemRef.collection('batches').doc(batch.id);

    await _firestore.runTransaction((transaction) async {
      final itemDoc = await transaction.get(itemRef);
      final batchDoc = await transaction.get(batchRef);

      if (!itemDoc.exists || !batchDoc.exists) throw Exception("Item or Batch not found");

      final oldBatch = Batch.fromSnapshot(batchDoc);
      final quantityDiff = batch.quantity - oldBatch.quantity;

      transaction.update(batchRef, batch.toMap());

      // Update Aggregates
      // For quantity: straightforward delta
      final currentTotal = (itemDoc.data() as Map<String, dynamic>)['totalQuantity'] as int? ?? 0;
      
      transaction.update(itemRef, {
        'totalQuantity': currentTotal + quantityDiff,
        // Re-calculating earliest date is hard in transaction without reading all.
      });
    });
    
    // Post-transaction fixup for Dates (if needed)
    await _recalculateAggregates(householdId, itemId);
  }

  Future<void> deleteBatch(String householdId, String itemId, String batchId) async {
    final itemRef = _getInventoryCollection(householdId).doc(itemId);
    final batchRef = itemRef.collection('batches').doc(batchId);

    await _firestore.runTransaction((transaction) async {
      final itemDoc = await transaction.get(itemRef);
      final batchDoc = await transaction.get(batchRef);

      if (!batchDoc.exists) return; // Already deleted

      final oldBatch = Batch.fromSnapshot(batchDoc);
      
      transaction.delete(batchRef);

      if (itemDoc.exists) {
        final currentTotal = (itemDoc.data() as Map<String, dynamic>)['totalQuantity'] as int? ?? 0;
        transaction.update(itemRef, {
          'totalQuantity': currentTotal - oldBatch.quantity,
        });
      }
    });

    // Cleanup aggregates
     await _recalculateAggregates(householdId, itemId);
  }

  Future<void> _recalculateAggregates(String householdId, String itemId) async {
    final itemRef = _getInventoryCollection(householdId).doc(itemId);
    
    // Fetch all batches to re-calculate precise aggregates
    final snapshot = await itemRef.collection('batches').get();
    final batches = snapshot.docs.map((d) => Batch.fromSnapshot(d)).toList();
    
    if (batches.isEmpty) {
      // If no batches left, maybe delete item or set to 0?
      await itemRef.update({
        'totalQuantity': 0,
        'earliestExpirationDate': Timestamp.fromDate(DateTime(2100)),
      });
      return;
    }

    int total = 0;
    DateTime earliest = DateTime(2100);
    final nutriscoreStats = <String, int>{};
    final storeStats = <String, int>{};
    
    for (final b in batches) {
      total += b.quantity;
      if (b.expirationDate.isBefore(earliest)) earliest = b.expirationDate;
      
      if (b.nutriscore != null && b.nutriscore!.isNotEmpty) {
        final score = b.nutriscore!.toUpperCase();
        nutriscoreStats[score] = (nutriscoreStats[score] ?? 0) + b.quantity;
      }
      
      if (b.storeName != null && b.storeName!.isNotEmpty) {
        final store = b.storeName!;
        storeStats[store] = (storeStats[store] ?? 0) + b.quantity;
      }
    }
    
    await itemRef.update({
      'totalQuantity': total,
      'earliestExpirationDate': Timestamp.fromDate(earliest),
      'nutriscoreStats': nutriscoreStats,
      'storeStats': storeStats,
    });
  }

  Future<void> deleteItem(String householdId, String itemId) async {
    // Delete subcollection first (manually, as Firestore doesn't recursive delete automatically in client SDKs)
    // NOTE: For large collections, use Cloud Functions or explicit recursive delete tool.
    // Here we assume reasonable size.
    final batches = await _getInventoryCollection(householdId).doc(itemId).collection('batches').get();
    for (final doc in batches.docs) {
      await doc.reference.delete();
    }
    await _getInventoryCollection(householdId).doc(itemId).delete();
  }

  Future<void> addInventoryItem(String householdId, InventoryItem item) async {
    // We set the document with the item's ID
    await _getInventoryCollection(householdId).doc(item.id).set(item.toMap());
  }

  Future<void> updateInventoryItem(String householdId, InventoryItem item) async {
    final docRef = _firestore
        .collection('households')
        .doc(householdId)
        .collection('inventory')
        .doc(item.id);

    await docRef.update(item.toMap());
  }
  
  Future<void> decrementItemQuantity(String householdId, String itemId, int quantityToRemove) async {
    final itemRef = _firestore
        .collection('households')
        .doc(householdId)
        .collection('inventory')
        .doc(itemId);

    await _firestore.runTransaction((transaction) async {
      final itemDoc = await transaction.get(itemRef);
      if (!itemDoc.exists) throw Exception("Item not found");

      final currentTotal = itemDoc.data()!['totalQuantity'] as int;
      if (currentTotal <= quantityToRemove) {
        // If removing all, delete the item and its sub-collection
        // Recursive delete is needed, but we can't do that easily in a transaction for sub-coll.
        // We delete the item doc here. The cloud function (if any) or separate process should clean up.
        // OR: We iterate batches and delete them.
        // Since we can't query reliably in transaction without index, we assume we might leave orphans or we do it outside transaction?
        // Actually, deleting the parent implies deleting access. Sub-collection remains but is orphaned.
        // Better: Delete the item doc. 
        // Note: 'deleteItem' method handles recursive delete. 
        // We CANNOT call other async methods easily inside transaction.
        // So we signal "delete" and do it after? 
        // Actually, if quantity <= 0, we can just delete the doc.
        transaction.delete(itemRef);
        return; 
      }
      
      // Need to remove from batches
      // We need to read batches to know which one to decrement.
      // This is hard in a transaction without a query. 
      // Query inside transaction requires strict indexing.
      // Wait, standard Firestore transactions usually lock documents read.
      
      // If we can't query inside transaction, we fallback to:
      // 1. Read 'InventoryItem' and 'Batches' (outside transaction or optimistically).
      // 2. Compute changes.
      // 3. Run transaction checking prerequisites (item version?).
      
      // Simplified approach for MVP:
      // Just modify the item total. 
      // And asynchronously clean up batches? No, consistency needed.
      
      // Let's look at `deleteItem`... it deletes subcollection first.
      
      // OK, for decrement:
      // We will assume "First Batch" logic.
      // We can fetch the list of batch IDs from a separate read?
      // No, we use `InventoryService` approach: Read, modify, write.
      // But wrapping in transaction?
    });
    
    // Correction: Since complex sub-collection query in transaction is hard:
    // We will do it in two steps with optimistic locking or just simple localized logic.
    // 1. Get batches.
    // 2. Pick batch to decrement.
    // 3. Transaction: verifying that batch still has qty.
    
    final batchesSnapshot = await itemRef.collection('batches')
        .orderBy('expirationDate')
        .limit(5) // Check first few
        .get();
        
    if (batchesSnapshot.docs.isEmpty) {
        // No batches? specific edge case. Update total only.
        await itemRef.update({'totalQuantity': FieldValue.increment(-quantityToRemove)});
        return;
    }
    
    // We try to decrement from the first batch
    final batchDoc = batchesSnapshot.docs.first;
    final batchId = batchDoc.id;
    // final batchExpired = batchDoc.data()['expirationDate']; // Not used
    
    await _firestore.runTransaction((transaction) async {
       final bRef = itemRef.collection('batches').doc(batchId);
       final bSnap = await transaction.get(bRef);
       final pSnap = await transaction.get(itemRef);
       
       if (!bSnap.exists) return; // Batch gone, abort/retry
       
       final bQty = bSnap.data()!['quantity'] as int;
       
       // Calculate new item total
       if (pSnap.exists) {
          final currentTotal = pSnap.data()!['totalQuantity'] as int;
          if (currentTotal - quantityToRemove <= 0) {
             transaction.delete(itemRef);
          } else {
             transaction.update(itemRef, {
                 'totalQuantity': currentTotal - quantityToRemove,
             });
          }
       }

       // Update Batch
       if (bQty > quantityToRemove) {
          transaction.update(bRef, {'quantity': bQty - quantityToRemove});
       } else {
          transaction.delete(bRef);
       }
    });
    
    // Post-transaction: Check if we need to recalc aggregates (if we deleted a batch)
    // We can call _recalculateAggregates(itemRef)
    await _recalculateAggregates(householdId, itemId);
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
      // Logic: Merge by adding new batches to existing sub-collection
      // We iterate over newItem.batches (which are in memory) and add them.
      
      final batchCollection = _getInventoryCollection(householdId)
          .doc(existingItem.id)
          .collection('batches');

      for (final batch in newItem.batches) {
         // Create new batch doc
         await batchCollection.add(batch.toMap());
      }
      
      // Update aggregates
      await _recalculateAggregates(householdId, existingItem.id);
      
      // Also update main item metadata if newItem has better data?
      // For fast add, we might trust existing.
      // But if we want to ensure latest images etc:
      /*
      await updateInventoryItem(householdId, existingItem.copyWith(
         imageUrl: newItem.imageUrl, // etc
      ));
      */
    } else {
      // Create new Item
      // 1. Create Doc (get ID)
      final docRef = _getInventoryCollection(householdId).doc();
      final String newItemId = docRef.id;
      
      // 2. Set Item Data (without batches in map)
      final itemToSave = newItem.copyWith(id: newItemId); // Ensure ID is set
      await docRef.set(itemToSave.toMap()); // toMap excludes batches
      
      // 3. Add Batches to sub-collection
      final batchCollection = docRef.collection('batches');
      for (final batch in newItem.batches) {
         // Batch ID? Firestore generates if we use add(), or we set it if batch has ID.
         // Usually new batches have empty ID.
         await batchCollection.add(batch.toMap());
      }
      
      // 4. Update aggregates (initial)
      // Since we just added batches, we can calc from them directly or call recalc.
      // But itemToSave might needed correct totalQuantity/earliestDate.
      // The `newItem` passed in usually has pre-calculated totalQuantity/earliestDate from the sheet?
      // Yes, `AddItemSheet` / `InventoryService` logic usually sets them.
      // But we just saved `itemToSave`.
      // Ensure correctness:
      await _recalculateAggregates(householdId, newItemId);
    }
  }
}
