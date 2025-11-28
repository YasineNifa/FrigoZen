import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/screens/auth/auth_screen.dart';
import 'package:frigo_zen/screens/core/household_setup_screen.dart';
import 'package:frigo_zen/screens/core/navigation_shell.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/services/revenue_provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _setupNotifications(user);
            _logInRevenueCat(context, user.uid);
          });

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userDocSnapshot.hasData && userDocSnapshot.data!.exists) {
                final data =
                    userDocSnapshot.data!.data() as Map<String, dynamic>?;
                final householdId = data?['householdId'];
                if (householdId != null) {
                  return const NavigationShell();
                }
                return const HouseholdSetupScreen();
              } else {
                return const HouseholdSetupScreen();
              }
            },
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _logOutRevenueCat(context);
        });

        return const AuthScreen();
      },
    );
  }

  Future<void> _logInRevenueCat(BuildContext context, String userId) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.originalAppUserId == userId) {
        if (context.mounted) {
          context.read<RevenueProvider>().setCustomerInfo(customerInfo);
        }
        return;
      }

      final logInResult = await Purchases.logIn(userId);
      if (context.mounted) {
        context.read<RevenueProvider>().setCustomerInfo(
          logInResult.customerInfo,
        );
      }
    } catch (e) {
      print("RevenueCat login error: $e");
    }
  }

  Future<void> _logOutRevenueCat(BuildContext context) async {
    try {
      final isAnonymous = await Purchases.isAnonymous;
      if (!isAnonymous) {
        if (context.mounted) {
          context.read<RevenueProvider>().setCustomerInfo(null);
        }
        await Purchases.logOut();
      }
    } catch (e) {
      print("RevenueCat logout error: $e");
    }
  }

  Future<void> _setupNotifications(User user) async {
    // ... (Votre code existant pour les notifs)
    final messaging = FirebaseMessaging.instance;
    try {
      await messaging.requestPermission();
      final String? token = await messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(user.uid, token);
      }
    } catch (e) {
      print("Notification setup error: $e");
    }
  }

  Future<void> _saveTokenToFirestore(String userId, String token) async {
    final tokenRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('deviceTokens')
        .doc(token);

    await tokenRef.set({
      'createdAt': FieldValue.serverTimestamp(),
      // 'platform': Theme.of(context).platform.toString(), // Attention context peut être instable ici
      'platform': 'mobile', // Plus sûr
    });
  }
}
