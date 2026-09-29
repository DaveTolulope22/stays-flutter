import 'package:flutter/painting.dart';

/// Corner radii.
abstract final class AppRadius {
  static const double s = 4;
  static const double m = 8;
  static const double l = 16;

  static const BorderRadius smallAll = BorderRadius.all(Radius.circular(s));
  static const BorderRadius mediumAll = BorderRadius.all(Radius.circular(m));
  static const BorderRadius largeAll = BorderRadius.all(Radius.circular(l));
}
