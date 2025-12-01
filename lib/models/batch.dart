import 'package:cloud_firestore/cloud_firestore.dart';

class Batch {
  final String? id;
  final int quantity;
  final DateTime expirationDate;
  final DateTime addedAt;
  final String? storeName;
  final String? imageUrl;
  final String? nutriscore;
  final String? name;
  final String? cleanedName;
  final String? canonicalName;
  final String? brands;
  final Map<String, String>? images;

  Batch({
    this.id,
    required this.quantity,
    required this.expirationDate,
    required this.addedAt,
    this.storeName,
    this.imageUrl,
    this.nutriscore,
    this.name,
    this.cleanedName,
    this.canonicalName,
    this.brands,
    this.images,
  });

  Batch copyWith({
    String? id,
    int? quantity,
    DateTime? expirationDate,
    DateTime? addedAt,
    String? storeName,
    String? imageUrl,
    String? nutriscore,
    String? name,
    String? cleanedName,
    String? canonicalName,
    String? brands,
    Map<String, String>? images,
  }) {
    return Batch(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      expirationDate: expirationDate ?? this.expirationDate,
      addedAt: addedAt ?? this.addedAt,
      storeName: storeName ?? this.storeName,
      imageUrl: imageUrl ?? this.imageUrl,
      nutriscore: nutriscore ?? this.nutriscore,
      name: name ?? this.name,
      cleanedName: cleanedName ?? this.cleanedName,
      canonicalName: canonicalName ?? this.canonicalName,
      brands: brands ?? this.brands,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quantity': quantity,
      'expirationDate': Timestamp.fromDate(expirationDate),
      'addedAt': Timestamp.fromDate(addedAt),
      'storeName': storeName,
      'imageUrl': imageUrl,
      'nutriscore': nutriscore,
      'name': name,
      'cleanedName': cleanedName,
      'canonicalName': canonicalName,
      'brands': brands,
      'images': images,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'expirationDate': expirationDate.toIso8601String(),
      'addedAt': addedAt.toIso8601String(),
      'storeName': storeName,
      'imageUrl': imageUrl,
      'nutriscore': nutriscore,
      'name': name,
      'cleanedName': cleanedName,
      'canonicalName': canonicalName,
      'brands': brands,
      'images': images,
    };
  }

  factory Batch.fromMap(Map<String, dynamic> map) {
    return Batch(
      id: map['id'] as String?,
      quantity: map['quantity'] as int? ?? 0,
      expirationDate: (map['expirationDate'] as Timestamp).toDate(),
      addedAt: (map['addedAt'] as Timestamp).toDate(),
      storeName: map['storeName'] as String?,
      imageUrl: map['imageUrl'] as String?,
      nutriscore: map['nutriscore'] as String?,
      name: map['name'] as String?,
      cleanedName: map['cleanedName'] as String?,
      canonicalName: map['canonicalName'] as String?,
      brands: map['brands'] as String?,
      images: map['images'] != null ? Map<String, String>.from(map['images']) : null,
    );
  }

  @override
  String toString() {
    return 'Batch(id: $id, quantity: $quantity, expirationDate: $expirationDate, addedAt: $addedAt, storeName: $storeName, imageUrl: $imageUrl, nutriscore: $nutriscore, name: $name, cleanedName: $cleanedName, canonicalName: $canonicalName, brands: $brands, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Batch &&
      other.id == id &&
      other.quantity == quantity &&
      other.expirationDate == expirationDate &&
      other.addedAt == addedAt &&
      other.storeName == storeName &&
      other.imageUrl == imageUrl &&
      other.nutriscore == nutriscore &&
      other.name == name &&
      other.cleanedName == cleanedName &&
      other.canonicalName == canonicalName &&
      other.brands == brands &&
      other.images == images;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      quantity.hashCode ^
      expirationDate.hashCode ^
      addedAt.hashCode ^
      storeName.hashCode ^
      imageUrl.hashCode ^
      nutriscore.hashCode ^
      name.hashCode ^
      cleanedName.hashCode ^
      canonicalName.hashCode ^
      brands.hashCode ^
      images.hashCode;
  }
}
