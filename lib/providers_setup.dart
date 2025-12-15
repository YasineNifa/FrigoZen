import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:frigo_zen/locator.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/viewmodels/meal_planner_view_model.dart';
import 'package:frigo_zen/viewmodels/recipes_view_model.dart';
import 'package:frigo_zen/screens/core/navigation_controller.dart';

List<SingleChildWidget> getApplicationProviders() {
  final revenueProvider = locator<RevenueProvider>();
  
  return [
    ChangeNotifierProvider(
      create: (context) => locator<InventoryViewModel>(),
    ),
    ChangeNotifierProvider(
      create: (context) => locator<ShoppingViewModel>(),
    ),
    ChangeNotifierProvider(create: (context) => MealPlannerViewModel()),
    ChangeNotifierProvider(
      create: (context) => locator<RecipesViewModel>(),
    ),
    ChangeNotifierProvider(create: (context) => NavigationController()),
    ChangeNotifierProvider.value(value: revenueProvider),
  ];
}
