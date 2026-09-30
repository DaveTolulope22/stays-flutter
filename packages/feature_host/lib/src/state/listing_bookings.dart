import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/host_repository_provider.dart';
import '../models/booking.dart';

part 'listing_bookings.g.dart';

/// The pages of bookings on ONE listing, for ONE status filter (null: all).
///
/// A family keyed by the listing and the filter: each distinct filter gets its
/// own notifier with its own pages, so changing the filter starts a fresh list
/// and a slow response for the old filter can never end up in the new one.
///
/// Auto-dispose: pages live only while the bookings screen watches this filter.
/// It does not retry automatically; the screen shows the error with a Retry
/// button.
///
/// The value is `AsyncData(PagedState)`. The first page failing is an
/// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
/// and sets `loadMoreError` instead.
@Riverpod(retry: noAutomaticRetry)
class ListingBookings extends _$ListingBookings {
  /// Counts builds. A "load more" that started before a refresh must not write
  /// its page into the refreshed list.
  int _generation = 0;

  @override
  Future<PagedState<Booking>> build(
    String listingId,
    BookingStatus? status,
  ) async {
    _generation++;
    final result = await ref
        .watch(hostRepositoryProvider)
        .bookings(listingId, status: status)
        .run();
    return result.fold((failure) => throw failure, PagedState.fromFirstPage);
  }

  /// Fetches the next page. Safe to call any number of times: it does nothing
  /// while a page is on its way, at the end of the list, or while the first
  /// page is (re)loading.
  ///
  /// The flag that blocks a second call is set BEFORE the first `await`, so two
  /// scroll events in the same frame cannot both pass the check.
  Future<void> loadMore() async {
    final current = state.value;
    if (state.isLoading || state.hasError || current == null) return;
    if (!current.canLoadMore) return;

    final generation = _generation;
    state = AsyncData(current.loadingMore());

    final result = await ref
        .read(hostRepositoryProvider)
        .bookings(listingId, status: status, cursor: current.nextCursor)
        .run();

    // Gone (the screen left) or replaced (a refresh): drop this answer.
    if (!ref.mounted || generation != _generation) return;
    state = AsyncData(
      result.fold(current.loadMoreFailed, current.withNextPage),
    );
  }
}
