import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/screens/auth/auth_screen.dart';
import 'package:frigo_zen/screens/core/navigation_shell.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Create a stream to listen to authentication state changes
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // if the snapshot has data (i.e., the user is logged in)
        if (snapshot.hasData) {
          _setupNotifications(snapshot.data!);
          // We show the main app page (our NavigationShell)
          return const NavigationShell();
        }

        // We show the authentication screen (AuthScreen) if the user is not logged in
        return const AuthScreen();
      },
    );
  }

  Future<void> _setupNotifications(User user) async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    // Récupérer le "Token" (l'adresse unique de cet appareil)
    final String? token = await messaging.getToken();

    if (token == null) {
      print("Error: Could not get FCM token.");
      return;
    }
    print("User Token: $token");

    // Sauvegarder ce token dans Firestore
    await _saveTokenToFirestore(user.uid, token);
  }

  // Sauvegarder le token
  Future<void> _saveTokenToFirestore(String userId, String token) async {
    // La meilleure pratique est de stocker les tokens dans une sous-collection
    // pour que l'utilisateur puisse avoir PLUSIEURS appareils (téléphone + tablette)
    final tokenRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('deviceTokens')
        .doc(token); // le token = ID de document

    await tokenRef.set({
      'createdAt': FieldValue.serverTimestamp(),
      'platform': Theme.of(
        context,
      ).platform.toString(), // ex: "TargetPlatform.android"
    });
  }
}
