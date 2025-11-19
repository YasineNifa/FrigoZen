import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/services/revenue_provider.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pas besoin d'AppBar, le PaywallView gère tout
      body: PaywallView(
        // SUPPRIMEZ LA LIGNE 'offeringIdentifier'.
        // Le SDK va automatiquement charger l'offre "Current" de votre Dashboard.
        onPurchaseCompleted:
            (CustomerInfo customerInfo, StoreTransaction storeTransaction) {
              // Achat réussi !
              context.read<RevenueProvider>().setCustomerInfo(customerInfo);
              Navigator.of(context).pop(); // On ferme le paywall

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Bienvenue dans FrigoZen Pro ! 🌟"),
                  backgroundColor: Colors.green,
                ),
              );
            },
        onRestoreCompleted: (CustomerInfo customerInfo) {
          // Restauration réussie
          context.read<RevenueProvider>().setCustomerInfo(customerInfo);
          Navigator.of(context).pop();
        },
        onDismiss: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
