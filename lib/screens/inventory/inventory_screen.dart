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
    // Use `toDate()` to convert Timestamp to DateTime
    final expiry = expirationDate.toDate();

    // Calculate difference in days, ignoring time of day
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

  // ---------------------------------------------------------------------------
  // NOUVELLE FONCTION : SCANNER UN PRODUIT (CODE-BARRES)
  // ---------------------------------------------------------------------------
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
      final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v2/product/$barcode',
      );
      print("URL : $url");
      final response = await http.get(url);

      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 1) {
          final product = jsonResponse['product'];

          final String name = product['product_name'] ?? 'Produit inconnu';
          final String brands = product['brands'] ?? '';
          // On combine Marque + Nom pour être précis (ex: "Lait (Candia)")
          final String fullName = brands.isNotEmpty ? "$name ($brands)" : name;

          final String? imageUrl =
              product['image_front_small_url'] ?? product['image_front_url'];
          final String? category = _mapOffCategory(product['categories_tags']);

          // TODO: Must be improved
          await _inventoryService.upsertItemToInventory(
            name: fullName,
            cleanedName: name,
            canonicalName: name,
            quantity: 1,
            category: category,
            location: 'Frigo',
            // On pourrait aussi stocker l'URL de l'image et le Nutri-Score ici
            // si on modifie InventoryService pour les accepter
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
          throw Exception("Produit non trouvé dans la base Open Food Facts.");
        }
      } else {
        throw Exception("Erreur réseau Open Food Facts.");
      }
    } catch (e) {
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
                    final name = (data['name'] as String? ?? '').toLowerCase();
                    return name.contains(_searchQuery);
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

  Widget _buildItemCard(QueryDocumentSnapshot item) {
    final data = item.data() as Map<String, dynamic>;
    final String cleanedName = data['cleanedName'] ?? 'Unnamed Item';
    final int itemQuantity = data["totalQuantity"] ?? 1;
    final Timestamp? expirationDate = data['earliestExpirationDate'];
    final List<dynamic> batchesData = data['batches'] ?? [];

    final status = _getExpirationStatus(expirationDate);
    final statusText = status['text'] as String;
    final statusColor = status['color'] as Color;
    final bool isLoading = _loadingItems.contains(item.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Dismissible(
            key: Key(item.id),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) =>
                _inventoryService.removeItemFromInventory(item.id),
            background: Container(
              color: Colors.red[700],
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (ctx) => EditBatchesSheet(
                    docId: item.id,
                    itemName: cleanedName,
                    batches: batchesData,
                    service: _inventoryService,
                  ),
                );
              },
              title: Text(
                cleanedName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: isLoading
                  ? const SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          iconSize: 20,
                          onPressed: () =>
                              _decrementItem(item.id, itemQuantity),
                        ),
                        Text(
                          itemQuantity.toString(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          iconSize: 20,
                          onPressed: () =>
                              _incrementItem(item.id, itemQuantity),
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
