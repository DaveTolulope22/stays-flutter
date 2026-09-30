import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listings/listings.dart';

import 'support/listing_json.dart';

void main() {
  group('Listing.fromJson', () {
    test('reads a rating that arrives as an int (5 on the wire)', () {
      final listing = Listing.fromJson(listingJson(rating: 5));

      expect(listing.rating, 5.0);
      expect(listing.rating, isA<double>());
    });

    test('reads whole and fractional numbers into num and int fields', () {
      final listing = Listing.fromJson(listingJson());

      expect(listing.pricePerNight, 249);
      expect(listing.cleaningFee, 40.5);
      expect(listing.latitude, 46.8);
      expect(listing.maxGuests, 4);
    });

    test('rating 0 with no reviews means "no reviews yet"', () {
      final listing = Listing.fromJson(listingJson(rating: 0, reviewsCount: 0));

      expect(listing.hasReviews, isFalse);
    });

    test('a rated listing has reviews', () {
      expect(Listing.fromJson(listingJson()).hasReviews, isTrue);
    });

    test('keeps an amenity slug it has no label for', () {
      final listing = Listing.fromJson(
        listingJson(amenities: ['wifi', 'teleporter']),
      );

      expect(listing.amenities, ['wifi', 'teleporter']);
    });

    test('a listing with no bedrooms is a studio', () {
      expect(Listing.fromJson(listingJson(bedrooms: 0)).isStudio, isTrue);
      expect(Listing.fromJson(listingJson()).isStudio, isFalse);
    });

    test('the first image is the cover', () {
      expect(
        Listing.fromJson(listingJson()).coverImage,
        'https://picsum.photos/1',
      );
    });
  });

  group('ListingFacets.fromJson', () {
    test('reads integer and fractional bounds', () {
      final facets = ListingFacets.fromJson({
        'cities': ['Davos'],
        'propertyTypes': ['chalet'],
        'amenities': ['wifi'],
        'priceMin': 51,
        'priceMax': 694.5,
        'maxGuests': 16,
        'currency': 'CHF',
      });

      expect(facets.priceMin, 51);
      expect(facets.priceMax, 694.5);
      expect(facets.maxGuests, 16);
    });
  });

  group('Availability.fromJson', () {
    test('parses dates and lists only the taken days', () {
      final availability = Availability.fromJson({
        'listingId': 'l1',
        'from': '2026-03-01',
        'to': '2026-04-01',
        'unavailable': [
          {'date': '2026-03-05', 'reason': 'booked'},
          {'date': '2026-03-06', 'reason': 'blocked'},
        ],
      });

      expect(availability.from, LocalDate(2026, 3, 1));
      expect(availability.takenDates, {
        LocalDate(2026, 3, 5),
        LocalDate(2026, 3, 6),
      });
      expect(availability.unavailable.last.reason, UnavailableReason.blocked);
    });

    test('a reason it does not know is still a taken day', () {
      final availability = Availability.fromJson({
        'listingId': 'l1',
        'from': '2026-03-01',
        'to': '2026-04-01',
        'unavailable': [
          {'date': '2026-03-05', 'reason': 'maintenance'},
        ],
      });

      expect(availability.unavailable.single.reason, UnavailableReason.unknown);
      expect(availability.takenDates, {LocalDate(2026, 3, 5)});
    });
  });
}
