import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/validation/validation_screen.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_functions/cloud_functions.dart';

import 'package:flutter/foundation.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

/// OcrService handles all logic related to picking images
/// and processing them via the backend AI.
class OcrService {
  /// This is the main function that handles the entire OCR flow.
  /// It is moved from inventory_screen.dart.
  /// We pass BuildContext here for showing SnackBars and Navigating.
  Future<void> pickAndProcessReceipt(
    BuildContext context,
    ImageSource source,
  ) async {
    /*
    arg must change to ImageSource source String base64Image
    */
    try {
      final imagePicker = ImagePicker();
      final XFile? pickedImage = await imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedImage == null) return;

      if (!context.mounted) return;

      // Loading snackbar
      final loadingSnackbar = SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(width: 16),
            Text(AppLocalizations.of(context)!.scanAnalyzing),
          ],
        ),
        duration: const Duration(minutes: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(loadingSnackbar);

      debugPrint("Image picked, processing...");

      final bytes = await pickedImage.readAsBytes();
      
      // Run heavy image processing in a separate isolate
      final base64Image = await compute(_processImageInIsolate, bytes);

      debugPrint("Image encoded, calling Cloud Function...");

      final functions = FirebaseFunctions.instanceFor(region: "us-central1");
      final callable = functions.httpsCallable('processReceiptGemini');

      final result = await callable.call(<String, dynamic>{
        'imageBase64': base64Image,
      });

      debugPrint("Cloud Function returned.");

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final data = result.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final jsonData = data['data'];
        final List<dynamic> items = jsonData['items'] ?? [];
        final String? storeName = jsonData['storeName'];

        // Inject storeName into each item
        if (storeName != null) {
          for (var item in items) {
            if (item is Map) {
              item['storeName'] = storeName;
            }
          }
        }

        // Check if the widget is still mounted before navigating
        if (context.mounted) {
          if (items.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No items found in the receipt.')),
            );
          } else {
            debugPrint("Navigating to ValidationScreen with ${items.length} items.");
            try {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => ValidationScreen(scannedItems: items),
                ),
              );
            } catch (e, stack) {
              debugPrint("Error navigating to ValidationScreen: $e");
              debugPrint(stack.toString());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Navigation Error: $e')),
              );
            }
          }
        }
      } else {
        throw Exception(
          "Function failed (success: false)",
        ); // Changed to English
      }
    } on FirebaseFunctionsException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backend Error : ${error.message}'),
          backgroundColor: Colors.red[700],
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error : $error'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }
}

/// Top-level function to run in an isolate
Future<String> _processImageInIsolate(Uint8List bytes) async {
  debugPrint("Isolate: Decoding image...");
  img.Image? originalImage = img.decodeImage(bytes);
  if (originalImage == null) {
    throw Exception("Loading image failed.");
  }

  debugPrint("Isolate: Resizing image...");
  final img.Image resizedImage = img.copyResize(originalImage, width: 800);

  debugPrint("Isolate: Encoding image...");
  return base64Encode(img.encodeJpg(resizedImage));
}
