import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http_adapter.dart';

String _config(String slug) => jsonEncode({
  'slug': slug,
  'name': 'Acme Stays',
  'currency': 'EUR',
  'locales': ['en'],
  'defaultLocale': 'en',
  'supportEmail': 'support@acme.example',
  'termsOfUseUrl': 'https://acme.example/terms',
  'privacyPolicyUrl': 'https://acme.example/privacy',
  'permissions': {'hostPanel': true},
  'theme': {'light': <String, String>{}, 'dark': <String, String>{}},
});

Dio _dio(FakeHttpAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'http://api.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(TenantInterceptor('acme'));

void main() {
  group('TenantConfigRepository', () {
    test('fetches the config for the slug', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(_config('acme')),
      );

      final result = await TenantConfigRepository(_dio(adapter))
          .fetch('acme')
          .run();

      expect(result.toNullable()?.name, 'Acme Stays');
      final request = adapter.requests.single;
      expect(request.path, '/tenants/acme/runtime-config');
      expect(request.headers['tenant'], 'acme');
    });

    test('a config for another tenant is a TenantMismatchFailure', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(_config('other')),
      );

      final result = await TenantConfigRepository(_dio(adapter))
          .fetch('acme')
          .run();

      expect(result.getLeft().toNullable(), isA<TenantMismatchFailure>());
    });

    test('an API error becomes an AppFailure with its messageCode', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(
          '{"statusCode":400,"messageCode":"error.tenantUnknown","message":"x"}',
          status: 400,
        ),
      );

      final failure = (await TenantConfigRepository(
        _dio(adapter),
      ).fetch('acme').run()).getLeft().toNullable();

      expect(failure, isA<ValidationFailure>());
      expect(failure?.messageCode, 'error.tenantUnknown');
    });

    test('a body that is not a config is an UnknownFailure', () async {
      final adapter = FakeHttpAdapter((_) => FakeHttpAdapter.json('{}'));

      final result = await TenantConfigRepository(_dio(adapter))
          .fetch('acme')
          .run();

      expect(result.getLeft().toNullable(), isA<UnknownFailure>());
    });
  });

  group('tenantConfigProvider', () {
    ProviderContainer containerFor(FakeHttpAdapter adapter) {
      final container = ProviderContainer(
        overrides: [
          tenantEnvironmentProvider.overrideWithValue(
            TenantEnvironment.validated(
              tenant: 'acme',
              flavor: 'acme',
              apiBaseUrl: 'http://api.test',
            ),
          ),
          dioProvider.overrideWithValue(_dio(adapter)),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('loads the config for the build tenant', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeHttpAdapter.json(_config('acme')),
      );
      final container = containerFor(adapter);

      final config = await container.read(tenantConfigProvider.future);

      expect(config.slug, 'acme');
    });

    test(
      'a failure is an AsyncError holding the AppFailure, no retry',
      () async {
        final adapter = FakeHttpAdapter(
          (_) => FakeHttpAdapter.json('{"messageCode":"error.x"}', status: 500),
        );
        final container = containerFor(adapter);

        await expectLater(
          container.read(tenantConfigProvider.future),
          throwsA(isA<ServerFailure>()),
        );
        // Riverpod 3 would retry after 200ms by default.
        await Future<void>.delayed(const Duration(milliseconds: 600));

        expect(adapter.requests, hasLength(1));
        expect(
          container.read(tenantConfigProvider).error,
          isA<ServerFailure>(),
        );
      },
    );

    test('invalidate retries the request', () async {
      var attempt = 0;
      final adapter = FakeHttpAdapter(
        (_) => attempt++ == 0
            ? FakeHttpAdapter.json('{}', status: 503)
            : FakeHttpAdapter.json(_config('acme')),
      );
      final container = containerFor(adapter);

      await expectLater(
        container.read(tenantConfigProvider.future),
        throwsA(isA<ServerFailure>()),
      );
      container.invalidate(tenantConfigProvider);
      final config = await container.read(tenantConfigProvider.future);

      expect(config.slug, 'acme');
      expect(adapter.requests, hasLength(2));
    });
  });
}
