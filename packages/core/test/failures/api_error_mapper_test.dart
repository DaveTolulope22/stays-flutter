import 'dart:io' show SocketException;

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

final _request = RequestOptions(path: '/x');

DioException _response(int status, [Object? body]) => DioException(
  requestOptions: _request,
  type: DioExceptionType.badResponse,
  response: Response<dynamic>(
    requestOptions: _request,
    statusCode: status,
    data: body,
  ),
);

Map<String, dynamic> _body(int status, String code) => {
  'statusCode': status,
  'messageCode': code,
  'message': 'server wording, never shown',
};

DioException _type(DioExceptionType type, {Object? error}) =>
    DioException(requestOptions: _request, type: type, error: error);

void main() {
  group('ApiErrorMapper status families', () {
    final table = <int, Matcher>{
      400: isA<ValidationFailure>(),
      422: isA<ValidationFailure>(),
      401: isA<UnauthorizedFailure>(),
      403: isA<ForbiddenFailure>(),
      404: isA<NotFoundFailure>(),
      409: isA<ConflictFailure>(),
      500: isA<ServerFailure>(),
      503: isA<ServerFailure>(),
      418: isA<UnknownFailure>(),
    };

    table.forEach((status, matcher) {
      test('$status', () {
        final failure = ApiErrorMapper.map(_response(status));

        expect(failure, matcher);
        expect(failure.statusCode, status);
      });
    });
  });

  group('messageCode', () {
    test('is read from the error envelope', () {
      final failure = ApiErrorMapper.map(
        _response(401, _body(401, 'error.badCredentials')),
      );

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.messageCode, 'error.badCredentials');
    });

    test('is null when the body is not JSON', () {
      final failure = ApiErrorMapper.map(
        _response(502, '<html>Bad gateway</html>'),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.messageCode, isNull);
    });

    test('is null when the body has no messageCode', () {
      final failure = ApiErrorMapper.map(_response(400, {'oops': true}));

      expect(failure.messageCode, isNull);
    });

    test('is null when messageCode is not a string', () {
      final failure = ApiErrorMapper.map(_response(400, {'messageCode': 7}));

      expect(failure.messageCode, isNull);
    });

    test('is null when the body is missing', () {
      expect(ApiErrorMapper.map(_response(404)).messageCode, isNull);
    });
  });

  group('no response', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.transformTimeout,
      DioExceptionType.connectionError,
      DioExceptionType.badCertificate,
    ]) {
      test('$type is a network failure', () {
        expect(ApiErrorMapper.map(_type(type)), isA<NetworkFailure>());
      });
    }

    test('a socket exception is a network failure', () {
      final failure = ApiErrorMapper.map(
        _type(DioExceptionType.unknown, error: const SocketException('down')),
      );

      expect(failure, isA<NetworkFailure>());
    });

    test('any other unknown error is an unknown failure', () {
      expect(
        ApiErrorMapper.map(_type(DioExceptionType.unknown, error: 'boom')),
        isA<UnknownFailure>(),
      );
    });

    test('a bad response without a response object is unknown', () {
      expect(
        ApiErrorMapper.map(_type(DioExceptionType.badResponse)),
        isA<UnknownFailure>(),
      );
    });

    test('a cancelled request is unknown', () {
      expect(
        ApiErrorMapper.map(_type(DioExceptionType.cancel)),
        isA<UnknownFailure>(),
      );
    });
  });

  test('an error that is not a DioException is unknown', () {
    expect(
      ApiErrorMapper.map(const FormatException('bad')),
      isA<UnknownFailure>(),
    );
  });
}
