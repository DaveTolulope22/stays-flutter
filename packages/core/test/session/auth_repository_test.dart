import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http_adapter.dart';

Map<String, dynamic> _user({String tenant = 'acme', String role = 'client'}) =>
    {
      'id': 'u1',
      'tenantId': tenant,
      'role': role,
      'email': 'guest@acme.example',
      'firstName': 'Gia',
      'lastName': 'Guest',
    };

String _sessionBody({String tenant = 'acme'}) =>
    jsonEncode({'accessToken': 'tok', 'user': _user(tenant: tenant)});

AuthRepository _repository(FakeHttpAdapter adapter, {String tenant = 'acme'}) =>
    AuthRepository(
      dio: Dio(BaseOptions(baseUrl: 'http://api.test'))
        ..httpClientAdapter = adapter,
      tenant: tenant,
    );

void main() {
  group('login', () {
    test('posts the credentials and returns the session', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(_sessionBody()),
      );

      final result = await _repository(adapter)
          .login(email: 'guest@acme.example', password: 'pw')
          .run();

      final session = result.getRight().toNullable();
      expect(session?.accessToken, 'tok');
      expect(session?.user.role, UserRole.client);
      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/auth/login');
      expect(request.data, {'email': 'guest@acme.example', 'password': 'pw'});
    });

    test('a wrong password is an UnauthorizedFailure with its code', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          '{"statusCode":401,"messageCode":"error.badCredentials","message":"x"}',
          status: 401,
        ),
      );

      final result = await _repository(adapter)
          .login(email: 'a@b.c', password: 'bad')
          .run();

      final failure = result.getLeft().toNullable();
      expect(failure, isA<UnauthorizedFailure>());
      expect(failure?.messageCode, 'error.badCredentials');
    });

    test('a user of another tenant is a TenantMismatchFailure', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(_sessionBody(tenant: 'other')),
      );

      final result = await _repository(adapter)
          .login(email: 'a@b.c', password: 'pw')
          .run();

      expect(result.getLeft().toNullable(), isA<TenantMismatchFailure>());
    });

    test('a body that is not a session is an UnknownFailure', () async {
      final adapter = FakeHttpAdapter((_) => FakeHttpAdapter.json('{}'));

      final result = await _repository(adapter)
          .login(email: 'a@b.c', password: 'pw')
          .run();

      expect(result.getLeft().toNullable(), isA<UnknownFailure>());
    });
  });

  group('register', () {
    test('posts all four fields and returns the session', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(_sessionBody(), status: 201),
      );

      final result = await _repository(adapter)
          .register(
            email: 'new@acme.example',
            password: 'longenough',
            firstName: 'Nia',
            lastName: 'New',
          )
          .run();

      expect(result.isRight(), isTrue);
      final request = adapter.requests.single;
      expect(request.path, '/auth/register');
      expect(request.data, {
        'email': 'new@acme.example',
        'password': 'longenough',
        'firstName': 'Nia',
        'lastName': 'New',
      });
    });

    test('an email that is taken is a ConflictFailure with its code', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          '{"statusCode":409,"messageCode":"error.userAlreadyExist","message":"x"}',
          status: 409,
        ),
      );

      final result = await _repository(adapter)
          .register(
            email: 'a@b.c',
            password: 'pw',
            firstName: 'A',
            lastName: 'B',
          )
          .run();

      final failure = result.getLeft().toNullable();
      expect(failure, isA<ConflictFailure>());
      expect(failure?.messageCode, 'error.userAlreadyExist');
    });

    test('a user of another tenant is a TenantMismatchFailure', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(_sessionBody(tenant: 'other'), status: 201),
      );

      final result = await _repository(adapter)
          .register(
            email: 'a@b.c',
            password: 'pw',
            firstName: 'A',
            lastName: 'B',
          )
          .run();

      expect(result.getLeft().toNullable(), isA<TenantMismatchFailure>());
    });
  });

  group('me', () {
    test('sends the given token explicitly and returns the user', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(jsonEncode(_user(role: 'host'))),
      );

      final result = await _repository(adapter).me(token: 'stored').run();

      expect(result.getRight().toNullable()?.role, UserRole.host);
      final request = adapter.requests.single;
      expect(request.path, '/auth/me');
      expect(request.headers['Authorization'], 'Bearer stored');
    });

    test('a revoked token is an UnauthorizedFailure', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          '{"statusCode":401,"messageCode":"auth.token.invalid.UnauthorizedException","message":"x"}',
          status: 401,
        ),
      );

      final result = await _repository(adapter).me(token: 'revoked').run();

      expect(result.getLeft().toNullable(), isA<UnauthorizedFailure>());
    });

    test('a user of another tenant is a TenantMismatchFailure', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(jsonEncode(_user(tenant: 'other'))),
      );

      final result = await _repository(adapter).me(token: 't').run();

      expect(result.getLeft().toNullable(), isA<TenantMismatchFailure>());
    });
  });

  group('logout', () {
    test('posts with the given token', () async {
      final adapter = FakeHttpAdapter((_) => ResponseBody.fromString('', 204));

      final result = await _repository(adapter).logout(token: 'abc').run();

      expect(result.isRight(), isTrue);
      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/auth/logout');
      expect(request.headers['Authorization'], 'Bearer abc');
    });

    test('an already-revoked token is reported as a failure', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          '{"statusCode":401,"messageCode":"auth.token.invalid.UnauthorizedException","message":"x"}',
          status: 401,
        ),
      );

      final result = await _repository(adapter).logout(token: 'abc').run();

      expect(result.getLeft().toNullable(), isA<UnauthorizedFailure>());
    });
  });
}
