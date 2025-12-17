import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HouseholdService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
    return 'FZ-$code';
  }

  Future<void> createHousehold(String householdName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    String inviteCode = "";
    bool isUnique = false;

    while (!isUnique) {
      inviteCode = _generateRandomCode(5);
      final query = await _firestore
          .collection('households')
          .where('inviteCode', isEqualTo: inviteCode)
          .get();

      if (query.docs.isEmpty) {
        isUnique = true;
      }
    }

    final householdRef = _firestore.collection('households').doc();
    await householdRef.set({
      'name': householdName,
      'inviteCode': inviteCode,
      'ownerId': user.uid,
      'members': [user.uid],
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'householdId': householdRef.id,
      'role': 'owner',
    }, SetOptions(merge: true));
  }

  Future<void> joinHousehold(String inviteCode) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    final formattedCode = inviteCode.trim().toUpperCase();
    final query = await _firestore
        .collection('households')
        .where('inviteCode', isEqualTo: formattedCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception("Invitation code not found.");
    }

    final householdDoc = query.docs.first;
    final List<dynamic> members = householdDoc['members'];
    if (members.contains(user.uid)) {
      await _firestore.collection('users').doc(user.uid).set({
        'householdId': householdDoc.id,
        'role': 'member',
      }, SetOptions(merge: true));
      return;
    }

    if (members.length >= 5) {
      throw Exception('HOUSEHOLD_FULL');
    }

    await householdDoc.reference.update({
      'members': FieldValue.arrayUnion([user.uid]),
    });

    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'householdId': householdDoc.id,
      'role': 'member',
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot?> getCurrentHouseholdStream() async* {
    final user = _auth.currentUser;
    if (user == null) yield null;

    final userDocSnapshot = await _firestore
        .collection('users')
        .doc(user!.uid)
        .get();

    if (!userDocSnapshot.exists ||
        !userDocSnapshot.data()!.containsKey('householdId')) {
      yield null;
      return;
    }

    final String householdId = userDocSnapshot.get('householdId');
    yield* _firestore.collection('households').doc(householdId).snapshots();
  }
  Future<String?> getUserHouseholdId() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDocSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDocSnapshot.exists ||
        !userDocSnapshot.data()!.containsKey('householdId')) {
      return null;
    }

    return userDocSnapshot.get('householdId');
  }

  Future<void> updateHouseholdCurrency(String currencyCode) async {
    final householdId = await getUserHouseholdId();
    if (householdId == null) return;

    await _firestore.collection('households').doc(householdId).update({
      'currency': currencyCode,
    });
  }
}
