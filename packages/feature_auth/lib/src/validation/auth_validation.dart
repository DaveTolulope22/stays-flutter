/// Client-side checks that mirror the server's registration rules, so a user
/// hears about a mistake before a request is made. The server stays the
/// authority and rejects the same things.
///
/// The functions return a kind of error, not text: the screens turn it into
/// translated copy. That keeps the rules pure and testable, and this file free
/// of strings.
library;

enum AuthFieldError {
  /// Nothing, or only spaces.
  required,

  /// Not shaped like an email address.
  invalidEmail,

  /// A password shorter than [minPasswordLength].
  tooShort,
}

/// The server's minimum password length.
const minPasswordLength = 8;

// Deliberately loose, like the server's "shaped like an email": something,
// an @, something, a dot, something, and no spaces.
final _emailShape = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Every input is trimmed before it is checked and before it is sent, so what
/// the user sees validated is exactly what the server receives.
String cleaned(String? raw) => raw?.trim() ?? '';

AuthFieldError? validateEmail(String? raw) {
  final value = cleaned(raw);
  if (value.isEmpty) return AuthFieldError.required;
  if (!_emailShape.hasMatch(value)) return AuthFieldError.invalidEmail;
  return null;
}

/// On sign-in an existing password only has to be present. Its length is a
/// registration rule, and enforcing it here could lock out a valid account.
AuthFieldError? validateExistingPassword(String? raw) =>
    cleaned(raw).isEmpty ? AuthFieldError.required : null;

/// For choosing a password at registration.
AuthFieldError? validateNewPassword(String? raw) {
  final value = cleaned(raw);
  if (value.isEmpty) return AuthFieldError.required;
  if (value.length < minPasswordLength) return AuthFieldError.tooShort;
  return null;
}

AuthFieldError? validateName(String? raw) =>
    cleaned(raw).isEmpty ? AuthFieldError.required : null;
