import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:l10n/l10n.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stays_app/src/app.dart';
import 'package:stays_app/src/boot/boot_app.dart';

import 'support/shell_harness.dart'
    show FakeSessionController, SessionScript, clientSession;

class _MockRepository extends Mock implements TenantConfigRepository {}

// Made-up tenant: the shell has no tenant names, and neither do its tests.
const _lightTokens = {
  'surface-primary': '#fafafa',
  'surface-secondary': '#eeeeee',
  'surface-action': '#0a5cb8',
  'text-default': '#101010',
  'text-muted': '#606060',
  'text-on-action': '#ffffff',
  'border-primary': '#d0d0d0',
  'icon-action': '#0a5cb8',
};

const _darkTokens = {
  'surface-primary': '#0a0a0a',
  'surface-secondary': '#1a1a1a',
  'surface-action': '#5ca8f0',
  'text-default': '#f0f0f0',
  'text-muted': '#a0a0a0',
  'text-on-action': '#000000',
  'border-primary': '#303030',
  'icon-action': '#5ca8f0',
};

TenantConfig _config({
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
  flags: const TenantFlags(),
  theme: const TenantTheme(light: _lightTokens, dark: _darkTokens),
);

AppLocalizations _copy(String language) =>
    lookupAppLocalizations(Locale(language));

Color _hex(int rgb) => Color(0xFF000000 | rgb);

void main() {
  late _MockRepository repository;

  setUp(() {
    repository = _MockRepository();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    List<Locale> deviceLocales = const [Locale('en')],
  }) async {
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    tester.platformDispatcher.localesTestValue = deviceLocales;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tenantEnvironmentProvider.overrideWithValue(
            TenantEnvironment.validated(
              tenant: 'acme',
              flavor: 'acme',
              apiBaseUrl: 'http://api.test',
            ),
          ),
          tenantConfigRepositoryProvider.overrideWithValue(repository),
          // Signed in as a client, so the tenant's own app is what shows.
          sessionControllerProvider.overrideWith(
            () => FakeSessionController(SessionScript(initial: clientSession)),
          ),
        ],
        child: const StaysApp(),
      ),
    );
  }

  void stubConfig(TenantConfig config) {
    when(() => repository.fetch('acme')).thenReturn(TaskEither.right(config));
  }

  AppColors colorsOnScreen(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Scaffold))).extension<AppColors>()!;

  group('once the config is loaded', () {
    testWidgets('shows the tenant name and the tenant colours', (tester) async {
      stubConfig(_config());

      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(find.text('Acme Stays'), findsOneWidget);
      expect(colorsOnScreen(tester).surfaceAction, _hex(0x0a5cb8));
      expect(
        Theme.of(tester.element(find.byType(Scaffold))).scaffoldBackgroundColor,
        _hex(0xfafafa),
      );
    });

    testWidgets('the app title comes from the config', (tester) async {
      stubConfig(_config());

      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).title,
        'Acme Stays',
      );
    });

    testWidgets('a dark phone gets the dark palette', (tester) async {
      stubConfig(_config());

      await pumpApp(tester, brightness: Brightness.dark);
      await tester.pumpAndSettle();

      expect(colorsOnScreen(tester).surfacePrimary, _hex(0x0a0a0a));
      expect(colorsOnScreen(tester).surfaceAction, _hex(0x5ca8f0));
    });

    testWidgets('a light phone gets the light palette', (tester) async {
      stubConfig(_config());

      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(colorsOnScreen(tester).surfacePrimary, _hex(0xfafafa));
    });
  });

  group('language', () {
    Future<Locale> shownLocale(WidgetTester tester) async {
      await tester.pumpAndSettle();
      return Localizations.localeOf(tester.element(find.byType(Scaffold)));
    }

    testWidgets('device language wins when the tenant offers it', (
      tester,
    ) async {
      stubConfig(_config(defaultLocale: 'en'));

      await pumpApp(tester, deviceLocales: const [Locale('de')]);

      expect((await shownLocale(tester)).languageCode, 'de');
    });

    testWidgets('an unsupported device language gets the tenant default', (
      tester,
    ) async {
      stubConfig(_config(defaultLocale: 'de'));

      await pumpApp(tester, deviceLocales: const [Locale('fr')]);

      expect((await shownLocale(tester)).languageCode, 'de');
    });

    testWidgets('a language the tenant does not offer is not used', (
      tester,
    ) async {
      stubConfig(_config(locales: const ['en']));

      await pumpApp(tester, deviceLocales: const [Locale('de')]);

      expect((await shownLocale(tester)).languageCode, 'en');
    });
  });

  group('while loading', () {
    testWidgets('shows a progress indicator, then the app', (tester) async {
      final completer = Completer<Either<AppFailure, TenantConfig>>();
      when(() => repository.fetch('acme'))
          .thenReturn(TaskEither(() => completer.future));

      await pumpApp(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Acme Stays'), findsNothing);

      completer.complete(right(_config()));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Acme Stays'), findsOneWidget);
    });
  });

  group('when the config fails to load', () {
    void stubFailure(AppFailure failure) {
      when(() => repository.fetch('acme')).thenReturn(TaskEither.left(failure));
    }

    testWidgets('a network failure shows our own network copy', (tester) async {
      stubFailure(const NetworkFailure());

      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(find.text(_copy('en').errorNetwork), findsOneWidget);
      expect(find.text(_copy('en').retry), findsOneWidget);
      expect(find.text('Acme Stays'), findsNothing);
    });

    testWidgets('a server failure with an unknown code shows the server-side '
        'copy, never the code', (tester) async {
      stubFailure(
        const ServerFailure(statusCode: 500, messageCode: 'error.whatever'),
      );

      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(find.text(_copy('en').errorServer), findsOneWidget);
      expect(find.textContaining('error.whatever'), findsNothing);
    });

    testWidgets('a failure with no status or code shows the generic copy', (
      tester,
    ) async {
      stubFailure(const UnknownFailure());

      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(find.text(_copy('en').errorGeneric), findsOneWidget);
    });

    testWidgets('the boot error follows the device language', (tester) async {
      stubFailure(const NetworkFailure());

      await pumpApp(tester, deviceLocales: const [Locale('de')]);
      await tester.pumpAndSettle();

      expect(find.text(_copy('de').errorNetwork), findsOneWidget);
      expect(find.text(_copy('de').retry), findsOneWidget);
    });

    testWidgets('it is fetched once: no silent automatic retry', (
      tester,
    ) async {
      stubFailure(const NetworkFailure());

      await pumpApp(tester);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      verify(() => repository.fetch('acme')).called(1);
    });

    testWidgets('Retry fetches again and then shows the app', (tester) async {
      var attempt = 0;
      when(() => repository.fetch('acme')).thenAnswer(
        (_) => attempt++ == 0
            ? TaskEither.left(const NetworkFailure())
            : TaskEither.right(_config()),
      );

      await pumpApp(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text(_copy('en').retry));
      await tester.pumpAndSettle();

      expect(find.text('Acme Stays'), findsOneWidget);
      verify(() => repository.fetch('acme')).called(2);
    });
  });

  testWidgets('a bad launch shows the developer message, not the app', (
    tester,
  ) async {
    await tester.pumpWidget(
      const BootApp(body: StartupError(message: 'TENANT does not match')),
    );

    expect(find.text('TENANT does not match'), findsOneWidget);
  });
}
