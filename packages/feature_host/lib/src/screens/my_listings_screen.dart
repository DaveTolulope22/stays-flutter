import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

import '../host_paths.dart';
import '../state/host_listings.dart';
import '../widgets/host_listing_card.dart';

/// The host's own listings: a card each, infinite scroll, pull to refresh, and a
/// loading, empty and error state that each offer the way forward. Edit,
/// calendar and bookings open on top of it, so the list keeps its pages and
/// scroll position underneath.
class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    // Invalidating keeps the old pages on screen until the new first page
    // arrives, and awaiting the future is what the refresh spinner waits for.
    ref.invalidate(hostListingsProvider);
    try {
      await ref.read(hostListingsProvider.future);
    } on Object {
      // The provider now holds the error and the screen shows it.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final listings = ref.watch(hostListingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.hostListingsTitle),
        actions: [
          IconButton(
            tooltip: l10n.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: listings.when(
        loading: () => LoadingView(semanticsLabel: l10n.loading),
        error: (error, _) => ErrorView(
          message: error is AppFailure
              ? failureMessage(error, l10n)
              : l10n.errorGeneric,
          action: ViewAction(
            label: l10n.retry,
            onPressed: () => ref.invalidate(hostListingsProvider),
          ),
        ),
        data: (paged) {
          if (paged.items.isEmpty) {
            return EmptyView(
              icon: Icons.home_work_outlined,
              message: l10n.hostListingsEmpty,
            );
          }
          return RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: PagedListView<Listing>(
              paged: paged,
              onLoadMore: () =>
                  unawaited(ref.read(hostListingsProvider.notifier).loadMore()),
              failureText: (failure) => failureMessage(failure, l10n),
              retryLabel: l10n.retry,
              loadingLabel: l10n.loading,
              itemBuilder: (context, listing) => HostListingCard(
                listing: listing,
                onEdit: () => context.push(HostPaths.edit(listing.id)),
                onCalendar: () => context.push(HostPaths.calendar(listing.id)),
                onBookings: () => context.push(HostPaths.bookings(listing.id)),
              ),
            ),
          );
        },
      ),
    );
  }
}
