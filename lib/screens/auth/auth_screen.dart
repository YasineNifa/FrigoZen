import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth package

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Firebase Auth Instance
  final _auth = FirebaseAuth.instance;

  // Key to validate our form
  final _formKey = GlobalKey<FormState>();

  // Email & Password controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State Variables
  bool _isLoginMode = true; // Default mode is "Login"
  bool _isLoading = false; // To display a loading indicator

  // Submit the form
  void _submitForm() async {
    // Validate the form
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    // Update the loading state
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLoginMode) {
        // Mode Login
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Mode Sinup
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      // Si on arrive ici, le login/signup a réussi
      // L'aiguilleur (qu'on va créer) fera le reste.
    } on FirebaseAuthException catch (error) {
      // Map Firebase error codes to user-friendly messages
      String errorMessage = "An error occurred, please check your credentials.";
      if (error.code == 'user-not-found') {
        errorMessage = "No user found for that email.";
      } else if (error.code == 'wrong-password') {
        errorMessage = "Password is incorrect.";
      } else if (error.code == 'email-already-in-use') {
        errorMessage = "This email is already in use.";
      }

      // Display an error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      // Update the loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // login and signup toggle
  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  _isLoginMode ? 'FrigoZen Login' : 'Create an Account',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true, // Hide the password
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return 'The password must be at least 6 characters long.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit button (with loading indicator)
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: _submitForm,
                    child: Text(_isLoginMode ? 'Login' : "Sign Up"),
                  ),

                const SizedBox(height: 16),

                if (!_isLoading)
                  TextButton(
                    onPressed: _toggleMode,
                    child: Text(
                      _isLoginMode
                          ? "No account? Sign up"
                          : 'Already have an account? Login',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
