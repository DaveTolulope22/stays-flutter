/// The host module's locations.
abstract final class HostPaths {
  static const base = '/host';

  /// The routes below, relative to [base]: a listing's screens are nested under
  /// the list, so each opens on top of it and the list keeps its pages and scroll
  /// position underneath.
  static const editRoute = 'listings/:id/edit';
  static const calendarRoute = 'listings/:id/calendar';
  static const bookingsRoute = 'listings/:id/bookings';

  static String edit(String id) => _listing(id, 'edit');
  static String calendar(String id) => _listing(id, 'calendar');
  static String bookings(String id) => _listing(id, 'bookings');

  static String _listing(String id, String screen) =>
      '$base/listings/${Uri.encodeComponent(id)}/$screen';
}
