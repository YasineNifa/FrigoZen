import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/main.dart';
import 'package:provider/provider.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final _textController = TextEditingController();
  List<QueryDocumentSnapshot> _checkedItems = [];

  // Return the CollectionReference for the shopping list for the current user
  CollectionReference _getShoppingListCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("No user logged in.");
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('shopping_list');
  }

  // Get a stream of the shopping list items
  Stream<QuerySnapshot> _getShoppingListStream() {
    return _getShoppingListCollection()
        .orderBy('createdAt', descending: false) // Les plus anciens en haut
        .snapshots();
  }

  void _addItem() async {
    final itemName = _textController.text.trim();
    if (itemName.isEmpty) return;

    // "listen: false" est important, on ne fait que lire la donnée
    // Get the provider
    final inventory = context.read<InventoryProvider>();

    // VÉRIFICATION "ANTI-DOUBLON"
    if (inventory.doesItemExist(itemName)) {
      // Alert
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "💡 Attention ! You already have \"$itemName\" in your inventory !",
          ),
          backgroundColor: Colors.blue[700],
          action: SnackBarAction(
            label: "Add Anyway",
            textColor: Colors.white,
            onPressed: () {
              _saveItemToFirebase(itemName);
            },
          ),
        ),
      );
      // On n'ajoute pas tout de suite, on attend que l'utilisateur clique "Ajouter quand même"
      _textController.clear();
      FocusScope.of(context).unfocus(); // Ferme le clavier
    } else {
      // Save directly to Firebase if no duplicate found
      _saveItemToFirebase(itemName);
    }
  }

  void _saveItemToFirebase(String itemName) {
    _getShoppingListCollection().add({
      'name': itemName,
      'isChecked': false,
      'createdAt': Timestamp.now(),
    });
    _textController.clear();
  }

  void _toggleItem(String docId, bool currentStatus) {
    _getShoppingListCollection().doc(docId).update({
      'isChecked': !currentStatus,
    });
  }

  void _deleteItem(String docId) {
    _getShoppingListCollection().doc(docId).delete();
  }

  void _moveCheckedItemsToInventory(
    List<QueryDocumentSnapshot> checkedItems,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final firestore = FirebaseFirestore.instance;
    final userDocRef = firestore.collection('users').doc(user.uid);
    final inventoryCollection = userDocRef.collection('inventory');
    final shoppingListCollection = userDocRef.collection('shopping_list');

    // Create a batch to perform multiple writes
    final batch = firestore.batch();

    for (final itemDoc in checkedItems) {
      final data = itemDoc.data() as Map<String, dynamic>;
      final itemName = data['name'];

      // Add to the inventory collection
      final newInventoryItemRef = inventoryCollection.doc();
      batch.set(newInventoryItemRef, {
        'name': itemName,
        'location':
            'Frigo', //By default, we place new items in the fridge (TODO: let user choose)
        'createdAt': Timestamp.now(),
      });

      // Delete from the shopping list collection
      batch.delete(shoppingListCollection.doc(itemDoc.id));
    }

    // Execute all the operations at once
    try {
      await batch.commit(); // Execute the batch

      // Display a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${checkedItems.length} item(s) moved to Inventory successfully!",
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    } catch (error) {
      // Gérer les erreurs
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error moving items: ${error.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Add to shopping list...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: _addItem,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getShoppingListStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("The shopping list is empty."),
                  );
                }

                final items = snapshot.data!.docs;
                final localCheckedItems = items.where((item) {
                  final data = item.data() as Map<String, dynamic>;
                  return data['isChecked'];
                }).toList();

                // Mettre à jour l'état local des articles cochés
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // On vérifie si la liste a changé pour éviter des rebuilds infinis
                  if (_checkedItems.length != localCheckedItems.length) {
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
                    final itemName = data['name'];
                    final bool isChecked = data['isChecked'];

                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteItem(item.id),
                      background: Container(
                        color: Colors.red[700],
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        // La case à cocher
                        leading: Checkbox(
                          value: isChecked,
                          onChanged: (_) => _toggleItem(item.id, isChecked),
                        ),
                        title: Text(
                          itemName,
                          style: TextStyle(
                            decoration: isChecked
                                ? TextDecoration
                                      .lineThrough // Barré si coché
                                : TextDecoration.none,
                            color: isChecked ? Colors.grey[600] : null,
                          ),
                        ),
                        // Bouton pour supprimer (alternative au swipe)
                        trailing: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _deleteItem(item.id),
                        ),
                      ),
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
              icon: const Icon(Icons.check),
              label: Text('Add ${_checkedItems.length} item(s) to Inventory'),
              onPressed: () {
                _moveCheckedItemsToInventory(_checkedItems);
              },
            ),
    );
  }
}
