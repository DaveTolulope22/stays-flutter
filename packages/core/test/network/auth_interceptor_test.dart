import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http_adapter.dart';

/// A Dio wired like the real one, answering every request with [status].
class _Harness {
  _Harness({this.token, int status = 200}) {
    adapter = FakeHttpAdapter(
      (_) => FakeHttpAdapter.json(
        '{"statusCode":$status,"messageCode":"x","message":"y"}',
        status: status,
      ),
    );
    dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(
          tokenGetter: () => token,
          onUnauthorized: () => signOuts++,
        ),
      );
  }

  String? token;
  int signOuts = 0;
  late final FakeHttpAdapter adapter;
  late final Dio dio;

  /// Sends a request and swallows the DioException, returning it.
  Future<DioException?> send(String path, {String method = 'GET'}) async {
    try {
      await dio.request<dynamic>(path, options: Options(method: method));
      return null;
    } on DioException catch (error) {
      return error;
    }
  }
}

void main() {
  group('Authorization header', () {
    test('is a Bearer token when signed in', () async {
      final harness = _Harness(token: 'abc');

      await harness.send('/listings');

      expect(
        harness.adapter.requests.single.headers['Authorization'],
        'Bearer abc',
      );
    });

    test('is absent when signed out', () async {
      final harness = _Harness();

      await harness.send('/listings');

      expect(
        harness.adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('follows the token as it changes, request by request', () async {
      final harness = _Harness(token: 'first');

      await harness.send('/listings');
      harness.token = 'second';
      await harness.send('/listings');
      harness.token = null;
      await harness.send('/listings');

      final headers = harness.adapter.requests.map(
        (request) => request.headers['Authorization'],
      );
      expect(headers, ['Bearer first', 'Bearer second', null]);
    });
  });

  group('a 401', () {
    test('on an authenticated call signs out, and the error still '
        'reaches the caller', () async {
      final harness = _Harness(token: 'abc', status: 401);

      final error = await harness.send('/favourites');

      expect(harness.signOuts, 1);
      expect(error?.response?.statusCode, 401);
    });

    test('on login does NOT sign out (wrong password)', () async {
      final harness = _Harness(token: 'stale', status: 401);

      await harness.send('/auth/login', method: 'POST');

      expect(harness.signOuts, 0);
    });

    test('on logout does NOT sign out (already-revoked token)', () async {
      final harness = _Harness(token: 'abc', status: 401);

      await harness.send('/auth/logout', method: 'POST');

      expect(harness.signOuts, 0);
    });

    test(
      'on /auth/me does NOT sign out here (the session handles it)',
      () async {
        final harness = _Harness(token: 'abc', status: 401);

        await harness.send('/auth/me');

        expect(harness.signOuts, 0);
      },
    );

    test('without a token does NOT sign out', () async {
      final harness = _Harness(status: 401);

      await harness.send('/favourites');

      expect(harness.signOuts, 0);
    });

    test('a path that only starts with "auth" is not an auth path', () async {
      final harness = _Harness(token: 'abc', status: 401);

      await harness.send('/authors');

      expect(harness.signOuts, 1);
    });

    test('a query string does not hide an auth path', () async {
      final harness = _Harness(token: 'abc', status: 401);

      await harness.send('/auth/me?language=de');

      expect(harness.signOuts, 0);
    });

    test(
      'each rejected request reports, so the callback must be idempotent',
      () async {
        final harness = _Harness(token: 'abc', status: 401);

        await harness.send('/favourites');
        await harness.send('/host/listings');

        expect(harness.signOuts, 2);
      },
    );
  });

  group('other statuses do NOT sign out', () {
    for (final status in [400, 403, 404, 409, 500]) {
      test('$status', () async {
        final harness = _Harness(token: 'abc', status: status);

        await harness.send('/favourites');

        expect(harness.signOuts, 0);
      });
    }
  });

  group('dioProvider wiring', () {
    test('uses the injected token getter and unauthorized callback', () async {
      var signOuts = 0;
      final container = ProviderContainer(
        overrides: [
          tenantEnvironmentProvider.overrideWithValue(
            TenantEnvironment.validated(
              tenant: 'acme',
              flavor: 'acme',
              apiBaseUrl: 'http://api.test',
            ),
          ),
          authTokenGetterProvider.overrideWithValue(() => 'abc'),
          unauthorizedCallbackProvider.overrideWithValue(() => signOuts++),
        ],
      );
      addTearDown(container.dispose);
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json('{}', status: 401),
      );
      final dio = container.read(dioProvider)..httpClientAdapter = adapter;

      await dio.get<dynamic>('/favourites').then((_) {}, onError: (_) {});

      final headers = adapter.requests.single.headers;
      expect(headers['Authorization'], 'Bearer abc');
      expect(headers['tenant'], 'acme');
      expect(signOuts, 1);
    });

    test('defaults to no token and does nothing on 401', () async {
      final container = ProviderContainer(
        overrides: [
          tenantEnvironmentProvider.overrideWithValue(
            TenantEnvironment.validated(
              tenant: 'acme',
              flavor: 'acme',
              apiBaseUrl: 'http://api.test',
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json('{}', status: 401),
      );
      final dio = container.read(dioProvider)..httpClientAdapter = adapter;

      await dio.get<dynamic>('/x').then((_) {}, onError: (_) {});

      expect(
        adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
    });
  });
}
