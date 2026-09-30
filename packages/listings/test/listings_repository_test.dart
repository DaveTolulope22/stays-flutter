import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listings/listings.dart';

import 'support/fake_http_adapter.dart';
import 'support/listing_json.dart';

const _tenant = 'alpine';

ListingsRepository repositoryWith(FakeHttpAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = adapter;
  return ListingsRepository(dio: dio, tenant: _tenant);
}

Map<String, dynamic> listingOf(String tenantId) => {
  ...listingJson(),
  'tenantId': tenantId,
};

ResponseBody page(
  List<Map<String, dynamic>> rows, {
  String next = 'null',
  int total = 500,
}) => FakeHttpAdapter.json(
  jsonEncode(rows),
  headers: {
    'x-total-count': '$total',
    'x-next-cursor': next,
    'x-prev-cursor': 'null',
  },
);

void main() {
  group('list', () {
    test(
      'sends the filter, the limit and no cursor on the first page',
      () async {
        final adapter = FakeHttpAdapter((_) => page([listingOf(_tenant)]));

        await repositoryWith(adapter)
            .list(const ListingFilter(city: 'Davos'), limit: 10)
            .run();

        final request = adapter.requests.single;
        expect(request.path, '/listings');
        expect(request.queryParameters, {
          'city': 'Davos',
          'orderBy': 'createdAt',
          'orderDir': 'desc',
          'limit': 10,
        });
      },
    );

    test('echoes the cursor it was given as nextCursor', () async {
      final adapter = FakeHttpAdapter((_) => page([listingOf(_tenant)]));

      await repositoryWith(adapter)
          .list(const ListingFilter(), cursor: 'bzoy')
          .run();

      expect(adapter.requests.single.queryParameters['nextCursor'], 'bzoy');
    });

    test('reads the items, the total and the next cursor', () async {
      final adapter = FakeHttpAdapter(
        (_) => page([listingOf(_tenant)], next: 'bzoy', total: 42),
      );

      final result = await repositoryWith(adapter)
          .list(const ListingFilter())
          .run();

      final loaded = result.getOrElse((_) => throw StateError('failed'));
      expect(loaded.items.single.id, 'l1');
      expect(loaded.total, 42);
      expect(loaded.nextCursor, 'bzoy');
    });

    test('the string "null" cursor is the end of the list', () async {
      final adapter = FakeHttpAdapter((_) => page([listingOf(_tenant)]));

      final result = await repositoryWith(adapter)
          .list(const ListingFilter())
          .run();

      final loaded = result.getOrElse((_) => throw StateError('failed'));
      expect(loaded.nextCursor, isNull);
      expect(loaded.hasNext, isFalse);
    });

    test('a row of another tenant fails the whole page', () async {
      final adapter = FakeHttpAdapter(
        (_) => page([listingOf(_tenant), listingOf('riviera')]),
      );

      final result = await repositoryWith(adapter)
          .list(const ListingFilter())
          .run();

      expect(result.getLeft().toNullable(), isA<TenantMismatchFailure>());
    });

    test('a 400 becomes a ValidationFailure with the messageCode', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          '{"statusCode":400,"messageCode":"error.rangeTooLong","message":"x"}',
          status: 400,
        ),
      );

      final failure = (await repositoryWith(
        adapter,
      ).list(const ListingFilter()).run()).getLeft().toNullable();

      expect(failure, isA<ValidationFailure>());
      expect(failure?.messageCode, 'error.rangeTooLong');
    });
  });

  group('detail', () {
    test('decodes the listing', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(jsonEncode(listingOf(_tenant))),
      );

      final result = await repositoryWith(adapter).detail('l1').run();

      expect(adapter.requests.single.path, '/listings/l1');
      expect(result.toNullable()?.title, 'Chalet with a view');
    });

    test('a 404 becomes a NotFoundFailure', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          '{"statusCode":404,"messageCode":"listing.NotFoundException",'
          '"message":"x"}',
          status: 404,
        ),
      );

      final failure = (await repositoryWith(
        adapter,
      ).detail('nope').run()).getLeft().toNullable();

      expect(failure, isA<NotFoundFailure>());
      expect(failure?.messageCode, 'listing.NotFoundException');
    });

    test('a listing of another tenant is never returned', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(jsonEncode(listingOf('riviera'))),
      );

      final result = await repositoryWith(adapter).detail('l1').run();

      expect(result.getLeft().toNullable(), isA<TenantMismatchFailure>());
    });
  });

  group('facets', () {
    test('decodes the bounds', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          jsonEncode({
            'cities': ['Davos'],
            'propertyTypes': ['chalet'],
            'amenities': ['wifi'],
            'priceMin': 51,
            'priceMax': 694,
            'maxGuests': 16,
            'currency': 'CHF',
          }),
        ),
      );

      final result = await repositoryWith(adapter).facets().run();

      expect(adapter.requests.single.path, '/listings/facets');
      expect(result.toNullable()?.maxGuests, 16);
    });
  });

  group('availability', () {
    test('asks for the half-open window as from and to', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          jsonEncode({
            'listingId': 'l1',
            'from': '2026-03-01',
            'to': '2026-04-01',
            'unavailable': [
              {'date': '2026-03-05', 'reason': 'booked'},
            ],
          }),
        ),
      );

      final result = await repositoryWith(adapter)
          .availability(
            'l1',
            DateRange(LocalDate(2026, 3, 1), LocalDate(2026, 4, 1)),
          )
          .run();

      final request = adapter.requests.single;
      expect(request.path, '/listings/l1/availability');
      expect(request.queryParameters, {
        'from': '2026-03-01',
        'to': '2026-04-01',
      });
      expect(result.toNullable()?.takenDates, {LocalDate(2026, 3, 5)});
    });

    test('a window over 366 nights is refused before any request', () {
      final adapter = FakeHttpAdapter((_) => FakeHttpAdapter.json('{}'));

      expect(
        () => repositoryWith(adapter).availability(
          'l1',
          DateRange(LocalDate(2026, 1, 1), LocalDate(2027, 1, 3)),
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(adapter.requests, isEmpty);
    });
  });
}
