/// Everything that can go wrong at the data edge, as a closed set. The UI
/// switches on it exhaustively, so a new kind of failure cannot be forgotten.
///
/// [statusCode] and [messageCode] carry what the API said, when it said
/// anything. They are for choosing our own copy, never for showing the
/// server's `message`.
sealed class AppFailure {
  const AppFailure({this.statusCode, this.messageCode});

  final int? statusCode;
  final String? messageCode;
}

/// No usable response: offline, timeout, refused connection.
final class NetworkFailure extends AppFailure {
  const NetworkFailure();
}

/// 401.
final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({super.statusCode, super.messageCode});
}

/// 403. A bug in the app if it happens: the router keeps clients out of host
/// routes before any request is made.
final class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure({super.statusCode, super.messageCode});
}

/// 404.
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({super.statusCode, super.messageCode});
}

/// 400 (and 422): the request was understood but rejected.
final class ValidationFailure extends AppFailure {
  const ValidationFailure({super.statusCode, super.messageCode});
}

/// 409, such as registering an email that already exists.
final class ConflictFailure extends AppFailure {
  const ConflictFailure({super.statusCode, super.messageCode});
}

/// 5xx.
final class ServerFailure extends AppFailure {
  const ServerFailure({super.statusCode, super.messageCode});
}

/// A decoded row belongs to another tenant. The API scopes by header, so this
/// should never happen; if it does it is a bug to see, not data to show.
final class TenantMismatchFailure extends AppFailure {
  const TenantMismatchFailure();
}

/// Anything else: an unexpected status, a body we could not decode, a bug.
final class UnknownFailure extends AppFailure {
  const UnknownFailure({super.statusCode, super.messageCode});
}
