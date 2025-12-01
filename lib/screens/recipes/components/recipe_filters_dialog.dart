import 'package:flutter/material.dart';
import 'package:frigo_zen/theme/app_theme.dart';

class RecipeFiltersDialog extends StatefulWidget {
  const RecipeFiltersDialog({super.key});

  @override
  State<RecipeFiltersDialog> createState() => _RecipeFiltersDialogState();
}

class _RecipeFiltersDialogState extends State<RecipeFiltersDialog> {
  String _selectedMealType = 'Any';
  String _selectedDiet = 'None';
  String _selectedDifficulty = 'Any';

  final List<String> _mealTypes = ['Any', 'Starter', 'Main', 'Dessert', 'Snack'];
  final List<String> _diets = ['None', 'Vegetarian', 'Vegan', 'Gluten Free'];
  final List<String> _difficulties = ['Any', 'Easy', 'Medium', 'Chef'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Préférences du Chef"), // TODO: l10n
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Type de plat"),
            _buildChipGroup(_mealTypes, _selectedMealType, (val) {
              setState(() => _selectedMealType = val);
            }),
            const SizedBox(height: 16),
            _buildSectionTitle("Régime"),
            _buildChipGroup(_diets, _selectedDiet, (val) {
              setState(() => _selectedDiet = val);
            }),
            const SizedBox(height: 16),
            _buildSectionTitle("Difficulté"),
            _buildChipGroup(_difficulties, _selectedDifficulty, (val) {
              setState(() => _selectedDifficulty = val);
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"), // TODO: l10n
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'mealType': _selectedMealType,
              'diet': _selectedDiet,
              'difficulty': _selectedDifficulty,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text("Générer"), // TODO: l10n
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildChipGroup(
      List<String> options, String selected, Function(String) onSelect) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: options.map((option) {
        final isSelected = selected == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (bool selected) {
            if (selected) {
              onSelect(option);
            }
          },
          selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryColor : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
