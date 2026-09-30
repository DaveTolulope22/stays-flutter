import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_host/feature_host.dart';
import 'package:feature_host/src/screens/host_calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

import 'support/host_harness.dart';

const _id = 'l1';

LocalDate _d(String iso) => LocalDate.parse(iso);

/// March 2026 (today is the 15th, a Sunday):
/// - 20th booked
/// - 21st blocked by the host
/// - 23rd both booked AND blocked (the API reports it as booked)
/// - 27th blocked by the host
/// April: the 2nd is blocked by the host.
final _taken = [
  takenOn('2026-03-20', UnavailableReason.booked),
  takenOn('2026-03-21', UnavailableReason.blocked),
  takenOn('2026-03-23', UnavailableReason.booked),
];
final _blocked = [
  blockedOn('2026-03-21'),
  blockedOn('2026-03-23'),
  blockedOn('2026-03-27'),
  blockedOn('2026-04-02'),
];

ScriptedHostRepository _repo({
  Future<BlockedDaysResult> Function(String id)? onBlockedDays,
  Future<DayWriteResult> Function(String id, LocalDate date)? onBlock,
  Future<DayWriteResult> Function(String id, LocalDate date)? onUnblock,
}) => ScriptedHostRepository(
  (_) async => right(pageOf(1)),
  onBlockedDays: onBlockedDays ?? (_) async => right(_blocked),
  onBlock: onBlock,
  onUnblock: onUnblock,
);

