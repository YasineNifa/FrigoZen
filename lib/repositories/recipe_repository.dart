import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frigo_zen/models/recipe.dart';

class RecipeRepository {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Search recipes by name
  Future<List<Recipe>> searchRecipes(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/search.php?s=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'] as List<dynamic>?;

      if (meals == null) return [];

      return meals.map((json) => Recipe.fromMealDB(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // Get recipe by ID
  Future<Recipe?> getRecipeById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/lookup.php?i=$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'] as List<dynamic>?;

      if (meals == null || meals.isEmpty) return null;

      return Recipe.fromMealDB(meals.first);
    } else {
      throw Exception('Failed to load recipe');
    }
  }

  // Get recipes by category
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    final response = await http.get(Uri.parse('$_baseUrl/filter.php?c=$category'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'] as List<dynamic>?;

      if (meals == null) return [];

      // Note: filter endpoint only returns id, title, and image.
      // We inject the category since we know it from the request.
      return meals.map((json) {
        final Map<String, dynamic> recipeData = Map.from(json);
        recipeData['strCategory'] = category;
        return Recipe.fromMealDB(recipeData);
      }).toList();
    } else {
      throw Exception('Failed to load recipes by category');
    }
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/list.php?c=list'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final categories = data['meals'] as List<dynamic>?;

      if (categories == null) return [];

      return categories.map((json) => json['strCategory'] as String).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}
