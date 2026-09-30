import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';
import 'status_views.dart';

/// A list of [PagedState] items that asks for the next page by itself: cards
/// with a spacing below each, an optional [header] above the first one, and a
/// footer that shows a spinner while a page loads, or the failure with Retry.
///
/// It knows nothing about what the rows are or where they come from: the caller
/// builds each row, and [onLoadMore] is whatever fetches the next page. It holds
/// no copy either; every word it shows is passed in.
///
/// It does not wrap itself in a `RefreshIndicator`: the caller does, because
/// only the caller knows what a refresh reloads.
class PagedListView<T> extends StatefulWidget {
  const PagedListView({
    required this.paged,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.failureText,
    required this.retryLabel,
    required this.loadingLabel,
    this.header,
    super.key,
  });

  final PagedState<T> paged;
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Fetches the next page. It may be called any number of times: the notifier
  /// behind it ignores a call while a page is already on its way.
  final VoidCallback onLoadMore;

  /// Our own words for a failed page, never the server's.
  final String Function(AppFailure failure) failureText;
  final String retryLabel;
  final String loadingLabel;
  final Widget? header;

  @override
  State<PagedListView<T>> createState() => _PagedListViewState<T>();
}

class _PagedListViewState<T> extends State<PagedListView<T>> {
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
  /// scroll AND after every build, so a first page that is too short to scroll
  /// at all still fills the screen instead of waiting for a scroll that can
  /// never happen. It stops by itself: at the end of the list, after a failure
  /// (the footer offers Retry), or once the screen is full.
  void _loadMoreIfNearEnd() {
    if (!mounted || !_scroll.hasClients) return;
    final position = _scroll.position;
    if (!position.hasContentDimensions) return;
    if (position.extentAfter > AppSizes.listPrefetchExtent) return;

    final paged = widget.paged;
    if (!paged.canLoadMore || paged.loadMoreError != null) return;
    widget.onLoadMore();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMoreIfNearEnd());

    final paged = widget.paged;
    final header = widget.header;
    final headerCount = header == null ? 0 : 1;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        child: ListView.builder(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.m),
          // The header, then one row per item, then the footer.
          itemCount: headerCount + paged.items.length + 1,
          itemBuilder: (context, index) {
            if (header != null && index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.m),
                child: header,
              );
            }
            if (index == headerCount + paged.items.length) {
              return _Footer(
                paged: paged,
                failureText: widget.failureText,
                retryLabel: widget.retryLabel,
                loadingLabel: widget.loadingLabel,
                onRetry: widget.onLoadMore,
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: widget.itemBuilder(
                context,
                paged.items[index - headerCount],
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
  const _Footer({
    required this.paged,
    required this.failureText,
    required this.retryLabel,
    required this.loadingLabel,
    required this.onRetry,
  });

  final PagedState<dynamic> paged;
  final String Function(AppFailure failure) failureText;
  final String retryLabel;
  final String loadingLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final error = paged.loadMoreError;

    if (paged.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: LoadingView(semanticsLabel: loadingLabel),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        child: Column(
          children: [
            Semantics(
              liveRegion: true,
              child: Text(failureText(error), textAlign: TextAlign.center),
            ),
            const SizedBox(height: AppSpacing.s),
            TextButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
