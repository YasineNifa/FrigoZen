import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/screens/inventory/components/inventory_empty_state.dart';
import 'package:frigo_zen/screens/inventory/components/inventory_item_card.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/components/skeleton.dart';

import 'package:frigo_zen/screens/inventory/inventory_view_mode.dart';
import 'package:frigo_zen/theme/app_theme.dart';

import 'package:frigo_zen/constants/app_categories.dart';
import 'package:frigo_zen/models/enums.dart';

class InventoryList extends StatelessWidget {
  final InventoryViewMode viewMode;

  const InventoryList({super.key, this.viewMode = InventoryViewMode.list});

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

        if (viewMode == InventoryViewMode.list) {
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InventoryItemCard(item: item);
            },
          );
        }

        // Grouping Logic
        final groupedItems = <dynamic>[]; // List of String (Header) or InventoryItem

        if (viewMode == InventoryViewMode.priority) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final expired = <InventoryItem>[];
          final urgent = <InventoryItem>[]; // <= 3 days
          final thisWeek = <InventoryItem>[]; // <= 7 days
          final fresh = <InventoryItem>[]; // > 7 days

          for (var item in items) {
            final diff = item.earliestExpirationDate.difference(today).inDays;
            if (diff < 0) {
              expired.add(item);
            } else if (diff <= 3) {
              urgent.add(item);
            } else if (diff <= 7) {
              thisWeek.add(item);
            } else {
              fresh.add(item);
            }
          }

          final l10n = AppLocalizations.of(context)!;

          if (expired.isNotEmpty) {
            groupedItems.add(_HeaderData(l10n.headerExpired, AppTheme.statusExpired));
            groupedItems.addAll(expired);
          }
          if (urgent.isNotEmpty) {
            groupedItems.add(_HeaderData(l10n.headerUrgent, AppTheme.statusWarning));
            groupedItems.addAll(urgent);
          }
          if (thisWeek.isNotEmpty) {
            groupedItems.add(_HeaderData(l10n.headerThisWeek, AppTheme.statusSafe));
            groupedItems.addAll(thisWeek);
          }
          if (fresh.isNotEmpty) {
            groupedItems.add(_HeaderData(l10n.headerFresh, AppTheme.statusNeutral));
            groupedItems.addAll(fresh);
          }
        } else if (viewMode == InventoryViewMode.category) {
          // Sort by category first
          items.sort((a, b) => a.category.compareTo(b.category));
          
          InventoryCategory? currentCategory;
          for (var item in items) {
            if (item.category != currentCategory) {
              currentCategory = item.category;
              final localizedCategory = AppCategories.getLocalizedName(context, currentCategory.key);
              groupedItems.add(_HeaderData(localizedCategory, Colors.grey[800]!));
            }
            groupedItems.add(item);
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80, top: 16),
          itemCount: groupedItems.length,
          itemBuilder: (context, index) {
            final item = groupedItems[index];
            if (item is _HeaderData) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              );
            } else if (item is InventoryItem) {
              return InventoryItemCard(item: item);
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

class _HeaderData {
  final String title;
  final Color color;
  _HeaderData(this.title, this.color);
}
