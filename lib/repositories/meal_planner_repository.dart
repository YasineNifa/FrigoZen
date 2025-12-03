import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frigo_zen/models/meal_plan.dart';

class MealPlannerRepository {
  final FirebaseFirestore _firestore;

  MealPlannerRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getMealPlansCollection(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('meal_plans');
  }

  Stream<List<MealPlan>> getMealPlansStream(String householdId) {
    return _getMealPlansCollection(householdId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MealPlan.fromSnapshot(doc);
      }).toList();
    });
  }

  Future<void> addMealPlan(String householdId, MealPlan meal) async {
    await _getMealPlansCollection(householdId).add(meal.toMap());
  }

  Future<void> updateMealPlan(String householdId, String mealId, Map<String, dynamic> data) async {
    await _getMealPlansCollection(householdId).doc(mealId).update(data);
  }

  Future<void> deleteMealPlan(String householdId, String mealId) async {
    await _getMealPlansCollection(householdId).doc(mealId).delete();
  }
}
