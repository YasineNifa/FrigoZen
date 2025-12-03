import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/inventory/add_item_sheet.dart';
import 'package:frigo_zen/services/ocr_service.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/screens/core/premium_guard.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:frigo_zen/services/inventory_service.dart';
import 'package:image_picker/image_picker.dart';

class ScanOptionsSheet extends StatefulWidget {
  final BuildContext parentContext;

  const ScanOptionsSheet({super.key, required this.parentContext});

  @override
  State<ScanOptionsSheet> createState() => _ScanOptionsSheetState();
}

class _ScanOptionsSheetState extends State<ScanOptionsSheet> {


  Future<void> _scanProductBarcode(BuildContext context) async {
    final hasAccess = await PremiumGuard.checkPremiumStatus(context);
    if (!hasAccess) return;
    if (!context.mounted) return;

    var barcode = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: BarcodeAppBar(
        appBarTitle: AppLocalizations.of(context)!.scanBarcodeTitle,
        centerTitle: false,
        enableBackButton: true,
        backButtonIcon: const Icon(Icons.arrow_back_ios),
      ),
      isShowFlashIcon: true,
      delayMillis: 2000,
      cameraFace: CameraFace.back,
    );

    if (!context.mounted) return;

    if (barcode == '-1') return;

    if (!context.mounted) return;
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

      if (!context.mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 1) {
          final product = jsonResponse['product'];
          final productName = product['product_name'] ?? AppLocalizations.of(context)!.productUnknown;
          final brands = product['brands'] ?? '';
          final nutriscore = product['nutriscore_grade'] ?? '';
          final imageUrl = product['image_front_url'] ?? product['image_url'];
          
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

          final String fullName = brands.isNotEmpty ? "$productName ($brands)" : productName;

          if (mounted) {
            // _showAddProductDialog( // This method is not defined in the provided context.
            //   context, 
            //   barcode: barcode, 
            //   name: productName,
            //   brands: brands,
            //   nutriscore: nutriscore,
            //   storeName: "Scan", // Default store for now
            //   imageUrl: imageUrl,
            //   images: images,
            // );
          }
          final functions =
              FirebaseFunctions.instanceFor(region: "us-central1");
          final callable = functions.httpsCallable('getSmartItemData');
          final result = await callable.call({'productName': productName});
          final Map<String, dynamic> itemData =
              Map<String, dynamic>.from(result.data['item']);

          final String cleanedName = itemData['cleanedName'] ?? productName;
          final String canonicalName = itemData['canonicalName'] ?? productName;
          final int dvm = itemData['dvm'] ?? 7;
          final String category = itemData['category'] ?? 'Other';
          final String location = itemData['location'] ?? 'Frigo';
          final int quantity = itemData['quantity'] ?? 1;

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
            images: images,
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.productAdded(fullName)),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.productNotFoundOFF),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        throw Exception(AppLocalizations.of(context)!.serverErrorOFF(response.statusCode));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: Text(
          l10n.proBadge,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return SafeArea(
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
              final hasAccess = await PremiumGuard.checkPremiumStatus(context);
              if (!hasAccess) return;
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ocrService.pickAndProcessReceipt(widget.parentContext, ImageSource.camera);
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
                Text(l10n.scanBarcodeTitle),
                if (!context.read<RevenueProvider>().isPro) buildProBadge(),
              ],
            ),
            trailing: !context.read<RevenueProvider>().isPro
                ? const Icon(Icons.lock_outline, color: Colors.grey)
                : null,
            onTap: () {
              Navigator.of(context).pop();
              _scanProductBarcode(widget.parentContext);
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
              final hasAccess = await PremiumGuard.checkPremiumStatus(context);
              if (!hasAccess) return;
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ocrService.pickAndProcessReceipt(widget.parentContext, ImageSource.gallery);
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
              Navigator.of(context).pop();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (ctx) => const AddItemSheet(),
              );
            },
          ),
        ],
      ),
    );
  }
}
