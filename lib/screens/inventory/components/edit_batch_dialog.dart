import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:frigo_zen/models/batch.dart';
import 'package:frigo_zen/theme/app_theme.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/services/open_food_facts_service.dart';

class EditBatchDialog extends StatefulWidget {
  final Batch batch;
  final Function(Batch) onSave;

  const EditBatchDialog({
    super.key,
    required this.batch,
    required this.onSave,
  });

  @override
  State<EditBatchDialog> createState() => _EditBatchDialogState();
}

class _EditBatchDialogState extends State<EditBatchDialog> {
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _storeController;
  late int _quantity;
  late DateTime _expirationDate;
  String? _nutriscore;
  String? _imageUrl;
  Map<String, String>? _images;

  final List<String> _nutriscoreOptions = ['A', 'B', 'C', 'D', 'E'];
  bool _isLoading = false;
  final OpenFoodFactsService _offService = OpenFoodFactsService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.batch.name ?? '');
    _brandController = TextEditingController(text: widget.batch.brands ?? '');
    _storeController = TextEditingController(text: widget.batch.storeName ?? '');
    _quantity = widget.batch.quantity;
    _expirationDate = widget.batch.expirationDate;
    _nutriscore = widget.batch.nutriscore?.toUpperCase();
    _imageUrl = widget.batch.imageUrl;
    _images = widget.batch.images;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _storeController.dispose();
    super.dispose();
  }

  Future<void> _scanProduct() async {
    final l10n = AppLocalizations.of(context)!;
    
    // 1. Scan Barcode
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );

    if (res is String && res != '-1') {
      setState(() => _isLoading = true);
      
      try {
        // 2. Fetch from Open Food Facts using Service
        final product = await _offService.fetchProduct(res);

        if (product != null) {
            // 3. Extract Info
            final String? productName = product['product_name'] ?? product['product_name_fr'];
            final String? brands = product['brands'];
            final String? nutriscore = product['nutriscore_grade'];
            final String? stores = product['stores'];
            final String? imageUrl = product['image_front_url'] ?? product['image_url'];
            
            // Capture all image variants
            final Map<String, String> images = {};
            final imageKeys = [
              "image_front_small_url",
              "image_front_thumb_url",
              "image_front_url",
              "image_nutrition_small_url",
              "image_nutrition_thumb_url",
              "image_nutrition_url",
              "image_small_url",
              "image_thumb_url",
              "image_url"
            ];
            for (var key in imageKeys) {
               if (product[key] != null && product[key].toString().isNotEmpty) {
                 images[key] = product[key].toString();
               }
            }

            // 4. Update Fields if empty or user wants to overwrite
            if (productName != null && productName.isNotEmpty) {
              _nameController.text = productName;
            }
            if (brands != null && brands.isNotEmpty) {
              _brandController.text = brands;
            }
            if (stores != null && stores.isNotEmpty) {
              _storeController.text = stores;
            }
            if (nutriscore != null && _nutriscoreOptions.contains(nutriscore.toUpperCase())) {
              setState(() {
                _nutriscore = nutriscore.toUpperCase();
              });
            }
            if (imageUrl != null && imageUrl.isNotEmpty) {
               setState(() {
                 _imageUrl = imageUrl;
                 _images = images;
               });
            }
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(l10n.productAdded(productName ?? 'Product')), backgroundColor: Colors.green),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _expirationDate = picked);
    }
  }

  void _save() {
    final updatedBatch = widget.batch.copyWith(
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      brands: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      storeName: _storeController.text.trim().isEmpty ? null : _storeController.text.trim(),
      quantity: _quantity,
      expirationDate: _expirationDate,
      nutriscore: _nutriscore,
      imageUrl: _imageUrl,
      images: _images,
    );
    widget.onSave(updatedBatch);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Flexible(child: Text(l10n.editBatchTitle)),
           IconButton(
             icon: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Icon(Icons.qr_code_scanner),
             onPressed: _isLoading ? null : _scanProduct,
             tooltip: l10n.scanBarcodeTitle,
           )
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.specificNameLabel,
                hintText: l10n.specificNameHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Marque
            TextField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: l10n.brandLabel,
                hintText: l10n.brandHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.branding_watermark_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Magasin
            TextField(
              controller: _storeController,
              decoration: InputDecoration(
                labelText: l10n.storeLabel,
                hintText: l10n.storeHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.store_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Nutri-Score
            InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.nutriScoreLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.health_and_safety_outlined),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _nutriscoreOptions.contains(_nutriscore) ? _nutriscore : null,
                  isDense: true,
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.nutriScoreUndefined)),
                    ..._nutriscoreOptions.map((score) => DropdownMenuItem(
                          value: score,
                          child: Text("${l10n.nutriScoreLabel} $score"),
                        )),
                  ],
                  onChanged: (value) => setState(() => _nutriscore = value),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Date d'expiration
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.expirationDateLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            _formatDate(_expirationDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quantité
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.quantityLabel,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.quantityControlBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelBtn),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.saveBtn),
        ),
      ],
    );
  }
}
