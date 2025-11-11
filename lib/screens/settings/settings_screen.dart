// import 'package:flutter/material.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings'), centerTitle: true),
//       body: const Center(child: Text('Settings Screen')),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // On importe Firebase Auth

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The user currently logged in
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        children: [
          if (user != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Account Information'),
              subtitle: Text(user.email ?? 'No email available'),
            ),

          const Divider(),

          // Logout button
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red[700]),
            title: Text('Logout', style: TextStyle(color: Colors.red[700])),
            onTap: () {
              FirebaseAuth.instance.signOut();
              // The AuthGate will detect this change
              // and automatically show the login screen.
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete Account'),
            onTap: () {
              // TODO: Ajouter la logique de suppression de compte
              // (Pour le MVP, un simple bouton de déconnexion suffit)
              // Note: Deleting a user is a sensitive operation and should
              // typically involve re-authentication and confirmation.
            },
          ),
        ],
      ),
    );
  }
}
