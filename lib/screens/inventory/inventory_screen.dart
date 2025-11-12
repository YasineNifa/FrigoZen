import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/screens/inventory/add_item_sheet.dart';
import 'dart:convert'; // Pour le Base64
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_functions/cloud_functions.dart';

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

  void _incrementItem(String docId, int currentQuantity) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('inventory')
        .doc(docId)
        .update({'quantity': currentQuantity + 1});
  }

  void _decrementItem(String docId, int currentQuantity) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (currentQuantity <= 1) {
      _deleteItem(docId);
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('inventory')
          .doc(docId)
          .update({'quantity': currentQuantity - 1});
    }
  }

  void _pickAndProcessReceipt(BuildContext context) async {
    // 1. AFFICHER UN "LOADING"
    // On crée une SnackBar de chargement
    final loadingSnackbar = SnackBar(
      content: Row(
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(width: 16),
          Text('Analyse du ticket...'),
        ],
      ),
      duration: Duration(minutes: 5), // Elle restera jusqu'à ce qu'on la cache
    );
    ScaffoldMessenger.of(context).showSnackBar(loadingSnackbar);

    try {
      // 2. PRENDRE LA PHOTO
      final imagePicker = ImagePicker();
      // final XFile? pickedImage = await imagePicker.pickImage(
      //   source: ImageSource.camera, // On ouvre la caméra
      //   imageQuality: 80, // Qualité (pas besoin de 100)
      // );
      final XFile? pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery, // <--- ON OUVRE LA GALERIE
        imageQuality: 80, 
      );

      if (pickedImage == null) {
        // L'utilisateur a annulé
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return;
      }

      // 3. LIRE ET REDIMENSIONNER L'IMAGE
      final bytes = await pickedImage.readAsBytes();
      // On utilise la bibliothèque 'image' pour décoder
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        throw Exception("Impossible de décoder l'image.");
      }

      // On redimensionne à 800px de large (largement suffisant pour l'OCR)
      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: 800,
      );

      // 4. ENCODER EN BASE64
      // On ré-encode la *petite* image en Jpeg, puis en Base64
      final String base64Image = base64Encode(img.encodeJpg(resizedImage));

      // 5. APPELER LA CLOUD FUNCTION
      final functions = FirebaseFunctions.instanceFor(region: "us-central1");
      final callable = functions.httpsCallable('processReceipt');
      
      final result = await callable.call(<String, dynamic>{
        'imageBase64': base64Image, // On envoie l'image
      });

      // 6. ON A LA RÉPONSE !
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Cacher le loading

      final data = result.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final lines = List<String>.from(data['lines']);

        // POUR L'INSTANT : ON AFFICHE LE RÉSULTAT DANS LA CONSOLE DE DEBUG
        print("---------------------------------");
        print("LIGNES DU TICKET DÉTECTÉES :");
        lines.forEach((line) => print(line));
        print("---------------------------------");

        // ÉTAPE FUTURE : Envoyer "lines" à un nouvel écran de validation
        // _navigateToValidationScreen(context, lines);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${lines.length} lignes de texte trouvées !'),
            backgroundColor: Colors.green[700],
          ),
        );

      } else {
        throw Exception("La fonction a échoué (success: false)");
      }

    } on FirebaseFunctionsException catch (error) {
      // Gérer les erreurs de la fonction (ex: non connecté)
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur Backend : ${error.message}'),
          backgroundColor: Colors.red[700],
        ),
      );
    } catch (error) {
      // Gérer les autres erreurs (caméra, etc.)
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $error'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory'), centerTitle: true, actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Scanner un ticket',
            onPressed: () {
              // On appelle notre nouvelle fonction de capture
              _pickAndProcessReceipt(context);
            },
          ),
        ],),

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

          // Mettre à jour le Provider avec les noms
          // On utilise "addPostFrameCallback" pour le faire après la construction du widget
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // On récupère la liste des noms
            final itemNames = items.map((item) {
              final data = item.data() as Map<String, dynamic>;
              return data['name'] as String;
            }).toList();
            // On met à jour le provider (sans déclencher de re-build de cet écran)
            context.read<InventoryProvider>().updateInventory(itemNames);
          });

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final data = item.data() as Map<String, dynamic>;
              final String itemName = data['name'] ?? 'Unnamed Item';
              // final itemLocation = data['location'];
              final int itemQuantity = data["quantity"] ?? 1;

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
                  title: Text(itemName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Prend le moins de place
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          _decrementItem(item.id, itemQuantity);
                        },
                      ),
                      Text(
                        itemQuantity.toString(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          _incrementItem(item.id, itemQuantity);
                        },
                      ),
                    ],
                  ),
                )
                // ListTile(
                //   leading: Icon(
                //     itemLocation == 'Frigo' ? Icons.kitchen : Icons.shelves,
                //   ),
                //   title: Text(itemName),
                //   subtitle: Text(itemLocation),
                // ),
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
