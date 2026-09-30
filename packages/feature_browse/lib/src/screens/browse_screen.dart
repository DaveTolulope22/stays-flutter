import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

import '../browse_paths.dart';
import '../filter/active_filter_chips.dart';
import '../filter/filter_sheet.dart';
import '../state/browse_listings.dart';
import '../state/listing_facets_provider.dart';
import '../state/listing_filter_controller.dart';

/// The guest's list of stays: cards, infinite scroll, pull to refresh, and a
/// loading, empty and error state that each offer the way forward.
class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  Future<void> _refresh(ListingFilter filter) async {
    // Invalidating keeps the old pages on screen until the new first page
    // arrives, and awaiting the future is what the refresh spinner waits for.
    ref.invalidate(browseListingsProvider(filter));
    try {
      await ref.read(browseListingsProvider(filter).future);
    } on Object {
      // The provider now holds the error and the screen shows it.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filter = ref.watch(listingFilterControllerProvider);
    final listings = ref.watch(browseListingsProvider(filter));
    final title = ref.watch(tenantConfigProvider).value?.name ?? '';
    // Fetches the facets as browsing starts, so the sheet opens with its options
    // ready, and keeps them (an auto-dispose provider) while this screen lives.
    ref.listen(listingFacetsProvider, (previous, next) {});

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: l10n.browseFilters,
            onPressed: () => showFilterSheet(context),
            icon: Badge(
              isLabelVisible: filter.activeCount > 0,
              label: Text(filter.activeCount.toString()),
              child: const Icon(Icons.tune),
            ),
          ),
          IconButton(
            tooltip: l10n.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      // The chips stay above every state, so someone with no results can still
      // remove the filter that caused it.
      body: Column(
        children: [
          ActiveFilterChips(filter: filter),
          Expanded(
            child: listings.when(
              loading: () => LoadingView(semanticsLabel: l10n.loading),
              error: (error, _) => ErrorView(
                message: error is AppFailure
                    ? failureMessage(error, l10n)
                    : l10n.errorGeneric,
                action: ViewAction(
                  label: l10n.retry,
                  onPressed: () =>
                      ref.invalidate(browseListingsProvider(filter)),
                ),
              ),
              data: (paged) {
                if (paged.items.isEmpty) return _empty(l10n, filter);
                return RefreshIndicator(
                  onRefresh: () => _refresh(filter),
                  child: _list(paged, filter),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(AppLocalizations l10n, ListingFilter filter) {
    final filtered = !filter.isUnfiltered;
    return EmptyView(
      icon: Icons.search_off,
      message: filtered ? l10n.browseEmptyFiltered : l10n.browseEmpty,
      action: filtered
          ? ViewAction(
              label: l10n.browseClearFilters,
              onPressed: ref
                  .read(listingFilterControllerProvider.notifier)
                  .clear,
            )
          : null,
    );
  }

  Widget _list(PagedState<Listing> paged, ListingFilter filter) {
    final l10n = context.l10n;
    return PagedListView<Listing>(
      paged: paged,
      onLoadMore: () => unawaited(
        ref.read(browseListingsProvider(filter).notifier).loadMore(),
      ),
      failureText: (failure) => failureMessage(failure, l10n),
      retryLabel: l10n.retry,
      loadingLabel: l10n.loading,
      header: Text(
        l10n.browseResultCount(paged.total ?? paged.items.length),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      itemBuilder: (context, listing) => ListingCard(
        listing: listing,
        onTap: () => context.push(BrowsePaths.listing(listing.id)),
      ),
    );
  }
}
