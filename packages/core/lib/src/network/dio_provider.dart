import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../tenant/tenant_environment_provider.dart';
import 'auth_hooks_provider.dart';
import 'auth_interceptor.dart';
import 'tenant_interceptor.dart';

part 'dio_provider.g.dart';

const _connectTimeout = Duration(seconds: 10);
const _receiveTimeout = Duration(seconds: 20);

/// keepAlive: the single Dio for the whole app. It is created once, so the
/// tenant header and base URL cannot differ between two call sites.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final environment = ref.watch(tenantEnvironmentProvider);
  return Dio(
      BaseOptions(
        baseUrl: environment.apiBaseUrl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
      ),
    )
    ..interceptors.addAll([
      TenantInterceptor(environment.tenant),
      AuthInterceptor(
        tokenGetter: ref.watch(authTokenGetterProvider),
        onUnauthorized: ref.watch(unauthorizedCallbackProvider),
      ),
    ]);
}
