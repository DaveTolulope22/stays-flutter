import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http_adapter.dart';

void main() {
  test('the tenant header is added to every request', () async {
    final adapter = FakeHttpAdapter();
    final dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(TenantInterceptor('acme'));

    await dio.get<dynamic>('http://api.test/listings');
    await dio.get<dynamic>('http://api.test/tenants/acme/runtime-config');

    expect(adapter.requests, hasLength(2));
    for (final request in adapter.requests) {
      expect(request.headers[TenantInterceptor.headerName], 'acme');
    }
  });

  test('the interceptor overwrites a tenant header set by a caller', () async {
    final adapter = FakeHttpAdapter();
    final dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(TenantInterceptor('acme'));

    await dio.get<dynamic>(
      'http://api.test/x',
      options: Options(headers: {'tenant': 'other'}),
    );

    expect(adapter.requests.single.headers['tenant'], 'acme');
  });

  test('dioProvider uses the environment base URL and tenant', () async {
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

    final dio = container.read(dioProvider);
    final adapter = FakeHttpAdapter();
    dio.httpClientAdapter = adapter;
    await dio.get<dynamic>('/listings');

    expect(dio.options.baseUrl, 'http://api.test');
    expect(adapter.requests.single.uri.toString(), 'http://api.test/listings');
    expect(adapter.requests.single.headers['tenant'], 'acme');
    expect(container.read(dioProvider), same(dio));
  });
}
