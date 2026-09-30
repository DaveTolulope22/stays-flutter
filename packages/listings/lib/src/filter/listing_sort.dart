/// How the list is ordered, mapped to the API's `orderBy` and `orderDir`.
enum ListingSort {
  newest('createdAt', 'desc'),
  priceLowToHigh('pricePerNight', 'asc'),
  priceHighToLow('pricePerNight', 'desc'),
  ratingHighToLow('rating', 'desc');

  const ListingSort(this.orderBy, this.orderDir);

  final String orderBy;
  final String orderDir;

  /// Sorting by something the user cannot see is a bug, so the rating option
  /// exists only while reviews are visible.
  bool get needsReviews => this == ratingHighToLow;
}
