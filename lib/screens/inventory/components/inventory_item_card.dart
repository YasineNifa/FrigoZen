
import 'package:flutter/material.dart';
import 'package:frigo_zen/models/inventory_item.dart';
import 'package:frigo_zen/screens/inventory/edit_batches_sheet.dart';
import 'package:frigo_zen/components/initials_avatar.dart';

import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/theme/app_theme.dart';

class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;

  const InventoryItemCard({super.key, required this.item});

  Map<String, dynamic> _getExpirationStatus(DateTime expirationDate) {
    final now = DateTime.now();
    final difference = expirationDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (difference < 0) {
      return {'text': 'Expired', 'color': AppTheme.statusExpired};
    } else if (difference == 0) {
      return {'text': 'Expires today', 'color': AppTheme.statusExpired};
    } else if (difference <= 3) {
      return {'text': 'Expires soon', 'color': AppTheme.statusWarning};
    } else if (difference <= 7) {
      return {
        'text': 'Expires in $difference days',
        'color': AppTheme.statusSafe,
      };
    } else {
      return {'text': 'Fresh', 'color': AppTheme.statusNeutral};
    }
  }



  @override
  Widget build(BuildContext context) {
    final vm = context.read<InventoryViewModel>();

    // Logic extracted from original _buildItemCard
    final String displayTitle = item.cleanedName.isNotEmpty
        ? item.cleanedName
        : item.name;
    final int itemQuantity = item.totalQuantity;

    // Image logic: Item image > First batch image > null
    final String? imageUrl = item.displayImageUrl;

    final status = _getExpirationStatus(item.earliestExpirationDate);
    final statusText = status['text'] as String;
    final statusColor = status['color'] as Color;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) => vm.deleteItem(item.id),
          background: Container(
            color: AppTheme.errorColor,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          child: InkWell(
            onTap: () {
              // We still need InventoryService for EditBatchesSheet because I haven't refactored that sheet yet.
              // I will pass a new instance or use the one from context if available.
              // Ideally EditBatchesSheet should also use VM.
              // For now, I'll instantiate InventoryService() as a temporary bridge or pass it if possible.
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (ctx) => EditBatchesSheet(item: item),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (ctx, error, stackTrace) =>
                                    InitialsAvatar(name: displayTitle),
                              )
                            : InitialsAvatar(name: displayTitle),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (statusText.isNotEmpty)
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.quantityControlBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          color: AppTheme.textDark,
                          onPressed: () => vm.decrementItemQuantity(item),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '$itemQuantity',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () => vm.incrementItemQuantity(item),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
