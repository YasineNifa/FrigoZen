import 'package:get_it/get_it.dart';
import 'package:frigo_zen/repositories/inventory_repository.dart';
import 'package:frigo_zen/repositories/shopping_repository.dart';
import 'package:frigo_zen/repositories/household_repository.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Repositories
  locator.registerLazySingleton<InventoryRepository>(() => InventoryRepository());
  locator.registerLazySingleton<ShoppingRepository>(() => ShoppingRepository());
  locator.registerLazySingleton<HouseholdRepository>(() => HouseholdRepository());

  // Services
  locator.registerLazySingleton<RevenueProvider>(() => RevenueProvider());

  // ViewModels
  locator.registerFactory<InventoryViewModel>(
    () => InventoryViewModel(
      inventoryRepository: locator<InventoryRepository>(),
    ),
  );
  locator.registerFactory<ShoppingViewModel>(
    () => ShoppingViewModel(
      shoppingRepository: locator<ShoppingRepository>(),
      inventoryRepository: locator<InventoryRepository>(),
    ),
  );
}
