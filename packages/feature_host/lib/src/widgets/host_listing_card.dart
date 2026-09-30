import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

/// One of the host's listings: cover image, title, city and price per night,
/// with what the host can do to it. It does not navigate; the screen says what
/// each action opens.
///
/// Unlike the guest's card it is not one big tap target: a host comes here to
/// pick an action, so the three actions are the controls, each labelled for
/// screen readers with the listing it belongs to.
class HostListingCard extends StatelessWidget {
  const HostListingCard({
    required this.listing,
    required this.onEdit,
    required this.onCalendar,
    required this.onBookings,
    super.key,
  });

  final Listing listing;
  final VoidCallback onEdit;
  final VoidCallback onCalendar;
  final VoidCallback onBookings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final title = listing.title;

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.largeAll,
        side: BorderSide(color: colors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: AppSizes.listingImageAspectRatio,
            child: ListingImage(url: listing.coverImage),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  listing.city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  l10n.listingPricePerNight(
                    formatPrice(
                      listing.pricePerNight,
                      listing.currency,
                      locale,
                    ),
                  ),
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.s),
                // Wraps, so a long German label moves to the next line instead
                // of overflowing.
                Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _Action(
                      icon: Icons.edit_outlined,
                      label: l10n.hostActionEdit,
                      semanticsLabel: l10n.hostActionEditSemantics(title),
                      onPressed: onEdit,
                    ),
                    _Action(
                      icon: Icons.calendar_month_outlined,
                      label: l10n.hostActionCalendar,
                      semanticsLabel: l10n.hostActionCalendarSemantics(title),
                      onPressed: onCalendar,
                    ),
                    _Action(
                      icon: Icons.event_note_outlined,
                      label: l10n.hostActionBookings,
                      semanticsLabel: l10n.hostActionBookingsSemantics(title),
                      onPressed: onBookings,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, AppSizes.minTapTarget),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: AppSizes.iconS),
        label: Text(label),
      ),
    );
  }
}
