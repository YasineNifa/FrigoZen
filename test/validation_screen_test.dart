import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frigo_zen/screens/validation/validation_screen.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('ValidationScreen displays canonicalName by default', (WidgetTester tester) async {
    final scannedItems = [
      {
        'name': 'Messy OCR Name',
        'canonicalName': 'Clean Name',
        'quantity': 1,
      },
      {
        'name': 'Just Name',
        'quantity': 1,
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('fr')],
        home: ValidationScreen(scannedItems: scannedItems),
      ),
    );

    await tester.pumpAndSettle();

    // Check if the first item displays the OCR name (User preference)
    expect(find.text('Messy OCR Name'), findsOneWidget);
    expect(find.text('Clean Name'), findsNothing);

    // Check if the second item displays the name (fallback)
    expect(find.text('Just Name'), findsOneWidget);
  });

  testWidgets('ValidationScreen parses quantity from name', (WidgetTester tester) async {
    final scannedItems = [
      {
        'name': '4 Laits',
        'quantity': 1,
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('fr')],
        home: ValidationScreen(scannedItems: scannedItems),
      ),
    );

    await tester.pumpAndSettle();

    // Check if name is cleaned to "Laits"
    expect(find.text('Laits'), findsOneWidget);
    // Check if quantity is updated to 4
    expect(find.text('4'), findsOneWidget);
  });
}
