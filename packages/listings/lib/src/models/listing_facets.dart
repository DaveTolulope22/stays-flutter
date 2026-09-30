import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_facets.freezed.dart';
part 'listing_facets.g.dart';

/// `GET /listings/facets`: what the filter sheet builds itself from. Bounds are
/// read from here, never hardcoded, because the two tenants price in different
/// currencies.
@freezed
abstract class ListingFacets with _$ListingFacets {
  const factory ListingFacets({
    required List<String> cities,
    required List<String> propertyTypes,
    required List<String> amenities,
    required num priceMin,
    required num priceMax,
    required int maxGuests,

    /// The currency [priceMin] and [priceMax] are in.
    required String currency,
  }) = _ListingFacets;

  factory ListingFacets.fromJson(Map<String, dynamic> json) =>
      _$ListingFacetsFromJson(json);
}
