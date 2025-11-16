import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/services/inventory_service.dart';

// C'est notre nouvel écran. Il accepte la liste des articles de Gemini.
class ValidationScreen extends StatefulWidget {
  // La liste vient de Gemini (ex: [{name: Flour, quantity: 1, ...}])
  final List<dynamic> scannedItems;

  const ValidationScreen({super.key, required this.scannedItems});

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  // On crée une liste "modifiable" dans l'état du widget
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

  // Fonction pour mettre à jour la quantité d'un article
  void _updateQuantity(int index, int change) {
    setState(() {
      final newQuantity = _editableItems[index]['quantity'] + change;
      if (newQuantity > 0) {
        _editableItems[index]['quantity'] = newQuantity;
      }
    });
  }

  // Fonction pour supprimer un article de la liste
  void _removeItem(int index) {
    setState(() {
      _editableItems.removeAt(index);
    });
  }

  // Fonction pour modifier le nom (si l'utilisateur clique dessus)
  // (On le fera dans une v2, pour l'instant on se concentre sur la validation)

  // La fonction finale : tout ajouter à l'inventaire
  // Future<void> _addItemsToInventory() async {
  //   setState(() { _isLoading = true; });

  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   final batch = FirebaseFirestore.instance.batch();
  //   final inventoryCollection = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user.uid)
  //       .collection('inventory');

  //   final now = Timestamp.now();
  //   final nowMillis = now.millisecondsSinceEpoch;

  //   try {
  //     for (final item in _editableItems) {
  //       final String canonicalName = item['canonicalName'] ?? item['name'];
  //       final existingDoc = await _findExistingItem(canonicalName);
  //       final int dvm = item['dvm'] ?? 7;
  //       final int dvmMillis = dvm * 24 * 60 * 60 * 1000;
  //       final Timestamp expirationDate = Timestamp.fromMillisecondsSinceEpoch(nowMillis + dvmMillis);

  //       final newBatch = {
  //         'quantity': item['quantity'] ?? 1,
  //         'expirationDate': expirationDate,
  //         'addedAt': now,
  //       };

  //       if (existingDoc != null) {
  //         final data = existingDoc.data() as Map<String, dynamic>;
  //         final List<dynamic> oldBatches = data['batches'] ?? [];
  //         final newBatches = [...oldBatches, newBatch];

  //         // On recalcule la quantité totale
  //         int newTotalQuantity = 0;
  //         for (var batch in newBatches) {
  //           newTotalQuantity += (batch['quantity'] as int? ?? 0);
  //         }

  //         // On met à jour le document existant
  //         await inventoryCollection.doc(existingDoc.id).update({
  //           'batches': newBatches,
  //           'totalQuantity': newTotalQuantity,
  //           // On met à jour la date la plus proche (pour les alertes)
  //           'earliestExpirationDate': _getEarliestDate(newBatches),
  //         });

  //       } else {
  //         // CAS B : L'ARTICLE N'EXISTE PAS -> ON CRÉE (SET)
  //         await inventoryCollection.add({
  //           'name': item['name'] ?? 'Article inconnu',
  //           'canonicalName': canonicalName,
  //           'category': item['category'] ?? 'Other',
  //           'location': item['location'] ?? 'Placard',
  //           'totalQuantity': item['quantity'] ?? 1,
  //           'batches': [newBatch], // On crée le tableau de lots
  //           'earliestExpirationDate': expirationDate, // La date la plus proche est celle-ci
  //           'createdAt': now,
  //         });
  //       }
  //     }

  //     if (mounted) {
  //       // Afficher un succès
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("${_editableItems.length} articles ajoutés à l'inventaire !"),
  //           backgroundColor: Colors.green[700],
  //         ),
  //       );
  //       // On ferme l'écran de validation
  //       Navigator.of(context).pop();
  //     }
  //   } catch (error) {
  //     if (mounted) {
  //       setState(() { _isLoading = false; });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Error : $error")),
  //       );
  //     }
  //   }
  // }

  Future<void> _addItemsToInventory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final inventoryService = InventoryService();
      final now = Timestamp.now();
      final nowMillis = now.millisecondsSinceEpoch;

      for (final item in _editableItems) {
        // 1. Get all the data from the IA
        final String name = item['name'] ?? 'Article inconnu';
        final String canonicalName = item['canonicalName'] ?? name;
        final int quantity = item['quantity'] ?? 1;
        final String category = item['category'] ?? 'Other';
        final String location = item['location'] ?? 'Placard';

        // 2. Calculate expiration date
        final int dvm = item['dvm'] ?? 7;
        final int dvmMillis = dvm * 24 * 60 * 60 * 1000;
        final Timestamp expirationDate = Timestamp.fromMillisecondsSinceEpoch(
          nowMillis + dvmMillis,
        );

        // 3. Call the single service function
        await inventoryService.upsertItemToInventory(
          name: name,
          canonicalName: canonicalName,
          quantity: quantity,
          expirationDate: expirationDate,
          category: category,
          location: location,
        );
      }

      // 4. Tout a réussi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_editableItems.length} articles mis à jour dans l\'inventaire !',
            ),
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
          SnackBar(content: Text("Erreur lors de la fusion : $error")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Valider vos articles (${_editableItems.length})'),
        // On empêche le "swipe back" accidentel
        automaticallyImplyLeading: false,
        actions: [
          // Bouton pour annuler
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _editableItems.length,
        itemBuilder: (context, index) {
          final item = _editableItems[index];
          final nameController = TextEditingController(text: item['name']);

          // return Card(
          //   margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Row(
          //       children: [
          //         IconButton(
          //           icon: Icon(Icons.delete_outline, color: Colors.red[700]),
          //           onPressed: () => _removeItem(index),
          //         ),

          //         Expanded(
          //           child: TextField(
          //             controller: nameController,
          //             decoration: const InputDecoration(border: InputBorder.none),
          //             onChanged: (newName) {
          //               _editableItems[index]['name'] = newName;
          //             },
          //           ),
          //         ),

          //         IconButton(
          //           icon: const Icon(Icons.remove),
          //           onPressed: () => _updateQuantity(index, -1),
          //         ),
          //         Text(
          //           item['quantity'].toString(),
          //           style: Theme.of(context).textTheme.titleMedium,
          //         ),
          //         IconButton(
          //           icon: const Icon(Icons.add),
          //           onPressed: () => _updateQuantity(index, 1),
          //         ),
          //       ],
          //     ),
          //   ),
          // );

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
              label: Text('Ajouter ${_editableItems.length} articles'),
              onPressed: _addItemsToInventory,
            ),
    );
  }
}
