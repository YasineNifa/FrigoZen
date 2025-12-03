import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:frigo_zen/viewmodels/meal_planner_view_model.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/models/meal_plan.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/models/shopping_item.dart';
import 'package:frigo_zen/repositories/inventory_repository.dart';
import 'package:frigo_zen/repositories/shopping_repository.dart';
import 'package:frigo_zen/repositories/meal_planner_repository.dart';

// Mocks

class MockMealPlannerRepository extends MealPlannerRepository {
  final List<MealPlan> _meals = [];
  
  @override
  Stream<List<MealPlan>> getMealPlansStream(String householdId) {
    return Stream.value(_meals);
  }

  @override
  Future<void> addMealPlan(String householdId, MealPlan meal) async {
    _meals.add(meal);
  }

  @override
  Future<void> updateMealPlan(String householdId, String mealId, Map<String, dynamic> data) async {
    final index = _meals.indexWhere((m) => m.id == mealId);
    if (index != -1) {
      final oldMeal = _meals[index];
      _meals[index] = oldMeal.copyWith(
        recipeName: data['recipeName'] as String?,
        ingredients: (data['ingredients'] as List<dynamic>?)?.cast<String>(),
      );
    }
  }

  @override
  Future<void> deleteMealPlan(String householdId, String mealId) async {
    _meals.removeWhere((m) => m.id == mealId);
  }

  void setMeals(List<MealPlan> meals) {
    _meals.clear();
    _meals.addAll(meals);
  }
}

class MockInventoryRepository extends InventoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockShoppingRepository extends ShoppingRepository {
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
    
    // Setup MealPlanner
    final mockRepository = MockMealPlannerRepository();
    final mealPlanner = MealPlannerViewModel(repository: mockRepository);
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
    debugPrint("Added items: ${shopping.addedItems}");
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
    final mockRepository = MockMealPlannerRepository();
    final mealPlanner = MealPlannerViewModel(repository: mockRepository);
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
    expect(count, 1);
    expect(shopping.addedItems, contains('ognons'));
  });

  test('updateMeal updates an existing meal', () async {
    final mockRepository = MockMealPlannerRepository();
    final viewModel = MealPlannerViewModel(repository: mockRepository);
    viewModel.init('household1');

    final date = DateTime(2024, 12, 25);
    final meal = MealPlan(
      id: 'meal1',
      date: date,
      mealType: MealType.lunch,
      recipeId: '',
      recipeName: 'Old Name',
      householdId: 'household1',
      ingredients: ['Old Ing'],
    );
    // Set initial state in repository and viewmodel
    mockRepository.setMeals([meal]);
    viewModel.setMealsForTesting([meal]);

    await viewModel.updateMeal('meal1', 'New Name', ['New Ing']);

    expect(viewModel.meals.first.recipeName, 'New Name');
    expect(viewModel.meals.first.ingredients, ['New Ing']);
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
    final mockRepository = MockMealPlannerRepository();
    final mealPlanner = MealPlannerViewModel(repository: mockRepository);
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
    expect(count, 0);
  });
}
