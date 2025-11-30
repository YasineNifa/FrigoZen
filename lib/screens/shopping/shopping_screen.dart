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

  Set<String> _checkedItemIds = {};
  List<QueryDocumentSnapshot> _allItems = [];

  final Color _backgroundColor = const Color(0xFFF9F9F9);

  void _saveItemToFirebase(
    String itemName,
    String cleanedName,
    String canonicalName,
    int quantity,
    int? dvm,
    String? category,
    String? location,
  ) {
    _shoppingService.addItemToShoppingList(
      name: itemName,
      cleanedName: cleanedName,
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
      final String name = itemData['name'] ?? itemName;
      final String cleanedName = itemData['cleanedName'] ?? itemName;
      final String canonicalName = itemData['canonicalName'] ?? itemName;
      final int dvm = itemData['dvm'] ?? 7;
      final String category = itemData['category'] ?? 'Other';
      final String location = itemData['location'] ?? 'Frigo';
      final int quantity = itemData['quantity'] ?? 1;

      if (!mounted) return;

      final inventory = context.read<InventoryProvider>();

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
                  cleanedName,
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
          cleanedName,
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

  void _toggleSelectAll() {
    if (_allItems.isEmpty) return;

    // Vérifie si tout est coché
    final bool allAreChecked = _checkedItemIds.length == _allItems.length;
    final bool newValue = !allAreChecked;

    final batch = FirebaseFirestore.instance.batch();

    for (var doc in _allItems) {
      // On ne met à jour que si nécessaire pour économiser des écritures
      if (doc['isChecked'] != newValue) {
        batch.update(doc.reference, {'isChecked': newValue});
      }
    }
    batch.commit();
  }

  void _moveCheckedItemsToInventory() async {
    if (_isMovingItems) return;

    // On récupère la liste des documents cochés depuis _allItems
    final checkedDocs = _allItems
        .where((doc) => _checkedItemIds.contains(doc.id))
        .toList();

    if (checkedDocs.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isMovingItems = true;
    });

    try {
      final inventoryService = InventoryService();
      List<Future> tasks = [];

      for (final itemDoc in checkedDocs) {
        final data = itemDoc.data() as Map<String, dynamic>;
        final String name = data['name'] ?? l10n.shoppingItemNoTitle;
        final String cleanedName = data['cleanedName'] ?? name;
        final String canonicalName = data['canonicalName'] ?? name;
        final int quantity = data['quantity'] ?? 1;
        final int? dvm = data['dvm'];
        final String category = data['category'] ?? 'Other';
        final String location = data['location'] ?? 'Frigo';

        tasks.add(
          inventoryService
              .upsertItemToInventory(
                name: name,
                cleanedName: cleanedName,
                canonicalName: canonicalName,
                quantity: quantity,
                dvm: dvm,
                category: category,
                location: location,
                imageUrl: '',
                nutriscore: '',
                storeName: '',
                brands: '',
              )
              .then((_) {
                return _shoppingService.removeItemFromShoppingList(itemDoc.id);
              }),
        );
      }

      await Future.wait(tasks);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.shoppingMovedSuccess(checkedDocs.length)),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
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
          // _checkedItemIds sera mis à jour automatiquement par le Stream
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool allChecked =
        _allItems.isNotEmpty && _checkedItemIds.length == _allItems.length;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(l10n.shoppingTitle),
        actions: [
          if (_allItems.isNotEmpty)
            IconButton(
              icon: Icon(
                allChecked ? Icons.deselect_outlined : Icons.select_all,
                color: Colors.black87,
              ),
              tooltip: allChecked ? "Tout décocher" : "Tout cocher",
              onPressed: _toggleSelectAll,
            ),
        ],
      ),
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
                // On n'affiche le loader QUE si on n'a pas de data ET qu'on attend
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // On nettoie les états locaux si la liste est vide
                  if (_allItems.isNotEmpty) {
                    // Petit hack pour éviter setState pendant le build
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted)
                        setState(() {
                          _allItems = [];
                          _checkedItemIds = {};
                        });
                    });
                  }
                  return const ShoppingListEmptyState();
                }

                final items = snapshot.data!.docs;

                // Mise à jour silencieuse de l'état local pour le FAB
                // On calcule les IDs cochés
                final newCheckedIds = items
                    .where(
                      (doc) =>
                          (doc.data() as Map<String, dynamic>)['isChecked'] ==
                          true,
                    )
                    .map((doc) => doc.id)
                    .toSet();

                // On ne déclenche un setState que si ça a vraiment changé
                if (newCheckedIds.length != _checkedItemIds.length ||
                    _allItems.length != items.length) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _allItems = items;
                        _checkedItemIds = newCheckedIds;
                      });
                    }
                  });
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final data = item.data() as Map<String, dynamic>;

                    return ShoppinglistTile(
                      title: data["name"],
                      id: item.id,
                      isChecked: data["isChecked"],
                      // ACTION IMMÉDIATE (Optimistic UI)
                      // On ne met pas de chargement ici, Firestore gère ça très vite
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
      floatingActionButton: _checkedItemIds.isEmpty
          ? null
          : FloatingActionButton.extended(
              icon: _isMovingItems
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check, color: Colors.white),
              label: Text(
                _isMovingItems
                    ? l10n.shoppingAddingBtn
                    : l10n.shoppingMoveBtn(_checkedItemIds.length),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: _isMovingItems ? null : _moveCheckedItemsToInventory,
            ),
    );
  }
}
