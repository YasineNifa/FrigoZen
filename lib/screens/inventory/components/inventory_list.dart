import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/inventory/components/inventory_empty_state.dart';
import 'package:frigo_zen/screens/inventory/components/inventory_item_card.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/components/skeleton.dart';

class InventoryList extends StatelessWidget {
  const InventoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 16),
            itemCount: 5,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Skeleton(width: 60, height: 60, borderRadius: 12),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Skeleton(width: 120, height: 16),
                        const SizedBox(height: 8),
                        const Skeleton(width: 80, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final items = vm.filteredItems;

        if (items.isEmpty) {
          return InventoryEmptyState(
            filter: vm.selectedFilter,
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
