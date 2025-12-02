import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/models/meal_plan.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';

class MealPlannerViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  
  MealPlannerViewModel({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;
  List<MealPlan> _meals = [];
  bool _isLoading = false;
  String? _householdId;

  List<MealPlan> get meals => _meals;
  bool get isLoading => _isLoading;

  void init(String householdId) {
    _householdId = householdId;
    _fetchMeals();
  }

  void _fetchMeals() {
    if (_householdId == null) return;

    _isLoading = true;
    notifyListeners();

    _firestore
        .collection('households')
        .doc(_householdId)
        .collection('meal_plans')
        .orderBy('date')
        .snapshots()
        .listen((snapshot) {
      _meals = snapshot.docs.map((doc) => MealPlan.fromSnapshot(doc)).toList();
      _isLoading = false;
      notifyListeners();
    });
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

    await _firestore
        .collection('households')
        .doc(_householdId)
        .collection('meal_plans')
        .add(newMeal.toMap());
  }

  Future<void> deleteMeal(String mealId) async {
    if (_householdId == null) return;

    await _firestore
        .collection('households')
        .doc(_householdId)
        .collection('meal_plans')
        .doc(mealId)
        .delete();
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
        await _firestore
            .collection('households')
            .doc(_householdId)
            .collection('meal_plans')
            .doc(mealId)
            .update({
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

  Future<int> generateShoppingList(InventoryViewModel inventory, ShoppingViewModel shopping, {bool isPro = false}) async {
    if (_meals.isEmpty) return 0;

    final Set<String> itemsToAdd = {};

    for (final meal in _meals) {
      for (final ingredient in meal.ingredients) {
        final rawName = ingredient.trim().toLowerCase();

        // 1. Check raw name in inventory
        final hasRawInInventory = inventory.items.any((item) => 
          item.name.trim().toLowerCase() == rawName
        );
        if (hasRawInInventory) continue;

        // 2. Check raw name in shopping list
        final hasRawInShopping = shopping.items.any((item) => 
          item.name.trim().toLowerCase() == rawName
        );
        if (hasRawInShopping) continue;

        // 3. Resolve canonical name (Costly operation) - ONLY IF PRO
        if (isPro) {
          final resolvedItem = await shopping.resolveItemName(ingredient);
          if (resolvedItem != null) {
            final canonicalName = resolvedItem.canonicalName;

            // 4. Check canonical name in inventory
            final hasCanonicalInInventory = await inventory.doesItemExist(canonicalName);
            if (hasCanonicalInInventory) continue;

            // 5. Check canonical name in shopping list
            final hasCanonicalInShopping = shopping.items.any((item) => 
              item.canonicalName == canonicalName
            );
            if (hasCanonicalInShopping) continue;
          }
        }

        itemsToAdd.add(ingredient);
      }
    }

    if (itemsToAdd.isNotEmpty) {
      await shopping.addItemsFromRecipe(itemsToAdd.toList());
    }

    return itemsToAdd.length;
  }

  @visibleForTesting
  void setMealsForTesting(List<MealPlan> meals) {
    _meals = meals;
  }
}
