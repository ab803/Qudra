import 'package:flutter/foundation.dart';

/// Validates and normalizes HH:mm time format strings
class TimeFormatValidator {
  TimeFormatValidator._();

  /// Validates if a string is in valid HH:mm format (24-hour)
  /// Returns true if format is valid (00:00 - 23:59)
  static bool isValidHHmm(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final parts = value.split(':');
    if (parts.length != 2) return false;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;

    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  /// Normalizes various time formats to HH:mm format
  /// Supports: HH:mm, h:mm AM/PM
  /// Returns null if format is invalid
  static String? normalizeToHHmm(String? raw) {
    if (raw == null) return null;
    var s = raw.trim();
    if (s.isEmpty) return null;

    // HH:mm format
    final m1 = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(s);
    if (m1 != null) {
      final h = int.parse(m1.group(1)!);
      final m = int.parse(m1.group(2)!);
      if (h >= 0 && h <= 23 && m >= 0 && m <= 59) {
        return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      }
    }

    // h:mm AM/PM format
    final m2 = RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$').firstMatch(s);
    if (m2 != null) {
      var h = int.parse(m2.group(1)!);
      final m = int.parse(m2.group(2)!);
      final ap = m2.group(3)!.toUpperCase();

      if (h < 1 || h > 12 || m < 0 || m > 59) return null;

      if (ap == 'AM') {
        if (h == 12) h = 0;
      } else {
        if (h != 12) h += 12;
      }

      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    }

    return null;
  }
}