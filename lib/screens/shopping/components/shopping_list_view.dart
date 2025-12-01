import 'package:flutter/material.dart';
import 'package:frigo_zen/components/shopping_list_empty_state.dart';
import 'package:frigo_zen/components/shopping_list_tile.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/theme/app_theme.dart';

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

        return ListView.builder(
          itemCount: vm.items.length,
          itemBuilder: (context, index) {
            final item = vm.items[index];
            return ShoppinglistTile(
              title: item.name,
              id: item.id ?? '',
              isChecked: item.isChecked,
              onToggle: () => vm.toggleItemChecked(item),
              onDelete: () {
                if (item.id != null) {
                  vm.deleteItem(item.id!);
                }
              },
            );
          },
        );
      },
    );
  }
}
