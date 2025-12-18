import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frigo_zen/models/batch.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/repositories/inventory_repository.dart';
import 'package:frigo_zen/services/history_service.dart';
import 'package:frigo_zen/models/activity_log.dart';
import 'package:frigo_zen/models/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum LocationFilter {
  all,
  fridge,
  pantry,
  freezer
}

class InventoryViewModel extends ChangeNotifier {
  final InventoryRepository _inventoryRepository;
  final HistoryService _historyService;
  
  // State
  List<InventoryItem> _items = [];
  bool _isLoading = false;
  LocationFilter _selectedFilter = LocationFilter.all;
  String _searchQuery = "";
  String? _householdId;
  StreamSubscription<List<InventoryItem>>? _inventorySubscription;

  // Getters
  List<InventoryItem> get items => _items;
  bool get isLoading => _isLoading;
  LocationFilter get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  List<InventoryItem> get filteredItems {
    return _items.where((item) {
      bool matchesLocation = false;
      // print("item.location.id: ${item.location.id}");
      // debugPrint("selectedFilter xx: ${_selectedFilter}");

      switch (_selectedFilter) {
        case LocationFilter.all:
          matchesLocation = true;
          break;
        case LocationFilter.fridge:
          matchesLocation = item.location.id == StorageLocation.fridge.id;
          break;
        case LocationFilter.pantry:
           matchesLocation = item.location.id == StorageLocation.pantry.id;
          break;
        case LocationFilter.freezer:
           matchesLocation = item.location.id == StorageLocation.freezer.id;
          break;
      }

      final matchesSearch = _searchQuery.isEmpty || 
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.canonicalName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.cleanedName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.key.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesLocation && matchesSearch;
    }).toList();
  }

  int get expiringSoonCount {
    final now = DateTime.now();
    return _items.where((item) {
      final difference = item.earliestExpirationDate
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;
      return difference <= 3;
    }).length;
  }

  Map<String, int> get nutriscoreDistribution {
    final distribution = <String, int>{};
    for (var item in _items) {
      item.nutriscoreStats.forEach((key, count) {
         distribution[key] = (distribution[key] ?? 0) + count;
      });
    }
    return distribution;
  }

  Map<String, int> get categoryDistribution {
    final distribution = <String, int>{};
    for (var item in _items) {
      final categoryKey = item.category.key;
      distribution[categoryKey] = (distribution[categoryKey] ?? 0) + item.totalQuantity;
    }
    return distribution;
  }

  Map<String, int> get locationDistribution {
    final distribution = <String, int>{};
    for (var item in _items) {
      final locationKey = item.location.localizationKey;
      distribution[locationKey] = (distribution[locationKey] ?? 0) + item.totalQuantity;
    }
    return distribution;
  }

  List<InventoryItem> get expiringItems {
    final sortedItems = List<InventoryItem>.from(_items);
    sortedItems.sort((a, b) => a.earliestExpirationDate.compareTo(b.earliestExpirationDate));
    return sortedItems.take(10).toList();
  }

  Map<String, int> get storeDistribution {
    final distribution = <String, int>{};
    for (var item in _items) {
       item.storeStats.forEach((key, count) {
         distribution[key] = (distribution[key] ?? 0) + count;
      });
    }
    return distribution;
  }

  InventoryViewModel({
    required InventoryRepository inventoryRepository,
    required HistoryService historyService,
  })  : _inventoryRepository = inventoryRepository,
        _historyService = historyService;

