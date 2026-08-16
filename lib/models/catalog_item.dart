import 'package:cloud_firestore/cloud_firestore.dart';

class CatalogItem {
  final String id;
  final String name;
  final String canonicalName; // Lowercase, trimmed
  final String category;
  final int defaultDVM;
  final String? imageUrl;
  final String? brands;
  final String? nutriscore;
  final String? storeName;
  final double? lastPrice; // Added for price tracking
  final DateTime createdAt;
  final DateTime updatedAt;
  final int usageCount;

  CatalogItem({
    required this.id,
    required this.name,
    required this.canonicalName,
    required this.category,
    required this.defaultDVM,
    this.imageUrl,
    this.brands,
    this.nutriscore,
    this.storeName,
    this.lastPrice,
    required this.createdAt,
    required this.updatedAt,
    this.usageCount = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'canonicalName': canonicalName,
      'category': category,
      'defaultDVM': defaultDVM,
      'imageUrl': imageUrl,
      'brands': brands,
      'nutriscore': nutriscore,
      'storeName': storeName,
      'lastPrice': lastPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'usageCount': usageCount,
    };
  }

  factory CatalogItem.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CatalogItem(
      id: doc.id,
      name: data['name'] ?? '',
      canonicalName: data['canonicalName'] ?? '',
      category: data['category'] ?? 'Other',
      defaultDVM: data['defaultDVM'] ?? 7,
      imageUrl: data['imageUrl'],
      brands: data['brands'],
      nutriscore: data['nutriscore'],
      storeName: data['storeName'],
      lastPrice: (data['lastPrice'] is num) ? (data['lastPrice'] as num).toDouble() : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      usageCount: data['usageCount'] ?? 1,
    );
  }
}
