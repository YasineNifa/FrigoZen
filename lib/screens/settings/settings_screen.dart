import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:frigo_zen/screens/paywall/paywall_screen.dart';
import 'package:frigo_zen/services/household_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isPro = context.watch<RevenueProvider>().isPro;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          if (user != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Account Information'),
              subtitle: Text(user.email ?? 'No email available'),
            ),

          const Divider(),
          ListTile(
            leading: Icon(
              isPro ? Icons.star : Icons.star_border,
              color: Colors.amber[700],
            ),
            title: Text(
              isPro ? 'Manage Subscription' : 'Upgrade to FrigoZen Pro',
            ),
            subtitle: Text(
              isPro ? 'You are a Pro member.' : 'Unlock all features.',
            ),
            onTap: () async {
              if (isPro) {
                // Si Pro -> Ouvrir le centre de gestion RevenueCat
                try {
                  await RevenueCatUI.presentCustomerCenter();
                } on PurchasesError catch (e) {
                  print("Customer Center error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Could not open settings")),
                  );
                }
              } else {
                // Si Pas Pro -> Ouvrir le Paywall
                // Navigator.of(context).push(
                //   MaterialPageRoute(builder: (ctx) => const PaywallScreen()),
                // );

                try {
                  await RevenueCatUI.presentPaywallIfNeeded("default");
                } on PurchasesError catch (e) {
                  print("Paywall error: $e");
                }
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Purchases'),
            onTap: () async {
              try {
                final customerInfo = await Purchases.restorePurchases();
                context.read<RevenueProvider>().setCustomerInfo(customerInfo);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Purchases restored successfully."),
                  ),
                );
              } on PurchasesError catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Restore failed: ${e.message}")),
                );
              }
            },
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              "FAMILLE & FOYER",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          // WIDGET DU CODE D'INVITATION
          StreamBuilder<DocumentSnapshot?>(
            stream: HouseholdService().getCurrentHouseholdStream(),
            builder: (context, snapshot) {
              // Si pas de données ou chargement, on affiche un placeholder vide
              if (!snapshot.hasData || snapshot.data == null)
                return const SizedBox();

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final String inviteCode = data['inviteCode'] ?? '...';
              final String householdName = data['name'] ?? 'Maison';

              // LOGIQUE PREMIUM
              if (!isPro) {
                // CAS 1 : UTILISATEUR GRATUIT (Verrouillé)
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock, color: Colors.grey),
                  ),
                  title: const Text("Inviter des membres"),
                  subtitle: const Text(
                    "Passez Premium pour partager votre inventaire.",
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Ouvre le Paywall
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const PaywallScreen(),
                      ),
                    );
                  },
                );
              } else {
                // CAS 2 : UTILISATEUR PREMIUM (Code visible)
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50], // Fond vert léger
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.home_filled, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            householdName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Code d'invitation :",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            inviteCode,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.green),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: inviteCode),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Code copié !")),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Partagez ce code pour inviter votre famille.",
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red[700]),
            title: Text('Logout', style: TextStyle(color: Colors.red[700])),
            onTap: () {
              context.read<RevenueProvider>().setCustomerInfo(null);
              Purchases.logOut();
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
