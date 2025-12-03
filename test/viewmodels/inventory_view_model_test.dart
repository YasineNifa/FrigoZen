import 'package:flutter_test/flutter_test.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/models/batch.dart';
import 'package:frigo_zen/repositories/inventory_repository.dart';

// Mock Repository
class MockInventoryRepository implements InventoryRepository {
  List<InventoryItem> _items = [];
  bool shouldThrow = false;

  @override
  Stream<List<InventoryItem>> getInventoryStream(String householdId, {String? location}) {
    if (shouldThrow) return Stream.error("Error");
    return Stream.value(_items);
  }

  @override
  Future<void> addInventoryItem(String householdId, InventoryItem item) async {
    if (shouldThrow) throw Exception("Error adding item");
    _items.add(item);
  }

  @override
  Future<void> updateInventoryItem(String householdId, InventoryItem item) async {
    if (shouldThrow) throw Exception("Error updating item");
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
    }
  }

  @override
  Future<void> deleteInventoryItem(String householdId, String itemId) async {
    if (shouldThrow) throw Exception("Error deleting item");
    _items.removeWhere((i) => i.id == itemId);
  }

  @override
  Future<InventoryItem?> getInventoryItemByCanonicalName(String householdId, String canonicalName) async {
    try {
        return _items.firstWhere((i) => i.canonicalName == canonicalName);
    } catch (e) {
        return null;
    }
  }

  @override
  DateTime getEarliestDate(List<Batch> batches) => DateTime.now();

  @override
  Future<InventoryItem?> findExistingItem(String householdId, String canonicalName, String name) async {
    try {
      return _items.firstWhere((i) => i.canonicalName == canonicalName || i.name == name);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> upsertInventoryItem(String householdId, InventoryItem item) async {
    if (shouldThrow) throw Exception("Error upserting item");
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
    } else {
      _items.add(item);
    }
  }
}

void main() {
  late InventoryViewModel viewModel;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    viewModel = InventoryViewModel(inventoryRepository: mockRepository);
    viewModel.init("test_household");
  });

  group('InventoryViewModel Tests', () {
    test('Initial state is empty', () {
      expect(viewModel.items, isEmpty);
      expect(viewModel.isLoading, false);
    });

    test('addItem adds item to list', () async {
      final item = InventoryItem(
        id: '1',
        name: 'Milk',
        cleanedName: 'milk',
        canonicalName: 'milk',
        category: 'Other',
        location: 'Frigo',
        totalQuantity: 1,
        earliestExpirationDate: DateTime.now(),
        createdAt: DateTime.now(),
        dvm: 7,
        batches: [],
      );

      await viewModel.addItem(item);

      // Wait for stream to update
      await Future.delayed(Duration.zero);

      expect(viewModel.items.length, 1);
      expect(viewModel.items.first.name, 'Milk');
    });

    test('updateItemName updates item name', () async {
      final item = InventoryItem(
        id: '1',
        name: 'Milk',
        cleanedName: 'milk',
        canonicalName: 'milk',
        category: 'Other',
        location: 'Frigo',
        totalQuantity: 1,
        earliestExpirationDate: DateTime.now(),
        createdAt: DateTime.now(),
        dvm: 7,
        batches: [],
      );
      await viewModel.addItem(item);
      await Future.delayed(Duration.zero);

      await viewModel.updateItemName(item, 'Fresh Milk');
      await Future.delayed(Duration.zero);

      expect(viewModel.items.first.name, 'Fresh Milk');
    });

    test('deleteItem removes item from list', () async {
      final item = InventoryItem(
        id: '1',
        name: 'Milk',
        cleanedName: 'milk',
        canonicalName: 'milk',
        category: 'Other',
        location: 'Frigo',
        totalQuantity: 1,
        earliestExpirationDate: DateTime.now(),
        createdAt: DateTime.now(),
        dvm: 7,
        batches: [],
      );
      await viewModel.addItem(item);
      await Future.delayed(Duration.zero);
      expect(viewModel.items.length, 1);

      await viewModel.deleteItem('1');
      await Future.delayed(Duration.zero);

      expect(viewModel.items, isEmpty);
    });
    
    test('doesItemExist returns correct value', () async {
       final item = InventoryItem(
        id: '1',
        name: 'Milk',
        cleanedName: 'milk',
        canonicalName: 'milk',
        category: 'Other',
        location: 'Frigo',
        totalQuantity: 1,
        earliestExpirationDate: DateTime.now(),
        createdAt: DateTime.now(),
        dvm: 7,
        batches: [],
      );
      await viewModel.addItem(item);
      await Future.delayed(Duration.zero);
      
      expect(viewModel.doesItemExist('milk'), true);
      expect(viewModel.doesItemExist('bread'), false);
    });
  });
}
