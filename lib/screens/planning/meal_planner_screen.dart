import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/viewmodels/meal_planner_view_model.dart';
import 'package:frigo_zen/models/meal_plan.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/repositories/household_repository.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/screens/core/navigation_controller.dart';
import 'package:frigo_zen/services/revenue_provider.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initViewModel();
    });
  }

  Future<void> _initViewModel() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final householdId = await HouseholdRepository().getHouseholdIdForUser(userId);
      if (householdId != null && mounted) {
        context.read<MealPlannerViewModel>().init(householdId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MealPlannerViewModel>();
    final mealsForDay = vm.meals.where((m) => isSameDay(m.date, _selectedDate)).toList();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(


      appBar: AppBar(
        title: Text(l10n.mealPlannerTitle),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_checkout, color: Colors.green),
            tooltip: l10n.mealPlannerGenerateList,
            onPressed: () => _generateShoppingList(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Week Calendar
          _buildWeekCalendar(),
          
          const Divider(),

          // Meals List
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildMealSection(l10n.mealPlannerLunch, MealType.lunch, mealsForDay),
                      const SizedBox(height: 24),
                      _buildMealSection(l10n.mealPlannerDinner, MealType.dinner, mealsForDay),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final now = DateTime.now();
    // Start of week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return Container(
      height: 100,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // 2 weeks
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final isSelected = isSameDay(date, _selectedDate);
          final isToday = isSameDay(date, now);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6B9C5F) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isToday && !isSelected 
                    ? Border.all(color: const Color(0xFF6B9C5F), width: 2) 
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E('fr').format(date).toUpperCase(), // Mon, Tue...
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealSection(String title, MealType type, List<MealPlan> meals) {
    final meal = meals.firstWhere(
      (m) => m.mealType == type, 
      orElse: () => MealPlan(
        id: '', 
        date: _selectedDate, 
        mealType: type, 
        recipeId: '', 
        recipeName: '', 
        householdId: ''
      )
    );
    
    final hasMeal = meal.recipeName.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _showAddMealDialog(type, existingMeal: hasMeal ? meal : null),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: hasMeal ? const Color(0xFF6B9C5F).withOpacity(0.1) : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasMeal ? const Color(0xFF6B9C5F).withOpacity(0.3) : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasMeal ? Icons.restaurant : Icons.add,
                    color: hasMeal ? const Color(0xFF6B9C5F) : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    hasMeal ? meal.recipeName : l10n.mealPlannerAddMeal,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: hasMeal ? FontWeight.w600 : FontWeight.normal,
                      color: hasMeal ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
                if (hasMeal)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => context.read<MealPlannerViewModel>().deleteMeal(meal.id),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddMealDialog(MealType type, {MealPlan? existingMeal}) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: existingMeal?.recipeName ?? '');
    final ingredientsController = TextEditingController(
      text: existingMeal?.ingredients.join(', ') ?? ''
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingMeal != null ? l10n.mealPlannerEditMeal : l10n.mealPlannerAddMeal),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.mealPlannerMealNameLabel,
                hintText: l10n.mealPlannerMealNameHint,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ingredientsController,
              decoration: InputDecoration(
                labelText: l10n.mealPlannerIngredientsLabel,
                hintText: l10n.mealPlannerIngredientsHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.mealPlannerCancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final ingredients = ingredientsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                    
                context.read<MealPlannerViewModel>().addMeal(
                  _selectedDate,
                  type,
                  nameController.text,
                  ingredients: ingredients,
                );
                // If editing, we might want to delete the old one or update it.
                // addMeal creates a new one. MealPlannerViewModel doesn't have updateMeal yet?
                // Actually addMeal uses `add` which creates a new doc.
                // If we are editing, we should probably delete the old one first OR implement updateMeal.
                // For now, let's delete the old one if it exists to avoid duplicates.
                if (existingMeal != null) {
                  context.read<MealPlannerViewModel>().deleteMeal(existingMeal.id);
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B9C5F),
              foregroundColor: Colors.white,
            ),
            child: Text(existingMeal != null ? l10n.mealPlannerModify : l10n.mealPlannerAdd),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _generateShoppingList(BuildContext context) async {
    final inventory = context.read<InventoryViewModel>();
    final shopping = context.read<ShoppingViewModel>();
    final planner = context.read<MealPlannerViewModel>();
    final isPro = context.read<RevenueProvider>().isPro;
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.mealPlannerAnalyzing)),
    );

    try {
      final count = await planner.generateShoppingList(inventory, shopping, isPro: isPro);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.mealPlannerAddedIngredients(count)),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: l10n.mealPlannerViewList,
              textColor: Colors.white,
              onPressed: () {
                 // Navigate to Shopping List (index 2)
                 context.read<NavigationController>().setIndex(2);
                 Navigator.pop(context); // Close Meal Planner
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    }
  }
}
