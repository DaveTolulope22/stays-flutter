import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../bookings/booking_status_view.dart';
import '../models/booking.dart';
import '../state/listing_bookings.dart';
import '../widgets/booking_card.dart';

/// The bookings on one listing, newest check-in first: status chips, a card per
/// booking, infinite scroll, pull to refresh, and a loading, empty and error
/// state that each offer the way forward. Read only.
///
/// The chosen status lives here, as the screen's own state: it is not shared
/// with anything, and it starts at "all" each time the screen opens.
class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({required this.listingId, super.key});

  final String listingId;

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  /// Null means every status.
  BookingStatus? _status;

  Future<void> _refresh() async {
    // Invalidating keeps the old pages on screen until the new first page
    // arrives, and awaiting the future is what the refresh spinner waits for.
    final provider = listingBookingsProvider(widget.listingId, _status);
    ref.invalidate(provider);
    try {
      await ref.read(provider.future);
    } on Object {
      // The provider now holds the error and the screen shows it.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = listingBookingsProvider(widget.listingId, _status);
    final bookings = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.hostActionBookings)),
      // The chips stay above every state, so a host looking at an empty filter
      // can still pick another one.
      body: Column(
        children: [
          _StatusFilter(
            selected: _status,
            onSelected: (status) => setState(() => _status = status),
          ),
          Expanded(
            child: bookings.when(
              loading: () => LoadingView(semanticsLabel: l10n.loading),
              error: (error, _) => ErrorView(
                message: error is AppFailure
                    ? failureMessage(error, l10n)
                    : l10n.errorGeneric,
                action: ViewAction(
                  label: l10n.retry,
                  onPressed: () => ref.invalidate(provider),
                ),
              ),
              data: (paged) {
                if (paged.items.isEmpty) return _empty(l10n);
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: PagedListView<Booking>(
                    paged: paged,
                    onLoadMore: () =>
                        unawaited(ref.read(provider.notifier).loadMore()),
                    failureText: (failure) => failureMessage(failure, l10n),
                    retryLabel: l10n.retry,
                    loadingLabel: l10n.loading,
                    header: Text(
                      l10n.hostBookingsCount(paged.total ?? paged.items.length),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    itemBuilder: (context, booking) =>
                        BookingCard(booking: booking),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(AppLocalizations l10n) {
    final filtered = _status != null;
    return EmptyView(
      icon: Icons.event_busy_outlined,
      message: filtered
          ? l10n.hostBookingsEmptyFiltered
          : l10n.hostBookingsEmpty,
      action: filtered
          ? ViewAction(
              label: l10n.hostBookingsShowAll,
              onPressed: () => setState(() => _status = null),
            )
          : null,
    );
  }
}

/// "All" and one chip per status, all visible at once: they wrap onto another
/// line on a narrow screen or in German rather than hiding off the edge.
class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.selected, required this.onSelected});

  final BookingStatus? selected;
  final ValueChanged<BookingStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.m,
        AppSpacing.xs,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.xs,
          children: [
            ChoiceChip(
              label: Text(l10n.hostBookingsFilterAll),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
            for (final status in bookingStatusFilters)
              ChoiceChip(
                avatar: Icon(bookingStatusIcon(status), size: AppSizes.iconS),
                label: Text(bookingStatusLabel(status, l10n)),
                selected: selected == status,
                onSelected: (_) => onSelected(status),
              ),
          ],
        ),
      ),
    );
  }
}
