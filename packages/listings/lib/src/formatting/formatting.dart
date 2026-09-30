import 'package:intl/intl.dart';

/// A price in the listing's own currency, written the way [locale] writes
/// money. Whole amounts drop the cents (249, not 249.00); prices are whole
/// currency units in this API, but a fractional one still shows correctly.
///
/// The currency is the row's, never the tenant's.
String formatPrice(num amount, String currency, String locale) {
  final isWhole = amount == amount.roundToDouble();
  return NumberFormat.simpleCurrency(
    locale: locale,
    name: currency,
    decimalDigits: isWhole ? 0 : 2,
  ).format(amount);
}

/// A rating to one decimal, in the decimal style of [locale]: 4.8 in English,
/// 4,8 in German.
String formatRating(double rating, String locale) =>
    NumberFormat('0.0', locale).format(rating);
