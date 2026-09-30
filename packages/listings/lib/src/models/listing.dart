import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing.freezed.dart';
part 'listing.g.dart';

/// A place to stay. The list and the detail endpoint return the same object, so
/// one model serves the card and the detail screen.
///
/// Every number is read as `num` first: JSON has one number type, so a rating
/// of exactly 5.00 arrives as the int `5` and a plain `as double` would throw
/// on that row only. json_serializable generates `(x as num).toDouble()` for
/// the `double` fields, and a test decodes `"rating": 5` to keep it that way.
@freezed
abstract class Listing with _$Listing {
  const Listing._();

  const factory Listing({
    required String id,
    required String tenantId,
    required String hostId,
    required String title,
    required String description,
    required String city,
    required String country,
    required String address,
    required double latitude,
    required double longitude,
    required String propertyType,
    required int maxGuests,

    /// 0 for a studio.
    required int bedrooms,
    required int beds,
    required int bathrooms,

    /// Whole currency units: 249 means 249.00, not 249 cents.
    required num pricePerNight,

    /// Charged once per stay, not per night. May be 0.
    required num cleaningFee,

    /// From the row, never assumed from the tenant.
    required String currency,

    /// An open set of slugs. Kept as strings so an unknown one cannot fail the
    /// decode; the UI degrades it to a humanised label.
    required List<String> amenities,

    /// 0 means "no reviews yet", not a zero score.
    required double rating,
    required int reviewsCount,

    /// At least one URL; the first is the cover.
    required List<String> images,
    required DateTime createdAt,
  }) = _Listing;

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);

  bool get hasReviews => reviewsCount > 0 && rating > 0;

  bool get isStudio => bedrooms == 0;

  /// Null only if the API ever sent an empty list, which the contract rules out;
  /// the card shows its placeholder then instead of crashing.
  String? get coverImage => images.isEmpty ? null : images.first;
}
