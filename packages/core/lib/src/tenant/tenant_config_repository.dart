import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../failures/app_failure.dart';
import '../network/api_call.dart';
import 'tenant_config.dart';

class TenantConfigRepository {
  const TenantConfigRepository(this._dio);

  final Dio _dio;

  /// Public endpoint; the tenant header still goes on it via the interceptor.
  TaskEither<AppFailure, TenantConfig> fetch(String slug) {
    return apiCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/tenants/$slug/runtime-config',
      );
      return TenantConfig.fromJson(response.data!);
    }).flatMap(
      // Isolation layer 5: a config for another tenant is never used.
      (config) => config.slug == slug
          ? TaskEither.right(config)
          : TaskEither.left(const TenantMismatchFailure()),
    );
  }
}
