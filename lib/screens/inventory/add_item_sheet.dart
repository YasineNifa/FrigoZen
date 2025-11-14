import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 import 'package:cloud_functions/cloud_functions.dart';

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _quantity = 1;
  bool _isLoading = false;

  // Get the path to the user's inventory collection
  CollectionReference _getInventoryCollection() {
    // Get the currently logged-in user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is currently logged in.");
    }
    // Return the path to THEIR inventory sub-collection
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('inventory');
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String userTypedName = _nameController.text.trim();
      try {
        final functions = FirebaseFunctions.instanceFor(region: "us-central1");
        final callable = functions.httpsCallable('canonicalizeName');
        final result = await callable.call({'productName': userTypedName});

        final String canonicalName = result.data['canonicalName'] ?? userTypedName;
        // Add the new article to the collection
        await _getInventoryCollection().add({
          'name': userTypedName,
          'canonicalName': canonicalName,
          'quantity': _quantity,
          'location': 'Frigo', // TODO: Make dynamic later by using AI
          'createdAt': Timestamp.now(),
        });

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${error.toString()}")));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Item',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name (ex: Lait)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                ),
                Text(
                  'Quantity : $_quantity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // const SizedBox(height: 16),
            // Sélecteur d'emplacement
            // ToggleButtons(
            //   isSelected: [
            //     _selectedLocation == 'Frigo',
            //     _selectedLocation == 'Placard',
            //   ],
            //   onPressed: (index) {
            //     setState(() {
            //       _selectedLocation = (index == 0) ? 'Frigo' : 'Placard';
            //     });
            //   },
            //   children: const [
            //     Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 16),
            //       child: Text('Frigo'),
            //     ),
            //     Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 16),
            //       child: Text('Placard'),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.green,
                ),
                onPressed: _saveItem,

                child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
