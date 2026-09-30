import 'package:feature_auth/src/validation/auth_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateEmail', () {
    final accepted = [
      'a@b.co',
      'guest@alpine-stays.example',
      'first.last+tag@sub.domain.example',
      '  guest@example.com  ',
      'UPPER@CASE.EXAMPLE',
    ];
    for (final email in accepted) {
      test('accepts "$email"', () => expect(validateEmail(email), isNull));
    }

    final rejected = {
      '': AuthFieldError.required,
      '   ': AuthFieldError.required,
      'plainaddress': AuthFieldError.invalidEmail,
      'no-at.example.com': AuthFieldError.invalidEmail,
      '@no-user.example': AuthFieldError.invalidEmail,
      'user@': AuthFieldError.invalidEmail,
      'user@nodot': AuthFieldError.invalidEmail,
      'user@dot.': AuthFieldError.invalidEmail,
      'us er@example.com': AuthFieldError.invalidEmail,
      'two@@example.com': AuthFieldError.invalidEmail,
    };
    rejected.forEach((email, error) {
      test('rejects "$email" as $error', () {
        expect(validateEmail(email), error);
      });
    });

    test('null is required', () {
      expect(validateEmail(null), AuthFieldError.required);
    });
  });

  group('validateNewPassword', () {
    test('accepts exactly the minimum length', () {
      expect(validateNewPassword('a' * minPasswordLength), isNull);
    });

    test('rejects one character short', () {
      expect(
        validateNewPassword('a' * (minPasswordLength - 1)),
        AuthFieldError.tooShort,
      );
    });

    test('accepts a long password', () {
      expect(validateNewPassword('a' * 200), isNull);
    });

    test('empty and blank are required, not "too short"', () {
      expect(validateNewPassword(''), AuthFieldError.required);
      expect(validateNewPassword('        '), AuthFieldError.required);
      expect(validateNewPassword(null), AuthFieldError.required);
    });

    test('the length counts after trimming, like the server', () {
      expect(validateNewPassword('1234567 '), AuthFieldError.tooShort);
      expect(validateNewPassword(' 12345678 '), isNull);
    });

    test('counts characters, not bytes', () {
      expect(validateNewPassword('äöüäöüäö'), isNull);
    });
  });

  group('validateExistingPassword', () {
    test('any non-blank password is accepted, whatever its length', () {
      expect(validateExistingPassword('x'), isNull);
      expect(validateExistingPassword('short'), isNull);
    });

    test('empty and blank are required', () {
      expect(validateExistingPassword(''), AuthFieldError.required);
      expect(validateExistingPassword('   '), AuthFieldError.required);
      expect(validateExistingPassword(null), AuthFieldError.required);
    });
  });

  group('validateName', () {
    test('accepts a name', () {
      expect(validateName('Gia'), isNull);
      expect(validateName('  Gia  '), isNull);
      expect(validateName('Zoë Müller-Åberg'), isNull);
    });

    test('rejects empty and blank', () {
      expect(validateName(''), AuthFieldError.required);
      expect(validateName('    '), AuthFieldError.required);
      expect(validateName(null), AuthFieldError.required);
    });
  });

  group('cleaned', () {
    test('trims and turns null into empty', () {
      expect(cleaned('  a b  '), 'a b');
      expect(cleaned(null), '');
    });
  });
}
