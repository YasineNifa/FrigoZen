import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

import 'package:frigo_zen/viewmodels/inventory_view_model.dart';

class InventoryEmptyState extends StatelessWidget {
  final LocationFilter filter;
  final bool isSearch;

  const InventoryEmptyState({
    super.key,
    required this.filter,
    this.isSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String image = "assets/images/discu.png";
    if (isSearch) {
      image = "assets/images/discu.png";
    } else {
      switch (filter) {
        case LocationFilter.freezer:
          image = "assets/images/conge.png";
          break;
        case LocationFilter.fridge:
          image = "assets/images/fridge.png";
          break;
        case LocationFilter.pantry:
          image = "assets/images/pant.png";
          break;
        case LocationFilter.all:
          image = "assets/images/discu.png";
          break;
      }
    }

    String title = isSearch
        ? l10n.searchNoResults
        : l10n.inventoryEmptyTitle;

    String subtitle = isSearch
        ? l10n.searchTryDifferent
        : l10n.inventoryEmptySubtitle;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, width: 250, height: 250, fit: BoxFit.contain),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
