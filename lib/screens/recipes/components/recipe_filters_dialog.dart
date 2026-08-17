import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

// TODO(cook-with-ai): Dialog de sélection des filtres pour la génération de recettes IA.
// Pour réactiver la fonctionnalité "Cuisiner avec IA" dans une future version :
// 1. Remplacer tout le contenu de ce fichier par le code original ci-dessous.
// 2. Le code original se trouve dans la branche feature/cook-with-ai.

class RecipeFiltersDialog extends StatefulWidget {
  const RecipeFiltersDialog({super.key});

  @override
  State<RecipeFiltersDialog> createState() => _RecipeFiltersDialogState();
}

class _RecipeFiltersDialogState extends State<RecipeFiltersDialog> {

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.recipeFilterTitle),
      content: const Text('Feature coming soon'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.recipeFilterCancel),
        ),
      ],
    );
  }
}

/*
// TODO(cook-with-ai): CODE ORIGINAL — Décommenter pour réactiver.

import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.recipeFilterTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(l10n.recipeFilterMealType),
            _buildChipGroup(_mealTypes, _selectedMealType, (val) {
              setState(() => _selectedMealType = val);
            }),
            const SizedBox(height: 16),
            _buildSectionTitle(l10n.recipeFilterDiet),
            _buildChipGroup(_diets, _selectedDiet, (val) {
              setState(() => _selectedDiet = val);
            }),
            const SizedBox(height: 16),
            _buildSectionTitle(l10n.recipeFilterDifficulty),
            _buildChipGroup(_difficulties, _selectedDifficulty, (val) {
              setState(() => _selectedDifficulty = val);
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.recipeFilterCancel),
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
          child: Text(l10n.recipeFilterGenerate),
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

*/