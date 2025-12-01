import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:provider/provider.dart';

class LocationFilterPills extends StatelessWidget {
  const LocationFilterPills({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<InventoryViewModel>();
    final selectedFilter = vm.selectedFilter;

    final filters = [
      {'filter': LocationFilter.all, 'label': l10n.inventoryTabAll},
      {'filter': LocationFilter.fridge, 'label': l10n.inventoryTabFridge},
      {'filter': LocationFilter.pantry, 'label': l10n.inventoryTabPantry},
      {'filter': LocationFilter.freezer, 'label': l10n.inventoryTabFreezer},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((f) {
          final filter = f['filter'] as LocationFilter;
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(f['label'] as String),
              onSelected: (bool selected) {
                if (selected) {
                  vm.setFilter(filter);
                }
              },
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
