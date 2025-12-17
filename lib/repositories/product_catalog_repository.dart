import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/catalog_item.dart';
import '../services/inventory_service.dart'; // To access inventory for migration

class ProductCatalogRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _getHouseholdId() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final userDoc = await _db.collection('users').doc(user.uid).get();
    return userDoc.data()?['householdId'];
  }

  Future<CollectionReference<Map<String, dynamic>>> _getCatalogCollection() async {
    final householdId = await _getHouseholdId();
    if (householdId == null) throw Exception("No household ID found");
    return _db.collection('households').doc(householdId).collection('catalog');
  }

  String _generateId(String canonicalName) {
    // Generate a consistent ID from the name to prevent duplicates
    final bytes = utf8.encode(canonicalName.trim().toLowerCase());
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 20);
  }

  Future<void> logItemToCatalog({
    required String name,
    required String canonicalName,
    required String category,
    required int defaultDVM,
    String? imageUrl,
    String? brands,
    String? nutriscore,
    String? storeName,
    double? lastPrice,
  }) async {
    try {
      final collection = await _getCatalogCollection();
      final String safeCanonical = canonicalName.trim().toLowerCase();
      final docId = _generateId(safeCanonical);
      final docRef = collection.doc(docId);
      final docSnapshot = await docRef.get();

      final now = DateTime.now();

      if (docSnapshot.exists) {
        // Update existing item
        final data = docSnapshot.data()!;
        final currentCount = data['usageCount'] as int? ?? 1;

        final Map<String, dynamic> updates = {
          'updatedAt': Timestamp.fromDate(now),
          'usageCount': currentCount + 1,
        };

        // If we have "richer" data now, let's upgrade the catalog entry
        if ((imageUrl != null && imageUrl.isNotEmpty) && (data['imageUrl'] == null || data['imageUrl'] == '')) {
            updates['imageUrl'] = imageUrl;
        }
        if ((brands != null && brands.isNotEmpty) && (data['brands'] == null || data['brands'] == '')) {
            updates['brands'] = brands;
        }
        if (lastPrice != null) {
            updates['lastPrice'] = lastPrice;
        }

        await docRef.update(updates);
      } else {
        // Create new item
        final newItem = CatalogItem(
          id: docId,
          name: name,
          canonicalName: safeCanonical,
          category: category,
          defaultDVM: defaultDVM,
          imageUrl: imageUrl,
          brands: brands,
          nutriscore: nutriscore,
          storeName: storeName,
          lastPrice: lastPrice,
          createdAt: now,
          updatedAt: now,
          usageCount: 1,
        );
        await docRef.set(newItem.toMap());
      }
    } catch (e) {
      // Fail silently for catalog logging, don't block main flow
      print("Error logging to catalog: $e");
    }
  }

  Future<CatalogItem?> getItem(String canonicalName) async {
    try {
      final collection = await _getCatalogCollection();
      final String safeCanonical = canonicalName.trim().toLowerCase();
      final docId = _generateId(safeCanonical);
      final docSnapshot = await collection.doc(docId).get();

      if (docSnapshot.exists) {
        return CatalogItem.fromSnapshot(docSnapshot);
      }
    } catch (e) {
      print("Error fetching item from catalog: $e");
    }
    return null;
  }

  Future<List<CatalogItem>> searchCatalog(String query) async {
    if (query.trim().isEmpty) return [];

    final collection = await _getCatalogCollection();
    final lowerQuery = query.toLowerCase();

    // OPTIMIZATION:
    // For a household catalog, user data is small (< 500 items).
    // It is BETTER to fetch all and filter client-side to allow "Contains" search
    // instead of just "StartsWith".
    // "Jus de Pomme" should be found when typing "Pomme".
    
    // We limit to 500 just in case.
    final QuerySnapshot<Map<String, dynamic>> snapshot = await collection
        .orderBy('usageCount', descending: true)
        .limit(500)
        .get();

    final allItems = snapshot.docs.map((doc) => CatalogItem.fromSnapshot(doc));
    
    final seenNames = <String>{};
    return allItems.where((item) {
        final matches = item.name.toLowerCase().contains(lowerQuery) || 
               item.canonicalName.toLowerCase().contains(lowerQuery) ||
               (item.brands?.toLowerCase().contains(lowerQuery) ?? false);
        
        if (!matches) return false;

        // Deduplication Logic
        final key = item.name.trim().toLowerCase();
        if (seenNames.contains(key)) return false;
        
        seenNames.add(key);
        return true;
    }).take(20).toList();
  }

  // --- MIGRATION TOOL ---
  Future<int> populateCatalogFromHistory() async {
    final householdId = await _getHouseholdId();
    if (householdId == null) return 0;
    
    // 0. CLEAR EXISTING CATALOG (To remove old duplicates/ghosts)
    final collection = await _getCatalogCollection();
    final existingDocs = await collection.get();
    
    // Batch delete (limit 500 per batch, simple loop for now)
    for (var doc in existingDocs.docs) {
      await doc.reference.delete();
    }
    
    int importedCount = 0;
    
    // 1. Import Current Inventory (Rich Data)
    final inventorySnapshot = await _db.collection('households').doc(householdId).collection('inventory').get();
    for (var doc in inventorySnapshot.docs) {
      final data = doc.data();
      await logItemToCatalog(
        name: data['name'],
        canonicalName: data['canonicalName'] ?? data['name'],
        category: data['category'] ?? 'Other',
        defaultDVM: 7, // Estimate
        imageUrl: data['imageUrl'],
        brands: data['brands'],
        nutriscore: data['nutriscore'],
        storeName: data['storeName'],
        lastPrice: (data['price'] is num) ? (data['price'] as num).toDouble() : null,
      );

      importedCount++;
    }

    // 2. Import History (To capture Prices and deleted items)
    // We fetch ALL history (bought/added). This might be large, but it's a migration tool.
    final historySnapshot = await _db.collection('households').doc(householdId).collection('history')
         .where('type', isEqualTo: 'bought')
         .orderBy('timestamp', descending: false) // Oldest first, so newest overwrites lastPrice
         .get();

    for (var doc in historySnapshot.docs) {
      final data = doc.data();
      final String name = data['itemName'];
      final Map<String, dynamic>? details = data['details'];
      
      // We don't have rich data (img, brands) in history usually, mostly just name and price.
      // But we can update the 'lastPrice' and 'usageCount'.
      
      if (details != null) {
        final double? price = (details['price'] is num) ? (details['price'] as num).toDouble() : null;
        
        // Only update if we have meaningful data
        await logItemToCatalog(
          name: name,
          canonicalName: name.toLowerCase(), // Best guess
          category: 'Other', // Don't know
          defaultDVM: 7, 
          // Don't overwrite rich fields with nulls if they exist
          lastPrice: price,
        );
         importedCount++;
      }
    }

    return importedCount;
  }
}
