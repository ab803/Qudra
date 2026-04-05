class DateTimeHelpers {
  DateTimeHelpers._();

  /// Returns today's date as yyyy-MM-dd format string
  /// Used as primary key for reminder logs
  static String todayKey() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Generates a unique log ID combining date and reminder ID
  /// Format: yyyy-MM-dd__reminderId
  static String generateLogId(String reminderId) {
    return '${todayKey()}__$reminderId';
  }

  /// Parses HH:mm time format and returns DateTime for today at that time
  /// Returns null if format is invalid
  static DateTime? scheduledDateTimeToday(String? hhmm) {
    if (hhmm == null || hhmm.trim().isEmpty) return null;

    final parts = hhmm.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}