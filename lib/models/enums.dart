import 'package:frigo_zen/constants/app_categories.dart';

enum InventoryCategory {
  fruitsVegetables('cat_fruits_vegetables'),
  bakery('cat_bakery'),
  dairyEggs('cat_dairy_eggs'),
  meatFish('cat_meat_fish'),
  frozen('cat_frozen'),
  pantrySalty('cat_pantry_salty'),
  pantrySweet('cat_pantry_sweet'),
  beverages('cat_beverages'),
  baby('cat_baby'),
  pets('cat_pets'),
  other('cat_other');

  final String key;
  const InventoryCategory(this.key);

  static InventoryCategory fromString(String? value) {
    if (value == null) return InventoryCategory.other;
    // Special handling for old "Other" or unknown values
    return InventoryCategory.values.firstWhere(
      (e) => e.key == value || e.name == value,
      orElse: () {
        // Try fallback logic via AppCategories normalizer if needed, 
        // but for now default to other to be safe.
        // We can use the old normalizer to map raw strings to keys
        final normalized = AppCategories.normalize(value);
         return InventoryCategory.values.firstWhere(
          (e) => e.key == normalized,
          orElse: () => InventoryCategory.other
        );
      },
    );
  }

  StorageLocation get defaultLocation {
    switch (this) {
      case InventoryCategory.fruitsVegetables:
      case InventoryCategory.dairyEggs:
      case InventoryCategory.meatFish:
        return StorageLocation.fridge;
      case InventoryCategory.frozen:
        return StorageLocation.freezer;
      case InventoryCategory.bakery:
      case InventoryCategory.pantrySalty:
      case InventoryCategory.pantrySweet:
      case InventoryCategory.beverages:
        return StorageLocation.pantry;
      case InventoryCategory.baby:
      case InventoryCategory.pets:
      case InventoryCategory.other:
      default:
        return StorageLocation.other;
    }
  }

  String toJson() => key;

  int compareTo(InventoryCategory other) => index.compareTo(other.index);
}

enum StorageLocation {
  fridge(0, 'fridge'),
  pantry(1, 'pantry'),
  freezer(2, 'freezer'),
  other(3, 'other');

  final int id;
  final String localizationKey;
  const StorageLocation(this.id, this.localizationKey);

  static StorageLocation fromId(dynamic value) {
    if (value is num) {
      final intVal = value.toInt();
       return StorageLocation.values.firstWhere(
        (e) => e.id == intVal,
        orElse: () => StorageLocation.other,
      );
    } else if (value is String) {
      final normalized = value.toLowerCase().trim();
      
      // Try parsing numeric string (int)
      final int? parsedInt = int.tryParse(normalized);
      if (parsedInt != null) {
         return StorageLocation.values.firstWhere(
          (e) => e.id == parsedInt,
          orElse: () => StorageLocation.other,
        );
      }
      
      // Try parsing numeric string (double) e.g. "0.0"
      final double? parsedDouble = double.tryParse(normalized);
      if (parsedDouble != null) {
         return StorageLocation.values.firstWhere(
          (e) => e.id == parsedDouble.toInt(),
          orElse: () => StorageLocation.other,
        );
      }

      // Match legacy keys from AppLocations
      if (normalized == 'loc_fridge' || normalized.contains('frigo')) return StorageLocation.fridge;
      if (normalized == 'loc_pantry' || normalized.contains('placard')) return StorageLocation.pantry;
      if (normalized == 'loc_freezer' || normalized.contains('congel') || normalized.contains('congél')) return StorageLocation.freezer;

      return StorageLocation.values.firstWhere(
        (e) => e.localizationKey == normalized || e.name == normalized,
        orElse: () => StorageLocation.other,
      );
    }
    return StorageLocation.other;
  }
  
  // Deprecated support for fromString to ease migration if needed, but strict refactor prefers fromId
  static StorageLocation fromString(String? value) => fromId(value);

  int toJson() => id;
}
