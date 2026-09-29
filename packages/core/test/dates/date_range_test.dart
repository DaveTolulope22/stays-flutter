import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

LocalDate _d(String iso) => LocalDate.parse(iso);
DateRange _r(String start, String end) => DateRange(_d(start), _d(end));

void main() {
  group('nights', () {
    test('03-01 to 03-03 is two nights: the 1st and the 2nd', () {
      final range = _r('2026-03-01', '2026-03-03');

      expect(range.nights, 2);
      expect(range.nightDates.map((d) => d.toIso()), [
        '2026-03-01',
        '2026-03-02',
      ]);
    });

    final table = <(String, String, int)>[
      ('2026-03-01', '2026-03-02', 1),
      ('2026-03-01', '2026-03-08', 7),
      ('2026-02-27', '2026-03-02', 3),
      ('2024-02-27', '2024-03-02', 4),
      ('2026-12-30', '2027-01-02', 3),
      ('2026-01-01', '2027-01-01', 365),
      ('2024-01-01', '2025-01-01', 366),
      ('2026-03-28', '2026-03-30', 2),
    ];

    for (final (start, end, nights) in table) {
      test('$start to $end is $nights', () {
        expect(_r(start, end).nights, nights);
      });
    }

    test(
      'nightDates has exactly `nights` entries and never includes the end',
      () {
        final range = _r('2026-02-27', '2026-03-03');

        expect(range.nightDates, hasLength(range.nights));
        expect(range.nightDates.contains(range.end), isFalse);
        expect(range.nightDates.first, range.start);
      },
    );
  });

  group('construction', () {
    test('an empty range is allowed and has zero nights', () {
      final range = _r('2026-03-01', '2026-03-01');

      expect(range.isEmpty, isTrue);
      expect(range.nights, 0);
      expect(range.nightDates, isEmpty);
    });

    test('an end before the start is rejected', () {
      expect(() => _r('2026-03-02', '2026-03-01'), throwsArgumentError);
    });
  });

  group('contains is half-open', () {
    final range = _r('2026-03-01', '2026-03-04');

    test(
      'includes the start',
      () => expect(range.contains(_d('2026-03-01')), isTrue),
    );
    test(
      'includes the middle',
      () => expect(range.contains(_d('2026-03-02')), isTrue),
    );
    test(
      'includes the last night',
      () => expect(range.contains(_d('2026-03-03')), isTrue),
    );
    test(
      'excludes the end date',
      () => expect(range.contains(_d('2026-03-04')), isFalse),
    );
    test(
      'excludes the day before',
      () => expect(range.contains(_d('2026-02-28')), isFalse),
    );
    test(
      'excludes the day after',
      () => expect(range.contains(_d('2026-03-05')), isFalse),
    );

    test('an empty range contains nothing', () {
      expect(
        _r('2026-03-01', '2026-03-01').contains(_d('2026-03-01')),
        isFalse,
      );
    });
  });

  group('overlaps', () {
    final base = _r('2026-03-10', '2026-03-15');

    final table = <String, (DateRange, bool)>{
      'identical': (_r('2026-03-10', '2026-03-15'), true),
      'inside': (_r('2026-03-11', '2026-03-13'), true),
      'contains it': (_r('2026-03-05', '2026-03-20'), true),
      'overlaps the start': (_r('2026-03-08', '2026-03-11'), true),
      'overlaps the end': (_r('2026-03-14', '2026-03-18'), true),
      'shares only the last night': (_r('2026-03-14', '2026-03-16'), true),
      'shares only the first night': (_r('2026-03-09', '2026-03-11'), true),
      'touching: other ends the day this starts': (
        _r('2026-03-05', '2026-03-10'),
        false,
      ),
      'touching: other starts the day this ends': (
        _r('2026-03-15', '2026-03-20'),
        false,
      ),
      'disjoint before': (_r('2026-03-01', '2026-03-05'), false),
      'disjoint after': (_r('2026-03-20', '2026-03-25'), false),
      'a one-night gap before': (_r('2026-03-07', '2026-03-09'), false),
    };

    table.forEach((name, row) {
      final (other, expected) = row;
      test('$name -> $expected', () {
        expect(base.overlaps(other), expected);
        // It is symmetric.
        expect(other.overlaps(base), expected);
      });
    });

    test('back-to-back bookings do not clash', () {
      final first = _r('2026-03-01', '2026-03-03');
      final second = _r('2026-03-03', '2026-03-05');

      expect(first.overlaps(second), isFalse);
      expect(second.overlaps(first), isFalse);
    });

    test('an empty range overlaps nothing, even inside another', () {
      final empty = _r('2026-03-12', '2026-03-12');

      expect(base.overlaps(empty), isFalse);
      expect(empty.overlaps(base), isFalse);
      expect(empty.overlaps(empty), isFalse);
    });

    test('a range spanning a month end and a leap day', () {
      expect(
        _r('2024-02-28', '2024-03-02').overlaps(_r('2024-02-29', '2024-03-01')),
        isTrue,
      );
    });
  });

  group('containsRange', () {
    final base = _r('2026-03-10', '2026-03-15');

    test('itself', () => expect(base.containsRange(base), isTrue));
    test('a smaller range inside', () {
      expect(base.containsRange(_r('2026-03-11', '2026-03-14')), isTrue);
    });
    test('a range sharing the start and end', () {
      expect(base.containsRange(_r('2026-03-10', '2026-03-12')), isTrue);
      expect(base.containsRange(_r('2026-03-13', '2026-03-15')), isTrue);
    });
    test('not a range that starts earlier', () {
      expect(base.containsRange(_r('2026-03-09', '2026-03-12')), isFalse);
    });
    test('not a range that ends later', () {
      expect(base.containsRange(_r('2026-03-12', '2026-03-16')), isFalse);
    });
    test('not a larger range', () {
      expect(base.containsRange(_r('2026-03-01', '2026-03-30')), isFalse);
    });
  });

  test('equality is by value', () {
    expect(_r('2026-03-01', '2026-03-03'), _r('2026-03-01', '2026-03-03'));
    expect(
      _r('2026-03-01', '2026-03-03').hashCode,
      _r('2026-03-01', '2026-03-03').hashCode,
    );
    expect(
      _r('2026-03-01', '2026-03-03') == _r('2026-03-01', '2026-03-04'),
      isFalse,
    );
  });

  test('toString reads naturally', () {
    expect('${_r('2026-03-01', '2026-03-03')}', '2026-03-01 to 2026-03-03');
  });
}
