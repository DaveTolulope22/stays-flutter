import 'package:fpdart/fpdart.dart';
import 'package:listings/listings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/host_repository_provider.dart';
import '../models/listing_patch.dart';
import 'host_listings.dart';

part 'listing_saver.g.dart';

/// Saves the edit form: one PATCH, and what happened to it.
///
/// Auto-dispose: it is the state of one open edit screen, and a failure from
/// one visit must not greet the next. The value is idle or saving, or an
/// `AsyncError` holding the `AppFailure` of the last attempt, which the screen
/// shows as one banner (the API is all or nothing, so there is no per-field
/// error to show).
@riverpod
class ListingSaver extends _$ListingSaver {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Sends [patch] for [listingId]. On success the updated listing replaces the
  /// old one in the host's list, so the list shows it without a refetch, and
  /// the listing is returned. On failure nothing changes anywhere and the
  /// failure is held in [state].
  ///
  /// A second call while one is on its way does nothing.
  Future<Option<Listing>> save(String listingId, ListingPatch patch) async {
    if (state.isLoading) return const None();
    state = const AsyncLoading();

    final result = await ref
        .read(hostRepositoryProvider)
        .update(listingId, patch)
        .run();

    // The screen left while the request was out: there is nobody to tell.
    if (!ref.mounted) return const None();
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return const None();
      },
      (updated) {
        state = const AsyncData(null);
        ref.read(hostListingsProvider.notifier).replace(updated);
        return Some(updated);
      },
    );
  }
}
