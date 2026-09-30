import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _screen(BuildContext context, GoRouterState state) => const SizedBox();

FeatureModule _module(
  String id,
  AccessArea area, {
  String? base,
  String? initial,
  bool Function(Capabilities)? requires,
}) {
  final basePath = base ?? '/$id';
  return FeatureModule(
    id: id,
    area: area,
    basePath: basePath,
    initialLocation: initial,
    routes: [GoRoute(path: initial ?? basePath, builder: _screen)],
    requires: requires,
  );
}

// Registration order matters: the first module a user may enter is their home.
final _auth = _module(
  'auth',
  AccessArea.none,
  initial: '/auth/sign-in',
  base: '/auth',
);
final _browse = _module('browse', AccessArea.guest);
final _saved = _module(
  'saved',
  AccessArea.guest,
  requires: (c) => c.canSaveListings,
);
final _host = _module('host', AccessArea.host);
final _hostUnavailable = _module('host-unavailable', AccessArea.host);

const _signedOut = Capabilities.none;
const _client = Capabilities(area: AccessArea.guest, canSaveListings: true);
const _clientNoFavourites = Capabilities(area: AccessArea.guest);
const _hostCaps = Capabilities(area: AccessArea.host, canUseHostPanel: true);

void main() {
  group('with every module registered', () {
    final modules = [_auth, _browse, _saved, _host];

    // (who, where) -> where they end up (null means: stay).
    final table = <String, (Capabilities, String, String?)>{
      'signed out at sign-in stays': (_signedOut, '/auth/sign-in', null),
      'signed out at register stays': (_signedOut, '/auth/register', null),
      'signed out at browse goes to sign-in': (
        _signedOut,
        '/browse',
        '/auth/sign-in',
      ),
      'signed out at a listing deep link goes to sign-in': (
        _signedOut,
        '/browse/listing-42',
        '/auth/sign-in',
      ),
      'signed out at host goes to sign-in': (
        _signedOut,
        '/host',
        '/auth/sign-in',
      ),
      'signed out at the root goes to sign-in': (
        _signedOut,
        '/',
        '/auth/sign-in',
      ),
      'client at browse stays': (_client, '/browse', null),
      'client at a listing stays': (_client, '/browse/listing-42', null),
      'client at saved stays': (_client, '/saved', null),
      'client at host goes to browse': (_client, '/host', '/browse'),
      'client at a host deep link goes to browse': (
        _client,
        '/host/listings/7/calendar',
        '/browse',
      ),
      'client at sign-in goes to browse': (_client, '/auth/sign-in', '/browse'),
      'client at the root goes to browse': (_client, '/', '/browse'),
      'client at a mistyped path goes to browse': (
        _client,
        '/nowhere/at/all',
        '/browse',
      ),
      'host at host stays': (_hostCaps, '/host', null),
      'host at a host sub-path stays': (_hostCaps, '/host/listings/7', null),
      'host at browse goes to host': (_hostCaps, '/browse', '/host'),
      'host at saved goes to host': (_hostCaps, '/saved', '/host'),
      'host at sign-in goes to host': (_hostCaps, '/auth/sign-in', '/host'),
      'host at the root goes to host': (_hostCaps, '/', '/host'),
    };

    table.forEach((name, row) {
      final (caps, location, expected) = row;
      test(name, () {
        expect(
          resolveRedirect(
            modules: modules,
            capabilities: caps,
            location: location,
          ),
          expected,
        );
      });
    });

    test('a query string does not change the decision', () {
      expect(
        resolveRedirect(
          modules: modules,
          capabilities: _client,
          location: '/host?x=/browse',
        ),
        '/browse',
      );
      expect(
        resolveRedirect(
          modules: modules,
          capabilities: _client,
          location: '/browse?city=Davos',
        ),
        isNull,
      );
    });

    test('a sibling path that only shares a prefix is not the module', () {
      expect(
        resolveRedirect(
          modules: modules,
          capabilities: _client,
          location: '/hostile',
        ),
        '/browse',
      );
    });

    test('a module whose extra requirement fails sends the user home', () {
      expect(
        resolveRedirect(
          modules: modules,
          capabilities: _clientNoFavourites,
          location: '/saved',
        ),
        '/browse',
      );
    });
  });

  group('a tenant with favourites off has no saved module at all', () {
    final modules = [_auth, _browse, _host];

    test('the saved path is simply unknown, and sends a client home', () {
      expect(
        resolveRedirect(
          modules: modules,
          capabilities: _client,
          location: '/saved',
        ),
        '/browse',
      );
    });
  });

  group('a tenant with the host panel off', () {
    final modules = [_auth, _browse, _hostUnavailable];

    test('a host is sent to the "not available" module, not to browsing', () {
      expect(
        resolveRedirect(
          modules: modules,
          capabilities: const Capabilities(area: AccessArea.host),
          location: '/browse',
        ),
        '/host-unavailable',
      );
    });

    test('a host at the "not available" module stays', () {
      expect(
        resolveRedirect(
          modules: modules,
          capabilities: const Capabilities(area: AccessArea.host),
          location: '/host-unavailable',
        ),
        isNull,
      );
    });

    test('a client cannot open the "not available" module', () {
      expect(
        resolveRedirect(
          modules: modules,
          capabilities: _clientNoFavourites,
          location: '/host-unavailable',
        ),
        '/browse',
      );
    });
  });

  group('edge cases', () {
    test('no module allows this user: stay put rather than loop', () {
      expect(
        resolveRedirect(
          modules: [_auth],
          capabilities: _client,
          location: '/anything',
        ),
        isNull,
      );
    });

    test('an empty module list never redirects', () {
      expect(
        resolveRedirect(
          modules: const [],
          capabilities: _signedOut,
          location: '/',
        ),
        isNull,
      );
    });

    test('never redirects to where the user already is', () {
      // The home of a client is /browse; being there is not a redirect.
      expect(
        resolveRedirect(
          modules: [_auth, _browse],
          capabilities: _client,
          location: '/browse',
        ),
        isNull,
      );
    });

    test('the redirect target is always somewhere the user may be', () {
      final modules = [_auth, _browse, _saved, _host];
      final everyone = [_signedOut, _client, _clientNoFavourites, _hostCaps];
      final places = ['/', '/auth/sign-in', '/browse', '/saved', '/host', '/x'];

      for (final caps in everyone) {
        for (final place in places) {
          final target = resolveRedirect(
            modules: modules,
            capabilities: caps,
            location: place,
          );
          if (target == null) continue;

          // One hop is enough: the target is stable.
          expect(
            resolveRedirect(
              modules: modules,
              capabilities: caps,
              location: target,
            ),
            isNull,
            reason: '$caps at $place -> $target',
          );
        }
      }
    });
  });

  group('homeLocation', () {
    test('is the first allowed module in registration order', () {
      expect(homeLocation([_auth, _browse, _saved], _client), '/browse');
      expect(homeLocation([_saved, _browse], _client), '/saved');
    });

    test('uses the initial location, not the base path', () {
      expect(homeLocation([_auth], _signedOut), '/auth/sign-in');
    });

    test('is null when nothing is allowed', () {
      expect(homeLocation([_host], _client), isNull);
      expect(homeLocation(const [], _signedOut), isNull);
    });
  });

  group('FeatureModule.initialLocation', () {
    test('defaults to the base path', () {
      expect(_browse.initialLocation, '/browse');
    });

    test('can name a front page below the base path', () {
      expect(_auth.initialLocation, '/auth/sign-in');
      expect(_auth.owns(_auth.initialLocation), isTrue);
    });

    test('must live under the base path', () {
      expect(
        () => FeatureModule(
          id: 'x',
          area: AccessArea.guest,
          basePath: '/x',
          initialLocation: '/elsewhere',
          routes: const [],
        ),
        throwsAssertionError,
      );
    });
  });
}
