import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/services/inventory_service.dart';

class ValidationScreen extends StatefulWidget {
  final List<dynamic> scannedItems;
  const ValidationScreen({super.key, required this.scannedItems});

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  late List<Map<String, dynamic>> _editableItems;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Quand l'écran se charge, on copie la liste de Gemini
    // dans notre variable d'état locale pour pouvoir la modifier.
    // On convertit List<dynamic> en List<Map<String, dynamic>>
    _editableItems = widget.scannedItems.map((item) {
      // Pour chaque "item" (qui est un Map<Object?, Object?>),
      // on crée un nouveau Map<String, dynamic>
      return Map<String, dynamic>.from(item);
    }).toList();
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      final newQuantity = _editableItems[index]['quantity'] + change;
      if (newQuantity > 0) {
        _editableItems[index]['quantity'] = newQuantity;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _editableItems.removeAt(index);
    });
  }

  Future<void> _addItemsToInventory() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });

    try {
      final inventoryService = InventoryService();
      final now = Timestamp.now();
      final nowMillis = now.millisecondsSinceEpoch;

      for (final item in _editableItems) {
        final String name = item['name'] ?? 'Article inconnu';
        final String canonicalName = item['canonicalName'] ?? name;
        final int quantity = item['quantity'] ?? 1;
        final String category = item['category'] ?? 'Other';
        final String location = item['location'] ?? 'Placard';

        final int dvm = item['dvm'] ?? 7;
        final int dvmMillis = dvm * 24 * 60 * 60 * 1000;
        final Timestamp expirationDate = Timestamp.fromMillisecondsSinceEpoch(
          nowMillis + dvmMillis,
        );

        await inventoryService.upsertItemToInventory(
          name: name,
          canonicalName: canonicalName,
          quantity: quantity,
          expirationDate: expirationDate,
          category: category,
          location: location,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.validationSuccess(_editableItems.length)),
            backgroundColor: Colors.green[700],
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.validationError(error.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.validationTitle(_editableItems.length)),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.validationCancelBtn,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _editableItems.length,
        itemBuilder: (context, index) {
          final item = _editableItems[index];
          final nameController = TextEditingController(text: item['name']);

          return ListTile(
            leading: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[700]),
              onPressed: () => _removeItem(index),
            ),

            title: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (newName) {
                _editableItems[index]['name'] = newName;
              },
            ),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _updateQuantity(index, -1),
                ),
                Text(
                  item['quantity'].toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _updateQuantity(index, 1),
                ),
              ],
            ),
          );
        },
      ),

      // Bouton de validation final
      floatingActionButton: _isLoading
          ? const FloatingActionButton(
              onPressed: null,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : FloatingActionButton.extended(
              icon: const Icon(Icons.check),
              label: Text(l10n.validationAddBtn(_editableItems.length)),
              onPressed: _addItemsToInventory,
            ),
    );
  }
}
