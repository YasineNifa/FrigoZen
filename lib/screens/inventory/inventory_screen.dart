import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/recipes/recipe_suggestion_screen.dart';
import 'package:frigo_zen/services/inventory_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/screens/inventory/add_item_sheet.dart';
import 'package:frigo_zen/services/ocr_service.dart';

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

  void _showImageSourceDialog(BuildContext context) {
    final OcrService ocrService = OcrService();

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
              title: const Text('Scan a receipt with camera'),
              onTap: () {
                Navigator.of(ctx).pop();
                ocrService.pickAndProcessReceipt(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 165, 214, 167),
                child: Icon(
                  Icons.photo_library,
                  color: Color.fromARGB(255, 32, 32, 32),
                ),
              ),
              title: const Text('Select a receipt from gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                ocrService.pickAndProcessReceipt(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 165, 214, 167),
                child: Icon(Icons.add, color: Color.fromARGB(255, 32, 32, 32)),
              ),
              title: const Text('Add manually'),
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

  // Groups items by category AND filters by search query
  Map<String, List<QueryDocumentSnapshot>> _groupItems(
    List<QueryDocumentSnapshot> items,
  ) {
    final Map<String, List<QueryDocumentSnapshot>> groupedItems = {};

    for (final item in items) {
      final data = item.data() as Map<String, dynamic>;

      // Client-side search filter
      final itemName = (data['name'] as String? ?? 'Unnamed Item')
          .toLowerCase();
      if (_searchQuery.isNotEmpty && !itemName.contains(_searchQuery)) {
        continue;
      }

      final category = data['category'] as String? ?? 'Other';

      if (groupedItems[category] == null) {
        groupedItems[category] = [];
      }
      groupedItems[category]!.add(item);
    }
    return groupedItems;
  }

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'Dairy':
        return Icons.icecream_outlined;
      case 'Vegetable':
        return Icons.grass_outlined;
      case 'Fruit':
        return Icons.apple_outlined;
      case 'Meat':
        return Icons.kebab_dining_outlined;
      case 'Pantry':
        return Icons.store_mall_directory_outlined;
      case 'Beverage':
        return Icons.local_bar_outlined;
      case 'Congélateur':
        return Icons.ac_unit;
      default:
        return Icons.takeout_dining_outlined;
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

  List<dynamic> _localRecipeCache = [];
  void _triggerRecipeGeneration(BuildContext context) async {
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

      final functions = FirebaseFunctions.instanceFor(region: "us-central1");
      final callable = functions.httpsCallable('generateRecipes');
      final result = await callable.call({
        'inventory': inventoryData,
        'searchKey': cacheKey,
        'forceNew': false,
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
        ? "No results found"
        : "Your ${_selectedLocation.toLowerCase()} is empty";

    String subtitle = isSearch
        ? "Try a different search term."
        : "Tap the + button to add an item or scan a receipt.";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Inventory'),
        centerTitle: true,
        actions: [
          // TODO: Implement notifications screen
          // IconButton(
          //   icon: const Icon(Icons.notifications_outlined),
          //   onPressed: () { /* Open Notifications */ },
          // ),
          // Scan button (your existing logic)
          // IconButton(
          //   icon: const Icon(Icons.receipt_long),
          //   tooltip: 'Scan Receipt',
          //   onPressed: () {
          //     _showImageSourceDialog(context);
          //   },
          // ),
          IconButton(
            color: Colors.yellow[700],
            icon: const Icon(Icons.lightbulb),
            tooltip: 'Suggest a recipe',
            onPressed: () {
              _triggerRecipeGeneration(context);
            },
          ),
        ],
        // 13. The Tabs from your design
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tout'),
            Tab(text: 'Frigo'),
            Tab(text: 'Placard'),
            Tab(text: 'Congélateur'),
          ],
          indicatorColor: Colors.green[400],
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for an item...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                // Use platform-adaptive colors
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

                final groupedItems = _groupItems(snapshot.data!.docs);

                if (groupedItems.isEmpty) {
                  return _buildEmptyState(isSearch: true);
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: groupedItems.keys.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final category = groupedItems.keys.elementAt(index);
                    final itemsInCategory = groupedItems[category]!;
                    return _buildCategorySection(category, itemsInCategory);
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
        backgroundColor: Colors.green[400],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategorySection(
    String category,
    List<QueryDocumentSnapshot> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Title (e.g., "Légumes")
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
          child: Text(
            category, // TODO: Translate this name (e.g., "Dairy" -> "Produits laitiers")
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // List of items in this category
        ListView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildItemCard(item); // Call the item card widget
          },
        ),
      ],
    );
  }

  Widget _buildItemCard(QueryDocumentSnapshot item) {
    final data = item.data() as Map<String, dynamic>;
    final String itemName = data['name'] ?? 'Unnamed Item';
    final String canonicalName = data['canonicalName'] ?? itemName;
    final int itemQuantity = data["totalQuantity"] ?? 1;
    final Timestamp? expirationDate = data['earliestExpirationDate'];

    final status = _getExpirationStatus(expirationDate);
    final statusText = status['text'] as String;
    final statusColor = status['color'] as Color;
    final bool isLoading = _loadingItems.contains(item.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 0,
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
              leading: CircleAvatar(
                backgroundColor: Colors.green[50],
                child: Icon(
                  _getIconForCategory(data['category']),
                  color: Colors.green[800],
                ),
              ),

              title: Text(
                itemName,
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
