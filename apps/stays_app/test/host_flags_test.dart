import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stays_app/src/modules/shell_modules.dart';

import 'support/fake_listings_repository.dart';
import 'support/shell_harness.dart';

/// The host area's two flags, proven against the REAL shell.
///
/// `hostPanel` removes the whole host area; `blockedDays` removes only the
/// ability to change the calendar. These tests run the real `modulesFor`, the
/// real router, the real host repository and providers. Only the network is
/// replaced, by an adapter that records every request. So when a test says "no
/// `/host` request", the app really did not make one, and each side has a
/// positive control that proves the recorder would have seen it.
void main() {
  final en = copy('en');

  // A date in March 2026, so the calendar's days are known and none is past.
  final march = LocalDate(2026, 3, 15);

  // What a host sees on a tenant whose host panel is off.
  final panelOff = allFlagsOn.copyWith(hostPanel: false);

  // What a host sees on a tenant that keeps the host area but not blocking.
  final blockingOff = allFlagsOn.copyWith(blockedDays: false);

  Future<void> go(WidgetTester tester, String location) async {
    routerOf(tester).go(location);
    await tester.pumpAndSettle();
  }

  const hostLocations = [
    '/host',
    '/host/listings/l1/edit',
    '/host/listings/l1/calendar',
    '/host/listings/l1/bookings',
  ];

  group('hostPanel OFF', () {
    testWidgets(
      'the host module is not registered, the unavailable screen is',
      (tester) async {
        final ids = [for (final module in modulesFor(panelOff)) module.id];

        expect(ids, isNot(contains('host')));
        expect(ids, contains('host-unavailable'));
      },
    );

    testWidgets('a host sees only the unavailable screen: no tab, no list', (
      tester,
    ) async {
      await ShellHarness(
        session: hostSession,
        flags: panelOff,
        realHostRepository: true,
      ).pump(tester);

      expect(find.text(en.hostUnavailable), findsOneWidget);
      expect(find.text(en.hostListingsTitle), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('every host deep link lands on the unavailable screen', (
      tester,
    ) async {
      await ShellHarness(
        session: hostSession,
        flags: panelOff,
        realHostRepository: true,
      ).pump(tester);

      for (final location in hostLocations) {
        await go(tester, location);

        expect(find.text(en.hostUnavailable), findsOneWidget, reason: location);
        expect(find.text(en.hostListingsTitle), findsNothing, reason: location);
      }
    });

    testWidgets('a whole visit makes ZERO requests to /host', (tester) async {
      final harness = ShellHarness(
        session: hostSession,
        flags: panelOff,
        realHostRepository: true,
      );
      await harness.pump(tester);

      for (final location in hostLocations) {
        await go(tester, location);
      }

      expect(harness.adapter.hostRequests, isEmpty);
    });

    testWidgets('it is the same in German', (tester) async {
      await ShellHarness(
        session: hostSession,
        flags: panelOff,
        realHostRepository: true,
      ).pump(tester, device: const Locale('de'));

      expect(find.text(copy('de').hostUnavailable), findsOneWidget);
    });
  });

  group('hostPanel ON: the positive control', () {
    testWidgets('the real repository DOES call /host/listings', (tester) async {
      final harness = ShellHarness(
        session: hostSession,
        realHostRepository: true,
      );

      await harness.pump(tester);

      expect(find.text(en.hostListingsTitle), findsOneWidget);
      expect(harness.adapter.hostRequests.map((r) => r.path), [
        '/host/listings',
      ]);
    });

    testWidgets('a client never reaches the host area, so no /host request', (
      tester,
    ) async {
      final harness = ShellHarness(
        session: clientSession,
        realHostRepository: true,
      );
      await harness.pump(tester);

      for (final location in hostLocations) {
        await go(tester, location);

        expect(find.text(shellListing.title), findsOneWidget, reason: location);
      }

      expect(harness.adapter.hostRequests, isEmpty);
    });
  });

  group('blockedDays OFF, hostPanel ON', () {
    Future<ShellHarness> openCalendar(
      WidgetTester tester,
      TenantFlags flags,
    ) async {
      final harness = ShellHarness(
        session: hostSession,
        flags: flags,
        realHostRepository: true,
        today: march,
      );
      await harness.pump(tester);
      await go(tester, '/host/listings/l1/calendar');
      return harness;
    }

    List<String> writes(ShellHarness harness) => [
      for (final request in harness.adapter.hostRequests)
        if (request.method != 'GET') '${request.method} ${request.path}',
    ];

    testWidgets('the host area is still there', (tester) async {
      final ids = [for (final module in modulesFor(blockingOff)) module.id];

      expect(ids, contains('host'));
      expect(ids, isNot(contains('host-unavailable')));
    });

    testWidgets('the calendar is view only, and says so', (tester) async {
      await openCalendar(tester, blockingOff);

      expect(find.text(en.hostCalendarReadOnly), findsOneWidget);
      expect(find.text(en.hostCalendarHint), findsNothing);
    });

    testWidgets('it still READS the blocked days', (tester) async {
      final harness = await openCalendar(tester, blockingOff);

      expect(
        harness.adapter.hostRequests.map((r) => '${r.method} ${r.path}'),
        contains('GET /host/listings/l1/blocked-days'),
      );
    });

    testWidgets('tapping a day sends NOTHING', (tester) async {
      final harness = await openCalendar(tester, blockingOff);

      await tester.tap(find.text('25'));
      await tester.pumpAndSettle();

      expect(writes(harness), isEmpty);
    });

    testWidgets(
      'the positive control: with blocking ON the same tap blocks the '
      'day',
      (tester) async {
        final harness = await openCalendar(tester, allFlagsOn);

        await tester.tap(find.text('25'));
        await tester.pumpAndSettle();

        expect(writes(harness), ['POST /host/listings/l1/blocked-days']);
        final post = harness.adapter.hostRequests.firstWhere(
          (r) => r.method == 'POST',
        );
        expect(post.data, {'date': '2026-03-25'});
      },
    );
  });
}
