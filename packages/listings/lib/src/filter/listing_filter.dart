import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'listing_sort.dart';

part 'listing_filter.freezed.dart';

/// What the guest asked for: the brief's four filters plus a sort. It is a
/// value with equality, which is what lets it be the key of the browse list's
/// provider family: same filter, same list; a new filter, a new list.
@freezed
abstract class ListingFilter with _$ListingFilter {
  const ListingFilter._();

  const factory ListingFilter({
    String? city,

    /// Listings whose `maxGuests` is at least this.
    int? guests,
    num? minPrice,
    num? maxPrice,

    /// Check-in is `start` (inclusive), check-out is `end` (exclusive).
    DateRange? dates,
    @Default(ListingSort.newest) ListingSort sort,
  }) = _ListingFilter;

  /// Number of narrowing filters in use, for the badge on the filter button.
  /// A price range counts once, and the sort is not a filter.
  int get activeCount =>
      (city != null ? 1 : 0) +
      (guests != null ? 1 : 0) +
      (minPrice != null || maxPrice != null ? 1 : 0) +
      (dates != null ? 1 : 0);

  bool get isUnfiltered => activeCount == 0;

  /// The same sort with every narrowing filter removed.
  ListingFilter cleared() => ListingFilter(sort: sort);

  /// Query parameters for `GET /listings`. Anything unset is left out, and the
  /// dates are sent together or not at all (the API answers 400 for only one).
  Map<String, Object> toQueryParameters() => {
    'city': ?city,
    'guests': ?guests,
    'minPrice': ?minPrice,
    'maxPrice': ?maxPrice,
    if (dates case final range?) ...{
      'checkIn': range.start.toIso(),
      'checkOut': range.end.toIso(),
    },
    'orderBy': sort.orderBy,
    'orderDir': sort.orderDir,
  };
}
