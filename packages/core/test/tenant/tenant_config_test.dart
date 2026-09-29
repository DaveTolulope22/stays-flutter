import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

// A made-up tenant: the tests never use a real tenant name.
Map<String, dynamic> _json({
  Object? permissions = const {
    'hostPanel': true,
    'favourites': false,
    'reviews': false,
    'blockedDays': true,
  },
  Object? theme = const {
    'light': {'surface-primary': '#ffffff', 'text-default': '#000000'},
    'dark': {'surface-primary': '#000000', 'text-default': '#ffffff'},
  },
}) => {
  'slug': 'acme',
  'name': 'Acme Stays',
  'currency': 'EUR',
  'locales': ['en', 'de'],
  'defaultLocale': 'en',
  'supportEmail': 'support@acme.example',
  'termsOfUseUrl': 'https://acme.example/terms',
  'privacyPolicyUrl': 'https://acme.example/privacy',
  'permissions': ?permissions,
  'theme': ?theme,
};

void main() {
  test('decodes the runtime config contract', () {
    final config = TenantConfig.fromJson(_json());

    expect(config.slug, 'acme');
    expect(config.name, 'Acme Stays');
    expect(config.currency, 'EUR');
    expect(config.locales, ['en', 'de']);
    expect(config.defaultLocale, 'en');
    expect(config.termsOfUseUrl, 'https://acme.example/terms');
    expect(config.flags.hostPanel, isTrue);
    expect(config.flags.favourites, isFalse);
    expect(config.flags.reviews, isFalse);
    expect(config.flags.blockedDays, isTrue);
    expect(config.theme.light['surface-primary'], '#ffffff');
    expect(config.theme.dark['text-default'], '#ffffff');
  });

  group('flags', () {
    test('a flag the API omits is off', () {
      final config = TenantConfig.fromJson(
        _json(permissions: {'favourites': true}),
      );

      expect(config.flags.favourites, isTrue);
      expect(config.flags.hostPanel, isFalse);
      expect(config.flags.reviews, isFalse);
      expect(config.flags.blockedDays, isFalse);
    });

    test('an unknown flag is ignored', () {
      final config = TenantConfig.fromJson(
        _json(permissions: {'hostPanel': true, 'somethingNew': true}),
      );

      expect(config.flags.hostPanel, isTrue);
    });
  });

  group('theme tokens', () {
    test('a missing brightness is an empty map, not a failure', () {
      final config = TenantConfig.fromJson(
        _json(
          theme: {
            'light': {'surface-primary': '#ffffff'},
          },
        ),
      );

      expect(config.theme.dark, isEmpty);
    });

    test('a token that is not a string is dropped', () {
      final config = TenantConfig.fromJson(
        _json(
          theme: {
            'light': {'surface-primary': '#ffffff', 'text-default': 7},
            'dark': <String, dynamic>{},
          },
        ),
      );

      expect(config.theme.light, {'surface-primary': '#ffffff'});
    });

    test('a theme that is not a map is treated as empty', () {
      final config = TenantConfig.fromJson(
        _json(theme: {'light': 'nope', 'dark': null}),
      );

      expect(config.theme.light, isEmpty);
      expect(config.theme.dark, isEmpty);
    });
  });

  test('a config without a name fails to decode', () {
    final json = _json()..remove('name');

    expect(() => TenantConfig.fromJson(json), throwsA(isA<TypeError>()));
  });
}
