/// The auth module's locations. Public so the shell and other packages can
/// refer to the sign-in screen without repeating the string.
abstract final class AuthPaths {
  static const base = '/auth';
  static const signIn = '/auth/sign-in';

  /// Register is a child of sign-in, so opening it always leaves sign-in
  /// underneath and a system back has something to return to.
  static const registerSegment = 'register';
  static const register = '$signIn/$registerSegment';
}
