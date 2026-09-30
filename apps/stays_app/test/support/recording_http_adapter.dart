import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A Dio adapter that records every request and answers like a healthy
/// favourites API. No network in tests. The shell tests use it to prove what the
/// app does NOT call.
class RecordingHttpAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  /// Every request whose path is, or is below, `/favourites`.
  List<RequestOptions> get favouritesRequests => [
    for (final request in requests)
      if (request.path == '/favourites' ||
          request.path.startsWith('/favourites/'))
        request,
  ];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.path == '/favourites' && options.method == 'GET') {
      return _json('[]', 200);
    }
    if (options.path == '/favourites' && options.method == 'POST') {
      return _json('{}', 201);
    }
    if (options.path.startsWith('/favourites/')) {
      return ResponseBody.fromString('', 204);
    }
    return _json('{"messageCode":"error.notFound"}', 404);
  }

  ResponseBody _json(String body, int status) => ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}
