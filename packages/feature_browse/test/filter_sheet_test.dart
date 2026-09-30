import 'package:core/core.dart';
import 'package:feature_browse/src/filter/filter_sheet.dart';
import 'package:feature_browse/src/state/listing_filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:listings/listings.dart';

import 'support/browse_harness.dart';

void main() {
  // A tap that misses its target must fail the test, not just warn: a missed
  // tap can leave an assertion true for the wrong reason.
  WidgetController.hitTestWarningShouldBeFatal = true;

  final en = copyFor('en');

  ScriptedRepository repository({
    Future<Either<AppFailure, ListingFacets>> Function()? onFacets,
  }) => ScriptedRepository(
    (filter, cursor) async => right(pageOf(2, total: 2)),
    onFacets: onFacets,
  );

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.byTooltip(en.browseFilters));
    await tester.pumpAndSettle();
  }

  ListingFilter appliedFilter(BrowseHarness harness, WidgetTester tester) =>
      harness.container(tester).read(listingFilterControllerProvider);

  Future<void> apply(WidgetTester tester, {String? label}) async {
    await tester.tap(find.text(label ?? en.filterShowResults));
    await tester.pumpAndSettle();
  }

  Finder chipWithText(String text) => find.widgetWithText(ChoiceChip, text);

  /// An applied-filter chip whose label satisfies [test].
  Finder chipWhere(bool Function(String text) test) => find.byWidgetPredicate(
    (widget) =>
        widget is InputChip &&
        widget.label is Text &&
        test((widget.label as Text).data ?? ''),
  );

  group('the sheet', () {
    testWidgets('is built from the facets: cities, guests, price, sort', (
      tester,
    ) async {
      final repo = repository();
      await BrowseHarness(repo).pump(tester);

      await openSheet(tester);

      expect(find.byType(FilterSheet), findsOneWidget);
      expect(chipWithText(en.filterCityAny), findsOneWidget);
      for (final city in facetsFixture().cities) {
        expect(chipWithText(city), findsOneWidget);
      }
      expect(find.byType(RangeSlider), findsOneWidget);
      expect(find.textContaining('694'), findsWidgets);
      expect(find.textContaining('CHF'), findsWidgets);
      expect(chipWithText(en.filterSortNewest), findsOneWidget);
      expect(chipWithText(en.filterSortRating), findsOneWidget);
    });

    testWidgets('the facets are fetched once, not on every open', (
      tester,
    ) async {
      final repo = repository();
      await BrowseHarness(repo).pump(tester);

      await openSheet(tester);
      await tester.tap(find.text(en.filterShowResults));
      await tester.pumpAndSettle();
      await openSheet(tester);

      expect(repo.facetsCalls, 1);
    });

    testWidgets('offers no rating sort when reviews are off', (tester) async {
      await BrowseHarness(repository(), canSeeReviews: false).pump(tester);

      await openSheet(tester);

      expect(chipWithText(en.filterSortNewest), findsOneWidget);
      expect(chipWithText(en.filterSortPriceLowToHigh), findsOneWidget);
      expect(chipWithText(en.filterSortRating), findsNothing);
    });

    testWidgets('shows our message and Retry when the facets fail', (
      tester,
    ) async {
      var fail = true;
      final repo = repository(
        onFacets: () async =>
            fail ? left(const NetworkFailure()) : right(facetsFixture()),
      );
      await BrowseHarness(repo).pump(tester);

      await openSheet(tester);
      expect(find.text(en.errorNetwork), findsOneWidget);
      expect(find.byType(RangeSlider), findsNothing);

      fail = false;
      await tester.tap(find.text(en.retry));
      await tester.pumpAndSettle();

      expect(find.byType(RangeSlider), findsOneWidget);
      expect(find.text(en.errorNetwork), findsNothing);
    });

    testWidgets('applies city, guests and sort once, on Show results', (
      tester,
    ) async {
      final repo = repository();
      final harness = BrowseHarness(repo);
      await harness.pump(tester);
      await openSheet(tester);

      await tester.tap(chipWithText('Davos'));
      await tester.tap(find.byTooltip(en.filterGuestsIncrease));
      await tester.tap(chipWithText(en.filterSortPriceLowToHigh));
      await tester.pumpAndSettle();
      expect(
        repo.calls,
        hasLength(1),
        reason: 'nothing reloads while the draft is edited',
      );

      await apply(tester);

      final filter = appliedFilter(harness, tester);
      expect(filter.city, 'Davos');
      expect(filter.guests, 2);
      expect(filter.sort, ListingSort.priceLowToHigh);
      expect(repo.calls.last.filter, filter);
      expect(find.byType(FilterSheet), findsNothing);
    });

    testWidgets('closing without Show results throws the draft away', (
      tester,
    ) async {
      final repo = repository();
      final harness = BrowseHarness(repo);
      await harness.pump(tester);
      await openSheet(tester);
      await tester.tap(chipWithText('Davos'));
      await tester.pumpAndSettle();

      Navigator.of(tester.element(find.byType(FilterSheet))).pop();
      await tester.pumpAndSettle();

      expect(appliedFilter(harness, tester).isUnfiltered, isTrue);
      expect(repo.calls, hasLength(1));
      await openSheet(tester);
      expect(
        tester.widget<ChoiceChip>(chipWithText(en.filterCityAny)).selected,
        isTrue,
      );
    });

    testWidgets('Clear resets the draft and is disabled when it is empty', (
      tester,
    ) async {
      await BrowseHarness(repository()).pump(tester);
      await openSheet(tester);
      TextButton clear() => tester.widget<TextButton>(
        find.widgetWithText(TextButton, en.filterClear),
      );
      expect(clear().onPressed, isNull);

      await tester.tap(chipWithText('Davos'));
      await tester.pumpAndSettle();
      expect(clear().onPressed, isNotNull);

      await tester.tap(find.widgetWithText(TextButton, en.filterClear));
      await tester.pumpAndSettle();

      expect(
        tester.widget<ChoiceChip>(chipWithText(en.filterCityAny)).selected,
        isTrue,
      );
      expect(clear().onPressed, isNull);
    });

    testWidgets('a German sheet does not overflow a narrow screen', (
      tester,
    ) async {
      await BrowseHarness(repository())
          .pump(tester, locale: const Locale('de'), size: const Size(320, 700));

      await tester.tap(find.byTooltip(copyFor('de').browseFilters));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(copyFor('de').filterShowResults), findsOneWidget);
    });
  });

  group('the guest stepper', () {
    testWidgets('starts at 1, which sends no guests filter', (tester) async {
      final harness = BrowseHarness(repository());
      await harness.pump(tester);
      await openSheet(tester);

      expect(find.text('1'), findsWidgets);
      await apply(tester);

      expect(appliedFilter(harness, tester).guests, isNull);
    });

    testWidgets('stops at 1 and at the facets maximum', (tester) async {
      await BrowseHarness(repository()).pump(tester);
      await openSheet(tester);
      IconButton button(IconData icon) =>
          tester.widget<IconButton>(find.widgetWithIcon(IconButton, icon));

      expect(button(Icons.remove).onPressed, isNull);
      for (var i = 1; i < facetsFixture().maxGuests; i++) {
        await tester.tap(find.byTooltip(en.filterGuestsIncrease));
        await tester.pump();
      }

      expect(button(Icons.add).onPressed, isNull);
      expect(button(Icons.remove).onPressed, isNotNull);
    });

    testWidgets('has labels for a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      await BrowseHarness(repository()).pump(tester);
      await openSheet(tester);

      expect(
        find.bySemanticsLabel(RegExp(en.filterGuestsIncrease)),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(en.filterGuestsDecrease)),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('1 guest'), findsOneWidget);

      await tester.tap(find.byTooltip(en.filterGuestsIncrease));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('2 guests'), findsOneWidget);
      handle.dispose();
    });
  });

  group('the price slider', () {
    Future<Rect> sliderRect(WidgetTester tester) async =>
        tester.getRect(find.byType(RangeSlider));

    testWidgets('left alone, it sends no price', (tester) async {
      final harness = BrowseHarness(repository());
      await harness.pump(tester);
      await openSheet(tester);

      await apply(tester);

      final filter = appliedFilter(harness, tester);
      expect(filter.minPrice, isNull);
      expect(filter.maxPrice, isNull);
    });

    testWidgets('moving only the lower end sends only that bound', (
      tester,
    ) async {
      final harness = BrowseHarness(repository());
      await harness.pump(tester);
      await openSheet(tester);
      final rect = await sliderRect(tester);

      await tester.dragFrom(
        Offset(rect.left + 24, rect.center.dy),
        const Offset(150, 0),
      );
      await tester.pumpAndSettle();
      await apply(tester);

      final filter = appliedFilter(harness, tester);
      expect(filter.minPrice, isNotNull);
      expect(filter.maxPrice, isNull);
      final params = filter.toQueryParameters();
      expect(params.containsKey('minPrice'), isTrue);
      expect(params.containsKey('maxPrice'), isFalse);
    });

    testWidgets('moving only the upper end sends only that bound', (
      tester,
    ) async {
      final harness = BrowseHarness(repository());
      await harness.pump(tester);
      await openSheet(tester);
      final rect = await sliderRect(tester);

      await tester.dragFrom(
        Offset(rect.right - 24, rect.center.dy),
        const Offset(-150, 0),
      );
      await tester.pumpAndSettle();
      await apply(tester);

      final filter = appliedFilter(harness, tester);
      expect(filter.maxPrice, isNotNull);
      expect(filter.minPrice, isNull);
    });

    testWidgets('only ever lands on whole, tidy prices', (tester) async {
      final harness = BrowseHarness(repository());
      await harness.pump(tester);
      await openSheet(tester);
      final rect = await sliderRect(tester);

      await tester.dragFrom(
        Offset(rect.left + 24, rect.center.dy),
        const Offset(137, 0),
      );
      await tester.pumpAndSettle();
      await tester.dragFrom(
        Offset(rect.right - 24, rect.center.dy),
        const Offset(-91, 0),
      );
      await tester.pumpAndSettle();
      await apply(tester);

      final filter = appliedFilter(harness, tester);
      expect(filter.minPrice! % 10, 0);
      expect(filter.maxPrice! % 10, 0);
      expect(filter.minPrice, lessThan(filter.maxPrice!));
    });
  });

  group('the dates', () {
    testWidgets('open our own date range picker', (tester) async {
      // Wide, because the framework's own picker header does not fit the narrow
      // test font at phone width; that is not our layout.
      await BrowseHarness(repository())
          .pump(tester, size: const Size(1000, 900));
      await openSheet(tester);

      await tester.ensureVisible(find.text(en.filterDatesAny));
      await tester.tap(find.text(en.filterDatesAny));
      await tester.pumpAndSettle();

      expect(find.text(en.filterDatesHelp), findsOneWidget);
    });

    testWidgets(
      'a chosen stay shows its dates and nights, and can be cleared',
      (tester) async {
        final harness = BrowseHarness(repository());
        await harness.pump(tester);
        harness
            .container(tester)
            .read(listingFilterControllerProvider.notifier)
            .apply(
              ListingFilter(
                dates: DateRange(LocalDate(2026, 3, 1), LocalDate(2026, 3, 4)),
              ),
            );
        await tester.pumpAndSettle();
        await openSheet(tester);

        expect(find.text('Mar 1 – Mar 4 · 3 nights'), findsWidgets);

        await tester.tap(find.byTooltip(en.filterDatesClear));
        await tester.pumpAndSettle();
        expect(find.text(en.filterDatesAny), findsOneWidget);

        await apply(tester);
        expect(appliedFilter(harness, tester).dates, isNull);
      },
    );
  });

  group('the active-filter chips', () {
    final dates = DateRange(LocalDate(2026, 3, 1), LocalDate(2026, 3, 4));

    Future<BrowseHarness> pumpWith(
      WidgetTester tester,
      ListingFilter filter, {
      Locale locale = const Locale('en'),
    }) async {
      final harness = BrowseHarness(repository());
      await harness.pump(tester, locale: locale);
      harness
          .container(tester)
          .read(listingFilterControllerProvider.notifier)
          .apply(filter);
      await tester.pumpAndSettle();
      return harness;
    }

    testWidgets('show nothing when no filter is applied', (tester) async {
      await BrowseHarness(repository()).pump(tester);

      expect(find.byType(InputChip), findsNothing);
      expect(find.text(en.browseClearFilters), findsNothing);
    });

    testWidgets('a sort alone is not a filter', (tester) async {
      await pumpWith(
        tester,
        const ListingFilter(sort: ListingSort.priceHighToLow),
      );

      expect(find.byType(InputChip), findsNothing);
    });

    testWidgets('show one chip per filter', (tester) async {
      await pumpWith(
        tester,
        ListingFilter(
          city: 'Davos',
          guests: 3,
          minPrice: 100,
          maxPrice: 300,
          dates: dates,
        ),
      );

      expect(find.widgetWithText(InputChip, 'Davos'), findsOneWidget);
      expect(find.widgetWithText(InputChip, '3+ guests'), findsOneWidget);
      expect(
        find.widgetWithText(InputChip, 'Mar 1 – Mar 4 · 3 nights'),
        findsOneWidget,
      );
      expect(chipWhere((text) => text.contains('100')), findsOneWidget);
      expect(chipWhere((text) => text.contains('300')), findsOneWidget);
      expect(find.byType(InputChip), findsNWidgets(4));
    });

    testWidgets('a one-sided price says From or Up to', (tester) async {
      await pumpWith(tester, const ListingFilter(minPrice: 100));
      expect(chipWhere((text) => text.startsWith('From')), findsOneWidget);

      await pumpWith(tester, const ListingFilter(maxPrice: 300));
      expect(chipWhere((text) => text.startsWith('Up to')), findsOneWidget);
    });

    testWidgets('deleting a chip removes only that filter', (tester) async {
      final harness = await pumpWith(
        tester,
        ListingFilter(city: 'Davos', guests: 3, dates: dates),
      );

      await tester.tap(find.byTooltip(en.filterRemove).first);
      await tester.pumpAndSettle();

      final filter = appliedFilter(harness, tester);
      expect(filter.city, isNull);
      expect(filter.guests, 3);
      expect(filter.dates, dates);
      expect(find.byType(InputChip), findsNWidgets(2));
    });

    testWidgets('deleting the price chip removes both bounds', (tester) async {
      final harness = await pumpWith(
        tester,
        const ListingFilter(minPrice: 100, maxPrice: 300),
      );

      await tester.ensureVisible(find.byTooltip(en.filterRemove));
      await tester.tap(find.byTooltip(en.filterRemove));
      await tester.pumpAndSettle();

      final filter = appliedFilter(harness, tester);
      expect(filter.minPrice, isNull);
      expect(filter.maxPrice, isNull);
    });

    testWidgets('Clear filters removes every one and keeps the sort', (
      tester,
    ) async {
      final harness = await pumpWith(
        tester,
        ListingFilter(
          city: 'Davos',
          guests: 3,
          dates: dates,
          sort: ListingSort.priceLowToHigh,
        ),
      );

      await tester.tap(find.text(en.browseClearFilters));
      await tester.pumpAndSettle();

      final filter = appliedFilter(harness, tester);
      expect(filter.isUnfiltered, isTrue);
      expect(filter.sort, ListingSort.priceLowToHigh);
      expect(find.byType(InputChip), findsNothing);
    });

    testWidgets('are translated', (tester) async {
      await pumpWith(
        tester,
        const ListingFilter(guests: 3, minPrice: 100),
        locale: const Locale('de'),
      );

      expect(find.widgetWithText(InputChip, '3+ Gäste'), findsOneWidget);
      expect(chipWhere((text) => text.startsWith('Ab')), findsOneWidget);
    });
  });
}
