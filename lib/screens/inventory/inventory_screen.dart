import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/screens/inventory/add_item_sheet.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  // Get a stream of the user's inventory items
  Stream<QuerySnapshot> _getInventoryStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.empty();
    }
    // Get the path to THEIR inventory sub-collection
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('inventory')
        .orderBy('createdAt', descending: true) // Le plus récent en haut
        .snapshots(); // .snapshots() est ce qui le rend "temps réel"
  }

  // Delete an item from the inventory
  void _deleteItem(String docId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('inventory')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory'), centerTitle: true),

      body: StreamBuilder<QuerySnapshot>(
        stream: _getInventoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("An error occurred."));
          }

          // Pas d'articles dans l'inventaire
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No items in your inventory. Tap + to add some!",
                textAlign: TextAlign.center,
              ),
            );
          }

          // Construct the list of items
          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final data = item.data() as Map<String, dynamic>;
              final itemName = data['name'];
              final itemLocation = data['location'];

              // Delete on swipe by using the Dismissible widget
              return Dismissible(
                key: Key(item.id), // Clé unique pour que Flutter s'y retrouve
                direction:
                    DismissDirection.endToStart, // Swipe from right to left
                onDismissed: (direction) {
                  // Once the "swipe" is complete, we delete
                  _deleteItem(item.id);

                  // Confirmation snackbar after deletion
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("$itemName deleted."),
                      action: SnackBarAction(
                        label: "Cancel",
                        onPressed: () {
                          // (Logique d'annulation non implémentée pour le MVP)
                        },
                      ),
                    ),
                  );
                },
                // Ce qui s'affiche sous l'article pendant le "swipe"
                background: Container(
                  color: Colors.red[700],
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                // C'est l'article lui-même
                child: ListTile(
                  leading: Icon(
                    itemLocation == 'Frigo' ? Icons.kitchen : Icons.shelves,
                  ),
                  title: Text(itemName),
                  subtitle: Text(itemLocation),
                ),
              );
            },
          );
        },
      ),

      // Le bouton + pour ajouter
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => const AddItemSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
