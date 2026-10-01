import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

typedef SignInCall = ({String email, String password});
typedef RegisterCall = ({
  String email,
  String password,
  String firstName,
  String lastName,
});

Session testSession() => const Session(
  accessToken: 'tok',
  user: User(
    id: 'u1',
    tenantId: 'acme',
    role: UserRole.client,
    email: 'guest@acme.example',
    firstName: 'Gia',
    lastName: 'Guest',
  ),
);

/// What the forms sent, and what the test wants the session to answer. It is a
/// plain object because a Riverpod notifier must not expose public fields.
class SessionScript {
  final signIns = <SignInCall>[];
  final registrations = <RegisterCall>[];

  Future<Either<AppFailure, Session>> Function() onSignIn = () async =>
      right(testSession());
  Future<Either<AppFailure, Session>> Function() onRegister = () async =>
      right(testSession());
}

/// A session controller the test drives through a [SessionScript].
class FakeSessionController extends SessionController {
  FakeSessionController(this._script);

  final SessionScript _script;

  @override
  Future<Session?> build() async => null;

  @override
  Future<Either<AppFailure, Session>> signIn({
    required String email,
    required String password,
  }) {
    _script.signIns.add((email: email, password: password));
    return _script.onSignIn();
  }

  @override
  Future<Either<AppFailure, Session>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    _script.registrations.add((
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    ));
    return _script.onRegister();
  }
}

class AuthHarness {
  final SessionScript session = SessionScript();

  Future<void> pump(
    WidgetTester tester, {
    String location = AuthPaths.signIn,
    Locale locale = const Locale('en'),
    Size size = const Size(400, 900),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: location,
      routes: authModule.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionControllerProvider.overrideWith(
            () => FakeSessionController(session),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: buildNeutralTheme(Brightness.light),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
}

AppLocalizations copy(String language) =>
    lookupAppLocalizations(Locale(language));
