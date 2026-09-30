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

  group('amenityIcon', () {
    test('has an icon for a known slug', () {
      expect(amenityIcon('wifi'), Icons.wifi);
    });

    test('falls back to a generic icon for an unknown slug', () {
      expect(amenityIcon('teleporter'), Icons.check_circle_outline);
    });
  });
}
