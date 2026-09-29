import 'package:dio/dio.dart';

/// Returns the current access token, or null when signed out. Called on every
/// request, so the interceptor never holds a stale token.
typedef AuthTokenGetter = String? Function();

/// Called when an authenticated request was rejected with 401, meaning the
/// session is no longer valid. It should sign out locally and must be safe to
/// call more than once (several in-flight requests can fail together).
typedef UnauthorizedCallback = void Function();

/// Adds the Bearer token and reports a dead session.
///
/// It gets the token through a getter, not by watching the session provider:
/// the session needs Dio for `/auth/me`, so watching it from here would be a
/// provider cycle.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokenGetter, required this.onUnauthorized});

  static const _authorization = 'Authorization';

  final AuthTokenGetter tokenGetter;
  final UnauthorizedCallback onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenGetter();
    if (token != null) {
      options.headers[_authorization] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_meansSessionIsDead(err)) onUnauthorized();
    // The error always continues, so the caller still gets its failure.
    handler.next(err);
  }

  /// A 401 ends the session only when the request carried a token AND is not
  /// an auth call. Login answers 401 `error.badCredentials` for a wrong
  /// password, and logout answers 401 for an already-revoked token; neither
  /// says anything about the current session.
  bool _meansSessionIsDead(DioException err) {
    if (err.response?.statusCode != 401) return false;
    if (!err.requestOptions.headers.containsKey(_authorization)) return false;
    return !_isAuthPath(err.requestOptions.uri.path);
  }

  static bool _isAuthPath(String path) =>
      path == '/auth' || path.startsWith('/auth/');
}
