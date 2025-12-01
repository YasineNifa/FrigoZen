import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6B9C5F);
  static const Color backgroundColor = Color(0xFFF9F9F9);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFE57373);
  
  // Text Colors
  static const Color textDark = Colors.black87;
  static const Color textGrey = Color(0xFF757575); // Colors.grey[600] approx
  
  // Status Colors
  static final Color statusExpired = Colors.red[700]!;
  static final Color statusWarning = Colors.orange[700]!;
  static final Color statusSafe = Colors.green[700]!;
  static final Color statusNeutral = Colors.grey[700]!;

  // UI Elements
  static final Color shadowColor = Colors.black.withOpacity(0.04);
  static const Color quantityControlBackground = Color(0xFFF5F7FA);

  static ThemeData get lightTheme {
    return ThemeData(
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
        error: errorColor,
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
    );
  }
}
