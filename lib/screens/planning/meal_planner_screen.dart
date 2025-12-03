// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/viewmodels/meal_planner_view_model.dart';
import 'package:frigo_zen/models/meal_plan.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/repositories/household_repository.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/screens/core/navigation_controller.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/screens/paywall/modern_paywall_screen.dart';
import 'dart:ui';

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
                      _buildMealSection(l10n.mealPlannerBreakfast, MealType.breakfast, mealsForDay),
                      const SizedBox(height: 16),
                      _buildMealSection(l10n.mealPlannerLunch, MealType.lunch, mealsForDay),
                      const SizedBox(height: 16),
                      _buildMealSection(l10n.mealPlannerSnack, MealType.snack, mealsForDay),
                      const SizedBox(height: 16),
                      _buildMealSection(l10n.mealPlannerDinner, MealType.dinner, mealsForDay),
                      const SizedBox(height: 80), // Bottom padding for FAB or scroll
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
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: 14, // 2 weeks
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final isSelected = isSameDay(date, _selectedDate);
          final isToday = isSameDay(date, now);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6B9C5F) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected 
                    ? Border.all(color: const Color(0xFF6B9C5F), width: 2) 
                    : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFF6B9C5F).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E(Localizations.localeOf(context).languageCode).format(date).toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white.withValues(alpha: 0.9) : Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 20,
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
    final l10n = AppLocalizations.of(context)!;
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
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: InkWell(
              onTap: () => _showAddMealDialog(type, existingMeal: hasMeal ? meal : null),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: hasMeal 
                      ? const Color(0xFF6B9C5F).withValues(alpha: 0.15) 
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasMeal 
                        ? const Color(0xFF6B9C5F).withValues(alpha: 0.3) 
                        : Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: hasMeal ? Colors.white : Colors.grey[100],
                        shape: BoxShape.circle,
                        boxShadow: hasMeal ? [
                          BoxShadow(
                            color: const Color(0xFF6B9C5F).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ] : null,
                      ),
                      child: Icon(
                        hasMeal ? Icons.restaurant_menu : Icons.add,
                        color: hasMeal ? const Color(0xFF6B9C5F) : Colors.grey[400],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasMeal ? meal.recipeName : l10n.mealPlannerAddMeal,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: hasMeal ? FontWeight.w600 : FontWeight.w500,
                              color: hasMeal ? Colors.black87 : Colors.grey[600],
                            ),
                          ),
                          if (hasMeal && meal.ingredients.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              "${meal.ingredients.length} ingrédients",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (hasMeal)
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red.withValues(alpha: 0.7), size: 20),
                        onPressed: () => context.read<MealPlannerViewModel>().deleteMeal(meal.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                  ],
                ),
              ),
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
                  context.read<MealPlannerViewModel>().updateMeal(
                    existingMeal.id,
                    nameController.text,
                    ingredients,
                  );
                } else {
                  context.read<MealPlannerViewModel>().addMeal(
                    _selectedDate,
                    type,
                    nameController.text,
                    ingredients: ingredients,
                  );
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

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final count = await planner.generateShoppingList(inventory, shopping, isPro: isPro);
      
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();

      if (count > 0) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.mealPlannerAddedIngredients(count)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.mealPlannerIngredientsAddedMessage),
                  if (!isPro) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.mealPlannerSmartListUpsell,
                            style: const TextStyle(fontSize: 13, color: Colors.indigo),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ModernPaywallScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: Text(l10n.mealPlannerGoPremium),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.ok),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // Navigate to Shopping List (index 2)
                    context.read<NavigationController>().setIndex(2);
                    // Pop back to the main shell
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.mealPlannerViewList),
                ),
              ],
            ),
          );
        } else {
          // No items added (maybe already exist)
           showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.mealPlannerNoIngredientsAddedTitle),
              content: Text(l10n.mealPlannerNoIngredientsAddedMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.ok),
                ),
              ],
            ),
          );
        }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric(e.toString()))),
        );
      }
    }
  }
}
