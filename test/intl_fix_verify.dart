import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  test('DateFormat works after global initialization', () async {
    await initializeDateFormatting(null, null);
    
    try {
      final date = DateTime.now();
      final formatter = DateFormat.E('fr');
      final result = formatter.format(date);
      print('Formatted: $result');
      expect(result, isNotEmpty);
    } catch (e) {
      fail('Should not have thrown an error: $e');
    }
  });
}
