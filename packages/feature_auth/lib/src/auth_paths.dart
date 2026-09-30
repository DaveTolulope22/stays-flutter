/// The auth module's locations. Public so the shell and other packages can
/// refer to the sign-in screen without repeating the string.
abstract final class AuthPaths {
  static const base = '/auth';
  static const signIn = '/auth/sign-in';
  static const register = '/auth/register';
}
