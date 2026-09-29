import 'dart:io' show SocketException;

import 'package:dio/dio.dart';

import 'app_failure.dart';

/// Turns whatever a call threw into an [AppFailure]. This is the one place
/// that knows the API's error envelope `{statusCode, messageCode, message}`.
abstract final class ApiErrorMapper {
  static AppFailure map(Object error) {
    if (error is! DioException) return const UnknownFailure();

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        return const NetworkFailure();
      case DioExceptionType.unknown:
        return error.error is SocketException
            ? const NetworkFailure()
            : const UnknownFailure();
      case DioExceptionType.cancel:
        return const UnknownFailure();
      case DioExceptionType.badResponse:
        return _fromResponse(error.response);
    }
  }

  static AppFailure _fromResponse(Response<dynamic>? response) {
    // The HTTP status is the truth; the body may be missing or not JSON
    // (a proxy's HTML error page, for example).
    final status = response?.statusCode;
    final code = _messageCode(response?.data);

    if (status == null) return UnknownFailure(messageCode: code);
    return switch (status) {
      400 || 422 => ValidationFailure(statusCode: status, messageCode: code),
      401 => UnauthorizedFailure(statusCode: status, messageCode: code),
      403 => ForbiddenFailure(statusCode: status, messageCode: code),
      404 => NotFoundFailure(statusCode: status, messageCode: code),
      409 => ConflictFailure(statusCode: status, messageCode: code),
      >= 500 => ServerFailure(statusCode: status, messageCode: code),
      _ => UnknownFailure(statusCode: status, messageCode: code),
    };
  }

  static String? _messageCode(Object? body) {
    if (body is! Map<String, dynamic>) return null;
    final code = body['messageCode'];
    return code is String && code.isNotEmpty ? code : null;
  }
}
