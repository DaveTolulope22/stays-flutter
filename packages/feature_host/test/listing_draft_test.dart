import 'package:feature_host/src/edit/listing_draft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listings/listings.dart';

import 'support/host_harness.dart';

/// The listing the diff tests start from: price 249, cleaning fee 40.5, wifi.
Listing original() => listingOf('l1');

/// A draft that says exactly what [original] says, so a test changes one thing.
ListingDraft unchangedDraft([Listing? from]) {
  final l = from ?? original();
  return ListingDraft(
    title: l.title,
    description: l.description,
    pricePerNight: l.pricePerNight,
    cleaningFee: l.cleaningFee,
    maxGuests: l.maxGuests,
    bedrooms: l.bedrooms,
    beds: l.beds,
    bathrooms: l.bathrooms,
    propertyType: l.propertyType,
    amenities: l.amenities,
  );
}

ListingDraft draftWith({
  String? title,
  String? description,
  num? pricePerNight,
  num? cleaningFee,
  int? maxGuests,
  int? bedrooms,
  String? propertyType,
  List<String>? amenities,
}) {
  final base = unchangedDraft();
  return ListingDraft(
    title: title ?? base.title,
    description: description ?? base.description,
    pricePerNight: pricePerNight ?? base.pricePerNight,
    cleaningFee: cleaningFee ?? base.cleaningFee,
    maxGuests: maxGuests ?? base.maxGuests,
    bedrooms: bedrooms ?? base.bedrooms,
    beds: base.beds,
    bathrooms: base.bathrooms,
    propertyType: propertyType ?? base.propertyType,
    amenities: amenities ?? base.amenities,
  );
}

void main() {
  group('buildListingPatch', () {
    test('a form nobody changed gives an empty patch', () {
      final patch = buildListingPatch(original(), unchangedDraft());

      expect(patch.isEmpty, isTrue);
      expect(patch.toJson(), isEmpty);
    });

    test('only the changed fields are in the patch', () {
      final patch = buildListingPatch(
        original(),
        draftWith(title: 'New title', bedrooms: 3),
      );

      expect(patch.toJson(), {'title': 'New title', 'bedrooms': 3});
    });

    test('a number stays a number, not a string', () {
      final patch = buildListingPatch(
        original(),
        draftWith(pricePerNight: 250, cleaningFee: 45.5),
      );

      final json = patch.toJson();
      expect(json['pricePerNight'], isA<num>());
      expect(json['pricePerNight'], 250);
      expect(json['cleaningFee'], 45.5);
    });

    test('249 and 249.0 are the same price: no change', () {
      final patch = buildListingPatch(
        original(),
        draftWith(pricePerNight: 249.0),
      );

      expect(patch.isEmpty, isTrue);
    });

    test('text is trimmed before it is sent', () {
      final patch = buildListingPatch(
        original(),
        draftWith(title: '  Cosy chalet \n', description: ' Quiet and warm.  '),
      );

      expect(patch.toJson(), {
        'title': 'Cosy chalet',
        'description': 'Quiet and warm.',
      });
    });

    test('a change of spaces only is no change', () {
      final patch = buildListingPatch(
        original(),
        draftWith(title: '  Chalet l1  '),
      );

      expect(patch.isEmpty, isTrue);
    });

    test('a changed property type is sent', () {
      final patch = buildListingPatch(
        original(),
        draftWith(propertyType: 'villa'),
      );

      expect(patch.toJson(), {'propertyType': 'villa'});
    });

    group('amenities', () {
      Listing withAmenities(List<String> slugs) =>
          Listing.fromJson({...listingRow('l1'), 'amenities': slugs});

      test('the same set in another order is no change', () {
        final listing = withAmenities(['wifi', 'sauna', 'pool']);

        final patch = buildListingPatch(
          listing,
          unchangedDraft(listing).copyWithAmenities(['pool', 'wifi', 'sauna']),
        );

        expect(patch.isEmpty, isTrue);
      });

      test('an added amenity sends the whole list', () {
        final listing = withAmenities(['wifi']);

        final patch = buildListingPatch(
          listing,
          unchangedDraft(listing).copyWithAmenities(['wifi', 'sauna']),
        );

        expect(patch.toJson(), {
          'amenities': ['wifi', 'sauna'],
        });
      });

      test('a slug the app cannot label survives an edit', () {
        final listing = withAmenities(['wifi', 'heated_towel_rail']);

        // The host adds a sauna; the unknown slug was never touched.
        final patch = buildListingPatch(
          listing,
          unchangedDraft(listing)
              .copyWithAmenities(['wifi', 'heated_towel_rail', 'sauna']),
        );

        expect(patch.amenities, contains('heated_towel_rail'));
      });

      test('removing every amenity sends an empty list, not nothing', () {
        final listing = withAmenities(['wifi']);

        final patch = buildListingPatch(
          listing,
          unchangedDraft(listing).copyWithAmenities([]),
        );

        expect(patch.toJson(), {'amenities': <String>[]});
      });
    });
  });

  group('parseAmount', () {
    test('reads whole and decimal amounts, with a point or a comma', () {
      expect(parseAmount('250'), 250);
      expect(parseAmount('40.5'), 40.5);
      expect(parseAmount('40,5'), 40.5);
      expect(parseAmount('  12 '), 12);
      expect(parseAmount('0'), 0);
    });

    test('an integer stays an int, so it is sent as an integer', () {
      expect(parseAmount('250'), isA<int>());
    });

    test('refuses anything that is not a plain non-negative amount', () {
      for (final bad in [
        '',
        ' ',
        'abc',
        '-1',
        '1e3',
        '1.',
        '.5',
        '1,2,3',
        '12 €',
      ]) {
        expect(parseAmount(bad), isNull, reason: '"$bad"');
      }
    });
  });

  group('parseCount', () {
    test('reads whole numbers', () {
      expect(parseCount('4'), 4);
      expect(parseCount(' 0 '), 0);
    });

    test('refuses decimals, signs and text', () {
      for (final bad in ['', '2.5', '2,5', '-1', '+1', 'two']) {
        expect(parseCount(bad), isNull, reason: '"$bad"');
      }
    });
  });

  group('amountToInput', () {
    test('a whole amount has no decimals', () {
      expect(amountToInput(249, 'en'), '249');
      expect(amountToInput(249.0, 'en'), '249');
    });

    test('uses the decimal separator of the locale', () {
      expect(amountToInput(40.5, 'en'), '40.5');
      expect(amountToInput(40.5, 'de'), '40,5');
    });

    test('reads back to the same number', () {
      for (final locale in ['en', 'de']) {
        expect(parseAmount(amountToInput(40.5, locale)), 40.5);
        expect(parseAmount(amountToInput(249, locale)), 249);
      }
    });
  });
}

extension on ListingDraft {
  ListingDraft copyWithAmenities(List<String> amenities) => ListingDraft(
    title: title,
    description: description,
    pricePerNight: pricePerNight,
    cleaningFee: cleaningFee,
    maxGuests: maxGuests,
    bedrooms: bedrooms,
    beds: beds,
    bathrooms: bathrooms,
    propertyType: propertyType,
    amenities: amenities,
  );
}
