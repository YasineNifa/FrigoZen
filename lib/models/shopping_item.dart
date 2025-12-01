import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItem {
  final String id;
  final String name;
  final String cleanedName;
  final String canonicalName;
  final int quantity;
  final int? dvm;
  final String category;
  final String location;
  final DateTime createdAt;
  final bool isChecked;
  final String? imageUrl;
  final String? nutriscore;
  final String? brands;
  final String? storeName;
  final DateTime? expirationDate;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.cleanedName,
    required this.canonicalName,
    required this.quantity,
    this.dvm,
    required this.category,
    required this.location,
    required this.createdAt,
    required this.isChecked,
    this.imageUrl,
    this.nutriscore,
    this.brands,
    this.storeName,
    this.expirationDate,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? cleanedName,
    String? canonicalName,
    int? quantity,
    int? dvm,
    String? category,
    String? location,
    DateTime? createdAt,
    bool? isChecked,
    String? imageUrl,
    String? nutriscore,
    String? brands,
    String? storeName,
    DateTime? expirationDate,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      cleanedName: cleanedName ?? this.cleanedName,
      canonicalName: canonicalName ?? this.canonicalName,
      quantity: quantity ?? this.quantity,
      dvm: dvm ?? this.dvm,
      category: category ?? this.category,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      isChecked: isChecked ?? this.isChecked,
      imageUrl: imageUrl ?? this.imageUrl,
      nutriscore: nutriscore ?? this.nutriscore,
      brands: brands ?? this.brands,
      storeName: storeName ?? this.storeName,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cleanedName': cleanedName,
      'canonicalName': canonicalName,
      'quantity': quantity,
      'dvm': dvm,
      'category': category,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'isChecked': isChecked,
      'imageUrl': imageUrl,
      'nutriscore': nutriscore,
      'brands': brands,
      'storeName': storeName,
      'expirationDate': expirationDate != null ? Timestamp.fromDate(expirationDate!) : null,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map, String id) {
    return ShoppingItem(
      id: id,
      name: map['name'] as String? ?? '',
      cleanedName: map['cleanedName'] as String? ?? '',
      canonicalName: map['canonicalName'] as String? ?? '',
      quantity: map['quantity'] as int? ?? 1,
      dvm: map['dvm'] as int?,
      category: map['category'] as String? ?? 'Other',
      location: map['location'] as String? ?? 'Frigo',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isChecked: map['isChecked'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
      nutriscore: map['nutriscore'] as String?,
      brands: map['brands'] as String?,
      storeName: map['storeName'] as String?,
      expirationDate: (map['expirationDate'] as Timestamp?)?.toDate(),
    );
  }

  factory ShoppingItem.fromSnapshot(DocumentSnapshot doc) {
    return ShoppingItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  String toString() {
    return 'ShoppingItem(id: $id, name: $name, quantity: $quantity, isChecked: $isChecked, imageUrl: $imageUrl, nutriscore: $nutriscore, brands: $brands, storeName: $storeName, expirationDate: $expirationDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ShoppingItem &&
      other.id == id &&
      other.name == name &&
      other.cleanedName == cleanedName &&
      other.canonicalName == canonicalName &&
      other.quantity == quantity &&
      other.dvm == dvm &&
      other.category == category &&
      other.location == location &&
      other.createdAt == createdAt &&
      other.isChecked == isChecked &&
      other.imageUrl == imageUrl &&
      other.nutriscore == nutriscore &&
      other.brands == brands &&
      other.storeName == storeName &&
      other.expirationDate == expirationDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      cleanedName.hashCode ^
      canonicalName.hashCode ^
      quantity.hashCode ^
      dvm.hashCode ^
      category.hashCode ^
      location.hashCode ^
      createdAt.hashCode ^
      isChecked.hashCode ^
      imageUrl.hashCode ^
      nutriscore.hashCode ^
      brands.hashCode ^
      storeName.hashCode ^
      expirationDate.hashCode;
  }
}
