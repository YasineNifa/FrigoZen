import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/repositories/inventory_repository.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/models/batch.dart';
import 'dart:async';

// Generate Mocks
@GenerateMocks([InventoryRepository])
import 'inventory_view_model_test.mocks.dart';

void main() {
  late InventoryViewModel viewModel;
  late MockInventoryRepository mockRepository;

  setUp(() {
    mockRepository = MockInventoryRepository();
    viewModel = InventoryViewModel(inventoryRepository: mockRepository);
  });

  group('InventoryViewModel Tests', () {
    // Helper to create a basic item
    InventoryItem createItem(
        {required String id,
        required String name,
        required String location,
        int daysUntilExpiration = 10}) {
      final now = DateTime.now();
      final expirationDate = now.add(Duration(days: daysUntilExpiration));
      
      return InventoryItem(
        id: id,
        name: name,
        canonicalName: name.toLowerCase(),
        cleanedName: name,
        category: 'cat_other',
        location: location,
        totalQuantity: 1,
        createdAt: now,
        dvm: 7,
        batches: [
          Batch(
            quantity: 1,
            expirationDate: expirationDate,
            addedAt: now,
          )
        ],
        earliestExpirationDate: expirationDate,
      );
    }

    test('Initial state is correct', () {
      expect(viewModel.items, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.selectedFilter, LocationFilter.all);
    });

    test('init loads items from repository', () async {
      final items = [
        createItem(id: '1', name: 'Milk', location: 'Fridge'),
        createItem(id: '2', name: 'Pasta', location: 'Pantry'),
      ];

      when(mockRepository.getInventoryStream('household1'))
          .thenAnswer((_) => Stream<List<InventoryItem>>.value(items));

      viewModel.init('household1');

      // Wait for stream to emit
      await Future.delayed(Duration.zero);

      expect(viewModel.items.length, 2);
      expect(viewModel.isLoading, false);
    });

    test('Filtering by location works', () async {
      final items = [
        createItem(id: '1', name: 'Milk', location: 'loc_fridge'),
        createItem(id: '2', name: 'Pasta', location: 'loc_pantry'),
        createItem(id: '3', name: 'Ice Cream', location: 'loc_freezer'),
      ];

      // Reset VM with items directly (simulating loaded state)
      when(mockRepository.getInventoryStream('household1'))
          .thenAnswer((_) => Stream<List<InventoryItem>>.value(items));
      viewModel.init('household1');
      await Future.delayed(Duration.zero);

      // Filter Fridge
      viewModel.setFilter(LocationFilter.fridge);
      expect(viewModel.filteredItems.length, 1);
      expect(viewModel.filteredItems.first.name, 'Milk');

      // Filter Pantry
      viewModel.setFilter(LocationFilter.pantry);
      expect(viewModel.filteredItems.length, 1);
      expect(viewModel.filteredItems.first.name, 'Pasta');
      
       // Filter Freezer
      viewModel.setFilter(LocationFilter.freezer);
      expect(viewModel.filteredItems.length, 1);
      expect(viewModel.filteredItems.first.name, 'Ice Cream');

      // Filter All
      viewModel.setFilter(LocationFilter.all);
      expect(viewModel.filteredItems.length, 3);
    });

    test('Search query filters items', () async {
      final items = [
        createItem(id: '1', name: 'Apple', location: 'Fridge'),
        createItem(id: '2', name: 'Banana', location: 'Fridge'),
      ];

      when(mockRepository.getInventoryStream('household1'))
          .thenAnswer((_) => Stream<List<InventoryItem>>.value(items));
      viewModel.init('household1');
      await Future.delayed(Duration.zero);

      viewModel.setSearchQuery('App');
      expect(viewModel.filteredItems.length, 1);
      expect(viewModel.filteredItems.first.name, 'Apple');

      viewModel.setSearchQuery('z');
      expect(viewModel.filteredItems, isEmpty);
    });

    test('expiringSoonCount counts items expiring in <= 3 days', () async {
      final items = [
        createItem(id: '1', name: 'Expired', daysUntilExpiration: -1, location: 'Fridge'),
        createItem(id: '2', name: 'Urgent', daysUntilExpiration: 2, location: 'Fridge'), // <= 3
        createItem(id: '3', name: 'Limit', daysUntilExpiration: 3, location: 'Fridge'), // <= 3
        createItem(id: '4', name: 'Fine', daysUntilExpiration: 4, location: 'Fridge'), // > 3
      ];

      when(mockRepository.getInventoryStream('household1'))
          .thenAnswer((_) => Stream<List<InventoryItem>>.value(items));
      viewModel.init('household1');
      await Future.delayed(Duration.zero);


      // Expired (-1) + Urgent (2) + Limit (3) = 3 items
      expect(viewModel.expiringSoonCount, 3);
    });
  });
}
