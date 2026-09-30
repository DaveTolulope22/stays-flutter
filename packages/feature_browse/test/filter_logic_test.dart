import 'package:core/core.dart';
import 'package:feature_browse/src/filter/filter_edits.dart';
import 'package:feature_browse/src/filter/price_scale.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:listings/listings.dart';

void main() {
  group('PriceScale', () {
    test('keeps the exact bounds at both ends (alpine: 51 to 694)', () {
      final scale = PriceScale(min: 51, max: 694);

      expect(scale.valueAt(0), 51);
      expect(scale.valueAt(scale.divisions), 694);
      expect(scale.min, 51);
      expect(scale.max, 694);
    });

    test('every position between the bounds is a whole multiple of 10', () {
      final scale = PriceScale(min: 51, max: 694);

      final interior = [
        for (var i = 1; i < scale.divisions; i++) scale.valueAt(i),
      ];

      expect(interior.first, 60);
      expect(interior.last, 690);
      expect(interior.every((price) => price % 10 == 0), isTrue);
      expect(interior.every((price) => price == price.roundToDouble()), isTrue);
      expect(scale.divisions, 65, reason: '51, 60, 70 ... 690, 694');
    });

    test('a bound that is already a multiple is not repeated (riviera 50)', () {
      final scale = PriceScale(min: 50, max: 765);

      expect(scale.valueAt(0), 50);
      expect(scale.valueAt(1), 60);
      expect(scale.valueAt(scale.divisions - 1), 760);
      expect(scale.valueAt(scale.divisions), 765);
    });

    test('a maximum on a multiple is not repeated either', () {
      final scale = PriceScale(min: 51, max: 690);

      expect(scale.valueAt(scale.divisions), 690);
      expect(scale.valueAt(scale.divisions - 1), 680);
    });

    test('the positions strictly increase', () {
      final scale = PriceScale(min: 51, max: 694);

      for (var i = 1; i <= scale.divisions; i++) {
        expect(scale.valueAt(i), greaterThan(scale.valueAt(i - 1)));
      }
    });

    test('a narrow range gets a finer step so it still has positions', () {
      expect(PriceScale.stepFor(51, 694), 10);
      expect(PriceScale.stepFor(100, 200), 5);
      expect(PriceScale.stepFor(100, 130), 1);

      final narrow = PriceScale(min: 10, max: 14);
      expect(
        [for (var i = 0; i <= narrow.divisions; i++) narrow.valueAt(i)],
        [10, 11, 12, 13, 14],
      );
    });

    test('equal bounds leave nothing to choose', () {
      final scale = PriceScale(min: 80, max: 80);

      expect(scale.isAdjustable, isFalse);
      expect(scale.divisions, 0);
    });

    test('indexOf finds the closest position and valueAt stays in range', () {
      final scale = PriceScale(min: 51, max: 694);

      expect(scale.indexOf(51), 0);
      expect(scale.indexOf(694), scale.divisions);
      expect(scale.valueAt(scale.indexOf(137)), 140);
      expect(scale.valueAt(-4), 51);
      expect(scale.valueAt(9999), 694);
    });
  });

  group('withGuests', () {
    test('one guest is every listing, so nothing is sent', () {
      expect(const ListingFilter().withGuests(1).guests, isNull);
      expect(const ListingFilter(guests: 4).withGuests(1).guests, isNull);
    });

    test('two or more is a filter', () {
      expect(const ListingFilter().withGuests(2).guests, 2);
      expect(
        const ListingFilter().withGuests(2).toQueryParameters()['guests'],
        2,
      );
    });
  });

  group('withPriceIndices', () {
    final scale = PriceScale(min: 51, max: 694);
    final last = scale.divisions;

    test('a slider left at both bounds sends no price at all', () {
      final params = const ListingFilter()
          .withPriceIndices(scale, 0, last)
          .toQueryParameters();

      expect(params.containsKey('minPrice'), isFalse);
      expect(params.containsKey('maxPrice'), isFalse);
    });

    test('moving only the lower end sends only minPrice', () {
      final params = const ListingFilter()
          .withPriceIndices(scale, 5, last)
          .toQueryParameters();

      expect(params['minPrice'], 100);
      expect(params.containsKey('maxPrice'), isFalse);
    });

    test('moving only the upper end sends only maxPrice', () {
      final params = const ListingFilter()
          .withPriceIndices(scale, 0, 25)
          .toQueryParameters();

      expect(params['maxPrice'], 300);
      expect(params.containsKey('minPrice'), isFalse);
    });

    test('moving both ends sends both, as whole numbers', () {
      final filter = const ListingFilter().withPriceIndices(scale, 5, 25);

      expect(filter.minPrice, 100);
      expect(filter.maxPrice, 300);
    });

    test('putting an end back on its bound removes that price again', () {
      final moved = const ListingFilter().withPriceIndices(scale, 5, 25);

      final back = moved.withPriceIndices(scale, 0, 25);

      expect(back.minPrice, isNull);
      expect(back.maxPrice, 300);
    });

    test('leaves the other filters alone', () {
      final filter = const ListingFilter(
        city: 'Davos',
        guests: 3,
      ).withPriceIndices(scale, 5, last);

      expect(filter.city, 'Davos');
      expect(filter.guests, 3);
    });
  });

  group('dateRangeFromPicker', () {
    test('the day picked last is the check-out, not the last night', () {
      final range = dateRangeFromPicker(
        DateTimeRange(start: DateTime(2026, 3, 1), end: DateTime(2026, 3, 4)),
      )!;

      expect(range.start, LocalDate(2026, 3, 1));
      expect(range.end, LocalDate(2026, 3, 4));
      expect(range.nights, 3);
      expect(range.contains(LocalDate(2026, 3, 4)), isFalse);
    });

    test('is sent as checkIn and checkOut', () {
      final params = ListingFilter(
        dates: dateRangeFromPicker(
          DateTimeRange(start: DateTime(2026, 3, 1), end: DateTime(2026, 3, 4)),
        ),
      ).toQueryParameters();

      expect(params['checkIn'], '2026-03-01');
      expect(params['checkOut'], '2026-03-04');
    });

    test('the same day twice is not a stay', () {
      expect(
        dateRangeFromPicker(
          DateTimeRange(start: DateTime(2026, 3, 1), end: DateTime(2026, 3, 1)),
        ),
        isNull,
      );
    });

    test('only the calendar day counts, not the time', () {
      final range = dateRangeFromPicker(
        DateTimeRange(
          start: DateTime(2026, 3, 1, 23, 30),
          end: DateTime(2026, 3, 3, 0, 15),
        ),
      )!;

      expect(range.start, LocalDate(2026, 3, 1));
      expect(range.end, LocalDate(2026, 3, 3));
    });
  });
}
