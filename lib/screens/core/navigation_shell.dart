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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B9C5F), // Primary Green
                );
              }
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              );
            }),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 65,
            animationDuration: const Duration(milliseconds: 300),
            indicatorColor: const Color(0xFF6B9C5F).withValues(alpha: 0.15),
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              context.read<NavigationController>().setIndex(index);
            },
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: Colors.grey[600]),
                selectedIcon: const Icon(Icons.dashboard, color: Color(0xFF6B9C5F)),
                label: l10n.dashboardTitle,
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined, color: Colors.grey[600]),
                selectedIcon: const Icon(Icons.inventory_2, color: Color(0xFF6B9C5F)),
                label: l10n.inventoryTab,
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_cart_outlined, color: Colors.grey[600]),
                selectedIcon: const Icon(Icons.shopping_cart, color: Color(0xFF6B9C5F)),
                label: l10n.shoppingListTab,
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined, color: Colors.grey[600]),
                selectedIcon: const Icon(Icons.restaurant_menu, color: Color(0xFF6B9C5F)),
                label: l10n.recipeTitle,
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, color: Colors.grey[600]),
                selectedIcon: const Icon(Icons.settings, color: Color(0xFF6B9C5F)),
                label: l10n.settingsTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
