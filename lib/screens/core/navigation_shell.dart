import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/inventory/inventory_screen.dart';
import 'package:frigo_zen/screens/settings/settings_screen.dart';
import 'package:frigo_zen/screens/shopping/shopping_screen.dart';
import 'package:frigo_zen/screens/recipes/favorites_screen.dart';
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
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navigationController = context.watch<NavigationController>();
    final selectedIndex = navigationController.selectedIndex;

    return Scaffold(
      body: _screens[selectedIndex],

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
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: l10n.inventoryTab,
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: l10n.shoppingListTab,
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: l10n.favoritesTab,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: l10n.settingsTab,
          ),
        ],
      ),
    );
  }
}
