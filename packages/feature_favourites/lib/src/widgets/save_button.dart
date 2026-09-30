import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

import '../state/favourites.dart';

/// The heart on a listing: outline when not saved, filled when saved.
///
/// It draws NOTHING unless the capability `canSaveListings` is true. The shell
/// fills the card's slot with this button whenever the tenant has favourites
/// on, but a host shares that tenant and must never see it. The capability is
/// checked before the list is read, so a host never makes a `/favourites`
/// request either.
class SaveButton extends ConsumerWidget {
  const SaveButton({required this.listing, super.key});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSave = ref.watch(
      capabilitiesProvider.select(
        (capabilities) => capabilities.canSaveListings,
      ),
    );
    if (!canSave) return const SizedBox.shrink();

    final l10n = context.l10n;
    final colors = context.colors;
    final saved = ref.watch(favouritesProvider);
    final isSaved =
        saved.value?.any((candidate) => candidate.id == listing.id) ?? false;

    return IconButton(
      tooltip: isSaved ? l10n.unsaveListing : l10n.saveListing,
      isSelected: isSaved,
      icon: const Icon(Icons.favorite_border),
      selectedIcon: const Icon(Icons.favorite),
      style: IconButton.styleFrom(
        backgroundColor: colors.surfacePrimary,
        foregroundColor: colors.iconAction,
      ),
      // Not until the list is known: a tap now could not tell save from unsave.
      onPressed: saved.hasValue ? () => _toggle(context, ref) : null,
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    // Taken before the await: the card may be gone when the answer arrives.
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    final failure = await ref.read(favouritesProvider.notifier).toggle(listing);

    failure.match(
      () {},
      (failure) => messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(failure, l10n))),
      ),
    );
  }
}

/// What the shell puts into `listingSaveActionProvider`.
Widget saveActionBuilder(Listing listing) => SaveButton(listing: listing);
