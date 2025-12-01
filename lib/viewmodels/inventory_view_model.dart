import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frigo_zen/models/batch.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/repositories/inventory_repository.dart';

class InventoryViewModel extends ChangeNotifier {
  final InventoryRepository _inventoryRepository;
  
  // State
  List<InventoryItem> _items = [];
  bool _isLoading = false;
  String _selectedLocation = "Tout";
  String _searchQuery = "";
  String? _householdId;
  StreamSubscription<List<InventoryItem>>? _inventorySubscription;

  // Getters
  List<InventoryItem> get items => _items;
  bool get isLoading => _isLoading;
  String get selectedLocation => _selectedLocation;
  String get searchQuery => _searchQuery;

  List<InventoryItem> get filteredItems {
    return _items.where((item) {
      final matchesLocation = _selectedLocation == "Tout" || item.location == _selectedLocation;
      final matchesSearch = _searchQuery.isEmpty || 
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.canonicalName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.cleanedName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesLocation && matchesSearch;
    }).toList();
  }

  InventoryViewModel({InventoryRepository? inventoryRepository})
      : _inventoryRepository = inventoryRepository ?? InventoryRepository();

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
        print("Error fetching inventory: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addItem(InventoryItem item) async {
    if (_householdId == null) return;
    await _inventoryRepository.addInventoryItem(_householdId!, item);
  }

  Future<void> updateItem(InventoryItem item) async {
    if (_householdId == null) return;
    await _inventoryRepository.updateInventoryItem(_householdId!, item);
  }

  Future<void> deleteItem(String itemId) async {
    if (_householdId == null) return;
    await _inventoryRepository.deleteInventoryItem(_householdId!, itemId);
  }

  Future<void> incrementItemQuantity(InventoryItem item) async {
    if (_householdId == null) return;

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
        await deleteItem(item.id);
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
      await deleteItem(item.id);
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
  
  bool doesItemExist(String canonicalName) {
    return _items.any((item) => item.canonicalName == canonicalName);
  }

  @override
  void dispose() {
    _inventorySubscription?.cancel();
    super.dispose();
  }
}
