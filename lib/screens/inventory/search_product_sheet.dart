import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frigo_zen/services/open_food_facts_service.dart';
import 'package:frigo_zen/models/scanned_product.dart';
import 'package:frigo_zen/services/inventory_service.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class SearchProductSheet extends StatefulWidget {
  final BuildContext parentContext;

  const SearchProductSheet({super.key, required this.parentContext});

  @override
  State<SearchProductSheet> createState() => _SearchProductSheetState();
}

class _SearchProductSheetState extends State<SearchProductSheet> {
  final _searchController = TextEditingController();
  final OpenFoodFactsService _offService = OpenFoodFactsService();
  List<Map<String, String>> _results = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() => _results = []);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    final results = await _offService.searchProducts(query);
    if (mounted) {
      if (results.isEmpty) {
        // Handle empty results if needed, or just show empty list
      }
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _onProductSelected(String barcode) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Reuse the exact same logic as scanning
      final ScannedProduct? product = await _offService.getScannedProduct(barcode);
      
      if (mounted) {
        Navigator.pop(context); // close loader
      }

      if (product != null && mounted) {
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
          
          if (mounted) {
             ScaffoldMessenger.of(widget.parentContext).showSnackBar( // Use parent context for snackbar visibility
               SnackBar(
                 content: Text(AppLocalizations.of(context)!.productAdded(fullName)),
                 backgroundColor: Colors.green,
               ),
             );
             Navigator.pop(context); // Close the sheet
          }
      } else {
         if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text(AppLocalizations.of(context)!.productNotFoundOFF),
                 backgroundColor: Colors.orange,
               ),
             );
         }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loader
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            Text(
              l10n.searchProductTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.searchProductHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _isLoading 
                    ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                    : null
              ),
              onChanged: _onSearchChanged,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _results.isEmpty 
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty 
                            ? l10n.searchProductEmpty 
                            : l10n.searchProductNoResults,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final product = _results[index];
                        final String image = product['image'] ?? '';
                        
                        return GestureDetector(
                          onTap: () => _onProductSelected(product['code']!),
                          child: Card(
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: image.isNotEmpty
                                      ? Image.network(image, fit: BoxFit.contain)
                                      : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
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
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
