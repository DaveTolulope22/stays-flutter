/// The browse module's locations.
abstract final class BrowsePaths {
  static const base = '/browse';

  /// The listing route, relative to [base] (it is nested under the list).
  static const listingRoute = 'listing/:id';

  /// The full location of one listing's screen.
  static String listing(String id) =>
      '$base/listing/${Uri.encodeComponent(id)}';
}
