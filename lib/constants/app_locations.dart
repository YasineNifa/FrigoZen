import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class AppLocations {
  static const List<String> values = [
    "loc_fridge",
    "loc_freezer",
    "loc_pantry",
  ];

  static String getLocalizedName(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case "loc_fridge": return l10n.loc_fridge;
      case "loc_freezer": return l10n.loc_freezer;
      case "loc_pantry": return l10n.loc_pantry;
      default: return key; // Fallback
    }
  }

  static String normalize(String? location) {
    if (location == null || location.trim().isEmpty) return "loc_fridge"; // Default
    
    final normalizedInput = location.trim().toLowerCase();
    
    if (values.contains(normalizedInput)) return normalizedInput;

    // Heuristics
    if (normalizedInput.contains("frigo") || normalizedInput.contains("fridge") || normalizedInput.contains("refrigerator")) return "loc_fridge";
    if (normalizedInput.contains("congélateur") || normalizedInput.contains("congelateur") || normalizedInput.contains("freezer") || normalizedInput.contains("frozen")) return "loc_freezer";
    if (normalizedInput.contains("placard") || normalizedInput.contains("pantry") || normalizedInput.contains("cupboard") || normalizedInput.contains("dry")) return "loc_pantry";

    return "loc_fridge"; // Default fallback
  }
}
