import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/paywall/modern_paywall_screen.dart';
import 'package:frigo_zen/screens/recipes/recipe_suggestion_screen.dart';
import 'package:frigo_zen/services/inventory_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/main.dart';
import 'package:frigo_zen/screens/inventory/add_item_sheet.dart';
import 'package:frigo_zen/services/ocr_service.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/screens/inventory/components/inventory_header.dart';
import 'package:frigo_zen/screens/inventory/components/inventory_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/repositories/household_repository.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _localRecipeCache = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _searchController.addListener(_handleSearch);
    
    // Initialize ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initViewModel();
    });
  }
  
  Future<void> _initViewModel() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final householdId = await HouseholdRepository().getHouseholdIdForUser(userId);
      if (householdId != null && mounted) {
        context.read<InventoryViewModel>().init(householdId);
      }
    }
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
    final vm = context.read<InventoryViewModel>();
    switch (_tabController.index) {
      case 0:
        vm.setLocation("Tout");
        break;
      case 1:
        vm.setLocation("Frigo");
        break;
      case 2:
        vm.setLocation("Placard");
        break;
      case 3:
        vm.setLocation("Congélateur");
        break;
    }
  }

  void _handleSearch() {
    context.read<InventoryViewModel>().setSearchQuery(_searchController.text.trim());
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
              ),
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

  // TODO: Move this logic to ViewModel or Service
  Future<void> _triggerRecipeGeneration(BuildContext context) async {
    final hasAccess = await _checkPremiumStatus(context);
    if (!hasAccess) return;
    if (_localRecipeCache.isNotEmpty) {
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
      final vm = context.read<InventoryViewModel>();
      final inventoryItems = vm.items;
      
      if (inventoryItems.isEmpty) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre inventaire est vide !')),
        );
        return;
      }

      // Convert items to map for cloud function
      final inventoryData = inventoryItems.map((item) => item.toMap()).toList();

      // Simple cache key generation
      final sortedItems = List.from(inventoryItems)..sort((a, b) => a.earliestExpirationDate.compareTo(b.earliestExpirationDate));
      final item1 = sortedItems[0].canonicalName;
      final item2 = sortedItems.length > 1 ? sortedItems[1].canonicalName : item1;
      final keys = [item1, item2]..sort();
      final String cacheKey = keys.join('_');

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
          if (mounted)
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => RecipeSuggestionScreen(
                  recipes: _localRecipeCache,
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
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json?fields=product_name,brands,image_front_small_url,image_front_url,categories_tags,nutriscore_grade',
      );
      
      final response = await http.get(url);

      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 1) {
          final product = jsonResponse['product'];

          final String name = product['product_name'] ?? 'Produit inconnu';
          final String brands = product['brands'] ?? '';
          final String fullName = brands.isNotEmpty ? "$name ($brands)" : name;

          final String? imageUrl = product['image_front_small_url'] ?? product['image_front_url'];
          final String? nutriscore = product['nutriscore_grade'];

          final functions = FirebaseFunctions.instanceFor(region: "us-central1");
          final callable = functions.httpsCallable('getSmartItemData');
          final result = await callable.call({'productName': name});
          final Map<String, dynamic> itemData = Map<String, dynamic>.from(result.data['item']);

          final String cleanedName = itemData['cleanedName'] ?? name;
          final String canonicalName = itemData['canonicalName'] ?? name;
          final int dvm = itemData['dvm'] ?? 7;
          final String category = itemData['category'] ?? 'Other';
          final String location = itemData['location'] ?? 'Frigo';
          final int quantity = itemData['quantity'] ?? 1;

          // Use legacy service for upsert for now as it handles complex batch logic
          // Ideally this should be moved to VM/Repository
          await InventoryService().upsertItemToInventory(
            name: fullName,
            canonicalName: canonicalName,
            cleanedName: cleanedName,
            quantity: quantity,
            dvm: dvm,
            category: category,
            location: location,
            imageUrl: imageUrl,
            nutriscore: nutriscore,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: InventoryHeader(
        tabController: _tabController,
        onRecipePressed: () => _triggerRecipeGeneration(context),
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
          const Expanded(
            child: InventoryList(),
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
}