void main() {
  // A tap that misses its target must fail the test, not just warn: a missed
  // tap can leave an assertion true for the wrong reason.
  WidgetController.hitTestWarningShouldBeFatal = true;

  final en = copyFor('en');
  final de = copyFor('de');

  Future<void> pump(
    WidgetTester tester, {
    required ScriptedHostRepository repo,
    ScriptedAvailabilityRepository? listings,
    bool canBlock = true,
    Locale locale = const Locale('en'),
    Size size = const Size(400, 900),
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hostRepositoryProvider.overrideWithValue(repo),
          listingsRepositoryProvider.overrideWithValue(
            listings ?? ScriptedAvailabilityRepository.taking(_taken),
          ),
          clockProvider.overrideWithValue(() => fixedToday),
          capabilitiesProvider.overrideWithValue(
            Capabilities(
              area: AccessArea.host,
              canUseHostPanel: true,
              canBlockDays: canBlock,
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildNeutralTheme(Brightness.light),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HostCalendarScreen(listingId: _id),
        ),
      ),
    );
    settle ? await tester.pumpAndSettle() : await tester.pump();
  }

  /// What a day looks like, read from what is drawn.
  ({bool struck, bool filled, bool muted}) lookOf(
    WidgetTester tester,
    String day,
  ) {
    final text = tester.widget<Text>(find.text(day));
    final box =
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
    return (
      struck: text.style?.decoration == TextDecoration.lineThrough,
      filled: box.color != null,
      muted:
          text.style?.color ==
          buildNeutralTheme(Brightness.light).extension<AppColors>()!.textMuted,
    );
  }

  group('what is drawn', () {
    testWidgets('the month, a hint, the legend and no spinner', (tester) async {
      await pump(tester, repo: _repo());

      expect(find.text('March 2026'), findsOneWidget);
      expect(find.text(en.hostCalendarHint), findsOneWidget);
      expect(find.text(en.availabilityLegendAvailable), findsOneWidget);
      expect(find.text(en.hostCalendarLegendBooked), findsOneWidget);
      expect(find.text(en.hostCalendarLegendBlocked), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('booked is filled and struck, blocked is struck only, free is '
        'neither', (tester) async {
      await pump(tester, repo: _repo());

      final booked = lookOf(tester, '20');
      expect((booked.struck, booked.filled), (true, true));
      final blocked = lookOf(tester, '27');
      expect((blocked.struck, blocked.filled), (true, false));
      final free = lookOf(tester, '25');
      expect((free.struck, free.filled), (false, false));
    });

    testWidgets('a day that is both booked and blocked is drawn as booked', (
      tester,
    ) async {
      await pump(tester, repo: _repo());

      final both = lookOf(tester, '23');
      expect((both.struck, both.filled), (true, true));
    });

    testWidgets('a day that has gone is muted, not struck', (tester) async {
      await pump(tester, repo: _repo());

      final past = lookOf(tester, '10');
      expect((past.struck, past.filled, past.muted), (false, false, true));
    });

    testWidgets('each kind of day says what it is to a screen reader', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, repo: _repo());

      expect(
        find.bySemanticsLabel(
          en.hostCalendarDayFreeTap('Wednesday, March 25, 2026'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          en.hostCalendarDayBlockedTap('Friday, March 27, 2026'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          en.hostCalendarDayBooked('Friday, March 20, 2026'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          en.availabilityDayPast('Tuesday, March 10, 2026'),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('tapping', () {
    testWidgets('a free day blocks it', (tester) async {
      final repo = _repo();
      await pump(tester, repo: repo);

      await tester.tap(find.text('25'));
      await tester.pumpAndSettle();

      expect(repo.blocks.single, (id: _id, date: _d('2026-03-25')));
      expect(lookOf(tester, '25').struck, isTrue);
    });

    testWidgets('a blocked day opens it again', (tester) async {
      final repo = _repo();
      await pump(tester, repo: repo);

      await tester.tap(find.text('27'));
      await tester.pumpAndSettle();

      expect(repo.unblocks.single, (id: _id, date: _d('2026-03-27')));
      expect(lookOf(tester, '27').struck, isFalse);
    });

    testWidgets('a booked day, a booked-and-blocked day and a day that has '
        'gone do nothing', (tester) async {
      final repo = _repo();
      await pump(tester, repo: repo);

      for (final day in ['20', '23', '10']) {
        await tester.tap(find.text(day), warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      expect(repo.blocks, isEmpty);
      expect(repo.unblocks, isEmpty);
    });

    testWidgets('the change shows before the answer, and a failure puts it '
        'back and says so in our own words', (tester) async {
      final gate = Completer<DayWriteResult>();
      final repo = _repo(onBlock: (id, date) => gate.future);
      await pump(tester, repo: repo);

      await tester.tap(find.text('25'));
      await tester.pump();
      expect(lookOf(tester, '25').struck, isTrue, reason: 'before the answer');

      gate.complete(left(const NetworkFailure()));
      await tester.pump();
      await tester.pump();

      expect(lookOf(tester, '25').struck, isFalse, reason: 'rolled back');
      expect(find.text(en.errorNetwork), findsOneWidget);
    });

    testWidgets('one failed day leaves the others as they were', (
      tester,
    ) async {
      final repo = _repo(
        onBlock: (id, date) async => date == _d('2026-03-26')
            ? left(const NetworkFailure())
            : right(unit),
      );
      await pump(tester, repo: repo);

      await tester.tap(find.text('25'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('26'));
      await tester.pump();
      await tester.pump();

      expect(lookOf(tester, '25').struck, isTrue);
      expect(lookOf(tester, '26').struck, isFalse);
    });
  });

  group('when blocking is switched off', () {
    testWidgets('it is view only: a note, and taps do nothing', (tester) async {
      final repo = _repo();
      await pump(tester, repo: repo, canBlock: false);

      expect(find.text(en.hostCalendarReadOnly), findsOneWidget);
      expect(find.text(en.hostCalendarHint), findsNothing);

      await tester.tap(find.text('25'));
      await tester.tap(find.text('27'));
      await tester.pumpAndSettle();

      expect(repo.blocks, isEmpty);
      expect(repo.unblocks, isEmpty);
    });

    testWidgets('the host still sees what is booked and blocked', (
      tester,
    ) async {
      await pump(tester, repo: _repo(), canBlock: false);

      expect(lookOf(tester, '20').filled, isTrue);
      expect(lookOf(tester, '27').struck, isTrue);
    });

    testWidgets('no day is announced as a button', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, repo: _repo(), canBlock: false);

      expect(
        find.bySemanticsLabel(
          en.availabilityDayAvailable('Wednesday, March 25, 2026'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          en.hostCalendarDayBlocked('Friday, March 27, 2026'),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .getSemantics(
              find.bySemanticsLabel(
                en.availabilityDayAvailable('Wednesday, March 25, 2026'),
              ),
            )
            .flagsCollection
            .isButton,
        isFalse,
      );
      handle.dispose();
    });
  });

  group('changing month', () {
    testWidgets('opens on this month, and back is off there', (tester) async {
      await pump(tester, repo: _repo());

      final back = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left),
      );
      expect(back.onPressed, isNull);
    });

    testWidgets('next month asks for that whole month and shows its blocks', (
      tester,
    ) async {
      final listings = ScriptedAvailabilityRepository.taking(_taken);
      final repo = _repo();
      await pump(tester, repo: repo, listings: listings);
      expect(listings.windows.last, DateRange(fixedToday, _d('2026-04-01')));

      await tester.tap(find.byTooltip(en.availabilityNext));
      await tester.pumpAndSettle();

      expect(find.text('April 2026'), findsOneWidget);
      expect(
        listings.windows.last,
        DateRange(_d('2026-04-01'), _d('2026-05-01')),
      );
      expect(lookOf(tester, '2').struck, isTrue);
      expect(repo.blockedDaysCalls, hasLength(1), reason: 'loaded once');
    });

    testWidgets('a day in another month can be blocked too', (tester) async {
      final repo = _repo();
      await pump(tester, repo: repo);

      await tester.tap(find.byTooltip(en.availabilityNext));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();

      expect(repo.blocks.single.date, _d('2026-04-10'));
    });

    testWidgets('a year ahead is the last month', (tester) async {
      await pump(tester, repo: _repo());

      for (var i = 0; i < calendarMonthsAhead; i++) {
        await tester.tap(find.byTooltip(en.availabilityNext));
        await tester.pumpAndSettle();
      }

      expect(find.text('March 2027'), findsOneWidget);
      final next = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(next.onPressed, isNull);
    });
  });

  group('loading and failing', () {
    testWidgets('a spinner while the days load', (tester) async {
      final gate = Completer<BlockedDaysResult>();
      final repo = _repo(onBlockedDays: (_) => gate.future);

      await pump(tester, repo: repo, settle: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      gate.complete(right(const []));
      await tester.pumpAndSettle();
    });

    testWidgets('a failed month shows our message and Retry', (tester) async {
      var fail = true;
      final listings = ScriptedAvailabilityRepository(
        (id, window) async => fail
            ? left(const NetworkFailure())
            : right(
                Availability(
                  listingId: id,
                  from: window.start,
                  to: window.end,
                  unavailable: const [],
                ),
              ),
      );
      await pump(tester, repo: _repo(), listings: listings);
      expect(find.text(en.errorNetwork), findsOneWidget);

      fail = false;
      await tester.tap(find.text(en.retry));
      await tester.pumpAndSettle();

      expect(find.text(en.errorNetwork), findsNothing);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('failed blocked days show our message and Retry', (
      tester,
    ) async {
      var fail = true;
      final repo = _repo(
        onBlockedDays: (_) async =>
            fail ? left(const NetworkFailure()) : right(_blocked),
      );
      await pump(tester, repo: repo);
      expect(find.text(en.errorNetwork), findsOneWidget);

      fail = false;
      await tester.tap(find.text(en.retry));
      await tester.pumpAndSettle();

      expect(lookOf(tester, '27').struck, isTrue);
    });
  });

  group('German', () {
    testWidgets('does not overflow a narrow screen and speaks German', (
      tester,
    ) async {
      await pump(
        tester,
        repo: _repo(),
        locale: const Locale('de'),
        size: const Size(320, 900),
      );

      expect(find.text('März 2026'), findsOneWidget);
      expect(find.text(de.hostCalendarLegendBlocked), findsOneWidget);
      expect(find.text(de.hostCalendarHint), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
