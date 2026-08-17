import 'package:flutter/material.dart';
// TODO(cook-with-ai): Décommenter ces imports quand "Cuisiner avec IA" sera réactivé.
// import 'package:provider/provider.dart';
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:frigo_zen/l10n/generated/app_localizations.dart';
// import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
// import 'package:frigo_zen/screens/recipes/recipe_suggestion_screen.dart';
// import 'package:frigo_zen/screens/recipes/components/recipe_filters_dialog.dart';
// import 'package:frigo_zen/screens/core/premium_guard.dart';

// TODO(cook-with-ai): Ce service orchestre la génération de recettes IA.
// Pour réactiver la fonctionnalité "Cuisiner avec IA" dans une future version,
// décommenter le corps de la méthode triggerRecipeGeneration ci-dessous.
// La Cloud Function `generateRecipes` est toujours déployée et prête côté backend.
class RecipeGenerationService {
  static Future<void> triggerRecipeGeneration(BuildContext context) async {
    // TODO(cook-with-ai): Décommenter le code ci-dessous pour activer la génération IA.

    // final hasAccess = await PremiumGuard.checkPremiumStatus(context);
    // if (!hasAccess) return;

    // if (!context.mounted) return;
    // final preferences = await showDialog<Map<String, String>>(
    //   context: context,
    //   builder: (ctx) => const RecipeFiltersDialog(),
    // );

    // if (preferences == null) return; // User cancelled
    // if (!context.mounted) return;

    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (ctx) => Dialog(
    //     child: Padding(
    //       padding: const EdgeInsets.all(20.0),
    //       child: Row(
    //         children: [
    //           const CircularProgressIndicator(),
    //           const SizedBox(width: 20),
    //           Text(AppLocalizations.of(context)!.recipeFinding),
    //         ],
    //       ),
    //     ),
    //   ),
    // );

    // try {
    //   if (!context.mounted) return;
    //   final vm = context.read<InventoryViewModel>();
    //   final inventoryItems = vm.items;

    //   if (inventoryItems.isEmpty) {
    //     Navigator.of(context).pop();
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text(AppLocalizations.of(context)!.inventoryEmpty)),
    //     );
    //     return;
    //   }

    //   final inventoryData = inventoryItems.map((item) => item.toJson()).toList();
    //   final sortedItems = List.from(inventoryItems)
    //     ..sort((a, b) => a.earliestExpirationDate.compareTo(b.earliestExpirationDate));
    //   final item1 = sortedItems[0].canonicalName;
    //   final item2 = sortedItems.length > 1 ? sortedItems[1].canonicalName : item1;
    //   final keys = [item1, item2]..sort();
    //   final String cacheKey = keys.join('_');
    //   final String userLanguage = Localizations.localeOf(context).languageCode;
    //   final functions = FirebaseFunctions.instanceFor(region: "us-central1");
    //   final callable = functions.httpsCallable('generateRecipes');
    //   final result = await callable.call({
    //     'inventory': inventoryData,
    //     'searchKey': cacheKey,
    //     'language': userLanguage,
    //     'preferences': preferences,
    //   });

    //   if (!context.mounted) return;
    //   Navigator.of(context).pop();
    //   final data = result.data as Map<String, dynamic>;
    //   if (data['success'] == true) {
    //     final recipes = List<dynamic>.from(data['data']['recipes'] ?? []);
    //     recipes.shuffle();
    //     if (recipes.isEmpty) {
    //       if (context.mounted) {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(content: Text(AppLocalizations.of(context)!.recipesNotFound)),
    //         );
    //       }
    //     } else {
    //       if (context.mounted) {
    //         Navigator.of(context).push(
    //           MaterialPageRoute(
    //             builder: (ctx) => RecipeSuggestionScreen(recipes: recipes),
    //           ),
    //         );
    //       }
    //     }
    //   } else {
    //     throw Exception("Function failed (success: false)");
    //   }
    // } catch (error) {
    //   if (context.mounted) {
    //     Navigator.of(context).pop();
    //   }
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(AppLocalizations.of(context)!.errorGeneric(error.toString())),
    //       backgroundColor: Colors.red[700],
    //     ),
    //   );
    // }
  }
}