  void init(String householdId) {
    if (_householdId == householdId) return;
    
    _householdId = householdId;
    _isLoading = true;
    notifyListeners();

    _inventorySubscription?.cancel();
    _inventorySubscription = _inventoryRepository.getInventoryStream(householdId).listen(
      (items) {
        _items = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint("Error fetching inventory: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setFilter(LocationFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addItem(InventoryItem item) async {
    if (_householdId == null) return;
    await _inventoryRepository.upsertInventoryItem(_householdId!, item);
  }

  Future<void> updateItem(InventoryItem item) async {
    if (_householdId == null) return;
    await _inventoryRepository.updateInventoryItem(_householdId!, item);
  }

  Future<void> deleteItem(String itemId, {bool logActivity = true}) async {
    if (_householdId == null) return;
    
    // Find item name for logging before deletion
    String itemName = 'Article';
    try {
      final item = _items.firstWhere((i) => i.id == itemId);
      itemName = item.name;
    } catch (_) {}

    await _inventoryRepository.deleteItem(_householdId!, itemId);

    if (logActivity) {
      await _historyService.logActivity(
        type: ActivityType.trashed,
        itemName: itemName,
      );
    }
  }

  Stream<List<Batch>> getBatchesStream(String itemId) {
    if (_householdId == null) return Stream.value([]);
    return _inventoryRepository.getBatchesStream(_householdId!, itemId);
  }

  Future<void> incrementItemQuantity(
    InventoryItem item, {
    required String defaultStoreName,
    required String defaultUserName,
  }) async {
    if (_householdId == null) return;

    // Log Activity
    await _historyService.logActivity(
      type: ActivityType.bought,
      itemName: item.name,
      details: {'quantity': 1, 'method': 'quick_add'},
    );

    // Get DVM from item or default
    int dvm = item.dvm;

    // Quick fetch of latest batch for enrichment & DVM check
    final batchesStream = _inventoryRepository.getBatchesStream(_householdId!, item.id);
    final upcomingBatches = await batchesStream.first;
    
    // If we have batches, check if we can deduce a better DVM
    if (upcomingBatches.isNotEmpty) {
      // Find the most recently added batch
      final recentBatch = upcomingBatches.reduce((curr, next) => 
        curr.addedAt.isAfter(next.addedAt) ? curr : next
      );

      final daysDiff = recentBatch.expirationDate.difference(recentBatch.addedAt).inDays;
      if (daysDiff > dvm) {
        dvm = daysDiff;
      }
    }

    final now = DateTime.now();
    final expirationDate = now.add(Duration(days: dvm > 0 ? dvm : 7));
    final user = FirebaseAuth.instance.currentUser;
    
    // Enrich from parent item (cache)
    // Since we don't have immediate access to other batches without async fetch, 
    // we use the item's current display properties as a baseline if they exist.
    // Or we could fetch the latest batch, but for performance let's stick to item properties + defaults.
    // Actually, the previous logic enriched from *existing* batches.
    // Given we moved to sub-collections, we can't synchronously iterate item.batches (it's empty or stale).
    // We will trust the item's cached "display" values if we want, OR we fetch the latest batch.
    // Let's simplified enrichment: use item fields. The rich data (images, brands) should be on the item if we want to reuse them.
    // But currently `InventoryItem` only has `imageUrl`.
    // Re-fetching batches is better for "smart" enrichment.
    

    
    String? brands;
    String? canonicalName = item.canonicalName;
    String? cleanedName = item.cleanedName;
    String? imageUrl = item.imageUrl;
    String? name = item.name;
    String? nutriscore;
    double? price;
    Map<String, String>? images;

    // Try to find better data from recent batches
    if (upcomingBatches.isNotEmpty) {
      // Logic: find first non-null
      for(final b in upcomingBatches) {
         if (brands == null || brands!.isEmpty) brands = b.brands;
         if (nutriscore == null || nutriscore!.isEmpty) nutriscore = b.nutriscore;
         if (price == null) price = b.price;
         if (images == null && b.images != null && b.images!.isNotEmpty) images = b.images;
      }
    }

    // Copied from recent batch if available, otherwise null.
    // User request: "mettre storeName à null ... si le batch recopie ne contient pas de storeName".
    // We prioritize the most recent batch's store.
    String? inheritedStoreName;
    if (upcomingBatches.isNotEmpty) {
       final recentBatch = upcomingBatches.reduce((curr, next) => 
         curr.addedAt.isAfter(next.addedAt) ? curr : next
       );
       inheritedStoreName = recentBatch.storeName;
    }

    final newBatch = Batch(
      id: '', // Will be generated by repository
      quantity: 1,
      expirationDate: expirationDate,
      addedAt: now,
      storeName: inheritedStoreName,
      // Enriched fields
      brands: brands,
      canonicalName: canonicalName,
      cleanedName: cleanedName,
      imageUrl: imageUrl,
      name: name,
      nutriscore: nutriscore,
      price: price,
      images: images,
      // User info: ONLY UID
      addedBy: user?.uid,
    );
    
    await _inventoryRepository.addBatch(_householdId!, item.id, newBatch);
  }

  Future<void> updateBatchDetails(InventoryItem item, Batch oldBatch, Batch newBatch) async {
    if (_householdId == null) return;
    
    // If quantity changed, we might want logs?
    // Repository handles the update logic
    await _inventoryRepository.updateBatch(_householdId!, item.id, newBatch);
    
    // If name/cleanedName changed on the batch and we propagated it to the item in UI logic,
    // we should also update the item itself.
    // The repository updateBatch ONLY updates the batch and aggregates (qty/date).
    // It does NOT update the item's name/image.
    
    if (item.name != newBatch.name || item.cleanedName != newBatch.cleanedName) {
       // Check if we need to update the parent item
       // This logic was partly in the UI "EditBatchesSheet".
       // We'll leave the explicitly passed 'item' (which might have been modified) to be updated via updateItem
       await updateItem(item); // Update parent fields if changed
    }
  }

  Future<void> deleteBatch(InventoryItem item, Batch batch) async {
    if (_householdId == null) return;
    await _inventoryRepository.deleteBatch(_householdId!, item.id, batch.id);
  }

  Future<void> decrementItemQuantity(InventoryItem item) async {
    if (_householdId == null || item.totalQuantity <= 0) return;

    // Log Consumption
    await _historyService.logActivity(
      type: ActivityType.consumed,
      itemName: item.name,
      details: {'quantity': 1},
    );

    // Delegate to Repository for transactional decrement on sub-collection
    await _inventoryRepository.decrementItemQuantity(_householdId!, item.id, 1);
  }

  Future<void> updateBatchDate(InventoryItem item, Batch batch, DateTime newDate) async {
    if (_householdId == null) return;

    final updatedBatch = batch.copyWith(expirationDate: newDate);
    // Delegate to Repository
    // Note: updateBatch in repo expects FULL update of the batch doc.
    await _inventoryRepository.updateBatch(_householdId!, item.id, updatedBatch);
  }

  Future<void> updateItemName(InventoryItem item, String newName) async {
    if (_householdId == null) return;
    
    // We update both name and cleanedName to the new value
    // Canonical name remains as is unless we want to re-normalize, 
    // but usually manual rename overrides everything.
    final updatedItem = item.copyWith(
      name: newName,
      cleanedName: newName,
    );

    await updateItem(updatedItem);
  }

  Future<void> updateItemCategory(InventoryItem item, String newCategory) async {
    if (_householdId == null) return;

    final updatedItem = item.copyWith(category: InventoryCategory.fromString(newCategory));
    await updateItem(updatedItem);
  }


  
  bool doesItemExist(String canonicalName) {
    return _items.any((item) => item.canonicalName == canonicalName);
  }

  @override
  void dispose() {
    _inventorySubscription?.cancel();
    super.dispose();
  }
}
