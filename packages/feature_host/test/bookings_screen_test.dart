import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_host/feature_host.dart';
import 'package:feature_host/src/widgets/booking_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'support/host_harness.dart';

void main() {
  // A tap that misses its target must fail the test, not just warn: a missed
  // tap can leave an assertion true for the wrong reason.
  WidgetController.hitTestWarningShouldBeFatal = true;

  final en = copyFor('en');
  final de = copyFor('de');

  /// The host's list with one listing, `l0`, opened on its bookings.
  Future<ScriptedHostRepository> openBookings(
    WidgetTester tester,
    Future<BookingsResult> Function(
      String id,
      BookingStatus? status,
      String? cursor,
    )
    onBookings, {
    Locale locale = const Locale('en'),
    Size size = const Size(400, 1800),
    bool settle = true,
  }) async {
    final repo = ScriptedHostRepository(
      (_) async => right(pageOf(1)),
      onBookings: onBookings,
    );
    final harness = HostHarness(repo);
    await harness.pump(tester, locale: locale, size: size);
    final l10n = copyFor(locale.languageCode);
    await tester.tap(find.widgetWithText(TextButton, l10n.hostActionBookings));
    settle ? await tester.pumpAndSettle() : await tester.pump();
    return repo;
  }

  Future<BookingsResult> Function(String, BookingStatus?, String?) returning(
    List<Booking> bookings,
  ) =>
      (id, status, cursor) async => right(
        CursorPage(
          items: [
            for (final booking in bookings)
              if (status == null || booking.status == status) booking,
          ],
        ),
      );

  Finder chip(String label) => find.widgetWithText(ChoiceChip, label);

  /// Text inside the booking cards only, so a chip with the same word does not
  /// count.
  Finder inCards(String text) =>
      find.descendant(of: find.byType(BookingCard), matching: find.text(text));

  group('a booking', () {
    testWidgets('shows who, when, how long, how many, the total and the '
        'status', (tester) async {
      await openBookings(tester, returning([bookingOf('b1')]));

      expect(find.text('Anna Guest'), findsOneWidget);
      expect(find.text('Oct 12, 2026 – Oct 15, 2026'), findsOneWidget);
      expect(find.text('3 nights'), findsOneWidget);
      expect(find.text('2 guests'), findsOneWidget);
      expect(find.text('€787.50'), findsOneWidget);
      expect(inCards(en.bookingStatusConfirmed), findsOneWidget);
    });

    testWidgets('one night and one guest are singular', (tester) async {
      await openBookings(
        tester,
        returning([
          bookingOf(
            'b1',
            checkIn: '2026-10-12',
            checkOut: '2026-10-13',
            guests: 1,
          ),
        ]),
      );

      expect(find.text('1 night'), findsOneWidget);
      expect(find.text('1 guest'), findsOneWidget);
    });

    testWidgets('each total is in its own booking\'s currency', (tester) async {
      await openBookings(
        tester,
        returning([
          bookingOf('b1', currency: 'EUR', totalPrice: 480),
          bookingOf('b2', currency: 'CHF', totalPrice: 620),
        ]),
      );

      expect(find.textContaining('€480'), findsOneWidget);
      expect(find.textContaining('CHF'), findsOneWidget);
      expect(find.textContaining('620'), findsOneWidget);
    });

    testWidgets('German uses German dates and plurals', (tester) async {
      await openBookings(
        tester,
        returning([bookingOf('b1')]),
        locale: const Locale('de'),
      );

      expect(find.text('3 Nächte'), findsOneWidget);
      expect(find.text('2 Gäste'), findsOneWidget);
      expect(find.textContaining('Okt'), findsOneWidget);
    });

    testWidgets('every status has its own badge, and an unknown one a generic '
        'label', (tester) async {
      await openBookings(
        tester,
        returning([
          bookingOf('b1', status: BookingStatus.confirmed),
          bookingOf('b2', status: BookingStatus.pending),
          bookingOf('b3', status: BookingStatus.completed),
          bookingOf('b4', status: BookingStatus.cancelled),
          bookingOf('b5', status: BookingStatus.unknown),
        ]),
      );

      for (final label in [
        en.bookingStatusConfirmed,
        en.bookingStatusPending,
        en.bookingStatusCompleted,
        en.bookingStatusCancelled,
        en.bookingStatusUnknown,
      ]) {
        expect(inCards(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('the count above the list comes from the total', (
      tester,
    ) async {
      await openBookings(
        tester,
        (id, status, cursor) async =>
            right(bookingsPageOf(2, next: 'c1', total: 1234)),
        settle: false,
      );
      await tester.pumpAndSettle();

      expect(find.text('1,234 bookings'), findsOneWidget);
    });
  });

  group('the status chips', () {
    testWidgets('are all visible, with All selected to begin with', (
      tester,
    ) async {
      await openBookings(tester, returning([bookingOf('b1')]));

      expect(chip(en.hostBookingsFilterAll), findsOneWidget);
      for (final label in [
        en.bookingStatusConfirmed,
        en.bookingStatusPending,
        en.bookingStatusCompleted,
        en.bookingStatusCancelled,
      ]) {
        expect(chip(label), findsOneWidget, reason: label);
      }
      expect(
        tester.widget<ChoiceChip>(chip(en.hostBookingsFilterAll)).selected,
        isTrue,
      );
    });

    testWidgets('choosing one asks for that status and shows only those', (
      tester,
    ) async {
      final repo = await openBookings(
        tester,
        returning([
          bookingOf('b1', guestName: 'Anna Guest'),
          bookingOf(
            'b2',
            guestName: 'Ben Pending',
            status: BookingStatus.pending,
          ),
        ]),
      );
      expect(repo.bookingCalls.last.status, isNull);

      await tester.tap(chip(en.bookingStatusPending));
      await tester.pumpAndSettle();

      expect(repo.bookingCalls.last.status, BookingStatus.pending);
      expect(find.text('Ben Pending'), findsOneWidget);
      expect(find.text('Anna Guest'), findsNothing);
      expect(
        tester.widget<ChoiceChip>(chip(en.bookingStatusPending)).selected,
        isTrue,
      );
    });

    testWidgets('All asks for every status again', (tester) async {
      final repo = await openBookings(
        tester,
        returning([bookingOf('b1', status: BookingStatus.pending)]),
      );
      await tester.tap(chip(en.bookingStatusCancelled));
      await tester.pumpAndSettle();

      await tester.tap(chip(en.hostBookingsFilterAll));
      await tester.pumpAndSettle();

      expect(repo.bookingCalls.last.status, isNull);
      expect(find.text('Anna Guest'), findsOneWidget);
    });

    testWidgets('an empty filter says so, offers all bookings, and keeps the '
        'chips', (tester) async {
      await openBookings(
        tester,
        returning([bookingOf('b1', status: BookingStatus.pending)]),
      );

      await tester.tap(chip(en.bookingStatusCancelled));
      await tester.pumpAndSettle();

      expect(find.text(en.hostBookingsEmptyFiltered), findsOneWidget);
      expect(chip(en.bookingStatusPending), findsOneWidget);

      await tester.tap(find.text(en.hostBookingsShowAll));
      await tester.pumpAndSettle();

      expect(find.text(en.hostBookingsEmptyFiltered), findsNothing);
      expect(find.text('Anna Guest'), findsOneWidget);
    });

    testWidgets('they wrap instead of overflowing a narrow German screen', (
      tester,
    ) async {
      await openBookings(
        tester,
        returning([bookingOf('b1', status: BookingStatus.completed)]),
        locale: const Locale('de'),
        size: const Size(320, 1800),
      );

      expect(chip(de.bookingStatusCompleted), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('states', () {
    testWidgets('a spinner while the first page loads', (tester) async {
      final gate = Completer<BookingsResult>();
      await openBookings(
        tester,
        (id, status, cursor) => gate.future,
        settle: false,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      gate.complete(right(bookingsPageOf(1)));
      await tester.pumpAndSettle();
    });

    testWidgets('a listing with no bookings says so', (tester) async {
      await openBookings(tester, returning(const []));

      expect(find.text(en.hostBookingsEmpty), findsOneWidget);
      expect(find.text(en.hostBookingsShowAll), findsNothing);
    });

    testWidgets('a failed first page shows our message and Retry, chips kept', (
      tester,
    ) async {
      var fail = true;
      await openBookings(
        tester,
        (id, status, cursor) async =>
            fail ? left(const NetworkFailure()) : right(bookingsPageOf(1)),
      );
      expect(find.text(en.errorNetwork), findsOneWidget);
      expect(chip(en.bookingStatusPending), findsOneWidget);

      fail = false;
      await tester.tap(find.text(en.retry));
      await tester.pumpAndSettle();

      expect(find.text('Guest 0'), findsOneWidget);
    });

    testWidgets('pull to refresh reloads the first page', (tester) async {
      final repo = await openBookings(
        tester,
        (id, status, cursor) async => right(bookingsPageOf(1)),
      );
      final before = repo.bookingCalls.length;

      await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      expect(repo.bookingCalls.length, before + 1);
      expect(repo.bookingCalls.last.cursor, isNull);
    });

    testWidgets('back returns to the listings', (tester) async {
      await openBookings(tester, returning([bookingOf('b1')]));

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text(en.hostListingsTitle), findsOneWidget);
    });
  });

  group('infinite scroll', () {
    testWidgets('a first page too short to scroll still loads the next', (
      tester,
    ) async {
      final repo = await openBookings(
        tester,
        (id, status, cursor) async => right(
          cursor == null
              ? bookingsPageOf(1, next: 'c1')
              : bookingsPageOf(1, start: 1),
        ),
      );

      expect(repo.bookingCalls.map((c) => c.cursor), [null, 'c1']);
      expect(find.text('Guest 1'), findsOneWidget);
    });

    testWidgets('the next page keeps the chosen status', (tester) async {
      final repo = await openBookings(
        tester,
        (id, status, cursor) async => right(
          cursor == null
              ? bookingsPageOf(
                  1,
                  next: 'c1',
                  status: status ?? BookingStatus.confirmed,
                )
              : bookingsPageOf(
                  1,
                  start: 1,
                  status: status ?? BookingStatus.confirmed,
                ),
        ),
      );

      await tester.tap(chip(en.bookingStatusPending));
      await tester.pumpAndSettle();

      final pending = repo.bookingCalls.where(
        (c) => c.status == BookingStatus.pending,
      );
      expect(pending.map((c) => c.cursor), [null, 'c1']);
    });

    testWidgets('a failing page does not loop: it shows Retry and waits', (
      tester,
    ) async {
      final repo = await openBookings(
        tester,
        (id, status, cursor) async => cursor == null
            ? right(bookingsPageOf(1, next: 'c1'))
            : left(const NetworkFailure()),
      );

      expect(repo.bookingCalls.map((c) => c.cursor), [null, 'c1']);
      expect(find.text(en.retry), findsOneWidget);
    });
  });

  group('German', () {
    testWidgets('a long name and the longest status do not overflow a narrow '
        'screen', (tester) async {
      await openBookings(
        tester,
        returning([
          bookingOf(
            'b1',
            guestName: 'Maximiliane von Hohenzollern-Sigmaringen',
            status: BookingStatus.completed,
            checkIn: '2026-12-28',
            checkOut: '2027-01-09',
          ),
        ]),
        locale: const Locale('de'),
        size: const Size(320, 1800),
      );

      expect(inCards(de.bookingStatusCompleted), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
