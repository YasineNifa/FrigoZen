/// Pure, side-effect-free helpers for the free-trial logic so the date math
/// can be unit-tested without Firebase or RevenueCat.
class TrialCalculator {
  /// End of the trial, or null when no start date is known.
  static DateTime? endDate(DateTime? startDate, int days) {
    if (startDate == null) return null;
    return startDate.add(Duration(days: days));
  }

  static bool isInTrial(DateTime? end, [DateTime? now]) {
    if (end == null) return false;
    now ??= DateTime.now();
    return now.isBefore(end);
  }

  static bool isExpired(DateTime? end, [DateTime? now]) {
    if (end == null) return false;
    now ??= DateTime.now();
    return now.isAfter(end);
  }

  static int daysRemaining(DateTime? end, [DateTime? now]) {
    if (end == null) return 0;
    now ??= DateTime.now();
    final diff = end.difference(now).inDays;
    return diff < 0 ? 0 : diff;
  }
}
