import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frigo_zen/main.dart' as app;
import 'package:frigo_zen/screens/inventory/inventory_screen.dart';
import 'package:frigo_zen/screens/shopping/shopping_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FrigoZen Critical Flows', () {
    testWidgets('Add Item Flow: Add item to inventory and verify it appears',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Verify we are on Inventory Screen (default)
      expect(find.byType(InventoryScreen), findsOneWidget);

      // 2. Tap FAB to add item
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // 3. Tap "Saisie manuelle" (Manual Entry)
      final manualEntry = find.text('Saisie manuelle'); // Assuming this text exists
      if (manualEntry.evaluate().isNotEmpty) {
          await tester.tap(manualEntry);
          await tester.pumpAndSettle();
      } else {
          // Fallback if the bottom sheet structure is different or text is different
          // Try finding the icon
          await tester.tap(find.byIcon(Icons.add));
          await tester.pumpAndSettle();
      }

      // 4. Enter item name "Test Apple"
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test Apple');
      await tester.pumpAndSettle();

      // 5. Save item
      final saveBtn = find.text('Ajouter'); // Assuming localized text
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // 6. Verify item appears in list
      expect(find.text('Test Apple'), findsOneWidget);
    });

    testWidgets('Shopping List Flow: Add item, check it, move to inventory',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Navigate to Shopping Screen
      final shoppingTab = find.byIcon(Icons.shopping_cart);
      await tester.tap(shoppingTab);
      await tester.pumpAndSettle();
      expect(find.byType(ShoppingScreen), findsOneWidget);

      // 2. Add item "Test Banana"
      final addField = find.byType(TextField);
      await tester.enterText(addField, 'Test Banana');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // 3. Verify item appears
      expect(find.text('Test Banana'), findsOneWidget);

      // 4. Check the item
      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // 5. Tap "Ajouter au frigo" (Add to fridge)
      final addToFridgeBtn = find.byIcon(Icons.kitchen);
      await tester.tap(addToFridgeBtn);
      await tester.pumpAndSettle();

      // 6. Verify item is removed from shopping list
      expect(find.text('Test Banana'), findsNothing);

      // 7. Navigate to Inventory and verify item is there
      final inventoryTab = find.byIcon(Icons.kitchen); // Assuming icon for inventory tab
      await tester.tap(inventoryTab);
      await tester.pumpAndSettle();
      expect(find.text('Test Banana'), findsOneWidget);
    });
  });
}
