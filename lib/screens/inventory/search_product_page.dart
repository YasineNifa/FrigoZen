import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frigo_zen/services/open_food_facts_service.dart';
import 'package:frigo_zen/models/scanned_product.dart';
import 'package:frigo_zen/services/inventory_service.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class SearchProductPage extends StatefulWidget {
  const SearchProductPage({super.key});

  @override
  State<SearchProductPage> createState() => _SearchProductPageState();
}

class _SearchProductPageState extends State<SearchProductPage> {
  final _searchController = TextEditingController();
  final OpenFoodFactsService _offService = OpenFoodFactsService();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, String>> _products = [];
  final Set<String> _selectedCodes = {};
  
  // Filtering & Pagination
  List<String> _categories = [];
  String? _selectedCategory;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true; // For infinite scroll

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initial Load (Catalog Mode)
    _performSearch(""); 
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && 
        !_isLoading && 
        _hasMore) {
      _loadMore();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Reset list on new search
      setState(() {
        _products.clear();
        _currentPage = 1;
        _hasMore = true;
        _categories.clear();
        _selectedCategory = null;
        // NOTE: We DO NOT clear _selectedCodes here, to persist selections!
      });
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);

    try {
      final results = await _offService.searchProducts(query, page: _currentPage);
      
      if (results.isEmpty) {
        if (mounted) setState(() => _hasMore = false);
      } else {
        if (mounted) {
          _extractCategories(results);
          setState(() {
             _products.addAll(results);
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    _currentPage++;
    await _performSearch(_searchController.text);
  }

  void _extractCategories(List<Map<String, String>> newProducts) {
    final Set<String> foundCategories = Set.from(_categories);
    for (var p in newProducts) {
      if (p['categories'] != null && p['categories']!.isNotEmpty) {
        final cats = p['categories']!.split(',');
        for (var c in cats) {
          final trimmed = c.trim();
          if (trimmed.isNotEmpty && !trimmed.startsWith('en:')) {
             foundCategories.add(trimmed);
             break; 
          }
        }
      }
    }
    setState(() {
      _categories = foundCategories.take(12).toList();
    });
  }

  void _filterResults(String? category) {
    setState(() {
      _selectedCategory = category;
      // Note: Client-side filtering on the CURRENT list. 
      // Ideally, API filtering is better for infinite scroll, but mixing Search query + Category filter in OFF is complex.
      // For now, we filter the displayed list.
    });
  }

  List<Map<String, String>> get _displayedProducts {
    if (_selectedCategory == null) return _products;
    return _products.where((p) {
       final cats = p['categories'] ?? '';
       return cats.contains(_selectedCategory!);
    }).toList();
  }

  void _toggleSelection(String barcode) {
    setState(() {
      if (_selectedCodes.contains(barcode)) {
        _selectedCodes.remove(barcode);
      } else {
        _selectedCodes.add(barcode);
      }
    });
  }

  Future<void> _addSelectedItems() async {
    if (_selectedCodes.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    int addedCount = 0;
    int failedCount = 0;

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.searchProductAdding),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      for (final code in _selectedCodes) {
         try {
           final ScannedProduct? product = await _offService.getScannedProduct(code);
           if (product != null) {
              final String fullName = product.brands.isNotEmpty ? "${product.name} (${product.brands})" : product.name;
              await InventoryService().upsertItemToInventory(
                name: fullName,
                canonicalName: product.canonicalName,
                cleanedName: product.cleanedName,
                quantity: product.quantity,
                dvm: product.dvm,
                category: product.category,
                location: product.location,
                imageUrl: product.imageUrl,
                nutriscore: product.nutriscore ?? '',
                images: product.images,
              );
              addedCount++;
           } else {
             failedCount++;
           }
         } catch (e) {
           failedCount++;
         }
      }
    } finally {
      if (mounted) {
        Navigator.pop(context); // Pop dialog
        Navigator.pop(context); // Pop Page
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failedCount > 0 
                ? l10n.searchProductError(addedCount, failedCount)
                : l10n.searchProductSuccess(addedCount)),
            backgroundColor: failedCount > 0 ? Colors.orange : Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayed = _displayedProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchProductTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.searchProductHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _isLoading && _products.isEmpty
                    ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                    : null
              ),
              onChanged: _onSearchChanged,
              // Removed autofocus to let the catalog shine first
            ),
          ),
          // Categories Filter
          if (_categories.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FilterChip(
                    label: Text(l10n.searchProductFilterAll),
                    selected: _selectedCategory == null,
                    onSelected: (bool selected) {
                      if (selected) _filterResults(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ..._categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (bool selected) {
                           _filterResults(selected ? category : null);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: displayed.isEmpty && !_isLoading
                ? Center(
                    child: Text(
                      l10n.searchProductNoResults,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 80),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75, // Taller for better visual
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: displayed.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == displayed.length) {
                         return const Center(child: CircularProgressIndicator());
                      }
                      
                      final product = displayed[index];
                      final String code = product['code']!;
                      final bool isSelected = _selectedCodes.contains(code);
                      final String image = product['image'] ?? '';
                      
                      return GestureDetector(
                        onTap: () => _toggleSelection(code),
                        child: Card(
                          elevation: isSelected ? 4 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isSelected 
                                ? const BorderSide(color: Colors.green, width: 2) 
                                : BorderSide.none,
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      child: image.isNotEmpty
                                          ? Image.network(image, fit: BoxFit.contain)
                                          : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name']!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        if (product['brand']!.isNotEmpty)
                                          Text(
                                            product['brand']!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (isSelected)
                                const Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.green,
                                    radius: 12,
                                    child: Icon(Icons.check, size: 16, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _selectedCodes.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _addSelectedItems,
              backgroundColor: Colors.green,
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
              label: Text(
                l10n.searchProductAddBtn(_selectedCodes.length),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}
