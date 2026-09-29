import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

// Fake slugs on purpose: the code has no list of real tenants.
const _api = 'http://127.0.0.1:8080';

TenantEnvironment _validate({
  required String tenant,
  required String? flavor,
}) => TenantEnvironment.validated(
  tenant: tenant,
  flavor: flavor,
  apiBaseUrl: _api,
);

void main() {
  group('TenantEnvironment.validated', () {
    test('accepts a tenant equal to the flavor', () {
      final env = _validate(tenant: 'acme', flavor: 'acme');

      expect(env.tenant, 'acme');
      expect(env.apiBaseUrl, _api);
    });

    test('rejects an empty tenant', () {
      expect(
        () => _validate(tenant: '', flavor: 'acme'),
        throwsA(isA<TenantEnvironmentError>()),
      );
    });

    test('rejects a blank tenant', () {
      expect(
        () => _validate(tenant: '  ', flavor: '  '),
        throwsA(isA<TenantEnvironmentError>()),
      );
    });

    test('rejects a tenant that differs from the flavor', () {
      expect(
        () => _validate(tenant: 'acme', flavor: 'other'),
        throwsA(
          isA<TenantEnvironmentError>().having(
            (e) => e.message,
            'message',
            allOf(contains('acme'), contains('other')),
          ),
        ),
      );
    });

    test('rejects a build with no flavor at all', () {
      expect(
        () => _validate(tenant: 'acme', flavor: null),
        throwsA(isA<TenantEnvironmentError>()),
      );
    });

    test('is case sensitive', () {
      expect(
        () => _validate(tenant: 'Acme', flavor: 'acme'),
        throwsA(isA<TenantEnvironmentError>()),
      );
    });
  });

  test('default API base URL suits a USB phone with adb reverse', () {
    expect(TenantEnvironment.defaultApiBaseUrl, 'http://127.0.0.1:8080');
  });
}
