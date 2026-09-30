import 'package:core/core.dart';

/// How many months ahead of the current one the calendar can go. Twelve covers
/// the longest stay the date filter allows.
const calendarMonthsAhead = 12;

/// The first day of the month [date] is in.
LocalDate firstOfMonth(LocalDate date) => LocalDate(date.year, date.month, 1);

/// The first day of the month [months] after (or before, if negative) the
/// month starting at [monthStart]. Rolls over years.
LocalDate addMonths(LocalDate monthStart, int months) => LocalDate.fromDateTime(
  DateTime.utc(monthStart.year, monthStart.month + months, 1),
);

/// The earliest month the calendar shows: the one [today] is in.
LocalDate firstShownMonth(LocalDate today) => firstOfMonth(today);

/// The latest month the calendar shows.
LocalDate lastShownMonth(LocalDate today) =>
    addMonths(firstOfMonth(today), calendarMonthsAhead);

/// [month] moved into the range the calendar shows, so a stale or far-away date
/// cannot open it on a month it cannot leave.
LocalDate clampShownMonth(LocalDate month, LocalDate today) {
  final first = firstShownMonth(today);
  final last = lastShownMonth(today);
  if (month < first) return first;
  if (month > last) return last;
  return month;
}

/// The nights to ask the API about for [month] (its first day): the whole month,
/// except that the current month starts today. Past days are never reported as
/// taken, so they are not asked for, and the request does not depend on how the
/// API treats a date in the past. Half-open, like every range here: it ends on
/// the first day of the next month.
DateRange availabilityWindow(LocalDate month, LocalDate today) {
  assert(
    month >= firstShownMonth(today),
    'The calendar never asks about a month that is over.',
  );
  return DateRange(month < today ? today : month, addMonths(month, 1));
}
