import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

import 'listing_json.dart';

Listing testListing({
  Object rating = 4.83,
  int reviewsCount = 12,
  String? title,
  String? city,
  List<String>? images,
}) => Listing.fromJson({
  ...listingJson(rating: rating, reviewsCount: reviewsCount),
  'title': ?title,
  'city': ?city,
  'images': ?images,
});

/// Pumps a widget in the app's theme with real localisation, the capabilities
/// a test asks for, and optionally a filled save slot. No network is involved:
/// `Image.network` fails under the test binding, which shows the placeholder.
Future<void> pumpListingWidget(
  WidgetTester tester,
  Widget child, {
  bool canSeeReviews = true,
  Locale locale = const Locale('en'),
  Size size = const Size(400, 900),
  double textScale = 1,
  ListingActionBuilder? saveAction,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        capabilitiesProvider.overrideWithValue(
          Capabilities(area: AccessArea.guest, canSeeReviews: canSeeReviews),
        ),
        if (saveAction != null)
          listingSaveActionProvider.overrideWithValue(saveAction),
      ],
      child: MaterialApp(
        theme: buildNeutralTheme(Brightness.light),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
  await tester.pump();
}

AppLocalizations copyFor(String language) =>
    lookupAppLocalizations(Locale(language));
