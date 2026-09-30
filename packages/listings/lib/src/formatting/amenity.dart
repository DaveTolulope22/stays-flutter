import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

/// The slugs [amenityLabel] has a translation for, in the order a form offers
/// them. The set the API can send is open, so this is what we can LABEL, not
/// what can exist; keep it next to the switch below.
const knownAmenitySlugs = [
  'wifi',
  'kitchen',
  'parking',
  'washer',
  'dryer',
  'air_conditioning',
  'heating',
  'tv',
  'pool',
  'hot_tub',
  'fireplace',
  'balcony',
  'sea_view',
  'mountain_view',
  'ski_storage',
  'pets_allowed',
  'workspace',
  'elevator',
  'bbq',
  'sauna',
];

/// The label for an amenity slug. The set of slugs is open, so one without a
/// translation degrades to a readable form of the slug instead of failing.
String amenityLabel(String slug, AppLocalizations l10n) => switch (slug) {
  'wifi' => l10n.amenityWifi,
  'kitchen' => l10n.amenityKitchen,
  'parking' => l10n.amenityParking,
  'washer' => l10n.amenityWasher,
  'dryer' => l10n.amenityDryer,
  'air_conditioning' => l10n.amenityAirConditioning,
  'heating' => l10n.amenityHeating,
  'tv' => l10n.amenityTv,
  'pool' => l10n.amenityPool,
  'hot_tub' => l10n.amenityHotTub,
  'fireplace' => l10n.amenityFireplace,
  'balcony' => l10n.amenityBalcony,
  'sea_view' => l10n.amenitySeaView,
  'mountain_view' => l10n.amenityMountainView,
  'ski_storage' => l10n.amenitySkiStorage,
  'pets_allowed' => l10n.amenityPetsAllowed,
  'workspace' => l10n.amenityWorkspace,
  'elevator' => l10n.amenityElevator,
  'bbq' => l10n.amenityBbq,
  'sauna' => l10n.amenitySauna,
  _ => humanizeSlug(slug),
};

/// The icon for an amenity slug, or a generic one for a slug we do not know.
IconData amenityIcon(String slug) => switch (slug) {
  'wifi' => Icons.wifi,
  'kitchen' => Icons.kitchen,
  'parking' => Icons.local_parking,
  'washer' => Icons.local_laundry_service,
  'dryer' => Icons.dry,
  'air_conditioning' => Icons.ac_unit,
  'heating' => Icons.thermostat,
  'tv' => Icons.tv,
  'pool' => Icons.pool,
  'hot_tub' => Icons.hot_tub,
  'fireplace' => Icons.fireplace,
  'balcony' => Icons.balcony,
  'sea_view' => Icons.water,
  'mountain_view' => Icons.landscape,
  'ski_storage' => Icons.downhill_skiing,
  'pets_allowed' => Icons.pets,
  'workspace' => Icons.work_outline,
  'elevator' => Icons.elevator,
  'bbq' => Icons.outdoor_grill,
  'sauna' => Icons.spa,
  _ => Icons.check_circle_outline,
};

/// `hot_tub` becomes "Hot tub". Only used as the fallback for a slug that has
/// no translation, so it is derived from data and is not app copy.
String humanizeSlug(String slug) {
  final words = slug.replaceAll(RegExp(r'[_\-\s]+'), ' ').trim();
  if (words.isEmpty) return slug;
  return words[0].toUpperCase() + words.substring(1).toLowerCase();
}
