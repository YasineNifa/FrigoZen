import 'package:frigo_zen/services/trial_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const days = 15;
  final start = DateTime(2026, 1, 1, 12, 0);

  test('endDate is null without a start date', () {
    expect(TrialCalculator.endDate(null, days), isNull);
  });

  test('endDate adds the trial duration', () {
    expect(
      TrialCalculator.endDate(start, days),
      DateTime(2026, 1, 16, 12, 0),
    );
  });

  group('isInTrial', () {
    test('true while before the end date', () {
      final now = start.add(const Duration(days: 7));
      expect(TrialCalculator.isInTrial(TrialCalculator.endDate(start, days), now), isTrue);
    });

    test('false exactly at the end date', () {
      final now = TrialCalculator.endDate(start, days)!;
      expect(TrialCalculator.isInTrial(now, now), isFalse);
    });

    test('false after the end date', () {
      final now = start.add(const Duration(days: 20));
      expect(TrialCalculator.isInTrial(TrialCalculator.endDate(start, days), now), isFalse);
    });

    test('false when no start date is known', () {
      expect(TrialCalculator.isInTrial(null), isFalse);
    });
  });

  group('isExpired', () {
    test('true after the end date', () {
      final now = start.add(const Duration(days: 16));
      expect(TrialCalculator.isExpired(TrialCalculator.endDate(start, days), now), isTrue);
    });

    test('false before the end date', () {
      final now = start.add(const Duration(days: 5));
      expect(TrialCalculator.isExpired(TrialCalculator.endDate(start, days), now), isFalse);
    });
  });

  group('daysRemaining', () {
    test('counts whole days left', () {
      final now = start.add(const Duration(days: 5));
      expect(TrialCalculator.daysRemaining(TrialCalculator.endDate(start, days), now), 10);
    });

    test('clamps to zero once expired', () {
      final now = start.add(const Duration(days: 30));
      expect(TrialCalculator.daysRemaining(TrialCalculator.endDate(start, days), now), 0);
    });

    test('zero when no start date', () {
      expect(TrialCalculator.daysRemaining(null), 0);
    });
  });
}
