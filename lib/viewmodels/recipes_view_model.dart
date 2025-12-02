import 'package:flutter/foundation.dart';
import 'package:frigo_zen/models/recipe.dart';
import 'package:frigo_zen/repositories/recipe_repository.dart';

class RecipesViewModel extends ChangeNotifier {
  final RecipeRepository _repository;

  List<Recipe> _recipes = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'Beef'; // Default category

  List<Recipe> get recipes => _recipes;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  RecipesViewModel({required RecipeRepository repository}) : _repository = repository;

  Future<void> init() async {
    await fetchCategories();
    await fetchRecipesByCategory(_selectedCategory);
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } catch (e) {
      // print("Error fetching categories: $e");
      // Fallback categories if API fails
      _categories = ['Beef', 'Chicken', 'Dessert', 'Lamb', 'Pasta', 'Pork', 'Seafood', 'Side', 'Starter', 'Vegan', 'Vegetarian', 'Breakfast', 'Goat'];
      notifyListeners();
    }
  }

  Future<void> fetchRecipesByCategory(String category) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedCategory = category;
    notifyListeners();

    try {
      _recipes = await _repository.getRecipesByCategory(category);
    } catch (e) {
      _errorMessage = "Failed to load recipes: $e";
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchRecipes(String query) async {
    if (query.trim().isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    _selectedCategory = ''; // Clear category selection on search
    notifyListeners();

    try {
      _recipes = await _repository.searchRecipes(query);
      if (_recipes.isEmpty) {
        _errorMessage = "No recipes found for '$query'";
      }
    } catch (e) {
      _errorMessage = "Failed to search recipes: $e";
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
