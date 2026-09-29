import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

LocalDate _d(String iso) => LocalDate.parse(iso);

void main() {
  group('LocalDate.parse', () {
    test('reads YYYY-MM-DD', () {
      final date = LocalDate.parse('2026-03-01');

      expect((date.year, date.month, date.day), (2026, 3, 1));
    });

    test('round trips through toIso, with zero padding', () {
      for (final iso in [
        '2026-03-01',
        '2026-12-31',
        '0999-01-09',
        '2024-02-29',
      ]) {
        expect(LocalDate.parse(iso).toIso(), iso);
      }
    });

    final invalid = <String, String>{
      'empty': '',
      'no separators': '20260301',
      'slashes': '2026/03/01',
      'single digit month': '2026-3-1',
      'two digit year': '26-03-01',
      'a time is attached': '2026-03-01T00:00:00Z',
      'trailing space': '2026-03-01 ',
      'leading space': ' 2026-03-01',
      'month 13': '2026-13-01',
      'month 00': '2026-00-10',
      'day 00': '2026-03-00',
      'day 32': '2026-03-32',
      'april 31': '2026-04-31',
      'feb 30': '2026-02-30',
      'feb 29 in a common year': '2025-02-29',
      'feb 29 in 1900 (not a leap year)': '1900-02-29',
      'year 0000': '0000-01-01',
      'letters': 'abcd-ef-gh',
      'a sign': '+026-03-01',
    };

    invalid.forEach((name, input) {
      test('rejects $name', () {
        expect(LocalDate.tryParse(input), isNull);
        expect(() => LocalDate.parse(input), throwsFormatException);
      });
    });

    test('accepts leap days in leap years, including 2000', () {
      expect(LocalDate.tryParse('2024-02-29'), isNotNull);
      expect(LocalDate.tryParse('2000-02-29'), isNotNull);
    });
  });

  group('LocalDate constructor', () {
    test('rejects a date that does not exist', () {
      expect(() => LocalDate(2025, 2, 30), throwsArgumentError);
      expect(() => LocalDate(2025, 13, 1), throwsArgumentError);
      expect(() => LocalDate(0, 1, 1), throwsArgumentError);
    });
  });

  group('LocalDate.fromDateTime', () {
    test('keeps the calendar fields and drops the time', () {
      expect(
        LocalDate.fromDateTime(DateTime(2026, 3, 1, 23, 59, 59)),
        _d('2026-03-01'),
      );
      expect(
        LocalDate.fromDateTime(DateTime(2026, 3, 1, 0, 0, 1)),
        _d('2026-03-01'),
      );
    });

    test(
      'does not convert between zones: a UTC value keeps its own fields',
      () {
        expect(
          LocalDate.fromDateTime(DateTime.utc(2026, 3, 1, 23, 59)),
          _d('2026-03-01'),
        );
      },
    );

    test('today is a valid date matching the device clock', () {
      final now = DateTime.now();

      expect(LocalDate.today().year, anyOf(now.year, now.year + 1));
      expect(LocalDate.tryParse(LocalDate.today().toIso()), isNotNull);
    });
  });

  group('addDays', () {
    final table = <(String, int, String)>[
      ('2026-03-01', 0, '2026-03-01'),
      ('2026-03-01', 1, '2026-03-02'),
      ('2026-03-31', 1, '2026-04-01'),
      ('2026-12-31', 1, '2027-01-01'),
      ('2026-01-01', -1, '2025-12-31'),
      ('2026-03-01', -1, '2026-02-28'),
      ('2024-03-01', -1, '2024-02-29'),
      ('2024-02-28', 1, '2024-02-29'),
      ('2024-02-28', 2, '2024-03-01'),
      ('2025-02-28', 1, '2025-03-01'),
      ('2026-01-31', 30, '2026-03-02'),
      ('2026-01-01', 365, '2027-01-01'),
      ('2024-01-01', 366, '2025-01-01'),
      ('2026-03-01', -365, '2025-03-01'),
    ];

    for (final (from, days, expected) in table) {
      test('$from + $days = $expected', () {
        expect(_d(from).addDays(days), _d(expected));
      });
    }

    test('crossing a daylight-saving change does not add or drop a day', () {
      // Europe springs forward on 2026-03-29 and falls back on 2026-10-25.
      expect(_d('2026-03-28').addDays(1), _d('2026-03-29'));
      expect(_d('2026-03-29').addDays(1), _d('2026-03-30'));
      expect(_d('2026-10-24').addDays(2), _d('2026-10-26'));
    });
  });

  group('daysUntil', () {
    test('counts whole days', () {
      expect(_d('2026-03-01').daysUntil(_d('2026-03-01')), 0);
      expect(_d('2026-03-01').daysUntil(_d('2026-03-04')), 3);
      expect(_d('2026-02-27').daysUntil(_d('2026-03-02')), 3);
      expect(_d('2024-02-27').daysUntil(_d('2024-03-02')), 4);
      expect(_d('2026-01-01').daysUntil(_d('2027-01-01')), 365);
      expect(_d('2024-01-01').daysUntil(_d('2025-01-01')), 366);
    });

    test('is negative going backwards', () {
      expect(_d('2026-03-04').daysUntil(_d('2026-03-01')), -3);
    });

    test('across a daylight-saving change is exact', () {
      expect(_d('2026-03-28').daysUntil(_d('2026-03-30')), 2);
      expect(_d('2026-10-24').daysUntil(_d('2026-10-26')), 2);
    });

    test('is the inverse of addDays', () {
      for (final days in [-400, -1, 0, 1, 59, 60, 365, 1000]) {
        final start = _d('2026-03-15');

        expect(start.daysUntil(start.addDays(days)), days);
      }
    });
  });

  group('comparison', () {
    test('orders by year, then month, then day', () {
      expect(_d('2026-03-01') < _d('2026-03-02'), isTrue);
      expect(_d('2026-03-31') < _d('2026-04-01'), isTrue);
      expect(_d('2026-12-31') < _d('2027-01-01'), isTrue);
      expect(_d('2027-01-01') > _d('2026-12-31'), isTrue);
      expect(_d('2026-03-01') <= _d('2026-03-01'), isTrue);
      expect(_d('2026-03-01') >= _d('2026-03-01'), isTrue);
      expect(_d('2026-03-01') < _d('2026-03-01'), isFalse);
      expect(_d('2026-03-02').isAfter(_d('2026-03-01')), isTrue);
      expect(_d('2026-03-01').isBefore(_d('2026-03-01')), isFalse);
    });

    test('sorts a list', () {
      final dates = [_d('2026-03-02'), _d('2025-12-31'), _d('2026-03-01')]
        ..sort();

      expect(dates.map((d) => d.toIso()), [
        '2025-12-31',
        '2026-03-01',
        '2026-03-02',
      ]);
    });
  });

  group('equality', () {
    test('is by value and works in sets and maps', () {
      expect(_d('2026-03-01'), _d('2026-03-01'));
      expect(_d('2026-03-01').hashCode, _d('2026-03-01').hashCode);
      expect({
        _d('2026-03-01'),
        _d('2026-03-01'),
        _d('2026-03-02'),
      }, hasLength(2));
      expect({_d('2026-03-01'): 'a'}[_d('2026-03-01')], 'a');
    });

    test('toString is the ISO form', () {
      expect('${_d('2026-03-01')}', '2026-03-01');
    });
  });
}
