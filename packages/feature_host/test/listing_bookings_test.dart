import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_host/feature_host.dart';
import 'package:feature_host/src/state/listing_bookings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'support/host_harness.dart';

const _id = 'l1';

void main() {
  /// A container with the repository swapped for [repository], and the provider
  /// for [status] kept alive (an auto-dispose provider nobody listens to would
  /// be disposed between the test's awaits).
  ProviderContainer containerFor(
    ScriptedHostRepository repository, [
    BookingStatus? status,
  ]) {
    final container = ProviderContainer(
      overrides: [hostRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(listingBookingsProvider(_id, status), (previous, next) {});
    return container;
  }

  ScriptedHostRepository repoAnswering(
    Future<BookingsResult> Function(
      String id,
      BookingStatus? status,
      String? cursor,
    )
    onBookings,
  ) => ScriptedHostRepository(
    (_) async => right(pageOf(1)),
    onBookings: onBookings,
  );

  PagedState<Booking> pagedOf(
    ProviderContainer container, [
    BookingStatus? status,
  ]) => container.read(listingBookingsProvider(_id, status)).requireValue;

  group('first page', () {
    test('loads the bookings, the total and the next cursor', () async {
      final repo = repoAnswering(
        (id, status, cursor) async =>
            right(bookingsPageOf(3, next: 'c1', total: 40)),
      );
      final container = containerFor(repo);

      final paged = await container.read(
        listingBookingsProvider(_id, null).future,
      );

      expect(paged.items.map((b) => b.id), ['b0', 'b1', 'b2']);
      expect(paged.total, 40);
      expect(paged.nextCursor, 'c1');
      expect(repo.bookingCalls.single, (id: _id, status: null, cursor: null));
    });

    test('a failure is an AsyncError holding the AppFailure', () async {
      final repo = repoAnswering(
        (id, status, cursor) async => left(const NetworkFailure()),
      );
      final container = containerFor(repo);

      await expectLater(
        container.read(listingBookingsProvider(_id, null).future),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('a failure is not retried automatically', () async {
      final repo = repoAnswering(
        (id, status, cursor) async => left(const NetworkFailure()),
      );
      final container = containerFor(repo);
      await container
          .read(listingBookingsProvider(_id, null).future)
          .then((_) {}, onError: (Object _) {});

      // Riverpod's default backoff would fire a retry within a second or two.
      await Future<void>.delayed(const Duration(seconds: 3));

      expect(repo.bookingCalls, hasLength(1));
    });
  });

  group('the status filter', () {
    test('is sent to the repository, for that listing', () async {
      final repo = repoAnswering(
        (id, status, cursor) async => right(bookingsPageOf(1)),
      );
      final container = containerFor(repo, BookingStatus.cancelled);

      await container.read(
        listingBookingsProvider(_id, BookingStatus.cancelled).future,
      );

      expect(repo.bookingCalls.single, (
        id: _id,
        status: BookingStatus.cancelled,
        cursor: null,
      ));
    });

    test('each filter has its own pages', () async {
      final repo = repoAnswering(
        (id, status, cursor) async => right(
          bookingsPageOf(
            status == null ? 3 : 1,
            status: status ?? BookingStatus.confirmed,
          ),
        ),
      );
      final container = containerFor(repo);
      container.listen(
        listingBookingsProvider(_id, BookingStatus.pending),
        (previous, next) {},
      );

      await container.read(listingBookingsProvider(_id, null).future);
      await container.read(
        listingBookingsProvider(_id, BookingStatus.pending).future,
      );

      expect(pagedOf(container).items, hasLength(3));
      expect(pagedOf(container, BookingStatus.pending).items, hasLength(1));
    });

    test('load more keeps the filter and the cursor it was given', () async {
      final repo = repoAnswering(
        (id, status, cursor) async => right(
          cursor == null
              ? bookingsPageOf(2, next: 'c1', total: 4)
              : bookingsPageOf(2, start: 2, total: 4),
        ),
      );
      final container = containerFor(repo, BookingStatus.pending);
      await container.read(
        listingBookingsProvider(_id, BookingStatus.pending).future,
      );

      await container
          .read(listingBookingsProvider(_id, BookingStatus.pending).notifier)
          .loadMore();

      expect(repo.bookingCalls.last, (
        id: _id,
        status: BookingStatus.pending,
        cursor: 'c1',
      ));
      expect(pagedOf(container, BookingStatus.pending).items, hasLength(4));
    });
  });

  group('loadMore', () {
    test('concurrent calls send one request and append once', () async {
      final gate = Completer<BookingsResult>();
      final repo = repoAnswering(
        (id, status, cursor) => cursor == null
            ? Future.value(right(bookingsPageOf(2, next: 'c1')))
            : gate.future,
      );
      final container = containerFor(repo);
      await container.read(listingBookingsProvider(_id, null).future);
      final notifier = container.read(
        listingBookingsProvider(_id, null).notifier,
      );

      final first = notifier.loadMore();
      final second = notifier.loadMore();
      gate.complete(right(bookingsPageOf(2, start: 2)));
      await Future.wait([first, second]);

      expect(repo.bookingCalls.map((c) => c.cursor), [null, 'c1']);
      expect(pagedOf(container).items, hasLength(4));
    });

    test(
      'stops at the end: the "null" cursor never becomes a request',
      () async {
        final repo = repoAnswering(
          (id, status, cursor) async => right(bookingsPageOf(2)),
        );
        final container = containerFor(repo);
        await container.read(listingBookingsProvider(_id, null).future);

        await container
            .read(listingBookingsProvider(_id, null).notifier)
            .loadMore();

        expect(repo.bookingCalls, hasLength(1));
      },
    );

    test('a failing page keeps the items and records the failure', () async {
      final repo = repoAnswering(
        (id, status, cursor) async => cursor == null
            ? right(bookingsPageOf(2, next: 'c1'))
            : left(const NetworkFailure()),
      );
      final container = containerFor(repo);
      await container.read(listingBookingsProvider(_id, null).future);

      await container
          .read(listingBookingsProvider(_id, null).notifier)
          .loadMore();

      final paged = pagedOf(container);
      expect(paged.items, hasLength(2));
      expect(paged.loadMoreError, isA<NetworkFailure>());
      expect(paged.nextCursor, 'c1');
    });
  });
}
