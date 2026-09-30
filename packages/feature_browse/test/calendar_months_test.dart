import 'package:core/core.dart';
import 'package:feature_browse/src/availability/calendar_months.dart';
import 'package:flutter_test/flutter_test.dart';

LocalDate _d(String iso) => LocalDate.parse(iso);

void main() {
  group('firstOfMonth', () {
    test('goes back to the first day', () {
      expect(firstOfMonth(_d('2026-03-15')), _d('2026-03-01'));
      expect(firstOfMonth(_d('2026-03-01')), _d('2026-03-01'));
      expect(firstOfMonth(_d('2026-12-31')), _d('2026-12-01'));
    });
  });

  group('addMonths', () {
    test('moves forward and rolls over the year', () {
      expect(addMonths(_d('2026-03-01'), 1), _d('2026-04-01'));
      expect(addMonths(_d('2026-12-01'), 1), _d('2027-01-01'));
      expect(addMonths(_d('2026-03-01'), 12), _d('2027-03-01'));
    });

    test('moves back and rolls under the year', () {
      expect(addMonths(_d('2026-03-01'), -1), _d('2026-02-01'));
      expect(addMonths(_d('2026-01-01'), -1), _d('2025-12-01'));
    });

    test('zero stays put', () {
      expect(addMonths(_d('2026-03-01'), 0), _d('2026-03-01'));
    });
  });

  group('the months the calendar shows', () {
    final today = _d('2026-03-15');

    test('run from this month to twelve months ahead', () {
      expect(firstShownMonth(today), _d('2026-03-01'));
      expect(lastShownMonth(today), _d('2027-03-01'));
    });

    test('a month inside the range is left alone', () {
      expect(clampShownMonth(_d('2026-07-01'), today), _d('2026-07-01'));
      expect(clampShownMonth(_d('2026-03-01'), today), _d('2026-03-01'));
      expect(clampShownMonth(_d('2027-03-01'), today), _d('2027-03-01'));
    });

    test('a month that is over opens on the current one', () {
      expect(clampShownMonth(_d('2026-01-01'), today), _d('2026-03-01'));
      expect(clampShownMonth(_d('2025-06-01'), today), _d('2026-03-01'));
    });

    test('a month too far ahead opens on the last one', () {
      expect(clampShownMonth(_d('2027-04-01'), today), _d('2027-03-01'));
      expect(clampShownMonth(_d('2030-01-01'), today), _d('2027-03-01'));
    });
  });

  group('availabilityWindow', () {
    final today = _d('2026-03-15');

    test('the current month starts today and ends on the 1st of the next', () {
      final window = availabilityWindow(_d('2026-03-01'), today);

      expect(window.start, _d('2026-03-15'));
      expect(window.end, _d('2026-04-01'));
      expect(window.nights, 17);
    });

    test('a later month is the whole month, half-open', () {
      final window = availabilityWindow(_d('2026-04-01'), today);

      expect(window.start, _d('2026-04-01'));
      expect(window.end, _d('2026-05-01'));
      expect(window.nights, 30);
      expect(window.contains(_d('2026-04-30')), isTrue);
      expect(window.contains(_d('2026-05-01')), isFalse);
    });

    test('on the 1st, the current month is the whole month', () {
      final window = availabilityWindow(_d('2026-03-01'), _d('2026-03-01'));

      expect(window.start, _d('2026-03-01'));
      expect(window.nights, 31);
    });

    test('on the last day, the current month is that one night', () {
      final window = availabilityWindow(_d('2026-03-01'), _d('2026-03-31'));

      expect(window.start, _d('2026-03-31'));
      expect(window.end, _d('2026-04-01'));
      expect(window.nights, 1);
    });

    test('December ends on the 1st of January', () {
      final window = availabilityWindow(_d('2026-12-01'), today);

      expect(window.end, _d('2027-01-01'));
      expect(window.nights, 31);
    });

    test('every month in range is far below the API limit of 366 nights', () {
      for (var i = 0; i <= calendarMonthsAhead; i++) {
        final month = addMonths(firstShownMonth(today), i);
        expect(availabilityWindow(month, today).nights, lessThanOrEqualTo(31));
      }
    });
  });
}
