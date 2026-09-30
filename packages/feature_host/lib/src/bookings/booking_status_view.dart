import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../models/booking.dart';

/// The statuses a host can filter by, in the order the chips show them. Not
/// [BookingStatus.unknown]: that is what a status we have never seen decodes to,
/// not something the API can be asked for.
const bookingStatusFilters = [
  BookingStatus.confirmed,
  BookingStatus.pending,
  BookingStatus.completed,
  BookingStatus.cancelled,
];

/// Our own word for a booking status. A status this app does not know gets a
/// generic label, so one new value on the API never breaks the list.
String bookingStatusLabel(BookingStatus status, AppLocalizations l10n) =>
    switch (status) {
      BookingStatus.confirmed => l10n.bookingStatusConfirmed,
      BookingStatus.pending => l10n.bookingStatusPending,
      BookingStatus.completed => l10n.bookingStatusCompleted,
      BookingStatus.cancelled => l10n.bookingStatusCancelled,
      BookingStatus.unknown => l10n.bookingStatusUnknown,
    };

/// The icon that goes with a status. Every status has its own, so the badge
/// never depends on colour alone.
IconData bookingStatusIcon(BookingStatus status) => switch (status) {
  BookingStatus.confirmed => Icons.check_circle_outline,
  BookingStatus.pending => Icons.schedule,
  BookingStatus.completed => Icons.done_all,
  BookingStatus.cancelled => Icons.cancel_outlined,
  BookingStatus.unknown => Icons.help_outline,
};
