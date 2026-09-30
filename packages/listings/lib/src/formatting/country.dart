import 'package:l10n/l10n.dart';

/// The name of a country from its ISO 3166-1 code, in the user's language.
///
/// The names cover the countries the catalogue has today. The set is open, like
/// amenities: a code we have no name for is shown as it arrived instead of
/// being hidden or failing.
String countryLabel(String code, AppLocalizations l10n) =>
    switch (code.toUpperCase()) {
      'AT' => l10n.countryAT,
      'CH' => l10n.countryCH,
      'FR' => l10n.countryFR,
      'IT' => l10n.countryIT,
      'MC' => l10n.countryMC,
      _ => code,
    };
