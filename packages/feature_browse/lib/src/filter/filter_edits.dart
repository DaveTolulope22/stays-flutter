import 'package:core/core.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:listings/listings.dart';

import 'price_scale.dart';

/// How the filter sheet's controls change a [ListingFilter]. They are plain
/// functions of values, so the rules that decide what is sent to the API are
/// tested without a widget.
extension ListingFilterEdits on ListingFilter {
  /// One guest is every listing, so it is "no filter", not `guests=1`.
  ListingFilter withGuests(int count) =>
      copyWith(guests: count <= 1 ? null : count);

  /// Moves the price slider to [startIndex] and [endIndex] of [scale]. An end
  /// resting on its bound sends nothing, so moving only one end sends only that
  /// bound, and a slider left alone sends no price at all.
  ListingFilter withPriceIndices(
    PriceScale scale,
    int startIndex,
    int endIndex,
  ) => copyWith(
    minPrice: startIndex <= 0 ? null : scale.valueAt(startIndex),
    maxPrice: endIndex >= scale.divisions ? null : scale.valueAt(endIndex),
  );
}

/// A stay from the date range picker. The day picked last is the check-out day,
/// so it is the exclusive end of the range: it is sent as `checkOut` and is not
/// a night that gets booked. Only the calendar day is kept, never the time or
/// the zone.
///
/// Null for zero nights (the same day twice), which is not a stay.
DateRange? dateRangeFromPicker(DateTimeRange picked) {
  final start = LocalDate.fromDateTime(picked.start);
  final end = LocalDate.fromDateTime(picked.end);
  return end > start ? DateRange(start, end) : null;
}
