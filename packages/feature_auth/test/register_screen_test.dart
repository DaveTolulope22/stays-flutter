import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:feature_auth/src/validation/auth_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'support/auth_harness.dart';

void main() {
  late AuthHarness harness;

  setUp(() => harness = AuthHarness());

  final en = copy('en');

  Finder field(String label) => find.widgetWithText(TextFormField, label);
  Finder submit() => find.widgetWithText(FilledButton, en.authRegister);

  Future<void> fillValid(WidgetTester tester) async {
    await tester.enterText(field(en.authFirstName), '  Nia ');
    await tester.enterText(field(en.authLastName), ' New  ');
    await tester.enterText(field(en.authEmail), '  nia@acme.example ');
    await tester.enterText(field(en.authPassword), ' longenough ');
  }

  Future<void> pumpRegister(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool configLoaded = true,
  }) => harness.pump(
    tester,
    location: AuthPaths.register,
    locale: locale,
    configLoaded: configLoaded,
  );

  testWidgets('shows the four fields, the legal links and a sign-in link', (
    tester,
  ) async {
    await pumpRegister(tester);

    expect(field(en.authFirstName), findsOneWidget);
    expect(field(en.authLastName), findsOneWidget);
    expect(field(en.authEmail), findsOneWidget);
    expect(field(en.authPassword), findsOneWidget);
    expect(find.text(en.authTermsOfUse), findsOneWidget);
    expect(find.text(en.authPrivacyPolicy), findsOneWidget);
    expect(find.text(en.authGoToSignIn), findsOneWidget);
  });

  group('validation mirrors the server rules', () {
    testWidgets('an empty form shows four required errors', (tester) async {
      await pumpRegister(tester);

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text(en.authErrorRequired), findsNWidgets(4));
      expect(harness.session.registrations, isEmpty);
    });

    testWidgets('a blank name (only spaces) is refused', (tester) async {
      await pumpRegister(tester);
      await fillValid(tester);
      await tester.enterText(field(en.authFirstName), '     ');

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text(en.authErrorRequired), findsOneWidget);
      expect(harness.session.registrations, isEmpty);
    });

    testWidgets('an email that is not shaped like one is refused', (
      tester,
    ) async {
      await pumpRegister(tester);
      await fillValid(tester);
      await tester.enterText(field(en.authEmail), 'nia@nodot');

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text(en.authErrorEmailInvalid), findsOneWidget);
      expect(harness.session.registrations, isEmpty);
    });

    testWidgets('a password under the minimum is refused, with the number', (
      tester,
    ) async {
      await pumpRegister(tester);
      await fillValid(tester);
      await tester.enterText(field(en.authPassword), '1234567');

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(
        find.text(en.authErrorPasswordTooShort(minPasswordLength)),
        findsOneWidget,
      );
      expect(find.textContaining('8'), findsOneWidget);
      expect(harness.session.registrations, isEmpty);
    });

    testWidgets('the password length is translated too', (tester) async {
      await pumpRegister(tester, locale: const Locale('de'));
      final de = copy('de');
      await tester.enterText(field(de.authPassword), '123');

      await tester.tap(find.widgetWithText(FilledButton, de.authRegister));
      await tester.pumpAndSettle();

      expect(
        find.text(de.authErrorPasswordTooShort(minPasswordLength)),
        findsOneWidget,
      );
    });

    testWidgets('exactly the minimum length is accepted', (tester) async {
      await pumpRegister(tester);
      await fillValid(tester);
      await tester.enterText(field(en.authPassword), 'a' * minPasswordLength);

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(harness.session.registrations, hasLength(1));
    });
  });

  group('submitting', () {
    testWidgets('sends every field trimmed', (tester) async {
      await pumpRegister(tester);
      await fillValid(tester);

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(harness.session.registrations, [
        (
          email: 'nia@acme.example',
          password: 'longenough',
          firstName: 'Nia',
          lastName: 'New',
        ),
      ]);
    });

    testWidgets('while waiting the button is disabled, so nothing is sent '
        'twice', (tester) async {
      final pending = Completer<Either<AppFailure, Session>>();
      harness.session.onRegister = () => pending.future;
      await pumpRegister(tester);
      await fillValid(tester);

      await tester.tap(submit());
      await tester.pump();
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(harness.session.registrations, hasLength(1));

      pending.complete(right(testSession()));
      await tester.pumpAndSettle();
    });
  });

  group('when registration fails', () {
    testWidgets('a taken email shows our translated message', (tester) async {
      harness.session.onRegister = () async => left(
        const ConflictFailure(
          statusCode: 409,
          messageCode: 'error.userAlreadyExist',
        ),
      );
      await pumpRegister(tester);
      await fillValid(tester);

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text(en.errorUserAlreadyExists), findsOneWidget);
    });

    testWidgets('and in German', (tester) async {
      harness.session.onRegister = () async => left(
        const ConflictFailure(
          statusCode: 409,
          messageCode: 'error.userAlreadyExist',
        ),
      );
      await pumpRegister(tester, locale: const Locale('de'));
      final de = copy('de');
      await tester.enterText(field(de.authFirstName), 'Nia');
      await tester.enterText(field(de.authLastName), 'Neu');
      await tester.enterText(field(de.authEmail), 'n@acme.example');
      await tester.enterText(field(de.authPassword), 'longenough');

      await tester.tap(find.widgetWithText(FilledButton, de.authRegister));
      await tester.pumpAndSettle();

      expect(find.text(de.errorUserAlreadyExists), findsOneWidget);
    });

    testWidgets('an unknown code falls back and is never shown', (
      tester,
    ) async {
      harness.session.onRegister = () async => left(
        const ValidationFailure(statusCode: 400, messageCode: 'error.mystery'),
      );
      await pumpRegister(tester);
      await fillValid(tester);

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text(en.errorRequestFailed), findsOneWidget);
      expect(find.textContaining('error.mystery'), findsNothing);
    });
  });

  group('terms and privacy links', () {
    testWidgets('open the tenant\'s own pages from the config', (tester) async {
      await pumpRegister(tester);

      await tester.tap(find.text(en.authTermsOfUse));
      await tester.pump();
      await tester.tap(find.text(en.authPrivacyPolicy));
      await tester.pump();

      expect(harness.attempts, [
        Uri.parse('https://acme.example/terms'),
        Uri.parse('https://acme.example/privacy'),
      ]);
    });

    testWidgets('a link that cannot be opened says so', (tester) async {
      harness.openerResult = false;
      await pumpRegister(tester);

      await tester.tap(find.text(en.authTermsOfUse));
      await tester.pumpAndSettle();

      expect(find.text(en.authLinkOpenFailed), findsOneWidget);
    });

    testWidgets('an address that is not a web page is never launched', (
      tester,
    ) async {
      harness = AuthHarness(
        config: testConfig(terms: 'tel:+123456789', privacy: 'javascript:x()'),
      );
      await pumpRegister(tester);

      await tester.tap(find.text(en.authTermsOfUse));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.authPrivacyPolicy));
      await tester.pumpAndSettle();

      expect(harness.attempts, isEmpty);
      expect(find.text(en.authLinkOpenFailed), findsOneWidget);
    });

    testWidgets('a malformed address is refused too', (tester) async {
      harness = AuthHarness(config: testConfig(terms: 'not a url at all'));
      await pumpRegister(tester);

      await tester.tap(find.text(en.authTermsOfUse));
      await tester.pumpAndSettle();

      expect(harness.attempts, isEmpty);
    });

    testWidgets('are hidden until the config has loaded', (tester) async {
      await harness.pump(
        tester,
        location: AuthPaths.register,
        configLoaded: false,
      );

      expect(find.text(en.authTermsOfUse), findsNothing);
      expect(find.text(en.authPrivacyPolicy), findsNothing);
      expect(field(en.authFirstName), findsOneWidget);
    });
  });

  testWidgets('the sign-in link opens the sign-in screen', (tester) async {
    await pumpRegister(tester);

    await tester.tap(find.text(en.authGoToSignIn));
    await tester.pumpAndSettle();

    expect(find.text(en.authGoToRegister), findsOneWidget);
  });

  testWidgets('fits a small screen with large German text', (tester) async {
    await harness.pump(
      tester,
      location: AuthPaths.register,
      locale: const Locale('de'),
      size: const Size(280, 480),
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
