import 'package:flutter/foundation.dart' show immutable;

/// A calendar date with no time and no timezone: `2026-03-01` means the first
/// of March everywhere. Check-in, check-out, blocked days and availability are
/// all dates like this, so they never go through a `DateTime`, which would
/// carry a timezone and can shift the day.
///
/// Arithmetic runs in UTC internally, where a day is always 24 hours, so a
/// daylight-saving change can never add or drop a day.
@immutable
final class LocalDate implements Comparable<LocalDate> {
  const LocalDate._(this.year, this.month, this.day);

  /// Throws [ArgumentError] for a date that does not exist (2025-02-30).
  factory LocalDate(int year, int month, int day) {
    final date = tryCreate(year, month, day);
    if (date == null) {
      throw ArgumentError('Not a calendar date: $year-$month-$day');
    }
    return date;
  }

  /// Null when the date does not exist.
  static LocalDate? tryCreate(int year, int month, int day) {
    if (year < 1 || year > 9999) return null;
    final roundTrip = DateTime.utc(year, month, day);
    // DateTime rolls 02-30 over to 03-02; a date that changed does not exist.
    if (roundTrip.year != year ||
        roundTrip.month != month ||
        roundTrip.day != day) {
      return null;
    }
    return LocalDate._(year, month, day);
  }

  /// Strictly `YYYY-MM-DD`. Throws [FormatException] otherwise.
  factory LocalDate.parse(String value) =>
      tryParse(value) ??
      (throw FormatException('Expected a date as YYYY-MM-DD', value));

  static final _pattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  /// Null unless [value] is exactly `YYYY-MM-DD` and a real calendar date.
  static LocalDate? tryParse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) return null;
    return tryCreate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  /// Takes the year, month and day of [dateTime] exactly as they are, ignoring
  /// the time of day and the zone.
  factory LocalDate.fromDateTime(DateTime dateTime) =>
      LocalDate(dateTime.year, dateTime.month, dateTime.day);

  /// Today on this device's clock.
  factory LocalDate.today() => LocalDate.fromDateTime(DateTime.now());

  final int year;
  final int month;
  final int day;

  DateTime get _utc => DateTime.utc(year, month, day);

  /// Negative [days] go back. Rolls over months, years and leap days.
  LocalDate addDays(int days) =>
      LocalDate.fromDateTime(DateTime.utc(year, month, day + days));

  /// Whole days from this date to [other]; negative if [other] is earlier.
  int daysUntil(LocalDate other) => other._utc.difference(_utc).inDays;

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  bool operator <(LocalDate other) => isBefore(other);
  bool operator <=(LocalDate other) => compareTo(other) <= 0;
  bool operator >(LocalDate other) => isAfter(other);
  bool operator >=(LocalDate other) => compareTo(other) >= 0;

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  /// `YYYY-MM-DD`, the wire format.
  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
