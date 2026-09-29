import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

Locale _l(String tag) => Locale(tag);

void main() {
  group('resolveLocale', () {
    // deviceLocales, configLocales, defaultLocale -> expected language.
    final table =
        <
          String,
          ({
            List<String> device,
            List<String> offered,
            String fallback,
            String expected,
          })
        >{
          'device de, tenant offers en+de': (
            device: ['de'],
            offered: ['en', 'de'],
            fallback: 'en',
            expected: 'de',
          ),
          'device en, default de: device wins': (
            device: ['en'],
            offered: ['en', 'de'],
            fallback: 'de',
            expected: 'en',
          ),
          'device fr, default en: default': (
            device: ['fr'],
            offered: ['en', 'de'],
            fallback: 'en',
            expected: 'en',
          ),
          'device fr, default de: default': (
            device: ['fr'],
            offered: ['en', 'de'],
            fallback: 'de',
            expected: 'de',
          ),
          'device fr then de: second preference': (
            device: ['fr', 'de'],
            offered: ['en', 'de'],
            fallback: 'en',
            expected: 'de',
          ),
          'device de but tenant offers only en': (
            device: ['de'],
            offered: ['en'],
            fallback: 'en',
            expected: 'en',
          ),
          'tenant offers a language the app lacks': (
            device: ['fr'],
            offered: ['fr', 'de'],
            fallback: 'fr',
            expected: 'de',
          ),
          'default not offered: first supported': (
            device: ['fr'],
            offered: ['en', 'de'],
            fallback: 'it',
            expected: 'en',
          ),
          'tenant offers nothing we support: baseline': (
            device: ['de'],
            offered: ['fr'],
            fallback: 'fr',
            expected: 'en',
          ),
          'no device locales': (
            device: [],
            offered: ['en', 'de'],
            fallback: 'de',
            expected: 'de',
          ),
          'region tags in config and default': (
            device: ['fr'],
            offered: ['en_US', 'de-CH'],
            fallback: 'de-CH',
            expected: 'de',
          ),
          'upper case config': (
            device: ['de'],
            offered: ['EN', 'DE'],
            fallback: 'EN',
            expected: 'de',
          ),
        };

    table.forEach((name, row) {
      test(name, () {
        final locale = resolveLocale(
          deviceLocales: row.device.map(_l).toList(),
          configLocales: row.offered,
          defaultLocale: row.fallback,
        );

        expect(locale.languageCode, row.expected);
      });
    });

    test('a device region does not matter: de_CH resolves to de', () {
      final locale = resolveLocale(
        deviceLocales: [const Locale('de', 'CH')],
        configLocales: ['en', 'de'],
        defaultLocale: 'en',
      );

      expect(locale.languageCode, 'de');
    });

    test('null device locales use the tenant default', () {
      final locale = resolveLocale(
        deviceLocales: null,
        configLocales: ['en', 'de'],
        defaultLocale: 'de',
      );

      expect(locale.languageCode, 'de');
    });
  });

  group('supportedLocalesFor', () {
    test('is the intersection of the tenant offer and app copy', () {
      expect(
        supportedLocalesFor(['en', 'de', 'fr']).map((l) => l.languageCode),
        unorderedEquals(['en', 'de']),
      );
    });

    test('keeps the tenant order and drops duplicates', () {
      expect(
        supportedLocalesFor(['de', 'en_US', 'en']).map((l) => l.languageCode),
        ['de', 'en'],
      );
    });

    test('never returns an empty list', () {
      expect(supportedLocalesFor([]).map((l) => l.languageCode), ['en']);
      expect(supportedLocalesFor(['fr']).map((l) => l.languageCode), ['en']);
    });
  });
}
