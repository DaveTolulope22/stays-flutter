import 'package:dio/dio.dart';

/// Stamps `tenant: <slug>` on every request, public ones included (the API
/// answers 400 `error.tenantRequired` without it). There is one Dio and one
/// interceptor, so no code path can send a different tenant.
class TenantInterceptor extends Interceptor {
  TenantInterceptor(this.tenant);

  static const headerName = 'tenant';

  final String tenant;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[headerName] = tenant;
    handler.next(options);
  }
}
