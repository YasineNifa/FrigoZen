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

    // 4. Resolve Items (Parallelized - Slower but parallel) & 5. Canonical Check
    // We delegate the resolution and final "add" decision to shopping view model via addItemsFromRecipe
    // But wait, addItemsFromRecipe blindly adds most things or does loose checking?
    // Let's look at ShoppingViewModel.addItemsFromRecipe. It resolves names but doesn't explicitly 
    // check against EXISTING canonical names in that method (checking view_file output... it just adds).
    // So we should do the resolution here or improve addItemsFromRecipe.
    // Given the architecture, let's keep logic here to be precise.

    final List<String> finalItemsToAdd = [];

    if (isPro) {
      // Parallel Resolution
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
              item.canonicalName == canonicalName
            );
            if (hasCanonicalInShopping) continue;
            
            // If we are here, it's a new item. We'll add the Original Name to the list
            // and let ShoppingViewModel resolve it again? Or optimize to pass the object?
            // ShoppingViewModel.addItemsFromRecipe resolves again. That's double work.
            // But we can't easily pass ShoppingItem objects to addItemsFromRecipe without changing it.
            // OPTIMIZATION: We already resolved it. We should use `shopping.addItem(item)` directly for each.
            // But we need to batch it or do it carefully.
            // Let's rely on ShoppingViewModel.addItemsFromRecipe for now to avoid logic duplication 
            // OR simply call `shopping.addItem` here since we have the object.
            
            await shopping.addItem(resolvedItem);
            finalItemsToAdd.add(originalName); // Just for counting
        } else {
          // Resolution failed, treat as raw unique item (already checked raw existence)
          finalItemsToAdd.add(originalName);
           await shopping.addItemByName(originalName, languageCode); // Fallback add
        }
      }
    } else {
      // Not Pro: We already filtered by raw name. Just add them.
      // But avoid duplicates within the batch? Set handles that.
      finalItemsToAdd.addAll(potentialCandidates);
      await shopping.addItemsFromRecipe(potentialCandidates, languageCode);
    }
    
    // Note: The above logic for PRO mixes explicit addItem calls and implicit logic. 
    // To be safer and more consistent with previous architecture where `addItemsFromRecipe` handles the add:
    // If IS PRO: We manually verified canonical names. We should probably just call `shopping.addItemsFromRecipe(finalItemsToAdd)`
    // BUT `addItemsFromRecipe` re-resolves. That's wasteful.
    // AND `addItemsFromRecipe` does NOT check canonical existence against inventory/shopping list (based on my read).
    // So if we just pass names to it, we lose the benefit of the canonical check we just did?
    // Wait, `addItemsFromRecipe` implementation:
    //   resolves items -> adds to list.
    // It does NOT check for duplicates in Repo or ViewModel before adding (Repo might, but ViewModel doesn't see it).
    // So YES, we must handle the add ourselves if we want to key off the resolution.
    
    // Correction on implementation above:
    // The previous implementation loop was:
    // for each meal -> ingredients -> check raw -> if Pro resolve -> check canonical -> add to set -> finally `shopping.addItemsFromRecipe`.
    // My previous analysis said `addItemsFromRecipe` does resolution. So we were resolving TWICE! 
    // Once here for the check, and once inside `shopping.addItemsFromRecipe`.
    
    // REVISED PLAN FOR PRO:
    // 1. Resolve all potential items in parallel.
    // 2. Filter resolved items against Inventory/Shopping using Canonical Name.
    // 3. Collect the *ShoppingItem* objects that passed the filter.
    // 4. Call `shopping.addShoppingItems(items)` (need to ensure this exists or use loop loop of `addItem`).
    // `ShoppingViewModel` has `addItem` (singular) and `addItemsFromRecipe` (does resolution).
    // It does NOT have `addItems(List<ShoppingItem>)` public method visible in previous view_file.
    // `ShoppingRepository` has `addShoppingItems`.
    // I should check `ShoppingViewModel` again or just iterate `addItem` (it's essentially just a repo call wrapper).
    // Iterating `addItem` is fine since it's just firing async calls, we can `Future.wait` them.

    return finalItemsToAdd.length;
  }

  @visibleForTesting
  void setMealsForTesting(List<MealPlan> meals) {
    _meals = meals;
  }
}
