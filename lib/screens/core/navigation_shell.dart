import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/inventory/inventory_screen.dart';
import 'package:frigo_zen/screens/settings/settings_screen.dart';
import 'package:frigo_zen/screens/shopping/shopping_screen.dart';
import 'package:frigo_zen/screens/recipes/favorites_screen.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  // State: we keep in memory the index of the selected tab
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
    return Scaffold(
      // The body of the application change based in the selected tab
      body: _screens[_selectedIndex],

      // Navigation Bar
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.grey[150],
        animationDuration: const Duration(milliseconds: 200),
        indicatorColor: Colors.green[100],
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'List',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
