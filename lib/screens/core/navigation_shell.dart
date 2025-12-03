import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/inventory/inventory_screen.dart';
import 'package:frigo_zen/screens/settings/settings_screen.dart';
import 'package:frigo_zen/screens/shopping/shopping_screen.dart';
import 'package:frigo_zen/screens/recipes/recipes_screen.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/screens/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/screens/core/navigation_controller.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}



class _NavigationShellState extends State<NavigationShell> {
  // Removed local _selectedIndex

  // List of the screens
  final List<Widget> _screens = [
    const DashboardScreen(),
    const InventoryScreen(),
    const ShoppingScreen(),
    const RecipesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navigationController = context.watch<NavigationController>();
    final selectedIndex = navigationController.selectedIndex;

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),

      // Navigation Bar
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.grey[150],
        animationDuration: const Duration(milliseconds: 200),
        indicatorColor: Colors.green[100],
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          context.read<NavigationController>().setIndex(index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.dashboardTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: l10n.inventoryTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_cart_outlined),
            selectedIcon: const Icon(Icons.shopping_cart),
            label: l10n.shoppingListTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu_outlined),
            selectedIcon: const Icon(Icons.restaurant_menu),
            label: l10n.recipeTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settingsTab,
          ),
        ],
      ),
    );
  }
}
