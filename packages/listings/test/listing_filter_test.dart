import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listings/listings.dart';

void main() {
  group('ListingFilter.toQueryParameters', () {
    test('an empty filter sends only the sort', () {
      expect(const ListingFilter().toQueryParameters(), {
        'orderBy': 'createdAt',
        'orderDir': 'desc',
      });
    });

    test('sends every narrowing filter that is set', () {
      final filter = ListingFilter(
        city: 'Davos',
        guests: 4,
        minPrice: 100,
        maxPrice: 300,
        dates: DateRange(LocalDate(2026, 3, 1), LocalDate(2026, 3, 3)),
      );

      expect(filter.toQueryParameters(), {
        'city': 'Davos',
        'guests': 4,
        'minPrice': 100,
        'maxPrice': 300,
        'checkIn': '2026-03-01',
        'checkOut': '2026-03-03',
        'orderBy': 'createdAt',
        'orderDir': 'desc',
      });
    });

    test('sends check-in and check-out together, end date as check-out', () {
      final params = ListingFilter(
        dates: DateRange(LocalDate(2026, 3, 1), LocalDate(2026, 3, 4)),
      ).toQueryParameters();

      expect(params['checkIn'], '2026-03-01');
      expect(params['checkOut'], '2026-03-04');
    });

    test('leaves out a price bound that is not set', () {
      final params = const ListingFilter(minPrice: 80).toQueryParameters();

      expect(params['minPrice'], 80);
      expect(params.containsKey('maxPrice'), isFalse);
    });

    test('maps every sort to the API order fields', () {
      final byName = {
        for (final sort in ListingSort.values)
          sort: ListingFilter(sort: sort).toQueryParameters(),
      };

      expect(byName[ListingSort.newest], containsPair('orderBy', 'createdAt'));
      expect(
        byName[ListingSort.priceLowToHigh],
        allOf(
          containsPair('orderBy', 'pricePerNight'),
          containsPair('orderDir', 'asc'),
        ),
      );
      expect(
        byName[ListingSort.priceHighToLow],
        allOf(
          containsPair('orderBy', 'pricePerNight'),
          containsPair('orderDir', 'desc'),
        ),
      );
      expect(
        byName[ListingSort.ratingHighToLow],
        allOf(
          containsPair('orderBy', 'rating'),
          containsPair('orderDir', 'desc'),
        ),
      );
    });
  });

  group('ListingFilter counting', () {
    test('an empty filter is unfiltered', () {
      expect(const ListingFilter().isUnfiltered, isTrue);
      expect(const ListingFilter().activeCount, 0);
    });

    test('a price range counts once, and the sort does not count', () {
      const filter = ListingFilter(
        minPrice: 50,
        maxPrice: 200,
        sort: ListingSort.priceLowToHigh,
      );

      expect(filter.activeCount, 1);
    });

    test('counts city, guests, price and dates separately', () {
      final filter = ListingFilter(
        city: 'Davos',
        guests: 2,
        maxPrice: 200,
        dates: DateRange(LocalDate(2026, 3, 1), LocalDate(2026, 3, 3)),
      );

      expect(filter.activeCount, 4);
    });

    test('cleared removes the filters and keeps the sort', () {
      final cleared = const ListingFilter(
        city: 'Davos',
        sort: ListingSort.priceHighToLow,
      ).cleared();

      expect(cleared.isUnfiltered, isTrue);
      expect(cleared.sort, ListingSort.priceHighToLow);
    });
  });

  group('ListingFilter as a provider family key', () {
    test('two filters with the same values are equal', () {
      final a = ListingFilter(
        city: 'Davos',
        dates: DateRange(LocalDate(2026, 3, 1), LocalDate(2026, 3, 3)),
      );
      final b = ListingFilter(
        city: 'Davos',
        dates: DateRange(LocalDate(2026, 3, 1), LocalDate(2026, 3, 3)),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a different value makes a different key', () {
      expect(
        const ListingFilter(city: 'Davos'),
        isNot(const ListingFilter(city: 'Zermatt')),
      );
    });
  });
}
