import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

import '../browse_paths.dart';
import '../state/listing_detail_provider.dart';
import 'availability_section.dart';

/// One listing: photos, where it is, what it offers and what it costs.
///
/// It opens on top of the list (in the browse branch), so going back returns to
/// the list exactly as it was.
class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({required this.listingId, super.key});

  final String listingId;

  /// Back goes to the previous screen; a deep link has none, so it goes to the
  /// list instead of leaving the user with no way out.
  void _leave(BuildContext context) =>
      context.canPop() ? context.pop() : context.go(BrowsePaths.base);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detail = ref.watch(listingDetailProvider(listingId));
    final saveAction = ref.watch(listingSaveActionProvider);
    final listing = detail.value;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => _leave(context)),
        actions: [
          if (saveAction != null && listing != null) saveAction(listing),
        ],
      ),
      body: detail.when(
        loading: () => LoadingView(semanticsLabel: l10n.loading),
        error: (error, _) => ErrorView(
          message: error is AppFailure
              ? failureMessage(error, l10n)
              : l10n.errorGeneric,
          action: ViewAction(
            label: l10n.retry,
            onPressed: () => ref.invalidate(listingDetailProvider(listingId)),
          ),
        ),
        data: (listing) => _Detail(listing: listing),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;

    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PhotoPager(images: listing.images),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        listing.title,
                        style: textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.detailLocation(
                              listing.city,
                              countryLabel(listing.country, l10n),
                            ),
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        RatingBadge(listing: listing),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),
                    _Facts(listing: listing),
                    const SizedBox(height: AppSpacing.l),
                    _Section(
                      title: l10n.detailAbout,
                      child: Text(listing.description),
                    ),
                    if (listing.amenities.isNotEmpty)
                      _Section(
                        title: l10n.detailAmenities,
                        child: Wrap(
                          spacing: AppSpacing.s,
                          runSpacing: AppSpacing.s,
                          children: [
                            for (final slug in listing.amenities)
                              Chip(
                                avatar: Icon(amenityIcon(slug)),
                                label: Text(amenityLabel(slug, l10n)),
                              ),
                          ],
                        ),
                      ),
                    _Section(
                      title: l10n.detailPrice,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.listingPricePerNight(
                              formatPrice(
                                listing.pricePerNight,
                                listing.currency,
                                locale,
                              ),
                            ),
                            style: textTheme.titleLarge,
                          ),
                          if (listing.cleaningFee > 0)
                            Text(
                              l10n.detailCleaningFee(
                                formatPrice(
                                  listing.cleaningFee,
                                  listing.currency,
                                  locale,
                                ),
                              ),
                              style: textTheme.bodyMedium?.copyWith(
                                color: colors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _Section(
                      title: l10n.availabilityTitle,
                      child: AvailabilitySection(listingId: listing.id),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The listing's photos. Swipe to change; a dot per photo shows where you are
/// (only when there is more than one). Each photo has its own screen reader
/// label ("Photo 2 of 5"); the dots are decoration and are left out.
class _PhotoPager extends StatefulWidget {
  const _PhotoPager({required this.images});

  final List<String> images;

  @override
  State<_PhotoPager> createState() => _PhotoPagerState();
}

class _PhotoPagerState extends State<_PhotoPager> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final images = widget.images;
    // No photo at all still shows one placeholder, so the layout never changes.
    final count = images.isEmpty ? 1 : images.length;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: AppSizes.listingImageAspectRatio,
          child: PageView.builder(
            controller: _controller,
            itemCount: count,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) => Semantics(
              image: true,
              label: l10n.detailPhoto(index + 1, count),
              child: ListingImage(url: images.isEmpty ? null : images[index]),
            ),
          ),
        ),
        if (count > 1)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s),
            child: ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < count; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      child: SizedBox(
                        width: AppSizes.pagerDot,
                        height: AppSizes.pagerDot,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _page
                                ? colors.surfaceAction
                                : colors.borderPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Guests, bedrooms, beds and bathrooms. A wrapping row, so a long German
/// phrase moves to the next line instead of overflowing.
class _Facts extends StatelessWidget {
  const _Facts({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.m,
      runSpacing: AppSpacing.s,
      children: [
        _Fact(Icons.people_outline, l10n.detailGuests(listing.maxGuests)),
        _Fact(Icons.bed_outlined, l10n.detailBedrooms(listing.bedrooms)),
        _Fact(Icons.single_bed_outlined, l10n.detailBeds(listing.beds)),
        _Fact(Icons.bathtub_outlined, l10n.detailBathrooms(listing.bathrooms)),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconM),
        const SizedBox(width: AppSpacing.xs),
        Flexible(child: Text(label)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: AppSpacing.s),
          child,
        ],
      ),
    );
  }
}
