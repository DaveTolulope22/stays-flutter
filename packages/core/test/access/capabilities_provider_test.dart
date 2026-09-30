import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// A session controller whose state the test decides.
class _FakeSessionController extends SessionController {
  _FakeSessionController(this._build);

  final Future<Session?> Function() _build;

  @override
  Future<Session?> build() => _build();

  void set(Session? session) => state = AsyncData(session);
}

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

TenantConfig _config(TenantFlags flags) => TenantConfig(
  slug: 'acme',
  name: 'Acme',
  currency: 'EUR',
  locales: const ['en'],
  defaultLocale: 'en',
  supportEmail: 'e@acme.example',
  termsOfUseUrl: 'https://acme.example/t',
  privacyPolicyUrl: 'https://acme.example/p',
  flags: flags,
  theme: const TenantTheme(),
);

const _allOn = TenantFlags(
  hostPanel: true,
  favourites: true,
  reviews: true,
  blockedDays: true,
);

void main() {
  ProviderContainer container({
    required Future<Session?> Function() session,
    Future<TenantConfig> Function()? config,
    void Function(_FakeSessionController)? onController,
  }) {
    final controller = _FakeSessionController(session);
    onController?.call(controller);
    final overrides = <Override>[
      sessionControllerProvider.overrideWith(() => controller),
      tenantConfigProvider.overrideWith(
        (ref) => (config ?? () async => _config(_allOn))(),
      ),
    ];
    final c = ProviderContainer(overrides: overrides);
    addTearDown(c.dispose);
    return c;
  }

  Future<Capabilities> settled(ProviderContainer c) async {
    await c.read(sessionControllerProvider.future);
    await c.read(tenantConfigProvider.future);
    return c.read(capabilitiesProvider);
  }

  test('signed out: none', () async {
    final c = container(session: () async => null);

    expect(await settled(c), Capabilities.none);
  });

  test('a client on a tenant with everything on', () async {
    final c = container(session: () async => _session(UserRole.client));

    final caps = await settled(c);

    expect(caps.area, AccessArea.guest);
    expect(caps.canSaveListings, isTrue);
  });

  test('a client on a tenant with favourites off cannot save', () async {
    final c = container(
      session: () async => _session(UserRole.client),
      config: () async => _config(const TenantFlags(reviews: true)),
    );

    final caps = await settled(c);

    expect(caps.canBrowse, isTrue);
    expect(caps.canSaveListings, isFalse);
    expect(caps.canSeeReviews, isTrue);
  });

  test('a host gets the host area', () async {
    final c = container(session: () async => _session(UserRole.host));

    final caps = await settled(c);

    expect(caps.area, AccessArea.host);
    expect(caps.canUseHostPanel, isTrue);
    expect(caps.canBlockDays, isTrue);
  });

  test('while the session is restoring, nobody is signed in', () async {
    final pending = Completer<Session?>();
    final c = container(session: () => pending.future);

    expect(c.read(capabilitiesProvider), Capabilities.none);
    pending.complete(_session(UserRole.client));
    await c.read(sessionControllerProvider.future);
    await c.read(tenantConfigProvider.future);

    expect(c.read(capabilitiesProvider).area, AccessArea.guest);
  });

  test('when restoring the session failed, nobody is signed in', () async {
    final c = container(session: () async => throw const NetworkFailure());

    await expectLater(
      c.read(sessionControllerProvider.future),
      throwsA(isA<NetworkFailure>()),
    );

    expect(c.read(capabilitiesProvider), Capabilities.none);
  });

  test('before the config loads, every flag is off', () async {
    final pending = Completer<TenantConfig>();
    final c = container(
      session: () async => _session(UserRole.client),
      config: () => pending.future,
    );
    await c.read(sessionControllerProvider.future);

    final early = c.read(capabilitiesProvider);
    expect(early.canBrowse, isTrue);
    expect(early.canSaveListings, isFalse);
    expect(early.canSeeReviews, isFalse);

    pending.complete(_config(_allOn));
    await c.read(tenantConfigProvider.future);
    expect(c.read(capabilitiesProvider).canSaveListings, isTrue);
  });

  test('follows the session as it changes: sign in, then sign out', () async {
    late _FakeSessionController controller;
    final c = container(
      session: () async => null,
      onController: (created) => controller = created,
    );
    await settled(c);
    expect(c.read(capabilitiesProvider), Capabilities.none);

    controller.set(_session(UserRole.host));
    expect(c.read(capabilitiesProvider).area, AccessArea.host);

    controller.set(null);
    expect(c.read(capabilitiesProvider), Capabilities.none);
  });
}
