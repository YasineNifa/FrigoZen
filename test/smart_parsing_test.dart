import 'package:flutter_test/flutter_test.dart';

class SmartParser {
  static Map<String, dynamic> parse(String rawName) {
    // Regex to match "Quantity x Name" or "Quantity Name"
    // ^(\d+)\s*[xX]?\s*(.*)$
    final regex = RegExp(r'^(\d+)\s*[xX]?\s*(.*)$');
    final match = regex.firstMatch(rawName);

    if (match != null) {
      final quantity = int.parse(match.group(1)!);
      final name = match.group(2)!.trim();
      return {'quantity': quantity, 'name': name};
    }

    return {'quantity': 1, 'name': rawName};
  }
}

void main() {
  group('SmartParser', () {
    test('parses "4 Laits"', () {
      final result = SmartParser.parse('4 Laits');
      expect(result['quantity'], 4);
      expect(result['name'], 'Laits');
    });

    test('parses "2 x Beurre"', () {
      final result = SmartParser.parse('2 x Beurre');
      expect(result['quantity'], 2);
      expect(result['name'], 'Beurre');
    });

    test('parses "2xBeurre"', () {
      final result = SmartParser.parse('2xBeurre');
      expect(result['quantity'], 2);
      expect(result['name'], 'Beurre');
    });

    test('parses "10  Pommes"', () {
      final result = SmartParser.parse('10  Pommes');
      expect(result['quantity'], 10);
      expect(result['name'], 'Pommes');
    });

    test('returns default for "Pommes"', () {
      final result = SmartParser.parse('Pommes');
      expect(result['quantity'], 1);
      expect(result['name'], 'Pommes');
    });
    
    test('returns default for "Coca Cola"', () {
      final result = SmartParser.parse('Coca Cola');
      expect(result['quantity'], 1);
      expect(result['name'], 'Coca Cola');
    });
  });
}
