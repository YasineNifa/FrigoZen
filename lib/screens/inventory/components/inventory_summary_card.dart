import 'package:flutter/material.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class InventorySummaryCard extends StatelessWidget {
  final VoidCallback? onRecipePressed;

  const InventorySummaryCard({super.key, this.onRecipePressed});

  @override
  Widget build(BuildContext context) {
    return Consumer2<InventoryViewModel, ShoppingViewModel>(
      builder: (context, inventoryVm, shoppingVm, child) {
        final expiringCount = inventoryVm.expiringSoonCount;
        final totalCount = inventoryVm.items.length;
        // Count unchecked items in shopping list as "To Buy"
        final toBuyCount = shoppingVm.items.where((item) => !item.isChecked).length;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCompactStat(
                    context,
                    label: AppLocalizations.of(context)!.summaryTotal,
                    value: "$totalCount",
                    icon: Icons.inventory_2_outlined,
                    color: Colors.blue,
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                  _buildCompactStat(
                    context,
                    label: AppLocalizations.of(context)!.summaryToEat,
                    value: "$expiringCount",
                    icon: Icons.timer_outlined,
                    color: expiringCount > 0 ? Colors.orange : Colors.green,
                    isBold: expiringCount > 0,
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                  _buildCompactStat(
                    context,
                    label: AppLocalizations.of(context)!.summaryShopping,
                    value: "$toBuyCount",
                    icon: Icons.shopping_cart_outlined,
                    color: Colors.purple,
                  ),
                ],
              ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isBold ? color : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
