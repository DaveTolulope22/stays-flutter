import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// February 2027 starts on a Monday and has 28 days.
final _february = LocalDate(2027, 2, 1);

CalendarDayAppearance _plain(LocalDate date) => const CalendarDayAppearance();

String _label(LocalDate date, CalendarDayAppearance look) =>
    'D${date.day}:${look.style.name}${look.outlined ? '+outlined' : ''}';

Future<void> _pump(
  WidgetTester tester, {
  LocalDate? month,
  CalendarDayAppearance Function(LocalDate)? appearance,
  VoidCallback? onPrevious,
  VoidCallback? onNext,
  Widget? status,
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
  Size size = const Size(400, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildNeutralTheme(brightness),
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('de')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(
        body: SingleChildScrollView(
          child: MonthCalendar(
            month: month ?? _february,
            appearance: appearance ?? _plain,
            label: _label,
            previousTooltip: 'Back a month',
            nextTooltip: 'On a month',
            onPrevious: onPrevious,
            onNext: onNext,
            status: status,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// The column (0 to 6) the day number sits in, from where it is drawn.
int _column(WidgetTester tester, String day, {double width = 400}) =>
    (tester.getCenter(find.text(day)).dx / (width / 7)).floor();

void main() {
  group('the grid', () {
    testWidgets('has one cell per day of the month', (tester) async {
      await _pump(tester);

      expect(find.text('1'), findsOneWidget);
      expect(find.text('28'), findsOneWidget);
      expect(find.text('29'), findsNothing);
    });

    testWidgets('knows leap years and month lengths', (tester) async {
      await _pump(tester, month: LocalDate(2028, 2, 1));
      expect(find.text('29'), findsOneWidget);
      expect(find.text('30'), findsNothing);

      await _pump(tester, month: LocalDate(2027, 3, 1));
      expect(find.text('31'), findsOneWidget);

      await _pump(tester, month: LocalDate(2027, 4, 1));
      expect(find.text('30'), findsOneWidget);
      expect(find.text('31'), findsNothing);
    });

    testWidgets('starts the week on Sunday in English', (tester) async {
      await _pump(tester);

      // Sunday, Monday: the 1st is a Monday, so one blank before it.
      expect(_column(tester, '1'), 1);
      expect(_column(tester, '7'), 0, reason: 'the 7th is a Sunday');
    });

    testWidgets('starts the week on Monday in German', (tester) async {
      await _pump(tester, locale: const Locale('de'));

      expect(_column(tester, '1'), 0);
      expect(_column(tester, '7'), 6, reason: 'the 7th is a Sunday, last');
    });

    testWidgets('shows the weekday initials in the locale\'s order', (
      tester,
    ) async {
      await _pump(tester);
      final english = [
        for (final text in tester.widgetList<Text>(find.byType(Text)))
          if (text.data != null && text.data!.length == 1) text.data!,
      ];
      expect(english.take(7).toList(), ['S', 'M', 'T', 'W', 'T', 'F', 'S']);
    });

    testWidgets('a month that fills six rows still fits', (tester) async {
      // 1 August 2027 is a Sunday; 31 days from a Saturday start needs 6 rows.
      await _pump(tester, month: LocalDate(2026, 8, 1));

      expect(tester.takeException(), isNull);
      expect(find.text('31'), findsOneWidget);
    });
  });

  group('the header', () {
    testWidgets('shows the month and year in the locale', (tester) async {
      await _pump(tester);
      expect(find.text('February 2027'), findsOneWidget);

      await _pump(tester, locale: const Locale('de'));
      expect(find.text('Februar 2027'), findsOneWidget);
    });

    testWidgets('a null callback disables that arrow', (tester) async {
      await _pump(tester, onNext: () {});

      IconButton button(String tooltip) => tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip(tooltip),
          matching: find.byType(IconButton),
        ),
      );
      expect(button('Back a month').onPressed, isNull);
      expect(button('On a month').onPressed, isNotNull);
    });

    testWidgets('the arrows call back and carry the given words', (
      tester,
    ) async {
      var previous = 0;
      var next = 0;
      final handle = tester.ensureSemantics();
      await _pump(tester, onPrevious: () => previous++, onNext: () => next++);

      await tester.tap(find.byTooltip('Back a month'));
      await tester.tap(find.byTooltip('On a month'));
      await tester.tap(find.byTooltip('On a month'));

      expect(previous, 1);
      expect(next, 2);
      expect(find.bySemanticsLabel(RegExp('Back a month')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('On a month')), findsOneWidget);
      handle.dispose();
    });
  });

  group('how a day looks is up to the caller', () {
    CalendarDayAppearance byDay(LocalDate date) => switch (date.day) {
      3 => const CalendarDayAppearance(style: CalendarDayStyle.muted),
      14 => const CalendarDayAppearance(style: CalendarDayStyle.marked),
      15 => const CalendarDayAppearance(
        style: CalendarDayStyle.marked,
        outlined: true,
      ),
      20 => const CalendarDayAppearance(outlined: true),
      _ => const CalendarDayAppearance(),
    };

    TextStyle? styleOf(WidgetTester tester, String day) =>
        tester.widget<Text>(find.text(day)).style;

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

    testWidgets('a marked day is struck through AND filled', (tester) async {
      await _pump(tester, appearance: byDay);

      expect(styleOf(tester, '14')?.decoration, TextDecoration.lineThrough);
      expect(boxOf(tester, '14').color, isNotNull);
    });

    testWidgets('a plain day has neither cue', (tester) async {
      await _pump(tester, appearance: byDay);

      expect(
        styleOf(tester, '10')?.decoration,
        isNot(TextDecoration.lineThrough),
      );
      expect(boxOf(tester, '10').color, isNull);
      expect(boxOf(tester, '10').border, isNull);
    });

    testWidgets('a muted day has muted text and no strike-through', (
      tester,
    ) async {
      await _pump(tester, appearance: byDay);

      expect(
        styleOf(tester, '3')?.decoration,
        isNot(TextDecoration.lineThrough),
      );
      expect(styleOf(tester, '3')?.color, isNot(styleOf(tester, '10')?.color));
    });

    testWidgets('an outline sits on top of any style', (tester) async {
      await _pump(tester, appearance: byDay);

      expect(boxOf(tester, '20').border, isNotNull, reason: 'outlined plain');
      expect(boxOf(tester, '15').border, isNotNull, reason: 'outlined marked');
      expect(
        styleOf(tester, '15')?.decoration,
        TextDecoration.lineThrough,
        reason: 'the outline does not replace the strike-through',
      );
      expect(boxOf(tester, '14').border, isNull);
    });

    testWidgets('each day carries the caller\'s screen reader label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, appearance: byDay);

      expect(find.bySemanticsLabel('D14:marked'), findsOneWidget);
      expect(find.bySemanticsLabel('D15:marked+outlined'), findsOneWidget);
      expect(find.bySemanticsLabel('D20:plain+outlined'), findsOneWidget);
      expect(find.bySemanticsLabel('D3:muted'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('works in the dark palette too', (tester) async {
      await _pump(tester, appearance: byDay, brightness: Brightness.dark);

      expect(tester.takeException(), isNull);
      expect(styleOf(tester, '14')?.decoration, TextDecoration.lineThrough);
    });
  });

  group('status', () {
    testWidgets('replaces the grid but keeps the header', (tester) async {
      await _pump(tester, status: const Text('Loading here'));

      expect(find.text('Loading here'), findsOneWidget);
      expect(find.text('February 2027'), findsOneWidget);
      expect(find.text('14'), findsNothing);
    });

    testWidgets('takes the height of the tallest month', (tester) async {
      await _pump(tester, status: const SizedBox.expand());

      final box = tester.getSize(
        find.ancestor(
          of: find.byType(SizedBox).last,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox &&
                widget.height == AppSizes.calendarCell * MonthCalendar.maxRows,
          ),
        ),
      );
      expect(box.height, AppSizes.calendarCell * 6);
    });
  });

  group('the legend key', () {
    testWidgets('draws a marked sample struck through, like the grid', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildNeutralTheme(Brightness.light),
          home: const Scaffold(
            body: CalendarDayKey(
              appearance: CalendarDayAppearance(style: CalendarDayStyle.marked),
              label: 'Taken',
            ),
          ),
        ),
      );

      expect(find.text('Taken'), findsOneWidget);
      final sample = tester.widget<Text>(find.text('12'));
      expect(sample.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('an outlined sample has an outline', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildNeutralTheme(Brightness.light),
          home: const Scaffold(
            body: CalendarDayKey(
              appearance: CalendarDayAppearance(outlined: true),
              label: 'Yours',
            ),
          ),
        ),
      );

      final box =
          tester
                  .widget<DecoratedBox>(
                    find
                        .ancestor(
                          of: find.text('12'),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      expect(box.border, isNotNull);
    });
  });

  group('layout', () {
    testWidgets('a German month on a narrow phone does not overflow', (
      tester,
    ) async {
      await _pump(
        tester,
        locale: const Locale('de'),
        size: const Size(320, 700),
        month: LocalDate(2027, 3, 1),
        appearance: (date) => date.day.isEven
            ? const CalendarDayAppearance(style: CalendarDayStyle.marked)
            : const CalendarDayAppearance(),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('März 2027'), findsOneWidget);
    });
  });

  group('CalendarDayAppearance', () {
    test('has value equality', () {
      expect(
        const CalendarDayAppearance(
          style: CalendarDayStyle.marked,
          outlined: true,
        ),
        const CalendarDayAppearance(
          style: CalendarDayStyle.marked,
          outlined: true,
        ),
      );
      expect(
        const CalendarDayAppearance(),
        isNot(const CalendarDayAppearance(outlined: true)),
      );
    });
  });
}
