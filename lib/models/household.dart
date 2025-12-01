class Household {
  final String id;
  final String name;
  final List<String> members;
  final String ownerId;
  final DateTime createdAt;
  final String inviteCode;

  Household({
    required this.id,
    required this.name,
    required this.members,
    required this.ownerId,
    required this.createdAt,
    required this.inviteCode,
  });

  Household copyWith({
    String? id,
    String? name,
    List<String>? members,
    String? ownerId,
    DateTime? createdAt,
    String? inviteCode,
  }) {
    return Household(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'members': members,
      'ownerId': ownerId,
      'createdAt': createdAt,
      'inviteCode': inviteCode,
    };
  }

  factory Household.fromMap(Map<String, dynamic> map, String id) {
    return Household(
      id: id,
      name: map['name'] as String? ?? '',
      members: List<String>.from(map['members'] ?? []),
      ownerId: map['ownerId'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      inviteCode: map['inviteCode'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'Household(id: $id, name: $name, members: $members, ownerId: $ownerId, createdAt: $createdAt, inviteCode: $inviteCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Household &&
      other.id == id &&
      other.name == name &&
      other.ownerId == ownerId &&
      other.createdAt == createdAt &&
      other.inviteCode == inviteCode;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      ownerId.hashCode ^
      createdAt.hashCode ^
      inviteCode.hashCode;
  }
}
