import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/services/inventory_service.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class EditBatchesSheet extends StatelessWidget {
  final String docId;
  final String itemName;
  final List<dynamic> batches;
  final InventoryService service;

  const EditBatchesSheet({
    super.key,
    required this.docId,
    required this.itemName,
    required this.batches,
    required this.service,
  });

  String _formatDate(Timestamp ts) {
    final date = ts.toDate();
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void _pickDate(BuildContext context, Map<String, dynamic> batch) async {
    final currentTs = batch['expirationDate'] as Timestamp;
    final initialDate = currentTs.toDate();
    final l10n = AppLocalizations.of(context)!;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      try {
        await service.updateBatchDate(docId, batch, pickedDate);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.editBatchesSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.editBatchesError(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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

  Widget _buildInitialsAvatar(String name) {
    String initials = "";
    if (name.isNotEmpty) {
      final trimmed = name.trim();
      if (trimmed.length >= 2) {
        initials = trimmed.substring(0, 2).toUpperCase();
      } else if (trimmed.isNotEmpty) {
        initials = trimmed.substring(0, 1).toUpperCase();
      } else {
        initials = "?";
      }
    }

    // 2. Générer une couleur unique basée sur le nom (Hashcode)
    // On utilise une liste de couleurs "FrigoZen" douces
    final List<Color> colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.blueGrey,
    ];

    // L'opérateur % assure qu'on reste toujours dans la limite de la liste
    final color = colors[name.hashCode.abs() % colors.length];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Fond pastel
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color, // Texte de la couleur vive
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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

          Text(
            l10n.editBatchesTitle(itemName),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
                      final batch = batches[index] as Map<String, dynamic>;

                      // --- RÉCUPÉRATION DES DONNÉES RICHES ---
                      final int quantity = batch['quantity'] ?? 1;
                      final Timestamp ts = batch['expirationDate'];

                      // Données spécifiques au lot (si disponibles)
                      final String specificName =
                          batch['name'] ??
                          itemName; // Le nom précis (ex: Cheddar Tex Mex)
                      final String brand = batch['brands'] ?? '';
                      final String? batchImageUrl = batch['imageUrl'];
                      final String? nutriscore = batch['nutriscore'];
                      final String storeName = batch['storeName'] ?? '';
                      final Timestamp? addedAtTs = batch['addedAt'];
                      final String addedDateStr = addedAtTs != null
                          ? _formatDate(addedAtTs)
                          : '';

                      // Calcul Expiration
                      final now = DateTime.now();
                      final date = ts.toDate();
                      final today = DateTime(now.year, now.month, now.day);
                      final expiryDay = DateTime(
                        date.year,
                        date.month,
                        date.day,
                      );

                      final isExpired = expiryDay.isBefore(today);
                      final isToday = expiryDay.isAtSameMomentAs(today);

                      Color statusColor = Colors.green[700]!;
                      if (isExpired)
                        statusColor = Colors.red[700]!;
                      else if (isToday)
                        statusColor = Colors.orange[800]!;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
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
                              // Container(
                              //   width: 60,
                              //   height: 60,
                              //   decoration: BoxDecoration(
                              //     borderRadius: BorderRadius.circular(8),
                              //     color: Colors.grey[100],
                              //     image:
                              //         batchImageUrl != null &&
                              //             batchImageUrl.isNotEmpty
                              //         ? DecorationImage(
                              //             image: NetworkImage(batchImageUrl),
                              //             fit: BoxFit.cover,
                              //           )
                              //         : null,
                              //   ),
                              //   child:
                              //       batchImageUrl == null ||
                              //           batchImageUrl.isEmpty
                              //       ? Icon(
                              //           Icons.fastfood,
                              //           color: Colors.grey[400],
                              //         )
                              //       : null,
                              // ),
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
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (ctx, error, stackTrace) =>
                                                    _buildInitialsAvatar(
                                                      specificName,
                                                    ),
                                          )
                                        : _buildInitialsAvatar(specificName),
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
                                    icon: const Icon(
                                      Icons.edit_calendar_outlined,
                                    ),
                                    color: Theme.of(context).primaryColor,
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => _pickDate(context, batch),
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
                                        _formatDate(ts),
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
                                        "Ajouté le $addedDateStr", // TODO: Traduire "Ajouté le"
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
  }
}
