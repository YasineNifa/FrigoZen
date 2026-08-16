import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/models/batch.dart';
import 'package:frigo_zen/models/enums.dart';

class InventoryItem {
  final String id;
  final String name;
  final String cleanedName;
  final String canonicalName;
  final InventoryCategory category;
  final StorageLocation location;
  final int totalQuantity;
  final DateTime earliestExpirationDate;
  final DateTime createdAt;
  final int dvm;
  final String? imageUrl;
  
  final Map<String, int> nutriscoreStats;
  final Map<String, int> storeStats;
  
  // Cache for local usage, not persisted in item doc
  final List<Batch> batches;

  String? get displayImageUrl {
    // ... same logic
    for (final batch in batches) {
      if (batch.images != null && 
          batch.images!['image_front_small_url'] != null && 
          batch.images!['image_front_small_url']!.isNotEmpty) {
        return batch.images!['image_front_small_url'];
      }
    }
    
    // Fallback to regular image url
    for (final batch in batches) {
      if (batch.imageUrl != null && batch.imageUrl!.trim().isNotEmpty) {
        return batch.imageUrl;
      }
    }
    return imageUrl;
  }

  String? get displayImageOriginal {
     // ... same logic
    for (final batch in batches) {
      if (batch.images != null && 
          batch.images!['image_front_url'] != null && 
          batch.images!['image_front_url']!.isNotEmpty) {
        return batch.images!['image_front_url'];
      }
    }
    return displayImageUrl;
  }

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
    this.batches = const [],
    this.nutriscoreStats = const {},
    this.storeStats = const {},
  });

  InventoryItem copyWith({
    String? id,
    String? name,
    String? cleanedName,
    String? canonicalName,
    InventoryCategory? category,
    StorageLocation? location,
    int? totalQuantity,
    DateTime? earliestExpirationDate,
    DateTime? createdAt,
    int? dvm,
    String? imageUrl,
    List<Batch>? batches,
    Map<String, int>? nutriscoreStats,
    Map<String, int>? storeStats,
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
      nutriscoreStats: nutriscoreStats ?? this.nutriscoreStats,
      storeStats: storeStats ?? this.storeStats,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cleanedName': cleanedName,
      'canonicalName': canonicalName,
      'category': category.key,
      'location': location.id,
      'totalQuantity': totalQuantity,
      'earliestExpirationDate': Timestamp.fromDate(earliestExpirationDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'dvm': dvm,
      'imageUrl': imageUrl,
      'nutriscoreStats': nutriscoreStats,
      'storeStats': storeStats,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cleanedName': cleanedName,
      'canonicalName': canonicalName,
      'category': category.key,
      'location': location.id,
      'totalQuantity': totalQuantity,
      'earliestExpirationDate': earliestExpirationDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'dvm': dvm,
      'imageUrl': imageUrl,
      'nutriscoreStats': nutriscoreStats,
      'storeStats': storeStats,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map, String id) {
    // Legacy support: if 'batches' exists in map (old data), parse it to populate the cache
    List<Batch> legacyBatches = [];
    if (map['batches'] != null) {
      legacyBatches = List<Batch>.from(
        (map['batches'] as List<dynamic>).map<Batch>(
          (x) => Batch.fromMap(x as Map<String, dynamic>),
        ),
      );
    }

    return InventoryItem(
      id: id,
      name: map['name'] as String? ?? '',
      cleanedName: map['cleanedName'] as String? ?? '',
      canonicalName: map['canonicalName'] as String? ?? '',
      category: InventoryCategory.fromString(map['category'] as String?),
      location: StorageLocation.fromId(map['location']),
      totalQuantity: map['totalQuantity'] as int? ?? 0,
      earliestExpirationDate: (map['earliestExpirationDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      dvm: map['dvm'] as int? ?? 7,
      imageUrl: map['imageUrl'] as String?,
      batches: legacyBatches,
      nutriscoreStats: (map['nutriscoreStats'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as int)) ?? {},
      storeStats: (map['storeStats'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as int)) ?? {},
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
      // Note: Map equality check might be shallow for defaults, but we assume generated maps 
      // are compared properly if using collection equality or similar. 
      // For simple MVP without collection package, we skip deep equality or implement simple length check + key check if needed.
      // Since these are aggregates, exact match is expected.
      // But standard == on Maps is reference equality.  We should ideally use `mapEquals`.
      // For now, let's omit deep map check to avoid adding dependency failure if collection not imported.
      // Or just check length.
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
