import 'package:core/core.dart';
import 'package:listings/listings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/host_repository_provider.dart';

part 'host_listings.g.dart';

/// The pages of the signed-in host's own listings.
///
/// Auto-dispose: pages live only while the host's listings screen is open, and
/// the next host to sign in starts from nothing. It does not retry
/// automatically; the screen shows the error with a Retry button.
///
/// The value is `AsyncData(PagedState)`. The first page failing is an
/// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
/// and sets `loadMoreError` instead.
@Riverpod(retry: noAutomaticRetry)
class HostListings extends _$HostListings {
  /// Counts builds. A "load more" that started before a refresh must not write
  /// its page into the refreshed list.
  int _generation = 0;

  @override
  Future<PagedState<Listing>> build() async {
    _generation++;
    final result = await ref.watch(hostRepositoryProvider).listings().run();
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
        .listings(cursor: current.nextCursor)
        .run();

    // Gone (the screen left) or replaced (a refresh): drop this answer.
    if (!ref.mounted || generation != _generation) return;
    state = AsyncData(
      result.fold(current.loadMoreFailed, current.withNextPage),
    );
  }

  /// Puts an edited listing back in its place, so the list shows the change
  /// without a refetch. A listing that is not loaded (another page) is ignored:
  /// the next load gets it as the API now has it.
  void replace(Listing updated) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final listing in current.items)
            if (listing.id == updated.id) updated else listing,
        ],
      ),
    );
  }
}
