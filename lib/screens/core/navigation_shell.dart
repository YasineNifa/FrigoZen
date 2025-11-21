import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/inventory/inventory_screen.dart';
import 'package:frigo_zen/screens/settings/settings_screen.dart';
import 'package:frigo_zen/screens/shopping/shopping_screen.dart';
import 'package:frigo_zen/screens/recipes/favorites_screen.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _selectedIndex = 0;

  // List of the three screens
  final List<Widget> _screens = [
    const InventoryScreen(),
    const ShoppingScreen(),
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  // Update the state of the activated tab.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: _screens[_selectedIndex],

      // Navigation Bar
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.grey[150],
        animationDuration: const Duration(milliseconds: 200),
        indicatorColor: Colors.green[100],
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
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
