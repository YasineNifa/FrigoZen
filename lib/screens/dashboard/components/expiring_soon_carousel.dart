import 'package:flutter/material.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/components/initials_avatar.dart';
import 'package:frigo_zen/components/skeleton.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class ExpiringSoonCarousel extends StatelessWidget {
  const ExpiringSoonCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: const Skeleton(width: 150, height: 20),
              ),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: 3,
                  itemBuilder: (context, index) => Container(
                    width: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Expanded(child: Skeleton(width: double.infinity, borderRadius: 12)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Skeleton(width: 80, height: 12),
                              const SizedBox(height: 4),
                              const Skeleton(width: 50, height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        final items = vm.expiringItems;
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                AppLocalizations.of(context)!.expiringSoonTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final daysLeft = item.earliestExpirationDate
                      .difference(DateTime.now())
                      .inDays;

                  Color statusColor = Colors.orange;
                  if (daysLeft < 0) statusColor = Colors.red;
                  if (daysLeft <= 2) statusColor = Colors.redAccent;

                  return Container(
                    width: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: item.displayImageUrl != null &&
                                    item.displayImageUrl!.isNotEmpty
                                ? Image.network(
                                    item.displayImageUrl!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, o, s) => InitialsAvatar(
                                      name: item.cleanedName.isNotEmpty
                                          ? item.cleanedName
                                          : item.name,
                                    ),
                                  )
                                : InitialsAvatar(
                                    name: item.cleanedName.isNotEmpty
                                        ? item.cleanedName
                                        : item.name,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.cleanedName.isNotEmpty ? item.cleanedName : item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                daysLeft < 0
                                    ? AppLocalizations.of(context)!.expiredLabel
                                    : (daysLeft == 0
                                          ? AppLocalizations.of(context)!.todayLabel
                                          : AppLocalizations.of(context)!.daysLeftLabel(daysLeft)),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }


}
