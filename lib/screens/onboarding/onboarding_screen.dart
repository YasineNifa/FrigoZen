import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frigo_zen/screens/core/auth_gate.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: [
              _buildOnboardingPage(
                context: context,
                imagePath: 'assets/onboarding/stop_wasting_money.png',
                title: l10n.onboardingPage1Title,
                description: l10n.onboardingPage1Desc,
                buttonText: l10n.onboardingPage1Btn,
                onButtonPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeIn,
                ),
              ),

              // Page 2: Know What to Eat
              _buildOnboardingPage(
                context: context,
                imagePath: 'assets/onboarding/know_what_to_eat.png',
                title: l10n.onboardingPage2Title,
                description: l10n.onboardingPage2Desc,
                buttonText: l10n.onboardingPage2Btn,
                onButtonPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeIn,
                ),
              ),

              // Page 3: Smart Shopping (Dernière page)
              _buildOnboardingPage(
                context: context,
                imagePath: 'assets/onboarding/smart_shopping.png',
                title: l10n.onboardingPage3Title,
                description: l10n.onboardingPage3Desc,
                buttonText: l10n.onboardingPage3Btn,
                onButtonPressed: _finishOnboarding,
              ),
            ],
          ),

          Positioned(
            bottom: 190,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => _buildDot(index)),
            ),
          ),

          if (_currentPage < 2)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  l10n.onboardingSkip,
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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Illustration
          Image.asset(
            imagePath,
            height: MediaQuery.of(context).size.height * 0.35,
          ),
          const Spacer(flex: 1),
          // Titre
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
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
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B9C5F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
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
          const SizedBox(height: 20),
          if (_currentPage == 2)
            TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                l10n.onboardingHaveAccount,
                style: TextStyle(
                  color: Color(0xFF6B9C5F),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Spacer(flex: 1),
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
            ? const Color(0xFF6B9C5F)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
