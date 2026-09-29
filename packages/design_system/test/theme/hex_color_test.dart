import 'package:design_system/src/theme/hex_color.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseHexColor accepts', () {
    final valid = <String, Color>{
      '#ffffff': const Color(0xFFFFFFFF),
      '#000000': const Color(0xFF000000),
      '#1663b0': const Color(0xFF1663B0),
      '#1663B0': const Color(0xFF1663B0),
      '#fff': const Color(0xFFFFFFFF),
      '#0af': const Color(0xFF00AAFF),
    };

    valid.forEach((input, expected) {
      test(input, () => expect(parseHexColor(input), expected));
    });
  });

  group('parseHexColor rejects', () {
    for (final input in [
      null,
      '',
      '#',
      'ffffff',
      '#gggggg',
      '#12345',
      '#1234567',
      '#12345678',
      '#-12345',
      '#+12345',
      '#ff ff',
      'red',
      'rgb(0,0,0)',
    ]) {
      test('$input', () => expect(parseHexColor(input), isNull));
    }
  });
}
