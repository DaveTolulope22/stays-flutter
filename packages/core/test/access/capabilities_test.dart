import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

Session _session(UserRole role) => Session(
  accessToken: 'tok',
  user: User(
    id: 'u1',
    tenantId: 'acme',
    role: role,
    email: 'e@acme.example',
    firstName: 'F',
    lastName: 'L',
  ),
);

final _client = _session(UserRole.client);
final _host = _session(UserRole.host);

TenantFlags _flags({
  bool hostPanel = false,
  bool favourites = false,
  bool reviews = false,
  bool blockedDays = false,
}) => TenantFlags(
  hostPanel: hostPanel,
  favourites: favourites,
  reviews: reviews,
  blockedDays: blockedDays,
);

/// Every combination of the four flags.
final _allFlagCombinations = [
  for (var bits = 0; bits < 16; bits++)
    _flags(
      hostPanel: bits & 1 != 0,
      favourites: bits & 2 != 0,
      reviews: bits & 4 != 0,
      blockedDays: bits & 8 != 0,
    ),
];

void main() {
  group('the readable matrix', () {
    // Two tenants shaped like the real ones: everything on, and a tenant with
    // favourites and reviews off.
    final everythingOn = _flags(
      hostPanel: true,
      favourites: true,
      reviews: true,
      blockedDays: true,
    );
    final noFavouritesNoReviews = _flags(hostPanel: true, blockedDays: true);

    test('signed out: nothing at all, whatever the flags', () {
      final caps = resolveCapabilities(null, everythingOn);

      expect(caps, Capabilities.none);
      expect(caps.area, AccessArea.none);
      expect(caps.canBrowse, isFalse);
    });

    test('client, everything on: browse, save, ratings; no host side', () {
      final caps = resolveCapabilities(_client, everythingOn);

      expect(caps.area, AccessArea.guest);
      expect(caps.canBrowse, isTrue);
      expect(caps.canSaveListings, isTrue);
      expect(caps.canSeeReviews, isTrue);
      expect(caps.canUseHostPanel, isFalse);
      expect(caps.canBlockDays, isFalse);
    });

    test('client, favourites and reviews off: browse only', () {
      final caps = resolveCapabilities(_client, noFavouritesNoReviews);

      expect(caps.canBrowse, isTrue);
      expect(caps.canSaveListings, isFalse);
      expect(caps.canSeeReviews, isFalse);
    });

    test(
      'host, everything on: the host area and the calendar, no guest side',
      () {
        final caps = resolveCapabilities(_host, everythingOn);

        expect(caps.area, AccessArea.host);
        expect(caps.canBrowse, isFalse);
        expect(caps.canSaveListings, isFalse);
        expect(caps.canUseHostPanel, isTrue);
        expect(caps.canBlockDays, isTrue);
        expect(caps.canSeeReviews, isTrue);
      },
    );

    test('host, blockedDays off: the host area but a read-only calendar', () {
      final caps = resolveCapabilities(
        _host,
        _flags(hostPanel: true, blockedDays: false),
      );

      expect(caps.canUseHostPanel, isTrue);
      expect(caps.canBlockDays, isFalse);
    });

    test(
      'host, hostPanel off: still on the host side, but with no host area',
      () {
        final caps = resolveCapabilities(
          _host,
          _flags(hostPanel: false, blockedDays: true, favourites: true),
        );

        expect(caps.area, AccessArea.host);
        expect(caps.canUseHostPanel, isFalse);
        expect(caps.canBlockDays, isFalse);
        // Still not a guest, so no browsing and no saving to fall back on.
        expect(caps.canBrowse, isFalse);
        expect(caps.canSaveListings, isFalse);
      },
    );

    test('ratings follow the reviews flag for both roles', () {
      for (final session in [_client, _host]) {
        expect(
          resolveCapabilities(session, _flags(reviews: true)).canSeeReviews,
          isTrue,
        );
        expect(
          resolveCapabilities(session, _flags(reviews: false)).canSeeReviews,
          isFalse,
        );
      }
    });
  });

  group('invariants over every role and all 16 flag combinations', () {
    test('signed out never has any capability', () {
      for (final flags in _allFlagCombinations) {
        expect(resolveCapabilities(null, flags), Capabilities.none);
      }
    });

    test('a client never gets a host capability', () {
      for (final flags in _allFlagCombinations) {
        final caps = resolveCapabilities(_client, flags);

        expect(caps.area, AccessArea.guest, reason: '$flags');
        expect(caps.canUseHostPanel, isFalse, reason: '$flags');
        expect(caps.canBlockDays, isFalse, reason: '$flags');
      }
    });

    test('a host never gets a guest capability', () {
      for (final flags in _allFlagCombinations) {
        final caps = resolveCapabilities(_host, flags);

        expect(caps.area, AccessArea.host, reason: '$flags');
        expect(caps.canBrowse, isFalse, reason: '$flags');
        expect(caps.canSaveListings, isFalse, reason: '$flags');
      }
    });

    test('a client can browse in every tenant, whatever the flags', () {
      for (final flags in _allFlagCombinations) {
        expect(resolveCapabilities(_client, flags).canBrowse, isTrue);
      }
    });

    test('a feature that is switched off is never available', () {
      for (final flags in _allFlagCombinations) {
        for (final session in [_client, _host]) {
          final caps = resolveCapabilities(session, flags);

          if (!flags.favourites) expect(caps.canSaveListings, isFalse);
          if (!flags.reviews) expect(caps.canSeeReviews, isFalse);
          if (!flags.hostPanel) {
            expect(caps.canUseHostPanel, isFalse);
            expect(caps.canBlockDays, isFalse);
          }
          if (!flags.blockedDays) expect(caps.canBlockDays, isFalse);
        }
      }
    });

    test('blocking days needs the host panel as well as its own flag', () {
      for (final flags in _allFlagCombinations) {
        final caps = resolveCapabilities(_host, flags);

        expect(
          caps.canBlockDays,
          flags.hostPanel && flags.blockedDays,
          reason: '$flags',
        );
      }
    });

    test('an unrelated flag never switches on someone else\'s capability', () {
      final onlyReviews = _flags(reviews: true);

      final client = resolveCapabilities(_client, onlyReviews);
      final host = resolveCapabilities(_host, onlyReviews);

      expect(client.canSaveListings, isFalse);
      expect(host.canUseHostPanel, isFalse);
    });
  });

  test('a default Capabilities grants nothing', () {
    const caps = Capabilities();

    expect(caps.area, AccessArea.none);
    expect(caps.canBrowse, isFalse);
    expect(caps.canSaveListings, isFalse);
    expect(caps.canSeeReviews, isFalse);
    expect(caps.canUseHostPanel, isFalse);
    expect(caps.canBlockDays, isFalse);
  });
}
