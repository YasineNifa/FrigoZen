import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class ShoppingListEmptyState extends StatelessWidget {
  const ShoppingListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Arrow pointing up
              Icon(
                Icons.arrow_upward_rounded,
                size: 48,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                "Ajoutez votre premier article !",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              
              // Image
              Image.asset(
                'assets/images/shopping.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.8),
              ),
              const SizedBox(height: 32),
              
              // Texts
              Text(
                l10n.shoppingListEmptyTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.shoppingListEmptySubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
