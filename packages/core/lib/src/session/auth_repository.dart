import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../failures/app_failure.dart';
import '../network/api_call.dart';
import '../network/auth_interceptor.dart';
import 'session.dart';
import 'user.dart';

/// The `/auth/*` endpoints. It only talks to the API; keeping the result (the
/// stored session, the signed-in state) is the session controller's job.
///
/// Every user that comes back is checked against the build's tenant. A user of
/// another tenant becomes a [TenantMismatchFailure] and is never used.
class AuthRepository {
  const AuthRepository({required this.dio, required this.tenant});

  final Dio dio;
  final String tenant;

  TaskEither<AppFailure, Session> login({
    required String email,
    required String password,
  }) => _session(
    () => dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    ),
  );

  TaskEither<AppFailure, Session> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) => _session(
    () => dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      },
    ),
  );

  /// The user behind [token]. The token is passed explicitly because on
  /// launch the session is not restored yet, so the interceptor has none.
  TaskEither<AppFailure, User> me({required String token}) => apiCall(() async {
    final response = await dio.get<Map<String, dynamic>>(
      '/auth/me',
      options: Options(headers: AuthInterceptor.bearerHeader(token)),
    );
    return User.fromJson(response.data!);
  }).flatMap(_ownTenant);

  /// Revokes [token]. Passed explicitly because the caller has already
  /// cleared its own state by the time this runs.
  TaskEither<AppFailure, Unit> logout({required String token}) =>
      apiCall(() async {
        await dio.post<void>(
          '/auth/logout',
          options: Options(headers: AuthInterceptor.bearerHeader(token)),
        );
        return unit;
      });

  TaskEither<AppFailure, Session> _session(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) => apiCall(() async {
    final response = await request();
    return Session.fromJson(response.data!);
  }).flatMap((session) => _ownTenant(session.user).map((_) => session));

  TaskEither<AppFailure, User> _ownTenant(User user) => user.tenantId == tenant
      ? TaskEither.right(user)
      : TaskEither.left(const TenantMismatchFailure());
}
