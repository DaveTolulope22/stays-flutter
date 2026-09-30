import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_browse/src/state/browse_listings.dart';
import 'package:feature_browse/src/state/listing_filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:listings/listings.dart';

import 'support/browse_harness.dart';

void main() {
  final en = copyFor('en');

  Finder cards({bool skipOffstage = true}) =>
      find.byType(ListingCard, skipOffstage: skipOffstage);

  Future<void> scrollToBottom(WidgetTester tester) async {
    await tester.drag(find.byType(ListView), const Offset(0, -20000));
    await tester.pumpAndSettle();
  }

  double scrollOffset(WidgetTester tester) => tester
      .state<ScrollableState>(
        find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      )
      .position
      .pixels;

  group('states', () {
    testWidgets('shows a spinner while the first page loads', (tester) async {
      final gate = Completer<ListResult>();
      final harness = BrowseHarness(
        ScriptedRepository((filter, cursor) => gate.future),
      );

      await harness.pump(tester, settle: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      gate.complete(right(pageOf(1)));
      await tester.pumpAndSettle();
    });

    testWidgets('shows the tenant name, the cards and the count', (
      tester,
    ) async {
      final harness = BrowseHarness(
        ScriptedRepository(
          (filter, cursor) async => right(pageOf(3, total: 3)),
        ),
      );

      await harness.pump(tester, size: const Size(400, 1600));

      expect(find.text('Acme Stays'), findsOneWidget);
      expect(cards(), findsNWidgets(3));
      expect(find.text('3 stays'), findsOneWidget);
    });

    testWidgets('formats a large count with the locale', (tester) async {
      final repo = ScriptedRepository(
        (filter, cursor) async => right(pageOf(2, total: 1234)),
      );

      await BrowseHarness(repo).pump(tester);
      expect(find.text('1,234 stays'), findsOneWidget);

      await BrowseHarness(repo).pump(tester, locale: const Locale('de'));
      expect(find.text('1.234 Unterkünfte'), findsOneWidget);
    });

    testWidgets('a count of one is singular', (tester) async {
      await BrowseHarness(
        ScriptedRepository(
          (filter, cursor) async => right(pageOf(1, total: 1)),
        ),
      ).pump(tester);

      expect(find.text('1 stay'), findsOneWidget);
    });

    testWidgets('a failed first page shows our message and Retry', (
      tester,
    ) async {
      var fail = true;
      final repo = ScriptedRepository(
        (filter, cursor) async =>
            fail ? left(const NetworkFailure()) : right(pageOf(2, total: 2)),
      );
      await BrowseHarness(repo).pump(tester);

      expect(find.text(en.errorNetwork), findsOneWidget);
      expect(cards(), findsNothing);

      fail = false;
      await tester.tap(find.text(en.retry));
      await tester.pumpAndSettle();

      expect(cards(), findsNWidgets(2));
      expect(find.text(en.errorNetwork), findsNothing);
    });

    testWidgets('an empty list says so', (tester) async {
      await BrowseHarness(
        ScriptedRepository(
          (filter, cursor) async => right(pageOf(0, total: 0)),
        ),
      ).pump(tester);

      expect(find.text(en.browseEmpty), findsOneWidget);
      expect(find.text(en.browseClearFilters), findsNothing);
    });

    testWidgets('an empty filtered list offers to clear the filters', (
      tester,
    ) async {
      final repo = ScriptedRepository(
        (filter, cursor) async => right(
          filter.isUnfiltered ? pageOf(2, total: 2) : pageOf(0, total: 0),
        ),
      );
      final harness = BrowseHarness(repo);
      await harness.pump(tester);
      harness
          .container(tester)
          .read(listingFilterControllerProvider.notifier)
          .apply(const ListingFilter(city: 'Nowhere'));
      await tester.pumpAndSettle();

      expect(find.text(en.browseEmptyFiltered), findsOneWidget);

      // The chips row offers it too; this is the empty state's own button.
      await tester.tap(
        find.widgetWithText(FilledButton, en.browseClearFilters),
      );
      await tester.pumpAndSettle();

      expect(cards(), findsNWidgets(2));
      expect(repo.calls.last.filter.isUnfiltered, isTrue);
    });

    testWidgets('the filter button shows how many filters are active', (
      tester,
    ) async {
      final harness = BrowseHarness(
        ScriptedRepository((filter, cursor) async => right(pageOf(1))),
      );
      await harness.pump(tester);
      expect(find.byType(Badge), findsOneWidget);
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);

      harness
          .container(tester)
          .read(listingFilterControllerProvider.notifier)
          .apply(const ListingFilter(city: 'Davos', guests: 2));
      await tester.pumpAndSettle();

      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('the sign-out button signs out', (tester) async {
      final harness = BrowseHarness(
        ScriptedRepository((filter, cursor) async => right(pageOf(1))),
      );
      await harness.pump(tester);

      await tester.tap(find.byTooltip(en.signOut));

      expect(harness.signOuts.count, 1);
    });
  });

  group('infinite scroll', () {
    testWidgets('scrolling to the end loads the next page once', (
      tester,
    ) async {
      final repo = ScriptedRepository(
        (filter, cursor) async => right(
          cursor == null
              ? pageOf(6, next: 'c1', total: 12)
              : pageOf(6, start: 6, total: 12),
        ),
      );
      await BrowseHarness(repo).pump(tester);
      expect(repo.calls, hasLength(1));

      await scrollToBottom(tester);

      expect(repo.calls, hasLength(2));
      expect(repo.calls.last.cursor, 'c1');

      // The new page is below where the first scroll stopped.
      await scrollToBottom(tester);
      expect(find.text('Stay l11'), findsOneWidget);
      expect(repo.calls, hasLength(2), reason: 'the list has ended');
    });

    testWidgets('a first page too short to scroll still loads the next', (
      tester,
    ) async {
      final repo = ScriptedRepository(
        (filter, cursor) async => right(
          cursor == null
              ? pageOf(1, next: 'c1', total: 3)
              : pageOf(2, start: 1, total: 3),
        ),
      );

      await BrowseHarness(repo).pump(tester);

      expect(repo.calls.map((call) => call.cursor), [null, 'c1']);
      expect(cards(skipOffstage: false), findsNWidgets(3));
    });

    testWidgets('keeps filling the screen until it is full or the list ends', (
      tester,
    ) async {
      var page = 0;
      final repo = ScriptedRepository((filter, cursor) async {
        final index = page++;
        return right(
          pageOf(
            1,
            start: index,
            next: index < 2 ? 'c${index + 1}' : null,
            total: 3,
          ),
        );
      });

      await BrowseHarness(repo).pump(tester);

      expect(repo.calls, hasLength(3));
      expect(cards(skipOffstage: false), findsNWidgets(3));
    });

    testWidgets('a failing page does not loop: it shows Retry and waits', (
      tester,
    ) async {
      var fail = true;
      final repo = ScriptedRepository((filter, cursor) async {
        if (cursor == null) return right(pageOf(1, next: 'c1', total: 3));
        return fail ? left(const NetworkFailure()) : right(pageOf(2, start: 1));
      });
      await BrowseHarness(repo).pump(tester);

      expect(repo.calls, hasLength(2), reason: 'one first page, one failure');
      expect(find.text(en.errorNetwork), findsOneWidget);
      expect(cards(), findsOneWidget, reason: 'the loaded item stays');

      fail = false;
      await tester.tap(find.text(en.retry));
      await tester.pumpAndSettle();

      expect(repo.calls.map((call) => call.cursor), [null, 'c1', 'c1']);
      expect(cards(skipOffstage: false), findsNWidgets(3));
      expect(find.text(en.errorNetwork), findsNothing);
    });

    testWidgets('nothing more is requested once the list has ended', (
      tester,
    ) async {
      final repo = ScriptedRepository(
        (filter, cursor) async => right(pageOf(6, total: 6)),
      );
      await BrowseHarness(repo).pump(tester);

      await scrollToBottom(tester);
      await scrollToBottom(tester);

      expect(repo.calls, hasLength(1));
    });

    testWidgets('pull to refresh reloads the first page', (tester) async {
      var version = 0;
      final repo = ScriptedRepository((filter, cursor) async {
        version++;
        return right(pageOf(6, prefix: 'v$version-', total: 6));
      });
      await BrowseHarness(repo).pump(tester);
      expect(find.text('Stay v1-0'), findsOneWidget);

      await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Stay v2-0'), findsOneWidget);
      expect(repo.calls, hasLength(2));
    });
  });

  group('opening a listing and coming back', () {
    testWidgets('keeps the filter, the pages and the scroll position', (
      tester,
    ) async {
      const filter = ListingFilter(city: 'Davos', guests: 2);
      final repo = ScriptedRepository(
        (f, cursor) async => right(pageOf(8, total: 8)),
      );
      final harness = BrowseHarness(repo);
      await harness.pump(tester);
      final container = harness.container(tester);
      container.read(listingFilterControllerProvider.notifier).apply(filter);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();
      final offsetBefore = scrollOffset(tester);
      final requestsBefore = repo.calls.length;
      expect(offsetBefore, greaterThan(0));

      unawaited(harness.router.push('/detail'));
      await tester.pumpAndSettle();
      expect(find.text('Detail page'), findsOneWidget);
      // The filter is still there while another page is on top.
      expect(container.read(listingFilterControllerProvider), filter);

      harness.router.pop();
      await tester.pumpAndSettle();

      expect(container.read(listingFilterControllerProvider), filter);
      expect(scrollOffset(tester), offsetBefore);
      expect(
        repo.calls,
        hasLength(requestsBefore),
        reason: 'coming back must not reload the list',
      );
      expect(
        container.read(browseListingsProvider(filter)).requireValue.items,
        hasLength(8),
      );
    });
  });

  group('long text', () {
    testWidgets('a German count and card do not overflow a narrow screen', (
      tester,
    ) async {
      final repo = ScriptedRepository(
        (filter, cursor) async => right(
          CursorPage(
            items: [
              listingFixture(
                'a',
                title: 'Gemütliche Ferienwohnung mit Bergblick und Wellnessbereich',
              ),
            ],
            total: 1234,
          ),
        ),
      );

      await BrowseHarness(repo)
          .pump(tester, locale: const Locale('de'), size: const Size(320, 700));

      expect(tester.takeException(), isNull);
    });
  });
}
