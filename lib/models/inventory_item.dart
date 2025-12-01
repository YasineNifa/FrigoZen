import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/models/batch.dart';

class InventoryItem {
  final String id;
  final String name;
  final String cleanedName;
  final String canonicalName;
  final String category;
  final String location;
  final int totalQuantity;
  final DateTime earliestExpirationDate;
  final DateTime createdAt;
  final int dvm;
  final String? imageUrl;
  final List<Batch> batches;

  InventoryItem({
    required this.id,
    required this.name,
    required this.cleanedName,
    required this.canonicalName,
    required this.category,
    required this.location,
    required this.totalQuantity,
    required this.earliestExpirationDate,
    required this.createdAt,
    required this.dvm,
    this.imageUrl,
    required this.batches,
  });

  InventoryItem copyWith({
    String? id,
    String? name,
    String? cleanedName,
    String? canonicalName,
    String? category,
    String? location,
    int? totalQuantity,
    DateTime? earliestExpirationDate,
    DateTime? createdAt,
    int? dvm,
    String? imageUrl,
    List<Batch>? batches,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      cleanedName: cleanedName ?? this.cleanedName,
      canonicalName: canonicalName ?? this.canonicalName,
      category: category ?? this.category,
      location: location ?? this.location,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      earliestExpirationDate: earliestExpirationDate ?? this.earliestExpirationDate,
      createdAt: createdAt ?? this.createdAt,
      dvm: dvm ?? this.dvm,
      imageUrl: imageUrl ?? this.imageUrl,
      batches: batches ?? this.batches,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cleanedName': cleanedName,
      'canonicalName': canonicalName,
      'category': category,
      'location': location,
      'totalQuantity': totalQuantity,
      'earliestExpirationDate': Timestamp.fromDate(earliestExpirationDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'dvm': dvm,
      'imageUrl': imageUrl,
      'batches': batches.map((x) => x.toMap()).toList(),
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map, String id) {
    return InventoryItem(
      id: id,
      name: map['name'] as String? ?? '',
      cleanedName: map['cleanedName'] as String? ?? '',
      canonicalName: map['canonicalName'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      location: map['location'] as String? ?? 'Frigo',
      totalQuantity: map['totalQuantity'] as int? ?? 0,
      earliestExpirationDate: (map['earliestExpirationDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      dvm: map['dvm'] as int? ?? 7,
      imageUrl: map['imageUrl'] as String?,
      batches: List<Batch>.from(
        (map['batches'] as List<dynamic>? ?? []).map<Batch>(
          (x) => Batch.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  factory InventoryItem.fromSnapshot(DocumentSnapshot doc) {
    return InventoryItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  String toString() {
    return 'InventoryItem(id: $id, name: $name, totalQuantity: $totalQuantity, earliestExpirationDate: $earliestExpirationDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is InventoryItem &&
      other.id == id &&
      other.name == name &&
      other.cleanedName == cleanedName &&
      other.canonicalName == canonicalName &&
      other.category == category &&
      other.location == location &&
      other.totalQuantity == totalQuantity &&
      other.earliestExpirationDate == earliestExpirationDate &&
      other.createdAt == createdAt &&
      other.dvm == dvm &&
      other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      cleanedName.hashCode ^
      canonicalName.hashCode ^
      category.hashCode ^
      location.hashCode ^
      totalQuantity.hashCode ^
      earliestExpirationDate.hashCode ^
      createdAt.hashCode ^
      imageUrl.hashCode ^
      dvm.hashCode;
  }
}
