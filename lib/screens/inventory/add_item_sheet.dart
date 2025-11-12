import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

      try {
        // Add the new article to the collection
        await _getInventoryCollection().add({
          'name': _nameController.text.trim(),
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
          mainAxisSize: MainAxisSize.min, // Take the least vertical space
          children: [
            Text(
              'Add New Item',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            // Champ Nom
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
                    if (_quantity > 1) { // On ne peut pas descendre sous 1
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
                ),
                onPressed: _saveItem,
                child: const Text('Save'),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
