import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Answers requests from a callback and records them. No network in tests.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter([this._respond = _ok]);

  final ResponseBody Function(RequestOptions options) _respond;
  final requests = <RequestOptions>[];

  static ResponseBody _ok(RequestOptions options) => json('{}');

  static ResponseBody json(String body, {int status = 200}) =>
      ResponseBody.fromString(
        body,
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _respond(options);
  }

  @override
  void close({bool force = false}) {}
}
