import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

/// The property types the API accepts (the `propertyType` enum of its listing
/// schema), in the order the form offers them. It is the API's closed set, not
/// tenant data, so it is the same on every tenant.
const propertyTypes = [
  'apartment',
  'chalet',
  'villa',
  'studio',
  'loft',
  'cabin',
  'townhouse',
];

/// The label for a property type slug. A slug outside [propertyTypes] (the API
/// grew a new one) degrades to a readable form instead of failing.
String propertyTypeLabel(String slug, AppLocalizations l10n) => switch (slug) {
  'apartment' => l10n.propertyTypeApartment,
  'chalet' => l10n.propertyTypeChalet,
  'villa' => l10n.propertyTypeVilla,
  'studio' => l10n.propertyTypeStudio,
  'loft' => l10n.propertyTypeLoft,
  'cabin' => l10n.propertyTypeCabin,
  'townhouse' => l10n.propertyTypeTownhouse,
  _ => humanizeSlug(slug),
};
