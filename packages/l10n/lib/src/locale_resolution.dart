import 'dart:ui' show Locale;

import 'generated/app_localizations.dart';

/// The language the app is written in. It is the last resort, and it is a
/// property of the app's own copy, not of any tenant.
const _baselineLanguage = 'en';

String _languageOf(String tag) => tag.split(RegExp('[-_]')).first.toLowerCase();

/// Locales a tenant is offered in AND the app has copy for, in the tenant's
/// own order (so "first" means the tenant's first choice). The tenant may list
/// more languages than we ship; those are ignored.
List<Locale> supportedLocalesFor(Iterable<String> configLocales) {
  final shipped = AppLocalizations.supportedLocales
      .map((locale) => locale.languageCode)
      .toSet();
  final supported = configLocales
      .map(_languageOf)
      .toSet()
      .where(shipped.contains)
      .map(Locale.new)
      .toList();
  // A config that offers nothing we support still needs a working app.
  return supported.isEmpty ? [const Locale(_baselineLanguage)] : supported;
}

/// Picks the locale to show, in this order:
/// 1. the first device language (in the user's preference order) that the
///    tenant offers and the app supports,
/// 2. the tenant's [defaultLocale], if that is supported,
/// 3. the tenant's first supported locale.
Locale resolveLocale({
  required List<Locale>? deviceLocales,
  required Iterable<String> configLocales,
  required String defaultLocale,
}) {
  final supported = supportedLocalesFor(configLocales);
  Locale? match(String language) {
    for (final locale in supported) {
      if (locale.languageCode == language) return locale;
    }
    return null;
  }

  for (final device in deviceLocales ?? const <Locale>[]) {
    final found = match(device.languageCode.toLowerCase());
    if (found != null) return found;
  }
  return match(_languageOf(defaultLocale)) ?? supported.first;
}
