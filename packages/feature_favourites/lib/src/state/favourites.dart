import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:listings/listings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/favourites_repository_provider.dart';

part 'favourites.g.dart';

/// The listings the signed-in user saved. The save buttons and the Saved screen
/// all read this one list, so they always agree.
///
/// keepAlive, but tied to the user: it watches the signed-in user's id, so
/// signing out or in as someone else rebuilds it from scratch and one account
/// never sees another's list. It lives as long as a session, not as long as a
/// screen, so a toggle in flight survives its card scrolling away. It does not
/// retry automatically; the Saved screen shows the error with a Retry button.
///
/// It is created only when something reads it. On a tenant with favourites off,
/// and for a host, nothing does.
@Riverpod(keepAlive: true, retry: noAutomaticRetry)
class Favourites extends _$Favourites {
  /// Listings with a request on its way. A second tap on the same one is
  /// ignored, so two requests can never cross.
  final _pending = <String>{};

  @override
  Future<List<Listing>> build() async {
    final userId = ref.watch(
      sessionControllerProvider.select((session) => session.value?.user.id),
    );
    if (userId == null) return const [];

    final result = await ref.watch(favouritesRepositoryProvider).list().run();
    return result.fold((failure) => throw failure, (listings) => listings);
  }

  bool isSaved(String listingId) =>
      state.value?.any((listing) => listing.id == listingId) ?? false;

  /// Saves or unsaves [listing]. The list changes FIRST, so the heart responds
  /// at once, then the request goes out. If it fails, only this listing is put
  /// back (an undo of one change, not a restore of an old copy of the whole
  /// list, which would also undo a toggle of another listing made meanwhile)
  /// and the failure is returned for the caller to show.
  Future<Option<AppFailure>> toggle(Listing listing) async {
    final current = state.value;
    if (current == null || _pending.contains(listing.id)) return const None();

    final index = current.indexWhere((saved) => saved.id == listing.id);
    final wasSaved = index != -1;

    _pending.add(listing.id);
    state = AsyncData([
      if (!wasSaved) listing,
      for (final saved in current)
        if (saved.id != listing.id) saved,
    ]);

    final repository = ref.read(favouritesRepositoryProvider);
    final request = wasSaved
        ? repository.remove(listing.id)
        : repository.add(listing.id);
    final result = await request.run();
    _pending.remove(listing.id);

    // The user changed while the request was out: this list is not theirs.
    if (!ref.mounted) return const None();

    return result.fold(
      (failure) {
        _undo(listing, wasSaved: wasSaved, index: index);
        return Some(failure);
      },
      (_) => const None(),
    );
  }

  void _undo(Listing listing, {required bool wasSaved, required int index}) {
    final now = state.value ?? const <Listing>[];
    if (wasSaved) {
      final restored = [...now];
      restored.insert(index.clamp(0, restored.length), listing);
      state = AsyncData(restored);
    } else {
      state = AsyncData([
        for (final saved in now)
          if (saved.id != listing.id) saved,
      ]);
    }
  }
}
