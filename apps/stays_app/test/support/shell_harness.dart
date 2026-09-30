import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:listings/listings.dart';
import 'package:stays_app/src/app.dart';
import 'package:stays_app/src/tenant_app.dart';

import 'fake_listings_repository.dart';

const clientSession = Session(
  accessToken: 'client-token',
  user: User(
    id: 'client-1',
    tenantId: 'acme',
    role: UserRole.client,
    email: 'gia@acme.example',
    firstName: 'Gia',
    lastName: 'Guest',
  ),
);

const hostSession = Session(
  accessToken: 'host-token',
  user: User(
    id: 'host-1',
    tenantId: 'acme',
    role: UserRole.host,
    email: 'hal@acme.example',
    firstName: 'Hal',
    lastName: 'Host',
  ),
);

const allFlagsOn = TenantFlags(
  hostPanel: true,
  favourites: true,
  reviews: true,
  blockedDays: true,
);

TenantConfig configWith(
  TenantFlags flags, {
  List<String> locales = const ['en', 'de'],
  String defaultLocale = 'en',
}) => TenantConfig(
  slug: 'acme',
  name: 'Acme Stays',
  currency: 'EUR',
  locales: locales,
  defaultLocale: defaultLocale,
  supportEmail: 'support@acme.example',
  termsOfUseUrl: 'https://acme.example/terms',
  privacyPolicyUrl: 'https://acme.example/privacy',
  flags: flags,
  theme: const TenantTheme(
    light: {
      'surface-primary': '#fafafa',
      'surface-secondary': '#eeeeee',
      'surface-action': '#0a5cb8',
      'text-default': '#101010',
      'text-muted': '#606060',
      'text-on-action': '#ffffff',
      'border-primary': '#d0d0d0',
      'icon-action': '#0a5cb8',
    },
    dark: {
      'surface-primary': '#0a0a0a',
      'surface-secondary': '#1a1a1a',
      'surface-action': '#5ca8f0',
      'text-default': '#f0f0f0',
      'text-muted': '#a0a0a0',
      'text-on-action': '#000000',
      'border-primary': '#303030',
      'icon-action': '#5ca8f0',
    },
  ),
);

/// What the fake session should do. A plain object because a Riverpod notifier
/// must not expose public fields.
class SessionScript {
  SessionScript({this.initial});

  /// The session found at start (null: signed out).
  Session? initial;

  /// Replaces the restore step, to simulate it loading or failing.
  Future<Session?> Function()? restore;

  /// What a successful sign-in or registration yields; null makes it fail.
  Session? signInResult;

  int signOuts = 0;
}

/// A session controller that behaves like the real one where it matters to the
/// router: signing in, signing out and expiring change its state.
class FakeSessionController extends SessionController {
  FakeSessionController(this._script);

  final SessionScript _script;

  @override
  Future<Session?> build() => _script.restore != null
      ? _script.restore!()
      : Future.value(_script.initial);

  @override
  Future<Either<AppFailure, Session>> signIn({
    required String email,
    required String password,
  }) async => _adopt();

  @override
  Future<Either<AppFailure, Session>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async => _adopt();

  Either<AppFailure, Session> _adopt() {
    final session = _script.signInResult;
    if (session == null) return left(const UnauthorizedFailure());
    state = AsyncData(session);
    return right(session);
  }

  @override
  Future<void> signOut() async {
    _script.signOuts++;
    state = const AsyncData(null);
  }

  @override
  Future<void> expireLocally() async {
    state = const AsyncData(null);
  }

  /// Simulates the session changing from outside the app's own screens.
  void setSession(Session? session) => state = AsyncData(session);
}

class ShellHarness {
  ShellHarness({
    Session? session,
    TenantFlags flags = allFlagsOn,
    TenantConfig? config,
  }) : script = SessionScript(initial: session),
       config = config ?? configWith(flags);

  final SessionScript script;
  final TenantConfig config;

  List<Override> get overrides => [
    tenantEnvironmentProvider.overrideWithValue(
      TenantEnvironment.validated(
        tenant: 'acme',
        flavor: 'acme',
        apiBaseUrl: 'http://api.test',
      ),
    ),
    tenantConfigProvider.overrideWith((ref) => config),
    sessionControllerProvider.overrideWith(() => FakeSessionController(script)),
    listingsRepositoryProvider.overrideWithValue(FakeListingsRepository()),
  ];

  /// Pumps the whole app ([StaysApp]), or just the tenant app with the given
  /// modules when [modules] is set.
  Future<void> pump(
    WidgetTester tester, {
    Locale device = const Locale('en'),
    Brightness brightness = Brightness.light,
    List<FeatureModule> Function(TenantFlags)? modules,
    bool settle = true,
  }) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.localesTestValue = [device];
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: modules == null
            ? const StaysApp()
            : TenantApp(config: config, buildModules: modules),
      ),
    );
    settle ? await tester.pumpAndSettle() : await tester.pump();
  }
}

/// The app's router, to navigate as a deep link would.
GoRouter routerOf(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(Scaffold).first));

/// The copy for a language, for finders.
AppLocalizations copy(String language) =>
    lookupAppLocalizations(Locale(language));

/// A module made for tests: a screen that just names itself.
FeatureModule tabbedModule(
  String id,
  AccessArea area, {
  String? label,
  bool withTab = true,
}) => FeatureModule(
  id: id,
  area: area,
  basePath: '/$id',
  routes: [
    GoRoute(
      path: '/$id',
      builder: (context, state) =>
          Scaffold(body: Center(child: Text('$id screen'))),
    ),
  ],
  tab: withTab
      ? NavTab(label: (_) => label ?? id, icon: Icons.circle_outlined)
      : null,
);
