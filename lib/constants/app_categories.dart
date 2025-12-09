import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class AppCategories {
  static const List<String> values = [
    "cat_fruits_vegetables",
    "cat_bakery",
    "cat_dairy_eggs",
    "cat_meat_fish",
    "cat_frozen",
    "cat_pantry_salty",
    "cat_pantry_sweet",
    "cat_beverages",
    "cat_baby",
    "cat_pets",
    "cat_other",
  ];

  static String getLocalizedName(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case "cat_fruits_vegetables": return l10n.cat_fruits_vegetables;
      case "cat_bakery": return l10n.cat_bakery;
      case "cat_dairy_eggs": return l10n.cat_dairy_eggs;
      case "cat_meat_fish": return l10n.cat_meat_fish;
      case "cat_frozen": return l10n.cat_frozen;
      case "cat_pantry_salty": return l10n.cat_pantry_salty;
      case "cat_pantry_sweet": return l10n.cat_pantry_sweet;
      case "cat_beverages": return l10n.cat_beverages;
      case "cat_baby": return l10n.cat_baby;
      case "cat_pets": return l10n.cat_pets;
      case "cat_other": return l10n.cat_other;
      default: return key; // Fallback if key not found or already localized
    }
  }

  static String normalize(String? category) {
    if (category == null || category.trim().isEmpty) return "cat_other";
    
    final normalizedInput = category.trim().toLowerCase();
    
    // Check if input matches any key directly
    if (values.contains(normalizedInput)) return normalizedInput;

    // Heuristics for mapping common variations to keys
    if (normalizedInput.contains("fruit") || normalizedInput.contains("legume") || normalizedInput.contains("légume") || normalizedInput.contains("vegetable")) return "cat_fruits_vegetables";
    if (normalizedInput.contains("pain") || normalizedInput.contains("boulangerie") || normalizedInput.contains("bread") || normalizedInput.contains("bakery")) return "cat_bakery";
    if (normalizedInput.contains("lait") || normalizedInput.contains("oeuf") || normalizedInput.contains("fromage") || normalizedInput.contains("yaourt") || normalizedInput.contains("dairy") || normalizedInput.contains("egg") || normalizedInput.contains("cheese") || normalizedInput.contains("yogurt")) return "cat_dairy_eggs";
    if (normalizedInput.contains("viande") || normalizedInput.contains("poisson") || normalizedInput.contains("boucherie") || normalizedInput.contains("meat") || normalizedInput.contains("fish")) return "cat_meat_fish";
    if (normalizedInput.contains("surgelé") || normalizedInput.contains("glace") || normalizedInput.contains("frozen") || normalizedInput.contains("ice")) return "cat_frozen";
    if (normalizedInput.contains("boisson") || normalizedInput.contains("jus") || normalizedInput.contains("eau") || normalizedInput.contains("soda") || normalizedInput.contains("drink") || normalizedInput.contains("water") || normalizedInput.contains("juice")) return "cat_beverages";
    if (normalizedInput.contains("bébé") || normalizedInput.contains("baby")) return "cat_baby";
    if (normalizedInput.contains("animaux") || normalizedInput.contains("pet") || normalizedInput.contains("dog") || normalizedInput.contains("cat") || normalizedInput.contains("chien") || normalizedInput.contains("chat")) return "cat_pets";
    
    // Pantry logic is tricky without more keywords, but let's try basic ones
    if (normalizedInput.contains("sucre") || normalizedInput.contains("chocolat") || normalizedInput.contains("biscuit") || normalizedInput.contains("sweet") || normalizedInput.contains("sugar") || normalizedInput.contains("chocolate") || normalizedInput.contains("cookie")) return "cat_pantry_sweet";
    if (normalizedInput.contains("sel") || normalizedInput.contains("pâte") || normalizedInput.contains("riz") || normalizedInput.contains("conserve") || normalizedInput.contains("salt") || normalizedInput.contains("pasta") || normalizedInput.contains("rice") || normalizedInput.contains("can")) return "cat_pantry_salty";

    return "cat_other";
  }
}
