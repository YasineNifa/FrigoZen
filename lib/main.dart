import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/core/auth_gate.dart';
import 'package:frigo_zen/providers_setup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frigo_zen/screens/onboarding/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:frigo_zen/services/revenue_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:frigo_zen/viewmodels/inventory_view_model.dart';
import 'package:frigo_zen/viewmodels/shopping_view_model.dart';
import 'package:frigo_zen/locator.dart';
import 'package:frigo_zen/screens/core/navigation_controller.dart';
import 'package:frigo_zen/viewmodels/meal_planner_view_model.dart';
import 'package:frigo_zen/viewmodels/recipes_view_model.dart';

// 2. Créer un "Provider" simple pour notre inventaire : REMOVED (Dead Code)

// The main function must be "async" to await initialization
Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(null, null);
  // Initialize Firebase with default options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.requestPermission();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  await Purchases.configure(
    PurchasesConfiguration("test_khYjXVBlKWQdgHIghJZqvHlaXyV"),// // goog_jffnkmLisnUHGaDInMHpqQUcLra
  );

  setupLocator();

  final revenueProvider = locator<RevenueProvider>();
  await revenueProvider.init();

  runApp(
    MultiProvider(
      providers: getApplicationProviders(),
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
          // background: backgroundColor, // Deprecated
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
            .copyWith(
              titleLarge: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20, // Reduced from 22
                color: Colors.black87,
              ),
              titleMedium: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16, // Reduced from 18
                color: Colors.black87,
              ),
              displayLarge: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              displayMedium: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
        appBarTheme: AppBarTheme(
          backgroundColor: cardColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20, // Kept at 20 (consistent with titleLarge)
          ),
        ),
        useMaterial3: true,
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: Colors.green[100],
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ), // Reduced from 14 to 11
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('de'),
        Locale('es'),
        Locale('ar'),
      ],
      home: hasSeenOnboarding ? const AuthGate() : const OnboardingScreen(),
      // home: const OnboardingScreen(),
    );
  }
}
