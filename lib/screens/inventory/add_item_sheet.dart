import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:frigo_zen/services/inventory_service.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _quantity = 1;
  bool _isLoading = false;

  void _saveItem() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String userTypedName = _nameController.text.trim();
      final int userQuantity = _quantity;
      try {
        final functions = FirebaseFunctions.instanceFor(region: "us-central1");
        final callable = functions.httpsCallable('getSmartItemData');
        final result = await callable.call({'productName': userTypedName});
        final Map<String, dynamic> itemData = Map<String, dynamic>.from(
          result.data['item'],
        );
        final String name = itemData['name'] ?? l10n.shoppingItemNoTitle;
        final String canonicalName = itemData['canonicalName'] ?? name;
        final int dvm = itemData['dvm'];
        final String category = itemData['category'] ?? 'Other';
        final String location = itemData['location'] ?? 'Frigo';
        final inventoryService = InventoryService();

        await inventoryService.upsertItemToInventory(
          name: userTypedName,
          canonicalName: canonicalName,
          quantity: userQuantity,
          dvm: dvm,
          category: category,
          location: location,
        );
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.addItemError(error.toString()))),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.addItemTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.addItemNameLabel,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.addItemNameError;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                ),
                Text(
                  l10n.addItemQuantityLabel(_quantity),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // const SizedBox(height: 16),
            // Sélecteur d'emplacement
            // ToggleButtons(
            //   isSelected: [
            //     _selectedLocation == 'Frigo',
            //     _selectedLocation == 'Placard',
            //   ],
            //   onPressed: (index) {
            //     setState(() {
            //       _selectedLocation = (index == 0) ? 'Frigo' : 'Placard';
            //     });
            //   },
            //   children: const [
            //     Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 16),
            //       child: Text('Frigo'),
            //     ),
            //     Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 16),
            //       child: Text('Placard'),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.green,
                ),
                onPressed: _saveItem,

                child: Text(
                  l10n.addItemSaveBtn,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
