import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

import '../bookings/booking_status_view.dart';
import '../models/booking.dart';

/// One booking on a listing: who, when, how long, how many, what it came to and
/// where it stands. Read only: nobody books through the app.
///
/// The total is shown in the booking's own currency, as it was when the booking
/// was made. A later price edit never restates it, and the tenant's currency is
/// never assumed. It reads as one item to a screen reader.
class BookingCard extends StatelessWidget {
  const BookingCard({required this.booking, super.key});

  final Booking booking;

  static String _date(LocalDate date, String locale) =>
      DateFormat.yMMMd(locale)
          .format(DateTime(date.year, date.month, date.day));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final nights = DateRange(booking.checkIn, booking.checkOut).nights;

    return MergeSemantics(
      child: Card.outlined(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.largeAll,
          side: BorderSide(color: colors.borderPrimary),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      booking.guestName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Flexible(child: _StatusBadge(status: booking.status)),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              // Wraps, so a long German date range moves the nights down a line
              // instead of overflowing.
              Wrap(
                spacing: AppSpacing.s,
                children: [
                  Text(
                    l10n.hostBookingDates(
                      _date(booking.checkIn, locale),
                      _date(booking.checkOut, locale),
                    ),
                  ),
                  Text(
                    l10n.hostBookingNights(nights),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Row(
                children: [
                  Expanded(child: Text(l10n.hostBookingGuests(booking.guests))),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    formatPrice(booking.totalPrice, booking.currency, locale),
                    style: textTheme.titleSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The status as an icon AND words in a small outlined box, so it never depends
/// on colour alone.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.smallAll,
        border: Border.all(color: colors.borderPrimary),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(bookingStatusIcon(status), size: AppSizes.iconS),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                bookingStatusLabel(status, context.l10n),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
