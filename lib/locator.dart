import 'package:get_it/get_it.dart';
import 'package:frigo_zen/repositories/inventory_repository.dart';
import 'package:frigo_zen/repositories/shopping_repository.dart';
import 'package:frigo_zen/repositories/household_repository.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:frigo_zen/services/auth_service.dart';
import 'package:frigo_zen/services/history_service.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/repositories/recipe_repository.dart';
import 'package:frigo_zen/viewmodels/recipes_view_model.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Repositories
  locator.registerLazySingleton<InventoryRepository>(() => InventoryRepository());
  locator.registerLazySingleton<ShoppingRepository>(() => ShoppingRepository());
  locator.registerLazySingleton<HouseholdRepository>(() => HouseholdRepository());
  locator.registerLazySingleton<RecipeRepository>(() => RecipeRepository());

  // Services
  locator.registerLazySingleton<RevenueProvider>(() => RevenueProvider());
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<HistoryService>(() => HistoryService());

  // ViewModels
  locator.registerFactory<InventoryViewModel>(
    () => InventoryViewModel(
      inventoryRepository: locator<InventoryRepository>(),
      historyService: locator<HistoryService>(),
    ),
  );
  locator.registerFactory<ShoppingViewModel>(
    () => ShoppingViewModel(
      shoppingRepository: locator<ShoppingRepository>(),
      inventoryRepository: locator<InventoryRepository>(),
      historyService: locator<HistoryService>(),
    ),
  );
  locator.registerFactory<RecipesViewModel>(
    () => RecipesViewModel(
      repository: locator<RecipeRepository>(),
    ),
  );
}
