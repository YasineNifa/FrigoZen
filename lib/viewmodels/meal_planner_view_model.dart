import 'package:flutter/foundation.dart';

import 'package:frigo_zen/models/meal_plan.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/repositories/meal_planner_repository.dart';
import 'dart:async'; // Required for StreamSubscription

class MealPlannerViewModel extends ChangeNotifier {
  final MealPlannerRepository _repository;
  
  // State
  List<MealPlan> _meals = [];
  bool _isLoading = false;
  String? _householdId;
  StreamSubscription<List<MealPlan>>? _mealsSubscription;

  List<MealPlan> get meals => _meals;
  bool get isLoading => _isLoading;

  MealPlannerViewModel({MealPlannerRepository? repository})
      : _repository = repository ?? MealPlannerRepository();

  void init(String householdId) {
    if (_householdId == householdId) return; // Avoid re-initializing if already set
    _householdId = householdId;
    _fetchMeals();
  }

  void _fetchMeals() {
    if (_householdId == null) return;

    _isLoading = true;
    notifyListeners();

    _mealsSubscription?.cancel(); // Cancel previous subscription if any
    _mealsSubscription = _repository.getMealPlansStream(_householdId!).listen(
      (meals) {
        _meals = meals;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint("Error fetching meal plans: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addMeal(DateTime date, MealType type, String name, {List<String> ingredients = const []}) async {
    if (_householdId == null) return;

    final newMeal = MealPlan(
      id: '',
      date: date,
      mealType: type,
      recipeId: '', // Custom meal for now
      recipeName: name,
      householdId: _householdId!,
      ingredients: ingredients,
    );

    await _repository.addMealPlan(_householdId!, newMeal);
  }

  Future<void> deleteMeal(String mealId) async {
    if (_householdId == null) return;

    await _repository.deleteMealPlan(_householdId!, mealId);
  }

  Future<void> updateMeal(String mealId, String newName, List<String> newIngredients) async {
    if (_householdId == null) return;

    // Optimistic update
    final index = _meals.indexWhere((m) => m.id == mealId);
    if (index != -1) {
      final oldMeal = _meals[index];
      final updatedMeal = oldMeal.copyWith(
        recipeName: newName,
        ingredients: newIngredients,
      );
      _meals[index] = updatedMeal;
      notifyListeners();

      try {
        await _repository.updateMealPlan(_householdId!, mealId, {
          'recipeName': newName,
          'ingredients': newIngredients,
        });
      } catch (e) {
        // Revert on failure
        _meals[index] = oldMeal;
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<int> generateShoppingList(
    InventoryViewModel inventory, 
    ShoppingViewModel shopping, 
    String languageCode, {
    required DateTime start,
    required DateTime end,
    bool isPro = false,
  }) async {
    // 1. Filter meals by date range
    final relevantMeals = _meals.where((m) {
      final date = m.date;
      return date.isAfter(start.subtract(const Duration(milliseconds: 1))) && 
             date.isBefore(end.add(const Duration(milliseconds: 1)));
    }).toList();

    if (relevantMeals.isEmpty) return 0;

    final Set<String> rawIngredientsToAdd = {};

    // 2. Collect unique ingredients from relevant meals
    for (final meal in relevantMeals) {
      for (final ingredient in meal.ingredients) {
        if (ingredient.trim().isNotEmpty) {
          rawIngredientsToAdd.add(ingredient);
        }
      }
    }

    if (rawIngredientsToAdd.isEmpty) return 0;

    // 3. Initial Local Filtering (Raw Name Check - Fast)
    // Filter out items that definitely exist based on simple string path (e.g. "Milk" vs "Milk")
    final List<String> potentialCandidates = [];
    
    for (final rawName in rawIngredientsToAdd) {
        final normalizedRaw = rawName.trim().toLowerCase();

        // Check raw name in inventory
        final hasRawInInventory = inventory.items.any((item) => 
          item.name.trim().toLowerCase() == normalizedRaw || 
          (item.canonicalName != null && item.canonicalName!.toLowerCase() == normalizedRaw)
        );
        if (hasRawInInventory) continue;

        // Check raw name in shopping list
        final hasRawInShopping = shopping.items.any((item) => 
          item.name.trim().toLowerCase() == normalizedRaw ||
          (item.canonicalName != null && item.canonicalName!.toLowerCase() == normalizedRaw)
        );
        if (hasRawInShopping) continue;

        potentialCandidates.add(rawName);
    }

    if (potentialCandidates.isEmpty) return 0;

    // 4. Resolve Items and Add to Shopping List
    final List<String> finalItemsToAdd = [];

    if (isPro) {
      // Parallel Resolution for Pro users
      final resolvedItems = await Future.wait(
        potentialCandidates.map((name) => shopping.resolveItemName(name, languageCode))
      );

      for (var i = 0; i < potentialCandidates.length; i++) {
        final originalName = potentialCandidates[i];
        final resolvedItem = resolvedItems[i];

        if (resolvedItem != null) {
           final canonicalName = resolvedItem.canonicalName;

           // Check canonical name in inventory
           final hasCanonicalInInventory = inventory.doesItemExist(canonicalName);
           if (hasCanonicalInInventory) continue;

           // Check canonical name in shopping list
            final hasCanonicalInShopping = shopping.items.any((item) => 
              item.canonicalName?.toLowerCase() == canonicalName.toLowerCase()
            );
            if (hasCanonicalInShopping) continue;
            
            // Add resolved item directly
            await shopping.addItem(resolvedItem);
            finalItemsToAdd.add(originalName);
        } else {
          // Resolution failed, treat as raw unique item
          finalItemsToAdd.add(originalName);
          await shopping.addItemByName(originalName, languageCode);
        }
      }
    } else {
      // Not Pro: Add items using standard logic (which handles resolution if implemented there, or raw add)
      finalItemsToAdd.addAll(potentialCandidates);
      await shopping.addItemsFromRecipe(potentialCandidates, languageCode);
    }

    return finalItemsToAdd.length;
  }

  @visibleForTesting
  void setMealsForTesting(List<MealPlan> meals) {
    _meals = meals;
  }
}
