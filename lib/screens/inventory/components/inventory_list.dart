import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/inventory/components/inventory_empty_state.dart';
import 'package:frigo_zen/screens/inventory/components/inventory_item_card.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:provider/provider.dart';

class InventoryList extends StatelessWidget {
  const InventoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = vm.filteredItems;

        if (items.isEmpty) {
          return InventoryEmptyState(
            location: vm.selectedLocation,
            isSearch: vm.searchQuery.isNotEmpty,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80, top: 16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return InventoryItemCard(item: item);
          },
        );
      },
    );
  }
}
