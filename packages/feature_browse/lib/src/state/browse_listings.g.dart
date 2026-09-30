// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browse_listings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The pages of listings for ONE filter.
///
/// A family, keyed by the filter: each distinct filter gets its own notifier
/// with its own pages, so a filter change starts a fresh list and a slow
/// response for the old filter can never end up in the new one.
///
/// Auto-dispose: pages live only while a screen watches this filter. It does
/// not retry automatically; the screen shows the error with a Retry button.
///
/// The value is `AsyncData(PagedState)`. The first page failing is an
/// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
/// and sets `loadMoreError` instead.

@ProviderFor(BrowseListings)
final browseListingsProvider = BrowseListingsFamily._();

/// The pages of listings for ONE filter.
///
/// A family, keyed by the filter: each distinct filter gets its own notifier
/// with its own pages, so a filter change starts a fresh list and a slow
/// response for the old filter can never end up in the new one.
///
/// Auto-dispose: pages live only while a screen watches this filter. It does
/// not retry automatically; the screen shows the error with a Retry button.
///
/// The value is `AsyncData(PagedState)`. The first page failing is an
/// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
/// and sets `loadMoreError` instead.
final class BrowseListingsProvider
    extends $AsyncNotifierProvider<BrowseListings, PagedState<Listing>> {
  /// The pages of listings for ONE filter.
  ///
  /// A family, keyed by the filter: each distinct filter gets its own notifier
  /// with its own pages, so a filter change starts a fresh list and a slow
  /// response for the old filter can never end up in the new one.
  ///
  /// Auto-dispose: pages live only while a screen watches this filter. It does
  /// not retry automatically; the screen shows the error with a Retry button.
  ///
  /// The value is `AsyncData(PagedState)`. The first page failing is an
  /// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
  /// and sets `loadMoreError` instead.
  BrowseListingsProvider._({
    required BrowseListingsFamily super.from,
    required ListingFilter super.argument,
  }) : super(
         retry: noAutomaticRetry,
         name: r'browseListingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$browseListingsHash();

  @override
  String toString() {
    return r'browseListingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BrowseListings create() => BrowseListings();

  @override
  bool operator ==(Object other) {
    return other is BrowseListingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$browseListingsHash() => r'67c7dba8ff133f9add9d9eb9831ae32f27ffa6f4';

/// The pages of listings for ONE filter.
///
/// A family, keyed by the filter: each distinct filter gets its own notifier
/// with its own pages, so a filter change starts a fresh list and a slow
/// response for the old filter can never end up in the new one.
///
/// Auto-dispose: pages live only while a screen watches this filter. It does
/// not retry automatically; the screen shows the error with a Retry button.
///
/// The value is `AsyncData(PagedState)`. The first page failing is an
/// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
/// and sets `loadMoreError` instead.

final class BrowseListingsFamily extends $Family
    with
        $ClassFamilyOverride<
          BrowseListings,
          AsyncValue<PagedState<Listing>>,
          PagedState<Listing>,
          FutureOr<PagedState<Listing>>,
          ListingFilter
        > {
  BrowseListingsFamily._()
    : super(
        retry: noAutomaticRetry,
        name: r'browseListingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The pages of listings for ONE filter.
  ///
  /// A family, keyed by the filter: each distinct filter gets its own notifier
  /// with its own pages, so a filter change starts a fresh list and a slow
  /// response for the old filter can never end up in the new one.
  ///
  /// Auto-dispose: pages live only while a screen watches this filter. It does
  /// not retry automatically; the screen shows the error with a Retry button.
  ///
  /// The value is `AsyncData(PagedState)`. The first page failing is an
  /// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
  /// and sets `loadMoreError` instead.

  BrowseListingsProvider call(ListingFilter filter) =>
      BrowseListingsProvider._(argument: filter, from: this);

  @override
  String toString() => r'browseListingsProvider';
}

/// The pages of listings for ONE filter.
///
/// A family, keyed by the filter: each distinct filter gets its own notifier
/// with its own pages, so a filter change starts a fresh list and a slow
/// response for the old filter can never end up in the new one.
///
/// Auto-dispose: pages live only while a screen watches this filter. It does
/// not retry automatically; the screen shows the error with a Retry button.
///
/// The value is `AsyncData(PagedState)`. The first page failing is an
/// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
/// and sets `loadMoreError` instead.

abstract class _$BrowseListings extends $AsyncNotifier<PagedState<Listing>> {
  late final _$args = ref.$arg as ListingFilter;
  ListingFilter get filter => _$args;

  FutureOr<PagedState<Listing>> build(ListingFilter filter);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PagedState<Listing>>, PagedState<Listing>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PagedState<Listing>>, PagedState<Listing>>,
              AsyncValue<PagedState<Listing>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
