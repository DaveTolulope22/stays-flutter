import 'dart:async';

import 'package:core/core.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'support/auth_harness.dart';

void main() {
  late AuthHarness harness;

  setUp(() => harness = AuthHarness());

  final en = copy('en');

  Finder field(String label) => find.widgetWithText(TextFormField, label);
  Finder submit() => find.widgetWithText(FilledButton, en.authSignIn);

  Future<void> fillValid(WidgetTester tester) async {
    await tester.enterText(field(en.authEmail), '  guest@acme.example  ');
    await tester.enterText(field(en.authPassword), ' secret ');
  }

  testWidgets('shows the form with its title, fields and register link', (
    tester,
  ) async {
    await harness.pump(tester);

    expect(find.text(en.authSignIn), findsNWidgets(2)); // title + button
    expect(field(en.authEmail), findsOneWidget);
    expect(field(en.authPassword), findsOneWidget);
    expect(find.text(en.authGoToRegister), findsOneWidget);
  });

  group('validation', () {
    testWidgets('an empty form shows both errors and sends nothing', (
      tester,
    ) async {
      await harness.pump(tester);

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text(en.authErrorRequired), findsNWidgets(2));
      expect(harness.session.signIns, isEmpty);
    });

    testWidgets('an email that is not shaped like one is refused', (
      tester,
    ) async {
      await harness.pump(tester);
      await tester.enterText(field(en.authEmail), 'not-an-email');
      await tester.enterText(field(en.authPassword), 'x');

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text(en.authErrorEmailInvalid), findsOneWidget);
      expect(harness.session.signIns, isEmpty);
    });

    testWidgets('a short password is fine on sign-in (length is a '
        'registration rule)', (tester) async {
      await harness.pump(tester);
      await tester.enterText(field(en.authEmail), 'a@b.co');
      await tester.enterText(field(en.authPassword), 'x');

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(harness.session.signIns, hasLength(1));
    });

    testWidgets('errors are quiet at first and live after the first attempt', (
      tester,
    ) async {
      await harness.pump(tester);
      expect(find.text(en.authErrorRequired), findsNothing);

      await tester.tap(submit());
      await tester.pumpAndSettle();
      expect(find.text(en.authErrorRequired), findsNWidgets(2));

      await tester.enterText(field(en.authEmail), 'a@b.co');
      await tester.pumpAndSettle();
      expect(find.text(en.authErrorRequired), findsOneWidget);
    });

    testWidgets('errors are translated', (tester) async {
      await harness.pump(tester, locale: const Locale('de'));
      final de = copy('de');

      await tester.tap(find.widgetWithText(FilledButton, de.authSignIn));
      await tester.pumpAndSettle();

      expect(find.text(de.authErrorRequired), findsNWidgets(2));
    });
  });

  group('submitting', () {
    testWidgets('sends the trimmed email and password', (tester) async {
      await harness.pump(tester);
      await fillValid(tester);

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(harness.session.signIns, [
        (email: 'guest@acme.example', password: 'secret'),
      ]);
    });

    testWidgets('the keyboard "done" key submits as well', (tester) async {
      await harness.pump(tester);
      await fillValid(tester);

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(harness.session.signIns, hasLength(1));
    });

    testWidgets('while waiting the button is disabled with a spinner, and a '
        'second tap sends nothing', (tester) async {
      final pending = Completer<Either<AppFailure, Session>>();
      harness.session.onSignIn = () => pending.future;
      await harness.pump(tester);
      await fillValid(tester);

      await tester.tap(submit());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(harness.session.signIns, hasLength(1));

      pending.complete(right(testSession()));
      await tester.pumpAndSettle();
    });

    testWidgets('the register link is disabled while waiting', (tester) async {
      final pending = Completer<Either<AppFailure, Session>>();
      harness.session.onSignIn = () => pending.future;
      await harness.pump(tester);
      await fillValid(tester);

      await tester.tap(submit());
      await tester.pump();

      final link = tester.widget<TextButton>(
        find.widgetWithText(TextButton, en.authGoToRegister),
      );
      expect(link.onPressed, isNull);

      pending.complete(right(testSession()));
      await tester.pumpAndSettle();
    });
  });

  group('when sign-in fails', () {
    const wrongPassword = UnauthorizedFailure(
      statusCode: 401,
      messageCode: 'error.badCredentials',
    );

    testWidgets('shows our own translated message', (tester) async {
      harness.session.onSignIn = () async => left(wrongPassword);
      await harness.pump(tester);
      await fillValid(tester);

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text(en.errorBadCredentials), findsOneWidget);
    });

    testWidgets('in German for a German phone', (tester) async {
      harness.session.onSignIn = () async => left(wrongPassword);
      await harness.pump(tester, locale: const Locale('de'));
      final de = copy('de');
      await tester.enterText(field(de.authEmail), 'a@b.co');
      await tester.enterText(field(de.authPassword), 'x');

      await tester.tap(find.widgetWithText(FilledButton, de.authSignIn));
      await tester.pumpAndSettle();

      expect(find.text(de.errorBadCredentials), findsOneWidget);
    });

    testWidgets('a network failure says so', (tester) async {
      harness.session.onSignIn = () async => left(const NetworkFailure());
      await harness.pump(tester);
      await fillValid(tester);

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text(en.errorNetwork), findsOneWidget);
    });

    testWidgets('an unknown code falls back, and the code is never shown', (
      tester,
    ) async {
      harness.session.onSignIn = () async => left(
        const ServerFailure(statusCode: 500, messageCode: 'error.mystery'),
      );
      await harness.pump(tester);
      await fillValid(tester);

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text(en.errorServer), findsOneWidget);
      expect(find.textContaining('error.mystery'), findsNothing);
    });

    testWidgets('the message is announced to a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      harness.session.onSignIn = () async => left(wrongPassword);
      await harness.pump(tester);
      await fillValid(tester);

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text(en.errorBadCredentials)),
        matchesSemantics(label: en.errorBadCredentials, isLiveRegion: true),
      );
      handle.dispose();
    });

    testWidgets('the form stays filled so the user can correct it', (
      tester,
    ) async {
      harness.session.onSignIn = () async => left(wrongPassword);
      await harness.pump(tester);
      await fillValid(tester);

      await tester.tap(submit());
      await tester.pumpAndSettle();

      expect(find.text('  guest@acme.example  '), findsOneWidget);
    });

    testWidgets('the old message goes away when trying again', (tester) async {
      var attempt = 0;
      final second = Completer<Either<AppFailure, Session>>();
      harness.session.onSignIn = () =>
          attempt++ == 0 ? Future.value(left(wrongPassword)) : second.future;
      await harness.pump(tester);
      await fillValid(tester);

      await tester.tap(submit());
      await tester.pumpAndSettle();
      expect(find.text(en.errorBadCredentials), findsOneWidget);

      await tester.tap(submit());
      await tester.pump();
      expect(find.text(en.errorBadCredentials), findsNothing);

      second.complete(right(testSession()));
      await tester.pumpAndSettle();
    });
  });

  group('password field', () {
    EditableText editable(WidgetTester tester) => tester.widget<EditableText>(
      find.descendant(
        of: field(en.authPassword),
        matching: find.byType(EditableText),
      ),
    );

    testWidgets('is hidden until the user reveals it', (tester) async {
      await harness.pump(tester);
      expect(editable(tester).obscureText, isTrue);

      await tester.tap(find.byTooltip(en.authShowPassword));
      await tester.pump();
      expect(editable(tester).obscureText, isFalse);

      await tester.tap(find.byTooltip(en.authHidePassword));
      await tester.pump();
      expect(editable(tester).obscureText, isTrue);
    });
  });

  group('navigation', () {
    testWidgets('the register link opens the registration screen', (
      tester,
    ) async {
      await harness.pump(tester);

      await tester.tap(find.text(en.authGoToRegister));
      await tester.pumpAndSettle();

      expect(find.text(en.authGoToSignIn), findsOneWidget);
      expect(field(en.authFirstName), findsOneWidget);
    });
  });

  group('layout', () {
    testWidgets('fits a small screen with large German text', (tester) async {
      await harness.pump(
        tester,
        locale: const Locale('de'),
        size: const Size(280, 480),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
      await tester.tap(
        find.widgetWithText(FilledButton, copy('de').authSignIn),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  test('the module describes the sign-in and register routes', () {
    expect(authModule.area, AccessArea.none);
    expect(authModule.owns(AuthPaths.signIn), isTrue);
    expect(authModule.owns(AuthPaths.register), isTrue);
    expect(authModule.tab, isNull);
    validateModules([authModule]);
  });

  test('the module is reachable only while signed out', () {
    expect(authModule.isAllowedFor(Capabilities.none), isTrue);
    expect(
      authModule.isAllowedFor(const Capabilities(area: AccessArea.guest)),
      isFalse,
    );
    expect(
      authModule.isAllowedFor(const Capabilities(area: AccessArea.host)),
      isFalse,
    );
  });
}
