import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final Color _primaryColor = const Color(0xFF6B9C5F);
    final Color _backgroundColor = const Color(0xFFF9F9F9);
    final Color _cardColor = Colors.white;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
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
            leading: Icon(Icons.logout, color: Colors.red[700]),
            title: Text('Logout', style: TextStyle(color: Colors.red[700])),
            onTap: () {
              FirebaseAuth.instance.signOut();
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
              try {
                final functions = FirebaseFunctions.instanceFor(
                  region: "us-central1",
                );
                final callable = functions.httpsCallable('helloWorld');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appel au backend en cours...')),
                );

                final result = await callable.call();
                final data = result.data as Map<String, dynamic>;
                final message = data['message'];

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Succès : $message'),
                    backgroundColor: Colors.green[700],
                  ),
                );
              } on FirebaseFunctionsException catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur : ${error.message}'),
                    backgroundColor: Colors.red[700],
                  ),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur inconnue : $error'),
                    backgroundColor: Colors.red[700],
                  ),
                );
              }
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Tester le Backend (Canonicalize Name)'),
            onTap: () async {
              try {
                final functions = FirebaseFunctions.instanceFor(
                  region: "us-central1",
                );
                final callable = functions.httpsCallable('canonicalizeName');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appel au backend en cours...')),
                );
                final result = await callable.call({'productName': 'mlik'});
                final data = result.data as Map<String, dynamic>;
                final message = data['canonicalName'];

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Succès : $message'),
                    backgroundColor: Colors.green[700],
                  ),
                );
              } on FirebaseFunctionsException catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur : ${error.message}'),
                    backgroundColor: Colors.red[700],
                  ),
                );
              } catch (error) {
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
