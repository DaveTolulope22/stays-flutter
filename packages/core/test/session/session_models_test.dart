import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _userJson({String role = 'client'}) => {
  'id': 'client-acme-1',
  'tenantId': 'acme',
  'role': role,
  'email': 'guest@acme.example',
  'firstName': 'Gia',
  'lastName': 'Guest',
};

void main() {
  group('User.fromJson', () {
    test('decodes the contract', () {
      final user = User.fromJson(_userJson());

      expect(user.id, 'client-acme-1');
      expect(user.tenantId, 'acme');
      expect(user.role, UserRole.client);
      expect(user.email, 'guest@acme.example');
      expect(user.firstName, 'Gia');
      expect(user.lastName, 'Guest');
    });

    test('decodes both roles', () {
      expect(User.fromJson(_userJson(role: 'host')).role, UserRole.host);
      expect(User.fromJson(_userJson(role: 'client')).role, UserRole.client);
    });

    test('an unknown role fails instead of defaulting to something', () {
      expect(
        () => User.fromJson(_userJson(role: 'admin')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('a missing field fails', () {
      final json = _userJson()..remove('tenantId');

      expect(() => User.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('ignores fields the app does not know', () {
      final user = User.fromJson({..._userJson(), 'nickname': 'G'});

      expect(user.firstName, 'Gia');
    });
  });

  group('Session', () {
    final session = Session(
      accessToken: 'secret-token-123',
      user: User.fromJson(_userJson()),
    );

    test('round trips through JSON, nested user included', () {
      final json = jsonDecode(jsonEncode(session.toJson()));

      expect(Session.fromJson(json as Map<String, dynamic>), session);
    });

    test('toJson produces plain maps, so it can be stored', () {
      final json = session.toJson();

      expect(json['user'], isA<Map<String, dynamic>>());
    });

    test('decodes the login response shape', () {
      final decoded = Session.fromJson({
        'accessToken': 'abc',
        'user': _userJson(role: 'host'),
      });

      expect(decoded.accessToken, 'abc');
      expect(decoded.user.role, UserRole.host);
    });

    test('toString never contains the token', () {
      expect(session.toString(), isNot(contains('secret-token-123')));
      expect('$session', contains('guest@acme.example'));
    });

    test('a state holding a session does not leak the token either', () {
      final holder = [session].toString();

      expect(holder, isNot(contains('secret-token-123')));
    });
  });
}
