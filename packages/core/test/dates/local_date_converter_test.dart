import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalDateConverter', () {
    const converter = LocalDateConverter();

    test('reads the wire format', () {
      expect(converter.fromJson('2026-03-01'), LocalDate(2026, 3, 1));
    });

    test('writes the wire format', () {
      expect(converter.toJson(LocalDate(2026, 3, 1)), '2026-03-01');
    });

    test('round trips', () {
      expect(converter.toJson(converter.fromJson('2024-02-29')), '2024-02-29');
    });

    test('rejects a value that is not a real date', () {
      expect(() => converter.fromJson('2026-02-30'), throwsFormatException);
      expect(
        () => converter.fromJson('2026-03-01T00:00:00Z'),
        throwsFormatException,
      );
    });

    test('inside apiCall a bad date becomes an UnknownFailure', () async {
      final result = await apiCall(() async => converter.fromJson('nope'))
          .run();

      expect(result.getLeft().toNullable(), isA<UnknownFailure>());
    });
  });

  group('NullableLocalDateConverter', () {
    const converter = NullableLocalDateConverter();

    test('keeps null as null in both directions', () {
      expect(converter.fromJson(null), isNull);
      expect(converter.toJson(null), isNull);
    });

    test('converts a value', () {
      expect(converter.fromJson('2026-03-01'), LocalDate(2026, 3, 1));
      expect(converter.toJson(LocalDate(2026, 3, 1)), '2026-03-01');
    });
  });
}
