import 'package:flutter/material.dart';
import 'package:frigo_zen/screens/core/navigation_shell.dart';

void main() {
  runApp(const FrigoZenApp());
}

class FrigoZenApp extends StatelessWidget {
  const FrigoZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FrigoZen",
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: Colors.green[100],
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const NavigationShell(),
    );
  }
}
