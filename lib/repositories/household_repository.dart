import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/models/household.dart';

class HouseholdRepository {
  final FirebaseFirestore _firestore;

  HouseholdRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String?> getHouseholdIdForUser(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();

    if (userDoc.exists && userDoc.data()!.containsKey('householdId')) {
      return userDoc.data()!['householdId'] as String?;
    }
    return null;
  }

  Stream<Household?> getHouseholdStream(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return Household.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }
}
