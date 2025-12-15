class ScannedProduct {
  final String name;
  final String brands;
  final String? nutriscore;
  final String? imageUrl;
  final Map<String, String> images;
  final String? stores;
  
  // Smart Data
  final String cleanedName;
  final String canonicalName;
  final String category;
  final String location;
  final int dvm;
  final int quantity;

  ScannedProduct({
    required this.name,
    required this.brands,
    this.nutriscore,
    this.imageUrl,
    required this.images,
    this.stores,
    required this.cleanedName,
    required this.canonicalName,
    required this.category,
    required this.location,
    required this.dvm,
    this.quantity = 1,
  });
}
