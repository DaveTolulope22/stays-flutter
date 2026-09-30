// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_facets_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the filter sheet builds itself from: cities, guest maximum and price
/// bounds with their currency. Nothing about them is hardcoded.
///
/// Auto-dispose, but the browse screen listens to it, so it is fetched once when
/// browsing starts (the sheet opens instantly) and freed with the screen. A
/// failure surfaces in the sheet with Retry; it does not retry automatically.

@ProviderFor(listingFacets)
final listingFacetsProvider = ListingFacetsProvider._();

/// What the filter sheet builds itself from: cities, guest maximum and price
/// bounds with their currency. Nothing about them is hardcoded.
///
/// Auto-dispose, but the browse screen listens to it, so it is fetched once when
/// browsing starts (the sheet opens instantly) and freed with the screen. A
/// failure surfaces in the sheet with Retry; it does not retry automatically.

final class ListingFacetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ListingFacets>,
          ListingFacets,
          FutureOr<ListingFacets>
        >
    with $FutureModifier<ListingFacets>, $FutureProvider<ListingFacets> {
  /// What the filter sheet builds itself from: cities, guest maximum and price
  /// bounds with their currency. Nothing about them is hardcoded.
  ///
  /// Auto-dispose, but the browse screen listens to it, so it is fetched once when
  /// browsing starts (the sheet opens instantly) and freed with the screen. A
  /// failure surfaces in the sheet with Retry; it does not retry automatically.
  ListingFacetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: noAutomaticRetry,
        name: r'listingFacetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listingFacetsHash();

  @$internal
  @override
  $FutureProviderElement<ListingFacets> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ListingFacets> create(Ref ref) {
    return listingFacets(ref);
  }
}

String _$listingFacetsHash() => r'6aa9c2b83443814106141a8b806c3b2bcda228d7';
