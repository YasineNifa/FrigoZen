import 'package:flutter/material.dart';
import 'package:frigo_zen/services/household_service.dart';
import 'package:frigo_zen/screens/core/navigation_shell.dart';

class HouseholdSetupScreen extends StatefulWidget {
  const HouseholdSetupScreen({super.key});

  @override
  State<HouseholdSetupScreen> createState() => _HouseholdSetupScreenState();
}

class _HouseholdSetupScreenState extends State<HouseholdSetupScreen> {
  final _householdService = HouseholdService();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  void _submit(bool isCreating) async {
    setState(() => _isLoading = true);
    try {
      if (isCreating) {
        if (_nameController.text.isEmpty) throw Exception("Name is required");
        await _householdService.createHousehold(_nameController.text.trim());
      } else {
        if (_codeController.text.isEmpty) throw Exception("Code is required");
        await _householdService.joinHousehold(_codeController.text.trim());
      }

      // Redirect to Home page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NavigationShell()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error : ${e.toString().replaceAll('Exception: ', '')}",
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.home_work_outlined,
                size: 80,
                color: Color(0xFF6B9C5F),
              ),
              const SizedBox(height: 24),
              const Text(
                "Welcome home !",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "To begin, create your family space or join an existing one.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),

              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6B9C5F)),
                )
              else ...[
                // --- CARTE 1 : CREATE ---
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "🏠 Create a new family space",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Name of your family space",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _submit(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B9C5F),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Create"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.all(8), child: Text("OU")),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // --- CARTE 2 : REJOINDRE ---
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "🔗 Use a code to join an existing family space",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            labelText: "Invitation code (ex: FZ-1234)",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _submit(false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6B9C5F),
                              side: const BorderSide(color: Color(0xFF6B9C5F)),
                            ),
                            child: const Text("Join"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
