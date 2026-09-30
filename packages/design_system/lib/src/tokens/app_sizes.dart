/// Fixed sizes for icons, tap targets and images.
abstract final class AppSizes {
  static const double iconS = 16;
  static const double iconM = 24;
  static const double iconL = 48;

  /// Smallest comfortable tap target (Material and Android guidance).
  static const double minTapTarget = 48;

  /// Width of a centred content column on wide screens.
  static const double maxContentWidth = 640;

  /// Width divided by height of a listing's cover image (4:3).
  static const double listingImageAspectRatio = 4 / 3;
}
