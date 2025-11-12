import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/validation/validation_screen.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_functions/cloud_functions.dart';

/// OcrService handles all logic related to picking images
/// and processing them via the backend AI.
class OcrService {

  /// This is the main function that handles the entire OCR flow.
  /// It is moved from inventory_screen.dart.
  /// We pass BuildContext here for showing SnackBars and Navigating.
  Future<void> pickAndProcessReceipt(BuildContext context, ImageSource source) async {
    /*
    arg must change to ImageSource source String base64Image
    */
    // Loading snackbar
    final loadingSnackbar = SnackBar(
      content: Row(
        children: const [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(width: 16),
          Text('Analyzing receipt...'),
        ],
      ),
      duration: const Duration(minutes: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(loadingSnackbar);

    try {
      // TODO: Uncomment the following lines to enable camera and gallery options + Modify the code above
      /**/
      final imagePicker = ImagePicker();
      final XFile? pickedImage = await imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      );

      if (pickedImage == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return;
      }

      final bytes = await pickedImage.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        throw Exception("Loading image failed.");
      }

      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: 800,
      );

      final String base64Image = base64Encode(img.encodeJpg(resizedImage));

      /**/

      final functions = FirebaseFunctions.instanceFor(region: "us-central1");
      final callable = functions.httpsCallable('processReceiptGemini');

      final result = await callable.call(<String, dynamic>{
        'imageBase64': base64Image,
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final data = result.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final jsonData = data['data'];
        final List<dynamic> items = jsonData['items'] ?? [];
        print("---------------------------------");
        print("ITEMS :");
        print(jsonData);
        print("---------------------------------");
        
        // Check if the widget is still mounted before navigating
        if (context.mounted) {
          if (items.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No items found in the receipt.'),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => ValidationScreen(scannedItems: items),
              ),
            );
          }
        }
      } else {
        throw Exception("Function failed (success: false)"); // Changed to English
      }
    } on FirebaseFunctionsException catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backend Error : ${error.message}'),
          backgroundColor: Colors.red[700],
        ),
      );
    } catch (error) {
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
