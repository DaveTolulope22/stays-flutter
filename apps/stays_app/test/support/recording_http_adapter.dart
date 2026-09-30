import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A Dio adapter that records every request and answers like a healthy
/// favourites and host API. No network in tests. The shell tests use it to prove
/// what the app does NOT call.
class RecordingHttpAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  /// Every request whose path is, or is below, `/favourites`.
  List<RequestOptions> get favouritesRequests => [
    for (final request in requests)
      if (request.path == '/favourites' ||
          request.path.startsWith('/favourites/'))
        request,
  ];

  /// Every request whose path is, or is below, `/host`. Not the app's own
  /// "host area not available" route: that is a location, never an API path.
  List<RequestOptions> get hostRequests => [
    for (final request in requests)
      if (request.path == '/host' || request.path.startsWith('/host/')) request,
  ];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final path = options.path;
    final method = options.method;
    if (path == '/favourites' && method == 'GET') return _json('[]', 200);
    if (path == '/favourites' && method == 'POST') return _json('{}', 201);
    if (path.startsWith('/favourites/')) {
      return ResponseBody.fromString('', 204);
    }
    if (path == '/host/listings' && method == 'GET') return _json('[]', 200);
    if (path.endsWith('/blocked-days') && method == 'GET') {
      return _json('[]', 200);
    }
    if (path.endsWith('/blocked-days') && method == 'POST') {
      return _json('{}', 201);
    }
    if (path.contains('/blocked-days/') && method == 'DELETE') {
      return ResponseBody.fromString('', 204);
    }
    if (path.endsWith('/bookings') && method == 'GET') return _json('[]', 200);
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
