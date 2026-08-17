import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/screens/inventory/components/inventory_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/repositories/household_repository.dart';
import 'package:frigo_zen/screens/inventory/components/inventory_list.dart';
import 'package:frigo_zen/screens/inventory/components/location_filter_pills.dart';

import 'package:frigo_zen/screens/inventory/components/scan_options_sheet.dart';
// TODO(cook-with-ai): Décommenter pour réactiver la génération de recettes IA
// import 'package:frigo_zen/services/recipe_generation_service.dart';
// import 'package:frigo_zen/screens/recipes/components/recipe_filters_dialog.dart';
import 'package:frigo_zen/screens/core/premium_guard.dart';
import 'package:frigo_zen/screens/planning/meal_planner_screen.dart';

import 'package:frigo_zen/screens/inventory/inventory_view_mode.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  InventoryViewMode _viewMode = InventoryViewMode.priority;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearch);
    
    // Initialize ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initViewModel();
    });
  }
  
  Future<void> _initViewModel() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final householdId = await HouseholdRepository().getHouseholdIdForUser(userId);
      if (householdId != null && mounted) {
        context.read<InventoryViewModel>().init(householdId);
        context.read<ShoppingViewModel>().init(householdId);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }



  void _handleSearch() {
    context.read<InventoryViewModel>().setSearchQuery(_searchController.text.trim());
  }

  // TODO(cook-with-ai): Décommenter pour réactiver la génération de recettes IA
  // void _triggerRecipeGeneration(BuildContext context) {
  //   RecipeGenerationService.triggerRecipeGeneration(context);
  // }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: InventoryHeader(
        onRecipePressed: () {}, // No-op, button removed from header
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                // TODO(cook-with-ai): Décommenter pour réactiver le bouton "Cuisiner avec mon frigo"
                // Expanded(
                //   child: _buildHeaderButton(
                //     context,
                //     icon: Icons.restaurant_menu,
                //     label: l10n.cookWithFridgeBtn,
                //     color: Theme.of(context).primaryColor,
                //     onTap: () => RecipeGenerationService.triggerRecipeGeneration(context),
                //   ),
                // ),
                // const SizedBox(width: 12),
                Expanded(
                  child: _buildHeaderButton(
                    context,
                    icon: Icons.calendar_month,
                    label: l10n.mealPlannerCardTitle,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MealPlannerScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const LocationFilterPills(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.inventorySearchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[200]
                    : Colors.grey[800],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          
          // View Mode Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<InventoryViewMode>(
                segments: [
                  ButtonSegment<InventoryViewMode>(
                    value: InventoryViewMode.priority,
                    label: Text(l10n.sortPriority),
                    icon: Icon(Icons.traffic),
                  ),
                  ButtonSegment<InventoryViewMode>(
                    value: InventoryViewMode.category,
                    label: Text(l10n.sortCategory),
                    icon: Icon(Icons.category),
                  ),
                  ButtonSegment<InventoryViewMode>(
                    value: InventoryViewMode.list,
                    label: Text(l10n.sortList),
                    icon: Icon(Icons.list),
                  ),
                ],
                selected: <InventoryViewMode>{_viewMode},
                onSelectionChanged: (Set<InventoryViewMode> newSelection) {
                  setState(() {
                    _viewMode = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: WidgetStateProperty.all(BorderSide(color: Colors.grey.withOpacity(0.2))),
                ),
              ),
            ),
          ),

          Expanded(
            child: InventoryList(viewMode: _viewMode),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
      context: context,
      builder: (ctx) => ScanOptionsSheet(parentContext: context),
    );      },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  Widget _buildHeaderButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        // Removed fixed height to avoid overflow
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

