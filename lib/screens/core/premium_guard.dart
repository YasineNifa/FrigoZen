import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:frigo_zen/screens/paywall/modern_paywall_screen.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PremiumGuard {
  /// Checks if the user is premium. If not, shows the paywall.
  /// Returns true if the user is premium (or becomes premium after paywall), false otherwise.
  static Future<bool> checkPremiumStatus(BuildContext context) async {
    final isPro = context.read<RevenueProvider>().isPro;

    if (isPro) {
      return true;
    } else {
      try {
        if (!context.mounted) return false;
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => const ModernPaywallScreen()),
        );
        if (!context.mounted) return false;
        return context.read<RevenueProvider>().isPro;
      } on PurchasesError catch (e) {
        debugPrint("Error while displaying Paywall: $e");
        return false;
      }
    }
  }
}
