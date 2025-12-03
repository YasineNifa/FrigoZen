import 'package:flutter_test/flutter_test.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/models/shopping_item.dart';
import 'package:frigo_zen/repositories/shopping_repository.dart';
import 'package:frigo_zen/repositories/inventory_repository.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/models/batch.dart';

// Mock Shopping Repository
class MockShoppingRepository implements ShoppingRepository {
  final List<ShoppingItem> _items = [];
  bool shouldThrow = false;

  @override
  Stream<List<ShoppingItem>> getShoppingListStream(String householdId) {
    if (shouldThrow) return Stream.error("Error");
    return Stream.value(_items);
  }

  // Removed @override
  @override
  Future<void> addShoppingItem(String householdId, ShoppingItem item) async {
    if (shouldThrow) throw Exception("Error adding item");
    _items.add(item);
  }

  @override
  Future<void> updateShoppingItem(String householdId, ShoppingItem item) async {
    if (shouldThrow) throw Exception("Error updating item");
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
    }
  }

  @override
  Future<void> deleteShoppingItem(String householdId, String itemId) async {
    if (shouldThrow) throw Exception("Error deleting item");
    _items.removeWhere((i) => i.id == itemId);
  }

  @override
  Future<void> addShoppingItems(String householdId, List<ShoppingItem> items) async {
    if (shouldThrow) throw Exception("Error adding items");
    _items.addAll(items);
  }

  @override
  Future<void> clearShoppingList(String householdId) async {
    if (shouldThrow) throw Exception("Error clearing list");
    _items.clear();
  }

  @override
  Future<void> deleteShoppingItems(String householdId, List<String> itemIds) async {
    if (shouldThrow) throw Exception("Error deleting items");
    _items.removeWhere((i) => itemIds.contains(i.id));
  }

  @override
  Future<void> updateShoppingItems(String householdId, List<ShoppingItem> items) async {
    if (shouldThrow) throw Exception("Error updating items");
    for (var item in items) {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
      }
    }
  }
}

// Mock Inventory Repository
class MockInventoryRepository implements InventoryRepository {
  @override
  Future<void> addInventoryItem(String householdId, InventoryItem item) async {}
  
  @override
  Future<void> deleteInventoryItem(String householdId, String itemId) async {}
  
  @override
  Stream<List<InventoryItem>> getInventoryStream(String householdId, {String? location}) => Stream.value([]);
  
  @override
  Future<void> updateInventoryItem(String householdId, InventoryItem item) async {}



  @override
  DateTime getEarliestDate(List<Batch> batches) => DateTime.now();

  @override
  Future<InventoryItem?> findExistingItem(String householdId, String canonicalName, String name) async => null;

  @override
  Future<void> upsertInventoryItem(String householdId, InventoryItem item) async {}
}

void main() {
  late ShoppingViewModel viewModel;
  late MockShoppingRepository mockRepository;
  late MockInventoryRepository mockInventoryRepository;

  setUp(() {
    mockRepository = MockShoppingRepository();
    mockInventoryRepository = MockInventoryRepository();
    viewModel = ShoppingViewModel(
      shoppingRepository: mockRepository,
      inventoryRepository: mockInventoryRepository,
    );
    viewModel.init("test_household");
  });

  group('ShoppingViewModel Tests', () {
    test('Initial state is empty', () {
      expect(viewModel.items, isEmpty);
    });

    test('addItem adds item to list', () async {
      final item = ShoppingItem(
        id: '1',
        name: 'Milk',
        cleanedName: 'milk',
        canonicalName: 'milk',
        isChecked: false,
        quantity: 1,
        createdAt: DateTime.now(),
        category: 'Other',
        location: 'Frigo',
      );
      
      await viewModel.addItem(item);
      
      // Wait for stream listener to fire
      await Future.delayed(Duration.zero);

      expect(viewModel.items.length, 1);
      expect(viewModel.items.first.name, 'Milk');
      expect(viewModel.items.first.isChecked, false);
    });

    test('toggleItemChecked updates isChecked status', () async {
      final item = ShoppingItem(
        id: '1',
        name: 'Milk',
        cleanedName: 'milk',
        canonicalName: 'milk',
        isChecked: false,
        quantity: 1,
        createdAt: DateTime.now(),
        category: 'Other',
        location: 'Frigo',
      );
      await viewModel.addItem(item);
      await Future.delayed(Duration.zero);
      
      final addedItem = viewModel.items.first;
      await viewModel.toggleItemChecked(addedItem);
      await Future.delayed(Duration.zero);

      expect(viewModel.items.first.isChecked, true);
    });

    test('deleteItem removes item', () async {
      final item = ShoppingItem(
        id: '1',
        name: 'Milk',
        cleanedName: 'milk',
        canonicalName: 'milk',
        isChecked: false,
        quantity: 1,
        createdAt: DateTime.now(),
        category: 'Other',
        location: 'Frigo',
      );
      await viewModel.addItem(item);
      await Future.delayed(Duration.zero);
      
      final addedItem = viewModel.items.first;
      await viewModel.deleteItem(addedItem.id);
      await Future.delayed(Duration.zero);

      expect(viewModel.items, isEmpty);
    });
  });
}
