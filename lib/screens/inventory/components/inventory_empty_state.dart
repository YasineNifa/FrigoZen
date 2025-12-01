import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class InventoryEmptyState extends StatelessWidget {
  final String location;
  final bool isSearch;

  const InventoryEmptyState({
    super.key,
    required this.location,
    this.isSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String image = "assets/images/discu.png";
    if (isSearch) {
      image = "assets/images/discu.png";
    } else if (location == "Congélateur") {
      image = "assets/images/conge.png";
    } else if (location == "Frigo") {
      image = "assets/images/fridge.png";
    } else if (location == "Placard") {
      image = "assets/images/pant.png";
    }

    String title = isSearch
        ? "No results found" // TODO: Traduire
        : l10n.inventoryEmptyTitle;

    String subtitle = isSearch
        ? "Try a different search term."
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
