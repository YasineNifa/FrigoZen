import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:frigo_zen/models/scanned_product.dart';

class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v0/product';

  /// Fetches product information from Open Food Facts using the barcode.
  /// Returns a Map<String, dynamic> containing the product data if found, or null otherwise.
  Future<Map<String, dynamic>?> fetchProduct(String barcode) async {
    // requesting all fields used by both ScanOptionsSheet and EditBatchDialog
    final url = Uri.parse(
        '$_baseUrl/$barcode.json?fields=product_name,product_name_fr,brands,image_front_small_url,image_front_url,image_front_thumb_url,image_nutrition_small_url,image_nutrition_thumb_url,image_nutrition_url,image_small_url,image_thumb_url,image_url,categories_tags,nutriscore_grade,stores');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 1) {
          return jsonResponse['product'];
        }
      }
    } catch (e) {
      // Ideally log this error
      rethrow;
    }
    return null; // Product not found or error
  }
  Future<ScannedProduct?> getScannedProduct(String barcode) async {
    final productData = await fetchProduct(barcode);
    if (productData == null) return null;

    final String productName = productData['product_name'] ?? productData['product_name_fr'] ?? '';
    if (productName.isEmpty) return null; // We need a name at minimum

    final String brands = productData['brands'] ?? '';
    final String? nutriscore = productData['nutriscore_grade'];
    final String? styles = productData['stores'];
    final String? imageUrl = productData['image_front_url'] ?? productData['image_url'];
    
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
       if (productData[key] != null && productData[key].toString().isNotEmpty) {
         images[key] = productData[key].toString();
       }
    }

    // Default smart data
    String cleanedName = productName;
    String canonicalName = productName.toLowerCase();
    String category = 'Other';
    String location = 'Frigo';
    int dvm = 7;
    int quantity = 1;

    // Fetch Smart Data
    try {
        final functions = FirebaseFunctions.instanceFor(region: "us-central1");
        final callable = functions.httpsCallable('getSmartItemData');
        final result = await callable.call({'productName': productName});
        final Map<String, dynamic> itemData = Map<String, dynamic>.from(result.data['item']);
        
        cleanedName = itemData['cleanedName'] ?? cleanedName;
        canonicalName = itemData['canonicalName'] ?? canonicalName;
        category = itemData['category'] ?? category;
        location = itemData['location'] ?? location;
        dvm = itemData['dvm'] ?? dvm;
        quantity = itemData['quantity'] ?? quantity;

    } catch (e) {
        print("Error fetching smart data: $e");
        // Use defaults
    }

    return ScannedProduct(
        name: productName,
        brands: brands,
        nutriscore: nutriscore,
        stores: styles,
        imageUrl: imageUrl,
        images: images,
        cleanedName: cleanedName,
        canonicalName: canonicalName,
        category: category,
        location: location,
        dvm: dvm,
        quantity: quantity,
    );
  }
}
