import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:frigo_zen/models/shopping_item.dart';
import 'package:frigo_zen/repositories/shopping_repository.dart';
import 'package:frigo_zen/repositories/inventory_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:frigo_zen/repositories/product_catalog_repository.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/models/batch.dart';
import 'package:frigo_zen/constants/app_categories.dart';
import 'package:frigo_zen/services/history_service.dart';
import 'package:frigo_zen/models/activity_log.dart';
import 'package:frigo_zen/models/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShoppingViewModel extends ChangeNotifier {
  final ShoppingRepository _shoppingRepository;
  final InventoryRepository _inventoryRepository;
  final HistoryService _historyService;

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
    required HistoryService historyService,
  })  : _shoppingRepository = shoppingRepository,
        _inventoryRepository = inventoryRepository,
        _historyService = historyService;

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
        debugPrint("Error fetching shopping list: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addItem(ShoppingItem item) async {
    if (_householdId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    final itemWithCreator = item.copyWith(
      creatorId: user?.uid,
      creatorName: user?.displayName ?? 'Utilisateur',
      creatorAvatar: user?.photoURL,
    );
    
    await _shoppingRepository.addShoppingItem(_householdId!, itemWithCreator);
    
    await _historyService.logActivity(
      type: ActivityType.addedShopping,
      itemName: item.name,
    );
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

  Future<ShoppingItem?> resolveItemName(String name, String languageCode) async {
    if (name.trim().isEmpty) return null;

    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('getSmartItemData')
          .call({
        'productName': name,
        'language': languageCode,
      });final Map<String, dynamic> itemData = Map<String, dynamic>.from(
        result.data['item'],
      );

      final categoryStr = AppCategories.normalize(itemData['category']);
      final category = InventoryCategory.fromString(categoryStr);
      final rawLocation = itemData['location'];
      final int locationId = rawLocation != null 
          ? StorageLocation.fromId(rawLocation).id 
          : category.defaultLocation.id;

      return ShoppingItem(
        id: '',
        name: itemData['name'] ?? name,
        cleanedName: itemData['cleanedName'] ?? name,
        canonicalName: itemData['canonicalName'] ?? name,
        quantity: itemData['quantity'] ?? 1,
        dvm: itemData['dvm'] ?? 7,
        category: categoryStr,
        location: locationId,
        isChecked: false,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint("Error resolving smart item: $e");
      // Fallback to basic item if resolution fails
      return ShoppingItem(
        id: '',
        name: name,
        cleanedName: name.toLowerCase().trim(),
        canonicalName: name.toLowerCase().trim(),
        quantity: 1,
        isChecked: false,
        createdAt: DateTime.now(),
        category: 'cat_other',
        location: StorageLocation.other.id,
      );
    }
  }

  Future<void> addItemByName(String name, String languageCode) async {
    if (_householdId == null || name.trim().isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newItem = await resolveItemName(name, languageCode);
      if (newItem != null) {
        await addItem(newItem);
      }
    } catch (e) {
      debugPrint("Error adding smart item: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItemsFromRecipe(List<String> ingredientNames, String languageCode, {bool checkInventory = false}) async {
    if (_householdId == null || ingredientNames.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final List<ShoppingItem> itemsToAdd = [];
      
      // Resolve all items first
      final results = await Future.wait(
        ingredientNames.map((name) => resolveItemName(name, languageCode)),
      );

      final user = FirebaseAuth.instance.currentUser;

      for (var i = 0; i < results.length; i++) {
        final item = results[i];
        if (item != null) {
          if (checkInventory) {
              final exists = await _inventoryRepository.findExistingItem(
                _householdId!, 
                item.canonicalName, 
                item.name
              );
              
              if (exists != null) {
                continue;
              }
          }
          
          itemsToAdd.add(item.copyWith(
            creatorId: user?.uid,
            creatorName: user?.displayName ?? 'Utilisateur',
            creatorAvatar: user?.photoURL,
          ));
        } else {
           // Fallback if resolution failed
           itemsToAdd.add(ShoppingItem(
            id: '',
            name: ingredientNames[i],
            cleanedName: ingredientNames[i].toLowerCase().trim(),
            canonicalName: ingredientNames[i].toLowerCase().trim(),
            quantity: 1,
            isChecked: false,
            createdAt: DateTime.now(),
            category: 'cat_other',
            location: StorageLocation.other.id,
            creatorId: user?.uid,
            creatorName: user?.displayName ?? 'Utilisateur',
            creatorAvatar: user?.photoURL,
          ));
        }
      }

      if (itemsToAdd.isNotEmpty) {
        await _shoppingRepository.addShoppingItems(_householdId!, itemsToAdd);
        
        // Log activities
        for (var item in itemsToAdd) {
           _historyService.logActivity(
            type: ActivityType.addedShopping,
            itemName: item.name,
            details: {'source': 'recipe'},
          );
        }
      }

    } catch (e) {
      debugPrint("Error adding ingredients from recipe: $e");
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

  Future<void> moveCheckedItemsToInventory(String? defaultStoreName) async {
    if (_householdId == null) return;

    final checkedItems = _items.where((item) => item.isChecked).toList();
    if (checkedItems.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final List<String> itemIdsToDelete = [];

      // Process items in parallel
      await Future.wait(checkedItems.map((item) async {
        // Logic:
        // 1. Create Batch
        final now = DateTime.now();
        final expirationDate = now.add(Duration(days: item.dvm ?? 7));
        final batch = Batch(
          id: '',
          quantity: item.quantity,
          expirationDate: expirationDate,
          addedAt: now,
          storeName: item.storeName ?? defaultStoreName,
          name: item.name,
          cleanedName: item.cleanedName,
          canonicalName: item.canonicalName,
          imageUrl: item.imageUrl,
          nutriscore: item.nutriscore,
          addedBy: FirebaseAuth.instance.currentUser?.uid,
        );
        
        // 2. Create InventoryItem
        final inventoryItem = InventoryItem(
          id: '',
          name: item.name,
          cleanedName: item.cleanedName,
          canonicalName: item.canonicalName,
          category: InventoryCategory.fromString(item.category),
          location: StorageLocation.fromId(item.location),
          totalQuantity: item.quantity,
          batches: [batch],
          earliestExpirationDate: expirationDate,
          createdAt: now,
          dvm: item.dvm ?? 7,
        );

        // 3. Add to Inventory (Upsert)
        await _inventoryRepository.upsertInventoryItem(_householdId!, inventoryItem);

        // 4. Log Activity
        await _historyService.logActivity(
          type: ActivityType.bought,
          itemName: item.name,
          details: {
            'quantity': item.quantity,
            'store': item.storeName ?? defaultStoreName,
          }
        );

        // 5. Log to Catalog
        try {
          final catalogRepo = ProductCatalogRepository();
          await catalogRepo.logItemToCatalog(
            name: item.name,
            canonicalName: item.canonicalName,
            category: item.category,
            defaultDVM: item.dvm ?? 7,
            imageUrl: item.imageUrl,
            nutriscore: item.nutriscore,
            storeName: item.storeName ?? defaultStoreName,
            // Price is not tracked in Shopping Item currently, but if we had it:
            // lastPrice: item.price, 
            // Since we don't, we omit it or pass null.
          );
        } catch (e) {
          debugPrint("Error logging to catalog: $e");
        }
      }));
      
      // Collect IDs after parallel execution
      itemIdsToDelete.addAll(checkedItems.map((e) => e.id));

      // Batch delete from shopping list
      if (itemIdsToDelete.isNotEmpty) {
        await _shoppingRepository.deleteShoppingItems(_householdId!, itemIdsToDelete);
      }
    } catch (e) {
      debugPrint("Error moving items: $e");
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
