import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'dart:ui';

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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3), // Semi-transparent white
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(image, width: 200, height: 200, fit: BoxFit.contain),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700], // Slightly darker for contrast
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
