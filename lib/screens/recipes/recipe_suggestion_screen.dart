import 'package:flutter/material.dart';

class RecipeSuggestionScreen extends StatelessWidget {
  final List<dynamic> recipes;

  const RecipeSuggestionScreen({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Suggestions')),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = Map<String, dynamic>.from(recipes[index]);
          final String title = recipe['title'] ?? 'Untitled Recipe';
          final String description = recipe['description'] ?? 'No description.';
          final List<dynamic> usedItems = recipe['usedItems'] ?? [];
          final List<dynamic> missingItems = recipe['missingItems'] ?? [];
          final List<dynamic> instructions = recipe['instructions'] ?? [];

          return Card(
            margin: const EdgeInsets.all(12.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(description),
              childrenPadding: const EdgeInsets.all(16.0),
              children: [
                // 1. What I have
                _buildIngredientList(
                  context,
                  '✅ In Your Inventory:',
                  usedItems,
                  Colors.green[700]!,
                ),

                // 2. Missing
                if (missingItems.isNotEmpty)
                  _buildIngredientList(
                    context,
                    '🛒 Missing Items:',
                    missingItems,
                    Colors.orange[700]!,
                  ),

                const Divider(height: 32),

                // 3. Instructions
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Instructions:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                for (final step in List<String>.from(instructions))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(step),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIngredientList(
    BuildContext context,
    String title,
    List<dynamic> items,
    Color titleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: titleColor),
        ),
        const SizedBox(height: 8),
        for (var item in items) ...[
          // On utilise un "spread operator"
          Builder(
            builder: (context) {
              final itemMap = Map<String, dynamic>.from(item);
              final name = itemMap['name'] ?? '...';
              final quantity = itemMap['quantity'] ?? '...';
              final isExpiring = itemMap['isExpiringSoon'] == true;

              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  '• $name ($quantity)${isExpiring ? ' (Expires soon!)' : ''}',
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
