import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/models/inventory_item.dart';

import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/theme/app_theme.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/components/initials_avatar.dart';
import 'package:frigo_zen/screens/inventory/components/edit_batch_dialog.dart';

class EditBatchesSheet extends StatelessWidget {
  final InventoryItem item;

  const EditBatchesSheet({super.key, required this.item});

  String _formatDate(Timestamp ts) {
    final date = ts.toDate();
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }



  void _showRenameDialog(BuildContext context, InventoryViewModel vm) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renameProductTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.newNameLabel,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelBtn),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await vm.updateItemName(item, newName);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text(l10n.saveBtn),
          ),
        ],
      ),
    );
  }

  Color _getNutriScoreColor(String? score) {
    switch (score?.toLowerCase()) {
      case 'a':
        return const Color(0xFF038141);
      case 'b':
        return const Color(0xFF85BB2F);
      case 'c':
        return const Color(0xFFFECB02);
      case 'd':
        return const Color(0xFFEE8100);
      case 'e':
        return const Color(0xFFE63E11);
      default:
        return Colors.grey;
    }
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<InventoryViewModel>(
      builder: (context, vm, child) {
        // Find the latest version of the item
        InventoryItem currentItem;
        try {
          currentItem = vm.items.firstWhere((i) => i.id == item.id);
        } catch (e) {
          // Item might have been deleted or not found, fallback to initial item
          currentItem = item;
        }

        final batches = currentItem.batches;

    return Container(
      padding: const EdgeInsets.all(24),
      // On agrandit un peu la hauteur pour accommoder les infos riches
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de drag
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.editBatchesTitle(currentItem.name),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _showRenameDialog(context, vm),
                tooltip: l10n.renameTooltip,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.editBatchesSubtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: batches.isEmpty
                ? Center(child: Text(l10n.editBatchesEmpty))
                : ListView.separated(
                    itemCount: batches.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final batch = batches[index];

                      // --- RÉCUPÉRATION DES DONNÉES RICHES ---
                      final int quantity = batch.quantity;
                      final DateTime ts = batch.expirationDate;

                      // Données spécifiques au lot (si disponibles), sinon fallback sur l'item
                      final String specificName = (batch.name != null && batch.name!.isNotEmpty) 
                          ? batch.name! 
                          : currentItem.name;
                      final String brand = batch.brands ?? '';
                      final String? batchImageUrl = batch.imageUrl; // Already correct
                      final String? nutriscore = batch.nutriscore;
                      final String storeName = batch.storeName ?? '';
                      final DateTime addedAtTs = batch.addedAt;
                      final String addedDateStr = _formatDate(Timestamp.fromDate(addedAtTs));

                      // Calcul Expiration
                      final now = DateTime.now();
                      final date = ts;
                      final today = DateTime(now.year, now.month, now.day);
                      final expiryDay = DateTime(
                        date.year,
                        date.month,
                        date.day,
                      );

                      final isExpired = expiryDay.isBefore(today);
                      final isToday = expiryDay.isAtSameMomentAs(today);

                      Color statusColor = Colors.green[700]!;
                      if (isExpired) {
                        statusColor = Colors.red[700]!;
                      } else if (isToday) {
                        statusColor = Colors.orange[800]!;
                      }

                      // Determine name for initials (prefer cleanedName)
                      final String initialsName = (batch.cleanedName != null && batch.cleanedName!.isNotEmpty)
                          ? batch.cleanedName!
                          : (currentItem.cleanedName.isNotEmpty ? currentItem.cleanedName : specificName);

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. IMAGE SPÉCIFIQUE DU LOT
                              Stack(
                                children: [
                                  // L'Image de base
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey[100],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        batchImageUrl != null &&
                                            batchImageUrl.isNotEmpty
                                        ? Image.network(
                                            batchImageUrl,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (ctx, error, stackTrace) =>
                                                    InitialsAvatar(
                                                      name: initialsName,
                                                    ),
                                          )
                                        : InitialsAvatar(name: initialsName),
                                  ),

                                  // Le Badge Nutri-Score (En bas à droite)
                                  if (nutriscore != null)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getNutriScoreColor(
                                            nutriscore,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            bottomRight: Radius.circular(
                                              12,
                                            ), // Suit le coin de l'image
                                          ),
                                        ),
                                        child: Text(
                                          nutriscore.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(width: 12),

                              // 2. INFOS PRINCIPALES
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Nom précis et Marque
                                    Text(
                                      specificName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (brand.isNotEmpty)
                                      Text(
                                        brand,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),

                                    const SizedBox(height: 8),

                                    // Badges (Nutri-Score + Quantité + Magasin)
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        // Badge Quantité
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          child: Text(
                                            "x$quantity",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        // Badge Nutri-Score (Si présent)
                                        // if (nutriscore != null &&
                                        //     nutriscore.isNotEmpty)
                                        //   Container(
                                        //     padding: const EdgeInsets.symmetric(
                                        //       horizontal: 6,
                                        //       vertical: 2,
                                        //     ),
                                        //     decoration: BoxDecoration(
                                        //       color: _getNutriScoreColor(
                                        //         nutriscore,
                                        //       ),
                                        //       borderRadius:
                                        //           BorderRadius.circular(4),
                                        //     ),
                                        //     child: Text(
                                        //       "Nutri ${nutriscore.toUpperCase()}",
                                        //       style: const TextStyle(
                                        //         color: Colors.white,
                                        //         fontSize: 10,
                                        //         fontWeight: FontWeight.bold,
                                        //       ),
                                        //     ),
                                        //   ),

                                        // Badge Magasin (Si présent)
                                        if (storeName.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.store,
                                                  size: 10,
                                                  color: Colors.blue[800],
                                                ),
                                                const SizedBox(width: 4),
                                                // TODO la valeur destoreName contient le lien vers l'image
                                                Text(
                                                  storeName,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.blue[800],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // 3. DATE ET ACTION
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    color: Colors.grey[600],
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => EditBatchDialog(
                                          batch: batch,
                                          onSave: (updatedBatch) async {
                                            try {
                                              await vm.updateBatchDetails(
                                                currentItem,
                                                batch,
                                                updatedBatch,
                                              );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        l10n.editBatchesSuccess),
                                                    backgroundColor:
                                                        AppTheme.statusSafe,
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        l10n.editBatchesError(
                                                            e.toString())),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isExpired
                                            ? Icons.warning_amber_rounded
                                            : Icons.event,
                                        size: 14,
                                        color: statusColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(Timestamp.fromDate(ts)),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (addedDateStr.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        l10n.addedOnDate(addedDateStr),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
        );
      },
    );
  }
}
