// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Assurez-vous d'importer votre écran d'authentification (login)
import 'package:frigo_zen/screens/core/auth_gate.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Marque l'onboarding comme vu et navigue vers l'AuthGate
  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc uniforme
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: [
              // Page 1: Stop Wasting Money
              _buildOnboardingPage(
                context: context,
                imagePath:
                    'assets/onboarding/stop_wasting_money.png', // Assurez-vous que ce chemin est correct
                title: "Arrêtez de jeter votre argent.",
                description:
                    "FrigoZen vous aide à consommer vos aliments avant qu'ils n'expirent.",
                buttonText: "Continuer",
                onButtonPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeIn,
                ),
              ),

              // Page 2: Know What to Eat
              _buildOnboardingPage(
                context: context,
                imagePath:
                    'assets/onboarding/know_what_to_eat.png', // Assurez-vous que ce chemin est correct
                title: "Sachez toujours quoi manger.",
                description:
                    "Recevez des recettes simples basées sur ce que vous avez déjà dans votre frigo.",
                buttonText: "Commencer", // Texte harmonisé
                onButtonPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeIn,
                ),
              ),

              // Page 3: Smart Shopping (Dernière page)
              _buildOnboardingPage(
                context: context,
                imagePath:
                    'assets/onboarding/smart_shopping.png', // Assurez-vous que ce chemin est correct
                title: "Des courses enfin intelligentes.",
                description:
                    "Ne rachetez plus jamais en double. Scannez, c'est ajouté, votre liste est à jour.",
                buttonText: "Commencer l'aventure",
                onButtonPressed: _finishOnboarding, // Termine l'onboarding
              ),
            ],
          ),

          // Indicateurs de page (points)
          Positioned(
            bottom: 190, // Positionnement ajusté au-dessus du bouton
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => _buildDot(index)),
            ),
          ),

          // Bouton "Passer" en haut à droite
          if (_currentPage <
              2) // N'affiche "Passer" que si ce n'est pas la dernière page
            Positioned(
              top: 50, // Ajustement pour l'espace AppBar/StatusBar
              right: 20,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text(
                  "Passer",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget pour construire chaque page d'onboarding
  Widget _buildOnboardingPage({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Illustration
          Image.asset(
            imagePath,
            height:
                MediaQuery.of(context).size.height * 0.35, // Taille dynamique
          ),
          const Spacer(flex: 1),
          // Titre
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333), // Gris foncé pour les titres
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const Spacer(flex: 2),
          // Bouton Principal
          SizedBox(
            width: double.infinity, // Bouton pleine largeur
            height: 50,
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF6B9C5F,
                ), // Un beau vert FrigoZen
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0, // Pas d'ombre pour un look plat
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20), // Espace sous le bouton
          // Bouton secondaire "Se connecter" sur la dernière page
          if (_currentPage == 2) // Seulement sur la dernière page
            TextButton(
              onPressed: _finishOnboarding, // Navigue aussi vers l'AuthGate
              child: const Text(
                "J'ai déjà un compte",
                style: TextStyle(
                  color: Color(0xFF6B9C5F), // Même vert que le bouton principal
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Spacer(flex: 1), // Espace en bas
        ],
      ),
    );
  }

  // Widget pour les indicateurs de page (les points)
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: _currentPage == index ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF6B9C5F) // Vert FrigoZen pour le point actif
            : Colors.grey[300], // Gris clair pour les inactifs
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
