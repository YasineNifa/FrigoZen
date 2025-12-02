import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:frigo_zen/models/shopping_item.dart';
import 'package:frigo_zen/repositories/shopping_repository.dart';
import 'package:frigo_zen/repositories/inventory_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/models/batch.dart';


class ShoppingViewModel extends ChangeNotifier {
  final ShoppingRepository _shoppingRepository;
  final InventoryRepository _inventoryRepository;

  // State
  List<ShoppingItem> _items = [];
  bool _isLoading = false;
  String? _householdId;
  StreamSubscription<List<ShoppingItem>>? _shoppingSubscription;

  // Getters
  List<ShoppingItem> get items => _items;
  bool get isLoading => _isLoading;

  ShoppingViewModel({
    required ShoppingRepository shoppingRepository,
    required InventoryRepository inventoryRepository,
  })  : _shoppingRepository = shoppingRepository,
        _inventoryRepository = inventoryRepository;

  void init(String householdId) {
    if (_householdId == householdId) return;

    _householdId = householdId;
    _isLoading = true;
    notifyListeners();

    _shoppingSubscription?.cancel();
    _shoppingSubscription = _shoppingRepository.getShoppingListStream(householdId).listen(
      (items) {
        _items = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print("Error fetching shopping list: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addItem(ShoppingItem item) async {
    if (_householdId == null) return;
    await _shoppingRepository.addShoppingItem(_householdId!, item);
  }

  Future<void> updateItem(ShoppingItem item) async {
    if (_householdId == null) return;
    await _shoppingRepository.updateShoppingItem(_householdId!, item);
  }

  Future<void> deleteItem(String itemId) async {
    if (_householdId == null) return;
    await _shoppingRepository.deleteShoppingItem(_householdId!, itemId);
  }

  Future<void> clearList() async {
    if (_householdId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _shoppingRepository.clearShoppingList(_householdId!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleItemChecked(ShoppingItem item) async {
    if (_householdId == null) return;
    final updatedItem = item.copyWith(isChecked: !item.isChecked);
    await _shoppingRepository.updateShoppingItem(_householdId!, updatedItem);
  }

  Future<ShoppingItem?> resolveItemName(String name) async {
    if (name.trim().isEmpty) return null;

    try {
      final functions = FirebaseFunctions.instanceFor(region: "us-central1");
      final callable = functions.httpsCallable('getSmartItemData');
      final result = await callable.call({'productName': name});
      final Map<String, dynamic> itemData = Map<String, dynamic>.from(
        result.data['item'],
      );

      return ShoppingItem(
        id: '',
        name: itemData['name'] ?? name,
        cleanedName: itemData['cleanedName'] ?? name,
        canonicalName: itemData['canonicalName'] ?? name,
        quantity: itemData['quantity'] ?? 1,
        dvm: itemData['dvm'] ?? 7,
        category: itemData['category'] ?? 'Other',
        location: itemData['location'] ?? 'Frigo',
        isChecked: false,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print("Error resolving smart item: $e");
      // Fallback to basic item if resolution fails
      return ShoppingItem(
        id: '',
        name: name,
        cleanedName: name.toLowerCase().trim(),
        canonicalName: name.toLowerCase().trim(),
        quantity: 1,
        isChecked: false,
        createdAt: DateTime.now(),
        category: 'Other',
        location: 'Frigo',
      );
    }
  }

  Future<void> addItemByName(String name) async {
    if (_householdId == null || name.trim().isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newItem = await resolveItemName(name);
      if (newItem != null) {
        await addItem(newItem);
      }
    } catch (e) {
      print("Error adding smart item: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItemsFromRecipe(List<String> ingredientNames) async {
    if (_householdId == null || ingredientNames.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final List<ShoppingItem> itemsToAdd = [];
      
      // Resolve all items first
      // We can do this in parallel for speed
      final results = await Future.wait(
        ingredientNames.map((name) => resolveItemName(name)),
      );

      for (var i = 0; i < results.length; i++) {
        final item = results[i];
        if (item != null) {
          itemsToAdd.add(item);
        } else {
          // Fallback if resolution failed (shouldn't happen often)
           itemsToAdd.add(ShoppingItem(
            id: '',
            name: ingredientNames[i],
            cleanedName: ingredientNames[i].toLowerCase().trim(),
            canonicalName: ingredientNames[i].toLowerCase().trim(),
            quantity: 1,
            isChecked: false,
            createdAt: DateTime.now(),
            category: 'Other',
            location: 'Frigo',
          ));
        }
      }

      if (itemsToAdd.isNotEmpty) {
        await _shoppingRepository.addShoppingItems(_householdId!, itemsToAdd);
      }

    } catch (e) {
      print("Error adding ingredients from recipe: $e");
      // We might want to rethrow or show error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> toggleSelectAll() async {
    if (_householdId == null || _items.isEmpty) return;

    final bool allChecked = _items.every((item) => item.isChecked);
    final bool newValue = !allChecked;

    // Batch update via repository would be ideal, but for now we iterate.
    // Ideally Repository should expose a batch update method.
    // Given the constraints, I'll update them one by one or add a batch method to repo later.
    // For now, let's assume we update them one by one (inefficient but works for small lists).
    // Actually, the original code used a batch.
    // I should probably add `updateShoppingItems` to Repository.
    // For this step, I will iterate.
    
    final List<ShoppingItem> itemsToUpdate = [];
    for (var item in _items) {
      if (item.isChecked != newValue) {
        itemsToUpdate.add(item.copyWith(isChecked: newValue));
      }
    }

    if (itemsToUpdate.isNotEmpty) {
      await _shoppingRepository.updateShoppingItems(_householdId!, itemsToUpdate);
    }
  }

  Future<void> moveCheckedItemsToInventory() async {
    if (_householdId == null) return;

    final checkedItems = _items.where((item) => item.isChecked).toList();
    if (checkedItems.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final List<String> itemIdsToDelete = [];

      for (var item in checkedItems) {
        // Create InventoryItem from ShoppingItem
        
        // Logic:
        // 1. Create Batch
        final now = DateTime.now();
        final expirationDate = now.add(Duration(days: item.dvm ?? 7));
        final batch = Batch(
          quantity: item.quantity,
          expirationDate: expirationDate,
          addedAt: now,
          storeName: item.storeName ?? 'Liste de courses',
          name: item.name,
          cleanedName: item.cleanedName,
          canonicalName: item.canonicalName,
          brands: item.brands,
          imageUrl: item.imageUrl,
          nutriscore: item.nutriscore,
        );
        
        // 2. Create InventoryItem
        final inventoryItem = InventoryItem(
          id: '',
          name: item.name,
          cleanedName: item.cleanedName,
          canonicalName: item.canonicalName,
          category: item.category,
          location: item.location,
          totalQuantity: item.quantity,
          batches: [batch],
          earliestExpirationDate: expirationDate,
          createdAt: now,
          dvm: item.dvm ?? 7,
        );

        // 3. Add to Inventory (Upsert) - Still sequential for now as InventoryRepo doesn't support batch upsert logic easily yet
        await _inventoryRepository.upsertInventoryItem(_householdId!, inventoryItem);

        // 4. Collect ID for batch deletion
        itemIdsToDelete.add(item.id);
      }

      // Batch delete from shopping list
      if (itemIdsToDelete.isNotEmpty) {
        await _shoppingRepository.deleteShoppingItems(_householdId!, itemIdsToDelete);
      }
    } catch (e) {
      print("Error moving items: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _shoppingSubscription?.cancel();
    super.dispose();
  }
}
