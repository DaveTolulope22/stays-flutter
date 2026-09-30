import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:listings/listings.dart';

import '../models/listing_patch.dart';

/// What the edit form holds once every field is valid: real values, not the
/// text in the boxes. The form turns text into this (or shows an error), so
/// [buildListingPatch] never has to guess what "12,5" or "" meant.
@immutable
class ListingDraft {
  const ListingDraft({
    required this.title,
    required this.description,
    required this.pricePerNight,
    required this.cleaningFee,
    required this.maxGuests,
    required this.bedrooms,
    required this.beds,
    required this.bathrooms,
    required this.propertyType,
    required this.amenities,
  });

  final String title;
  final String description;
  final num pricePerNight;
  final num cleaningFee;
  final int maxGuests;
  final int bedrooms;
  final int beds;
  final int bathrooms;
  final String propertyType;

  /// In the order the form shows them: the listing's own first, then what the
  /// host added.
  final List<String> amenities;
}

/// The patch that turns [original] into [draft]: only the fields that differ.
///
/// - Text is trimmed before it is compared and before it is sent, as the API
///   trims it on its side anyway. A change of spaces only is no change.
/// - Numbers stay numbers. They are compared as numbers (249 and 249.0 are the
///   same price) and sent as numbers, because the API refuses `"250"`.
/// - Amenities are compared as a set. Their order does not matter, and a slug
///   this app has no label for stays in the list because the draft started from
///   the listing's own.
///
/// A draft that changes nothing gives an empty patch, and the caller sends no
/// request at all.
ListingPatch buildListingPatch(Listing original, ListingDraft draft) {
  final title = draft.title.trim();
  final description = draft.description.trim();
  return ListingPatch(
    title: title == original.title.trim() ? null : title,
    description: description == original.description.trim()
        ? null
        : description,
    pricePerNight: draft.pricePerNight == original.pricePerNight
        ? null
        : draft.pricePerNight,
    cleaningFee: draft.cleaningFee == original.cleaningFee
        ? null
        : draft.cleaningFee,
    maxGuests: draft.maxGuests == original.maxGuests ? null : draft.maxGuests,
    bedrooms: draft.bedrooms == original.bedrooms ? null : draft.bedrooms,
    beds: draft.beds == original.beds ? null : draft.beds,
    bathrooms: draft.bathrooms == original.bathrooms ? null : draft.bathrooms,
    propertyType: draft.propertyType == original.propertyType
        ? null
        : draft.propertyType,
    amenities: setEquals(draft.amenities.toSet(), original.amenities.toSet())
        ? null
        : draft.amenities,
  );
}

final _amountPattern = RegExp(r'^\d+([.,]\d+)?$');
final _countPattern = RegExp(r'^\d+$');

/// An amount of money typed by a person: digits with an optional decimal part,
/// written with a point or a comma. Null for anything else (empty, a minus sign,
/// letters, `1e3`), so the form can say so instead of sending something odd.
num? parseAmount(String text) {
  final trimmed = text.trim();
  if (!_amountPattern.hasMatch(trimmed)) return null;
  return num.tryParse(trimmed.replaceAll(',', '.'));
}

/// A whole number typed by a person: digits only. Null for anything else.
int? parseCount(String text) {
  final trimmed = text.trim();
  if (!_countPattern.hasMatch(trimmed)) return null;
  return int.tryParse(trimmed);
}

/// [value] as it should appear in a text box for [locale]: no trailing `.0`, no
/// thousands separator, and the locale's decimal separator, so a German host sees
/// `40,5`. [parseAmount] reads it back to the same number.
String amountToInput(num value, String locale) {
  final text = value == value.roundToDouble()
      ? value.round().toString()
      : value.toString();
  return text.replaceAll(
    '.',
    NumberFormat.decimalPattern(locale).symbols.DECIMAL_SEP,
  );
}
