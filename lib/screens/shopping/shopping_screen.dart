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


  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/shopping.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              "Your shopping list is empty",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Add an item using the field above to get started.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600]
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
                  child: 
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Add to shopping list...',
                      prefixIcon: const Icon(Icons.shop),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.light 
                            ? Colors.grey[200] 
                            : Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                  onPressed: _addItem,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            )
          ),


          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getShoppingListStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
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
                        leading: Checkbox(
                          activeColor: Colors.green[400],
                          value: isChecked,
                          onChanged: (_) => _toggleItem(item.id, isChecked),
                        ),
                        title: Text(
                          itemName,
                          style: TextStyle(
                            decoration: isChecked
                                ? TextDecoration
                                      .lineThrough
                                : TextDecoration.none,
                            color: isChecked ? Colors.grey[600] : Colors.black,
                          ),
                        ),
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
              icon: const Icon(
                Icons.check,
                color: Color.fromARGB(237, 255, 255, 255),
              ),
              label: Text(
                'Add ${_checkedItems.length} item(s) to Inventory', 
                style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Color.fromARGB(237, 255, 255, 255)
                )
              ),
              backgroundColor: Colors.green[400],
              onPressed: () {
                _moveCheckedItemsToInventory(_checkedItems);
              },
            ),
    );
  }
}
