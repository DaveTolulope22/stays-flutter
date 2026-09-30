import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

/// The words for a sort option.
String sortLabel(ListingSort sort, AppLocalizations l10n) => switch (sort) {
  ListingSort.newest => l10n.filterSortNewest,
  ListingSort.priceLowToHigh => l10n.filterSortPriceLowToHigh,
  ListingSort.priceHighToLow => l10n.filterSortPriceHighToLow,
  ListingSort.ratingHighToLow => l10n.filterSortRating,
};

/// "Mar 1 – Mar 4 · 3 nights". The days are written by the platform's own
/// localisation, so no extra locale data has to be loaded.
String stayLabel(BuildContext context, DateRange range) {
  final material = MaterialLocalizations.of(context);
  return context.l10n.filterDatesRange(
    material.formatShortMonthDay(asDateTime(range.start)),
    material.formatShortMonthDay(asDateTime(range.end)),
    range.nights,
  );
}

/// "CHF 100 – CHF 300", "From CHF 100" or "Up to CHF 300", in [currency].
String priceLabel({
  required num? min,
  required num? max,
  required String currency,
  required BuildContext context,
}) {
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toString();
  String format(num price) => formatPrice(price, currency, locale);
  if (min != null && max != null) {
    return l10n.filterPriceRange(format(min), format(max));
  }
  if (min != null) return l10n.filterPriceFrom(format(min));
  return l10n.filterPriceUpTo(format(max!));
}

/// The framework's date widgets speak `DateTime`; this is where a [LocalDate]
/// becomes one, at midnight of that calendar day.
DateTime asDateTime(LocalDate date) =>
    DateTime(date.year, date.month, date.day);
