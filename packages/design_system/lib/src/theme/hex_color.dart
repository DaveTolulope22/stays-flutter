import 'dart:ui' show Color;

/// The only hex parser in the codebase. Accepts `#rrggbb` and `#rgb`
/// (case-insensitive) and returns null for anything else, so the caller
/// decides the fallback instead of the app crashing on a bad config.
Color? parseHexColor(String? value) {
  if (value == null || !value.startsWith('#')) return null;

  var digits = value.substring(1);
  if (digits.length == 3) {
    digits = digits.split('').map((digit) => '$digit$digit').join();
  }
  if (digits.length != 6) return null;

  final rgb = int.tryParse(digits, radix: 16);
  // tryParse accepts a sign ("-12345"), which is not a colour.
  if (rgb == null || digits.startsWith('-') || digits.startsWith('+')) {
    return null;
  }
  return Color(0xFF000000 | rgb);
}
