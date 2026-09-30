import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../formatting/formatting.dart';
import '../models/listing.dart';

/// What a screen reader says for the rating: the score and the number of
/// reviews, or "new listing" when there are none. The card includes it in its
/// own label whenever the badge is visible.
String ratingSemanticsLabel(
  Listing listing,
  AppLocalizations l10n,
  String locale,
) => listing.hasReviews
    ? l10n.listingRatingSemantics(
        formatRating(listing.rating, locale),
        listing.reviewsCount,
      )
    : l10n.listingNewSemantics;

/// The rating of a listing: a star with the score and review count, or "New"
/// when nobody has reviewed it (a rating of 0 is not a score).
///
/// It renders nothing unless the user may see reviews, which follows the
/// tenant's `reviews` flag. The API sends ratings either way, so hiding them is
/// this widget's decision, not the server's.
class RatingBadge extends ConsumerWidget {
  const RatingBadge({required this.listing, super.key});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSeeReviews = ref.watch(
      capabilitiesProvider.select((capabilities) => capabilities.canSeeReviews),
    );
    if (!canSeeReviews) return const SizedBox.shrink();

    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final style = Theme.of(context).textTheme.labelLarge;

    if (!listing.hasReviews) {
      return Text(l10n.listingNew, style: style);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: AppSizes.iconS),
        const SizedBox(width: AppSpacing.xs),
        Text(
          l10n.listingRatingLabel(
            formatRating(listing.rating, locale),
            listing.reviewsCount,
          ),
          style: style,
        ),
      ],
    );
  }
}
