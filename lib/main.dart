import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/core/auth_gate.dart';
import 'package:frigo_zen/screens/onboarding/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:frigo_zen/services/revenue_provider.dart';

// 2. Créer un "Provider" simple pour notre inventaire
// Il tiendra juste la liste des noms d'articles de l'inventaire.
class InventoryProvider with ChangeNotifier {
  List<String> _itemNames = []; // Liste privée

  // "Getter" public pour que les autres widgets puissent lire la liste
  List<String> get itemNames => _itemNames;

  // Fonction pour mettre à jour la liste
  void updateInventory(List<String> newItemNames) {
    _itemNames = newItemNames;
    notifyListeners(); // Informe les widgets qui écoutent que les données ont changé
  }

  // Fonction pour vérifier si un article existe (insensible à la casse)
  bool doesItemExist(String name) {
    final lowerCaseName = name.toLowerCase().trim();
    return _itemNames.any((item) => item.toLowerCase().trim() == lowerCaseName);
  }
}

// The main function must be "async" to await initialization
Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with default options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.requestPermission();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  await Purchases.configure(
    PurchasesConfiguration("test_khYjXVBlKWQdgHIghJZqvHlaXyV"),
  );
  final revenueProvider = RevenueProvider();
  await revenueProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => InventoryProvider()),
        ChangeNotifierProvider.value(value: revenueProvider),
      ],
      child: FrigoZenApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class FrigoZenApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const FrigoZenApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF6B9C5F);
    final Color backgroundColor = const Color(0xFFF9F9F9);
    const Color cardColor = Colors.white;
    return MaterialApp(
      title: "FrigoZen",
      theme: ThemeData(
        primaryColor: primaryColor,
        cardColor: cardColor,
        scaffoldBackgroundColor: backgroundColor,
        disabledColor: Colors.grey,
        applyElevationOverlayColor: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          surface: cardColor,
          background: backgroundColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: cardColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        useMaterial3: true,
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: Colors.green[100],
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: hasSeenOnboarding ? const AuthGate() : const OnboardingScreen(),
      // home: const OnboardingScreen(),
    );
  }
}
