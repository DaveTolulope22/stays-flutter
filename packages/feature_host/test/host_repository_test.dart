import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:feature_host/src/data/host_repository.dart';
import 'package:feature_host/src/models/booking.dart';
import 'package:feature_host/src/models/listing_patch.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_http_adapter.dart';
import 'support/host_harness.dart';

HostRepository repositoryWith(FakeHttpAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = adapter;
  return HostRepository(dio: dio, tenant: testTenant);
}

ResponseBody emptyBody(int status) => ResponseBody.fromString('', status);

ResponseBody errorBody(int status, String code) => FakeHttpAdapter.json(
  jsonEncode({'statusCode': status, 'messageCode': code, 'message': 'secret'}),
  status: status,
);

void main() {
  group('listings', () {
    test('reads the page, its total and the next cursor', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          jsonEncode([listingRow('a'), listingRow('b')]),
          headers: {
            'x-total-count': '5',
            'x-next-cursor': 'bzoy',
            'x-prev-cursor': 'null',
          },
        ),
      );

      final page = (await repositoryWith(
        adapter,
      ).listings().run()).getOrElse((_) => throw StateError('failed'));

      final request = adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/host/listings');
      expect(request.queryParameters, {'limit': 20});
      expect([for (final l in page.items) l.id], ['a', 'b']);
      expect(page.total, 5);
      expect(page.nextCursor, 'bzoy');
    });

    test('the string "null" cursor means the last page', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          jsonEncode([listingRow('a')]),
          headers: {'x-next-cursor': 'null', 'x-prev-cursor': 'null'},
        ),
      );

      final page = (await repositoryWith(
        adapter,
      ).listings().run()).getOrElse((_) => throw StateError('failed'));

      expect(page.nextCursor, isNull);
      expect(page.hasNext, isFalse);
    });

    test('sends the cursor it was given, untouched', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(jsonEncode(<dynamic>[])),
      );

      await repositoryWith(adapter).listings(cursor: 'bzoy').run();

      expect(adapter.requests.single.queryParameters['nextCursor'], 'bzoy');
    });

    test('a row of another tenant is a failure, nothing is returned', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          jsonEncode([listingRow('a'), listingRow('b', tenantId: 'other')]),
        ),
      );

      final result = await repositoryWith(adapter).listings().run();

      expect(result.getLeft().toNullable(), isA<TenantMismatchFailure>());
    });

    test('a 403 is a ForbiddenFailure that carries the messageCode', () async {
      final adapter = FakeHttpAdapter(
        (_) => errorBody(403, 'auth.forbidden.ForbiddenException'),
      );

      final failure = (await repositoryWith(
        adapter,
      ).listings().run()).getLeft().toNullable();

      expect(failure, isA<ForbiddenFailure>());
      expect(failure!.messageCode, 'auth.forbidden.ForbiddenException');
    });
  });

  group('bookings', () {
    test('omits the status query when no filter is chosen', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(jsonEncode([bookingRow('b1')])),
      );

      await repositoryWith(adapter).bookings('l 1').run();

      final request = adapter.requests.single;
      expect(request.uri.path, '/host/listings/l%201/bookings');
      expect(request.queryParameters.containsKey('status'), isFalse);
    });

    test('sends the status filter by its API name', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(jsonEncode(<dynamic>[])),
      );

      await repositoryWith(adapter)
          .bookings('l1', status: BookingStatus.cancelled)
          .run();

      expect(adapter.requests.single.queryParameters['status'], 'cancelled');
    });

    test('decodes dates as LocalDate and the total as a number', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(jsonEncode([bookingRow('b1')])),
      );

      final page = (await repositoryWith(
        adapter,
      ).bookings('l1').run()).getOrElse((_) => throw StateError('failed'));

      final booking = page.items.single;
      expect(booking.checkIn, LocalDate(2026, 10, 12));
      expect(booking.checkOut, LocalDate(2026, 10, 15));
      expect(booking.totalPrice, 787.5);
      expect(booking.status, BookingStatus.confirmed);
    });

    test('an unknown status decodes to unknown instead of failing', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          jsonEncode([bookingRow('b1', status: 'on_hold')]),
        ),
      );

      final page = (await repositoryWith(
        adapter,
      ).bookings('l1').run()).getOrElse((_) => throw StateError('failed'));

      expect(page.items.single.status, BookingStatus.unknown);
    });

    test('a listing the host does not own is a NotFoundFailure', () async {
      final adapter = FakeHttpAdapter(
        (_) => errorBody(404, 'listing.NotFoundException'),
      );

      final result = await repositoryWith(adapter).bookings('x').run();

      expect(result.getLeft().toNullable(), isA<NotFoundFailure>());
    });
  });

  group('blocked days', () {
    test('reads the plain array of days', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          jsonEncode([
            {'listingId': 'l1', 'date': '2026-10-01'},
            {'listingId': 'l1', 'date': '2026-10-02'},
          ]),
        ),
      );

      final days = (await repositoryWith(
        adapter,
      ).blockedDays('l1').run()).getOrElse((_) => throw StateError('failed'));

      expect(adapter.requests.single.path, '/host/listings/l1/blocked-days');
      expect(
        [for (final d in days) d.date],
        [LocalDate(2026, 10, 1), LocalDate(2026, 10, 2)],
      );
    });

    test('block posts the day as YYYY-MM-DD', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          jsonEncode({'listingId': 'l1', 'date': '2026-10-05'}),
          status: 201,
        ),
      );

      final result = await repositoryWith(adapter)
          .block('l1', LocalDate(2026, 10, 5))
          .run();

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/host/listings/l1/blocked-days');
      expect(request.data, {'date': '2026-10-05'});
      expect(result.isRight(), isTrue);
    });

    test('unblock deletes by date in the path', () async {
      final adapter = FakeHttpAdapter((_) => emptyBody(204));

      final result = await repositoryWith(adapter)
          .unblock('l1', LocalDate(2026, 10, 5))
          .run();

      final request = adapter.requests.single;
      expect(request.method, 'DELETE');
      expect(request.uri.path, '/host/listings/l1/blocked-days/2026-10-05');
      expect(result.isRight(), isTrue);
    });

    test('a network error is a NetworkFailure', () async {
      final adapter = FakeHttpAdapter(
        (options) => throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        ),
      );

      final result = await repositoryWith(adapter)
          .block('l1', LocalDate(2026, 10, 5))
          .run();

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
    });
  });

  group('update', () {
    test('patches only the fields that are set, numbers as numbers', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(jsonEncode(listingRow('l1'))),
      );

      final result = await repositoryWith(adapter)
          .update(
            'l1',
            const ListingPatch(title: 'New title', pricePerNight: 250),
          )
          .run();

      final request = adapter.requests.single;
      expect(request.method, 'PATCH');
      expect(request.path, '/host/listings/l1');
      expect(request.data, {'title': 'New title', 'pricePerNight': 250});
      expect(request.data['pricePerNight'], isA<num>());
      expect(result.getOrElse((_) => throw StateError('failed')).id, 'l1');
    });

    test('an empty list of amenities is sent: it clears them', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(jsonEncode(listingRow('l1'))),
      );

      await repositoryWith(adapter)
          .update('l1', const ListingPatch(amenities: []))
          .run();

      expect(adapter.requests.single.data, {'amenities': <String>[]});
    });

    test('a rejected patch is a ValidationFailure with its code', () async {
      final adapter = FakeHttpAdapter(
        (_) => errorBody(400, 'error.badRequest'),
      );

      final failure =
          (await repositoryWith(adapter)
                  .update('l1', const ListingPatch(beds: -1))
                  .run())
              .getLeft()
              .toNullable();

      expect(failure, isA<ValidationFailure>());
      expect(failure!.messageCode, 'error.badRequest');
    });

    test('an updated listing of another tenant is a failure', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          jsonEncode(listingRow('l1', tenantId: 'other')),
        ),
      );

      final result = await repositoryWith(adapter)
          .update('l1', const ListingPatch(title: 'x'))
          .run();

      expect(result.getLeft().toNullable(), isA<TenantMismatchFailure>());
    });
  });
}
