import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:frigo_zen/screens/core/premium_guard.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class PremiumStatsWrapper extends StatelessWidget {
  final Widget child;
  final String label;

  const PremiumStatsWrapper({
    super.key,
    required this.child,
    this.label = "Statistiques Premium", // TODO: This default value might need to be removed or localized differently if used
  });

  @override
  Widget build(BuildContext context) {
    final isPro = context.watch<RevenueProvider>().isPro;

    if (isPro) {
      return child;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12), // Match card radius
      child: Stack(
        children: [
          // Blurred Child
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: child,
          ),
          
          // Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.1),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Colors.orange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => PremiumGuard.checkPremiumStatus(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.statsUnlockBtn,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
