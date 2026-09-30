import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listings/listings.dart';

import 'support/card_harness.dart';

void main() {
  testWidgets('shows the score and the review count', (tester) async {
    await pumpListingWidget(tester, RatingBadge(listing: testListing()));

    expect(find.text('4.8 (12)'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
  });

  testWidgets('writes the score with a decimal comma in German', (
    tester,
  ) async {
    await pumpListingWidget(
      tester,
      RatingBadge(listing: testListing()),
      locale: const Locale('de'),
    );

    expect(find.text('4,8 (12)'), findsOneWidget);
    expect(find.textContaining('4.8'), findsNothing);
  });

  testWidgets('a rating of 5 sent as an int shows as 5.0', (tester) async {
    await pumpListingWidget(
      tester,
      RatingBadge(listing: testListing(rating: 5)),
    );

    expect(find.text('5.0 (12)'), findsOneWidget);
  });

  testWidgets('a listing with no reviews says New, not a zero score', (
    tester,
  ) async {
    await pumpListingWidget(
      tester,
      RatingBadge(listing: testListing(rating: 0, reviewsCount: 0)),
    );

    expect(find.text('New'), findsOneWidget);
    expect(find.textContaining('0.0'), findsNothing);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
  });

  testWidgets('says Neu in German', (tester) async {
    await pumpListingWidget(
      tester,
      RatingBadge(listing: testListing(rating: 0, reviewsCount: 0)),
      locale: const Locale('de'),
    );

    expect(find.text('Neu'), findsOneWidget);
  });

  testWidgets('shows nothing when the user may not see reviews', (
    tester,
  ) async {
    await pumpListingWidget(
      tester,
      RatingBadge(listing: testListing()),
      canSeeReviews: false,
    );

    expect(find.byType(Text), findsNothing);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
  });

  testWidgets('shows neither a score nor New when reviews are off', (
    tester,
  ) async {
    await pumpListingWidget(
      tester,
      RatingBadge(listing: testListing(rating: 0, reviewsCount: 0)),
      canSeeReviews: false,
    );

    expect(find.text('New'), findsNothing);
  });
}
