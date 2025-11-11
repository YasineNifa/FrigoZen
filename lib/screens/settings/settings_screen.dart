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
import 'package:cloud_functions/cloud_functions.dart';

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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Tester le Backend (helloWorld)'),
            onTap: () async {
              // 3. C'est ici qu'on appelle la fonction
              try {
                // Initialiser l'instance des fonctions
                final functions = FirebaseFunctions.instanceFor(region: "us-central1"); // Mettez votre région si différente

                // Obtenir la référence de notre fonction par son nom
                final callable = functions.httpsCallable('helloWorld');

                // Afficher un "loading"
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appel au backend en cours...')),
                );

                // Appeler la fonction (on n'envoie pas de données)
                final result = await callable.call();

                // 4. On a la réponse !
                final data = result.data as Map<String, dynamic>;
                final message = data['message'];
                
                // Afficher le message de succès
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Succès : $message'),
                    backgroundColor: Colors.green[700],
                  ),
                );

              } on FirebaseFunctionsException catch (error) {
                // 5. Gérer les erreurs (ex: non connecté)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur : ${error.message}'),
                    backgroundColor: Colors.red[700],
                  ),
                );
              } catch (error) {
                // Gérer les autres erreurs
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur inconnue : $error'),
                    backgroundColor: Colors.red[700],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
