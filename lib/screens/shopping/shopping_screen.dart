import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:frigo_zen/main.dart';
import 'package:frigo_zen/services/shopping_service.dart';
import 'package:frigo_zen/services/inventory_service.dart';
import 'package:frigo_zen/components/shopping_list_tile.dart';
import 'package:frigo_zen/components/shopping_list_empty_state.dart';
import 'package:frigo_zen/components/input_field.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final _shoppingService = ShoppingService();
  final _textController = TextEditingController();

  bool _isAddingItem = false;
  bool _isMovingItems = false;

  List<QueryDocumentSnapshot> _checkedItems = [];

  void _saveItemToFirebase(
    String itemName,
    String canonicalName,
    int quantity,
    int? dvm,
    String? category,
    String? location,
  ) {
    _shoppingService.addItemToShoppingList(
      name: itemName,
      canonicalName: canonicalName,
      quantity: quantity,
      dvm: dvm,
      category: category,
      location: location,
    );
    _textController.clear();
  }

  void _addItem() async {
    final itemName = _textController.text.trim();
    if (itemName.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isAddingItem = true;
    });
    FocusScope.of(context).unfocus();

    try {
      final functions = FirebaseFunctions.instanceFor(region: "us-central1");
      final callable = functions.httpsCallable('getSmartItemData');
      final result = await callable.call({'productName': itemName});
      final Map<String, dynamic> itemData = Map<String, dynamic>.from(
        result.data['item'],
      );
      final String canonicalName = itemData['canonicalName'] ?? itemName;
      final int dvm = itemData['dvm'] ?? 7;
      final String category = itemData['category'] ?? 'Other';
      final String location = itemData['location'] ?? 'Frigo';
      final int quantity = itemData['quantity'] ?? 1;

      if (!mounted) return;

      // Get the provider
      final inventory = context.read<InventoryProvider>();
      // VÉRIFICATION "ANTI-DOUBLON"
      if (inventory.doesItemExist(canonicalName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.shoppingDuplicateAlert(itemName)),
            backgroundColor: Colors.blue[700],
            action: SnackBarAction(
              label: l10n.shoppingAddAnyway,
              textColor: Colors.white,
              onPressed: () {
                _saveItemToFirebase(
                  itemName,
                  canonicalName,
                  quantity,
                  dvm,
                  category,
                  location,
                );
              },
            ),
          ),
        );
        _textController.clear();
        FocusScope.of(context).unfocus();
      } else {
        _saveItemToFirebase(
          itemName,
          canonicalName,
          quantity,
          dvm,
          category,
          location,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.shoppingErrorGeneric(error.toString())),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingItem = false;
        });
      }
      _textController.clear();
    }
  }

  void _moveCheckedItemsToInventory(
    List<QueryDocumentSnapshot> checkedItems,
  ) async {
    if (_isMovingItems) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isMovingItems = true;
    });

    try {
      final inventoryService = InventoryService();

      for (final itemDoc in checkedItems) {
        final data = itemDoc.data() as Map<String, dynamic>;

        final String name = data['name'] ?? l10n.shoppingItemNoTitle;
        final String canonicalName = data['canonicalName'] ?? name;
        final int quantity = data['quantity'] ?? 1;
        final int? dvm = data['dvm'];
        final String category = data['category'];
        final String location = data['location'];

        await inventoryService.upsertItemToInventory(
          name: name,
          canonicalName: canonicalName,
          quantity: quantity,
          dvm: dvm,
          category: category,
          location: location,
        );
        await _shoppingService.removeItemFromShoppingList(itemDoc.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.shoppingMovedSuccess(checkedItems.length)),
            backgroundColor: Colors.green[700],
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.shoppingMoveError(error.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isMovingItems = false;
          _checkedItems.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(l10n.shoppingTitle)),
      body: Column(
        children: [
          CustomizedInputField(
            textController: _textController,
            isAdding: _isAddingItem,
            onAdd: _addItem,
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _shoppingService.getShoppingListStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const ShoppingListEmptyState();
                }

                final items = snapshot.data!.docs;
                final localCheckedItems = items.where((item) {
                  final data = item.data() as Map<String, dynamic>;
                  return data['isChecked'];
                }).toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted &&
                      _checkedItems.length != localCheckedItems.length) {
                    setState(() {
                      _checkedItems = localCheckedItems;
                    });
                  }
                });

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final data = item.data() as Map<String, dynamic>;

                    return ShoppinglistTile(
                      title: data["name"],
                      id: item.id,
                      isChecked: data["isChecked"],
                      onToggle: () => _shoppingService.updateItem(item.id, {
                        'isChecked': !data["isChecked"],
                      }),
                      onDelete: () =>
                          _shoppingService.removeItemFromShoppingList(item.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _checkedItems.isEmpty
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                _isMovingItems
                    ? l10n.shoppingAddingBtn
                    : l10n.shoppingMoveBtn(_checkedItems.length),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: _isMovingItems
                  ? null
                  : () {
                      _moveCheckedItemsToInventory(_checkedItems);
                    },
            ),
    );
  }
}
