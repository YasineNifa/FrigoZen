import 'dart:convert';
import 'package:http/http.dart' as http;

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
}
