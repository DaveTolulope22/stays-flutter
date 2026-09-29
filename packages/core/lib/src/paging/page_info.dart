import 'package:dio/dio.dart';

/// Where a page sits in the full result, read from the response headers.
///
/// The API sends the string `"null"` (not a missing header, not JSON null)
/// when there is no next or previous page. All three "no page" forms (missing,
/// empty, `"null"`) become a null cursor here, so callers test one thing.
/// Cursors are opaque: they are never decoded or built, only echoed back.
class PageInfo {
  const PageInfo({this.total, this.nextCursor, this.prevCursor});

  static const totalCountHeader = 'x-total-count';
  static const nextCursorHeader = 'x-next-cursor';
  static const prevCursorHeader = 'x-prev-cursor';

  factory PageInfo.fromHeaders(Headers headers) => PageInfo(
    total: int.tryParse(headers.value(totalCountHeader)?.trim() ?? ''),
    nextCursor: _cursor(headers.value(nextCursorHeader)),
    prevCursor: _cursor(headers.value(prevCursorHeader)),
  );

  /// Rows matching the filter before paging. Null when the header is absent
  /// or not a number.
  final int? total;
  final String? nextCursor;
  final String? prevCursor;

  static String? _cursor(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty || value == 'null') return null;
    return value;
  }
}
