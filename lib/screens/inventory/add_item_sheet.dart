import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:frigo_zen/services/inventory_service.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/components/scan_tip_card.dart';
import 'package:frigo_zen/services/open_food_facts_service.dart';
import 'package:frigo_zen/screens/core/premium_guard.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:provider/provider.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:frigo_zen/models/scanned_product.dart';
import 'package:frigo_zen/models/catalog_item.dart';
import 'package:frigo_zen/repositories/product_catalog_repository.dart';

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final OpenFoodFactsService _offService = OpenFoodFactsService();
  ScannedProduct? _scannedProduct;
  int _quantity = 1;
  bool _isLoading = false;

  void _saveItem() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String userTypedName = _nameController.text.trim();
      final int userQuantity = _quantity;
      try {
        // Default values from Scan (if available)
        String cleanedName = _scannedProduct?.cleanedName ?? userTypedName;
        String canonicalName = _scannedProduct?.canonicalName ?? userTypedName.toLowerCase();
        int dvm = _scannedProduct?.dvm ?? 7; // Default 7 days if no scan
        String category = _scannedProduct?.category ?? 'Other';
        String location = _scannedProduct?.location ?? 'Frigo';
        
        // Only call Smart Data if we DON'T have a scan, or if the name changed significantly
        // For simplicity, let's always call generic smart data for categorization if scan didn't provide good category, 
        // but scan usually provides good category now.
        // Actually, let's rely on Cloud Function ONLY if not scanned, or to refine.
        
        if (_scannedProduct == null) {
            final functions = FirebaseFunctions.instanceFor(region: "us-central1");
            final callable = functions.httpsCallable('getSmartItemData');
            final locale = Localizations.localeOf(context);
            final languageCode = locale.languageCode;
            final result = await callable.call({
              'productName': userTypedName,
              'language': languageCode,
            });
            final Map<String, dynamic> itemData = Map<String, dynamic>.from(
              result.data['item'],
            );
            
            // Overwrite with smart data
            cleanedName = itemData['cleanedName'] ?? userTypedName;
            canonicalName = itemData['canonicalName'] ?? userTypedName.toLowerCase();
            dvm = itemData['dvm'] ?? 7;
            category = itemData['category'] ?? 'Other';
            location = itemData['location'] ?? 'Frigo';
        }

        final inventoryService = InventoryService();

        await inventoryService.upsertItemToInventory(
          name: userTypedName,
          cleanedName: cleanedName,
          canonicalName: canonicalName,
          quantity: userQuantity,
          dvm: dvm,
          category: category,
          location: location,
          imageUrl: _scannedProduct?.imageUrl ?? '',
          nutriscore: _scannedProduct?.nutriscore ?? '',
          storeName: _scannedProduct?.stores ?? '',
          brands: _scannedProduct?.brands ?? '',
          images: _scannedProduct?.images,
        );
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.addItemError(error.toString()))),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _scanProduct() async {
    final l10n = AppLocalizations.of(context)!;
    
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );

    if (res is String && res != '-1') {
      setState(() => _isLoading = true);
      
      try {
        final product = await _offService.getScannedProduct(res);

        if (product != null && product.name.isNotEmpty) {
           _nameController.text = product.name;
           if (mounted) {
              setState(() {
                 _scannedProduct = product;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(l10n.productAdded(product.name)), backgroundColor: Colors.green),
              );
           }
        } else {
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(l10n.productNotFoundOFF), backgroundColor: Colors.orange),
              );
             }
        }
      } catch (e) {
        debugPrint("Scan error: $e");
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(l10n.errorGeneric(e.toString())), backgroundColor: Colors.red),
            );
         }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  final _focusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.addItemTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const ScanTipCard(),
            const SizedBox(height: 16),
            RawAutocomplete<CatalogItem>(
              textEditingController: _nameController,
              focusNode: _focusNode, // Use persistent focus node
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.trim().length < 2) {
                   return const Iterable<CatalogItem>.empty();
                }
                final repo = ProductCatalogRepository();
                return await repo.searchCatalog(textEditingValue.text);
              },
              displayStringForOption: (CatalogItem option) => option.name,
              onSelected: (CatalogItem selection) {
                // Populate _scannedProduct with catalog data (Silver/Gold record)
                setState(() {
                  _scannedProduct = ScannedProduct(
                    name: selection.name,
                    brands: selection.brands ?? '',
                    nutriscore: selection.nutriscore,
                    imageUrl: selection.imageUrl,
                    images: selection.imageUrl != null ? {'front_fr': selection.imageUrl!} : {},
                    cleanedName: selection.name,
                    canonicalName: selection.canonicalName,
                    category: selection.category,
                    location: 'Frigo', // Default
                    dvm: selection.defaultDVM,
                  );
                });
              },
              fieldViewBuilder: (
                  BuildContext context, 
                  TextEditingController fieldTextEditingController, 
                  FocusNode fieldFocusNode, 
                  VoidCallback onFieldSubmitted
              ) {
                  return TextFormField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    decoration: InputDecoration(
                        labelText: l10n.addItemNameLabel,
                        border: const OutlineInputBorder(),
                        suffixIcon: Consumer<RevenueProvider>(
                           builder: (context, revenue, child) {
                             final isPro = revenue.isPro;
                             return Stack(
                               alignment: Alignment.center,
                               children: [
                                 IconButton(
                                   icon: _isLoading 
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                                      : Icon(Icons.qr_code_scanner, color: isPro ? null : Colors.grey),
                                   onPressed: _isLoading ? null : () async {
                                     if (await PremiumGuard.checkPremiumStatus(context)) {
                                       _scanProduct();
                                     }
                                   },
                                 ),
                                 if (!isPro && !_isLoading)
                                   const Positioned(
                                     right: 8,
                                     bottom: 8,
                                     child: Icon(Icons.lock, size: 10, color: Colors.amber),
                                   ),
                               ],
                             );
                           },
                        ),
                    ),
                    validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.addItemNameError;
                        }
                        return null;
                    },
                    onChanged: (val) {
                         // Reset scanned product if user types manually effectively
                         // But we want to keep it if they just selected it.
                         // Actually, standard behavior: if they edit, they might lose specifics.
                         // But let's verify if we need to clear _scannedProduct
                    },
                  );
              },
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<CatalogItem> onSelected, Iterable<CatalogItem> options) {
                 return Align(
                   alignment: Alignment.topLeft,
                   child: Material(
                      elevation: 4.0,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 48, // Match parent padding
                        height: 200,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                             final CatalogItem option = options.elementAt(index);
                             return ListTile(
                               leading: option.imageUrl != null && option.imageUrl!.isNotEmpty
                                   ? SizedBox(
                                       width: 40, 
                                       height: 40,
                                       child: Image.network(option.imageUrl!, errorBuilder: (_,__,___) => const Icon(Icons.fastfood))
                                   )
                                   : const Icon(Icons.fastfood), // Fallback icon
                               title: Text(option.name),
                               subtitle: Text(option.brands ?? option.category),
                               onTap: () {
                                 onSelected(option);
                               },
                             );
                          },
                        ),
                      ),
                   ),
                 );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                ),
                Text(
                  l10n.addItemQuantityLabel(_quantity),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.green,
                ),
                onPressed: _saveItem,
                child: Text(
                  l10n.addItemSaveBtn,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
