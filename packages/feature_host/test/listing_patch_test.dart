import 'package:feature_host/src/models/listing_patch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ListingPatch', () {
    test('a patch with nothing set is empty and encodes to {}', () {
      const patch = ListingPatch();

      expect(patch.isEmpty, isTrue);
      expect(patch.toJson(), isEmpty);
    });

    test('only the set fields are encoded', () {
      const patch = ListingPatch(title: 'New', beds: 3);

      expect(patch.toJson(), {'title': 'New', 'beds': 3});
      expect(patch.isEmpty, isFalse);
    });

    test('numbers encode as JSON numbers, not strings', () {
      const patch = ListingPatch(pricePerNight: 250, cleaningFee: 40.5);

      final json = patch.toJson();

      expect(json['pricePerNight'], isA<num>());
      expect(json['cleaningFee'], 40.5);
    });
  });
}
