import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_patch.freezed.dart';
part 'listing_patch.g.dart';

/// The body of `PATCH /host/listings/{id}`: only the fields the host changed.
///
/// A null field means "not changed" and is left out of the JSON
/// (`includeIfNull: false`), which is what makes the request a diff. The types
/// matter because the API takes them literally: the prices are `num` and the
/// counts `int`, so they encode as JSON numbers, never as strings. Only the
/// editable fields exist here; city and address are read-only.
@freezed
abstract class ListingPatch with _$ListingPatch {
  const ListingPatch._();

  // Freezed copies this onto the generated class; the analyzer only sees a
  // factory constructor, so it warns.
  // ignore: invalid_annotation_target
  @JsonSerializable(includeIfNull: false)
  const factory ListingPatch({
    String? title,
    String? description,
    num? pricePerNight,
    num? cleaningFee,
    int? maxGuests,
    int? bedrooms,
    int? beds,
    int? bathrooms,
    String? propertyType,
    List<String>? amenities,
  }) = _ListingPatch;

  factory ListingPatch.fromJson(Map<String, dynamic> json) =>
      _$ListingPatchFromJson(json);

  /// Nothing changed, so there is nothing to send.
  bool get isEmpty => toJson().isEmpty;
}
