import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:frigo_zen/screens/paywall/modern_paywall_screen.dart';
import 'package:frigo_zen/screens/recipes/recipe_suggestion_screen.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/screens/inventory/components/inventory_header.dart';
import 'package:frigo_zen/screens/inventory/components/inventory_list.dart';
import 'package:frigo_zen/screens/inventory/components/location_filter_pills.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/repositories/household_repository.dart';

import 'package:frigo_zen/screens/inventory/components/scan_options_sheet.dart';
import 'package:frigo_zen/screens/recipes/components/recipe_filters_dialog.dart';
import 'package:frigo_zen/screens/inventory/components/inventory_summary_card.dart';
import 'package:frigo_zen/screens/core/premium_guard.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _localRecipeCache = [];

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

  // TODO: Move this logic to ViewModel or Service
  Future<void> _triggerRecipeGeneration(BuildContext context) async {
    final hasAccess = await PremiumGuard.checkPremiumStatus(context);
    if (!hasAccess) return;
    // Show filters dialog
    if (!context.mounted) return;
    final preferences = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => const RecipeFiltersDialog(),
    );

    if (preferences == null) return; // User cancelled
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(AppLocalizations.of(context)!.recipeFinding),
            ],
          ),
        ),
      ),
    );

    try {
      if (!context.mounted) return;
      final vm = context.read<InventoryViewModel>();
      final inventoryItems = vm.items;
      
      if (inventoryItems.isEmpty) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(AppLocalizations.of(context)!.inventoryEmpty)),
        );
        return;
      }

      // Convert items to map for cloud function
      final inventoryData = inventoryItems.map((item) => item.toJson()).toList();

      // Simple cache key generation
      final sortedItems = List.from(inventoryItems)..sort((a, b) => a.earliestExpirationDate.compareTo(b.earliestExpirationDate));
      final item1 = sortedItems[0].canonicalName;
      final item2 = sortedItems.length > 1 ? sortedItems[1].canonicalName : item1;
      final keys = [item1, item2]..sort();
      final String cacheKey = keys.join('_');

      final String userLanguage = Localizations.localeOf(context).languageCode;
      final functions = FirebaseFunctions.instanceFor(region: "us-central1");
      final callable = functions.httpsCallable('generateRecipes');
      final result = await callable.call({
        'inventory': inventoryData,
        'searchKey': cacheKey,
        'language': userLanguage,
        'preferences': preferences,
      });

      if (!context.mounted) return;
      Navigator.of(context).pop();

      final data = result.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _localRecipeCache = List<dynamic>.from(data['data']['recipes'] ?? []);
        _localRecipeCache.shuffle();
        if (_localRecipeCache.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.recipesNotFound)));
          }
        } else {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => RecipeSuggestionScreen(
                  recipes: _localRecipeCache,
                ),
              ),
            );
          }
        }
      } else {
        throw Exception("Function failed (success: false)");
      }
    } catch (error) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorGeneric(error.toString())),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: InventoryHeader(
        onRecipePressed: () {}, // No-op, button removed from header
      ),
      body: Column(
        children: [
          InventorySummaryCard(
            onRecipePressed: () => _triggerRecipeGeneration(context),
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
          const Expanded(
            child: InventoryList(),
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
}

