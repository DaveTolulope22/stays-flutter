import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart' show ResponseBody;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../support/fake_http_adapter.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

User _user({
  String tenant = 'acme',
  UserRole role = UserRole.client,
  String id = 'u1',
}) => User(
  id: id,
  tenantId: tenant,
  role: role,
  email: 'guest@acme.example',
  firstName: 'Gia',
  lastName: 'Guest',
);

Session _session({
  String token = 'tok',
  String tenant = 'acme',
  UserRole role = UserRole.client,
}) => Session(
  accessToken: token,
  user: _user(tenant: tenant, role: role),
);

const _storageKey = 'session.acme';

void _storeSession(Session session) =>
    FlutterSecureStorage.setMockInitialValues({
      _storageKey: jsonEncode(session.toJson()),
    });

Future<Map<String, String>> _rawStorage() =>
    const FlutterSecureStorage().readAll();

TenantEnvironment _environment() => TenantEnvironment.validated(
  tenant: 'acme',
  flavor: 'acme',
  apiBaseUrl: 'http://api.test',
);

void main() {
  late _MockAuthRepository repository;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    repository = _MockAuthRepository();
  });

  ProviderContainer containerWithMock({List<Override> extra = const []}) {
    final container = ProviderContainer(
      overrides: [
        tenantEnvironmentProvider.overrideWithValue(_environment()),
        authRepositoryProvider.overrideWithValue(repository),
        ...extra,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Session? current(ProviderContainer container) =>
      container.read(sessionControllerProvider).value;

  void stubMe(Either<AppFailure, User> result) {
    when(() => repository.me(token: any(named: 'token')))
        .thenReturn(TaskEither.fromEither(result));
  }

  group('restoring on start', () {
    test('nothing stored: signed out, and the server is not asked', () async {
      final container = containerWithMock();

      final session = await container.read(sessionControllerProvider.future);

      expect(session, isNull);
      verifyNever(() => repository.me(token: any(named: 'token')));
    });

    test(
      'a stored session is confirmed with /auth/me using its token',
      () async {
        _storeSession(_session(token: 'stored'));
        stubMe(right(_user()));
        final container = containerWithMock();

        final session = await container.read(sessionControllerProvider.future);

        expect(session?.accessToken, 'stored');
        verify(() => repository.me(token: 'stored')).called(1);
      },
    );

    test(
      'the confirmed user replaces the stored one (a changed role)',
      () async {
        _storeSession(_session(role: UserRole.client));
        stubMe(right(_user(role: UserRole.host)));
        final container = containerWithMock();

        final session = await container.read(sessionControllerProvider.future);

        expect(session?.user.role, UserRole.host);
        final stored = Session.fromJson(
          jsonDecode((await _rawStorage())[_storageKey]!)
              as Map<String, dynamic>,
        );
        expect(stored.user.role, UserRole.host);
        expect(stored.accessToken, 'tok');
      },
    );

    test(
      'a revoked token (401) is discarded: signed out, storage cleared',
      () async {
        _storeSession(_session());
        stubMe(left(const UnauthorizedFailure(statusCode: 401)));
        final container = containerWithMock();

        final session = await container.read(sessionControllerProvider.future);

        expect(session, isNull);
        expect(await _rawStorage(), isEmpty);
      },
    );

    test('a user of another tenant from /auth/me is discarded', () async {
      _storeSession(_session());
      stubMe(left(const TenantMismatchFailure()));
      final container = containerWithMock();

      final session = await container.read(sessionControllerProvider.future);

      expect(session, isNull);
      expect(await _rawStorage(), isEmpty);
    });

    test(
      'a stored session of another tenant is discarded without a request',
      () async {
        _storeSession(_session(tenant: 'other'));
        final container = containerWithMock();

        final session = await container.read(sessionControllerProvider.future);

        expect(session, isNull);
        expect(await _rawStorage(), isEmpty);
        verifyNever(() => repository.me(token: any(named: 'token')));
      },
    );

    test('a corrupt stored value is signed out, not an error', () async {
      FlutterSecureStorage.setMockInitialValues({_storageKey: 'not json'});
      final container = containerWithMock();

      final session = await container.read(sessionControllerProvider.future);

      expect(session, isNull);
      expect(await _rawStorage(), isEmpty);
    });

    group('fails closed when the check cannot be made', () {
      final failures = <String, AppFailure>{
        'network': const NetworkFailure(),
        'server error': const ServerFailure(statusCode: 500),
        'forbidden': const ForbiddenFailure(statusCode: 403),
        'unknown': const UnknownFailure(),
      };

      failures.forEach((name, failure) {
        test(name, () async {
          _storeSession(_session());
          stubMe(left(failure));
          final container = containerWithMock();

          await expectLater(
            container.read(sessionControllerProvider.future),
            throwsA(same(failure)),
          );

          expect(container.read(sessionControllerProvider).hasError, isTrue);
          // Nothing was decided, so the stored session is untouched.
          expect((await _rawStorage()).containsKey(_storageKey), isTrue);
        });
      });

      test('it asks once: no silent automatic retry', () async {
        _storeSession(_session());
        stubMe(left(const NetworkFailure()));
        final container = containerWithMock();

        await expectLater(
          container.read(sessionControllerProvider.future),
          throwsA(isA<NetworkFailure>()),
        );
        await Future<void>.delayed(const Duration(milliseconds: 600));

        verify(() => repository.me(token: any(named: 'token'))).called(1);
      });

      test('invalidate retries the restore and then signs in', () async {
        _storeSession(_session());
        var attempt = 0;
        when(() => repository.me(token: any(named: 'token'))).thenAnswer(
          (_) => attempt++ == 0
              ? TaskEither.left(const NetworkFailure())
              : TaskEither.right(_user()),
        );
        final container = containerWithMock();

        await expectLater(
          container.read(sessionControllerProvider.future),
          throwsA(isA<NetworkFailure>()),
        );
        container.invalidate(sessionControllerProvider);
        final session = await container.read(sessionControllerProvider.future);

        expect(session?.accessToken, 'tok');
        verify(() => repository.me(token: any(named: 'token'))).called(2);
      });
    });
  });

  group('signIn', () {
    test('a success stores the session and becomes the state', () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenReturn(TaskEither.right(_session(token: 'new')));
      final container = containerWithMock();
      await container.read(sessionControllerProvider.future);

      final result = await container
          .read(sessionControllerProvider.notifier)
          .signIn(email: 'a@b.c', password: 'pw');

      expect(result.isRight(), isTrue);
      expect(current(container)?.accessToken, 'new');
      expect((await _rawStorage()).containsKey(_storageKey), isTrue);
    });

    test('a wrong password returns the failure and stays signed out', () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenReturn(
        TaskEither.left(
          const UnauthorizedFailure(
            statusCode: 401,
            messageCode: 'error.badCredentials',
          ),
        ),
      );
      final container = containerWithMock();
      await container.read(sessionControllerProvider.future);

      final result = await container
          .read(sessionControllerProvider.notifier)
          .signIn(email: 'a@b.c', password: 'bad');

      expect(
        result.getLeft().toNullable()?.messageCode,
        'error.badCredentials',
      );
      // The session is still a normal signed-out value, not an error.
      expect(container.read(sessionControllerProvider).hasError, isFalse);
      expect(current(container), isNull);
      expect(await _rawStorage(), isEmpty);
    });

    test('a user of another tenant is not stored or adopted', () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenReturn(TaskEither.left(const TenantMismatchFailure()));
      final container = containerWithMock();
      await container.read(sessionControllerProvider.future);

      final result = await container
          .read(sessionControllerProvider.notifier)
          .signIn(email: 'a@b.c', password: 'pw');

      expect(result.getLeft().toNullable(), isA<TenantMismatchFailure>());
      expect(current(container), isNull);
      expect(await _rawStorage(), isEmpty);
    });

    test(
      'still signs in for this run if the platform refuses to store it',
      () async {
        final failing = _MockSecureStorage();
        when(() => failing.read(key: any(named: 'key')))
            .thenAnswer((_) async => null);
        when(
          () => failing.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenThrow(Exception('keystore unavailable'));
        when(
          () => repository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenReturn(TaskEither.right(_session()));
        final container = containerWithMock(
          extra: [secureStorageProvider.overrideWithValue(failing)],
        );
        await container.read(sessionControllerProvider.future);

        final result = await container
            .read(sessionControllerProvider.notifier)
            .signIn(email: 'a@b.c', password: 'pw');

        expect(result.isRight(), isTrue);
        expect(current(container)?.accessToken, 'tok');
      },
    );
  });

  group('register', () {
    test('a success signs the new user in and stores the session', () async {
      when(
        () => repository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
        ),
      ).thenReturn(TaskEither.right(_session(token: 'fresh')));
      final container = containerWithMock();
      await container.read(sessionControllerProvider.future);

      final result = await container
          .read(sessionControllerProvider.notifier)
          .register(
            email: 'n@acme.example',
            password: 'longenough',
            firstName: 'Nia',
            lastName: 'New',
          );

      expect(result.isRight(), isTrue);
      expect(current(container)?.accessToken, 'fresh');
      expect((await _rawStorage()).containsKey(_storageKey), isTrue);
    });

    test('a taken email returns the failure and stays signed out', () async {
      when(
        () => repository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
        ),
      ).thenReturn(
        TaskEither.left(
          const ConflictFailure(
            statusCode: 409,
            messageCode: 'error.userAlreadyExist',
          ),
        ),
      );
      final container = containerWithMock();
      await container.read(sessionControllerProvider.future);

      final result = await container
          .read(sessionControllerProvider.notifier)
          .register(
            email: 'n@acme.example',
            password: 'longenough',
            firstName: 'Nia',
            lastName: 'New',
          );

      expect(result.getLeft().toNullable(), isA<ConflictFailure>());
      expect(current(container), isNull);
    });
  });

  group('signOut', () {
    Future<ProviderContainer> signedIn() async {
      _storeSession(_session());
      stubMe(right(_user()));
      final container = containerWithMock();
      await container.read(sessionControllerProvider.future);
      return container;
    }

    test('clears the state and storage and revokes the token', () async {
      final container = await signedIn();
      when(() => repository.logout(token: any(named: 'token')))
          .thenReturn(TaskEither.right(unit));

      await container.read(sessionControllerProvider.notifier).signOut();

      expect(current(container), isNull);
      expect(await _rawStorage(), isEmpty);
      verify(() => repository.logout(token: 'tok')).called(1);
    });

    test('still clears locally when the server answers 401', () async {
      final container = await signedIn();
      when(
        () => repository.logout(token: any(named: 'token')),
      ).thenReturn(TaskEither.left(const UnauthorizedFailure(statusCode: 401)));

      await container.read(sessionControllerProvider.notifier).signOut();

      expect(current(container), isNull);
      expect(await _rawStorage(), isEmpty);
    });

    test('still clears locally when the network is down', () async {
      final container = await signedIn();
      when(() => repository.logout(token: any(named: 'token')))
          .thenReturn(TaskEither.left(const NetworkFailure()));

      await container.read(sessionControllerProvider.notifier).signOut();

      expect(current(container), isNull);
      expect(await _rawStorage(), isEmpty);
    });

    test(
      'leaves the signed-in area at once, before the server answers',
      () async {
        final container = await signedIn();
        final pending = Completer<Either<AppFailure, Unit>>();
        when(() => repository.logout(token: any(named: 'token')))
            .thenReturn(TaskEither(() => pending.future));

        final done = container
            .read(sessionControllerProvider.notifier)
            .signOut();
        await pumpEventQueue();

        expect(current(container), isNull);
        pending.complete(right(unit));
        await done;
      },
    );

    test('when nobody is signed in it makes no server call', () async {
      final container = containerWithMock();
      await container.read(sessionControllerProvider.future);

      await container.read(sessionControllerProvider.notifier).signOut();

      verifyNever(() => repository.logout(token: any(named: 'token')));
      expect(current(container), isNull);
    });
  });

  group('expireLocally', () {
    test('clears the session without calling the server', () async {
      _storeSession(_session());
      stubMe(right(_user()));
      final container = containerWithMock();
      await container.read(sessionControllerProvider.future);

      await container.read(sessionControllerProvider.notifier).expireLocally();

      expect(current(container), isNull);
      expect(await _rawStorage(), isEmpty);
      verifyNever(() => repository.logout(token: any(named: 'token')));
    });

    test('is harmless when called twice or when signed out', () async {
      final container = containerWithMock();
      await container.read(sessionControllerProvider.future);
      final controller = container.read(sessionControllerProvider.notifier);

      await controller.expireLocally();
      await controller.expireLocally();

      expect(current(container), isNull);
    });
  });

  /// The real Dio and the real hooks, with only the network faked. This proves
  /// the getter and callback are wired to the controller and that building
  /// them does not create a provider cycle.
  group('wired to the real Dio', () {
    ProviderContainer realContainer(FakeHttpAdapter adapter) {
      final container = ProviderContainer(
        overrides: [
          tenantEnvironmentProvider.overrideWithValue(_environment()),
        ],
      );
      addTearDown(container.dispose);
      container.read(dioProvider).httpClientAdapter = adapter;
      return container;
    }

    ResponseBody userBody() =>
        FakeHttpAdapter.json(jsonEncode(_user().toJson()));

    test('restore works with no cycle, sending the stored token', () async {
      _storeSession(_session(token: 'stored'));
      final adapter = FakeHttpAdapter((_) => userBody());
      final container = realContainer(adapter);

      final session = await container.read(sessionControllerProvider.future);

      expect(session?.accessToken, 'stored');
      final request = adapter.requests.single;
      expect(request.path, '/auth/me');
      expect(request.headers['Authorization'], 'Bearer stored');
      expect(request.headers['tenant'], 'acme');
    });

    test('later requests carry the session token', () async {
      _storeSession(_session(token: 'stored'));
      final adapter = FakeHttpAdapter(
        (options) => options.path == '/auth/me'
            ? userBody()
            : FakeHttpAdapter.json('[]'),
      );
      final container = realContainer(adapter);
      await container.read(sessionControllerProvider.future);

      await container.read(dioProvider).get<dynamic>('/favourites');

      expect(adapter.requests.last.headers['Authorization'], 'Bearer stored');
    });

    test('a 401 on an authenticated call signs out locally', () async {
      _storeSession(_session());
      final adapter = FakeHttpAdapter(
        (options) => options.path == '/auth/me'
            ? userBody()
            : FakeHttpAdapter.json('{"messageCode":"x"}', status: 401),
      );
      final container = realContainer(adapter);
      await container.read(sessionControllerProvider.future);

      await container
          .read(dioProvider)
          .get<dynamic>('/favourites')
          .then((_) {}, onError: (_) {});
      await pumpEventQueue();

      expect(current(container), isNull);
      expect(await _rawStorage(), isEmpty);
    });

    test('a 401 on login does NOT sign out a signed-in session', () async {
      _storeSession(_session());
      final adapter = FakeHttpAdapter(
        (options) => options.path == '/auth/me'
            ? userBody()
            : FakeHttpAdapter.json('{"messageCode":"x"}', status: 401),
      );
      final container = realContainer(adapter);
      await container.read(sessionControllerProvider.future);

      await container
          .read(dioProvider)
          .post<dynamic>('/auth/login')
          .then((_) {}, onError: (_) {});
      await pumpEventQueue();

      expect(current(container)?.accessToken, 'tok');
    });

    test('a full sign-in then sign-out round trip', () async {
      final adapter = FakeHttpAdapter((options) {
        return switch (options.path) {
          '/auth/login' => FakeHttpAdapter.json(
            jsonEncode(_session(token: 'issued').toJson()),
          ),
          '/auth/logout' => ResponseBody.fromString('', 204),
          _ => FakeHttpAdapter.json('{}'),
        };
      });
      final container = realContainer(adapter);
      final controller = container.read(sessionControllerProvider.notifier);
      await container.read(sessionControllerProvider.future);

      await controller.signIn(email: 'a@b.c', password: 'pw');
      expect(current(container)?.accessToken, 'issued');

      await controller.signOut();
      expect(current(container), isNull);
      final logout = adapter.requests.last;
      expect(logout.path, '/auth/logout');
      expect(logout.headers['Authorization'], 'Bearer issued');
    });
  });
}
