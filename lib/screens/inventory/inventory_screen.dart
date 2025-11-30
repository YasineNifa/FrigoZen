import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/paywall/modern_paywall_screen.dart';
import 'package:frigo_zen/screens/recipes/recipe_suggestion_screen.dart';
import 'package:frigo_zen/services/inventory_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/screens/inventory/add_item_sheet.dart';
import 'package:frigo_zen/services/ocr_service.dart';
import 'package:frigo_zen/services/household_service.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/screens/inventory/edit_batches_sheet.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  final _inventoryService = InventoryService();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _selectedLocation = "Tout";
  String _searchQuery = "";
  final Set<String> _loadingItems = {};
  List<dynamic> _localRecipeCache = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(_handleTabSelection);
    _searchController.addListener(_handleSearch);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _checkPremiumStatus(BuildContext context) async {
    final isPro = context.read<RevenueProvider>().isPro;

    if (isPro) {
      return true;
    } else {
      try {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => const ModernPaywallScreen()),
        );
        return context.read<RevenueProvider>().isPro;
      } on PurchasesError catch (e) {
        print("Error while displaying Paywall: $e");
        return false;
      }
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedLocation = "Tout";
          break;
        case 1:
          _selectedLocation = "Frigo";
          break;
        case 2:
          _selectedLocation = "Placard";
          break;
        case 3:
          _selectedLocation = "Congélateur";
          break;
      }
      // Rebuilds the StreamBuilder with the new location
    });
  }

  void _handleSearch() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
    });
  }

  void _incrementItem(String docId, int currentQuantity) async {
    setState(() => _loadingItems.add(docId));
    try {
      await _inventoryService.incrementItemQuantity(docId, currentQuantity);
    } catch (e) {
      print("Error incrementing item: $e");
    } finally {
      if (mounted) {
        setState(() => _loadingItems.remove(docId));
      }
    }
  }

  void _decrementItem(String docId, int currentQuantity) async {
    setState(() => _loadingItems.add(docId));
    try {
      await _inventoryService.decrementItemQuantity(docId, currentQuantity);
    } catch (e) {
      print("Error decrementing item: $e");
    } finally {
      if (mounted) {
        setState(() => _loadingItems.remove(docId));
      }
    }
  }

  void _showImageSourceDialog(BuildContext context) async {
    final OcrService ocrService = OcrService();
    final bool isPro = context.read<RevenueProvider>().isPro;
    final l10n = AppLocalizations.of(context)!;
    Widget buildProBadge() {
      return Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          "PRO",
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 165, 214, 167),
                child: Icon(
                  Icons.receipt_long,
                  color: Color.fromARGB(255, 32, 32, 32),
                ),
              ), //camera_alt
              title: Row(
                children: [
                  Text(l10n.scanReceiptCamera),
                  if (!isPro) buildProBadge(),
                ],
              ),
              trailing: !isPro
                  ? const Icon(Icons.lock_outline, color: Colors.grey)
                  : null,
              onTap: () async {
                final hasAccess = await _checkPremiumStatus(context);
                if (!hasAccess) return;
                Navigator.of(ctx).pop();
                ocrService.pickAndProcessReceipt(context, ImageSource.camera);
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 165, 214, 167),
                child: Icon(
                  Icons.qr_code_2,
                  color: Color.fromARGB(255, 32, 32, 32),
                ),
              ),
              title: Row(
                children: [
                  const Text('Scanner un code-barres'),
                  if (!context.read<RevenueProvider>().isPro) buildProBadge(),
                ],
              ),
              trailing: !context.read<RevenueProvider>().isPro
                  ? const Icon(Icons.lock_outline, color: Colors.grey)
                  : null,
              onTap: () {
                Navigator.of(ctx).pop();
                _scanProductBarcode(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 165, 214, 167),
                child: Icon(
                  Icons.photo_library,
                  color: Color.fromARGB(255, 32, 32, 32),
                ),
              ),
              title: Row(
                children: [
                  Text(l10n.scanReceiptGallery),
                  if (!isPro) buildProBadge(),
                ],
              ),
              trailing: !isPro
                  ? const Icon(Icons.lock_outline, color: Colors.grey)
                  : null,
              onTap: () async {
                final hasAccess = await _checkPremiumStatus(context);
                if (!hasAccess) return;
                Navigator.of(ctx).pop();
                ocrService.pickAndProcessReceipt(context, ImageSource.gallery);
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 165, 214, 167),
                child: Icon(Icons.add, color: Color.fromARGB(255, 32, 32, 32)),
              ),
              title: Text(l10n.scanManual),
              onTap: () {
                Navigator.of(ctx).pop();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => const AddItemSheet(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getExpirationStatus(Timestamp? expirationDate) {
    if (expirationDate == null) {
      return {'text': 'Unknown', 'color': Colors.grey};
    }

    final now = DateTime.now();
    final expiry = expirationDate.toDate();

    final difference = expiry
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (difference < 0) {
      return {'text': 'Expired', 'color': Colors.red[700]!};
    } else if (difference == 0) {
      return {'text': 'Expires today', 'color': Colors.red[700]!};
    } else if (difference <= 3) {
      return {'text': 'Expires soon', 'color': Colors.orange[700]!};
    } else if (difference <= 7) {
      return {
        'text': 'Expires in $difference days',
        'color': Colors.green[700]!,
      };
    } else {
      return {'text': 'Fresh', 'color': Colors.grey[700]!};
    }
  }

  Future<List<Map<String, dynamic>>> _getInventoryData() async {
    try {
      final inventorySnapshot = await _inventoryService.getInventory();
      final inventoryData = inventorySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        final List<dynamic> batches = data['batches'] ?? [];
        final List<dynamic> convertedBatches = batches.map((batch) {
          final ts = batch['expirationDate'] as Timestamp?;
          final addedAtTs = batch['addedAt'] as Timestamp?;
          return {
            'quantity': batch['quantity'],
            'expirationDate': ts?.toDate().toIso8601String(),
            'addedAt': addedAtTs?.toDate().toIso8601String(),
          };
        }).toList();

        final earliestTs = data['earliestExpirationDate'] as Timestamp?;
        final createdTs = data['createdAt'] as Timestamp?;

        return {
          'name': data['name'],
          'canonicalName': data['canonicalName'],
          'category': data['category'],
          'location': data['location'],
          'totalQuantity': data['totalQuantity'],
          'batches': convertedBatches,
          'earliestExpirationDate': earliestTs?.toDate().toIso8601String(),
          'createdAt': createdTs?.toDate().toIso8601String(),
        };
      }).toList();

      return inventoryData;
    } catch (e) {
      print("Error fetching inventory data: $e");
      return [];
    }
  }

  String _getCacheKeyFromInventory(List<Map<String, dynamic>> inventoryData) {
    if (inventoryData.isEmpty) {
      return "empty";
    }

    inventoryData.sort((a, b) {
      final dateA = a['earliestExpirationDate'] ?? '';
      final dateB = b['earliestExpirationDate'] ?? '';
      return dateA.compareTo(dateB);
    });

    // On prend les 2 ingrédients les plus urgents
    final item1 = inventoryData[0]['canonicalName'] ?? "item1";
    final item2 = inventoryData.length > 1
        ? (inventoryData[1]['canonicalName'] ?? "item2")
        : item1;

    final keys = [item1, item2]..sort();
    return keys.join('_');
  }

  void _triggerRecipeGeneration(BuildContext context) async {
    final hasAccess = await _checkPremiumStatus(context);
    if (!hasAccess) return;
    if (_localRecipeCache.isNotEmpty) {
      print("Local cache is not empty. let's display the next 3 recipes.");
      final recipesToShow = _localRecipeCache.take(3).toList();
      _localRecipeCache.removeRange(0, recipesToShow.length);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => RecipeSuggestionScreen(recipes: recipesToShow),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Finding recipes..."),
            ],
          ),
        ),
      ),
    );

    try {
      final inventoryData = await _getInventoryData();
      if (inventoryData.isEmpty) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre inventaire est vide !')),
        );
        return;
      }

      final String cacheKey = _getCacheKeyFromInventory(inventoryData);
      final String userLanguage = Localizations.localeOf(context).languageCode;
      final functions = FirebaseFunctions.instanceFor(region: "us-central1");
      final callable = functions.httpsCallable('generateRecipes');
      final result = await callable.call({
        'inventory': inventoryData,
        'searchKey': cacheKey,
        'language': userLanguage,
      });

      if (!context.mounted) return;
      Navigator.of(context).pop();

      final data = result.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _localRecipeCache = List<dynamic>.from(data['data']['recipes'] ?? []);
        _localRecipeCache.shuffle();
        if (_localRecipeCache.isEmpty) {
          if (mounted)
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('No recipes found.')));
        } else {
          // Naviguez vers l'écran de suggestions avec TOUTES les recettes
          if (mounted)
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => RecipeSuggestionScreen(
                  recipes: _localRecipeCache, // On passe toute la liste
                ),
              ),
            );
        }
      } else {
        throw Exception("Function failed (success: false)");
      }
    } catch (error) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $error"),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Widget _buildEmptyState({bool isSearch = false}) {
    final l10n = AppLocalizations.of(context)!;
    String image = "assets/images/discu.png";
    if (isSearch) {
      image = "assets/images/discu.png";
    } else if (_selectedLocation == "Congélateur") {
      image = "assets/images/conge.png";
    } else if (_selectedLocation == "Frigo") {
      image = "assets/images/fridge.png";
    } else if (_selectedLocation == "Placard") {
      image = "assets/images/pant.png";
    }

    String title = isSearch
        ? "No results found" // TODO: Traduire
        : l10n.inventoryEmptyTitle;

    String subtitle = isSearch
        ? "Try a different search term."
        : l10n.inventoryEmptySubtitle;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, width: 250, height: 250, fit: BoxFit.contain),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanProductBarcode(BuildContext context) async {
    final hasAccess = await _checkPremiumStatus(context);
    if (!hasAccess) return;

    var barcode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()),
    );

    if (barcode == null || barcode == '-1' || barcode is! String) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 3. Appeler Open Food Facts (API v0 - Plus stable pour la lecture simple)
      // On demande spécifiquement les champs dont on a besoin pour alléger la requête
      final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json?fields=product_name,brands,image_front_small_url,image_front_url,categories_tags,nutriscore_grade',
      );
      print("Appel OFF: $url");
      print("barcodebarcodebarcodebarcode: $barcode");

      final response = await http.get(url);

      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("JSON : $jsonResponse");

        if (jsonResponse['status'] == 1) {
          final product = jsonResponse['product'];

          final String name =
              product['product_name'] ?? 'Produit inconnu'; // TODO: Traduire
          final String brands = product['brands'] ?? '';
          final String fullName = brands.isNotEmpty ? "$name ($brands)" : name;

          final String? imageUrl =
              product['image_front_small_url'] ?? product['image_front_url'];
          final String? nutriscore = product['nutriscore_grade'];

          final functions = FirebaseFunctions.instanceFor(
            region: "us-central1",
          );
          final callable = functions.httpsCallable('getSmartItemData');
          final result = await callable.call({'productName': name});
          final Map<String, dynamic> itemData = Map<String, dynamic>.from(
            result.data['item'],
          );

          final String cleanedName = itemData['cleanedName'] ?? name;
          final String canonicalName = itemData['canonicalName'] ?? name;
          final int dvm = itemData['dvm'] ?? 7;
          final String category = itemData['category'] ?? 'Other';
          final String location = itemData['location'] ?? 'Frigo';
          final int quantity = itemData['quantity'] ?? 1;

          await _inventoryService.upsertItemToInventory(
            name: fullName,
            canonicalName: canonicalName,
            cleanedName: cleanedName,
            quantity: quantity,
            dvm: dvm,
            category: category,
            location: location,
            imageUrl: imageUrl,
            nutriscore: nutriscore,
            // storeName: '',
            // brands: '',
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$fullName ajouté !"),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Produit non trouvé dans Open Food Facts."),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        throw Exception("Erreur serveur OFF (${response.statusCode})");
      }
    } catch (e) {
      // Fermer le dialogue si encore ouvert
      // (Note: Navigator.pop a déjà été appelé plus haut, mais par sécurité en cas d'exception avant)
      // if (Navigator.canPop(context)) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Petit helper pour deviner la catégorie depuis les tags OFF (Optionnel)
  String _mapOffCategory(List<dynamic>? tags) {
    if (tags == null) return 'Other';
    final str = tags.join(' ').toLowerCase();
    if (str.contains('dairy') || str.contains('lait') || str.contains('cheese'))
      return 'Dairy';
    if (str.contains('meat') || str.contains('viande') || str.contains('fish'))
      return 'Meat';
    if (str.contains('fruit')) return 'Fruit';
    if (str.contains('vegetable') || str.contains('plant')) return 'Vegetable';
    if (str.contains('beverage') || str.contains('boisson')) return 'Beverage';
    return 'Pantry';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot?>(
          stream: HouseholdService().getCurrentHouseholdStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              return Text(data['name'] ?? l10n.inventoryTab);
            }
            return Text(l10n.inventoryTitle);
          },
        ),
        actions: [
          IconButton(
            color: Colors.yellow[700],
            icon: const Icon(Icons.lightbulb),
            tooltip: l10n.suggestRecipeTooltip,
            onPressed: () {
              _triggerRecipeGeneration(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(text: l10n.inventoryTabAll),
            Tab(text: l10n.inventoryTabFridge),
            Tab(text: l10n.inventoryTabPantry),
            Tab(text: l10n.inventoryTabFreezer),
          ],
          indicatorColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Theme.of(context).disabledColor,
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.inventorySearchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[200]
                    : Colors.grey[800],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _inventoryService.getInventoryStream(
                location: _selectedLocation,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("An error occurred."));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final itemNames = snapshot.data!.docs.map((item) {
                    final data = item.data() as Map<String, dynamic>;
                    return data['canonicalName'] as String? ??
                        data['name'] as String;
                  }).toList();
                  context.read<InventoryProvider>().updateInventory(itemNames);
                });

                var items = snapshot.data!.docs;

                if (_searchQuery.isNotEmpty) {
                  items = items.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final String name = (data['name'] as String? ?? '')
                        .toLowerCase();
                    final String canonicalName =
                        (data['canonicalName'] as String? ?? '').toLowerCase();
                    final String cleanedName =
                        (data['cleanedName'] as String? ?? '').toLowerCase();
                    final String category = (data['category'] as String? ?? '')
                        .toLowerCase();

                    return name.contains(_searchQuery) ||
                        canonicalName.contains(_searchQuery) ||
                        cleanedName.contains(_searchQuery) ||
                        category.contains(_searchQuery);
                  }).toList();
                }

                if (items.isEmpty) {
                  return _buildEmptyState(isSearch: true);
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, top: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildItemCard(item);
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showImageSourceDialog(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Helper pour générer un avatar avec initiales et couleur unique
  Widget _buildInitialsAvatar(String name) {
    String initials = "";
    if (name.isNotEmpty) {
      final trimmed = name.trim();
      if (trimmed.length >= 2) {
        initials = trimmed.substring(0, 2).toUpperCase();
      } else if (trimmed.isNotEmpty) {
        initials = trimmed.substring(0, 1).toUpperCase();
      } else {
        initials = "?";
      }
    }

    // 2. Générer une couleur unique basée sur le nom (Hashcode)
    // On utilise une liste de couleurs "FrigoZen" douces
    final List<Color> colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.blueGrey,
    ];

    // L'opérateur % assure qu'on reste toujours dans la limite de la liste
    final color = colors[name.hashCode.abs() % colors.length];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Fond pastel
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color, // Texte de la couleur vive
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(QueryDocumentSnapshot item) {
    final data = item.data() as Map<String, dynamic>;

    // DONNÉES
    final String name = data['name'] ?? 'Produit inconnu';
    // On préfère le nom nettoyé s'il existe, sinon le nom brut
    final String displayTitle = data['cleanedName'] ?? name;

    final int itemQuantity = data["totalQuantity"] ?? 1;
    final Timestamp? expirationDate = data['earliestExpirationDate'];
    final List<dynamic> batchesData = data['batches'] ?? [];

    // CORRECTION LECTURE DONNÉES (Priorité : Racine > Premier Lot)
    final String? imageUrl =
        data['imageUrl'] ??
        (batchesData.isNotEmpty ? batchesData[0]['imageUrl'] : null);

    final String? nutriscore =
        data['nutriscore'] ??
        (batchesData.isNotEmpty ? batchesData[0]['nutriscore'] : null);

    // CALCULS
    final status = _getExpirationStatus(expirationDate);
    final statusText = status['text'] as String;
    final statusColor = status['color'] as Color;
    final bool isLoading = _loadingItems.contains(item.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) =>
              _inventoryService.removeItemFromInventory(item.id),
          background: Container(
            color: const Color(0xFFE57373),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (ctx) => EditBatchesSheet(
                  docId: item.id,
                  itemName: displayTitle,
                  batches: batchesData,
                  service: _inventoryService,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, error, stackTrace) =>
                                    _buildInitialsAvatar(name),
                              )
                            : _buildInitialsAvatar(name),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // --- 2. INFORMATIONS ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Nom du produit
                        Text(
                          displayTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Statut d'expiration (Seul sur sa ligne, plus propre)
                        if (statusText.isNotEmpty)
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // --- 3. CONTRÔLES QUANTITÉ ---
                  isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Container(
                          height: 36, // Un peu plus compact
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  size: 16,
                                ), // Icône plus fine
                                color: Colors.grey[700],
                                onPressed: () =>
                                    _decrementItem(item.id, itemQuantity),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  '$itemQuantity',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () =>
                                    _incrementItem(item.id, itemQuantity),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
