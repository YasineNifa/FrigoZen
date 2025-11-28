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
  // Mémoire locale pour éviter de spammer les APIs
  String? _currentRevenueCatId;
  bool _notificationsSetupDone = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Chargement initial
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Utilisateur CONNECTÉ
        if (snapshot.hasData) {
          final user = snapshot.data!;

          // --- A. Notifications (Une seule fois) ---
          if (!_notificationsSetupDone) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _setupNotifications(user);
              _notificationsSetupDone = true; // On marque comme fait
            });
          }

          // --- B. Stream Firestore (Profil Utilisateur) ---
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

              // Analyse des données
              final data =
                  userDocSnapshot.hasData && userDocSnapshot.data!.exists
                  ? userDocSnapshot.data!.data() as Map<String, dynamic>?
                  : null;

              final householdId = data?['householdId'];

              // --- C. Logique RevenueCat (Intelligente) ---
              // On détermine quel ID utiliser (Maison ou User)
              final revenueCatIdToUse = householdId ?? user.uid;

              // OPTIMISATION MAJEURE :
              // On ne déclenche la connexion QUE si l'ID a changé depuis la dernière fois.
              // Cela empêche de spammer RevenueCat à chaque reconstruction de l'écran.
              if (_currentRevenueCatId != revenueCatIdToUse) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _logInRevenueCat(context, revenueCatIdToUse);
                });
              }

              // --- D. Navigation ---
              if (householdId != null) {
                return const NavigationShell();
              }
              return const HouseholdSetupScreen();
            },
          );
        }

        // 3. Utilisateur DÉCONNECTÉ
        // Si on pensait être connecté, on nettoie
        if (_currentRevenueCatId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _logOutRevenueCat(context);
          });
        }

        return const AuthScreen();
      },
    );
  }

  // --- FONCTIONS HELPERS ---

  Future<void> _logInRevenueCat(BuildContext context, String idToLogIn) async {
    // Double sécurité
    if (_currentRevenueCatId == idToLogIn) return;

    try {
      print("RevenueCat: Connexion en cours pour l'ID: $idToLogIn");

      // On met à jour la mémoire locale tout de suite pour bloquer les appels suivants
      _currentRevenueCatId = idToLogIn;

      final logInResult = await Purchases.logIn(idToLogIn);

      if (context.mounted) {
        context.read<RevenueProvider>().setCustomerInfo(
          logInResult.customerInfo,
        );
      }
    } catch (e) {
      print("RevenueCat login error: $e");
      // En cas d'erreur, on reset pour retenter plus tard si besoin
      _currentRevenueCatId = null;
    }
  }

  Future<void> _logOutRevenueCat(BuildContext context) async {
    try {
      // Reset des états locaux
      _currentRevenueCatId = null;
      _notificationsSetupDone = false;

      if (context.mounted) {
        context.read<RevenueProvider>().setCustomerInfo(null);
      }

      final isAnonymous = await Purchases.isAnonymous;
      if (!isAnonymous) {
        await Purchases.logOut();
        print("RevenueCat: logout.");
      }
    } catch (e) {
      print("RevenueCat logout error: $e");
    }
  }

  Future<void> _setupNotifications(User user) async {
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
      'platform': 'mobile',
    });
  }
}
