import 'package:flutter/foundation.dart' show immutable;

import 'local_date.dart';

/// A stretch of nights from [start] up to but NOT including [end]: a
/// half-open range `[start, end)`. Check-in is [start], check-out is [end].
///
/// 03-01 to 03-03 is the nights of the 1st and the 2nd. That is why
/// back-to-back bookings (one's check-out is the next one's check-in) do not
/// clash, and why [nights] is a plain subtraction.
@immutable
final class DateRange {
  /// Throws [ArgumentError] if [end] is before [start]. An empty range
  /// (`start == end`, zero nights) is allowed.
  DateRange(this.start, this.end) {
    if (end.isBefore(start)) {
      throw ArgumentError(
        'A range cannot end before it starts: $start to $end',
      );
    }
  }

  final LocalDate start;
  final LocalDate end;

  int get nights => start.daysUntil(end);
  bool get isEmpty => nights == 0;

  /// The start night is in, the end date is not.
  bool contains(LocalDate date) => date >= start && date < end;

  /// True when the two ranges share at least one night. Ranges that only
  /// touch (one ends the day the other starts) do not overlap, and an empty
  /// range has no nights to share.
  bool overlaps(DateRange other) {
    if (isEmpty || other.isEmpty) return false;
    return start < other.end && other.start < end;
  }

  /// True when every night of [other] is also a night of this range.
  bool containsRange(DateRange other) =>
      other.start >= start && other.end <= end;

  /// Each night in order: [start], the day after, and so on, up to the day
  /// before [end].
  Iterable<LocalDate> get nightDates sync* {
    for (var date = start; date < end; date = date.addDays(1)) {
      yield date;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start to $end';
}
