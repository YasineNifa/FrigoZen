import 'package:flutter/material.dart';
import 'package:frigo_zen/services/recipe_service.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:frigo_zen/screens/core/navigation_controller.dart';

import 'package:frigo_zen/models/recipe.dart';
import 'package:frigo_zen/locator.dart';
import 'package:frigo_zen/repositories/recipe_repository.dart';
import 'package:frigo_zen/viewmodels/meal_planner_view_model.dart';
import 'package:frigo_zen/models/meal_plan.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? recipeData;
  final Recipe? recipe;

  const RecipeDetailScreen({
    super.key,
    this.recipeData,
    this.recipe,
  }) : assert(recipeData != null || recipe != null, 'Either recipeData or recipe must be provided');

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _favoritesService = RecipeService(); // Renamed for clarity
  final _apiRepository = locator<RecipeRepository>();
  
  Recipe? _fullRecipe;
  bool _isLoadingDetails = false;
  bool _isFavorite = false;
  String? _favoriteDocId;

  @override
  void initState() {
    super.initState();
    _fullRecipe = widget.recipe;
    _checkIfFavorite();
    _fetchFullDetailsIfNeeded();
  }

  Future<void> _fetchFullDetailsIfNeeded() async {
    // If we have a recipe object but it lacks instructions (likely from category filter), fetch full details
    if (_fullRecipe != null && _fullRecipe!.instructions.isEmpty && _fullRecipe!.id.isNotEmpty) {
      setState(() {
        _isLoadingDetails = true;
      });

      try {
        final fullDetails = await _apiRepository.getRecipeById(_fullRecipe!.id);
        if (fullDetails != null && mounted) {
          setState(() {
            _fullRecipe = fullDetails;
          });
        }
      } catch (e) {
        // print("Error fetching full details: $e");
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingDetails = false;
          });
        }
      }
    }
  }

  void _checkIfFavorite() async {
    final title = _fullRecipe?.title ?? widget.recipeData?['title'];
    if (title != null) {
      final docId = await _favoritesService.getFavoriteDocId(title);
      if (mounted) {
        setState(() {
          _isFavorite = docId != null;
          _favoriteDocId = docId;
        });
      }
    }
  }

  void _toggleFavorite() async {
    final l10n = AppLocalizations.of(context)!;
    final Map<String, dynamic> recipeMap = _fullRecipe?.toMap() ?? widget.recipeData!;

    // Optimistic UI update (update icon immediately)
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      if (_isFavorite) {
        // SAVE
        await _favoritesService.saveRecipe(recipeMap);
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
          await _favoritesService.removeRecipe(_favoriteDocId!);
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
    final vm = context.read<ShoppingViewModel>();
    final isPro = context.read<RevenueProvider>().isPro;
    
    // Extract names
    final names = missingItems.map((item) {
      if (item is String) {
        return item;
      } else if (item is Map) {
        return item['name'] as String;
      }
      return '';
    }).where((name) => name.isNotEmpty).toList();

    if (names.isEmpty) return;

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      await vm.addItemsFromRecipe(names, languageCode, checkInventory: isPro);
      
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();
        
                        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.recipeIngredientsAddedTitle),
            content: Text(AppLocalizations.of(context)!.recipeIngredientsAddedMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.recipeDialogStay),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  // Navigate to Shopping List (index 2)
                  context.read<NavigationController>().setIndex(2);
                  // Pop back to the main shell (remove recipe detail from stack)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(AppLocalizations.of(context)!.recipeDialogViewList),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog if open
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.recipeAddError(e.toString()))),
        );
      }
    }
  }

  void _addToMealPlanner() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _fullRecipe?.title ?? widget.recipeData?['title'] ?? l10n.recipeDetailUntitled;
    
    // Get ingredients
    List<String> ingredients = [];
    if (_fullRecipe != null) {
      ingredients = _fullRecipe!.ingredients.map((e) => e['name']!).toList();
    }
    // TODO(cook-with-ai): Restaurer le fallback recipeData (usedItems/missingItems) quand
    // "Cuisiner avec IA" sera réactivé.
    // } else {
    //   final usedItems = widget.recipeData?['usedItems'] ?? [];
    //   final missingItems = widget.recipeData?['missingItems'] ?? [];
    //   for (var item in usedItems) {
    //     if (item is Map) ingredients.add(item['name']);
    //   }
    //   for (var item in missingItems) {
    //     if (item is Map) ingredients.add(item['name']);
    //   }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null || !mounted) return;

    // Ask for Meal Type (Lunch/Dinner)
    final MealType? pickedType = await showDialog<MealType>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.recipeMealTypeTitle),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, MealType.breakfast),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(l10n.recipeMealTypeBreakfast, style: const TextStyle(fontSize: 16)),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, MealType.lunch),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(l10n.recipeMealTypeLunch, style: const TextStyle(fontSize: 16)),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, MealType.snack),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(l10n.recipeMealTypeSnack, style: const TextStyle(fontSize: 16)),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, MealType.dinner),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(l10n.recipeMealTypeDinner, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );

    if (pickedType == null || !mounted) return;

    try {
      await context.read<MealPlannerViewModel>().addMeal(
        pickedDate,
        pickedType,
        title,
        ingredients: ingredients,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.recipeAddedToPlanning),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: l10n.recipeViewPlanning,
              textColor: Colors.white,
              onPressed: () {
                if (!mounted) return;
                context.read<NavigationController>().setIndex(3); // Planning tab
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.recipeError(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Use _fullRecipe if available, otherwise fallback to widget.recipeData
    final String title = _fullRecipe?.title ?? widget.recipeData?['title'] ?? l10n.recipeDetailUntitled;
    final String description = _fullRecipe?.category ?? widget.recipeData?['description'] ?? ''; 
    final String? imageUrl = _fullRecipe?.imageUrl ?? widget.recipeData?['imageUrl'];
    
    // Smart Recipe Data (kept for backward compatibility with existing favorites)
    // TODO(cook-with-ai): La vue "Smart Recipe" avec usedItems/missingItems sera rétablie
    // quand la fonctionnalité "Cuisiner avec IA" sera réactivée.
    // final List<dynamic> usedItems = widget.recipeData?['usedItems'] ?? [];
    // final List<dynamic> missingItems = widget.recipeData?['missingItems'] ?? [];
    
    // API Recipe Data
    final List<Map<String, String>> apiIngredients = _fullRecipe?.ingredients ?? [];
    
    // Instructions
    List<dynamic> instructions = [];
    if (_fullRecipe != null) {
      instructions = _fullRecipe!.instructions.split(RegExp(r'\r\n|\r|\n')).where((s) => s.trim().isNotEmpty).toList();
    } else {
      final rawInstructions = widget.recipeData?['instructions'];
      if (rawInstructions is String) {
        instructions = rawInstructions.split(RegExp(r'\r\n|\r|\n')).where((s) => s.trim().isNotEmpty).toList();
      } else if (rawInstructions is List) {
        instructions = rawInstructions;
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.black87),
                  onPressed: _addToMealPlanner,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
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
                    if (_isLoadingDetails)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ))
                    else ...[
                      if (description.isNotEmpty)
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- INGREDIENTS SECTION ---
                      if (_fullRecipe != null) ...[
                        // API Recipe View (Single List)
                        Text(
                          l10n.recipeIngredientsTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...apiIngredients.map((ing) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 8, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(child: Text("${ing['measure']} ${ing['name']}", style: const TextStyle(fontSize: 16))),
                            ],
                          ),
                        )),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                               // Add all ingredients to shopping list
                               final names = apiIngredients.map((e) => e['name']!).toList();
                               _addMissingItemsToShoppingList(names);
                            },
                            icon: const Icon(Icons.add_shopping_cart),
                            label: Text(l10n.recipeAddIngredientsBtn),
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
                      ] else ...[
                        // TODO(cook-with-ai): La vue "Smart Recipe" avec ingrédients possessed/missing
                        // sera rétablie quand "Cuisiner avec IA" sera réactivée.
                        // Pour l'instant, afficher les ingrédients depuis recipeData si disponible.
                        // if (usedItems.isNotEmpty || missingItems.isNotEmpty) ...[
                        //   _buildIngredientsSection(
                        //     context,
                        //     l10n.recipeDetailFridge,
                        //     usedItems,
                        //     true,
                        //   ),
                        //   if (missingItems.isNotEmpty) ...[
                        //     const SizedBox(height: 24),
                        //     _buildIngredientsSection(
                        //       context,
                        //       l10n.recipeDetailToBuy,
                        //       missingItems,
                        //       false,
                        //     ),
                        //     const SizedBox(height: 16),
                        //     SizedBox(
                        //       width: double.infinity,
                        //       child: OutlinedButton.icon(
                        //         onPressed: () => _addMissingItemsToShoppingList(missingItems),
                        //         icon: const Icon(Icons.add_shopping_cart),
                        //         label: Text(l10n.recipeAddIngredientsBtn),
                        //         style: OutlinedButton.styleFrom(
                        //           foregroundColor: Theme.of(context).primaryColor,
                        //           side: BorderSide(color: Theme.of(context).primaryColor),
                        //           padding: const EdgeInsets.symmetric(vertical: 12),
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(12),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ],
                        if (widget.recipeData != null) ...[
                          Text(
                            l10n.recipeIngredientsTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...apiIngredients.map((ing) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.circle, size: 8, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(child: Text("${ing['measure']} ${ing['name']}", style: const TextStyle(fontSize: 16))),
                              ],
                            ),
                          )),
                          const SizedBox(height: 16),
                        ],
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



    Color bgColor = isOwned
        ? const Color(0xFF6B9C5F).withValues(alpha: 0.1)
        : Colors.orange[50]!;
    Color textColor = isOwned ? const Color(0xFF6B9C5F) : Colors.orange[800]!;
    Color borderColor = isOwned
        ? const Color(0xFF6B9C5F).withValues(alpha: 0.3)
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
