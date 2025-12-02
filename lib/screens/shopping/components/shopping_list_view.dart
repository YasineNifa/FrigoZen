import 'package:flutter/material.dart';
import 'package:frigo_zen/components/shopping_list_empty_state.dart';
import 'package:frigo_zen/models/shopping_item.dart';
import 'package:frigo_zen/components/shopping_list_tile.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:provider/provider.dart';


class ShoppingListView extends StatelessWidget {
  const ShoppingListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading && vm.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.items.isEmpty) {
          return const ShoppingListEmptyState();
        }

        // Group items by category
        final groupedItems = <String, List<ShoppingItem>>{};
        for (var item in vm.items) {
          final category = item.category.isNotEmpty ? item.category : 'Autres';
          if (!groupedItems.containsKey(category)) {
            groupedItems[category] = [];
          }
          groupedItems[category]!.add(item);
        }

        // Sort categories (optional: define a specific order)
        final sortedCategories = groupedItems.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100), // Space for FAB
          itemCount: sortedCategories.length,
          itemBuilder: (context, sectionIndex) {
            final category = sortedCategories[sectionIndex];
            final items = groupedItems[category]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ShoppinglistTile(
                        item: item, // Pass the whole item
                        onToggle: () => vm.toggleItemChecked(item),
                        onDelete: () {
                          vm.deleteItem(item.id);
                        },
                      ),
                    )),
              ],
            );
          },
        );
      },
    );
  }
}
