class Recipe {
  final String id;
  final String title;
  final String category;
  final String area;
  final String instructions;
  final String? imageUrl;
  final List<String> tags;
  final String? youtubeUrl;
  final List<Map<String, String>> ingredients; // List of {name: "Ingredient", measure: "Measure"}
  final String? sourceUrl;

  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.area,
    required this.instructions,
    this.imageUrl,
    this.tags = const [],
    this.youtubeUrl,
    this.ingredients = const [],
    this.sourceUrl,
  });

  factory Recipe.fromMealDB(Map<String, dynamic> json) {
    // Extract ingredients and measures
    final List<Map<String, String>> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add({
          'name': ingredient.toString().trim(),
          'measure': measure?.toString().trim() ?? '',
        });
      }
    }

    // Parse tags
    List<String> tags = [];
    if (json['strTags'] != null) {
      tags = json['strTags'].toString().split(',').map((e) => e.trim()).toList();
    }

    return Recipe(
      id: json['idMeal'] ?? '',
      title: json['strMeal'] ?? 'Untitled',
      category: json['strCategory'] ?? 'Unknown',
      area: json['strArea'] ?? 'Unknown',
      instructions: json['strInstructions'] ?? '',
      imageUrl: json['strMealThumb'],
      tags: tags,
      youtubeUrl: json['strYoutube'],
      ingredients: ingredients,
      sourceUrl: json['strSource'],
    );
  }

  // Helper to convert to Map for Firestore (Favorites)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'area': area,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'tags': tags,
      'youtubeUrl': youtubeUrl,
      'ingredients': ingredients,
      'sourceUrl': sourceUrl,
    };
  }

  factory Recipe.fromFirestore(Map<String, dynamic> data, String docId) {
    return Recipe(
      id: docId, // Use Firestore doc ID if available, or data['id']
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      area: data['area'] ?? '',
      instructions: data['instructions'] ?? '',
      imageUrl: data['imageUrl'],
      tags: List<String>.from(data['tags'] ?? []),
      youtubeUrl: data['youtubeUrl'],
      ingredients: (data['ingredients'] as List<dynamic>?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList() ?? [],
      sourceUrl: data['sourceUrl'],
    );
  }
}
