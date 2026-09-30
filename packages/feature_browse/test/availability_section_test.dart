import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_browse/feature_browse.dart';
import 'package:feature_browse/src/state/listing_filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:listings/listings.dart';

import 'support/browse_harness.dart';

const _deepLink = '/browse/listing/l7';

LocalDate _d(String iso) => LocalDate.parse(iso);

Availability _availability(
  String id,
  DateRange window,
  Map<String, UnavailableReason> taken,
) => Availability(
  listingId: id,
  from: window.start,
  to: window.end,
  unavailable: [
    for (final entry in taken.entries)
      UnavailableDay(date: _d(entry.key), reason: entry.value),
  ],
);

void main() {
  // A tap that misses its target must fail the test, not just warn.
  WidgetController.hitTestWarningShouldBeFatal = true;

  final en = copyFor('en');
  final de = copyFor('de');

  ScriptedRepository repository({
    Future<Either<AppFailure, Availability>> Function(
      String id,
      DateRange window,
    )?
    onAvailability,
  }) => ScriptedRepository(
    (filter, cursor) async => right(pageOf(3, total: 3)),
    onAvailability: onAvailability,
  );

  ScriptedRepository withTaken(Map<String, UnavailableReason> taken) =>
      repository(
        onAvailability: (id, window) async =>
            right(_availability(id, window, taken)),
      );

  Future<BrowseHarness> openDetail(
    WidgetTester tester, {
    ScriptedRepository? repo,
    Locale locale = const Locale('en'),
  }) async {
    final harness = BrowseHarness(repo ?? repository());
    await harness.pump(tester, location: _deepLink, locale: locale);
    await tester.ensureVisible(find.byType(MonthCalendar));
    await tester.pumpAndSettle();
    return harness;
  }

  /// Opens the list, applies [dates] as the search, then opens the listing: the
  /// way a guest who searched for a stay gets to the calendar.
  Future<BrowseHarness> openDetailAfterSearch(
    WidgetTester tester,
    DateRange dates, {
    ScriptedRepository? repo,
  }) async {
    final harness = BrowseHarness(repo ?? repository());
    await harness.pump(tester);
    harness
        .container(tester)
        .read(listingFilterControllerProvider.notifier)
        .apply(ListingFilter(dates: dates));
    await tester.pumpAndSettle();
    unawaited(harness.router.push(BrowsePaths.listing('l7')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(MonthCalendar));
    await tester.pumpAndSettle();
    return harness;
  }

  Future<void> tapArrow(WidgetTester tester, String tooltip) async {
    await tester.ensureVisible(find.byTooltip(tooltip));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(tooltip));
    await tester.pumpAndSettle();
  }

  IconButton arrow(WidgetTester tester, String tooltip) =>
      tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip(tooltip),
          matching: find.byType(IconButton),
        ),
      );

  Finder struck() => find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.style?.decoration == TextDecoration.lineThrough,
  );

  BoxDecoration boxOf(WidgetTester tester, String day) =>
      tester
              .widget<DecoratedBox>(
                find
                    .ancestor(
                      of: find.text(day),
                      matching: find.byType(DecoratedBox),
                    )
                    .first,
              )
              .decoration
          as BoxDecoration;

  group('the month and its request', () {
    testWidgets('opens on this month, asking for today up to the 1st', (
      tester,
    ) async {
      final repo = repository();
      await openDetail(tester, repo: repo);

      expect(find.text('March 2026'), findsOneWidget);
      expect(repo.availabilityCalls, hasLength(1));
      expect(repo.availabilityCalls.single.id, 'l7');
      expect(
        repo.availabilityCalls.single.window,
        DateRange(_d('2026-03-15'), _d('2026-04-01')),
        reason: 'today comes from the clock, not the device',
      );
    });

    testWidgets('the next month asks for that whole month, half-open', (
      tester,
    ) async {
      final repo = repository();
      await openDetail(tester, repo: repo);

      await tapArrow(tester, en.availabilityNext);

      expect(find.text('April 2026'), findsOneWidget);
      expect(
        repo.availabilityCalls.last.window,
        DateRange(_d('2026-04-01'), _d('2026-05-01')),
      );
      expect(
        repo.availabilityCalls,
        hasLength(2),
        reason: 'one month at a time',
      );
    });

    testWidgets('going back to a month asks for it again', (tester) async {
      final repo = repository();
      await openDetail(tester, repo: repo);

      await tapArrow(tester, en.availabilityNext);
      await tapArrow(tester, en.availabilityPrevious);

      expect(find.text('March 2026'), findsOneWidget);
      expect(repo.availabilityCalls.map((call) => call.window.start), [
        _d('2026-03-15'),
        _d('2026-04-01'),
        _d('2026-03-15'),
      ]);
    });
  });

  group('the arrows', () {
    testWidgets('cannot go before the current month', (tester) async {
      await openDetail(tester);

      expect(arrow(tester, en.availabilityPrevious).onPressed, isNull);
      expect(arrow(tester, en.availabilityNext).onPressed, isNotNull);

      await tapArrow(tester, en.availabilityNext);
      expect(arrow(tester, en.availabilityPrevious).onPressed, isNotNull);
    });

    testWidgets('stop twelve months ahead', (tester) async {
      final repo = repository();
      await openDetail(tester, repo: repo);

      for (var i = 0; i < calendarMonthsAheadForTest; i++) {
        await tapArrow(tester, en.availabilityNext);
      }

      expect(find.text('March 2027'), findsOneWidget);
      expect(arrow(tester, en.availabilityNext).onPressed, isNull);
      expect(repo.availabilityCalls, hasLength(13));
      expect(
        repo.availabilityCalls.every((call) => call.window.nights <= 31),
        isTrue,
      );
    });
  });

  group('taken days', () {
    final taken = {
      '2026-03-20': UnavailableReason.booked,
      '2026-03-21': UnavailableReason.blocked,
      // A day already gone is never shown as taken, whatever the API says.
      '2026-03-12': UnavailableReason.booked,
    };

    testWidgets('are named taken for a screen reader, booked or blocked', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openDetail(tester, repo: withTaken(taken));

      expect(
        find.bySemanticsLabel(RegExp('March 20, 2026, taken')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('March 21, 2026, taken')),
        findsOneWidget,
        reason: 'a guest is not told whether it is booked or blocked',
      );
      expect(
        find.bySemanticsLabel(RegExp('March 22, 2026, available')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('today is available and earlier days are in the past', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openDetail(tester, repo: withTaken(taken));

      expect(
        find.bySemanticsLabel(RegExp('March 15, 2026, available')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('March 14, 2026, in the past')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('March 12, 2026, in the past')),
        findsOneWidget,
        reason: 'a past day is not shown as taken',
      );
      handle.dispose();
    });

    testWidgets('have a second cue besides colour: a struck-through number', (
      tester,
    ) async {
      await openDetail(tester, repo: withTaken(taken));

      // Two taken days in the grid plus the legend's own sample.
      expect(struck(), findsNWidgets(3));
      expect(
        tester.widget<Text>(find.text('20')).style?.decoration,
        TextDecoration.lineThrough,
      );
      expect(
        tester.widget<Text>(find.text('22')).style?.decoration,
        isNot(TextDecoration.lineThrough),
      );
      expect(boxOf(tester, '20').color, isNotNull, reason: 'and a fill');
    });

    testWidgets('the legend shows the same struck-through cue', (tester) async {
      await openDetail(tester, repo: withTaken(taken));

      final takenKey = find.widgetWithText(
        CalendarDayKey,
        en.availabilityLegendTaken,
      );
      final availableKey = find.widgetWithText(
        CalendarDayKey,
        en.availabilityLegendAvailable,
      );

      expect(find.descendant(of: takenKey, matching: struck()), findsOneWidget);
      expect(
        find.descendant(of: availableKey, matching: struck()),
        findsNothing,
      );
    });

    testWidgets('are named and explained in German too', (tester) async {
      final handle = tester.ensureSemantics();
      await openDetail(
        tester,
        repo: withTaken(taken),
        locale: const Locale('de'),
      );

      expect(find.text('März 2026'), findsOneWidget);
      expect(find.text(de.availabilityLegendTaken), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(', belegt')), findsNWidgets(2));
      handle.dispose();
    });
  });

  group('the legend', () {
    testWidgets('explains available and taken', (tester) async {
      await openDetail(tester);

      expect(find.text(en.availabilityLegendAvailable), findsOneWidget);
      expect(find.text(en.availabilityLegendTaken), findsOneWidget);
    });

    testWidgets('has no "your dates" entry without a search', (tester) async {
      await openDetail(tester);

      expect(find.text(en.availabilityLegendYourDates), findsNothing);
    });
  });

  group('states', () {
    testWidgets('shows a spinner where the grid will be while it loads', (
      tester,
    ) async {
      final gate = Completer<Either<AppFailure, Availability>>();
      final harness = BrowseHarness(
        repository(onAvailability: (id, window) => gate.future),
      );
      await harness.pump(tester, location: _deepLink, settle: false);
      await tester.pump();
      await tester.pump();
      await tester.ensureVisible(find.byType(MonthCalendar));
      await tester.pump();

      expect(find.text('March 2026'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.text('20'), findsNothing);

      gate.complete(
        right(
          _availability(
            'l7',
            DateRange(_d('2026-03-15'), _d('2026-04-01')),
            {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('a failed month shows our message inline and can retry', (
      tester,
    ) async {
      var fail = true;
      await openDetail(
        tester,
        repo: repository(
          onAvailability: (id, window) async => fail
              ? left(const NetworkFailure())
              : right(_availability(id, window, {})),
        ),
      );

      expect(find.text(en.errorNetwork), findsOneWidget);
      expect(find.text('20'), findsNothing);
      expect(find.text('Stay l7'), findsOneWidget, reason: 'the rest stays');
      expect(find.text('4 guests'), findsOneWidget);

      fail = false;
      await tester.ensureVisible(find.text(en.retry));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.retry));
      await tester.pumpAndSettle();

      expect(find.text(en.errorNetwork), findsNothing);
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('a failure is not retried on its own', (tester) async {
      final repo = repository(
        onAvailability: (id, window) async => left(const NetworkFailure()),
      );
      await openDetail(tester, repo: repo);

      await tester.pump(const Duration(seconds: 3));

      expect(repo.availabilityCalls, hasLength(1));
    });
  });

  group('the searched stay', () {
    // Tue 10 to Fri 13 May 2026: the nights of the 10th, 11th and 12th.
    final stay = DateRange(_d('2026-05-10'), _d('2026-05-13'));

    testWidgets('opens the calendar on the check-in month', (tester) async {
      final repo = repository();
      await openDetailAfterSearch(tester, stay, repo: repo);

      expect(find.text('May 2026'), findsOneWidget);
      expect(
        repo.availabilityCalls.last.window,
        DateRange(_d('2026-05-01'), _d('2026-06-01')),
      );
      expect(
        repo.availabilityCalls,
        hasLength(1),
        reason: 'it never asked about the current month first',
      );
    });

    testWidgets('outlines the nights of the stay, not the check-out day', (
      tester,
    ) async {
      await openDetailAfterSearch(tester, stay);

      expect(boxOf(tester, '10').border, isNotNull);
      expect(boxOf(tester, '11').border, isNotNull);
      expect(boxOf(tester, '13').border, isNull, reason: 'the day they leave');
      expect(boxOf(tester, '9').border, isNull);
    });

    testWidgets('names the nights as yours for a screen reader', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openDetailAfterSearch(tester, stay);

      expect(
        find.bySemanticsLabel(RegExp('May 10, 2026, available, in your dates')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'May 13, 2026, available$')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('adds "your dates" to the legend, drawn with the outline', (
      tester,
    ) async {
      await openDetailAfterSearch(tester, stay);

      final key = find.widgetWithText(
        CalendarDayKey,
        en.availabilityLegendYourDates,
      );
      expect(key, findsOneWidget);
      final sample = tester
          .widgetList<DecoratedBox>(
            find.descendant(of: key, matching: find.byType(DecoratedBox)),
          )
          .map((box) => box.decoration)
          .whereType<BoxDecoration>();
      expect(sample.any((decoration) => decoration.border != null), isTrue);
    });

    testWidgets('a taken night inside the stay keeps both cues', (
      tester,
    ) async {
      await openDetailAfterSearch(
        tester,
        stay,
        repo: withTaken({'2026-05-11': UnavailableReason.booked}),
      );

      expect(boxOf(tester, '11').border, isNotNull, reason: 'outlined');
      expect(boxOf(tester, '11').color, isNotNull, reason: 'filled');
      expect(
        tester.widget<Text>(find.text('11')).style?.decoration,
        TextDecoration.lineThrough,
      );
    });

    testWidgets('a stay across two months is outlined in both', (tester) async {
      await openDetailAfterSearch(
        tester,
        DateRange(_d('2026-04-29'), _d('2026-05-02')),
      );

      expect(find.text('April 2026'), findsOneWidget);
      expect(boxOf(tester, '29').border, isNotNull);
      expect(boxOf(tester, '30').border, isNotNull);

      await tapArrow(tester, en.availabilityNext);

      expect(find.text('May 2026'), findsOneWidget);
      expect(
        boxOf(tester, '1').border,
        isNotNull,
        reason: 'the night of the 1st',
      );
      expect(boxOf(tester, '2').border, isNull, reason: 'the check-out day');
    });

    testWidgets('a stay that began before today still opens on this month', (
      tester,
    ) async {
      final repo = repository();
      await openDetailAfterSearch(
        tester,
        DateRange(_d('2026-01-10'), _d('2026-01-12')),
        repo: repo,
      );

      expect(find.text('March 2026'), findsOneWidget);
      expect(repo.availabilityCalls.last.window.start, _d('2026-03-15'));
    });

    testWidgets('a stay too far ahead opens on the last month', (tester) async {
      await openDetailAfterSearch(
        tester,
        DateRange(_d('2028-01-10'), _d('2028-01-12')),
      );

      expect(find.text('March 2027'), findsOneWidget);
      expect(arrow(tester, en.availabilityNext).onPressed, isNull);
    });

    testWidgets('the month does not jump back when the search changes', (
      tester,
    ) async {
      final harness = await openDetailAfterSearch(tester, stay);
      await tapArrow(tester, en.availabilityNext);
      expect(find.text('June 2026'), findsOneWidget);

      harness
          .container(tester)
          .read(listingFilterControllerProvider.notifier)
          .clear();
      await tester.pumpAndSettle();

      expect(find.text('June 2026'), findsOneWidget);
      expect(find.text(en.availabilityLegendYourDates), findsNothing);
    });
  });
}

/// How many times the forward arrow can be used from the current month.
const calendarMonthsAheadForTest = 12;
