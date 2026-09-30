// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_listings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The pages of the signed-in host's own listings.
///
/// Auto-dispose: pages live only while the host's listings screen is open, and
/// the next host to sign in starts from nothing. It does not retry
/// automatically; the screen shows the error with a Retry button.
///
/// The value is `AsyncData(PagedState)`. The first page failing is an
/// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
/// and sets `loadMoreError` instead.

@ProviderFor(HostListings)
final hostListingsProvider = HostListingsProvider._();

/// The pages of the signed-in host's own listings.
///
/// Auto-dispose: pages live only while the host's listings screen is open, and
/// the next host to sign in starts from nothing. It does not retry
/// automatically; the screen shows the error with a Retry button.
///
/// The value is `AsyncData(PagedState)`. The first page failing is an
/// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
/// and sets `loadMoreError` instead.
final class HostListingsProvider
    extends $AsyncNotifierProvider<HostListings, PagedState<Listing>> {
  /// The pages of the signed-in host's own listings.
  ///
  /// Auto-dispose: pages live only while the host's listings screen is open, and
  /// the next host to sign in starts from nothing. It does not retry
  /// automatically; the screen shows the error with a Retry button.
  ///
  /// The value is `AsyncData(PagedState)`. The first page failing is an
  /// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
  /// and sets `loadMoreError` instead.
  HostListingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: noAutomaticRetry,
        name: r'hostListingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostListingsHash();

  @$internal
  @override
  HostListings create() => HostListings();
}

String _$hostListingsHash() => r'0b3efd0fc61c896a56613d871aded24764e69808';

/// The pages of the signed-in host's own listings.
///
/// Auto-dispose: pages live only while the host's listings screen is open, and
/// the next host to sign in starts from nothing. It does not retry
/// automatically; the screen shows the error with a Retry button.
///
/// The value is `AsyncData(PagedState)`. The first page failing is an
/// `AsyncError` holding the `AppFailure`; a later page failing keeps the items
/// and sets `loadMoreError` instead.

abstract class _$HostListings extends $AsyncNotifier<PagedState<Listing>> {
  FutureOr<PagedState<Listing>> build();
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
    return element.handleCreate(ref, build);
  }
}
