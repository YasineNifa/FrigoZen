import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType {
  addedShopping, // Item added to shopping list
  bought,        // Item checked off (moved to inventory)
  consumed,      // Item quantity reduced
  trashed,       // Item deleted/thrown away
}

class ActivityLog {
  final String id;
  final ActivityType type;
  final String itemName;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  ActivityLog({
    required this.id,
    required this.type,
    required this.itemName,
    required this.userId,
    required this.timestamp,
    this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name, // Store as string
      'itemName': itemName,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'details': details,
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map, String id) {
    return ActivityLog(
      id: id,
      type: ActivityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ActivityType.addedShopping,
      ),
      itemName: map['itemName'] as String,
      userId: map['userId'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      details: map['details'] as Map<String, dynamic>?,
    );
  }

  factory ActivityLog.fromSnapshot(DocumentSnapshot doc) {
    return ActivityLog.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
