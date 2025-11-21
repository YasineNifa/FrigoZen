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
        // Appel au service pour mettre à jour
        await service.updateBatchDate(docId, batch, pickedDate);

        if (context.mounted) {
          Navigator.pop(context); // Fermer la modale
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.editBatchesSuccess),
              behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    separatorBuilder: (ctx, i) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final batch = batches[index] as Map<String, dynamic>;
                      final quantity = batch['quantity'];
                      final ts = batch['expirationDate'] as Timestamp;

                      // Vérifier si c'est aujourd'hui ou passé
                      final now = DateTime.now();
                      final date = ts.toDate();
                      final isExpired = date.isBefore(
                        DateTime(now.year, now.month, now.day),
                      );

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[100],
                          child: Text(
                            "x$quantity",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        title: Text(
                          isExpired
                              ? l10n.editBatchesExpiredPrefix
                              : l10n.editBatchesExpiresPrefix,
                          style: TextStyle(
                            color: isExpired ? Colors.red : Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          _formatDate(ts),
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_calendar_outlined),
                          color: Theme.of(context).primaryColor,
                          onPressed: () => _pickDate(context, batch),
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
