import 'package:flutter_test/flutter_test.dart';
import 'package:frigo_zen/viewmodels/meal_planner_view_model.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/models/meal_plan.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/models/shopping_item.dart';
import 'package:frigo_zen/repositories/inventory_repository.dart';
import 'package:frigo_zen/repositories/shopping_repository.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

// Mocks
class MockFirebaseFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockInventoryRepository implements InventoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockShoppingRepository implements ShoppingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockInventoryViewModel extends InventoryViewModel {
  final List<InventoryItem> _testItems;

  MockInventoryViewModel(this._testItems) 
      : super(inventoryRepository: MockInventoryRepository());

  @override
  List<InventoryItem> get items => _testItems;

  @override
  bool doesItemExist(String canonicalName) {
    return _testItems.any((item) => item.canonicalName == canonicalName);
  }
}

class MockShoppingViewModel extends ShoppingViewModel {
  final List<String> addedItems = [];

  MockShoppingViewModel() 
      : super(shoppingRepository: MockShoppingRepository(), inventoryRepository: MockInventoryRepository());

  @override
  Future<void> addItemsFromRecipe(List<String> ingredientNames) async {
    addedItems.addAll(ingredientNames);
  }

  @override
  Future<ShoppingItem?> resolveItemName(String name) async {
    if (name == 'ognons') {
      return ShoppingItem(
        id: 'mock_id',
        name: 'Oignon',
        cleanedName: 'oignon',
        canonicalName: 'Oignon',
        quantity: 1,
        isChecked: false,
        createdAt: DateTime.now(),
        category: 'Veg',
        location: 'Frigo',
      );
    }
    return null;
  }
}

void main() {
  test('generateShoppingList adds only missing ingredients (strict match)', () async {
    // Setup Inventory
    final inventoryItems = [
      InventoryItem(
        id: '1',
        name: 'Pâtes',
        cleanedName: 'pates',
        canonicalName: 'pates',
        category: 'Dry',
        location: 'Pantry',
        totalQuantity: 1,
        batches: [],
        earliestExpirationDate: DateTime.now(),
        createdAt: DateTime.now(),
        dvm: 7,
      ),
      InventoryItem(
        id: '2',
        name: 'Oignon',
        cleanedName: 'oignon',
        canonicalName: 'Oignon',
        category: 'Veg',
        location: 'Frigo',
        totalQuantity: 1,
        batches: [],
        earliestExpirationDate: DateTime.now(),
        createdAt: DateTime.now(),
        dvm: 7,
      ),
    ];
    final inventory = MockInventoryViewModel(inventoryItems);

    // Setup Shopping
    final shopping = MockShoppingViewModel();
    // Mock resolveItemName
    // We can't easily mock resolveItemName on the instance unless we override it in the Mock class.
    // Let's update MockShoppingViewModel to handle resolveItemName.
    
    // Setup MealPlanner
    final mealPlanner = MealPlannerViewModel(firestore: MockFirebaseFirestore());
    final meal = MealPlan(
      id: '1',
      date: DateTime.now(),
      mealType: MealType.lunch,
      recipeId: '',
      recipeName: 'Test Meal',
      householdId: 'h1',
      ingredients: ['ognons', 'Pâtes'], // 'ognons' -> 'Oignon' (exists), 'Pâtes' (exists)
    );
    mealPlanner.setMealsForTesting([meal]);

    // Execute
    final count = await mealPlanner.generateShoppingList(inventory, shopping, isPro: true);

    // Verify
    // 'Pâtes' matches raw name 'Pâtes' in inventory -> Skipped (Optimization)
    // 'ognons' does NOT match raw name.
    // 'ognons' resolves to 'Oignon'.
    // 'Oignon' exists in inventory (we need to add it to mock inventory).
    // So both should be skipped.
    print("Added items: ${shopping.addedItems}");
    expect(count, 0);
  });

  test('generateShoppingList with isPro=false does NOT resolve canonical name', () async {
    // Setup Inventory
    final inventoryItems = [
      InventoryItem(
        id: '2',
        name: 'Oignon',
        cleanedName: 'oignon',
        canonicalName: 'Oignon',
        category: 'Veg',
        location: 'Frigo',
        totalQuantity: 1,
        batches: [],
        earliestExpirationDate: DateTime.now(),
        createdAt: DateTime.now(),
        dvm: 7,
      ),
    ];
    final inventory = MockInventoryViewModel(inventoryItems);

    // Setup Shopping
    final shopping = MockShoppingViewModel();
    
    // Setup MealPlanner
    final mealPlanner = MealPlannerViewModel(firestore: MockFirebaseFirestore());
    final meal = MealPlan(
      id: '1',
      date: DateTime.now(),
      mealType: MealType.lunch,
      recipeId: '',
      recipeName: 'Test Meal',
      householdId: 'h1',
      ingredients: ['ognons'], // 'ognons' -> 'Oignon' (exists)
    );
    mealPlanner.setMealsForTesting([meal]);

    // Execute with isPro = false
    final count = await mealPlanner.generateShoppingList(inventory, shopping, isPro: false);

    // Verify
    // 'ognons' does not match 'Oignon' (raw check).
    // Resolution is skipped.
    // So 'ognons' should be ADDED.
    
    expect(count, 1);
    expect(shopping.addedItems, contains('ognons'));
  });

  test('generateShoppingList with isPro=true DOES resolve canonical name', () async {
    // Setup Inventory
    final inventoryItems = [
      InventoryItem(
        id: '2',
        name: 'Oignon',
        cleanedName: 'oignon',
        canonicalName: 'Oignon',
        category: 'Veg',
        location: 'Frigo',
        totalQuantity: 1,
        batches: [],
        earliestExpirationDate: DateTime.now(),
        createdAt: DateTime.now(),
        dvm: 7,
      ),
    ];
    final inventory = MockInventoryViewModel(inventoryItems);

    // Setup Shopping
    final shopping = MockShoppingViewModel();
    
    // Setup MealPlanner
    final mealPlanner = MealPlannerViewModel(firestore: MockFirebaseFirestore());
    final meal = MealPlan(
      id: '1',
      date: DateTime.now(),
      mealType: MealType.lunch,
      recipeId: '',
      recipeName: 'Test Meal',
      householdId: 'h1',
      ingredients: ['ognons'], // 'ognons' -> 'Oignon' (exists)
    );
    mealPlanner.setMealsForTesting([meal]);

    // Execute with isPro = true
    final count = await mealPlanner.generateShoppingList(inventory, shopping, isPro: true);

    // Verify
    // 'ognons' resolves to 'Oignon'.
    // 'Oignon' exists in inventory.
    // So 'ognons' should be SKIPPED.
    
    expect(count, 0);
  });
}
