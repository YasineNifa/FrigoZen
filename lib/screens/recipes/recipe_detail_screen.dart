import 'package:flutter/material.dart';
import 'package:frigo_zen/services/recipe_service.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/screens/core/navigation_controller.dart';

class RecipeDetailScreen extends StatefulWidget {
  final dynamic recipeData;

  const RecipeDetailScreen({super.key, required this.recipeData});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _recipeService = RecipeService();
  bool _isFavorite = false;
  String? _favoriteDocId;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  void _checkIfFavorite() async {
    final recipe = Map<String, dynamic>.from(widget.recipeData);
    final title = recipe['title'];
    if (title != null) {
      final docId = await _recipeService.getFavoriteDocId(title);
      if (mounted) {
        setState(() {
          _isFavorite = docId != null;
          _favoriteDocId = docId;
        });
      }
    }
  }

  void _toggleFavorite() async {
    final recipe = Map<String, dynamic>.from(widget.recipeData);
    final l10n = AppLocalizations.of(context)!;

    // Optimistic UI update (update icon immediately)
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      if (_isFavorite) {
        // SAVE
        await _recipeService.saveRecipe(recipe);
        // Re-fetch ID
        _checkIfFavorite();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.recipeDetailSaved)));
        }
      } else {
        // REMOVE
        if (_favoriteDocId != null) {
          await _recipeService.removeRecipe(_favoriteDocId!);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.recipeDetailRemoved)));
          }
        }
      }
    } catch (e) {
      // Revert UI on error
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.recipeDetailError(e.toString()))),
        );
      }
    }

  }



  void _addMissingItemsToShoppingList(List<dynamic> missingItems) async {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.read<ShoppingViewModel>();
    
    // Extract names
    final names = missingItems.map((item) {
      final map = Map<String, dynamic>.from(item);
      return map['name'] as String;
    }).toList();

    if (names.isEmpty) return;

    // Show processing message immediately
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ajout des ingrédients en cours... ⏳"),
          duration: Duration(seconds: 1),
        ),
      );
    }

    try {
      await vm.addItemsFromRecipe(names);
      if (mounted) {
        // Clear previous snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ingrédients ajoutés à la liste !"),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: "VOIR",
              textColor: Colors.white,
              onPressed: () {
                // Navigate to Shopping List (index 2)
                context.read<NavigationController>().setIndex(2);
                // Pop back to the main shell (remove recipe detail from stack)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'ajout : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recipe = Map<String, dynamic>.from(widget.recipeData);
    final String title = recipe['title'] ?? l10n.recipeDetailUntitled;
    final String description = recipe['description'] ?? '';
    final String? imageUrl = recipe['imageUrl'];
    final List<dynamic> usedItems = recipe['usedItems'] ?? [];
    final List<dynamic> missingItems = recipe['missingItems'] ?? [];
    final List<dynamic> instructions = recipe['instructions'] ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.black87,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black54,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: _buildHeroImage(imageUrl),
            ),
          ),
          // Contenu de la recette
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description.isEmpty
                          ? l10n.recipeDetailNoDesc
                          : description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Ingrédients Possédés
                    _buildIngredientsSection(
                      context,
                      l10n.recipeDetailFridge,
                      usedItems,
                      true,
                    ),

                      if (missingItems.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        // Ingrédients Manquants
                        _buildIngredientsSection(
                          context,
                          l10n.recipeDetailToBuy,
                          missingItems,
                          false,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _addMissingItemsToShoppingList(missingItems),
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text("Ajouter à la liste de courses"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                              side: BorderSide(color: Theme.of(context).primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],

                    const SizedBox(height: 32),

                    // Instructions
                    Text(
                      l10n.recipeDetailPreparation,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (int i = 0; i < instructions.length; i++)
                      _buildInstructionStep(i + 1, instructions[i]),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Icon(Icons.restaurant_menu, size: 60, color: Colors.grey[500]),
        ),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
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
          child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildIngredientsSection(
    BuildContext context,
    String title,
    List<dynamic> items,
    bool isOwned,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10, // Espace horizontal entre les chips
          runSpacing: 10, // Espace vertical entre les lignes de chips
          children: items.map((item) => _buildChip(item, isOwned)).toList(),
        ),
      ],
    );
  }

  Widget _buildChip(dynamic itemMap, bool isOwned) {
    final item = Map<String, dynamic>.from(itemMap);
    final name = item['name'] ?? '';
    final quantity = item['quantity'] ?? '';
    final isExpiring = item['isExpiringSoon'] == true;

    final primaryColor =
        Colors.green; // Or Theme.of(context).primaryColor if you pass context

    Color bgColor = isOwned
        ? const Color(0xFF6B9C5F).withOpacity(0.1)
        : Colors.orange[50]!;
    Color textColor = isOwned ? const Color(0xFF6B9C5F) : Colors.orange[800]!;
    Color borderColor = isOwned
        ? const Color(0xFF6B9C5F).withOpacity(0.3)
        : Colors.orange[200]!;

    if (isOwned && isExpiring) {
      bgColor = Colors.red[50]!;
      textColor = Colors.red[800]!;
      borderColor = Colors.red[200]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOwned && isExpiring)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: Colors.red,
              ),
            ),
          Flexible(
            child: Text(
              "$name ($quantity)",
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int index, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$index",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
