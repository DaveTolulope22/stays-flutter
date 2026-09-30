import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listings/listings.dart';
import 'package:stays_app/src/modules/shell_modules.dart';

import 'support/fake_listings_repository.dart';
import 'support/shell_harness.dart';

/// The brief's "show us a flag that actually turns something off".
///
/// These tests run the REAL app shell: the real `modulesFor`, the real save-slot
/// override, the real favourites repository and providers. Only the network is
/// replaced, by an adapter that records every request. So when a test says
/// "no `/favourites` request", the app really did not make one, and the positive
/// control at the end proves the recorder would have seen it.
void main() {
  final en = copy('en');

  // riviera's shape: favourites (and reviews) off, everything else on.
  final favouritesOff = allFlagsOn.copyWith(favourites: false, reviews: false);

  Finder saveControl() => find.byTooltip(en.saveListing);
  Finder savedTab() => find.text(en.savedTab);
  Finder savedScreen() => find.text(en.savedTitle);
  Finder card() => find.text(shellListing.title);

  /// The app's provider container, to ask what the shell installed.
  ProviderContainer ref(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));

  Future<void> go(WidgetTester tester, String location) async {
    routerOf(tester).go(location);
    await tester.pumpAndSettle();
  }

  Future<void> openListing(WidgetTester tester) async {
    await tester.tap(card());
    await tester.pumpAndSettle();
  }

  group('favourites OFF (riviera)', () {
    testWidgets('the card\'s save slot is EMPTY, not merely hidden', (
      tester,
    ) async {
      await ShellHarness(
        session: clientSession,
        flags: favouritesOff,
      ).pump(tester);

      expect(ref(tester).read(listingSaveActionProvider), isNull);
    });

    testWidgets('there is no Saved tab and no bottom bar', (tester) async {
      await ShellHarness(
        session: clientSession,
        flags: favouritesOff,
      ).pump(tester);

      expect(card(), findsOneWidget);
      expect(savedTab(), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('/saved is not routable: a deep link lands on browse', (
      tester,
    ) async {
      await ShellHarness(
        session: clientSession,
        flags: favouritesOff,
      ).pump(tester);

      await go(tester, '/saved');

      expect(savedScreen(), findsNothing);
      expect(card(), findsOneWidget);
    });

    testWidgets('a card has no save control', (tester) async {
      await ShellHarness(
        session: clientSession,
        flags: favouritesOff,
      ).pump(tester);

      expect(card(), findsOneWidget);
      expect(saveControl(), findsNothing);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('the listing page has no save control either', (tester) async {
      await ShellHarness(
        session: clientSession,
        flags: favouritesOff,
      ).pump(tester);

      await openListing(tester);

      expect(find.text(en.detailAbout), findsOneWidget);
      expect(saveControl(), findsNothing);
    });

    testWidgets('a whole visit makes ZERO requests to /favourites', (
      tester,
    ) async {
      final harness = ShellHarness(
        session: clientSession,
        flags: favouritesOff,
      );
      await harness.pump(tester);

      await openListing(tester);
      routerOf(tester).pop();
      await tester.pumpAndSettle();
      await go(tester, '/saved');

      expect(harness.adapter.favouritesRequests, isEmpty);
    });

    testWidgets('the module is not registered at all', (tester) async {
      final ids = [for (final module in modulesFor(favouritesOff)) module.id];

      expect(ids, isNot(contains('favourites')));
    });
  });

  group('favourites ON (alpine), the positive control', () {
    testWidgets('the card\'s save slot is filled', (tester) async {
      await ShellHarness(session: clientSession).pump(tester);

      expect(ref(tester).read(listingSaveActionProvider), isNotNull);
    });

    testWidgets('a Saved tab and a bottom bar appear', (tester) async {
      await ShellHarness(session: clientSession).pump(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(savedTab(), findsOneWidget);
    });

    testWidgets('/saved opens the Saved screen', (tester) async {
      await ShellHarness(session: clientSession).pump(tester);

      await go(tester, '/saved');

      expect(savedScreen(), findsOneWidget);
    });

    testWidgets('the card and the listing page both have the save control', (
      tester,
    ) async {
      await ShellHarness(session: clientSession).pump(tester);
      expect(saveControl(), findsOneWidget);

      await openListing(tester);

      expect(find.text(en.detailAbout), findsOneWidget);
      expect(saveControl(), findsOneWidget);
    });

    testWidgets('it DOES call /favourites, so the recorder can see it', (
      tester,
    ) async {
      final harness = ShellHarness(session: clientSession);
      await harness.pump(tester);

      expect(harness.adapter.favouritesRequests, isNotEmpty);
      expect(harness.adapter.favouritesRequests.first.method, 'GET');
    });

    testWidgets('saving from the card sends a POST', (tester) async {
      final harness = ShellHarness(session: clientSession);
      await harness.pump(tester);

      await tester.tap(saveControl());
      await tester.pumpAndSettle();

      final post = harness.adapter.favouritesRequests.where(
        (request) => request.method == 'POST',
      );
      expect(post.single.data, {'listingId': shellListing.id});
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  group('favourites ON, but a host', () {
    testWidgets('cannot open /saved and never triggers a request', (
      tester,
    ) async {
      final harness = ShellHarness(session: hostSession);
      await harness.pump(tester);

      await go(tester, '/saved');

      expect(savedScreen(), findsNothing);
      expect(saveControl(), findsNothing);
      expect(harness.adapter.favouritesRequests, isEmpty);
    });
  });
}
