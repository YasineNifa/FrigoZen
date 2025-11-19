import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeService {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  // Reference to the 'favoriteRecipes' sub-collection
  late final CollectionReference _favoritesCollection;

  RecipeService() {
    if (_userId == null) {
      throw Exception("User not logged in");
    }
    _favoritesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('favoriteRecipes');
  }

  // --- 1. READ: Get the stream of favorite recipes ---
  Stream<QuerySnapshot> getFavoritesStream() {
    // Order by saved date (newest first)
    return _favoritesCollection
        .orderBy('savedAt', descending: true)
        .snapshots();
  }

  // --- 2. WRITE: Save a recipe to favorites ---
  Future<void> saveRecipe(Map<String, dynamic> recipeData) async {
    // We use the recipe title as a unique ID key to avoid duplicates
    // We clean the title (remove spaces, lowercase) to make a safe ID
    // Or we can just let Firestore generate an ID.
    // Let's use a generated ID but check for duplicates first.

    final title = recipeData['title'] ?? 'Untitled';

    // Check if already exists
    final existing = await _favoritesCollection
        .where('title', isEqualTo: title)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      // Already saved, do nothing or update
      return;
    }

    await _favoritesCollection.add({
      ...recipeData, // Save all recipe data (ingredients, instructions, image...)
      'savedAt': Timestamp.now(), // Add timestamp
    });
  }

  // --- 3. DELETE: Remove a recipe from favorites ---
  Future<void> removeRecipe(String docId) async {
    await _favoritesCollection.doc(docId).delete();
  }

  // --- 4. CHECK: Is this recipe already a favorite? ---
  // Used to toggle the heart icon state
  Future<bool> isRecipeFavorite(String title) async {
    final query = await _favoritesCollection
        .where('title', isEqualTo: title)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // Helper to find the docID by title (for toggling)
  Future<String?> getFavoriteDocId(String title) async {
    final query = await _favoritesCollection
        .where('title', isEqualTo: title)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }
    return null;
  }
}
