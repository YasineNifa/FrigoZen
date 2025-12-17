import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frigo_zen/models/batch.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/repositories/inventory_repository.dart';
import 'package:frigo_zen/services/history_service.dart';
import 'package:frigo_zen/models/activity_log.dart';

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
      
      switch (_selectedFilter) {
        case LocationFilter.all:
          matchesLocation = true;
          break;
        case LocationFilter.fridge:
          final loc = item.location.toLowerCase();
          matchesLocation = loc == 'frigo' || loc == 'fridge' || loc == 'refrigerator' || loc == 'loc_fridge';
          break;
        case LocationFilter.pantry:
          final loc = item.location.toLowerCase();
          matchesLocation = loc == 'placard' || loc == 'pantry' || loc == 'loc_pantry';
          break;
        case LocationFilter.freezer:
          final loc = item.location.toLowerCase();
          matchesLocation = loc == 'congélateur' || loc == 'freezer' || loc == 'loc_freezer';
          break;
      }

      final matchesSearch = _searchQuery.isEmpty || 
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.canonicalName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.cleanedName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
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
      // Check batches for NutriScore
      for (var batch in item.batches) {
        if (batch.nutriscore != null && batch.nutriscore!.isNotEmpty) {
          final score = batch.nutriscore!.toUpperCase();
          distribution[score] = (distribution[score] ?? 0) + batch.quantity;
        }
      }
    }
    return distribution;
  }

  Map<String, int> get categoryDistribution {
    final distribution = <String, int>{};
    for (var item in _items) {
      final category = item.category;
      distribution[category] = (distribution[category] ?? 0) + item.totalQuantity;
    }
    return distribution;
  }

  Map<String, int> get locationDistribution {
    final distribution = <String, int>{};
    for (var item in _items) {
      final location = item.location;
      distribution[location] = (distribution[location] ?? 0) + item.totalQuantity;
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
      for (var batch in item.batches) {
        if (batch.storeName != null && batch.storeName!.isNotEmpty) {
          final store = batch.storeName!;
          distribution[store] = (distribution[store] ?? 0) + batch.quantity;
        }
      }
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

    await _inventoryRepository.deleteInventoryItem(_householdId!, itemId);

    if (logActivity) {
      await _historyService.logActivity(
        type: ActivityType.trashed,
        itemName: itemName,
      );
    }
  }

  Future<void> incrementItemQuantity(InventoryItem item) async {
    if (_householdId == null) return;

    // Log Activity (Quick Add)
    await _historyService.logActivity(
      type: ActivityType.bought,
      itemName: item.name,
      details: {'quantity': 1, 'method': 'quick_add'},
    );

    // Logic ported from InventoryService:
    // 1. Calculate expiration date based on DVM (Default Value Max? or Shelf Life)
    final int dvm = item.dvm; // Default to 7 if 0? Model defaults to 7 usually.
    final now = DateTime.now();
    final expirationDate = now.add(Duration(days: dvm > 0 ? dvm : 7));

    // 2. Create new batch
    final newBatch = Batch(
      quantity: 1,
      expirationDate: expirationDate,
      addedAt: now,
      storeName: 'Ajout Rapide',
    );

    // 3. Add to batches and sort
    final List<Batch> updatedBatches = List.from(item.batches);
    updatedBatches.add(newBatch);
    updatedBatches.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));

    // 4. Update item with new total quantity and earliest expiration date
    // Note: totalQuantity is calculated from batches in the service, 
    // but here we can just increment or recalculate. Recalculating is safer.
    final newTotalQuantity = updatedBatches.fold(0, (sum, b) => sum + b.quantity);
    
    final updatedItem = item.copyWith(
      totalQuantity: newTotalQuantity,
      batches: updatedBatches,
      earliestExpirationDate: updatedBatches.first.expirationDate,
    );

    await updateItem(updatedItem);
  }

  Future<void> decrementItemQuantity(InventoryItem item) async {
    if (_householdId == null || item.totalQuantity <= 0) return;

    // Log Consumption
    await _historyService.logActivity(
      type: ActivityType.consumed,
      itemName: item.name,
      details: {'quantity': 1},
    );

    // Logic ported from InventoryService:
    // 1. Sort batches by expiration date (already sorted usually, but good to be safe)
    final List<Batch> updatedBatches = List.from(item.batches);
    updatedBatches.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));

    if (updatedBatches.isEmpty) {
      // Should not happen if quantity > 0, but if it does, just delete item?
      // Or just decrement quantity?
      // If no batches but quantity > 0, it's an inconsistent state.
      // We'll just decrement totalQuantity to be safe, or delete if 1.
      if (item.totalQuantity <= 1) {
        await deleteItem(item.id, logActivity: false);
      } else {
        await updateItem(item.copyWith(totalQuantity: item.totalQuantity - 1));
      }
      return;
    }

    // 2. Decrement or remove the first (oldest) batch
    final firstBatch = updatedBatches.first;
    if (firstBatch.quantity > 1) {
      updatedBatches[0] = firstBatch.copyWith(quantity: firstBatch.quantity - 1);
    } else {
      updatedBatches.removeAt(0);
    }

    // 3. Check if item should be removed
    if (updatedBatches.isEmpty) {
      await deleteItem(item.id, logActivity: false);
      return;
    }

    // 4. Update item
    final newTotalQuantity = updatedBatches.fold(0, (sum, b) => sum + b.quantity);
    
    final updatedItem = item.copyWith(
      totalQuantity: newTotalQuantity,
      batches: updatedBatches,
      earliestExpirationDate: updatedBatches.first.expirationDate,
    );

    await updateItem(updatedItem);
  }

  Future<void> updateBatchDate(InventoryItem item, Batch batch, DateTime newDate) async {
    if (_householdId == null) return;

    final List<Batch> updatedBatches = List.from(item.batches);
    final index = updatedBatches.indexOf(batch);
    
    if (index != -1) {
      updatedBatches[index] = batch.copyWith(expirationDate: newDate);
      updatedBatches.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));

      final updatedItem = item.copyWith(
        batches: updatedBatches,
        earliestExpirationDate: updatedBatches.first.expirationDate,
      );

      await updateItem(updatedItem);
    }
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

    final updatedItem = item.copyWith(category: newCategory);
    await updateItem(updatedItem);
  }

  Future<void> updateBatchDetails(InventoryItem item, Batch oldBatch, Batch newBatch) async {
    if (_householdId == null) return;

    final List<Batch> updatedBatches = List.from(item.batches);
    final index = updatedBatches.indexOf(oldBatch);

    if (index != -1) {
      updatedBatches[index] = newBatch;
      updatedBatches.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));

      final newTotalQuantity = updatedBatches.fold(0, (sum, b) => sum + b.quantity);

      final updatedItem = item.copyWith(
        totalQuantity: newTotalQuantity,
        batches: updatedBatches,
        earliestExpirationDate: updatedBatches.first.expirationDate,
      );

      await updateItem(updatedItem);
    }
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
