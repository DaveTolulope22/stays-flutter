import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stays_app/src/modules/shell_modules.dart';

import 'support/fake_listings_repository.dart';
import 'support/shell_harness.dart';

void main() {
  final en = copy('en');

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  /// The guest side is the browse screen, which shows the (fake) listing; the
  /// host side is still the temporary home, which shows the role in plain text.
  Finder guestHome() => find.text(shellListing.title);
  Finder hostHome() => find.text('host');
  Finder signInScreen() => find.widgetWithText(FilledButton, en.authSignIn);

  Future<void> go(WidgetTester tester, String location) async {
    routerOf(tester).go(location);
    await tester.pumpAndSettle();
  }

  group('signed out', () {
    testWidgets('lands on sign-in', (tester) async {
      await ShellHarness().pump(tester);

      expect(signInScreen(), findsOneWidget);
      expect(guestHome(), findsNothing);
    });

    testWidgets('a deep link to a guest or host page goes to sign-in', (
      tester,
    ) async {
      await ShellHarness().pump(tester);

      await go(tester, '/browse');
      expect(signInScreen(), findsOneWidget);

      await go(tester, '/host');
      expect(signInScreen(), findsOneWidget);
    });

    testWidgets('can open registration and come back', (tester) async {
      await ShellHarness().pump(tester);

      await go(tester, '/auth/register');
      expect(field(en.authFirstName), findsOneWidget);

      await tester.tap(find.text(en.authGoToSignIn));
      await tester.pumpAndSettle();
      expect(signInScreen(), findsOneWidget);
    });
  });

  group('a client', () {
    testWidgets('lands on the guest side, not on sign-in', (tester) async {
      await ShellHarness(session: clientSession).pump(tester);

      expect(guestHome(), findsOneWidget);
      expect(signInScreen(), findsNothing);
    });

    testWidgets('cannot reach a host route, decided on the device', (
      tester,
    ) async {
      await ShellHarness(session: clientSession).pump(tester);

      await go(tester, '/host');
      expect(guestHome(), findsOneWidget);
      expect(hostHome(), findsNothing);

      await go(tester, '/host/listings/7/calendar');
      expect(guestHome(), findsOneWidget);
    });

    testWidgets('cannot open sign-in or registration while signed in', (
      tester,
    ) async {
      await ShellHarness(session: clientSession).pump(tester);

      await go(tester, '/auth/sign-in');
      expect(guestHome(), findsOneWidget);

      await go(tester, '/auth/register');
      expect(guestHome(), findsOneWidget);
    });

    testWidgets('a mistyped path goes to the guest side', (tester) async {
      await ShellHarness(session: clientSession).pump(tester);

      await go(tester, '/nowhere');

      expect(guestHome(), findsOneWidget);
    });
  });

  group('a host', () {
    testWidgets('lands on the host side', (tester) async {
      await ShellHarness(session: hostSession).pump(tester);

      expect(hostHome(), findsOneWidget);
      expect(find.text('Hal Host'), findsOneWidget);
    });

    testWidgets('sees only the host side: no browsing', (tester) async {
      await ShellHarness(session: hostSession).pump(tester);

      await go(tester, '/browse');

      expect(hostHome(), findsOneWidget);
      expect(guestHome(), findsNothing);
    });

    testWidgets('cannot open sign-in while signed in', (tester) async {
      await ShellHarness(session: hostSession).pump(tester);

      await go(tester, '/auth/sign-in');

      expect(hostHome(), findsOneWidget);
    });
  });

  group('a host on a tenant with the host panel off', () {
    final flags = allFlagsOn.copyWith(hostPanel: false);

    testWidgets('sees a "not available" screen with sign-out', (tester) async {
      await ShellHarness(session: hostSession, flags: flags).pump(tester);

      expect(find.text(en.hostUnavailable), findsOneWidget);
      expect(find.text(en.signOut), findsOneWidget);
      expect(hostHome(), findsNothing);
    });

    testWidgets('does not fall through to browsing', (tester) async {
      await ShellHarness(session: hostSession, flags: flags).pump(tester);

      await go(tester, '/browse');
      expect(find.text(en.hostUnavailable), findsOneWidget);
      expect(guestHome(), findsNothing);
    });

    testWidgets('the host route does not exist for this tenant', (
      tester,
    ) async {
      await ShellHarness(session: hostSession, flags: flags).pump(tester);

      await go(tester, '/host');

      expect(find.text(en.hostUnavailable), findsOneWidget);
    });

    testWidgets('the screen is translated', (tester) async {
      await ShellHarness(
        session: hostSession,
        flags: flags,
      ).pump(tester, device: const Locale('de'));

      expect(find.text(copy('de').hostUnavailable), findsOneWidget);
    });

    testWidgets('can sign out from it', (tester) async {
      final harness = ShellHarness(session: hostSession, flags: flags);
      await harness.pump(tester);

      await tester.tap(find.text(en.signOut));
      await tester.pumpAndSettle();

      expect(harness.script.signOuts, 1);
      expect(signInScreen(), findsOneWidget);
    });

    testWidgets('a client on the same tenant is unaffected', (tester) async {
      await ShellHarness(session: clientSession, flags: flags).pump(tester);

      expect(guestHome(), findsOneWidget);
      await go(tester, '/host-unavailable');
      expect(guestHome(), findsOneWidget);
    });
  });

  group('moving without navigating', () {
    testWidgets('signing in moves a client to the guest side', (tester) async {
      final harness = ShellHarness();
      harness.script.signInResult = clientSession;
      await harness.pump(tester);

      await tester.enterText(field(en.authEmail), 'gia@acme.example');
      await tester.enterText(field(en.authPassword), 'secret');
      await tester.tap(find.widgetWithText(FilledButton, en.authSignIn));
      await tester.pumpAndSettle();

      expect(guestHome(), findsOneWidget);
      expect(signInScreen(), findsNothing);
    });

    testWidgets('signing in as a host moves to the host side', (tester) async {
      final harness = ShellHarness();
      harness.script.signInResult = hostSession;
      await harness.pump(tester);

      await tester.enterText(field(en.authEmail), 'hal@acme.example');
      await tester.enterText(field(en.authPassword), 'secret');
      await tester.tap(find.widgetWithText(FilledButton, en.authSignIn));
      await tester.pumpAndSettle();

      expect(hostHome(), findsOneWidget);
    });

    testWidgets('registering signs the new client in', (tester) async {
      final harness = ShellHarness();
      harness.script.signInResult = clientSession;
      await harness.pump(tester);
      await go(tester, '/auth/register');

      await tester.enterText(field(en.authFirstName), 'Gia');
      await tester.enterText(field(en.authLastName), 'Guest');
      await tester.enterText(field(en.authEmail), 'gia@acme.example');
      await tester.enterText(field(en.authPassword), 'longenough');
      await tester.tap(find.widgetWithText(FilledButton, en.authRegister));
      await tester.pumpAndSettle();

      expect(guestHome(), findsOneWidget);
    });

    testWidgets('a wrong password stays on sign-in with our message', (
      tester,
    ) async {
      await ShellHarness().pump(tester); // signInResult null: it fails

      await tester.enterText(field(en.authEmail), 'gia@acme.example');
      await tester.enterText(field(en.authPassword), 'wrong');
      await tester.tap(find.widgetWithText(FilledButton, en.authSignIn));
      await tester.pumpAndSettle();

      expect(signInScreen(), findsOneWidget);
      expect(guestHome(), findsNothing);
    });

    testWidgets('signing out moves back to sign-in', (tester) async {
      final harness = ShellHarness(session: clientSession);
      await harness.pump(tester);

      await tester.tap(find.byTooltip(en.signOut));
      await tester.pumpAndSettle();

      expect(signInScreen(), findsOneWidget);
      expect(guestHome(), findsNothing);
    });

    testWidgets('after signing out, the guest pages are closed again', (
      tester,
    ) async {
      await ShellHarness(session: clientSession).pump(tester);
      await tester.tap(find.byTooltip(en.signOut));
      await tester.pumpAndSettle();

      await go(tester, '/browse');

      expect(signInScreen(), findsOneWidget);
    });

    testWidgets('a session that dies elsewhere (a rejected token) moves the '
        'user to sign-in', (tester) async {
      await ShellHarness(session: clientSession).pump(tester);
      expect(guestHome(), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      await container.read(sessionControllerProvider.notifier).expireLocally();
      await tester.pumpAndSettle();

      expect(signInScreen(), findsOneWidget);
    });

    testWidgets('a client signed in as a different account is re-sorted', (
      tester,
    ) async {
      await ShellHarness(session: clientSession).pump(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );

      (container.read(
        sessionControllerProvider.notifier,
      ) as FakeSessionController).setSession(hostSession);
      await tester.pumpAndSettle();

      expect(hostHome(), findsOneWidget);
      expect(guestHome(), findsNothing);
    });
  });

  group('while the session is being restored', () {
    testWidgets('shows the boot spinner, never the sign-in screen', (
      tester,
    ) async {
      final pending = Completer<Session?>();
      final harness = ShellHarness();
      harness.script.restore = () => pending.future;

      await harness.pump(tester, settle: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(signInScreen(), findsNothing);

      pending.complete(clientSession);
      await tester.pumpAndSettle();
      expect(guestHome(), findsOneWidget);
      expect(signInScreen(), findsNothing);
    });

    testWidgets('a restore that cannot be verified shows our message with '
        'Retry, then continues', (tester) async {
      var attempt = 0;
      final harness = ShellHarness();
      harness.script.restore = () async {
        if (attempt++ == 0) throw const NetworkFailure();
        return clientSession;
      };

      await harness.pump(tester);

      expect(find.text(en.errorNetwork), findsOneWidget);
      expect(signInScreen(), findsNothing);

      await tester.tap(find.text(en.retry));
      await tester.pumpAndSettle();

      expect(guestHome(), findsOneWidget);
    });
  });

  group('tabs', () {
    List<FeatureModule> Function(TenantFlags) withModules({
      required bool favourites,
    }) =>
        (flags) => [
          authModule,
          tabbedModule('browse', AccessArea.guest, label: 'Browse'),
          if (favourites)
            tabbedModule('saved', AccessArea.guest, label: 'Saved'),
          tabbedModule('listings', AccessArea.host, label: 'My listings'),
          tabbedModule('bookings', AccessArea.host, label: 'Bookings'),
        ];

    testWidgets('a guest with two tabs gets a bottom bar and can switch', (
      tester,
    ) async {
      await ShellHarness(session: clientSession)
          .pump(tester, modules: withModules(favourites: true));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('browse screen'), findsOneWidget);

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      expect(find.text('saved screen'), findsOneWidget);

      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      expect(find.text('browse screen'), findsOneWidget);
    });

    testWidgets('a guest never sees the host tabs', (tester) async {
      await ShellHarness(session: clientSession)
          .pump(tester, modules: withModules(favourites: true));

      expect(find.text('My listings'), findsNothing);
      expect(find.text('Bookings'), findsNothing);
    });

    testWidgets('with one tab there is no bottom bar (favourites off)', (
      tester,
    ) async {
      await ShellHarness(session: clientSession)
          .pump(tester, modules: withModules(favourites: false));

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('browse screen'), findsOneWidget);
    });

    testWidgets('a switched-off tab has no route at all', (tester) async {
      await ShellHarness(session: clientSession)
          .pump(tester, modules: withModules(favourites: false));

      await go(tester, '/saved');

      expect(find.text('browse screen'), findsOneWidget);
      expect(find.text('saved screen'), findsNothing);
    });

    testWidgets('a host gets the host tabs and cannot open a guest tab', (
      tester,
    ) async {
      await ShellHarness(session: hostSession)
          .pump(tester, modules: withModules(favourites: true));

      expect(find.text('My listings'), findsOneWidget);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Browse'), findsNothing);

      await go(tester, '/saved');
      expect(find.text('listings screen'), findsOneWidget);
      expect(find.text('saved screen'), findsNothing);
    });

    testWidgets('tab labels come from the feature, in the user\'s language', (
      tester,
    ) async {
      List<FeatureModule> localized(TenantFlags flags) => [
        authModule,
        FeatureModule(
          id: 'browse',
          area: AccessArea.guest,
          basePath: '/browse',
          routes: [
            GoRoute(
              path: '/browse',
              builder: (context, state) => const Scaffold(),
            ),
          ],
          tab: NavTab(label: (c) => copy('de').signOut, icon: Icons.home),
        ),
        FeatureModule(
          id: 'more',
          area: AccessArea.guest,
          basePath: '/more',
          routes: [
            GoRoute(
              path: '/more',
              builder: (context, state) => const Scaffold(),
            ),
          ],
          tab: NavTab(label: (c) => 'More', icon: Icons.more_horiz),
        ),
      ];

      await ShellHarness(session: clientSession)
          .pump(tester, modules: localized);

      expect(find.text(copy('de').signOut), findsOneWidget);
    });
  });

  group('modulesFor: registration comes from the flags only', () {
    List<String> ids(TenantFlags flags) => [
      for (final module in modulesFor(flags)) module.id,
    ];

    test('with the host panel on: auth, guest and host', () {
      expect(ids(allFlagsOn), ['auth', 'browse', 'host-home']);
    });

    test('with the host panel off: the "not available" module instead', () {
      expect(ids(allFlagsOn.copyWith(hostPanel: false)), [
        'auth',
        'browse',
        'host-unavailable',
      ]);
    });

    test('the same flags always give the same modules', () {
      expect(ids(allFlagsOn), ids(allFlagsOn));
    });

    test('the registered set is valid', () {
      for (final panel in [true, false]) {
        validateModules(modulesFor(allFlagsOn.copyWith(hostPanel: panel)));
      }
    });
  });
}
