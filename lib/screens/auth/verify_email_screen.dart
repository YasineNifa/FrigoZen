import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const int _resendCooldownSeconds = 60;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Color _primaryColor = const Color(0xFF6B9C5F);

  Timer? _autoCheckTimer;
  Timer? _cooldownTimer;
  bool _isChecking = false;
  int _cooldownRemaining = 0;

  @override
  void initState() {
    super.initState();
    // Vérification automatique toutes les 3 secondes :
    // dès que l'utilisateur clique sur le lien, AuthGate bascule
    // automatiquement vers l'app (via le stream userChanges).
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        await _auth.currentUser?.reload();
      } catch (_) {
        // Silencieux : réseau indisponible, on retentera au prochain tick.
      }
    });
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldownRemaining = _resendCooldownSeconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _cooldownRemaining--);
      if (_cooldownRemaining <= 0) timer.cancel();
    });
  }

  Future<void> _resendEmail() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Template dans la langue de l'app.
      await _auth.setLanguageCode(
        Localizations.localeOf(context).languageCode,
      );
      await _auth.currentUser?.sendEmailVerification();
      _startCooldown();
      if (mounted) _showSnack(l10n.authVerifyEmailSent, Colors.green);
    } catch (_) {
      if (mounted) _showSnack(l10n.authErrorGeneric, Colors.red[400]!);
    }
  }

  Future<void> _checkManually() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isChecking = true);
    try {
      await _auth.currentUser?.reload();
      // Si vérifié, AuthGate reconstruit automatiquement l'app.
      if (!(_auth.currentUser?.emailVerified ?? false) && mounted) {
        _showSnack(l10n.verifyEmailNotVerifiedYet, Colors.orange[700]!);
      }
    } catch (_) {
      if (mounted) _showSnack(l10n.authErrorGeneric, Colors.red[400]!);
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _signOut() async {
    _autoCheckTimer?.cancel();
    _cooldownTimer?.cancel();
    await _auth.signOut();
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final email = _auth.currentUser?.email ?? '';

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Background Image
            Positioned.fill(
              child: Image.asset('assets/images/zen.jpg', fit: BoxFit.cover),
            ),

            // 2. Overlay Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_outlined,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          l10n.verifyEmailTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Subtitle with the user's email
                        Text(
                          l10n.verifyEmailSubtitle(email),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        Text(
                          l10n.verifyEmailBody,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Check button
                        ElevatedButton(
                          onPressed: _isChecking ? null : _checkManually,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: _primaryColor.withValues(alpha: 0.5),
                          ),
                          child: _isChecking
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  l10n.verifyEmailCheckBtn,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),

                        // Resend button (with cooldown)
                        TextButton(
                          onPressed:
                              _cooldownRemaining > 0 ? null : _resendEmail,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            _cooldownRemaining > 0
                                ? l10n.verifyEmailResendIn(_cooldownRemaining)
                                : l10n.verifyEmailResend,
                            style: TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              color: _cooldownRemaining > 0
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Sign out
                        TextButton(
                          onPressed: _signOut,
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Colors.white.withValues(alpha: 0.6),
                          ),
                          child: Text(l10n.verifyEmailSignOut),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
