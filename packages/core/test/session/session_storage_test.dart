import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

Session _session({String tenant = 'acme', String token = 'token-1'}) => Session(
  accessToken: token,
  user: User(
    id: 'client-$tenant-1',
    tenantId: tenant,
    role: UserRole.client,
    email: 'guest@$tenant.example',
    firstName: 'Gia',
    lastName: 'Guest',
  ),
);

void main() {
  const storage = FlutterSecureStorage();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  SessionStorage storageFor(String tenant) =>
      SessionStorage(storage: storage, tenant: tenant);

  group('SessionStorage', () {
    test('reads nothing when nothing was stored', () async {
      expect(await storageFor('acme').read(), isNull);
    });

    test('writes and reads a session back', () async {
      final sessions = storageFor('acme');

      final result = await sessions.write(_session()).run();

      expect(result.isRight(), isTrue);
      expect(await sessions.read(), _session());
    });

    test('overwrites the previous session', () async {
      final sessions = storageFor('acme');

      await sessions.write(_session(token: 'old')).run();
      await sessions.write(_session(token: 'new')).run();

      expect((await sessions.read())?.accessToken, 'new');
    });

    test('clear removes the session', () async {
      final sessions = storageFor('acme');
      await sessions.write(_session()).run();

      await sessions.clear();

      expect(await sessions.read(), isNull);
    });

    test('clear on an empty store is fine', () async {
      await storageFor('acme').clear();
    });
  });

  group('tenant namespace', () {
    test('the key includes the tenant', () async {
      await storageFor('acme').write(_session()).run();

      expect((await storage.readAll()).keys, ['session.acme']);
    });

    test('a session of one tenant is invisible to another', () async {
      await storageFor('acme').write(_session()).run();

      expect(await storageFor('other').read(), isNull);
    });

    test('two tenants keep separate sessions', () async {
      await storageFor('acme').write(_session(token: 'a')).run();
      await storageFor('other')
          .write(_session(tenant: 'other', token: 'b'))
          .run();

      expect((await storageFor('acme').read())?.accessToken, 'a');
      expect((await storageFor('other').read())?.accessToken, 'b');
    });

    test('clearing one tenant leaves the other', () async {
      await storageFor('acme').write(_session()).run();
      await storageFor('other').write(_session(tenant: 'other')).run();

      await storageFor('acme').clear();

      expect(await storageFor('acme').read(), isNull);
      expect(await storageFor('other').read(), isNotNull);
    });
  });

  group('an unusable stored value counts as signed out, and is removed', () {
    final cases = <String, String>{
      'not JSON': 'this is not json',
      'JSON but not an object': '[1, 2, 3]',
      'an object of the wrong shape': '{"hello": "world"}',
      'a session with no user': '{"accessToken": "t"}',
      'a user with an unknown role': jsonEncode({
        'accessToken': 't',
        'user': {
          'id': 'x',
          'tenantId': 'acme',
          'role': 'admin',
          'email': 'e',
          'firstName': 'f',
          'lastName': 'l',
        },
      }),
      'an empty string': '',
    };

    cases.forEach((name, raw) {
      test(name, () async {
        FlutterSecureStorage.setMockInitialValues({'session.acme': raw});

        expect(await storageFor('acme').read(), isNull);
        expect(await storage.readAll(), isEmpty);
      });
    });
  });

  group('when the platform storage fails', () {
    late _MockSecureStorage failing;

    setUp(() {
      failing = _MockSecureStorage();
      when(() => failing.read(key: any(named: 'key')))
          .thenThrow(Exception('keystore unavailable'));
      when(
        () => failing.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(Exception('keystore unavailable'));
      when(() => failing.delete(key: any(named: 'key')))
          .thenThrow(Exception('keystore unavailable'));
    });

    test('read returns null instead of throwing', () async {
      final sessions = SessionStorage(storage: failing, tenant: 'acme');

      expect(await sessions.read(), isNull);
    });

    test('write returns a failure instead of throwing', () async {
      final sessions = SessionStorage(storage: failing, tenant: 'acme');

      final result = await sessions.write(_session()).run();

      expect(result.getLeft().toNullable(), isA<UnknownFailure>());
    });

    test('clear never throws', () async {
      final sessions = SessionStorage(storage: failing, tenant: 'acme');

      await sessions.clear();
    });
  });

  group('sessionStorageProvider', () {
    test('is bound to the build tenant', () async {
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

      final sessions = container.read(sessionStorageProvider);
      await sessions.write(_session()).run();

      expect(sessions.tenant, 'acme');
      expect((await storage.readAll()).keys, ['session.acme']);
      expect(container.read(sessionStorageProvider), same(sessions));
    });
  });
}
