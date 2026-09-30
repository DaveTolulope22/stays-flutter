import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:l10n/l10n.dart';

import 'support/host_harness.dart';

void main() {
  // A tap that misses its target must fail the test, not just warn: a missed
  // tap can leave an assertion true for the wrong reason.
  WidgetController.hitTestWarningShouldBeFatal = true;

  final en = copyFor('en');
  final de = copyFor('de');

  Finder action(String label) => find.widgetWithText(TextButton, label);

  group('states', () {
    testWidgets('shows a spinner while the first page loads', (tester) async {
      final gate = Completer<ListResult>();
      final harness = HostHarness(ScriptedHostRepository((_) => gate.future));

      await harness.pump(tester, settle: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      gate.complete(right(pageOf(1)));
      await tester.pumpAndSettle();
    });

    testWidgets('shows the title and a card for each listing', (tester) async {
      final harness = HostHarness(
        ScriptedHostRepository((_) async => right(pageOf(2))),
      );

      await harness.pump(tester, size: const Size(400, 1600));

      expect(find.text(en.hostListingsTitle), findsOneWidget);
      expect(find.text('Chalet l0'), findsOneWidget);
      expect(find.text('Chalet l1'), findsOneWidget);
      expect(action(en.hostActionEdit), findsNWidgets(2));
      expect(action(en.hostActionCalendar), findsNWidgets(2));
      expect(action(en.hostActionBookings), findsNWidgets(2));
    });

    testWidgets('a host with no listings is told so', (tester) async {
      final harness = HostHarness(
        ScriptedHostRepository((_) async => right(pageOf(0))),
      );

      await harness.pump(tester);

      expect(find.text(en.hostListingsEmpty), findsOneWidget);
    });

    testWidgets('a failed first page shows our message and Retry', (
      tester,
    ) async {
      var fail = true;
      final harness = HostHarness(
        ScriptedHostRepository(
          (_) async => fail ? left(const NetworkFailure()) : right(pageOf(1)),
        ),
      );

      await harness.pump(tester);
      expect(
        find.text(failureMessage(const NetworkFailure(), en)),
        findsOneWidget,
      );

      fail = false;
      await tester.tap(find.text(en.retry));
      await tester.pumpAndSettle();

      expect(find.text('Chalet l0'), findsOneWidget);
    });

    testWidgets('the sign-out button signs out', (tester) async {
      final harness = HostHarness(
        ScriptedHostRepository((_) async => right(pageOf(1))),
      );
      await harness.pump(tester);

      await tester.tap(find.byTooltip(en.signOut));

      expect(harness.signOuts.count, 1);
    });
  });

  group('actions', () {
    testWidgets('each action opens its screen on top, and back returns', (
      tester,
    ) async {
      final harness = HostHarness(
        ScriptedHostRepository((_) async => right(pageOf(1))),
      );
      await harness.pump(tester);

      for (final (label, path) in [
        (en.hostActionEdit, '/host/listings/l0/edit'),
        (en.hostActionCalendar, '/host/listings/l0/calendar'),
        (en.hostActionBookings, '/host/listings/l0/bookings'),
      ]) {
        await tester.tap(action(label));
        await tester.pumpAndSettle();

        expect(
          harness
              .router
              .routerDelegate
              .currentConfiguration
              .last
              .matchedLocation,
          path,
        );

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.text('Chalet l0'), findsOneWidget);
      }
    });

    testWidgets('each action says which listing it is for', (tester) async {
      final harness = HostHarness(
        ScriptedHostRepository((_) async => right(pageOf(1))),
      );
      final semantics = tester.ensureSemantics();
      await harness.pump(tester);

      expect(
        find.bySemanticsLabel(en.hostActionEditSemantics('Chalet l0')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(en.hostActionCalendarSemantics('Chalet l0')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(en.hostActionBookingsSemantics('Chalet l0')),
        findsOneWidget,
      );
      semantics.dispose();
    });
  });

  group('infinite scroll', () {
    testWidgets('a first page too short to scroll still loads the next', (
      tester,
    ) async {
      final harness = HostHarness(
        ScriptedHostRepository(
          (cursor) async => right(
            cursor == null ? pageOf(1, next: 'c1') : pageOf(1, start: 1),
          ),
        ),
      );

      await harness.pump(tester, size: const Size(400, 1600));

      expect(harness.repository.cursors, [null, 'c1']);
      expect(find.text('Chalet l1'), findsOneWidget);
    });

    testWidgets('a failing page does not loop: it shows Retry and waits', (
      tester,
    ) async {
      final harness = HostHarness(
        ScriptedHostRepository(
          (cursor) async => cursor == null
              ? right(pageOf(1, next: 'c1'))
              : left(const NetworkFailure()),
        ),
      );

      await harness.pump(tester, size: const Size(400, 1600));

      expect(harness.repository.cursors, [null, 'c1']);
      expect(find.text(en.retry), findsOneWidget);
    });
  });

  group('German', () {
    testWidgets('long labels wrap instead of overflowing a narrow screen', (
      tester,
    ) async {
      final harness = HostHarness(
        ScriptedHostRepository((_) async => right(pageOf(1))),
      );

      await harness.pump(
        tester,
        locale: const Locale('de'),
        size: const Size(320, 900),
      );

      expect(find.text(de.hostListingsTitle), findsOneWidget);
      expect(action(de.hostActionBookings), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
