import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../formatting/formatting.dart';
import '../models/listing.dart';
import '../slots/listing_save_action.dart';
import 'rating_badge.dart';

/// A listing in a list: cover image, title, city, price per night and, when
/// reviews are visible, the rating. Browse, favourites and host screens all
/// show listings, which is why the card lives in the domain package.
///
/// The card does not navigate; the screen decides what a tap does. The save
/// control comes from [listingSaveActionProvider], so the card has no idea
/// whether favourites exist in this tenant.
class ListingCard extends ConsumerWidget {
  const ListingCard({required this.listing, required this.onTap, super.key});

  final Listing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final showRating = ref.watch(
      capabilitiesProvider.select((capabilities) => capabilities.canSeeReviews),
    );
    final saveAction = ref.watch(listingSaveActionProvider);

    final price = l10n.listingPricePerNight(
      formatPrice(listing.pricePerNight, listing.currency, locale),
    );
    final semanticsLabel = showRating
        ? l10n.listingCardSemanticsRated(
            listing.title,
            listing.city,
            price,
            ratingSemanticsLabel(listing, l10n, locale),
          )
        : l10n.listingCardSemantics(listing.title, listing.city, price);

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.largeAll,
        side: BorderSide(color: colors.borderPrimary),
      ),
      child: Stack(
        children: [
          // One label for the whole card. The save control sits outside this
          // node so a screen reader can still reach it on its own.
          Semantics(
            button: true,
            label: semanticsLabel,
            excludeSemantics: true,
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: AppSizes.listingImageAspectRatio,
                    child: _CoverImage(url: listing.coverImage),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                listing.city,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            RatingBadge(listing: listing),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(price, style: textTheme.titleSmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (saveAction != null)
            Positioned(
              top: AppSpacing.s,
              right: AppSpacing.s,
              child: saveAction(listing),
            ),
        ],
      ),
    );
  }
}

/// The cover, with a plain surface while it loads and an icon if it fails, so
/// a missing image never changes the card's size or throws.
class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null) {
      return const _ImagePlaceholder(icon: Icons.image_not_supported_outlined);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      excludeFromSemantics: true,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _ImagePlaceholder(),
      errorBuilder: (context, error, stackTrace) =>
          const _ImagePlaceholder(icon: Icons.image_not_supported_outlined),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.icon});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.surfaceSecondary,
      child: icon == null
          ? null
          : Center(
              child: Icon(icon, size: AppSizes.iconL, color: colors.textMuted),
            ),
    );
  }
}
