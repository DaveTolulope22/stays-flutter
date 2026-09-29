import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns the value on success', () async {
    final result = await apiCall(() async => 42).run();

    expect(result.getOrElse((_) => -1), 42);
  });

  test('turns a DioException into an AppFailure', () async {
    final result = await apiCall<int>(
      () async => throw DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionTimeout,
      ),
    ).run();

    expect(result.getLeft().toNullable(), isA<NetworkFailure>());
  });

  test('turns a decoding error into an unknown failure', () async {
    final result = await apiCall<int>(
      () async => throw const FormatException('bad json'),
    ).run();

    expect(result.getLeft().toNullable(), isA<UnknownFailure>());
  });
}
