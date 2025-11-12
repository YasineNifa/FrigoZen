// lib/screens/inventory/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/screens/inventory/add_item_sheet.dart';
import 'package:frigo_zen/services/ocr_service.dart';

// 1. Converted to StatefulWidget to manage Tabs, Search, and Loading
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

// 2. Added "with SingleTickerProviderStateMixin" for the TabController
class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
      
  // 3. Controllers for UI state
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // 4. State variables
  String _selectedLocation = "Tout"; // The active tab
  String _searchQuery = ""; // The active search
  final Set<String> _loadingItems = {}; // Your existing loading set, now part of the state

  @override
  void initState() {
    super.initState();
    // 5. Initialize controllers
    _tabController = TabController(length: 4, vsync: this);

    // Add listeners to rebuild the UI on change
    _tabController.addListener(_handleTabSelection);
    _searchController.addListener(_handleSearch);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 6. State update handlers
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      switch (_tabController.index) {
        case 0: _selectedLocation = "Tout"; break;
        case 1: _selectedLocation = "Frigo"; break;
        case 2: _selectedLocation = "Placard"; break;
        case 3: _selectedLocation = "Congélateur"; break;
      }
      // Rebuilds the StreamBuilder with the new location
    });
  }

  void _handleSearch() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
      // Rebuilds the StreamBuilder by applying the search query in the _groupItems function
    });
  }

  // 7. Modified Stream function to filter by Tab (location)
  Stream<QuerySnapshot> _getInventoryStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    // Base query
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('inventory');

    // 8. Apply the Tab filter (Firestore query)
    if (_selectedLocation != "Tout") {
      query = query.where('location', isEqualTo: _selectedLocation);
    }
    
    // We will order by name to make grouping easier
    // The search filter itself will be applied client-side
    query = query.orderBy('name');

    return query.snapshots();
  }

  // --- Your existing data functions (unchanged, just moved) ---

  // Delete an item from the inventory
  void _deleteItem(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('inventory')
        .doc(docId)
        .delete();
  }

  void _incrementItem(String docId, int currentQuantity) async {
    setState(() {
      _loadingItems.add(docId);
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('inventory')
        .doc(docId)
        .update({'quantity': currentQuantity + 1});

    if (mounted) {
      setState(() {
        _loadingItems.remove(docId);
      });
    }
  }

  void _decrementItem(String docId, int currentQuantity) async {
    setState(() {
      _loadingItems.add(docId);
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (currentQuantity <= 1) {
      _deleteItem(docId); // Use await here
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('inventory')
          .doc(docId)
          .update({'quantity': currentQuantity - 1});
    }
    if (mounted) {
      setState(() {
        _loadingItems.remove(docId);
      });
    }
  }

  // Your existing OCR/Image Dialog function (unchanged)
  void _showImageSourceDialog(BuildContext context) {
    final OcrService ocrService = OcrService();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(child: Wrap(
        children: [
          // TODO: Uncomment the following lines to enable camera and gallery options
          /*
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a Photo'),
            onTap: () {
              Navigator.of(ctx).pop();
              // This function call will need to be updated when the hack is removed
              // ocrService.pickAndProcessReceipt(context, ImageSource.camera); 
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.of(ctx).pop();
              // This function call will need to be updated when the hack is removed
              // ocrService.pickAndProcessReceipt(context, ImageSource.gallery);
            },
          ),
          */
          // TODO: comment the following lines to enable camera and gallery options
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Use a testing Receipts'),
              onTap: () {
                Navigator.of(ctx).pop();
                final String fullBase64String = "iVBORw0KGgoAAAAN"; // Your test string
                final String base64Image = fullBase64String.split(',').last;
                ocrService.pickAndProcessReceipt(context, base64Image);
              },
            )
        ]
      ))
    );
  }

  // --- New UI Helper Functions ---

  // 9. Calculates the expiration status text and color
  Map<String, dynamic> _getExpirationStatus(Timestamp? expirationDate) {
    if (expirationDate == null) {
      return {'text': 'Unknown', 'color': Colors.grey};
    }

    final now = DateTime.now();
    // Use `toDate()` to convert Timestamp to DateTime
    final expiry = expirationDate.toDate(); 
    
    // Calculate difference in days, ignoring time of day
    final difference = expiry.difference(DateTime(now.year, now.month, now.day)).inDays;

    if (difference < 0) {
      return {'text': 'Expired', 'color': Colors.red[700]!};
    } else if (difference == 0) {
      return {'text': 'Expires today', 'color': Colors.red[700]!};
    } else if (difference <= 3) {
      return {'text': 'Expires soon', 'color': Colors.orange[700]!};
    } else if (difference <= 7) {
      return {'text': 'Expires in $difference days', 'color': Colors.green[700]!};
    } else {
      return {'text': 'Fresh', 'color': Colors.grey[700]!}; // Changed from "OK"
    }
  }

  // 10. Groups items by category AND filters by search query
  Map<String, List<QueryDocumentSnapshot>> _groupItems(List<QueryDocumentSnapshot> items) {
    final Map<String, List<QueryDocumentSnapshot>> groupedItems = {};

    for (final item in items) {
      final data = item.data() as Map<String, dynamic>;
      
      // Client-side search filter
      final itemName = (data['name'] as String? ?? 'Unnamed Item').toLowerCase();
      if (_searchQuery.isNotEmpty && !itemName.contains(_searchQuery)) {
        continue; // Skip item if it doesn't match search
      }
      
      final category = data['category'] as String? ?? 'Other';
      
      if (groupedItems[category] == null) {
        groupedItems[category] = [];
      }
      groupedItems[category]!.add(item);
    }
    return groupedItems;
  }
  
  // 11. Helper to get an icon for each category
  IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'Dairy': return Icons.icecream_outlined;
      case 'Vegetable': return Icons.grass_outlined;
      case 'Fruit': return Icons.apple_outlined;
      case 'Meat': return Icons.kebab_dining_outlined;
      case 'Pantry': return Icons.store_mall_directory_outlined;
      case 'Beverage': return Icons.local_bar_outlined;
      case 'Congélateur': return Icons.ac_unit; // Freezer
      default: return Icons.takeout_dining_outlined; // Other
    }
  }

  // 12. New widget for the "Empty State" from your design
  Widget _buildEmptyState({bool isSearch = false}) {
    // Selects the icon based on context
    IconData icon = Icons.eco_outlined; // Default
    if (isSearch) {
      icon = Icons.search_off;
    } else if (_selectedLocation == "Congélateur") {
      icon = Icons.ac_unit_outlined;
    } else if (_selectedLocation == "Frigo") {
      icon = Icons.kitchen_outlined;
    } else if (_selectedLocation == "Placard") {
      icon = Icons.store_mall_directory_outlined;
    }

    String title = isSearch 
      ? "No results found" 
      : "Your ${_selectedLocation.toLowerCase()} is empty";
      
    String subtitle = isSearch
      ? "Try a different search term."
      : "Tap the + button to add an item or scan a receipt.";

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
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

  // ---------------------------------
  // THE NEW BUILD() METHOD
  // ---------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Inventory'),
        centerTitle: true,
        // TODO: Implement navigation drawer
        // leading: IconButton(
        //   icon: const Icon(Icons.menu),
        //   onPressed: () { /* Open Drawer */ },
        // ),
        actions: [
          // TODO: Implement notifications screen
          // IconButton(
          //   icon: const Icon(Icons.notifications_outlined),
          //   onPressed: () { /* Open Notifications */ },
          // ),
          // Scan button (your existing logic)
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Scan Receipt',
            onPressed: () {
              _showImageSourceDialog(context);
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
        ),
      ),

      // 14. The body with Search + List
      body: Column(
        children: [
          // 15. The Search Bar from your design
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

          // 16. The Filtered & Grouped List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getInventoryStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("An error occurred."));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(); // Empty state for the current tab
                }

                // Update the Provider (your existing logic)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final itemNames = snapshot.data!.docs.map((item) {
                    final data = item.data() as Map<String, dynamic>;
                    return data['name'] as String;
                  }).toList();
                  context.read<InventoryProvider>().updateInventory(itemNames);
                });
                
                // 17. Group items by Category AND filter by Search
                final groupedItems = _groupItems(snapshot.data!.docs);
                
                if (groupedItems.isEmpty) {
                  // If search returns no results
                  return _buildEmptyState(isSearch: true);
                }

                // 18. Build the grouped list
                // We use ListView.separated for clean dividers
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80), // Space for FAB
                  itemCount: groupedItems.keys.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1, 
                    indent: 16, 
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final category = groupedItems.keys.elementAt(index);
                    final itemsInCategory = groupedItems[category]!;

                    // Return a full section (Title + Items)
                    return _buildCategorySection(category, itemsInCategory);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // FAB (your existing logic)
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

  // 19. Widget for the Category Section (Title + Items)
  Widget _buildCategorySection(String category, List<QueryDocumentSnapshot> items) {
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

  // 20. Widget for the individual Item Card (New Design)
  Widget _buildItemCard(QueryDocumentSnapshot item) {
    final data = item.data() as Map<String, dynamic>;
    final String itemName = data['name'] ?? 'Unnamed Item';
    final int itemQuantity = data["quantity"] ?? 1;
    final Timestamp? expirationDate = data['expirationDate'];
    
    // Calculate status
    final status = _getExpirationStatus(expirationDate);
    final statusText = status['text'] as String;
    final statusColor = status['color'] as Color;

    final bool isLoading = _loadingItems.contains(item.id);

    // Using a "Card" to match the design
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 0, // Flat design
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.grey[300]!), // Light border
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Dismissible(
            key: Key(item.id),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _deleteItem(item.id),
            background: Container(
              color: Colors.red[700],
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              // Icon from design
              leading: CircleAvatar(
                backgroundColor: Colors.green[50],
                child: Icon(
                  _getIconForCategory(data['category']),
                  color: Colors.green[800],
                ),
              ),
              
              // Title and Expiration
              title: Text(itemName, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                statusText,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),

              // Quantity Counter
              trailing: isLoading
                  ? const SizedBox( // Spinner
                      width: 48, // Match button size
                      height: 48,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          iconSize: 20,
                          onPressed: () => _decrementItem(item.id, itemQuantity),
                        ),
                        Text(
                          itemQuantity.toString(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          iconSize: 20,
                          onPressed: () => _incrementItem(item.id, itemQuantity),
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