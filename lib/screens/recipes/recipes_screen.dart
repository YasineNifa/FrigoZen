import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/viewmodels/recipes_view_model.dart';
import 'package:frigo_zen/screens/recipes/favorites_screen.dart';
import 'package:frigo_zen/screens/recipes/recipe_detail_screen.dart';
import 'package:frigo_zen/screens/core/premium_guard.dart';
import 'package:frigo_zen/services/recipe_generation_service.dart';

import 'package:frigo_zen/models/recipe.dart';
import 'package:frigo_zen/components/skeleton.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _localRecipeCache = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipesViewModel>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    context.read<RecipesViewModel>().searchRecipes(query);
  }

  void _triggerRecipeGeneration(BuildContext context) {
    RecipeGenerationService.triggerRecipeGeneration(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.recipeTitle),
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: l10n.recipeTabCatalog),
              Tab(text: l10n.recipeTabAI),
              Tab(text: l10n.recipeTabFavorites),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDiscoverTab(context),
            _buildAITab(context),
            const FavoritesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAITab(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 24),
            Text(
              l10n.recipeAITitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.recipeAIDesc,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _triggerRecipeGeneration(context),
              icon: const Icon(Icons.restaurant_menu),
              label: Text(l10n.recipeAIBtn),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverTab(BuildContext context) {
    final viewModel = context.watch<RecipesViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.recipeSearchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  viewModel.fetchRecipesByCategory(viewModel.selectedCategory);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onSubmitted: _handleSearch,
          ),
        ),

        // Categories
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: viewModel.categories.length,
            itemBuilder: (context, index) {
              final category = viewModel.categories[index];
              final isSelected = category == viewModel.selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _searchController.clear();
                      viewModel.fetchRecipesByCategory(category);
                    }
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Content
        Expanded(
          child: viewModel.isLoading
              ? GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Skeleton(width: double.infinity, borderRadius: 16),
                      ),
                      const SizedBox(height: 12),
                      const Skeleton(width: 100, height: 14),
                      const SizedBox(height: 8),
                      const Skeleton(width: 60, height: 12),
                    ],
                  ),
                )
              : viewModel.errorMessage != null
                  ? Center(child: Text(viewModel.errorMessage!))
                  : _buildRecipeGrid(context, viewModel.recipes),
        ),
      ],
    );
  }

  Widget _buildRecipeGrid(BuildContext context, List<Recipe> recipes) {
    if (recipes.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.recipeNoResults));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _buildRecipeCard(context, recipe);
      },
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: recipe.imageUrl != null
                  ? Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.restaurant, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.restaurant, color: Colors.grey),
                    ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.category, // Or Area
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
