import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';

/// Locale output uses non-breaking spaces; compare with plain ones.
String plain(String text) => text.replaceAll(RegExp(r'[  ]'), ' ');

void main() {
  group('formatPrice', () {
    test('writes a whole CHF amount without cents, in English', () {
      final text = plain(formatPrice(249, 'CHF', 'en'));

      expect(text, contains('CHF'));
      expect(text, contains('249'));
      expect(text, isNot(contains('.00')));
    });

    test('puts the currency after the amount in German', () {
      expect(plain(formatPrice(249, 'CHF', 'de')), '249 CHF');
      expect(plain(formatPrice(249, 'EUR', 'de')), '249 €');
    });

    test('uses the currency it is given, not a default', () {
      expect(plain(formatPrice(120, 'EUR', 'en')), contains('€'));
      expect(plain(formatPrice(120, 'EUR', 'en')), isNot(contains('CHF')));
    });

    test('keeps the cents of a fractional amount', () {
      expect(plain(formatPrice(99.5, 'EUR', 'de')), '99,50 €');
    });

    test('groups thousands the way the locale does', () {
      expect(plain(formatPrice(1250, 'CHF', 'de')), '1.250 CHF');
    });
  });

  group('formatRating', () {
    test('uses a decimal point in English', () {
      expect(formatRating(4.83, 'en'), '4.8');
    });

    test('uses a decimal comma in German', () {
      expect(formatRating(4.83, 'de'), '4,8');
    });

    test('shows a whole rating with one decimal', () {
      expect(formatRating(5, 'en'), '5.0');
      expect(formatRating(5, 'de'), '5,0');
    });
  });

  group('amenityLabel', () {
    test('translates a known slug in each language', () {
      expect(
        amenityLabel('hot_tub', lookupAppLocalizations(const Locale('en'))),
        'Hot tub',
      );
      expect(
        amenityLabel('hot_tub', lookupAppLocalizations(const Locale('de'))),
        'Whirlpool',
      );
    });

    test('humanises a slug it has no label for', () {
      final en = lookupAppLocalizations(const Locale('en'));

      expect(amenityLabel('heated_towel_rail', en), 'Heated towel rail');
    });

    test('copes with a one-letter or empty slug', () {
      final en = lookupAppLocalizations(const Locale('en'));

      expect(amenityLabel('x', en), 'X');
      expect(amenityLabel('', en), '');
    });
  });

  group('knownAmenitySlugs', () {
    test('has no duplicates', () {
      expect(knownAmenitySlugs.toSet(), hasLength(knownAmenitySlugs.length));
    });

    test('lists only slugs the app really knows: each has its own icon', () {
      // The icon switch mirrors the label switch, so a slug added to the list
      // but not to them shows the generic fallback icon and fails here.
      final generic = amenityIcon('not_a_known_slug');

      for (final slug in knownAmenitySlugs) {
        expect(amenityIcon(slug), isNot(generic), reason: slug);
      }
    });
  });

  group('countryLabel', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final de = lookupAppLocalizations(const Locale('de'));

    test('names every country the catalogue has, in each language', () {
      expect(countryLabel('CH', en), 'Switzerland');
      expect(countryLabel('CH', de), 'Schweiz');
      expect(countryLabel('AT', en), 'Austria');
      expect(countryLabel('AT', de), 'Österreich');
      expect(countryLabel('FR', en), 'France');
      expect(countryLabel('FR', de), 'Frankreich');
      expect(countryLabel('IT', en), 'Italy');
      expect(countryLabel('IT', de), 'Italien');
      expect(countryLabel('MC', en), 'Monaco');
      expect(countryLabel('MC', de), 'Monaco');
    });

    test('a code it has no name for is shown as it arrived', () {
      expect(countryLabel('ZZ', en), 'ZZ');
      expect(countryLabel('ZZ', de), 'ZZ');
      expect(countryLabel('xx', en), 'xx');
    });

    test('is not case sensitive for a known code', () {
      expect(countryLabel('ch', en), 'Switzerland');
    });

    test('an empty code stays empty instead of failing', () {
      expect(countryLabel('', en), '');
    });
  });

  group('amenityIcon', () {
    test('has an icon for a known slug', () {
      expect(amenityIcon('wifi'), Icons.wifi);
    });

    test('falls back to a generic icon for an unknown slug', () {
      expect(amenityIcon('teleporter'), Icons.check_circle_outline);
    });
  });
}
