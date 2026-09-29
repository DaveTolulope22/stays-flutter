import 'package:dio/dio.dart';

import 'page_info.dart';

/// One page of a cursor-paginated list: the rows and where the page sits.
class CursorPage<T> {
  const CursorPage({
    required this.items,
    this.total,
    this.nextCursor,
    this.prevCursor,
  });

  /// Builds a page from a list response: a bare JSON array for the items and
  /// the position headers for the rest. Throws if the body is not an array of
  /// objects; call it inside `apiCall` so that becomes an `UnknownFailure`.
  factory CursorPage.fromResponse(
    Response<dynamic> response,
    T Function(Map<String, dynamic> json) decode,
  ) {
    final body = response.data;
    if (body is! List<dynamic>) {
      throw FormatException(
        'Expected a JSON array from ${response.requestOptions.path}, '
        'got ${body.runtimeType}.',
      );
    }
    final info = PageInfo.fromHeaders(response.headers);
    return CursorPage(
      items: [for (final row in body) decode(row as Map<String, dynamic>)],
      total: info.total,
      nextCursor: info.nextCursor,
      prevCursor: info.prevCursor,
    );
  }

  final List<T> items;
  final int? total;
  final String? nextCursor;
  final String? prevCursor;

  bool get hasNext => nextCursor != null;
}
