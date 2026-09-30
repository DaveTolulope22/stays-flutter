import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listings/listings.dart';

import 'support/card_harness.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    Listing? listing,
    VoidCallback? onTap,
    bool canSeeReviews = true,
    Locale locale = const Locale('en'),
    Size size = const Size(400, 900),
    double textScale = 1,
    ListingActionBuilder? saveAction,
  }) => pumpListingWidget(
    tester,
    ListingCard(listing: listing ?? testListing(), onTap: onTap ?? () {}),
    canSeeReviews: canSeeReviews,
    locale: locale,
    size: size,
    textScale: textScale,
    saveAction: saveAction,
  );

  testWidgets('shows title, city, price per night and rating', (tester) async {
    await pumpCard(tester);

    expect(find.text('Chalet with a view'), findsOneWidget);
    expect(find.text('Davos'), findsOneWidget);
    expect(find.textContaining('249'), findsOneWidget);
    expect(find.textContaining('/ night'), findsOneWidget);
    expect(find.text('4.8 (12)'), findsOneWidget);
  });

  testWidgets('prices in the row currency and the locale', (tester) async {
    await pumpCard(tester, locale: const Locale('de'));

    expect(find.textContaining('CHF'), findsOneWidget);
    expect(find.textContaining('/ Nacht'), findsOneWidget);
    expect(find.text('4,8 (12)'), findsOneWidget);
  });

  testWidgets('hides the rating when reviews are off', (tester) async {
    await pumpCard(tester, canSeeReviews: false);

    expect(find.text('4.8 (12)'), findsNothing);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
  });

  testWidgets('a tap calls onTap', (tester) async {
    var taps = 0;
    await pumpCard(tester, onTap: () => taps++);

    await tester.tap(find.byType(ListingCard));

    expect(taps, 1);
  });

  testWidgets('a failed image shows the placeholder and does not throw', (
    tester,
  ) async {
    await pumpCard(tester);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });

  testWidgets('a listing with no images still builds', (tester) async {
    await pumpCard(tester, listing: testListing(images: const []));

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });

  group('save slot', () {
    testWidgets('is empty by default', (tester) async {
      await pumpCard(tester);

      expect(find.byKey(const Key('save')), findsNothing);
    });

    testWidgets('shows what the slot builds, for that listing', (tester) async {
      Listing? received;
      await pumpCard(
        tester,
        saveAction: (listing) {
          received = listing;
          return const SizedBox(key: Key('save'), width: 48, height: 48);
        },
      );

      expect(find.byKey(const Key('save')), findsOneWidget);
      expect(received?.id, 'l1');
    });
  });

  group('semantics', () {
    testWidgets('one label with title, city, price and rating', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCard(tester);

      expect(
        find.bySemanticsLabel(
          RegExp(
            r'Chalet with a view, Davos, .*249.* / night, '
            r'Rated 4\.8 out of 5 from 12 reviews',
          ),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('leaves the rating out when reviews are off', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCard(tester, canSeeReviews: false);

      expect(
        find.bySemanticsLabel(RegExp('Chalet with a view')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp('Rated')), findsNothing);
      handle.dispose();
    });

    testWidgets('says the listing is new when it has no reviews', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpCard(tester, listing: testListing(rating: 0, reviewsCount: 0));

      expect(
        find.bySemanticsLabel(RegExp('New listing, no reviews yet')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('reads the German rating with a comma', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCard(tester, locale: const Locale('de'));

      expect(
        find.bySemanticsLabel(RegExp(r'Bewertet mit 4,8 von 5 aus 12')),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('long text', () {
    const longGerman =
        'Gemütliche Ferienwohnung mit Bergblick und Wellnessbereich '
        'in Garmisch-Partenkirchen mit Selbstversorgung';

    testWidgets('a long title and city do not overflow a narrow card', (
      tester,
    ) async {
      await pumpCard(
        tester,
        listing: testListing(
          title: longGerman,
          city: 'Sankt Gallenkirch im Montafon',
        ),
        locale: const Locale('de'),
        size: const Size(320, 900),
        textScale: 1.5,
      );

      expect(tester.takeException(), isNull);
    });
  });
}
