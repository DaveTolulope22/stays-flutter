import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

import '../state/browse_listings.dart';
import '../state/listing_filter_controller.dart';

/// The guest's list of stays: cards, infinite scroll, pull to refresh, and a
/// loading, empty and error state that each offer the way forward.
class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_loadMoreIfNearEnd);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Asks for the next page when the end of the list is close. It runs on every
  /// scroll AND after every rebuild, so a first page that is too short to
  /// scroll at all still fills the screen instead of waiting for a scroll that
  /// can never happen. It stops by itself: at the end of the list, after a
  /// failure (the footer offers Retry), or once the screen is full.
  ///
  /// Calling it too often is harmless: `loadMore` ignores a call while a page
  /// is already on its way.
  void _loadMoreIfNearEnd() {
    if (!mounted || !_scroll.hasClients) return;
    final position = _scroll.position;
    if (!position.hasContentDimensions) return;
    if (position.extentAfter > AppSizes.listPrefetchExtent) return;

    final filter = ref.read(listingFilterControllerProvider);
    final paged = ref.read(browseListingsProvider(filter)).value;
    if (paged == null || !paged.canLoadMore || paged.loadMoreError != null) {
      return;
    }
    unawaited(ref.read(browseListingsProvider(filter).notifier).loadMore());
  }

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

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // Enabled by the filter sheet (next step).
          IconButton(
            tooltip: l10n.browseFilters,
            onPressed: null,
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
      body: listings.when(
        loading: () => LoadingView(semanticsLabel: l10n.loading),
        error: (error, _) => ErrorView(
          message: error is AppFailure
              ? failureMessage(error, l10n)
              : l10n.errorGeneric,
          action: ViewAction(
            label: l10n.retry,
            onPressed: () => ref.invalidate(browseListingsProvider(filter)),
          ),
        ),
        data: (paged) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _loadMoreIfNearEnd(),
          );
          if (paged.items.isEmpty) return _empty(l10n, filter);
          return RefreshIndicator(
            onRefresh: () => _refresh(filter),
            child: _list(paged, filter),
          );
        },
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
    // Header, then one card per listing, then the footer.
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        child: ListView.builder(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.m),
          itemCount: paged.items.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.m),
                child: Text(
                  l10n.browseResultCount(paged.total ?? paged.items.length),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            }
            if (index == paged.items.length + 1) {
              return _Footer(
                paged: paged,
                onRetry: () => unawaited(
                  ref.read(browseListingsProvider(filter).notifier).loadMore(),
                ),
              );
            }
            final listing = paged.items[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: ListingCard(
                listing: listing,
                // The detail screen arrives in the next step.
                onTap: () {},
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The end of the list: a spinner while a page loads, a message with Retry if
/// it failed, nothing otherwise.
class _Footer extends StatelessWidget {
  const _Footer({required this.paged, required this.onRetry});

  final PagedState<Listing> paged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = paged.loadMoreError;

    if (paged.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: LoadingView(semanticsLabel: l10n.loading),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        child: Column(
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                failureMessage(error, l10n),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
