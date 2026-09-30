import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_browse/feature_browse.dart';
import 'package:feature_browse/src/screens/browse_screen.dart';
import 'package:feature_browse/src/screens/listing_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:listings/listings.dart';

import 'support/browse_harness.dart';

const _deepLink = '/browse/listing/l7';

void main() {
  // A tap that misses its target must fail the test, not just warn: a missed
  // tap can leave an assertion true for the wrong reason.
  WidgetController.hitTestWarningShouldBeFatal = true;

  final en = copyFor('en');
  final de = copyFor('de');

  ScriptedRepository repository({
    Future<Either<AppFailure, Listing>> Function(String id)? onDetail,
  }) => ScriptedRepository(
    (filter, cursor) async => right(pageOf(3, total: 3)),
    onDetail: onDetail,
  );

  /// Opens the detail screen straight from a link, as a deep link would.
  Future<BrowseHarness> openDetail(
    WidgetTester tester, {
    ScriptedRepository? repo,
    bool canSeeReviews = true,
    Locale locale = const Locale('en'),
    Size size = const Size(400, 900),
    ListingActionBuilder? saveAction,
  }) async {
    final harness = BrowseHarness(
      repo ?? repository(),
      canSeeReviews: canSeeReviews,
      saveAction: saveAction,
    );
    await harness.pump(tester, locale: locale, size: size, location: _deepLink);
    return harness;
  }

  ScriptedRepository repositoryWith(Listing listing) =>
      repository(onDetail: (id) async => right(listing));

  group('the content', () {
    testWidgets('shows the listing, fetched by its id', (tester) async {
      final repo = repository();
      await openDetail(tester, repo: repo);

      expect(repo.detailCalls, ['l7']);
      expect(find.text('Stay l7'), findsOneWidget);
      expect(find.text('Davos, Switzerland'), findsOneWidget);
      expect(find.text('4 guests'), findsOneWidget);
      expect(find.text('2 bedrooms'), findsOneWidget);
      expect(find.text('3 beds'), findsOneWidget);
      expect(find.text('1 bathroom'), findsOneWidget);
      expect(find.text('Quiet chalet near the lift.'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'Wi-Fi'), findsOneWidget);
      expect(find.textContaining('249'), findsOneWidget);
      expect(find.textContaining('/ night'), findsOneWidget);
      expect(find.textContaining('once per stay'), findsOneWidget);
    });

    testWidgets('is translated, including the country and the plurals', (
      tester,
    ) async {
      await openDetail(tester, locale: const Locale('de'));

      expect(find.text('Davos, Schweiz'), findsOneWidget);
      expect(find.text('4 Gäste'), findsOneWidget);
      expect(find.text('2 Schlafzimmer'), findsOneWidget);
      expect(find.text('3 Betten'), findsOneWidget);
      expect(find.text('1 Badezimmer'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'WLAN'), findsOneWidget);
      expect(find.textContaining('Reinigungsgebühr'), findsOneWidget);
      expect(find.textContaining('/ Nacht'), findsOneWidget);
    });

    testWidgets('no bedrooms means a studio', (tester) async {
      await openDetail(
        tester,
        repo: repositoryWith(listingFixture('l7', bedrooms: 0)),
      );

      expect(find.text('Studio'), findsOneWidget);
      expect(find.textContaining('0 bedrooms'), findsNothing);
    });

    testWidgets('a country it has no name for shows the raw code', (
      tester,
    ) async {
      await openDetail(
        tester,
        repo: repositoryWith(listingFixture('l7', country: 'ZZ')),
      );

      expect(find.text('Davos, ZZ'), findsOneWidget);
    });

    testWidgets('an amenity it has no label for is still shown', (
      tester,
    ) async {
      await openDetail(
        tester,
        repo: repositoryWith(
          listingFixture('l7', amenities: const ['wifi', 'teleporter']),
        ),
      );

      expect(find.widgetWithText(Chip, 'Wi-Fi'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'Teleporter'), findsOneWidget);
    });

    testWidgets('a listing with no amenities has no amenities heading', (
      tester,
    ) async {
      await openDetail(
        tester,
        repo: repositoryWith(listingFixture('l7', amenities: const [])),
      );

      expect(find.text(en.detailAmenities), findsNothing);
    });

    testWidgets('no cleaning fee, no cleaning fee line', (tester) async {
      await openDetail(
        tester,
        repo: repositoryWith(listingFixture('l7', cleaningFee: 0)),
      );

      expect(find.textContaining('once per stay'), findsNothing);
    });

    testWidgets('a long German title and facts do not overflow', (
      tester,
    ) async {
      await openDetail(
        tester,
        repo: repositoryWith(
          listingFixture(
            'l7',
            title: 'Gemütliche Ferienwohnung mit Bergblick und Wellnessbereich',
            amenities: const [
              'pets_allowed',
              'air_conditioning',
              'ski_storage',
            ],
          ),
        ),
        locale: const Locale('de'),
        size: const Size(320, 700),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('the rating', () {
    testWidgets('is shown when reviews are on', (tester) async {
      await openDetail(tester);

      expect(find.text('4.5 (3)'), findsOneWidget);
    });

    testWidgets('says New when nobody has reviewed it', (tester) async {
      await openDetail(
        tester,
        repo: repositoryWith(listingFixture('l7', rating: 0, reviewsCount: 0)),
      );

      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('is hidden when reviews are off; the rest stays', (
      tester,
    ) async {
      await openDetail(tester, canSeeReviews: false);

      expect(find.text('4.5 (3)'), findsNothing);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(find.text('Stay l7'), findsOneWidget);
      expect(find.text('4 guests'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('shows a spinner while it loads', (tester) async {
      final gate = Completer<Either<AppFailure, Listing>>();
      final harness = BrowseHarness(repository(onDetail: (id) => gate.future));
      await harness.pump(tester, location: _deepLink, settle: false);

      expect(find.byType(CircularProgressIndicator), findsWidgets);
      gate.complete(right(listingFixture('l7')));
      await tester.pumpAndSettle();
      expect(find.text('Stay l7'), findsOneWidget);
    });

    testWidgets('a missing listing says so in our words and offers Retry', (
      tester,
    ) async {
      var missing = true;
      await openDetail(
        tester,
        repo: repository(
          onDetail: (id) async => missing
              ? left(
                  const NotFoundFailure(
                    statusCode: 404,
                    messageCode: 'listing.NotFoundException',
                  ),
                )
              : right(listingFixture(id)),
        ),
      );

      expect(find.text(en.errorListingNotFound), findsOneWidget);
      expect(find.text('Stay l7'), findsNothing);

      missing = false;
      await tester.tap(find.text(en.retry));
      await tester.pumpAndSettle();

      expect(find.text('Stay l7'), findsOneWidget);
      expect(find.text(en.errorListingNotFound), findsNothing);
    });

    testWidgets('a network failure shows its own message', (tester) async {
      await openDetail(
        tester,
        repo: repository(onDetail: (id) async => left(const NetworkFailure())),
      );

      expect(find.text(en.errorNetwork), findsOneWidget);
    });

    testWidgets('a failure is not retried on its own', (tester) async {
      final repo = repository(
        onDetail: (id) async => left(const NetworkFailure()),
      );
      await openDetail(tester, repo: repo);

      await tester.pump(const Duration(seconds: 3));

      expect(repo.detailCalls, hasLength(1));
    });
  });

  group('the save slot', () {
    Finder inAppBar(Key key) =>
        find.descendant(of: find.byType(AppBar), matching: find.byKey(key));
    const saveKey = Key('save');

    testWidgets('is empty by default', (tester) async {
      await openDetail(tester);

      expect(find.byKey(saveKey), findsNothing);
    });

    testWidgets(
      'shows what the slot builds, in the app bar, for this listing',
      (tester) async {
        Listing? received;
        await openDetail(
          tester,
          saveAction: (listing) {
            received = listing;
            return const SizedBox(key: saveKey, width: 48, height: 48);
          },
        );

        expect(inAppBar(saveKey), findsOneWidget);
        expect(received?.id, 'l7');
      },
    );

    testWidgets('is not built while the listing is not loaded', (tester) async {
      var builds = 0;
      final gate = Completer<Either<AppFailure, Listing>>();
      final harness = BrowseHarness(
        repository(onDetail: (id) => gate.future),
        saveAction: (listing) {
          builds++;
          return const SizedBox(key: saveKey);
        },
      );

      await harness.pump(tester, location: _deepLink, settle: false);

      expect(builds, 0);
      gate.complete(right(listingFixture('l7')));
      await tester.pumpAndSettle();
      expect(builds, greaterThan(0));
    });
  });

  group('the photo pager', () {
    final photos = List.generate(3, (i) => 'https://picsum.photos/$i');
    Finder dots() => find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).shape == BoxShape.circle,
    );

    testWidgets('has a label per photo and a dot per photo', (tester) async {
      final handle = tester.ensureSemantics();
      await openDetail(
        tester,
        repo: repositoryWith(listingFixture('l7', images: photos)),
      );

      expect(find.bySemanticsLabel('Photo 1 of 3'), findsOneWidget);
      expect(dots(), findsNWidgets(3));
      handle.dispose();
    });

    testWidgets('swiping moves to the next photo', (tester) async {
      final handle = tester.ensureSemantics();
      await openDetail(
        tester,
        repo: repositoryWith(listingFixture('l7', images: photos)),
      );

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        1,
      );
      expect(find.bySemanticsLabel('Photo 2 of 3'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('one photo has no dots', (tester) async {
      await openDetail(tester);

      expect(dots(), findsNothing);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('no photo at all still builds, with a placeholder', (
      tester,
    ) async {
      await openDetail(
        tester,
        repo: repositoryWith(listingFixture('l7', images: const [])),
      );

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    });
  });

  group('navigation', () {
    testWidgets('tapping a card opens it, and back returns to the list as it '
        'was', (tester) async {
      final repo = repository();
      final harness = BrowseHarness(repo);
      await harness.pump(tester);
      expect(repo.calls, hasLength(1));

      await tester.tap(find.text('Stay l0'));
      await tester.pumpAndSettle();

      expect(find.byType(ListingDetailScreen), findsOneWidget);
      expect(repo.detailCalls, ['l0']);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(ListingDetailScreen), findsNothing);
      expect(find.byType(BrowseScreen), findsOneWidget);
      expect(find.text('Stay l0'), findsOneWidget);
      expect(repo.calls, hasLength(1), reason: 'the list was not reloaded');
    });

    testWidgets('back from a deep link leads to the list, not nowhere', (
      tester,
    ) async {
      await openDetail(tester);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(BrowseScreen), findsOneWidget);
    });

    test('an id is encoded into the location', () {
      expect(BrowsePaths.listing('l7'), '/browse/listing/l7');
      expect(BrowsePaths.listing('a b/c'), '/browse/listing/a%20b%2Fc');
    });

    testWidgets('an id with special characters arrives intact', (tester) async {
      final repo = repository();
      final harness = BrowseHarness(repo);
      await harness.pump(tester, location: BrowsePaths.listing('a b/c'));

      expect(repo.detailCalls, ['a b/c']);
    });
  });

  test('the German copy exists for every detail string', () {
    expect(de.detailAbout, isNotEmpty);
    expect(de.detailPhoto(2, 5), 'Foto 2 von 5');
  });
}
