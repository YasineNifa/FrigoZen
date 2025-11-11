import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/screens/auth/auth_screen.dart';
import 'package:frigo_zen/screens/core/navigation_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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
          // We show the main app page (our NavigationShell)
          return const NavigationShell();
        }

        // We show the authentication screen (AuthScreen) if the user is not logged in
        return const AuthScreen();
      },
    );
  }
}
