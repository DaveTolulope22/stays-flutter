/// Fixed sizes for icons, tap targets and images.
abstract final class AppSizes {
  static const double iconS = 16;
  static const double iconM = 24;
  static const double iconL = 48;

  /// Edge of the rounded square that holds the app mark on the auth screens.
  static const double brandMark = 80;

  /// Smallest comfortable tap target (Material and Android guidance).
  static const double minTapTarget = 48;

  /// Width of a centred content column on wide screens.
  static const double maxContentWidth = 640;

  /// How far from the end of a list, in logical pixels, the next page is
  /// requested: about a card and a half, so it arrives before the user gets
  /// there.
  static const double listPrefetchExtent = 600;

  /// Height of one row of a month calendar, and the size of a legend sample.
  static const double calendarCell = 48;

  /// Line width of the outline that marks a highlighted calendar day.
  static const double calendarOutline = 2;

  /// Diameter of one dot in a photo pager's page indicator.
  static const double pagerDot = 8;

  /// Width divided by height of a listing's cover image (4:3).
  static const double listingImageAspectRatio = 4 / 3;
}
