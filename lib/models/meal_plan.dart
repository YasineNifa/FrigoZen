import 'package:cloud_firestore/cloud_firestore.dart';

enum MealType { breakfast, lunch, snack, dinner }

class MealPlan {
  final String id;
  final DateTime date;
  final MealType mealType;
  final String recipeId; // Can be empty if custom meal
  final String recipeName;
  final String householdId;
  final List<String> ingredients;

  MealPlan({
    required this.id,
    required this.date,
    required this.mealType,
    required this.recipeId,
    required this.recipeName,
    required this.householdId,
    this.ingredients = const [],
  });

  MealPlan copyWith({
    String? id,
    DateTime? date,
    MealType? mealType,
    String? recipeId,
    String? recipeName,
    String? householdId,
    List<String>? ingredients,
  }) {
    return MealPlan(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      householdId: householdId ?? this.householdId,
      ingredients: ingredients ?? this.ingredients,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'mealType': mealType.toString(),
      'recipeId': recipeId,
      'recipeName': recipeName,
      'householdId': householdId,
      'ingredients': ingredients,
    };
  }

  factory MealPlan.fromMap(Map<String, dynamic> map, String id) {
    return MealPlan(
      id: id,
      date: (map['date'] as Timestamp).toDate(),
      mealType: MealType.values.firstWhere(
        (e) => e.toString() == map['mealType'],
        orElse: () => MealType.lunch,
      ),
      recipeId: map['recipeId'] ?? '',
      recipeName: map['recipeName'] ?? '',
      householdId: map['householdId'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
    );
  }

  factory MealPlan.fromSnapshot(DocumentSnapshot doc) {
    return MealPlan.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
