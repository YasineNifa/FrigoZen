import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/inventory/add_item_sheet.dart';
import 'package:frigo_zen/components/scan_tip_card.dart';
import 'package:frigo_zen/services/ocr_service.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/screens/core/premium_guard.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:frigo_zen/services/inventory_service.dart';
import 'package:frigo_zen/services/open_food_facts_service.dart';
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
    if (barcode == null) return;
    
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final product = await OpenFoodFactsService().getScannedProduct(barcode!);
      
      if (!context.mounted) return;
      Navigator.pop(context); // close loader

      if (product != null) {
          final String fullName = product.brands.isNotEmpty ? "${product.name} (${product.brands})" : product.name;

          if (mounted) {
            // ...
          }

          // Use data directly from product
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
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // close loader if error
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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ScanTipCard(),
          ),
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
