import 'dart:ui' show Locale;

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

// Every messageCode in the API contract (openapi ApiError.messageCode).
const _knownCodes = [
  'error.tenantRequired',
  'error.tenantUnknown',
  'error.badCredentials',
  'error.userAlreadyExist',
  'error.fieldRequired',
  'error.badRequest',
  'auth.token.invalid.UnauthorizedException',
  'auth.forbidden.ForbiddenException',
  'listing.NotFoundException',
  'route.NotFoundException',
  'error.internalServerError',
  'error.rangeTooLong',
];

AppFailure _withCode(String? code, {int status = 400}) =>
    ValidationFailure(statusCode: status, messageCode: code);

void main() {
  for (final language in ['en', 'de']) {
    group(language, () {
      final l10n = lookupAppLocalizations(Locale(language));

      group('known messageCodes', () {
        final expected = <String, String>{
          'error.tenantRequired': l10n.errorTenantSetup,
          'error.tenantUnknown': l10n.errorTenantSetup,
          'error.badCredentials': l10n.errorBadCredentials,
          'error.userAlreadyExist': l10n.errorUserAlreadyExists,
          'error.fieldRequired': l10n.errorFieldRequired,
          'error.badRequest': l10n.errorBadRequest,
          'auth.token.invalid.UnauthorizedException': l10n.errorSessionExpired,
          'auth.forbidden.ForbiddenException': l10n.errorForbidden,
          'listing.NotFoundException': l10n.errorListingNotFound,
          'route.NotFoundException': l10n.errorNotFound,
          'error.internalServerError': l10n.errorServer,
          'error.rangeTooLong': l10n.errorRangeTooLong,
        };

        test('the table covers every code in the contract', () {
          expect(expected.keys, unorderedEquals(_knownCodes));
        });

        expected.forEach((code, copy) {
          test(code, () {
            expect(failureMessage(_withCode(code), l10n), copy);
            expect(copy, isNotEmpty);
          });
        });

        test('the code wins over the failure kind', () {
          expect(
            failureMessage(
              const UnauthorizedFailure(
                statusCode: 401,
                messageCode: 'error.badCredentials',
              ),
              l10n,
            ),
            l10n.errorBadCredentials,
          );
          expect(
            failureMessage(
              const UnknownFailure(messageCode: 'listing.NotFoundException'),
              l10n,
            ),
            l10n.errorListingNotFound,
          );
        });
      });

      group('an unknown messageCode falls back by kind and status', () {
        const unknown = 'something.we.never.heard.of';
        final table = <String, (AppFailure, String)>{
          'network': (const NetworkFailure(), l10n.errorNetwork),
          '401': (
            const UnauthorizedFailure(statusCode: 401, messageCode: unknown),
            l10n.errorSessionExpired,
          ),
          '403': (
            const ForbiddenFailure(statusCode: 403, messageCode: unknown),
            l10n.errorForbidden,
          ),
          '404': (
            const NotFoundFailure(statusCode: 404, messageCode: unknown),
            l10n.errorNotFound,
          ),
          '400': (_withCode(unknown), l10n.errorRequestFailed),
          '409': (
            const ConflictFailure(statusCode: 409, messageCode: unknown),
            l10n.errorRequestFailed,
          ),
          '500': (
            const ServerFailure(statusCode: 500, messageCode: unknown),
            l10n.errorServer,
          ),
          '503': (
            const ServerFailure(statusCode: 503, messageCode: unknown),
            l10n.errorServer,
          ),
          'tenant mismatch': (
            const TenantMismatchFailure(),
            l10n.errorTenantSetup,
          ),
          'unexpected 4xx (418)': (
            const UnknownFailure(statusCode: 418, messageCode: unknown),
            l10n.errorRequestFailed,
          ),
          'unexpected 5xx (599)': (
            const UnknownFailure(statusCode: 599, messageCode: unknown),
            l10n.errorServer,
          ),
        };

        table.forEach((name, row) {
          final (failure, copy) = row;
          test(name, () {
            expect(failureMessage(failure, l10n), copy);
          });
        });
      });

      group('the final generic fallback', () {
        test('an unknown failure with no status and no code', () {
          expect(
            failureMessage(const UnknownFailure(), l10n),
            l10n.errorGeneric,
          );
        });

        test('an unknown failure with a strange status and unknown code', () {
          expect(
            failureMessage(
              const UnknownFailure(statusCode: 302, messageCode: 'x'),
              l10n,
            ),
            l10n.errorGeneric,
          );
        });
      });

      test('an empty messageCode is treated as unknown', () {
        expect(failureMessage(_withCode(''), l10n), l10n.errorRequestFailed);
      });
    });
  }

  group('every failure produces non-empty text in both languages', () {
    final failures = <AppFailure>[
      const NetworkFailure(),
      const UnauthorizedFailure(),
      const ForbiddenFailure(),
      const NotFoundFailure(),
      const ValidationFailure(),
      const ConflictFailure(),
      const ServerFailure(),
      const TenantMismatchFailure(),
      const UnknownFailure(),
      for (final code in _knownCodes) UnknownFailure(messageCode: code),
    ];

    for (final language in ['en', 'de']) {
      test(language, () {
        final l10n = lookupAppLocalizations(Locale(language));

        for (final failure in failures) {
          expect(failureMessage(failure, l10n).trim(), isNotEmpty);
        }
      });
    }
  });

  test('English and German copy differ for every specific message', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final de = lookupAppLocalizations(const Locale('de'));

    for (final code in _knownCodes) {
      expect(
        failureMessage(_withCode(code), de),
        isNot(failureMessage(_withCode(code), en)),
        reason: code,
      );
    }
  });
}
