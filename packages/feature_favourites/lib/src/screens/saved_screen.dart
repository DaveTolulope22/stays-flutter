import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

import '../state/favourites.dart';

/// The listings the guest saved, as the same cards browse shows. Each card's
/// heart comes from the save slot, so removing one here is the ordinary
/// optimistic toggle: the card goes at once and comes back if that fails.
///
/// The screen does not know where a listing opens; [listingLocation] is given
/// by the shell, so this package never names a browse path.
class SavedScreen extends ConsumerWidget {
  const SavedScreen({required this.listingLocation, super.key});

  final String Function(String listingId) listingLocation;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(favouritesProvider);
    try {
      await ref.read(favouritesProvider.future);
    } on Object {
      // The provider now holds the error and the screen shows it.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final saved = ref.watch(favouritesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.savedTitle)),
      body: saved.when(
        loading: () => LoadingView(semanticsLabel: l10n.loading),
        error: (error, _) => ErrorView(
          message: error is AppFailure
              ? failureMessage(error, l10n)
              : l10n.errorGeneric,
          action: ViewAction(
            label: l10n.retry,
            onPressed: () => ref.invalidate(favouritesProvider),
          ),
        ),
        data: (listings) {
          if (listings.isEmpty) {
            return EmptyView(
              icon: Icons.favorite_border,
              message: l10n.savedEmpty,
            );
          }
          return RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxContentWidth,
                ),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.m),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.m),
                      child: ListingCard(
                        listing: listing,
                        onTap: () => context.go(listingLocation(listing.id)),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
