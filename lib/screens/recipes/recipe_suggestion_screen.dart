// lib/screens/recipes/recipe_suggestion_screen.dart

import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/recipes/recipe_detail_screen.dart'; // Importez le nouvel écran de détail

class RecipeSuggestionScreen extends StatelessWidget {
  final List<dynamic> recipes; // Reçoit TOUTES les recettes

  const RecipeSuggestionScreen({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Fond uniforme
      appBar: AppBar(
        title: const Text(
          'Idées Recettes',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: recipes.isEmpty
          ? Center(
              child: Text(
                "Aucune recette trouvée pour cette combinaison. :(",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 cartes par ligne
                crossAxisSpacing: 16.0, // Espacement horizontal
                mainAxisSpacing: 16.0, // Espacement vertical
                childAspectRatio:
                    0.75, // Ratio pour des cartes un peu plus hautes
              ),
              itemCount: recipes.length, // Affiche TOUTES les recettes
              itemBuilder: (context, index) {
                return RecipeGridTile(recipeData: recipes[index]);
              },
            ),
    );
  }
}

// --- NOUVEAU WIDGET : La petite carte pour la Grid ---
class RecipeGridTile extends StatelessWidget {
  final dynamic recipeData;

  const RecipeGridTile({super.key, required this.recipeData});

  @override
  Widget build(BuildContext context) {
    final recipe = Map<String, dynamic>.from(recipeData);
    final String title = recipe['title'] ?? 'Recette sans titre';
    final String? imageUrl = recipe['imageUrl'];
    final List<dynamic> usedItems = recipe['usedItems'] ?? [];
    final List<dynamic> missingItems = recipe['missingItems'] ?? [];

    final int totalIngredients = usedItems.length + missingItems.length;
    final int ownedIngredients = usedItems.length;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => RecipeDetailScreen(recipeData: recipeData),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  _buildGridImage(imageUrl),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: ownedIngredients == totalIngredients
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$ownedIngredients/$totalIngredients",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Icon(Icons.food_bank, size: 40, color: Colors.grey[400]),
        ),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (c, e, s) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
        ),
      ),
    );
  }
}
