import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/services/inventory_service.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

// 1. NOUVEAUX IMPORTS
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    _editableItems = widget.scannedItems.map((item) {
      final map = Map<String, dynamic>.from(item);
      
      // 1. Smart Parsing of Quantity/Name
      // If quantity is default (1) and name looks like "4 Laits", parse it.
      if ((map['quantity'] == null || map['quantity'] == 1) && map['name'] != null) {
        final parsed = _parseQuantityAndName(map['name']);
        if (parsed['quantity'] != 1) {
          map['quantity'] = parsed['quantity'];
          map['name'] = parsed['name'];
        }
      }

      // 2. Prioritize OCR name (already in 'name') > canonicalName > cleanedName
      // Only overwrite if OCR name is empty
      if (map['name'] == null || map['name'].toString().trim().isEmpty) {
        if (map['canonicalName'] != null && map['canonicalName'].toString().isNotEmpty) {
          map['name'] = map['canonicalName'];
        } else if (map['cleanedName'] != null && map['cleanedName'].toString().isNotEmpty) {
          map['name'] = map['cleanedName'];
        }
      }
      return map;
    }).toList();
  }

  Map<String, dynamic> _parseQuantityAndName(String rawName) {
    // Regex to match "Quantity x Name" or "Quantity Name"
    // ^(\d+)\s*[xX]?\s*(.*)$
    final regex = RegExp(r'^(\d+)\s*[xX]?\s*(.*)$');
    final match = regex.firstMatch(rawName);

    if (match != null) {
      final quantity = int.parse(match.group(1)!);
      final name = match.group(2)!.trim();
      return {'quantity': quantity, 'name': name};
    }

    return {'quantity': 1, 'name': rawName};
  }

  // --- 2. NOUVELLE FONCTION : SCANNER ET METTRE À JOUR ---
  Future<void> _scanBarcodeAndUpdateItem(int index) async {
    try {
      // A. Lancer le scanner
      var res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SimpleBarcodeScannerPage(),
        ),
      );

      if (res is String && res != '-1' && res.isNotEmpty) {
        // B. Afficher le chargement sur CET item spécifique
        setState(() {
          _editableItems[index]['_isLoading'] = true;
        });

        // C. Appeler Open Food Facts
        final url = Uri.parse(
          'https://world.openfoodfacts.org/api/v2/product/$res?fields=product_name,brands,image_front_small_url,nutriscore_grade',
        );
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['status'] == 1) {
            final product = data['product'];
            final String newName =
                product['product_name'] ?? _editableItems[index]['name'];
            final String brands = product['brands'] ?? '';
            final String fullName = brands.isNotEmpty
                ? "$newName ($brands)"
                : newName;

            // D. Mettre à jour l'item avec les vraies données
            setState(() {
              _editableItems[index]['name'] = fullName;
              // On garde le canonicalName d'origine pour la logique, ou on le met à jour aussi
              // _editableItems[index]['canonicalName'] = newName;

              if (product['image_front_small_url'] != null) {
                _editableItems[index]['imageUrl'] =
                    product['image_front_small_url'];
              }
              if (product['nutriscore_grade'] != null) {
                _editableItems[index]['nutriscore'] =
                    product['nutriscore_grade'];
              }

              _editableItems[index]['_isLoading'] = false;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Produit mis à jour !"),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            throw Exception("Produit introuvable.");
          }
        } else {
          throw Exception("Erreur réseau.");
        }
      }
    } catch (e) {
      setState(() {
        _editableItems[index]['_isLoading'] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    }
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
        final String cleanedName = item['cleanedName'] ?? name;
        final String canonicalName = item['canonicalName'] ?? name;
        final int quantity = item['quantity'] ?? 1;
        final String category = item['category'] ?? 'Other';
        final String location = item['location'] ?? 'Placard';

        // On récupère les nouvelles données potentielles (image, nutri)
        final String? imageUrl = item['imageUrl'];
        final String? nutriscore = item['nutriscore'];
        final String? storeName = item['imageUrl'];
        final String? brands = item['nutriscore'];

        final int dvm = item['dvm'] ?? 7;
        final int dvmMillis = dvm * 24 * 60 * 60 * 1000;
        final Timestamp expirationDate = Timestamp.fromMillisecondsSinceEpoch(
          nowMillis + dvmMillis,
        );

        await inventoryService.upsertItemToInventory(
          name: name,
          cleanedName: cleanedName,
          canonicalName: canonicalName,
          quantity: quantity,
          expirationDate: expirationDate,
          category: category,
          location: location,
          imageUrl: imageUrl,
          nutriscore: nutriscore,
          storeName: storeName,
          brands: brands,
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
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _editableItems.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _editableItems[index];

          // Gestion de l'affichage de l'image ou du loader
          final bool isItemLoading = item['_isLoading'] == true;
          final String? imageUrl = item['imageUrl'];
          final String? nutriscore = item['nutriscore'];

          // Controller pour le champ texte
          // Attention: recréer le controller à chaque build peut faire perdre le focus
          // Pour une liste simple de validation, c'est acceptable, sinon il faudrait une liste de controllers.
          final nameController = TextEditingController(text: item['name']);
          // Hack pour garder le curseur à la fin si l'utilisateur tape
          nameController.selection = TextSelection.fromPosition(
            TextPosition(offset: nameController.text.length),
          );

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  // 1. BOUTON SUPPRIMER
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                    onPressed: () => _removeItem(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                  const SizedBox(width: 8),

                  // 2. IMAGE / LOADING / SCAN
                  GestureDetector(
                    onTap: () => _scanBarcodeAndUpdateItem(index),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: isItemLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(imageUrl, fit: BoxFit.cover),
                            )
                          : const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.black54,
                            ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 3. NOM ET NUTRISCORE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          onChanged: (newName) {
                            _editableItems[index]['name'] = newName;
                          },
                        ),
                        if (nutriscore != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "Nutri-Score ${nutriscore.toUpperCase()}",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 4. QUANTITÉ
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        onPressed: () => _updateQuantity(index, -1),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          item['quantity'].toString(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        onPressed: () => _updateQuantity(index, 1),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          );
        },
      ),

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
