class FrigoUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;

  FrigoUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
  });

  factory FrigoUser.fromMap(Map<String, dynamic> map, String id) {
    return FrigoUser(
      id: id,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      photoURL: map['photoURL'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
    };
  }
}
