import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/screens/auth/auth_screen.dart';
import 'package:frigo_zen/screens/core/household_setup_screen.dart';
import 'package:frigo_zen/screens/core/navigation_shell.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
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
          debugPrint("AuthGate: User is logged in: ${snapshot.data?.uid}");

          final user = snapshot.data!;

          // --- A. Notifications & Sync (Une seule fois) ---
          if (!_notificationsSetupDone) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _setupNotifications(user);
              _syncUserData(user);
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

              // --- C. Navigation ---
              if (householdId != null) {
                return const NavigationShell();
              }
              return const HouseholdSetupScreen();
            },
          );
        }

        // 3. Utilisateur DÉCONNECTÉ
        return const AuthScreen();
      },
    );
  }

  // --- FONCTIONS HELPERS ---

  Future<void> _setupNotifications(User user) async {
    final messaging = FirebaseMessaging.instance;
    try {
      await messaging.requestPermission();
      final String? token = await messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(user.uid, token);
      }
    } catch (e) {
      debugPrint("Notification setup error: $e");
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

    // Also save to main user doc for simple Cloud Function access
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }

  Future<void> _syncUserData(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'emailVerified': user.emailVerified,
        'lastLogin': FieldValue.serverTimestamp(),
        'language': Localizations.localeOf(context).languageCode,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("User sync error: $e");
    }
  }
}
