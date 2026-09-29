import 'package:core/core.dart';

import 'generated/app_localizations.dart';

/// The text to show a user for [failure], in our own words and the user's
/// language. It never receives, and so can never show, the server's `message`.
///
/// It looks for the most specific copy first and always ends with something:
/// 1. the failure's `messageCode`, if we know it,
/// 2. otherwise its kind or, for an unrecognised status, its status family
///    (4xx "could not be completed", 5xx "our side"),
/// 3. otherwise the generic message.
String failureMessage(AppFailure failure, AppLocalizations l10n) {
  return _byMessageCode(failure.messageCode, l10n) ??
      _byKind(failure, l10n) ??
      l10n.errorGeneric;
}

String? _byMessageCode(String? code, AppLocalizations l10n) => switch (code) {
  'error.tenantRequired' || 'error.tenantUnknown' => l10n.errorTenantSetup,
  'error.badCredentials' => l10n.errorBadCredentials,
  'error.userAlreadyExist' => l10n.errorUserAlreadyExists,
  'error.fieldRequired' => l10n.errorFieldRequired,
  'error.badRequest' => l10n.errorBadRequest,
  'auth.token.invalid.UnauthorizedException' => l10n.errorSessionExpired,
  'auth.forbidden.ForbiddenException' => l10n.errorForbidden,
  'listing.NotFoundException' => l10n.errorListingNotFound,
  'route.NotFoundException' => l10n.errorNotFound,
  'error.internalServerError' => l10n.errorServer,
  'error.rangeTooLong' => l10n.errorRangeTooLong,
  _ => null,
};

String? _byKind(AppFailure failure, AppLocalizations l10n) => switch (failure) {
  NetworkFailure() => l10n.errorNetwork,
  UnauthorizedFailure() => l10n.errorSessionExpired,
  ForbiddenFailure() => l10n.errorForbidden,
  NotFoundFailure() => l10n.errorNotFound,
  ValidationFailure() || ConflictFailure() => l10n.errorRequestFailed,
  ServerFailure() => l10n.errorServer,
  TenantMismatchFailure() => l10n.errorTenantSetup,
  UnknownFailure(:final statusCode) => _byStatusFamily(statusCode, l10n),
};

String? _byStatusFamily(int? status, AppLocalizations l10n) {
  if (status == null) return null;
  if (status >= 500) return l10n.errorServer;
  if (status >= 400) return l10n.errorRequestFailed;
  return null;
}
